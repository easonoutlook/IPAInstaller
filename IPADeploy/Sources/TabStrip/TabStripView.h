
#import <UIKit/UIKit.h>

@class TabStripView;

/*
 * Creating instances of this class by yourself is relatively useless.
 * If it's absolutely neccessary see the loadView method in TabStripleViewController
 */

@protocol TabStripViewDelegate, TabStripViewDataSource;

@interface TabStripView : UIImageView<UIScrollViewDelegate> {
@private
	UIScrollView* scrollView;
	UIView* leftCap;
	UIView* rightCap;
	id dataSource;
	id delegate;
	UIEdgeInsets buttonInsets;
	UILabel *titleLabel;
	BOOL momentary;
}

/*
 * Reloads the tabs
 */
- (void)reloadData;

/* 
 * Scrolls to and selects the tab at the given index, no scrolling animation
 */
- (void)selectTabAtIndex:(NSUInteger)index;

/*
 * Scrolls to and selects the tab at the given index, scrolling animation optional
 */
- (void)selectTabAtIndex:(NSUInteger)index animated:(BOOL)animated;

/*
 * @see TabStripViewDelegate protocol
 */
@property(nonatomic,assign) IBOutlet id<TabStripViewDelegate> delegate;

/*
 * @see TabStripViewDataSource protocol
 */
@property(nonatomic,assign) IBOutlet id<TabStripViewDataSource> dataSource;

/*
 * Currectly selected tab
 */
@property(readonly) NSInteger selectedTabIndex;

/*
 * Allows you to set the button left/right insets, top/bottom values will be set to 0 regardless.
 */
@property(nonatomic,assign) UIEdgeInsets buttonInsets;

/*
 * These properties are used internally, shouldn't need to be used elsewhere.
 */
@property(nonatomic,readonly) UIScrollView* scrollView;
@property(nonatomic,readonly) UIView* leftCap;
@property(nonatomic,readonly) UIView* rightCap;

/*
 * Momentary style.
 */
@property(nonatomic,getter=isMomentary) BOOL momentary;

/*
 * Allows you to a title.
 */
@property(nonatomic,retain) NSString* title;

@end

@protocol TabStripViewDelegate<NSObject>
- (void)tabStripView:(TabStripView*)tabStripView didSelectedTabAtIndex:(NSInteger)index;
@end

@protocol TabStripViewDataSource<NSObject>
- (NSInteger)numberOfTabsInTabStripView:(TabStripView*)tabStripView;
- (NSString*)tabStripView:(TabStripView*)tabStripView titleForTabAtIndex:(NSInteger)index;
@end
