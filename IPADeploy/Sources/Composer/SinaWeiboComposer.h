
#import <UIKit/UIKit.h>
#import "SinaOAuthController.h"
#import "URLShortenService.h"

@class SinaOAuthEngine;

@interface SinaWeiboComposer : UIViewController <UITextViewDelegate, SinaOAuthControllerDelegate, URLShortenServiceDelegate>
{
	UITextView *_content;
	
	SinaOAuthEngine *_sinaEngine;
	
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
