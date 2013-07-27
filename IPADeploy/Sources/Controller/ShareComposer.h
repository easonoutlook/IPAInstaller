

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "WebController.h"

// Compose mail
@interface MailComposer : MFMailComposeViewController <MFMailComposeViewControllerDelegate>
{
}
+ (id)composerWithBody:(NSString *)body subject:(NSString *)subject to:(NSArray *)recipients;
@end


// Compose SMS
// NOTICE: MessageUI.framework should select "Optional" mode
@interface SMSComposer : MFMessageComposeViewController <MFMessageComposeViewControllerDelegate>
{
}
+ (id)composerWithBody:(NSString *)body to:(NSArray *)recipients;
@end


//
@interface UIViewController (MailComposer)
- (MailComposer *)composeMail:(NSString *)body subject:(NSString *)subject to:(NSArray *)recipients;
- (SMSComposer *)composeSMS:(NSString *)body to:(NSArray *)recipients;
- (UINavigationController *)composeWeibo:(NSString *)body url:(NSString *)url key:(NSString *)key pic:(NSString *)pic uid:(NSString *)uid;
@end