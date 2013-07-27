
#import <UIKit/UIKit.h>


@interface TabStripButton : UIControl {
@private
	UILabel* label;
	UIImageView* imageView;
}

- (void)markSelected;
- (void)markUnselected;	

@property(nonatomic,copy) NSString* text;
@property(readonly) UIFont* font;
@end
