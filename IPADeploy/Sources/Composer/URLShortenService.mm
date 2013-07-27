
#import "URLShortenService.h"

static NSString * kIsgdRequestURLString = @"http://is.gd/api.php?longurl=%@";
static NSString * kSinaWeiboShorter = @"http://api.t.sina.com.cn/short_url/shorten.xml?source=%@&url_long=%@";

@implementation URLShortenService

@synthesize delegate = _delegate;

-(void) dealloc
{
	[_response release];
	[_data release];
	[_origURLString release];
	
	[super dealloc];
}

-(void) startShortingURL:(NSString *)urlString
{
	[_origURLString release];
	_origURLString = nil;
	
	[_response release];
	_response = nil;
	
	[_data release];
	_data = nil;
	
	_origURLString = [urlString retain];
	
	_isUsingSinaShorter = YES;
	
	NSURLRequest * req = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:kIsgdRequestURLString, urlString]]];
	[NSURLConnection connectionWithRequest:req delegate:self];	
}

-(void) startShortingSinaWeiboURL:(NSString *)appkey andUrl:(NSString *)urlString
{
	[_origURLString release];
	_origURLString = nil;
	
	[_response release];
	_response = nil;
	
	[_data release];
	_data = nil;
	
	_origURLString = [urlString retain];
	
	NSURLRequest * req = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:kSinaWeiboShorter, appkey, urlString]]];
	[NSURLConnection connectionWithRequest:req delegate:self];	
}

#pragma mark ----------------------- NSURLConnection delegate ----------------------------------

-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	_response = (NSHTTPURLResponse *)[response retain];
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if ( _data == nil )
		_data = [[NSMutableData alloc] init];
	
	[_data appendData:data];
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[_delegate urlShortenService:self didShortenURL:_origURLString failedWithError:[error localizedDescription]];
}

//
- (NSString *)getSinaShortenURL:(NSString *)xml 
{
    NSScanner *scanner;
    NSString *text = nil;
	
    scanner = [NSScanner scannerWithString:xml];
	
	// find start of tag
	[scanner scanUpToString:@"<url_short" intoString:nil] ; 
	
	// find end of tag
	[scanner scanUpToString:@"</url_short>" intoString:&text] ;
	
	if (!text) 
	{
		return nil;
	}
    
	xml = [text substringFromIndex:11];
	
    return xml;
	
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (_isUsingSinaShorter)
	{
		NSString * s = [[NSString alloc] initWithBytes:[_data bytes] length:[_data length] encoding:NSUTF8StringEncoding];
		
		if ( [_response statusCode] != 200 )
			[_delegate urlShortenService:self didShortenURL:_origURLString failedWithError:s];
		else
			[_delegate urlShortenService:self didShortenURL:_origURLString to:s];
		
		[s release];
	}
	else
	{
		NSString * s = [[NSString alloc] initWithBytes:[_data bytes] length:[_data length] encoding:NSUTF8StringEncoding];
		
		NSString* shortenUrl = [self getSinaShortenURL:s];
		
		if ( [_response statusCode] != 200 )
			[_delegate urlShortenService:self didShortenURL:_origURLString failedWithError:nil];
		else
			[_delegate urlShortenService:self didShortenURL:_origURLString to:shortenUrl];
		
		[s release];
	}
}

@end
