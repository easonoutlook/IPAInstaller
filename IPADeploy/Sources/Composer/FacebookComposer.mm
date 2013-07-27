
#import "UIUtil.h"
#import "FacebookComposer.h"


@interface FacebookComposer (privateMethod)
- (void)onSend;
@end

@implementation FacebookComposer

//
- (id)initWithTitle:(NSString *)title 
	   contentTitle:(NSString *)title2 
			content:(NSString *)content 
			   link:(NSString *)link
				key:(NSString *)key 
			 secret:(NSString *)secret
		downloadURL:(NSString *)url
{
	_contentTitle = [title retain];
	
	content = (content.length <= 500) ? content : [[content substringToIndex:500] stringByAppendingString:NSLocalizedString(@"...", @"⋯")];
	_contentString = [content retain];
	
	_link = [link retain];
	
	_title2 = [title2 retain];
	
	_key = [key retain];
	_secret = [secret retain];
	_downloadUrl = [url retain];
	
	return [super init];
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView 
{
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	UITextView *textView = [[UITextView alloc] initWithFrame:frame];
	textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	textView.text = _contentString;
	textView.font = [UIFont systemFontOfSize:18];
	[self.view addSubview:textView];
	[textView release];
	textView.backgroundColor = [UIColor clearColor];
	_content = textView;
}

// Do additional setup after loading the view.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	UIBarButtonItem *leftItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"取消") 
																  style:UIBarButtonItemStyleBordered 
																 target:self 
																 action:@selector(onCancel)] autorelease];
	
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
											[NSArray arrayWithObjects:
											 NSLocalizedString(@"Logout", @"注销"),
											 NSLocalizedString(@"Send", @"发送"),
											 nil]];
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.frame = CGRectMake(0, 0, 90, 30);
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.momentary = YES;
	
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    [segmentedControl release];
    
	self.navigationItem.rightBarButtonItem = segmentBarItem;
    [segmentBarItem release];
	
	self.navigationItem.leftBarButtonItem = leftItem;
	//self.title = _contentTitle;
	
	_segment = segmentedControl;	
	NSObject *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"FBUserId"];
	[_segment setEnabled:(userId!=nil) forSegmentAtIndex:0];
}

// Called when the view is about to made visible.
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(keyboardDidShow:)
												 name:UIKeyboardDidShowNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
}

// Called after the view was dismissed, covered or otherwise hidden.
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

// Override to allow rotation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

//
- (void)dealloc 
{
	[_contentTitle release];
	[_contentString release];
	
	[_link release];
	
	[_title2 release];
	
	[_key release];
	[_secret release];
	[_downloadUrl release];
	
    [super dealloc];
}

//
- (void)onCancel
{
	[self dismissModalViewControllerAnimated:YES];
}

//
- (void)onLogout
{
	if (!_fbSession)
	{
		_fbSession = [[FBSession sessionForApplication:_key secret:_secret delegate:self] retain];
	}
	
	[_fbSession logout];
	_fbSession = nil;
	
	// Remove cookies that UIWebView may have stored
	NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray* facebookCookies = [cookies cookiesForURL:
								[NSURL URLWithString:@"http://www.facebook.com"]];
	for (NSHTTPCookie* cookie in facebookCookies) {
		[cookies deleteCookie:cookie];
	}
	
	[_segment setEnabled:NO forSegmentAtIndex:0];
	
	[UIAlertView alertWithTitle:NSLocalizedString(@"Did Logout", @"已注销")];
}

//
- (IBAction)segmentAction:(id)sender
{
	// The segmented control was clicked, handle it here 
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	segmentedControl.selectedSegmentIndex == 0 ? [self onLogout] : [self onSend];
}

//
- (void)fbShowLoginDialog
{
	FBLoginDialog * loginDialog = [[FBLoginDialog alloc] initWithSession:_fbSession];
	loginDialog.delegate = self;
	[loginDialog show];
	[loginDialog release];
}

//
- (void)onSend
{
	[_content resignFirstResponder];
	
	if (!_fbSession)
	{
		_fbSession = [[FBSession sessionForApplication:_key secret:_secret delegate:self] retain];
		[_fbSession resume];
	}
    
	// Check whether we need login...
    if ( !_fbSession.isConnected ) 
	{
		[self fbShowLoginDialog];
    }
	else
	{		
		_alertForSending = [UIAlertView alertWithTitle:nil
											   message:NSLocalizedString(@"Sending...", @"正在发送⋯")
											  delegate:nil
									 cancelButtonTitle:nil
									 otherButtonTitle:nil];
		[_alertForSending.activityIndicator startAnimating];
	}
}

//
- (void)fbCheckPublishPermissionWithUid:(FBUID)uid
{
	// Ask for permission
    FBRequest * request = [FBRequest requestWithSession:_fbSession delegate:self];
	NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									@"publish_stream", @"ext_perm",
									[NSString stringWithFormat:@"%llu", uid], @"uid", nil];
	[request call:@"facebook.users.hasAppPermission" params:params];
}

