
#import "NSUtil.h"
#import "UIUtil.h"
#import "DownloadUtil.h"

//
NSData *DownloadUtil::DownloadData(NSString *url, NSString *to, DownloadMode mode)
{
	if ((mode == DownloadFromLocal) || ((mode == DownloadCheckLocal) && NSUtil::IsFileExist(to)))
	{
		return [NSData dataWithContentsOfFile:to];
	}

	NSError *error = nil;
	NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url] options:((mode == DownloadCheckOnline) ? 0 : NSUncachedRead) error:&error];
	[data writeToFile:to atomically:NO];
	return data;
}


// Request HTTP data
NSData *DownloadUtil::HttpData(NSString *url, NSData *post)
{
	UIUtil::ShowNetworkIndicator(YES);
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]]; 
	if (post)
	{
		[request setHTTPMethod:@"POST"];
		[request setHTTPBody:post];
	}
	
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	
	UIUtil::ShowNetworkIndicator(NO);
	return data;
}

// Request HTTP string
NSString *DownloadUtil::HttpString(NSString *url, NSString *post)
{
	NSData *send = post ? [NSData dataWithBytes:[post UTF8String] length:[post length]] : nil;
	NSData *recv = HttpData(url, send);
	return recv ? [[[NSString alloc] initWithData:recv encoding:NSUTF8StringEncoding] autorelease] : nil;
}

// Request HTTP file
// Return error string, or nil on success
NSString *DownloadUtil::HttpFile(NSString *url, NSString *path)
{
	UIUtil::ShowNetworkIndicator(YES);
	
	NSError *error = nil;
	NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url] options:NSUncachedRead error:&error];
	if (data != nil)
	{
		[data writeToFile:path atomically:NO];
		[data release];
	}
	
	UIUtil::ShowNetworkIndicator(NO);
	
	return data ? nil : error.localizedDescription;
}

//
NSData *DownloadUtil::HttpRequest(NSString *url, NSHTTPURLResponse **response, NSURLRequestCachePolicy cachePolicy)
{
	NSURL *URL = [NSURL URLWithString:url];
	NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:cachePolicy timeoutInterval:30];
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:response error:nil];
	return data;
}