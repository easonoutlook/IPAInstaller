


#import "OAMutableURLRequest.h"


@interface SinaOAMutableURLRequest : OAMutableURLRequest {

	//NSMutableDictionary *extraOAuthParameters;
	
	BOOL _needAddVerifier;
}

- (void)prepare;
- (void)setOAuthParameterName:(NSString*)parameterName withValue:(NSString*)parameterValue;

- (id)initWithURL:(NSURL *)aUrl
		 consumer:(OAConsumer *)aConsumer
			token:(OAToken *)aToken
            realm:(NSString *)aRealm
signatureProvider:(id<OASignatureProviding, NSObject>)aProvider
            nonce:(NSString *)aNonce
        timestamp:(NSString *)aTimestamp 
		 verifier:(BOOL)addVerifier;

@end
