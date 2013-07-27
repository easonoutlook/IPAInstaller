

#import <UIKit/UIKit.h>

//
@interface WebController : UIViewController <UIWebViewDelegate>
{
	NSURL *_url;
	UIBarButtonItem *_rightButton;
}

@property(nonatomic,retain) NSURL *url;
@property(nonatomic,readonly) UIWebView *webView;

- (id)initWithUrl:(NSURL *)url;

@end


//
@interface WebBrowser : WebController <UIActionSheetDelegate>
{
	BOOL _toolBarHidden;
}

//
- (void)onRefresh:(UIBarButtonItem *)sender;
- (void)onBackward:(UIBarButtonItem *)sender;
- (void)onForward:(UIBarButtonItem *)sender;
- (void)onAction:(UIBarButtonItem *)sender;

@end
