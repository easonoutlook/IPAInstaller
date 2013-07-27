
#import "UIUtil.h"
#import "MoviePlayer.h"


@implementation MoviePlayer

//
- (id)initWithURL:(NSURL *)URL
{
	_URL = [URL retain];
	return [super init];
}

//
- (void)dealloc 
{
	if (_player)
	{
		if (!_playerRemoved) 
		{
			[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
		}

		[_player stop];
		[_player release];
		_player = nil;
	}
	
	[_URL release];

	[super dealloc];
}

//
- (void)RemoveCacheInTemp
{
	NSString* tempDir = NSTemporaryDirectory();
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:tempDir])
	{
		[fm removeItemAtPath:tempDir error:nil];
	}
}

//
- (void)loadView
{
	[super loadView];
	self.view.backgroundColor = [UIColor blackColor];
	
	[self RemoveCacheInTemp];
	
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
	
	_player = [[MPMoviePlayerController alloc] initWithContentURL:_URL];

	if (UIUtil::SystemVersion() >= 3.2)
	{
		[self.view addSubview:_player.view];
		_player.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
		_player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	}
}

//
- (void)viewDidLoad
{
	[super viewDidLoad];
	[_player play];
}


#pragma mark Video play notification

//
-(void)videoPlayFinished:(NSNotification *)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
	
	_playerRemoved = YES;
	
	MPMoviePlayerController *player = [notification object];
	[player stop];
}

@end
