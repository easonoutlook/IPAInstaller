
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "SinaOAuthEngine.h"
#import "SinaOAuthController.h"

@interface SinaOAuthController ()
@property (nonatomic, readwrite) UIInterfaceOrientation orientation;

- (id)initWithEngine:(SinaOAuthEngine *)engine andOrientation:(UIInterfaceOrientation)theOrientation;
- (NSString *)locateAuthPinInWebView:(UIWebView *)webView;

//- (void)showPinCopyPrompt;
- (void)gotPin:(NSString *)pin;
@end

@interface DummyClassForProvidingSetDataDetectorTypesMethod
- (void)setDataDetectorTypes:(int)types;
- (void)setDetectsPhoneNumbers:(BOOL)detects;
@end

@interface NSString(TwitterOAuth)
- (BOOL)oauthtwitter_isNumeric;
@end

@implementation NSString (TwitterOAuth)
- (BOOL) oauthtwitter_isNumeric {
	const char				*raw = (const char *) [self UTF8String];
	
	for (int i = 0; i < strlen(raw); i++) {
		if (raw[i] < '0' || raw[i] > '9') return NO;
	}
	return YES;
}
@end


@implementation SinaOAuthController
@synthesize engine = _engine, delegate = _delegate, navigationBar = _navBar, orientation = _orientation;

//
- (void)dealloc 
{
	[_backgroundView release];
	
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	_webView.delegate = nil;
	[_webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: @""]]];
	[_webView release];
	
	self.view = nil;
	self.engine = nil;
	[super dealloc];
}

//
+ (SinaOAuthController *)controllerToEnterCredentialsWithSinaEngine:(SinaOAuthEngine *)engine 
														   delegate:(id <SinaOAuthControllerDelegate>)delegate 
													 forOrientation:(UIInterfaceOrientation)theOrientation 
{
	if (![self credentialEntryRequiredWithSinaEngine:engine]) return nil;
	
	SinaOAuthController *controller = [[[SinaOAuthController alloc] initWithEngine:engine 
																	andOrientation:theOrientation] autorelease];
	controller.delegate = delegate;
	return controller;
}

//
+ (SinaOAuthController *)controllerToEnterCredentialsWithSinaEngine:(SinaOAuthEngine *)engine 
														   delegate:(id <SinaOAuthControllerDelegate>)delegate
{
	return [SinaOAuthController controllerToEnterCredentialsWithSinaEngine:engine 
																  delegate:delegate 
															forOrientation:UIInterfaceOrientationPortrait];
}

//
+ (BOOL)credentialEntryRequiredWithSinaEngine:(SinaOAuthEngine *)engine 
{
	return ![engine isAuthorized];
}

//
- (id) initWithEngine:(SinaOAuthEngine *)engine andOrientation:(UIInterfaceOrientation)theOrientation 
{
	[super init];
	
	self.engine = engine;
	if (!engine.OAuthSetup) [_engine requestRequestToken];
	self.orientation = theOrientation;
	
	if (UIInterfaceOrientationIsLandscape( self.orientation ) )
		_webView = [[UIWebView alloc] initWithFrame: CGRectMake(0, 32, 480, 288)];
	else
		_webView = [[UIWebView alloc] initWithFrame: CGRectMake(0, 44, 320, 416)];
	
	_webView.alpha = 0.0;
	_webView.delegate = self;
	_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	if ([_webView respondsToSelector: @selector(setDetectsPhoneNumbers:)]) [(id) _webView setDetectsPhoneNumbers: NO];
	if ([_webView respondsToSelector: @selector(setDataDetectorTypes:)]) [(id) _webView setDataDetectorTypes: 0];
	
	NSURLRequest *request = _engine.authorizeURLRequest;
	[_webView loadRequest: request];
	
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(pasteboardChanged:) name: UIPasteboardChangedNotification object: nil];

	return self;
}

//=============================================================================================================================
#pragma mark Actions
- (void)denied 
{
	if ([_delegate respondsToSelector: @selector(SinaOAuthControllerFailed:)]) [_delegate SinaOAuthControllerFailed: self];
	[self performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id) kCFBooleanTrue afterDelay: 1.0];
}

- (void)gotPin:(NSString *)pin 
{
	_engine.pin = pin;
	[_engine requestAccessToken];
	
	if ([_delegate respondsToSelector: @selector(SinaOAuthController:)]) [_delegate SinaOAuthController:self];
	[self performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id) kCFBooleanTrue afterDelay: 1.0];
}

- (void)cancel:(id)sender 
{
	if ([_delegate respondsToSelector: @selector(SinaOAuthControllerCanceled:)]) [_delegate SinaOAuthControllerCanceled: self];
	[self performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id) kCFBooleanTrue afterDelay: 0.0];
}

