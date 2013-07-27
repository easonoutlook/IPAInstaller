
#import "AppDelegate.h"
#import "BrowseController.h"

//
@implementation AppDelegate
@synthesize window=_window;
@synthesize controller=_controller;

#pragma mark Generic methods

// Destructor
- (void)dealloc
{
	[_controller release];
	[_window release];
	[super dealloc];
}

//
#ifdef _MobClick
- (NSString *)appKey
{
	return NSUtil::BundleInfo(@"MobClickKey");
}
#endif


#pragma mark Monitoring Application State Changes

// The application has launched and may have additional launch options to handle.
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef _MobClick
	[MobClick setDelegate:self];
	[MobClick appLaunched];
#endif

	UIUtil::ShowStatusBar(YES);

	// Create window
	CGRect frame = UIUtil::ScreenFrame();
	frame.origin.y = 0;
	_window = [[UIWindow alloc] initWithFrame:frame];

	// Create controller
	NSMutableArray *controllers = [NSMutableArray arrayWithCapacity:4];
	static const struct {NSString *cls; UITabBarSystemItem item;} c_controllers[] =
	{
		{@"BrowseController", UITabBarSystemItemFeatured},
		{@"DownloadController", UITabBarSystemItemDownloads},
		{@"InstalledController", UITabBarSystemItemFavorites},
		{@"MoreController", UITabBarSystemItemMore},
	};
	for (NSInteger i = 0; i < sizeof(c_controllers) / sizeof(c_controllers[0]); i++)
	{
		BrowseController *controller = [[[NSClassFromString(c_controllers[i].cls) alloc] init] autorelease];
		UIViewController *navigator = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
		navigator.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:c_controllers[i].item tag:i] autorelease];
		[controllers addObject:navigator];
	}
	
	_controller = [[UITabBarController alloc] init];
	_controller.viewControllers = controllers;
	_controller.selectedIndex = [Settings::Get(@"TabIndex") intValue];

	// Show main view
	[_window addSubview:_controller.view];
	[_window makeKeyAndVisible];

	UIUtil::ShowSplashView(_controller.view);
		
	return YES;
}

// The application is about to terminate.
- (void)applicationWillTerminate:(UIApplication *)application
{
#ifdef _MobClick
	[MobClick appTerminated];
#endif
	
	Settings::Save(@"TabIndex", [NSNumber numberWithInt:_controller.selectedIndex]);
}

// Tells the delegate that the application is about to become inactive.
- (void)applicationWillResignActive:(UIApplication *)application
{
#ifdef _MobClick
	[MobClick appTerminated];
#endif
}

// The application has become active.
//- (void)applicationDidBecomeActive:(UIApplication *)application
//{
//}

// Tells the delegate that the application is about to enter the foreground.
- (void)applicationWillEnterForeground:(UIApplication *)application
{
#ifdef _MobClick
	[MobClick setDelegate:self];
	[MobClick appLaunched];
#endif
	
	id controller = ((UINavigationController*)_controller.currentViewController).visibleViewController;
	if ([controller respondsToSelector:@selector(reloadData)])
	{
		[controller reloadData];
	}
}

// Tells the delegate that the application is now in the background.
- (void)applicationDidEnterBackground:(UIApplication *)application
{
	Settings::Save(@"TabIndex", [NSNumber numberWithInt:_controller.selectedIndex]);
}


#pragma mark Managing Status Bar Changes

//The interface orientation of the status bar is about to change.
//- (void)application:(UIApplication *)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration
//{
//}

// The interface orientation of the status bar has changed.
//- (void)application:(UIApplication *)application didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation
//{
//}

// The frame of the status bar is about to change.
//- (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame
//{
//}

// The frame of the status bar has changed.
//- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame
//{
//}


#pragma mark Responding to System Notifications

// There is a significant change in the time.
//- (void)applicationSignificantTimeChange:(UIApplication *)application
//{
//}

// The application receives a memory warning from the system.
//- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
//{
//}

// Open a resource identified by URL.
//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
//{
//	return NO;
//}

@end
