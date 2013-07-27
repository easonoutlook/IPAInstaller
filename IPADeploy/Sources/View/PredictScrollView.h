//TODO: Optimize
#import <UIKit/UIKit.h>


//
@class PredictScrollView;
@protocol PredictScrollViewDelegate <NSObject>
@required
- (UIView *)scrollView:(PredictScrollView *)scrollView viewForPage:(NSUInteger)index inFrame:(CGRect)frame;
- (void)scrollView:(PredictScrollView *)scrollView scrollToPage:(NSUInteger)index;
@end


//
@interface PredictScrollView : UIScrollView <UIScrollViewDelegate>
{
	BOOL _bIgnore;
	UIView **_pages;
	NSUInteger _itemPage;
	NSUInteger _numberOfPages;
	id<PredictScrollViewDelegate> _delegate2;
}

@property(nonatomic,readonly) UIView **pages;
@property(nonatomic,assign) NSUInteger currentPage;
@property(nonatomic,assign) NSUInteger numberOfPages;
@property(nonatomic,assign) id<PredictScrollViewDelegate> delegate2;

@end


//
@interface PageControlScrollView : PredictScrollView
{
	BOOL _hasParent;
	UIPageControl *_pageCtrl;
}
@property(nonatomic,readonly) UIPageControl *pageCtrl;
@end
