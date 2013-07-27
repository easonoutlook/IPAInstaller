
#import <Foundation/Foundation.h>

// Network connection enum
enum NetworkConnectionType {NetworkConnectionNONE, NetworkConnectionWWAN, NetworkConnectionWIFI};

//
class NetworkUtil
{
#pragma mark Network methods
public:
	// Check network connection status
	static NetworkConnectionType NetworkConnectionStatus(NSString *host = @"www.apple.com");
	
	// Check if the network is available.
	static BOOL IsNetworkAvailable();
};
