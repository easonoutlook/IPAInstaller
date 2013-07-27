
#import "TabStripView.h"
#import "TabStripButton.h"

@interface TabStripView (Private)
- (void)setupCaps;
@end


@implementation TabStripView
@synthesize scrollView, leftCap, rightCap, delegate, dataSource, buttonInsets, momentary;

// 
- (id)initWithFrame:(CGRect)frame
{
	UIImage *image = [UIImage imageNamed:@"TabStripBack.png"];
	if (image)
	{
		frame.size.height = image.size.height;
	}

	[super initWithFrame:frame];
	self.userInteractionEnabled = YES;
	self.image = image;
	
	// Create scroll view
	frame.origin.x = 0;
	frame.origin.y = 0;
	scrollView = [[UIScrollView alloc] initWithFrame:frame];
	scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	scrollView.directionalLockEnabled = YES;
	scrollView.alwaysBounceVertical = NO;
	scrollView.alwaysBounceHorizontal = YES;
	scrollView.showsVerticalScrollIndicator = NO;
	scrollView.showsHorizontalScrollIndicator = NO;
	scrollView.bounces = YES;
	scrollView.contentInset = UIEdgeInsetsMake(0, 20, 0, 20);
	scrollView.delegate = self;
	[self addSubview:scrollView];

	// Create left cap
	UIImage *leftImage = [UIImage imageNamed:@"TabStripLeft.png"];
	leftCap = [[UIImageView alloc] initWithImage:leftImage];
	leftCap.hidden = YES;
	leftCap.center = CGPointMake(leftImage.size.width / 2, frame.size.height / 2);
	leftCap.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
	[self addSubview:leftCap];
	
	// Create right cap
	UIImage *rightImage = [UIImage imageNamed:@"TabStripRight.png"];
	rightCap = [[UIImageView alloc] initWithImage:rightImage];
	rightCap.hidden = YES;
	rightCap.center = CGPointMake(frame.size.width - rightImage.size.width / 2, frame.size.height / 2);
	rightCap.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
	[self addSubview:rightCap];

	return self;
}

//
- (NSString *)title
{
	return titleLabel.text;
}

//
- (void)setTitle:(NSString *)title
{
	UIFont *titleFont = [UIFont systemFontOfSize:14];
	CGSize titleSize = [title sizeWithFont:titleFont];
	CGRect titleFrame = CGRectMake(5, 0, titleSize.width, self.frame.size.height - 2);

	if (titleLabel == nil)
	{
		titleLabel = [[[UILabel alloc] initWithFrame:titleFrame] autorelease];
		titleLabel.text = title;
		titleLabel.font = titleFont;
		titleLabel.textColor = [UIColor blackColor];
		titleLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:titleLabel];
	}
	else
	{
		titleLabel.frame = titleFrame;
	}
	
	CGRect frame = scrollView.frame;
	frame.origin.x = titleFrame.origin.x + titleFrame.size.width - 5;
	frame.size.width = self.frame.size.width - frame.origin.x;
	scrollView.frame = frame;
	
	frame = leftCap.frame;
	frame.origin.x = titleFrame.origin.x + titleFrame.size.width - 5;
	leftCap.frame = frame;
}

//
- (void)didMoveToSuperview {
	[super didMoveToSuperview];
	
	scrollView.scrollsToTop = NO;
	[self reloadData];
	
	if(scrollView.subviews && scrollView.subviews.count > 0) {
		[(TabStripButton*)[scrollView.subviews objectAtIndex:0] markSelected];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOrientation) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)reloadData {
	if(scrollView.subviews && scrollView.subviews.count > 0) {
		[scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	}
	
	if(!self.dataSource) {
		return;
	}
	
	int items;
	
	if((items = [self.dataSource numberOfTabsInTabStripView:self]) == 0) {
		return;
	}
	
	int x;
	
	float origin_x = 0;
	for(x=0;x<items;x++) {
		NSString* str = [self.dataSource tabStripView:self titleForTabAtIndex:x];
		
		TabStripButton* button = [[TabStripButton alloc] initWithFrame:CGRectZero];
		
		if (momentary)
		{
			[button addTarget:self action:@selector(buttonDown:) forControlEvents:UIControlEventTouchDown];
		}
		[button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
		
		CGSize size = [str sizeWithFont:button.font];
		
		button.frame = CGRectMake(origin_x, 0.0f, size.width+20.0f, self.frame.size.height);
		origin_x += size.width + 3.0f + 20.0f;
		button.text = str;
		
		[scrollView addSubview:button];
		
		[button release];
	}
	
	scrollView.contentSize = CGSizeMake(origin_x, self.frame.size.height);
	
	[self setupCaps];
}


- (void)buttonDown:(TabStripButton*)button
{
	[scrollView.subviews makeObjectsPerformSelector:@selector(markUnselected)];
	[button markSelected];
}


- (void)buttonClicked:(TabStripButton*)button
{
	[scrollView.subviews makeObjectsPerformSelector:@selector(markUnselected)];
	if (momentary == NO)
	{
		[button markSelected];
	}

	if(self.delegate && [self.delegate respondsToSelector:@selector(tabStripView:didSelectedTabAtIndex:)])
	{
		[self.delegate tabStripView:self didSelectedTabAtIndex:[scrollView.subviews indexOfObject:button]];
	}
}

- (void)selectTabAtIndex:(NSUInteger)index {
	[self selectTabAtIndex:index animated:NO];
}

- (void)selectTabAtIndex:(NSUInteger)index animated:(BOOL)animated {
	if(!scrollView.subviews) return;
	
	[scrollView.subviews makeObjectsPerformSelector:@selector(markUnselected)];

	if(index >= (NSUInteger)scrollView.subviews.count) return;

	[(TabStripButton*)[scrollView.subviews objectAtIndex:index] markSelected];
	
	CGRect rect = ((TabStripButton*)[scrollView.subviews objectAtIndex:index]).frame;
	rect.size.width += 25.0f;
	
	[scrollView scrollRectToVisible:rect animated:animated];
	
	[self setupCaps];
}

- (void)updateOrientation {
	[self performSelector:@selector(setupCaps) withObject:nil afterDelay:0.3];
}

- (void)setupCaps {
	if(scrollView.contentSize.width <= scrollView.frame.size.width - scrollView.contentInset.left - scrollView.contentInset.right) {
		leftCap.hidden = YES;
		rightCap.hidden = YES;
	} else {
		if(scrollView.contentOffset.x > (-scrollView.contentInset.left)+10.0f) {
			leftCap.hidden = NO;
		} else {
			leftCap.hidden = YES;
		}
		
		if((scrollView.frame.size.width+scrollView.contentOffset.x)+10.0f >= scrollView.contentSize.width) {
			rightCap.hidden = YES;
		} else {
			rightCap.hidden = NO;
		}
	}
	
}

- (void)scrollViewDidScroll:(UIScrollView *)inScrollView {
	[self setupCaps];
}

- (NSInteger)selectedTabIndex {
	int x = 0;
	
	for(TabStripButton* tab in scrollView.subviews) {
		if([tab isMemberOfClass:[TabStripButton class]]) {
			if([tab isSelected]) return x;
		}
		
		x++;
	}
	
	return NSNotFound;
}

- (void)setButtonInsets:(UIEdgeInsets)insets {
	buttonInsets = UIEdgeInsetsMake(0.0f, insets.left, 0.0f, insets.right);
	self.scrollView.contentInset = buttonInsets;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	[scrollView release];
	[leftCap release];
	[rightCap release];
	[super dealloc];
}


@end
