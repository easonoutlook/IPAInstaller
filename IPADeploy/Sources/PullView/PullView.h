

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

//
typedef enum
{
	PullViewStateNormal,
	PullViewStatePulling,
	PullViewStateLoading,	
}
PullViewState;


//
@protocol PullViewDelegate;
@interface PullView : UIView
{
	BOOL _ignore;

	PullViewState _state;
	id<PullViewDelegate> _delegate;

	CALayer *_arrowImage;
	UILabel *_stampLabel;
	UILabel *_stateLabel;
	UIActivityIndicatorView *_activityView;
}

@property(nonatomic,assign) PullViewState state;
@property(nonatomic,assign) id<PullViewDelegate> delegate;

//@property(nonatomic,readonly) CALayer *arrowImage;
@property(nonatomic,readonly) UILabel *stampLabel;
@property(nonatomic,readonly) UILabel *stateLabel;
//@property(nonatomic,readonly) UIActivityIndicatorView *activityView;

- (void)didScroll;
- (BOOL)endDragging;
- (void)beginLoading;
- (void)finishLoading;

@end


//
@protocol PullViewDelegate
@optional
- (NSString *)pullView:(PullView *)pullView textForState:(PullViewState)state;
@end


//
@interface UIScrollView (PullScrollView)
@property(nonatomic,readonly) PullView *pullView;
@end