//
- (void)fbPublishToStream
{	
    FBRequest * request = [FBRequest requestWithSession:_fbSession delegate:self];
	
	// TODO:
	NSString *title2 = [_title2 stringByReplacingOccurrencesOfString:@" " withString:@""];
	title2 = [title2 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	title2 = [title2 stringByReplacingOccurrencesOfString:@"\t" withString:@""];
	title2 = [title2 stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	
	NSString *content = [_content.text stringByReplacingOccurrencesOfString:@" " withString:@""];
	content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	content = [content stringByReplacingOccurrencesOfString:@"\t" withString:@""];
	content = [content stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	
	// TODO:
	 NSString * att = [NSString stringWithFormat:@"{\"name\":\"%@\",\
												\"href\":\"%@\",\
												\"caption\":\"%@\",\
												\"description\": \"%@\",\
												\"properties\":\
												{\"%@\":\
					   {\"text\":\"%@\",\"href\":\"%@\"}}}", title2, _link, @"", content, 
					   NSLocalizedString(@"Download", @"下载"), NSLocalizedString(@"applications", @"应用"), _downloadUrl];
		
	NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									@"1.0", @"v",
									att, @"attachment", nil];
	
	[request call:@"facebook.stream.publish" params:params];
}

#pragma mark ---------------------- FBSessionDelegate --------------------------

- (void)session:(FBSession *)session didLogin:(FBUID)uid
{
	[self fbCheckPublishPermissionWithUid:uid];
}


- (void)sessionDidNotLogin:(FBSession *)session
{
}

- (void)sessionDidLogout:(FBSession *)session
{
}

#pragma mark ----------------- FBRequestDelegate -----------------------

//
- (void)requestLoading:(FBRequest*)request
{
}

//
- (void)request:(FBRequest*)request didReceiveResponse:(NSURLResponse*)response
{
}

//
- (void)request:(FBRequest*)request didFailWithError:(NSError*)error
{
	// Check error code. if 102, re-launch login 
	if ( [error code] == 102 ) 
	{ // Invalid session key
		[self fbShowLoginDialog];
	}
	else 
	{
		[_alertForSending dismiss];
		NSString *errorStr = [NSString stringWithFormat:NSLocalizedString(@"Failed: %@", @"失败: %@"), [error localizedDescription]];
		[UIAlertView alertWithTitle:NSLocalizedString(@"Share To Facebook", @"分享至 Facebook") message:errorStr];
		[self onCancel];
	}
}

//
- (void)request:(FBRequest*)request didLoad:(id)result
{
	if ( [request.method isEqualToString:@"facebook.users.hasAppPermission"] ) 
	{
		if ( [result intValue] == 0) 
		{
			FBPermissionDialog * permissionDialog = [[FBPermissionDialog alloc] initWithSession:_fbSession];
			permissionDialog.delegate = self;
			permissionDialog.permission = @"publish_stream";
			[permissionDialog show];
			[permissionDialog release];
		}
		else 
		{
			[self fbPublishToStream];
		}
		
		[_segment setEnabled:YES forSegmentAtIndex:0];
	}
	else if ( [request.method isEqualToString:@"facebook.stream.publish"] ) 
	{
		// Posted.?
		
		[_alertForSending dismiss];
		[UIAlertView alertWithTitle:NSLocalizedString(@"Share To Facebook", @"分享至 Facebook") 
							message:NSLocalizedString(@"Succeed", @"发送成功")];
		
		[self onCancel];
	}
	
}

//
- (void)requestWasCancelled:(FBRequest*)request
{
	[_alertForSending dismiss];
	[self onCancel];
}


#pragma mark ------------------- FBDialogDelegate --------------------------------

- (void)dialogDidSucceed:(FBDialog *)dialog
{
	if ( [dialog isKindOfClass:[FBPermissionDialog class]] ) 
	{
		[self fbPublishToStream];
	}
}

- (void)dialogDidCancel:(FBDialog *)dialog
{
	[_alertForSending dismiss];
	//[UIAlertView alertWithTitle:NSLocalizedString(@"Share To Facebook", @"分享至 Facebook") message:NSLocalizedString(@"Cancelled", @"已取消")];
	
	[self onCancel];
}

- (void)dialog:(FBDialog *)dialog didFailWithError:(NSError *)error
{
	[_alertForSending dismiss];
	NSString *errorStr = [NSString stringWithFormat:NSLocalizedString(@"Failed: %@", @"失败: %@"), [error localizedDescription]];
	[UIAlertView alertWithTitle:NSLocalizedString(@"Share To Facebook", @"分享至 Facebook") message:errorStr];
	
	[self onCancel];
}

//
- (void)keyboardDidShow:(NSNotification *)notification
{
	CGRect rect;
	NSValue *value = [notification.userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
	[value getValue:&rect];
	
	CGRect frame = self.view.frame;
	frame.size.height -= rect.size.height;
	_content.frame = frame;
}

//
- (void)keyboardWillHide:(NSNotification *)notification
{
	CGRect rect;
	NSValue *value = [notification.userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
	[value getValue:&rect];
	
	CGRect frame = self.view.frame;
	frame.size.height += rect.size.height;
	_content.frame = frame;
}

@end

