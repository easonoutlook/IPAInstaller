
#import "PullView.h"


@implementation PullView
@synthesize state=_state;
@synthesize delegate=_delegate;

//@synthesize arrowImage=_arrowImage;
@synthesize stampLabel=_stampLabel;
@synthesize stateLabel=_stateLabel;
//@synthesize activityView=_activityView;

//
- (id)initWithFrame:(CGRect)frame
{
	[super initWithFrame:frame];

	//
	_stampLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_stampLabel.font = [UIFont systemFontOfSize:12];
	_stampLabel.textColor = [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0];
	_stampLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1];
	_stampLabel.shadowOffset = CGSizeMake(0, 1);
	_stampLabel.backgroundColor = [UIColor clearColor];
	_stampLabel.textAlignment = UITextAlignmentCenter;
	[self addSubview:_stampLabel];
	[_stampLabel release];
	
	//
	_stateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_stateLabel.font = [UIFont boldSystemFontOfSize:13];
	_stateLabel.textColor = [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0];
	_stateLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1];
	_stateLabel.shadowOffset = CGSizeMake(0, 1);
	_stateLabel.backgroundColor = [UIColor clearColor];
	_stateLabel.textAlignment = UITextAlignmentCenter;
	[self addSubview:_stateLabel];
	[_stateLabel release];
	
	//
	_arrowImage = [CALayer layer];
	_arrowImage.contentsGravity = kCAGravityResizeAspect;
	_arrowImage.contents = (id)[UIImage imageNamed:@"PullArrow.png"].CGImage;
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
	{
		_arrowImage.contentsScale = [[UIScreen mainScreen] scale];
	}
	[[self layer] addSublayer:_arrowImage];
	
	//
	_activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[self addSubview:_activityView];
	[_activityView release];
	
	self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth;// | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
	self.delegate = nil;

    return self;
}

//
- (void)layoutSubviews
{
	[super layoutSubviews];

	CGRect frame = self.frame;
	_stampLabel.frame = CGRectMake(0, frame.size.height - 30, frame.size.width, 20);
	_stateLabel.frame = CGRectMake(0, frame.size.height - 48, frame.size.width, 20);
	_arrowImage.frame = CGRectMake(25, frame.size.height - 65, 30, 55);
	_activityView.frame = CGRectMake(25, frame.size.height - 40, 20, 20);
}

//
- (void)setDelegate:(id <PullViewDelegate>)delegate
{
	_delegate = delegate;
	_stateLabel.text = [(id)_delegate respondsToSelector:@selector(pullView: textForState:)] ? [_delegate pullView:self textForState:PullViewStateNormal] : NSLocalizedString(@"Pull down to refresh...", @"下拉可以更新⋯");
}

//
- (void)setState:(PullViewState)state
{
	NSString *statusText = [(id)_delegate respondsToSelector:@selector(pullView: textForState:)] ? [_delegate pullView:self textForState:state] : nil;
	
	switch (state)
	{
		case PullViewStateNormal:
			if (_state == PullViewStatePulling)
			{
				[CATransaction begin];
				[CATransaction setAnimationDuration:0.2f];
				_arrowImage.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
			_stateLabel.text = statusText ? statusText : NSLocalizedString(@"Pull down to refresh...", @"下拉可以更新⋯");
			[_activityView stopAnimating];
			
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = NO;
			_arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
			break;
			
		case PullViewStatePulling:
			_stateLabel.text = statusText ? statusText : NSLocalizedString(@"Release to refresh...", @"松开立即更新⋯");
			[CATransaction begin];
			[CATransaction setAnimationDuration:0.2f];
			_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180, 0, 0, 1);
			[CATransaction commit];
			break;
			
		case PullViewStateLoading:
			_stateLabel.text = statusText ? statusText : NSLocalizedString(@"Loading...", @"加载中⋯");
			[_activityView startAnimating];
			
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = YES;
			[CATransaction commit];
			break;
			
		default:
			break;
	}
	_state = state;
}

//
- (void)didScroll
{
	if (_ignore)
	{
		return;
	}
	_ignore = YES;
	
	UIScrollView *scrollView = (UIScrollView *)self.superview;
	if (_state == PullViewStateLoading)
	{
		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
		offset = MIN(offset, 60);
		scrollView.contentInset = UIEdgeInsetsMake(offset, 0, 0, 0);
	}
	else if (scrollView.isDragging)
	{
		if (_state == PullViewStatePulling)
		{
			if ((scrollView.contentOffset.y > -65) && (scrollView.contentOffset.y < 0))
			{
				self.state = PullViewStateNormal;
			}
		}
		else
		{
			if (scrollView.contentOffset.y < -65)
			{
				self.state = PullViewStatePulling;
			}
		}
		
		if (scrollView.contentInset.top != 0)
		{
			scrollView.contentInset = UIEdgeInsetsZero;
		}
	}
	
	_ignore = NO;
}

//
- (BOOL)endDragging
{
	UIScrollView *scrollView = (UIScrollView *)self.superview;
	return (scrollView.contentOffset.y <= -65) && (_state != PullViewStateLoading);
}

//
- (void)beginLoading
{
	UIScrollView *scrollView = (UIScrollView *)self.superview;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.2];

	_ignore = YES;
	scrollView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
	scrollView.contentOffset = CGPointMake(0, -60);
	_ignore = NO;

	[UIView commitAnimations];
	
	self.state = PullViewStateLoading;
}

//
- (void)fold
{
	UIScrollView *scrollView = (UIScrollView *)self.superview;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];

	_ignore = YES;
	scrollView.contentInset = UIEdgeInsetsZero;
	_ignore = NO;

	[UIView commitAnimations];
}

//
- (void)finishLoading
{
	[self fold];
	self.state = PullViewStateNormal;
}

//
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self fold];
	[super touchesBegan:touches withEvent:event];
}

@end


//
@implementation UIScrollView (PullScrollView)

//
#define kPullViewTag 28182
- (PullView *)pullView
{
	PullView *pullView = (PullView *)[self viewWithTag:kPullViewTag];
	if (pullView == nil)
	{
		pullView = [[[PullView alloc] initWithFrame:CGRectMake(0, -self.frame.size.height - self.contentInset.top, self.frame.size.width, self.frame.size.height)] autorelease];
		pullView.tag = kPullViewTag;
		[self addSubview:pullView];
	}
	return pullView;
}

@end
