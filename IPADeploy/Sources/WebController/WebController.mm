
#import "UIUtil.h"
#import "WebController.h"

@implementation WebController
@synthesize url=_url;

#pragma mark Generic methods

// Contructor
- (id)initWithUrl:(NSURL *)url
{
	[super init];
	_url = [url retain];
	return self;
}

// Destructor
- (void)dealloc
{
	[_rightButton release];
	[_url release];
	[super dealloc];
}

//
- (UIWebView *)webView
{
	return (UIWebView *)self.view;
}

//
- (void)setUrl:(NSURL *)url
{
	if (url != _url)
	{
		[_url release];
		_url = [url retain];
	}
	[self.webView loadRequest:[NSURLRequest requestWithURL:_url]];
}


#pragma mark View methods

//
- (void)loadView
{
	UIWebView *webView = [[UIWebView alloc] initWithFrame:UIUtil::AppFrame()];
	//webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; 
	webView.scalesPageToFit = YES;
	webView.delegate = self;
	self.view = webView;
	[webView release];
}

// Do additional setup after loading the view.
- (void)viewDidLoad
{	
	[super viewDidLoad];

	if (_url) self.url = _url;
}

// Override to allow rotation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


#pragma mark Web view delegate

//
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
//{
//	return YES;
//}

//
- (void)webViewDidStartLoad:(UIWebView *)webView
{
	UIUtil::ShowNetworkIndicator(YES);
	self.title = NSLocalizedString(@"Loading...", @"加载中⋯");
	
	[_rightButton release];
	_rightButton = [self.navigationItem.rightBarButtonItem retain];

	UIActivityIndicatorView* indicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithCustomView:indicator] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:YES];
	[indicator startAnimating];
}

//
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	UIUtil::ShowNetworkIndicator(NO);
	self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	[self.navigationItem setRightBarButtonItem:_rightButton animated:YES];
	
	[_rightButton release];
	_rightButton = nil;
}

//
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[self webViewDidFinishLoad:webView];
	if (error.code != -999)
	{
#ifdef _WebViewInlineError
		NSString *string = [NSString stringWithFormat:
							@"<head>"
							@"<meta name=\"viewport\" content=\"width=device-width; initial-scale=1.0; maximum-scale=1.0;\"/>"
							@"<title>%@</title>"
							@"<head>"
							@"<body>%@</body>", 
							NSLocalizedString(@"Error", @"错误"),
							error.localizedDescription];
		
		[((UIWebView *)self.view) loadHTMLString:string baseURL:nil];
#else
		[UIAlertView alertWithTitle:NSLocalizedString(@"Error", @"错误") message:error.localizedDescription];
#endif
	}
}


@end


@implementation WebBrowser


#pragma mark Generic methods

// Destructor
//- (void)dealloc
//{
//	[super dealloc];
//}


#pragma mark View methods

// Do additional setup after loading the view.
- (void)viewDidLoad
{
	[super viewDidLoad];

	// Create toolbar
	const static struct {NSString* title; SEL action;} c_buttons[] =
	{
		{(NSString *)UIBarButtonSystemItemRefresh, @selector(onRefresh:)},
		{@"BackwardIcon.png", @selector(onBackward:)},
		{@"ForwardIcon.png", @selector(onForward:)},
		{(NSString *)UIBarButtonSystemItemAction, @selector(onAction:)},
	};
	
	NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:3 * sizeof(c_buttons)/sizeof(c_buttons[0])];
	for (NSUInteger i = 0; i < sizeof(c_buttons) / sizeof(c_buttons[0]); ++i)
	{
		[buttons addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
		
		UIBarButtonItem *button = [UIBarButtonItem alloc];
		if ((NSUInteger)c_buttons[i].title < 256) 
		{
			[button initWithBarButtonSystemItem:(UIBarButtonSystemItem)(NSUInteger)c_buttons[i].title  target:self action:c_buttons[i].action];
		}
		else
		{
			[button initWithImage:[UIImage imageNamed:c_buttons[i].title] style:UIBarButtonItemStylePlain target:self action:c_buttons[i].action];
		}
		[buttons addObject:button];
		[button release];

		[buttons addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
	}
	
	self.toolbarItems = buttons;
}

// Called when the view is about to made visible.
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	_toolBarHidden = self.navigationController.toolbarHidden;
	[self.navigationController setToolbarHidden:NO animated:YES];
}

// Called after the view was dismissed, covered or otherwise hidden.
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self.navigationController setToolbarHidden:_toolBarHidden animated:YES];
}


#pragma mark Web view delegate

//
- (void)updateButtons:(BOOL)isLoading
{
	NSMutableArray *buttons = [NSMutableArray arrayWithArray:self.toolbarItems];
	for (NSInteger i = buttons.count - 1; i >= 0; i--)
	{
		UIBarButtonItem *button = [buttons objectAtIndex:i];
		if (button.action == @selector(onForward:))
		{
			button.enabled = isLoading ? NO : self.webView.canGoForward;
		}
		else if (button.action == @selector(onBackward:))
		{
			button.enabled = isLoading ? NO : self.webView.canGoBack;
		}
		else if (button.action == @selector(onRefresh:))
		{
			UIBarButtonSystemItem type = isLoading ? UIBarButtonSystemItemStop : UIBarButtonSystemItemRefresh;
			UIBarButtonItem *newButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:type target:self action:@selector(onRefresh:)] autorelease];
			[buttons replaceObjectAtIndex:i withObject:newButton];
		}
	}
	[self setToolbarItems:buttons animated:NO];
}

//
- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[super webViewDidStartLoad:webView];
	[self updateButtons:YES];
}

//
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[super webViewDidFinishLoad:webView];
	[self updateButtons:NO];
}


#pragma mark Event methods

//
- (void)onRefresh:(UIBarButtonItem *)sender
{
	if (self.webView.isLoading)
	{
		[self.webView stopLoading];
	}
	else
	{
		[self.webView reload];
	}
}

//
- (void)onBackward:(UIBarButtonItem *)sender
{
	[self.webView goBack];
}

//
- (void)onForward:(UIBarButtonItem *)sender
{
	[self.webView goForward];
}

//
- (void)onAction:(UIBarButtonItem *)sender
{
	UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:nil
															  delegate:self
													 cancelButtonTitle:NSLocalizedString(@"Cancel", @"取消")
												destructiveButtonTitle:nil
													 otherButtonTitles:
								   NSLocalizedString(@"Open with Safari", @"在 Safari 中打开"),
								   //NSLocalizedString(@"Send via Email", @"发送邮件链接"), 
								   nil] autorelease];
	if ([actionSheet respondsToSelector:@selector(showFromBarButtonItem: animated:)])
	{
		[actionSheet showFromBarButtonItem:sender animated:YES];
	}
	else
	{
		[actionSheet showFromToolbar:self.navigationController.toolbar];
	}
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex)
	{
		case 0:
		{
			NSString *url = [((UIWebView *)self.view) stringByEvaluatingJavaScriptFromString:@"window.location.href"];
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
			break;
		}
			
		case 1:
		{
			
		}
	}
}

@end
