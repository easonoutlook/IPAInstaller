
@class OAToken;
@class OAConsumer;

@protocol SinaOAuthEngineDelegate 
@optional
- (void)storeCachedSinaOAuthData:(NSString *)data;
- (NSString *)cachedSinaOAuthData;
- (void)sinaOAuthConnectionFailedWithData:(NSData *)data;

- (void)requestSucceeded;
- (void)requestFailed:(NSError *)error;

@end

@interface SinaOAuthEngine : NSObject {
	NSString *_consumerSecret;
	NSString *_consumerKey;
	NSURL *_requestTokenURL;
	NSURL *_accessTokenURL;
	NSURL *_authorizeURL;
	
	NSString *_pin;
	
	__weak NSObject<SinaOAuthEngineDelegate> *_delegate;
	
@private
	OAConsumer *_consumer;
	OAToken *_requestToken;
	OAToken	*_accessToken; 
}

@property (nonatomic, retain) NSString *consumerSecret, *consumerKey;
@property (nonatomic, retain) NSURL *requestTokenURL, *accessTokenURL, *authorizeURL;
@property (nonatomic, readonly) BOOL OAuthSetup;
@property (nonatomic, retain) NSObject<SinaOAuthEngineDelegate> *delegate;

- (SinaOAuthEngine *)initOAuthWithDelegate:(NSObject *)delegate;
- (BOOL)isAuthorized;

- (void)requestAccessToken;
- (void)requestRequestToken;
- (void)clearAccessToken;

- (void)sendUpdate:(NSString *)msg;

@property(nonatomic, readwrite, retain) NSString *pin;
@property(nonatomic, readonly) NSURLRequest *authorizeURLRequest;
@property(nonatomic, readonly) OAConsumer *consumer;

@end
