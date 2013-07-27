
#import <UIKit/UIKit.h>

@class SinaOAuthEngine, SinaOAuthController;

@protocol SinaOAuthControllerDelegate <NSObject>
@optional
- (void)SinaOAuthController:(SinaOAuthController *)controller;
- (void)SinaOAuthControllerFailed:(SinaOAuthController *)controller;
- (void)SinaOAuthControllerCanceled:(SinaOAuthController *)controller;
@end

//
@interface SinaOAuthController : UIViewController <UIWebViewDelegate> 
{
	SinaOAuthEngine	*_engine;
	UIWebView *_webView;
	UINavigationBar *_navBar;
	UIImageView *_backgroundView;
	
	id <SinaOAuthControllerDelegate> _delegate;
	UIView *_blockerView;

	UIInterfaceOrientation _orientation;
	BOOL _loading;
}

@property (nonatomic, readwrite, retain) SinaOAuthEngine *engine;
@property (nonatomic, readwrite, assign) id <SinaOAuthControllerDelegate> delegate;
@property (nonatomic, readonly) UINavigationBar *navigationBar;

+ (SinaOAuthController *)controllerToEnterCredentialsWithSinaEngine: (SinaOAuthEngine *) engine 
															   delegate: (id <SinaOAuthControllerDelegate>) delegate 
														 forOrientation:(UIInterfaceOrientation)theOrientation;
+ (SinaOAuthController *)controllerToEnterCredentialsWithSinaEngine: (SinaOAuthEngine *) engine 
															   delegate: (id <SinaOAuthControllerDelegate>) delegate;
+ (BOOL)credentialEntryRequiredWithSinaEngine: (SinaOAuthEngine *) engine;

@end
