
#import "AppDelegate.h"
#import "DownloadController.h"
#import "IPADeploy.h"
#import <QuartzCore/QuartzCore.h>


@implementation DownloadController

#pragma mark Generic methods

// Constructor
//- (id)init
//{
//	[super initW];
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
	
	NSString *dir = NSUtil::CachePath();
	NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:nil];
	_items = [[NSMutableArray alloc] initWithCapacity:items.count];
	for (NSString *item in items)
	{
		if ([item hasSuffix:@".ipa"])
		{
			[_items addObject:item];
		}
	}
	
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
	self.title = @"下载管理";
	self.tableView.rowHeight = 55;
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEdit:)] autorelease];
	
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
	}
	
	NSString *file = [_items objectAtIndex:indexPath.row];
	NSString *path = NSUtil::CacheSubPath(file);
	
	NSDictionary *info = IPAExtractInfo(path);
	
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
		NSString *file = [path stringByAppendingString:icon];
		if (NSUtil::IsFileExist(file) == NO)
		{
			IPAExtractFile(path, icon, file);
		}
		image = [UIImage imageWithContentsOfFile:file];
	}
	cell.imageView.image = image ? image : [UIImage imageNamed:@"Icon.png"];

	//
	BOOL installed = IPAIsPlistInstalled(info);
	NSString *buttonTitle = installed ? NSLocalizedString(@"Reinstall", @"重装") : NSLocalizedString(@"Install", @"安装");
	UIButton *button = [UIButton buttonWithType:(UIButtonType)(installed ? 102 : 100)];
	[button addTarget:self action:@selector(install:) forControlEvents:UIControlEventTouchUpInside];
	[button setTitle:buttonTitle forState:UIControlStateNormal];
	button.tag = indexPath.row;
	//[button sizeToFit];
	cell.accessoryView = button;
	
	return cell;
}

//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//
- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSUInteger row = [indexPath row];
	NSString *file = [_items objectAtIndex:indexPath.row];
	NSString *path = NSUtil::CacheSubPath(file);

	[_items removeObjectAtIndex:row];
	[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
	[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	
	if (_items.count == 0)
	{
		[self toggleEdit:nil];
	}
}


#pragma mark Web view

//
- (void)install:(UIButton *)sender
{
	UIAlertView *alertView = [UIAlertView alertWithTask:self title:NSLocalizedString(@"Installing...", @"正在安装…")];
	alertView.tag = sender.tag;
}

//
- (void)doTask:(UIAlertView *)alertView
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSString *error;
	NSInteger row = alertView.tag;
	do
	{
		NSString *file = [_items objectAtIndex:row];
		NSString *path = NSUtil::CacheSubPath(file);
		
		IPAResult ret = IPAInstall(path);
		if (ret == IPAResultOK)
		{
			error = nil;
		}
		else
		{
			[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
			error = [NSString stringWithFormat:NSLocalizedString(@"IPA installation failed.\n\nError: %#08X", @"IPA 安装失败。\n\n错误代码：%#08X"), ret];
		}
	}
	while (NO);
	
	[alertView dismissOnMainThread];
	[self performSelectorOnMainThread:@selector(endTask:) withObject:error waitUntilDone:YES];
	[pool release];
}

//
- (void)endTask:(NSString *)error
{
	if (error == nil)
	{
		//UIUtil::ShowMessage(NSLocalizedString(@"IPA installation completed successfully.", @"IPA 安装成功。"), self.view);
		[[UIAlertView alertWithTitle:NSLocalizedString(@"IPA installation completed successfully.", @"IPA 安装成功。")] dismissAfterDelay:3];
	}
	else
	{
		[UIAlertView alertWithTitle:error];
	}
	[self reloadData];
}


#pragma mark Event methods

@end
