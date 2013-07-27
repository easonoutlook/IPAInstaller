
#import <UIKit/UIKit.h>
#import "DelayImageView.h"

//TODO: Porting UILongPressGestureRecognizer to 3.0～3.1.2, instead of using this subclass

//
@protocol TouchViewDelegate <NSObject>
@optional
- (BOOL)touchView:(UIView *)sender touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (BOOL)touchView:(UIView *)sender touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (BOOL)touchView:(UIView *)sender touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
@end


//
#define _DeclareTouchView(TouchView, ParentView)	\
	\
@interface TouchView : ParentView	\
{	\
	BOOL _showTouchHighlight;	\
	BOOL _acceptOutsideTouch;	\
	id<TouchViewDelegate> _touchDelegate;	\
}	\
@property(nonatomic, assign) BOOL showTouchHighlight;	\
@property(nonatomic, assign) BOOL acceptOutsideTouch;	\
@property(nonatomic, assign) id<TouchViewDelegate> touchDelegate;	\
@end


//
#define _ImplementTouchView(TouchView)	\
@implementation TouchView	\
@synthesize showTouchHighlight=_showTouchHighlight;	\
@synthesize acceptOutsideTouch=_acceptOutsideTouch;	\
@synthesize touchDelegate=_touchDelegate;	\
	\
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event	\
{	\
	if (_showTouchHighlight)	\
	{	\
		self.alpha = 0.75;	\
	}	\
	if ([_touchDelegate respondsToSelector:@selector(touchView: touchesBegan: withEvent:)] == NO ||	\
		[_touchDelegate touchView:self touchesBegan:touches withEvent:event] == NO)	\
		[super touchesBegan:touches withEvent:event];	\
}	\
	\
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event	\
{	\
	if (_showTouchHighlight)	\
	{	\
		self.alpha = 1;	\
	}	\
	if (_acceptOutsideTouch == NO)	\
	{	\
		UITouch *touch = [touches anyObject];	\
		CGPoint location = [touch locationInView:self];	\
		if ([self pointInside:location withEvent:event] == NO)	\
		{	\
			[super touchesEnded:touches withEvent:event];	\
			return;	\
		}	\
	}	\
	if ([_touchDelegate respondsToSelector:@selector(touchView: touchesEnded: withEvent:)] == NO ||	\
		[_touchDelegate touchView:self touchesEnded:touches withEvent:event] == NO)	\
		[super touchesEnded:touches withEvent:event];	\
}	\
	\
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event	\
{	\
	if (_showTouchHighlight)	\
	{	\
		self.alpha = 1;	\
	}	\
	if ([_touchDelegate respondsToSelector:@selector(touchView: touchesCancelled: withEvent:)] == NO ||	\
		[_touchDelegate touchView:self touchesCancelled:touches withEvent:event] == NO)	\
		[super touchesCancelled:touches withEvent:event];	\
}	\
@end

//
//_DeclareTouchView(TouchView, UIView);
_DeclareTouchView(TouchImageView, UIImageView);
_DeclareTouchView(TouchScrollView, UIScrollView);
//_DeclareTouchView(TouchDelayImageView, DelayImageView);


