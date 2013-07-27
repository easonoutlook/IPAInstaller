
#import <Foundation/Foundation.h>

//
enum DownloadMode
{
	DownloadFromLocal,		// Load from local cache only
	DownloadFromOnline,		// Download from online (and cache it)
	DownloadCheckLocal,		// Check local cache: DownloadFromLocal on existing; DownloadFromOnline otherwise.
	DownloadCheckOnline,	// Check online update: DownloadFromOnline on updating; DownloadFromLocal otherwize.
};


//
class DownloadUtil
{
public:
	// Download data from local or online
	static NSData *DownloadData(NSString *url, NSString *to, DownloadMode mode = DownloadCheckOnline);

public:
	// Request HTTP data
	static NSData *HttpData(NSString *url, NSData *post = nil);
	
	// Request HTTP string
	static NSString *HttpString(NSString *url, NSString *post = nil);
	
	// Request HTTP file
	// Return error string, or nil on success
	static NSString *HttpFile(NSString *url, NSString *path);

public:
	// Request HTTP
	static NSData *HttpRequest(NSString *url, NSHTTPURLResponse **response, NSURLRequestCachePolicy cachePolicy = NSURLRequestUseProtocolCachePolicy);
};
