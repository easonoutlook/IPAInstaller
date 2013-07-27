
#import "OAConsumer.h"
#import "SinaOAMutableURLRequest.h"
#import "OADataFetcher.h"

#import "SinaOAuthEngine.h"

#define RequestURL @"http://api.t.sina.com.cn/oauth/request_token"
#define AuthorizeURL @"http://api.t.sina.com.cn/oauth/authorize"
#define AccessURL @"http://api.t.sina.com.cn/oauth/access_token"
#define UpdateURL @"http://api.t.sina.com.cn/statuses/update.json"

@interface SinaOAuthEngine(private)

- (void)requestURL:(NSURL *)url token:(OAToken *)token onSuccess:(SEL)success onFail:(SEL)fail verifier:(BOOL)addVerifier;
- (void)outhTicketFailed:(OAServiceTicket *)ticket data:(NSData *)data;

- (void)setRequestToken:(OAServiceTicket *)ticket withData:(NSData *)data;
- (void)setAccessToken:(OAServiceTicket *)ticket withData:(NSData *)data;

@end

@implementation SinaOAuthEngine

@synthesize pin = _pin, requestTokenURL = _requestTokenURL, accessTokenURL = _accessTokenURL, authorizeURL = _authorizeURL;
@synthesize consumerSecret = _consumerSecret, consumerKey = _consumerKey;
@synthesize delegate = _delegate;

//
- (NSString *)_generateTimestamp 
{
    return [NSString stringWithFormat:@"%d", time(NULL)];
}

//
- (NSString *)_generateNonce 
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    NSMakeCollectable(theUUID);
    return (NSString *)string;
}

//
- (void) dealloc 
{
	self.pin = nil;
	self.authorizeURL = nil;
	self.requestTokenURL = nil;
	self.accessTokenURL = nil;
	
	[_accessToken release];
	[_requestToken release];
	[_consumer release];
	[super dealloc];
}

- (SinaOAuthEngine *)initOAuthWithDelegate:(NSObject *)delegate 
{
    if (self = (id) [super init]) 
	{
		self.requestTokenURL = [NSURL URLWithString:RequestURL];
		self.accessTokenURL = [NSURL URLWithString:AccessURL];
		self.authorizeURL = [NSURL URLWithString:AuthorizeURL];
		
		self.delegate = delegate;
	}
    return self;
}

//
- (BOOL) OAuthSetup 
{
	return _consumer != nil;
}

//
- (OAConsumer *)consumer 
{
	if (_consumer) return _consumer;
	_consumer = [[OAConsumer alloc] initWithKey: self.consumerKey secret: self.consumerSecret];
	return _consumer;
}

//
- (BOOL)isAuthorized 
{	
	if (_accessToken.key && _accessToken.secret) return YES;
	
	//first, check for cached creds
	NSString *accessTokenString = [_delegate respondsToSelector: @selector(cachedSinaOAuthData)] ? [(id) _delegate cachedSinaOAuthData] : @"";
	
	if (accessTokenString.length) 
	{				
		[_accessToken release];
		_accessToken = [[OAToken alloc] initWithHTTPResponseBody: accessTokenString];
		
		if (_accessToken.key && _accessToken.secret) return YES;
	}
	
	[_accessToken release];
	_accessToken = [[OAToken alloc] initWithKey: nil secret: nil];
	return NO;
}

//
- (NSURLRequest *)authorizeURLRequest 
{
	if (!_requestToken.key && _requestToken.secret) return nil;
	
	NSString *tt = [_requestToken.key URLEncodedString];
	NSString *url = [NSString stringWithFormat:@"%@?oauth_token=%@",AuthorizeURL, tt];
	
	_Log(@"%@", url);
	
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
	return [request autorelease];
}

//
- (void)requestRequestToken 
{
	[self requestURL:self.requestTokenURL 
			   token:nil 
		   onSuccess:@selector(setRequestToken:withData:) 
			  onFail:@selector(outhTicketFailed:data:) 
			verifier:NO];
}

//
- (void)requestAccessToken 
{
	[self requestURL:self.accessTokenURL 
			   token:_requestToken 
		   onSuccess:@selector(setAccessToken:withData:) 
			  onFail:@selector(outhTicketFailed:data:)
			verifier:YES];
}

//
- (void)clearAccessToken 
{
	if ([_delegate respondsToSelector: @selector(storeCachedSinaOAuthData:)]) [(id) _delegate storeCachedSinaOAuthData:@""];
	[_accessToken release];
	_accessToken = nil;
	[_consumer release];
	_consumer = nil;
	self.pin = nil;
	[_requestToken release];
	_requestToken = nil;
}

- (void)setPin:(NSString *)pin 
{
	[_pin autorelease];
	_pin = [pin retain];
	
	_accessToken.pin = pin;
	_requestToken.pin = pin;
}

