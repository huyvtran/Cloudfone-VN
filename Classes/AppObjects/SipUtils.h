//
//  SipUtils.h
//  linphone
//
//  Created by admin on 6/13/18.
//

#import <Foundation/Foundation.h>

@interface SipUtils : NSObject

+ (BOOL)loginSipWithDomain: (NSString *)domain username: (NSString *)username password: (NSString *)password port: (NSString *)port;
+ (void)registerProxyWithUsername: (NSString *)username password: (NSString *)accountPassword domain: (NSString *)domain port: (NSString *)port;
+ (void)registerPBXAccount: (NSString *)pbxAccount password: (NSString *)password ipAddress: (NSString *)address port: (NSString *)portID;
@end
