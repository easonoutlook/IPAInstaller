
#import <Foundation/Foundation.h>

//
class NSUtil
{
#pragma mark Appcalition path methods
public:
	//
	NS_INLINE NSBundle *Bundle()
	{
		return [NSBundle mainBundle];
	}
	
	//
	NS_INLINE id BundleInfo(NSString *key)
	{
		return [Bundle() objectForInfoDictionaryKey:key];
	}
	
	//
	NS_INLINE NSString *BundleName()
	{
		return BundleInfo(@"CFBundleName");
	}
	
	//
	NS_INLINE NSString *BundleDisplayName()
	{
		return BundleInfo(@"CFBundleDisplayName");
	}
	
	//
	NS_INLINE NSString *BundleVersion()
	{
		return BundleInfo(@"CFBundleVersion");
	}
	
	//
	NS_INLINE NSString *BundlePath()
	{
		return [Bundle() bundlePath];
	}
	
	//
	NS_INLINE NSString *BundleSubPath(NSString *file)
	{
		return [BundlePath() stringByAppendingPathComponent:file];
	}

#pragma mark File manager methods	
public:
	//
	NS_INLINE NSFileManager *FileManager()
	{
		return [NSFileManager defaultManager];
	}
	
	//
	NS_INLINE BOOL IsPathExist(NSString* path)
	{
		return [FileManager() fileExistsAtPath:path];
	}
	
	//
	NS_INLINE BOOL IsFileExist(NSString* path)
	{
		BOOL isDirectory;
		return [FileManager() fileExistsAtPath:path isDirectory:&isDirectory] && !isDirectory;
	}
	
	//
	NS_INLINE BOOL IsDirectoryExist(NSString* path)
	{
		BOOL isDirectory;
		return [FileManager() fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory;
	}
	
	//
	NS_INLINE BOOL RemovePath(NSString* path)
	{
		return [FileManager() removeItemAtPath:path error:nil];
	}

#pragma mark User directory methods
public:
	//
	NS_INLINE NSString *UserDirectoryPath(NSSearchPathDirectory directory)
	{
		return [NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES) objectAtIndex:0];
	}
	
	//
	NS_INLINE NSString *DocumentsPath()
	{
		return UserDirectoryPath(NSDocumentDirectory);
	}
	
	// 
	NS_INLINE NSString *DocumentsSubPath(NSString *file)
	{
		return [DocumentsPath() stringByAppendingPathComponent:file];
	}

#pragma mark User defaults
public:
	//
	NS_INLINE NSUserDefaults *UserDefaults()
	{
		return [NSUserDefaults standardUserDefaults];
	}
	
	//
	NS_INLINE id DefaultForKey(NSString *key)
	{
		return [UserDefaults() objectForKey:key];
	}

	//
	NS_INLINE void SetDefaultForKey(NSString *key, id value)
	{
		return [UserDefaults() setObject:value forKey:key];
	}

	//
	NS_INLINE NSString *PhoneNumber()
	{
		return DefaultForKey(@"SBFormattedPhoneNumber");
	}

	//
	NS_INLINE NSString *DefaultLanguage()
	{
		return [[NSLocale preferredLanguages] objectAtIndex:0];
		//return [DefaultForKey(@"AppleLanguages") objectAtIndex:0];
	}

#pragma mark Cache methods
public:
	//
	NS_INLINE NSString *CachePath()
	{
		return DocumentsSubPath(@"Cache");
		//return UserDirectoryPath(NSCachesDirectory);
	}
	
	//
	NS_INLINE void RemoveCache()
	{	
		[FileManager() removeItemAtPath:CachePath() error:nil];
	}
	
