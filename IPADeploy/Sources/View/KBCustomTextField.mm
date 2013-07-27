
#import "UIUtil.h"
#import "KBCustomTextField.h"


@implementation KBCustomTextField
@synthesize kbDelegate=_kbDelegate;

//
- (void)dealloc
{
	[_kbDelegate keyboardHide:self];
	[super dealloc];
}

//
- (BOOL)becomeFirstResponder
{
	BOOL ret = [super becomeFirstResponder];
	[_kbDelegate keyboardShow:self];
	return ret;
}

//
- (BOOL)resignFirstResponder
{
	BOOL ret = [super resignFirstResponder];
	[_kbDelegate keyboardHide:self];
	return ret;
}

//
//#define _LOG_KEY_VIEW
#ifdef _LOG_KEY_VIEW
+ (void)logKeyView:(UIKBKeyView *)view
{
	_Log(@"\tname=%@"
		  @"\trepresentedString=%@"
		  @"\tdisplayString=%@"
		  @"\tdisplayType=%@"
		  @"\tinteractionType=%@"
		  //@"\tvariantType=%@"
		  //@"\tvisible=%u"
		  //@"\tdisplayTypeHint=%d"
		  @"\tdisplayRowHint=%@"
		  //@"\toverrideDisplayString=%@"
		  //@"\tdisabled=%d"
		  //@"\thidden=%d\n"
		  
		  ,view.key.name
		  ,view.key.representedString
		  ,view.key.displayString
		  ,view.key.displayType
		  ,view.key.interactionType
		  //,view.key.variantType
		  //,view.key.visible
		  //,view.key.displayTypeHint
		  ,view.key.displayRowHint
		  //,view.key.overrideDisplayString
		  //,view.key.disabled
		  //,view.key.hidden
		  );
}
#endif

//
+ (UIKBKeyView *)findKeyView:(NSString *)name inView:(UIView *)view
{
	for (UIKBKeyView *subview in view.subviews)
	{
		NSString *className = NSStringFromClass([subview class]);

#ifdef _LOG_KEY_VIEW
		_Log(@"Found View: %@\n", className);
		if ([className isEqualToString:@"UIKBKeyView"])
		{
			[self logKeyView:subview];
		}
#else
		if ([className isEqualToString:@"UIKBKeyView"])
		{
			if ((name == nil) || [subview.key.name isEqualToString:name])
			{
				return subview;
			}
		}
#endif
		else if (UIKBKeyView *subview2 = [self findKeyView:name inView:subview])
		{
			return subview2;
		}
	}
	return nil;
}

//
+ (UIKBKeyView *)findKeyView:(NSString *)name
{
	NSArray *windows = [[UIApplication sharedApplication] windows];
	if (windows.count < 2) return nil;
	return [self findKeyView:name inView:[windows objectAtIndex:1]];
}

//
+ (UIKBKeyView *)modifyKeyView:(NSString *)name display:(NSString *)display represent:(NSString *)represent interaction:(NSString *)type
{
	UIKBKeyView *view = [self findKeyView:name];
	if (view)
	{	
		view.key.representedString = represent;
		view.key.displayString = display;
		view.key.interactionType = type;
		[view setNeedsDisplay];
	}
	return view;
}

//
+ (UIButton *)addCustomButton:(NSString *)name title:(NSString *)title target:(id)target action:(SEL)action
{
	UIKBKeyView *view = [self findKeyView:name];
	if (view)
	{
		UIButton *button = [[[UIButton alloc] initWithFrame:view.frame] autorelease];
		button.titleLabel.font = [UIFont boldSystemFontOfSize:17];
		[button setTitle:title forState:UIControlStateNormal];
		[button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
		[button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
		[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];

		[view.superview addSubview:button];
		view.superview.userInteractionEnabled = YES;
		return button;
	}
	return nil;
}

@end


//
@implementation DecimalNumberField

//
- (id)initWithFrame:(CGRect)frame
{
	[super initWithFrame:frame];
	if (UIUtil::SystemVersion() >= 4.1)
	{
		self.keyboardType = UIKeyboardTypeDecimalPad;
	}
	else
	{
		self.keyboardType = UIKeyboardTypeNumberPad;
		if (UIUtil::IsPad() == NO)
		{
			self.kbDelegate = self;
		}
	}
	return self;
}

//
- (void)keyboardShow:(KBCustomTextField *)sender
{
	[KBCustomTextField modifyKeyView:@"NumberPad-Empty" display:@"." represent:@"." interaction:@"String"];
}

//
- (void)keyboardHide:(KBCustomTextField *)sender
{
	[KBCustomTextField modifyKeyView:@"NumberPad-Empty" display:nil represent:nil interaction:@"None"];
}

@end


//
@implementation DoneNumberField

//
- (id)initWithFrame:(CGRect)frame
{
	[super initWithFrame:frame];
	self.keyboardType = UIKeyboardTypeNumberPad;
	if (UIUtil::IsPad() == NO)
	{
		self.kbDelegate = self;
	}
	return self;
}

// Handle keyboard show
- (void)keyboardShow:(KBCustomTextField *)sender
{
	[self keyboardHide:self];
	_customButton = [[KBCustomTextField addCustomButton:@"NumberPad-Empty" title:NSLocalizedString(@"Hide KB", @"隐藏键盘") target:self action:@selector(onDoneButton:)] retain];
}

// Handle keyboard hide
- (void)keyboardHide:(KBCustomTextField *)sender
{
	[_customButton removeFromSuperview];
	[_customButton release];
	_customButton = nil;
}

//
- (void)onDoneButton:(UIButton *)sender
{
	[self resignFirstResponder];
}

@end
