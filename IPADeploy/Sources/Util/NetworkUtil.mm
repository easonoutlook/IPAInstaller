
#import "NetworkUtil.h"
#import <SystemConfiguration/SCNetworkReachability.h>


// Check network connection status
NetworkConnectionType NetworkUtil::NetworkConnectionStatus(NSString *host)
{
	NetworkConnectionType status = NetworkConnectionNONE;

	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [host UTF8String]);
	if (reachability)
	{
		SCNetworkReachabilityFlags flags;
		if (SCNetworkReachabilityGetFlags(reachability, &flags))
		{
			if (flags & kSCNetworkReachabilityFlagsReachable)
			{
				if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
				{
					// if target host is reachable and no connection is required then we'll assume (for now) that your on Wi-Fi
					status = NetworkConnectionWIFI;
				}

				if ((flags & kSCNetworkReachabilityFlagsConnectionOnDemand) ||
					(flags & kSCNetworkReachabilityFlagsConnectionOnTraffic))
				{
					// ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs
					if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
					{
						// ... and no [user] intervention is needed
						status = NetworkConnectionWIFI;
					}
				}
				
				if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
				{
					// ... but WWAN connections are OK if the calling application is using the CFNetwork (CFSocketStream?) APIs.
					status = NetworkConnectionWWAN;
				}
			}
		}
		CFRelease(reachability);
	}

	return status;
}

// Check if the network is available.
BOOL NetworkUtil::IsNetworkAvailable()
{
	// Set address to 0.0.0.0 to check the local network..
	struct sockaddr zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sa_len = sizeof(zeroAddress);
	zeroAddress.sa_family = AF_INET;
	
	// Recover reachability flags
	SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
	SCNetworkReachabilityFlags flags;

	BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
	CFRelease(defaultRouteReachability);

	if (!didRetrieveFlags)
	{
		return NO;
	}

	BOOL isReachable = flags & kSCNetworkFlagsReachable;
	BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
	
	return (isReachable && !needsConnection);
}
