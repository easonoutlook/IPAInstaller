
#import "AppDelegate.h"
#import "PredictScrollView.h"


@implementation PredictScrollView
@synthesize pages=_pages;
@synthesize currentPage=_itemPage;
@synthesize numberOfPages=_numberOfPages;
@synthesize delegate2=_delegate2;


#pragma mark Generic methods

// Constructor
- (id)initWithFrame:(CGRect)frame
{
	frame.origin.x = -5;
	frame.size.width += 10;
	[super initWithFrame:frame];
	self.pagingEnabled = YES;
	self.delegate = self;
	//self.backgroundColor = [UIColor blackColor];

	return self;
}

// Destructor
- (void)dealloc
{
	if (_pages) free(_pages);
	[super dealloc];
}

//
- (void)removeFromSuperview
{
	_delegate2 = nil;
	[super removeFromSuperview];
}

// Remove cached pages
- (void)freePages:(BOOL)force
{	
	NSUInteger count = _numberOfPages;
	for (NSUInteger i = 0; i < count; ++i)
	{
		if (_pages[i]) 
		{
			if ((i != _itemPage) && (force || ((i != _itemPage - 1) && (i != _itemPage + 1))))
			{
				[_pages[i] removeFromSuperview];
				_pages[i] = nil;
			}
		}
	}
}

//
- (void)loadPage:(NSUInteger)index
{	
	if (index >= _numberOfPages) return;
	if (_pages[index]) return;

	CGRect frame = self.frame;
	frame.origin.y = 0;
	frame.origin.x = frame.size.width * index + 5;
	frame.size.width -= 10;

	_pages[index] = [_delegate2 scrollView:self viewForPage:index inFrame:frame];
	_pages[index].autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	[self addSubview:_pages[index]];
}

//
- (void)loadNearby
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self loadPage:_itemPage - 1];
	[self loadPage:_itemPage + 1];
	[pool release];
}

//
- (void)scheduledNearby
{	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self performSelectorOnMainThread:@selector(loadNearby) withObject:nil waitUntilDone:YES];
	[pool release];
}

//
- (void)loadPages
{	
	[self freePages:NO];
	[self loadPage:_itemPage];
	[_delegate2 scrollView:self scrollToPage:_itemPage];

	// TODO: Check for call mode
	[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(scheduledNearby) userInfo:nil repeats:NO];
}

//
- (void)setCurrentPage:(NSUInteger)currentPage
{	
	if (currentPage >= _numberOfPages)
	{
		currentPage = 0;
	}
	if (_itemPage != currentPage)
	{
		self.contentOffset = CGPointMake(self.frame.size.width * currentPage, 0);
	}
	else
	{
		[self loadPages];
	}
}

//
- (void)setNumberOfPages:(NSUInteger)numberOfPages
{
	if (_numberOfPages) [self removeSubviews];
	_numberOfPages = numberOfPages;
	
	NSUInteger size = numberOfPages * sizeof(UIView *);
	_pages = (UIView **)realloc(_pages, size);
	memset(_pages, 0, size);
}


#pragma mark View methods

// Layout subviews.
- (void)layoutSubviews
{	
	_bIgnore = YES;
	[super layoutSubviews];
	self.contentSize = CGSizeMake(self.frame.size.width * _numberOfPages, self.frame.size.height);
	_bIgnore = NO;
}

// Set view frame.
- (void)setFrame:(CGRect)frame
{	
	_bIgnore = YES;
	[super setFrame:frame];
	self.contentOffset = CGPointMake(frame.size.width * _itemPage, 0);
	_bIgnore = NO;
}


#pragma mark Scroll view methods

//
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{	
	if (_bIgnore) return;

	CGFloat width = scrollView.frame.size.width;
	NSUInteger currentPage = floor((scrollView.contentOffset.x - width / 2) / width) + 1;
	if (_itemPage != currentPage)
	{
		_itemPage = currentPage;
		[self loadPages];
	}
}

@end


//
@implementation PageControlScrollView
@synthesize pageCtrl=_pageCtrl;

//
- (id)initWithFrame:(CGRect)frame
{
	[super initWithFrame:frame];

	frame.origin.y = 0;//frame.size.height - 40;
	frame.size.height = 26;
	_pageCtrl = [[UIPageControl alloc] initWithFrame:frame];
	_pageCtrl.autoresizingMask = UIViewAutoresizingFlexibleWidth/* | UIViewAutoresizingFlexibleTopMargin*/;
	_pageCtrl.numberOfPages = 0;
	_pageCtrl.currentPage = 0;
	_pageCtrl.hidesForSinglePage = YES;
	[_pageCtrl addTarget:self action:@selector(setCurrentPage) forControlEvents:UIControlEventValueChanged];

	return self;
}

//
- (void)dealloc
{
	[_pageCtrl release];
	[super dealloc];
}

//
- (void)willMoveToSuperview:(UIView *)newSuperview
{
	if (_hasParent)
	{
		[_pageCtrl removeFromSuperview];
		_hasParent = NO;
	}
}

//
- (void)didMoveToSuperview
{
	if (self.superview)
	{
		_hasParent = YES;
		[self.superview addSubview:_pageCtrl];
	}
}

//
- (void)setNumberOfPages:(NSUInteger)count
{
	[super setNumberOfPages:count];
	_pageCtrl.numberOfPages = count;
}

//
- (void)loadPages
{
	[super loadPages];
	_pageCtrl.currentPage = self.currentPage;
}

//
- (void)setCurrentPage
{
	self.currentPage = _pageCtrl.currentPage;
}

@end

