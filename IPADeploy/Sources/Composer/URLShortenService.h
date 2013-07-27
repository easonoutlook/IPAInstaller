
#import <Foundation/Foundation.h>

@class URLShortenService;

@protocol URLShortenServiceDelegate 

-(void) urlShortenService:(URLShortenService *)service didShortenURL:(NSString *)origURLString to:(NSString *)shortenURLString;
-(void) urlShortenService:(URLShortenService *)service didShortenURL:(NSString *)origURLString failedWithError:(NSString *)errorString;

@end


@interface URLShortenService : NSObject {

	id<URLShortenServiceDelegate> _delegate;
	
	NSHTTPURLResponse * _response;
	NSMutableData * _data;
	NSString * _origURLString;
	BOOL _isUsingSinaShorter;
	
}

@property (nonatomic, assign) id delegate;

-(void) startShortingURL:(NSString *)urlString;
-(void) startShortingSinaWeiboURL:(NSString *)appkey andUrl:(NSString *)urlString;

@end
