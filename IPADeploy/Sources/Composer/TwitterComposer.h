
#import <UIKit/UIKit.h>
#import "SA_OAuthTwitterController.h"
#import "URLShortenService.h"

@class SA_OAuthTwitterEngine;

@interface TwitterComposer : UIViewController <UITextViewDelegate, SA_OAuthTwitterControllerDelegate, URLShortenServiceDelegate>
{
	UITextView *_content;
	
	SA_OAuthTwitterEngine *_twitterEngine;
	
	UIAlertView *_alertForSending;
	
	NSString *_contentTitle;
	NSString *_contentString;
	
	URLShortenService * _shortenService;
	
	NSString *_link;
	
	NSString *_key;
	NSString *_secret;
	
	UISegmentedControl *_segment;
}

- (id)initWithTitle:(NSString *)title 
			content:(NSString *)content 
			   link:(NSString *)link 
				key:(NSString *)key 
			 secret:(NSString *)secret;

@end
