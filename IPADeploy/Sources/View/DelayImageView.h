
#import <UIKit/UIKit.h>


//
@interface DelayImageView: UIImageView
{
	BOOL _force;
	BOOL _loaded;
	NSString *_url;
	NSString *_def;
	UIActivityIndicatorView *_activityView;
}

- (id)initWithUrl:(NSString *)url frame:(CGRect)frame;

@property (nonatomic,retain) NSString *url;
@property (nonatomic,retain) NSString *def;
@property (nonatomic,readonly) BOOL loaded;
@end

