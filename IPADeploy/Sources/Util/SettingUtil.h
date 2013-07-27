
#import "NSUtil.h"

//
#define kSettingsFile	@"Settings.plist"

//
class Settings
{
public:
	//
	static NSMutableDictionary *_settings;

public:
	//
	Settings()
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		//if (_settings == nil)
		{
			NSString *path = NSUtil::DocumentsSubPath(kSettingsFile);
			_settings = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
			if (_settings == nil) _settings = [[NSMutableDictionary alloc] init];
		}
		[pool release];
	}
	
	//
	~Settings()
	{
		[_settings release];
		_settings = nil;
	}

public:
	//
	NS_INLINE void Save()
	{
		[_settings writeToFile:NSUtil::DocumentsSubPath(kSettingsFile) atomically:YES];
	}
	
	//
	NS_INLINE id Get(NSString *key)
	{
		return [_settings valueForKey:key];
	}
	
	//
	NS_INLINE void Set(NSString *key, id value = nil)
	{
		[_settings setValue:value forKey:key];
	}
	
	// 
	NS_INLINE void Save(NSString *key, id value = nil)
	{
		Set(key, value);
		Save();
	}
};