	//
	NS_INLINE NSString *CacheSubPath(NSString *file)
	{
		NSString *dir = CachePath();
		if (IsDirectoryExist(dir) == NO)
		{
			[FileManager() createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
		}
		return [dir stringByAppendingPathComponent:file];
	}
	
	//
	NS_INLINE NSString *CacheUrlPath(NSString *url)
	{
		unichar chars[256];
		NSRange range = {0, MIN(url.length, 256)};
		[url getCharacters:chars range:range];
		for (NSUInteger i = 0; i < range.length; i++)
		{
			switch (chars[i])
			{
				case '|':
				case '/':
				case '\\':
				case '?':
				case '*':
				case ':':
				case '<':
				case '>':
				case '"':
					chars[i] = '_';
					break;
			}
		}
		NSString *file = [NSString stringWithCharacters:chars length:range.length];
		return CacheSubPath(file);
	}

#pragma mark Format methods
public:	
	// Convert number to string
	static NSString *FormatNumber(NSNumber *number, NSNumberFormatterStyle style = NSNumberFormatterNoStyle);
	
	// Convert date to string
	static NSString *FormatDate(NSDate *date, NSString *format);
	
	// Convert date to string
	static NSString *FormatDate(NSDate *date, NSDateFormatterStyle dateStyle, NSDateFormatterStyle timeStyle = NSDateFormatterNoStyle);
	
	// Convert string to date
	static NSDate *FormatDate(NSString *string, NSString *format = @"yyyy-MM-dd HH:mm:ss", NSLocale *locale = nil);
	
	// Convert string to date
	static NSDate *FormatDate(NSString *string, NSDateFormatterStyle dateStyle, NSDateFormatterStyle timeStyle = NSDateFormatterNoStyle, NSLocale *locale = nil);

	// Convert date to readable string. Return nil on fail
	static NSString *SmartDate(NSDate *date);
	
	// Convert date to smart string
	static NSString *SmartDate(NSDate *date, NSString *format);

	// Convert date to smart string
	static NSString *SmartDate(NSDate *date, NSDateFormatterStyle dateStyle);

	// Convert date to smart string
	static NSString *SmartDate(NSDate *date, NSDateFormatterStyle dateStyle, NSDateFormatterStyle timeStyle);

#pragma mark Crypto methods
public:
	// Check email address
	static BOOL IsEmailAddress(NSString *emailAddress);
	
	// Check phone number equal
	static BOOL IsPhoneNumberEqual(NSString *phoneNumber1, NSString *phoneNumber2, NSUInteger minEqual = 10);

	// Calculate MD5
	static NSString *MD5(NSString *str);

	// Calculate HMAC SHA1
	static NSString *HmacSHA1(NSString *text, NSString *secret);

	// BASE64 encode
	static NSString *BASE64Encode(const unsigned char *data, NSUInteger length, NSUInteger lineLength = 0);
	
	// BASE64 decode
	static NSData *BASE64Decode(NSString *string);
	
	// BASE64 encode data
	NS_INLINE NSString *BASE64EncodeData(NSData *data, NSUInteger lineLength = 0)
	{
		return BASE64Encode((const unsigned char *)data.bytes, data.length, lineLength);
	}

	// BASE64 encode string
	NS_INLINE NSString *BASE64EncodeString(NSString *string, NSUInteger lineLength = 0)
	{
		return BASE64EncodeData([string dataUsingEncoding:NSUTF8StringEncoding], lineLength);
	}
	
	// BASE64 decode string
	NS_INLINE NSString *BASE64DecodeString(NSString *string)
	{
		NSData *data = BASE64Decode(string);
		return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	}

public:
	//
	NS_INLINE NSString *URLEscape(NSString *string)
	{
		CFStringRef result = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
																	 (CFStringRef)string,
																	 NULL,
																	 CFSTR("!*'();:@&=+$,/?%#[]"),
																	 kCFStringEncodingUTF8);
		return [(NSString *)result autorelease];
	}

	//
	NS_INLINE NSString *URLUnEscape(NSString *string)
	{
		CFStringRef result = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
																					 (CFStringRef)string,
																					 CFSTR(""),
																					 kCFStringEncodingUTF8);
		return [(NSString *)result autorelease];
	}

	//
	NS_INLINE NSString *TS()
	{
		return [NSString stringWithFormat:@"%d", time(NULL)];
	}

	//
	NS_INLINE NSString *UUID()
	{
		CFUUIDRef uuid = CFUUIDCreate(NULL);
		CFStringRef string = CFUUIDCreateString(NULL, uuid);
		CFRelease(uuid);
		return (NSString *)string;
	}
};
