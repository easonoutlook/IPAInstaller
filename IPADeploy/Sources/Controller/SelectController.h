//TODO: Optimize
#import <UIKit/UIKit.h>

// TODO: check & reflector it totally before using it

//
@class SelectController;
@protocol SelectControllerDelegate
- (BOOL)didSelect:(SelectController *)controller selectedIndex:(NSUInteger)select;
@end

//
@interface SelectController : UITableViewController 
{
	NSArray *_array;
	NSUInteger _selectedIndex;
	NSUInteger _tag;
	
	id<SelectControllerDelegate> _delegate;
}

@property(nonatomic) NSUInteger tag;
@property(nonatomic,assign) id<SelectControllerDelegate> delegate;
@property(nonatomic) NSUInteger selectedIndex;

- (id)initWithArray:(NSArray *)array selectedIndex:(NSUInteger)select;


@end
