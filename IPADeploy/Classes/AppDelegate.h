
#import <UIKit/UIKit.h>


//
@interface AppDelegate : NSObject <UIApplicationDelegate
#ifdef _MobClick
, MobClickDelegate
#endif
>
{
	UIWindow *_window;
	UITabBarController *_controller;	
}

//
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, readonly) UITabBarController *controller;

@end

