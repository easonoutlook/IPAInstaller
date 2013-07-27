
#import "IPADeploy.h"
#import "unzip.h"
#import <dlfcn.h>


//
static BOOL UNZExtractFile(unzFile unzFile, NSString *path)
{
	if (unzOpenCurrentFile(unzFile) != UNZ_OK)
	{
		return NO;
	}
	
	FILE *fp = fopen(path.UTF8String, "wb");
	if (fp != nil)
	{
		int read ;
		unsigned char buffer[4096];
		while ((read = unzReadCurrentFile(unzFile, buffer, 4096)) > 0)
		{
			fwrite(buffer, read, 1, fp );
		}
		
		fclose(fp);
	}
	
	unzCloseCurrentFile(unzFile);
	return (fp != nil);
}

//
BOOL IPAExtractFile(NSString *path, NSString *suffix, NSString *to)
{
	unzFile unzFile = unzOpen(path.UTF8String);
	if (unzFile == nil)
	{
		return NO;
	}
	
	BOOL success = NO;
	for (int ret = unzGoToFirstFile(unzFile); ret == UNZ_OK; ret = unzGoToNextFile(unzFile))
	{
		char fileName[256];
		unz_file_info fileInfo = {0};
		success = unzGetCurrentFileInfo(unzFile, &fileInfo, fileName, 256, NULL, 0, NULL, 0) == UNZ_OK;
		if (!success) break;

		fileName[fileInfo.size_filename] = 0;
		NSString *name = [NSString stringWithUTF8String:fileName];
		if (suffix == nil)
		{
			NSString *path = [to stringByAppendingPathComponent:name];
			[[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
			success = UNZExtractFile(unzFile, path);
			if (!success) break;
		}
		else if ([name hasSuffix:suffix])
		{
			success = UNZExtractFile(unzFile, to);
			break;
		}
	}
	
	unzClose(unzFile);
	
	return success;
}

//
NSDictionary *IPAExtractInfo(NSString *path)
{
	NSString* temp = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"IPADeploy.Info.plist"];
	BOOL success = IPAExtractFile(path, @".app/Info.plist", temp);
	if (success)
	{
		NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:temp];
		[[NSFileManager defaultManager] removeItemAtPath:temp error:nil];
		return info;
	}
	return nil;
}

//
typedef int (*PMobileInstallationInstall)(NSString *path, NSDictionary *dict, void *na, NSString *path2_equal_path_maybe_no_use);
IPAResult IPAInstall(NSString *path)
{
	void *lib = dlopen("/System/Library/PrivateFrameworks/MobileInstallation.framework/MobileInstallation", RTLD_LAZY);
	if (lib)
	{
		PMobileInstallationInstall pMobileInstallationInstall = (PMobileInstallationInstall)dlsym(lib, "MobileInstallationInstall");
		if (pMobileInstallationInstall)
		{
			NSString *name = [@"Install_" stringByAppendingString:path.lastPathComponent];
			NSString* temp = [NSTemporaryDirectory() stringByAppendingPathComponent:name];
			if (![[NSFileManager defaultManager] copyItemAtPath:path toPath:temp error:nil]) return IPAResultFileNotFound;
			
			int ret = (IPAResult)pMobileInstallationInstall(temp, [NSDictionary dictionaryWithObject:@"User" forKey:@"ApplicationType"], 0, path);
			[[NSFileManager defaultManager] removeItemAtPath:temp error:nil];
			return ret;
		}
	}
	return IPAResultNoFunction;
}

//
typedef NSDictionary *(*PMobileInstallationLookup)(NSDictionary *params, id callback_unknown_usage);
NSDictionary *IPAInstalledApps()
{
	void *lib = dlopen("/System/Library/PrivateFrameworks/MobileInstallation.framework/MobileInstallation", RTLD_LAZY);
	if (lib)
	{
		PMobileInstallationLookup pMobileInstallationLookup = (PMobileInstallationLookup)dlsym(lib, "MobileInstallationLookup");
		if (pMobileInstallationLookup)
		{
			NSArray *wanted = nil;//[NSArray arrayWithObjects:@"com.celeware.IPADeploy",@"com.celeware.celedial",nil]; Lookup specified only
			NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"User", @"ApplicationType", wanted, @"BundleIDs",nil];
			NSDictionary *dict = pMobileInstallationLookup(params, NULL);
#ifdef DEBUG
			NSLog(@"%@", dict);
#endif
			return dict;
		}
	}
	return nil;
	
	/*NSString *bundlePath = [NSBundle mainBundle].bundlePath;
	NSString *bundleContainer = [bundlePath stringByDeletingLastPathComponent];
	NSString *appsPath = [bundleContainer stringByDeletingLastPathComponent];

	// Try read from installation cache
	if (tryFromCache)
	{
		NSString *userPath = [appsPath stringByDeletingLastPathComponent];
		NSString *cachePath = [userPath stringByAppendingPathComponent:@"Library/Caches/com.apple.mobile.installation.plist"];

		NSDictionary *cache = [NSDictionary dictionaryWithContentsOfFile:cachePath];
		NSDictionary *dict = [cache objectForKey:@"User"];
		if ([dict isKindOfClass:[NSDictionary class]])
		{
			return dict;
		}
	}
	
	// Lookup from applications folder
	//NSString *appsPath = @"/User/Applications";
	NSFileManager *fm = [NSFileManager defaultManager];
	NSArray *apps = [fm contentsOfDirectoryAtPath:appsPath error:nil];
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:apps.count];
	for (NSString *app in apps)
	{
		NSString *container = [appsPath stringByAppendingPathComponent:app];
		NSArray *dirs = [fm contentsOfDirectoryAtPath:container error:nil];
		for (NSString *dir in dirs)
		{
			if ([dir hasSuffix:@".app"])
			{
				NSString *path = [container stringByAppendingPathComponent:dir];
				NSMutableDictionary *plist = [[NSMutableDictionary alloc] initWithContentsOfFile:[path stringByAppendingPathComponent:@"Info.plist"]];
				NSString *key = [plist objectForKey:@"CFBundleIdentifier"];
				if (key)
				{
					[plist setObject:path forKey:@"Path"];
					[plist setObject:container forKey:@"Container"];
					[plist setObject:@"User" forKey:@"ApplicationType"];
					//[plist setObject:@"APPSYNC Bypass" forKey:@"SignerIdentity"];
					//NSDictionary *vars = [[NSDictionary alloc] initWithObjectsAndKeys:container, @"CFFIXED_USER_HOME", container, @"HOME", [container stringByAppendingPathComponent:@"tmp"], @"TMPDIR", nil];
					//[plist setObject:vars forKey:@"EnvironmentVariables"];
					//[vars release];

					[dict setObject:plist forKey:key];
				}
				[plist release];
				break;
			}
		}
	}
	
	return dict;*/
}

// TODO:Archive a IPA
//NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:YES,@"SkipUninstall",@"ApplicationOnly",@"ArchiveType",nil];
//MobileInstallationArchive(@"com.celeware.IPADeploy",dict,NULL,NULL);

