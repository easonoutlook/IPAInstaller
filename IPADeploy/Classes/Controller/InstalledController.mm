
#import "AppDelegate.h"
#import "InstalledController.h"
#import "IPADeploy.h"
#import <QuartzCore/QuartzCore.h>

@implementation InstalledController

#pragma mark Generic methods

// Constructor
//- (id)init
//{
//	[super init];
//	return self;
//}

// Destructor
- (void)dealloc
{
	[_items release];
	[super dealloc];
}

//
- (void)reloadData
{
	[_items release];
	_items = [IPAInstalledApps().allValues retain];
	[self.tableView reloadData];
}

//
- (void)toggleEdit:(UIBarButtonItem *)sender
{
	BOOL editing = !self.tableView.editing;
	[self.tableView setEditing:editing animated:YES];
	
	UIBarButtonSystemItem item = editing ? UIBarButtonSystemItemDone : UIBarButtonSystemItemEdit;
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:item target:self action:@selector(toggleEdit:)] autorelease];
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
	self.title = NSLocalizedString(@"Installed Apps", @"已安装程序");
	self.tableView.rowHeight = 55;
	//self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEdit:)] autorelease];

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
	
	[self reloadData];
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
	return _items.count;
}

//
 -(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Item"];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Item"] autorelease];

		cell.imageView.layer.cornerRadius = 6;
		cell.imageView.layer.masksToBounds = YES;
		cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
		//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	NSDictionary *info = [_items objectAtIndex:indexPath.row];
	
	//
	NSString *name = [info objectForKey:@"CFBundleDisplayName"];
	if (name == nil) name = [info objectForKey:@"CFBundleName"];
	cell.textLabel.text = name;
	
	//
	NSString *version = [info objectForKey:@"CFBundleVersion"];
	if (version == nil) version = [info objectForKey:@"CFBundleShortVersionString"];
	cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Version: %@", @"版本：%@"), version];
	
	//
	NSString *icon = [info objectForKey:@"CFBundleIconFile"];
	if (icon == nil)
	{
		NSArray *icons = [info objectForKey:@"CFBundleIconFiles"];
		if (icons.count) icon = [icons objectAtIndex:0];
	}
	
	UIImage *image = nil;
	if (icon)
	{
		NSString *path = [info objectForKey:@"Path"];
		NSString *file = [path stringByAppendingPathComponent:icon];
		image = [UIImage imageWithContentsOfFile:file];
	}
	cell.imageView.image = image ? image : [UIImage imageNamed:@"Icon.png"];
	
	return cell;
}

//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*/
- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSUInteger row = [indexPath row];
	NSDictionary *info = [_items objectAtIndex:indexPath.row];
	
	[_items removeObjectAtIndex:row];
	[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	
	if (_items.count == 0)
	{
		[self toggleEdit:nil];
	}
}
*/

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
	UIUtil::ShowMessage(result, self.view);
}


#pragma mark Event methods


#pragma mark Event methods

@end