//
- (void)requestURL:(NSURL *)url token:(OAToken *)token onSuccess:(SEL)success onFail:(SEL)fail verifier:(BOOL)addVerifier
{	
	OAHMAC_SHA1SignatureProvider *hmacSha1Provider = [[[OAHMAC_SHA1SignatureProvider alloc] init] autorelease];
	SinaOAMutableURLRequest	*request = [[[SinaOAMutableURLRequest alloc] initWithURL:url 
																	consumer:self.consumer 
																	   token:token 
																	   realm:nil 
														   signatureProvider:hmacSha1Provider
																	   nonce:[self _generateNonce]
																   timestamp:[self _generateTimestamp]
																    verifier:addVerifier] autorelease];
	if (!request) return;
	
	if (self.pin.length) token.pin = self.pin;
    //[request setHTTPMethod: @"POST"];
	
    OADataFetcher *fetcher = [[[OADataFetcher alloc] init] autorelease];
    [fetcher fetchDataWithRequest: request delegate:self didFinishSelector:success didFailSelector:fail];
}

//
- (void)outhTicketFailed:(OAServiceTicket *)ticket data:(NSData *)data 
{
	//_Log(@"%@",  [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);	
	if ([_delegate respondsToSelector:@selector(sinaOAuthConnectionFailedWithData:)]) 
		[(id)_delegate sinaOAuthConnectionFailedWithData:data];
}

//
- (void)setRequestToken:(OAServiceTicket *)ticket withData:(NSData *)data 
{
	if (!ticket.didSucceed || !data) return;
	
	NSString *dataString = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
	if (!dataString) return;
	
	_Log(@"%@", dataString);
	
	[_requestToken release];
	_requestToken = [[OAToken alloc] initWithHTTPResponseBody:dataString];
	
	if (self.pin.length) _requestToken.pin = self.pin;
}

// 
- (void)setAccessToken:(OAServiceTicket *)ticket withData:(NSData *)data 
{
	if (!ticket.didSucceed || !data) return;
	
	NSString *dataString = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
	if (!dataString) return;
	
	_Log(@"%@", dataString);
	
	if ([_delegate respondsToSelector: @selector(storeCachedSinaOAuthData:)]) 
		[(id)_delegate storeCachedSinaOAuthData:dataString];
	
	[_accessToken release];
	_accessToken = [[OAToken alloc] initWithHTTPResponseBody:dataString];
}

//
- (void)sendUpdate:(NSString *)msg
{	
	_Log(@"sendUpdate:%@, _accessToken [%@,%@]", msg, _accessToken.key, _accessToken.secret);
	
	OAHMAC_SHA1SignatureProvider *hmacSha1Provider = [[[OAHMAC_SHA1SignatureProvider alloc] init] autorelease];
	OAMutableURLRequest *hmacSha1Request = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:UpdateURL]
																		   consumer:self.consumer
																			  token:_accessToken
																			  realm:NULL
																  signatureProvider:hmacSha1Provider
																			  nonce:[self _generateNonce]
																		  timestamp:[self _generateTimestamp]];
	
	[hmacSha1Request setHTTPMethod:@"POST"];
	
	NSString *postStr = [NSString stringWithFormat:@"status=%@", [msg URLEncodedString]];
	NSData *postData = [NSData dataWithBytes:[postStr UTF8String] length:[postStr length]];
	[hmacSha1Request setHTTPBody:postData];
	
	OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:hmacSha1Request 
                         delegate:self
                didFinishSelector:@selector(requestDidFinish:finishedWithData:)
                  didFailSelector:@selector(requestFailed:failedWithError:)];
}

//
- (void)requestDidFinish:(OAServiceTicket *)ticket finishedWithData:(NSMutableData *)data
{
	NSString *responseBody = [[NSString alloc] initWithData:data
												   encoding:NSUTF8StringEncoding];
	_Log(@"api获取的数据:%@",responseBody);
	
	// patch...
	if ([responseBody rangeOfString: @"error_code"].location != NSNotFound) 
	{
		NSError *error = [NSError errorWithDomain:@"Sina Weibo Error" code:400 userInfo:nil];
		if ([responseBody rangeOfString: @"40025"].location != NSNotFound) 
		{
			error = [NSError errorWithDomain:@"Sina Weibo Error" code:40025 userInfo:nil];
		}
		
		if ([_delegate respondsToSelector: @selector(requestFailed:)]) 
			[(id)_delegate requestFailed:error];
		
		return;
	}
	
	if ([_delegate respondsToSelector: @selector(requestSucceeded)]) 
		[(id)_delegate requestSucceeded];
}

//
- (void)requestFailed:(OAServiceTicket *)ticket failedWithError:(NSError *)error 
{	
	if ([_delegate respondsToSelector: @selector(requestFailed:)]) 
		[(id)_delegate requestFailed:error];
}

@end
