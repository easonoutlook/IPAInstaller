

#import <UIKit/UIKit.h>


//
@interface UIImage (ImageEx)
+ (UIImage *)imageWithColor:(UIColor *)color;
- (UIImage *)scaleImageToSize:(CGSize)size;
- (UIImage *)cropImageInRect:(CGRect)rect;
//- (UIImage *)cropImageToRect:(CGRect)rect;
- (UIImage *)maskImageWithImage:(UIImage *)mask;
- (CGAffineTransform)orientationTransform:(CGSize *)newSize;
- (UIImage *)straightenAndScaleImage:(NSUInteger)maxDimension;
@end


//
@interface UIView (ViewEx)
- (void)removeSubviews;
- (UIView *)findFirstResponder;
- (UIView *)findSubview:(NSString *)cls;

- (void)fadeForAction:(SEL)action target:(id)target;
@end


//
@protocol AlertViewExDelegate
@required
- (void)doTask:(UIAlertView *)alertView;
@end

//
@interface UIAlertView (AlertViewEx)

//
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle;
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message;
+ (id)alertWithTitle:(NSString *)title;
+ (id)alertWithTask:(id/*<AlertViewExDelegate>*/)delegate title:(NSString *)title;

//
- (UITextField *)textField;
- (UIActivityIndicatorView *)activityIndicator;
- (void)dismiss;
- (void)dismissOnMainThread;
- (void)dismissAfterDelay:(NSTimeInterval)delay;

@end


//
@interface UITabBarController (TabBarControllerEx)
- (UIViewController *)currentViewController;
@end


//
@interface UIViewController (ViewControllerEx)
- (UINavigationController *)presentNavigationController:(UIViewController *)controller animated:(BOOL)animated;
- (UINavigationController *)presentModalNavigationController:(UIViewController *)controller animated:(BOOL)animated;
@end


// 
@interface SolidNavigationController: UINavigationController
{
}
@end


//
#define UIButtonTypeNavigationItem		(UIButtonType)100
#define UIButtonTypeNavigationBack		(UIButtonType)101
#define UIButtonTypeNavigationDone		(UIButtonType)102
@interface UIFlexButton: UIButton
{
}
@property(nonatomic,retain) UIColor *tintColor;
@end


//
#define UIButtonTypeTextured			(UIButtonType)110
@interface UITexturedButton: UIButton
{
}
@end


//
#define UIButtonTypeGlass				(UIButtonType)111
@interface UIGlassButton: UIButton
{
}
@property(nonatomic,retain) UIColor *tintColor;
@end