//
- (void) loadView 
{
	[super loadView];

	_backgroundView = [[UIImageView alloc] init];
	_backgroundView.backgroundColor = [UIColor lightGrayColor];
	if ( UIInterfaceOrientationIsLandscape( self.orientation ) ) {
		self.view = [[[UIView alloc] initWithFrame: CGRectMake(0, 0, 480, 288)] autorelease];	
		_backgroundView.frame =  CGRectMake(0, 44, 480, 288);
		
		_navBar = [[[UINavigationBar alloc] initWithFrame: CGRectMake(0, 0, 480, 32)] autorelease];
	} else {
		self.view = [[[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 416)] autorelease];	
		_backgroundView.frame =  CGRectMake(0, 44, 320, 416);
		_navBar = [[[UINavigationBar alloc] initWithFrame: CGRectMake(0, 0, 320, 44)] autorelease];
	}
	_navBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
	_backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	if (!UIInterfaceOrientationIsLandscape( self.orientation)) [self.view addSubview:_backgroundView];
	
	[self.view addSubview: _webView];
	[self.view addSubview: _navBar];
	
	_blockerView = [[[UIView alloc] initWithFrame: CGRectMake(0, 0, 200, 60)] autorelease];
	_blockerView.backgroundColor = [UIColor colorWithWhite: 0.0 alpha: 0.8];
	_blockerView.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
	_blockerView.alpha = 0.0;
	_blockerView.clipsToBounds = YES;
	if ([_blockerView.layer respondsToSelector: @selector(setCornerRadius:)]) [(id) _blockerView.layer setCornerRadius: 10];
	
	UILabel								*label = [[[UILabel alloc] initWithFrame: CGRectMake(0, 5, _blockerView.bounds.size.width, 15)] autorelease];
	label.text = NSLocalizedString(@"Please wait...", @"请稍候⋯");
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor whiteColor];
	label.textAlignment = UITextAlignmentCenter;
	label.font = [UIFont boldSystemFontOfSize: 15];
	[_blockerView addSubview: label];
	
	UIActivityIndicatorView	*spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite] autorelease];
	
	spinner.center = CGPointMake(_blockerView.bounds.size.width / 2, _blockerView.bounds.size.height / 2 + 10);
	[_blockerView addSubview: spinner];
	[self.view addSubview: _blockerView];
	[spinner startAnimating];
	
	UINavigationItem *navItem = [[[UINavigationItem alloc] initWithTitle: NSLocalizedString(@"Sina Account Info", @"新浪微博账户")] autorelease];
	navItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel target: self action: @selector(cancel:)] autorelease];
	
	[_navBar pushNavigationItem: navItem animated: NO];
	[self locateAuthPinInWebView: nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation 
{
	self.orientation = self.interfaceOrientation;
	_blockerView.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
}

//  TODO: remove?
//=============================================================================================================================
#pragma mark Notifications
- (void)pasteboardChanged:(NSNotification *)note 
{
	UIPasteboard *pb = [UIPasteboard generalPasteboard];
	if ([note.userInfo objectForKey: UIPasteboardChangedTypesAddedKey] == nil) return;
	
	NSString *copied = pb.string;
	
	if (copied.length != 7 || !copied.oauthtwitter_isNumeric) return;
	[self gotPin: copied];
}

//=============================================================================================================================
#pragma mark Webview Delegate stuff
- (void)webViewDidFinishLoad: (UIWebView *) webView
{
	_loading = NO;
	
	_Log(@"%@", webView.request.URL.absoluteString);
	
	NSString *url = webView.request.URL.absoluteString;
	if ([url rangeOfString:@"oauth_token="].location != NSNotFound) 
	{
		[_webView performSelector:@selector(stringByEvaluatingJavaScriptFromString:) withObject: @"window.scrollBy(0,200)" afterDelay:0];
	} 
	else
	{
		NSString *authPin = [self locateAuthPinInWebView:webView];
		if (authPin.length) 
		{
			[self gotPin: authPin];
			return;
		}
		else
		{
			//[self denied];
			//return;
		}
	}
	
	[UIView beginAnimations:nil context:nil];
	_blockerView.alpha = 0.0;
	[UIView commitAnimations];
	
	_webView.alpha = [_webView isLoading] ? 0.0 : 1.0;
}

// get the sina oauth pin.
- (NSString *)locateAuthPinInWebView:(UIWebView *)webView 
{
	if (webView == nil)
	{
		return nil;
	}
	
	// the auth.... result webview was changed by Sina!!!
	NSString *html = [webView stringByEvaluatingJavaScriptFromString: @"document.body.innerText"];
	_Log(@"%@", html);
	
	BOOL bValue = YES;
	NSRange range = [html rangeOfString:@"授权码"];
	if (range.location == NSNotFound)
	{
		range = [html rangeOfString:@"授權碼"];
		bValue = NO;
	}
	
	if (range.location == NSNotFound)
	{
		return nil;
	}
	
	NSScanner *scanner;
    NSString *text = nil;
	
    scanner = [NSScanner scannerWithString:html];
	
    while ([scanner isAtEnd] == NO) 
	{
        // find start of tag
        [scanner scanUpToString:(bValue ? @"授权码" : @"授權碼") intoString:nil]; 
		
        // find end of tag
        [scanner scanUpToString:@"\n" intoString:&text] ;
		
        html = [html stringByReplacingOccurrencesOfString:
				[NSString stringWithFormat:@"%@\n", text] withString:@""];
		
    }

	if ([text length] < 6)
	{
		return nil;
	}
	
	NSString *pin = [text substringWithRange:NSMakeRange([text length]-6, 6)];
	
	_Log(@"sina pin ====== %@", pin);
	return pin;
}

//
- (void)webViewDidStartLoad:(UIWebView *)webView 
{
	//[_activityIndicator startAnimating];
	_loading = YES;
	[UIView beginAnimations: nil context: nil];
	_blockerView.alpha = 1.0;
	[UIView commitAnimations];
}

//
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request 
 navigationType:(UIWebViewNavigationType)navigationType 
{
	NSData *data = [request HTTPBody];
	char *raw = data ? (char *) [data bytes] : "";
	
	if (raw && strstr(raw, "cancel=")) 
	{
		[self denied];
		return NO;
	}
	if (navigationType != UIWebViewNavigationTypeOther) _webView.alpha = 0.1;
	return YES;
}

@end
