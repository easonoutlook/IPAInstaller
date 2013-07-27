
#import "AppDelegate.h"
#import "MoreController.h"
#import "IPADeploy.h"


@implementation MoreController

#pragma mark Generic methods

// Constructor
- (id)init
{
	[super initWithStyle:UITableViewStyleGrouped];
	return self;
}

// Destructor
- (void)dealloc
{
	[super dealloc];
}

#pragma mark View methods

// Creates the view that the controller manages.
//- (void)loadView
//{
//	[super loadView];
//}

// Do additional setup after loading the view.
- (void)viewDidLoad
{
	self.title = NSLocalizedString(@"More", @"更多");
	
	[super viewDidLoad];
}

// Called after the view controller's view is released and set to nil.
//- (void)viewDidUnload
//{
//	[super viewDidUnload];
//}

// Called when the view is about to made visible.
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

// Called after the view was dismissed, covered or otherwise hidden.
//- (void)viewWillDisappear:(BOOL)animated
//{
//	[super viewWillDisappear:animated];
//}

// Override to allow rotation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

// Notifies when rotation begins.
//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
//}

// Release any cached data, images, etc that aren't in use.
//- (void)didReceiveMemoryWarning
//{
//	[super didReceiveMemoryWarning];
//}


#pragma Table methods


//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 0;
}

//
 -(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Item"];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Item"] autorelease];
	}
	
	//cell.textLabel.text = [_items objectAtIndex:indexPath.row];
	
	return cell;
}


#pragma mark Action sheet

//
- (void)onAction:(UIBarButtonItem *)sender
{
/*	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Share", @"分享")
															 delegate:self
													cancelButtonTitle:NSLocalizedString(@"Cancel", @"取消")
											   destructiveButtonTitle:nil
													otherButtonTitles:
								  @"http://google.com",
								  @"http://51ipa.com",
								  @"http://55ipa.com",
								  @"http://loveipa.com",
								  @"http://ipa-down.com", 
								  @"http://apptrackr.org",
								  nil];
	if ([actionSheet respondsToSelector:@selector(showFromBarButtonItem: animated:)])
	{
		[actionSheet showFromBarButtonItem:sender animated:YES];
	}
	else
	{
		[actionSheet showFromToolbar:self.navigationController.toolbar];
	}
	[actionSheet release];*/
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

}


#pragma mark Web view

//
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSURL *url = (NSURL*)alertView.tag;
	if (url == nil) return;
	
	if (buttonIndex == 1)
	{
		UIAlertView *alertView2 = [UIAlertView alertWithTask:self title:NSLocalizedString(@"Downloading...", @"正在下载…")];
		alertView2.tag = alertView.tag;
	}
	else
	{
		[url release];
	}
}

//
- (void)doTask:(UIAlertView *)alertView
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSString *result;
	NSURL *url = (NSURL*)alertView.tag;
	do
	{
		NSString *path = NSUtil::CacheUrlPath(url.absoluteString);

		if (!NSUtil::IsFileExist(path))
		{
			UIUtil::ShowNetworkIndicator(YES);
			NSData *data = [[NSData alloc] initWithContentsOfURL:url];
			UIUtil::ShowNetworkIndicator(NO);
			if (data == nil)
			{
				result = NSLocalizedString(@"IPA download failed!", @"IPA 下载失败！");
				break;
			}
			
			[data writeToFile:path atomically:NO];
			[data release];	
		}

		[alertView performSelectorOnMainThread:@selector(setTitle:) withObject:NSLocalizedString(@"Installing...", @"正在安装…") waitUntilDone:YES];
		if (IPAIsInstalled(path))
		{
			result = NSLocalizedString(@"IPA already installed!", @"IPA 已经安装过！");
			break;
		}
		
		IPAResult ret = IPAInstall(path);
		if (ret == IPAResultOK)
		{
			result = NSLocalizedString(@"IPA installation completed successfully.", @"IPA 安装成功。");
		}
		else
		{
			[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
			result = [NSString stringWithFormat:NSLocalizedString(@"IPA installation failed.\n\nError: %#08X", @"IPA 安装失败。\n\n错误代码：%#08X"), ret];
		}
	}
	while (NO);
	
	[alertView dismissOnMainThread];
	[self performSelectorOnMainThread:@selector(endTask:) withObject:result waitUntilDone:YES];
	[url release];
	[pool release];
}

//
- (void)endTask:(NSString *)result
{
	[UIAlertView alertWithTitle:result];
}


#pragma mark Event methods

@end
