
#import "UIUtil.h"
#import "TwitterComposer.h"
#import "SA_OAuthTwitterEngine.h"

#define kPad				10

@implementation TwitterComposer

//
- (id)initWithTitle:(NSString *)title 
			content:(NSString *)content 
			   link:(NSString *)link 
				key:(NSString *)key 
			 secret:(NSString *)secret
{
	_contentTitle = [title retain];
	content = (content.length <= 130) ? content : [[content substringToIndex:130] stringByAppendingString:NSLocalizedString(@"...", @"⋯")];
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
	NSString *authData = [[NSUserDefaults standardUserDefaults] objectForKey:@"authData"];
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
	[_twitterEngine release];
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
	
	[_shortenService startShortingURL:urlString];
}

//
- (void)onCancel
{
	[self dismissModalViewControllerAnimated:YES];
}

//
- (void)onLogout
{
	if (!_twitterEngine)
	{
		_twitterEngine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
		_twitterEngine.consumerKey = _key;
		_twitterEngine.consumerSecret = _secret;
	}
	
	[_twitterEngine clearAccessToken];
	
	// Remove cookies that UIWebView may have stored
	NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray* cookiesArray = [cookies cookiesForURL:
								[NSURL URLWithString:@"http://twitter.com/oauth"]];
	for (NSHTTPCookie* cookie in cookiesArray) {
		[cookies deleteCookie:cookie];
	}
	
	[UIAlertView alertWithTitle:NSLocalizedString(@"Did Logout", @"已注销")];
}

//
- (void)onSend
{
	[_content resignFirstResponder];
    
	if (!_twitterEngine)
	{
		_twitterEngine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
		_twitterEngine.consumerKey = _key;
		_twitterEngine.consumerSecret = _secret;
	}
	
	UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_twitterEngine delegate:self];
	
	if (controller)
	{
		[self presentModalViewController:controller animated:YES];
	}
	else 
	{		
		if (_link)
		{
			[self startShortenURL:_link];
		}
		else
		{
			NSString *msg = [NSString stringWithFormat:@"%@ %@", _content.text, [NSDate date]];
			[_twitterEngine sendUpdate:msg];
		}

		_alertForSending = [UIAlertView alertWithTitle:nil
											   message:NSLocalizedString(@"Sending...", @"正在发送⋯") 
											  delegate:nil
									 cancelButtonTitle:nil
									 otherButtonTitle:nil];
		[_alertForSending.activityIndicator startAnimating];
	}
	
}

//
- (IBAction)segmentAction:(id)sender
{
	// The segmented control was clicked, handle it here 
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	
	segmentedControl.selectedSegmentIndex == 0 ? [self onLogout] : [self onSend];
}

// MGTwitterEngineDelegate
-(void) requestSucceeded:(NSString *)connectionIdentifier
{
	[_alertForSending dismiss];
    [UIAlertView alertWithTitle:NSLocalizedString(@"Share To Twitter", @"分享至 Twitter") message:NSLocalizedString(@"Succeed", @"发送成功")];
    [self dismissModalViewControllerAnimated:YES];
}

//
-(void) requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
 	[_alertForSending dismiss];
	
	if ([error code] == 403)
	{
		[UIAlertView alertWithTitle:NSLocalizedString(@"Share To Twitter", @"分享至 Twitter") 
							message:NSLocalizedString(@"Repeated Weibo Text", @"重复博文")];
	}
	else
	{
		[UIAlertView alertWithTitle:NSLocalizedString(@"Share To Twitter", @"分享至 Twitter") 
							message:NSLocalizedString(@"Failed", @"发送失败")];
	}
}

//=============================================================================================================================
#pragma mark SA_OAuthTwitterEngineDelegate
- (void) storeCachedTwitterOAuthData:(NSString *)data forUsername:(NSString *)username 
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	[defaults setObject:data forKey:@"authData"];
	[defaults synchronize];
	
	[_segment setEnabled:![data isEqualToString:@""] forSegmentAtIndex:0];
}

- (NSString *) cachedTwitterOAuthDataForUsername:(NSString *)username 
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"authData"];
}

//=============================================================================================================================
#pragma mark SA_OAuthTwitterControllerDelegate
- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username 
{
	if (_link)
	{
		[self startShortenURL:_link];
	}
	else
	{
		NSString *msg = [NSString stringWithFormat:@"%@ %@", _content.text, [NSDate date]];
		[_twitterEngine sendUpdate:msg];	
	}
	
	_alertForSending = [UIAlertView alertWithTitle:nil
										   message:NSLocalizedString(@"Sending...", @"正在发送⋯") 
										  delegate:nil
								 cancelButtonTitle:nil
								 otherButtonTitle:nil];
	[_alertForSending.activityIndicator startAnimating];
}

- (void) OAuthTwitterControllerFailed: (SA_OAuthTwitterController *) controller {
}

- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller {
}

// URLShortenService delegate

-(void) urlShortenService:(URLShortenService *)service didShortenURL:(NSString *)origURLString to:(NSString *)shortenURLString
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
	[_twitterEngine sendUpdate:msg];
}

-(void) urlShortenService:(URLShortenService *)service didShortenURL:(NSString *)origURLString failedWithError:(NSString *)errorString
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
	
	[_twitterEngine sendUpdate:msg];
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

