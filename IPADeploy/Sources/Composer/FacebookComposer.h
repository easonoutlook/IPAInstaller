
#import <UIKit/UIKit.h>
#import "FBConnect.h"

@interface FacebookComposer : UIViewController <FBSessionDelegate, FBRequestDelegate, FBDialogDelegate>
{	
	UIAlertView *_alertForSending;
	
	NSString *_contentTitle;
	NSString *_contentString;
	
	// Facebook session
	FBSession * _fbSession;	
	
	UITextView *_content;
	
	NSString *_link;
	
	NSString *_title2;
	
	NSString *_key;
	NSString *_secret;
	NSString *_downloadUrl;
	
	UISegmentedControl *_segment;
}

- (id)initWithTitle:(NSString *)title 
	   contentTitle:(NSString *)title2 
			content:(NSString *)content 
			   link:(NSString *)link
				key:(NSString *)key 
			 secret:(NSString *)secret
		downloadURL:(NSString *)url;

@end
