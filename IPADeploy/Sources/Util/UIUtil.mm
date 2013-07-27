
#import "UIUtil.h"
#import <QuartzCore/QuartzCore.h>

//
void UIUtil::PrintIndentString(NSUInteger indent, NSString *str)
{
	NSString *log = @"";
	for (NSUInteger i = 0; i < indent; i++)
	{
		log = [log stringByAppendingString:@"\t"];
	}
	log = [log stringByAppendingString:str];
	_Log(@"%@", log);
}

// Print controller and sub-controllers
void UIUtil::PrintController(UIViewController *controller, NSUInteger indent)
{
	PrintIndentString(indent, [NSString stringWithFormat:@"<Controller Description=\"%@\">", [controller description]]);

	if (controller.modalViewController)
	{
		PrintController(controller, indent + 1);
	}
	
	if ([controller isKindOfClass:[UINavigationController class]])
	{
		for (UIViewController *child in ((UINavigationController *)controller).viewControllers)
		{
			PrintController(child, indent + 1);
		}
	}
	else if ([controller isKindOfClass:[UITabBarController class]])
	{
		UITabBarController *tabBarController = (UITabBarController *)controller;
		for (UIViewController *child in tabBarController.viewControllers)
		{
			PrintController(child, indent + 1);
		}

		if (tabBarController.moreNavigationController)
		{
			PrintController(tabBarController.moreNavigationController, indent + 1);
		}
	}

	PrintIndentString(indent, @"</Controller>");
}

// Print view and subviews
void UIUtil::PrintView(UIView *view, NSUInteger indent)
{
	PrintIndentString(indent, [NSString stringWithFormat:@"<View Description=\"%@\">", [view description]]);
	
	for (UIView *child in view.subviews)
	{
		PrintView(child, indent + 1);
	}
	
	PrintIndentString(indent, @"</View>");
	
}

//
UIImageView *UIUtil::ShowSplashView(UIView *fadeInView)
{
	//
	CGRect frame = UIUtil::ScreenFrame();
	UIImageView *splashView = [[[UIImageView alloc] initWithFrame:frame] autorelease];
	splashView.image = [UIImage imageWithContentsOfFile:NSUtil::BundleSubPath(UIUtil::IsPad() ? @"Default@iPad.png" : @"Default.png")];
	splashView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[UIUtil::KeyWindow() addSubview:splashView];

	//
	//UIImage *logoImage = [UIImage imageWithContentsOfFile:NSUtil::BundleSubPath(UIUtil::IsPad() ? @"Splash@2x.png" : @"Splash.png")];
	//UIImageView *logoView = [[[UIImageView alloc] initWithImage:logoImage] autorelease];
	//logoView.center = CGPointMake(frame.size.width / 2, (frame.size.height / 2));
	//logoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	//splashView.tag = (NSInteger)logoView;
	//[splashView addSubview:logoView];

	//
	fadeInView.alpha = 0;
	[UIView beginAnimations:@"Splash" context:nil];
	[UIView setAnimationDuration:0.6];
	[UIView setAnimationDelegate:splashView];
	[UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];

	//
	fadeInView.alpha = 1;
	splashView.alpha = 0;
	//splashView.frame = CGRectInset(frame, -frame.size.width / 2, -frame.size.height / 2);
	//splashView.frame = CGRectInset(frame, frame.size.width / 2, frame.size.height / 2);

	//
	[UIView commitAnimations];
	return splashView;
}

//
void UIUtil::ShowMessage(NSString *text, UIView *view, NSUInteger duration)
{
	UILabel *label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	label.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
	label.textColor = [UIColor whiteColor];
	label.font = [UIFont systemFontOfSize:16];
	label.text = text;
	label.numberOfLines = 0;
	label.textAlignment = UITextAlignmentCenter;
	[view addSubview:label];
	
	CGRect frame2;
	CGRect frame = view.frame;
	frame2.size.width = frame.size.width * 3 / 4;
	frame2.size.height = 30 + [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(frame2.size.width, 1000) lineBreakMode:label.lineBreakMode].height;
	frame2.origin.x = (frame.size.width - frame2.size.width) / 2;
	frame2.origin.y = (frame.size.height - frame2.size.height) / 2;
	label.frame = frame2;
	label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

	CALayer *layer = label.layer;
	layer.cornerRadius = 8;
	layer.masksToBounds = YES;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelay:duration];
	[UIView setAnimationDuration:1.5];
	[UIView setAnimationDelegate:label];
	[UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
	label.alpha = 0;
	[UIView commitAnimations];
}
