
#import "UIUtil.h"
#import "SinaWeiboComposer.h"

#import "SinaOAuthEngine.h"

#define kPad				10

@implementation SinaWeiboComposer

//
- (id)initWithTitle:(NSString *)title 
			content:(NSString *)content 
			   link:(NSString *)link 
				key:(NSString *)key 
			 secret:(NSString *)secret
{
	_contentTitle = [title retain];
	_contentString = [content retain];
	
	_link = [link retain];
	
	_key = [key retain];
	_secret = [secret retain];
	
	return [super init];
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView 
{
	[super loadView];

	self.view.backgroundColor = [UIColor lightGrayColor];
	
	CGRect frame = [UIScreen mainScreen].applicationFrame;
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
																 target:self action:@selector(onCancel)] autorelease];
	
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
	NSString *authData = [[NSUserDefaults standardUserDefaults] objectForKey:@"sina authData"];
	[_segment setEnabled:(authData!=nil && ![authData isEqualToString:@""]) forSegmentAtIndex:0];
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
	[_sinaEngine release];
	[_contentTitle release];
	[_contentString release];
	[_link release];
	
	[_key release];
	[_secret release];
	[super dealloc];
}

//UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	// leave space for time info..
	// TODO: short url, time.
	return range.location <= 100;
}

//
-(void) startShortenURL:(NSString *)urlString
{
	if ( _shortenService == nil ) {
		_shortenService = [[URLShortenService alloc] init];
		_shortenService.delegate = self;
	}
	
	[_shortenService startShortingSinaWeiboURL:_key andUrl:urlString];
}

//
- (void)onCancel
{
	[self dismissModalViewControllerAnimated:YES];
}

//
- (void)onLogout
{
	if (!_sinaEngine)
	{
		_sinaEngine = [[SinaOAuthEngine alloc] initOAuthWithDelegate:self];
		_sinaEngine.consumerKey = _key;
		_sinaEngine.consumerSecret = _secret;
	}
	
	[_sinaEngine clearAccessToken];
	
	// Remove cookies that UIWebView may have stored
	NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray* cookiesArray = [cookies cookiesForURL:
							 [NSURL URLWithString:@"http://api.t.sina.com.cn/oauth"]];
	for (NSHTTPCookie* cookie in cookiesArray) {
		[cookies deleteCookie:cookie];
	}
	
	[UIAlertView alertWithTitle:NSLocalizedString(@"Did Logout", @"已注销")];
}

//
- (void)onSend
{
	[_content resignFirstResponder];
    
	if (!_sinaEngine)
	{
		_sinaEngine = [[SinaOAuthEngine alloc] initOAuthWithDelegate:self];
		_sinaEngine.consumerKey = _key;
		_sinaEngine.consumerSecret = _secret;
	}
	
	UIViewController *controller = [SinaOAuthController controllerToEnterCredentialsWithSinaEngine:_sinaEngine delegate:self];
	
	if (controller)
	{
		[self presentModalViewController:controller animated:YES];
	}
	else 
	{	
		_alertForSending = [UIAlertView alertWithTitle:nil
											   message:NSLocalizedString(@"Sending...", @"正在发送⋯") 
											  delegate:nil
									 cancelButtonTitle:nil
									 otherButtonTitle:nil];
		[_alertForSending.activityIndicator startAnimating];
		
		if (_link)
		{
			[self startShortenURL:_link];
		}
		else
		{
			[_sinaEngine sendUpdate:_content.text];
		}
	}
	
}

//
- (IBAction)segmentAction:(id)sender
{
	// The segmented control was clicked, handle it here 
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	
	segmentedControl.selectedSegmentIndex == 0 ? [self onLogout] : [self onSend];
}

//=============================================================================================================================
#pragma mark SinaOAuthEngineDelegate
- (void) storeCachedSinaOAuthData:(NSString *)data 
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setObject:data forKey:@"sina authData"];
	[defaults synchronize];
	
	[_segment setEnabled:![data isEqualToString:@""] forSegmentAtIndex:0];
}

- (NSString *)cachedSinaOAuthData 
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"sina authData"];
}

//
- (void)requestSucceeded
{
	[_alertForSending dismiss];
    [UIAlertView alertWithTitle:NSLocalizedString(@"Share To Sina Weibo", @"分享至新浪微博") message:NSLocalizedString(@"Succeed", @"发送成功")];
    [self dismissModalViewControllerAnimated:YES];
}

//
- (void)requestFailed:(NSError *)error
{
	[_alertForSending dismiss];
	
	if ([error code] == 40025)
	{
		[UIAlertView alertWithTitle:NSLocalizedString(@"Share To Sina Weibo", @"分享至新浪微博") 
							message:NSLocalizedString(@"Repeated Weibo Text", @"重复博文")];
	}
	else
	{
		[UIAlertView alertWithTitle:NSLocalizedString(@"Share To Sina Weibo", @"分享至新浪微博") 
							message:NSLocalizedString(@"Failed", @"发送失败")];
	}
}

//=============================================================================================================================
#pragma mark SinaOAuthControllerDelegate
- (void)SinaOAuthController:(SinaOAuthController *)controller
{	
	if (_link)
	{
		[self startShortenURL:_link];
	}
	else
	{
		[_sinaEngine sendUpdate:_content.text];
	}
	
	_alertForSending = [UIAlertView alertWithTitle:nil
										   message:NSLocalizedString(@"Sending...", @"正在发送⋯")
										  delegate:nil
								 cancelButtonTitle:nil
								 otherButtonTitle:nil];
	[_alertForSending.activityIndicator startAnimating];
}

- (void)SinaOAuthControllerFailed:(SinaOAuthController *)controller 
{
}

- (void)SinaOAuthControllerCanceled:(SinaOAuthController *)controller 
{
}

// URLShortenService delegate
- (void)urlShortenService:(URLShortenService *)service didShortenURL:(NSString *)origURLString to:(NSString *)shortenURLString
{
	NSString *linkPart = shortenURLString;
	NSString *contentPart;
	if ([_content.text length] + [linkPart length] > 130)
	{
		contentPart = [_content.text substringToIndex:130-[linkPart length]];
	}
	else
	{
		contentPart = _content.text;
	}

	NSString *msg = [NSString stringWithFormat:@"%@%@", contentPart, linkPart];
	[_sinaEngine sendUpdate:msg];
	
}

- (void)urlShortenService:(URLShortenService *)service didShortenURL:(NSString *)origURLString failedWithError:(NSString *)errorString
{
	NSString *linkPart = origURLString;
	NSString *contentPart;
	if ([_content.text length] + [linkPart length] > 130)
	{
		contentPart = [_content.text substringToIndex:130-[linkPart length]];
	}
	else
	{
		contentPart = _content.text;
	}
	
	NSString *msg = [NSString stringWithFormat:@"%@%@", contentPart, linkPart];
	[_sinaEngine sendUpdate:msg];
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

