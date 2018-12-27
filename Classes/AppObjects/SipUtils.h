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

+ (BOOL)makeCallWithPhoneNumber: (NSString *)phoneNumber;

+ (AccountState)getStateOfDefaultProxyConfig;
+ (NSString *)getAccountIdOfDefaultProxyConfig;
+ (void)enableProxyConfig: (LinphoneProxyConfig *)proxy withValue: (BOOL)enable withRefresh: (BOOL)refresh;
+ (LinphoneRegistrationState)getRegistrationStateOfDefaultProxyConfig;
+ (NSString *)getPhoneNumberOfCall: (LinphoneCall *)call orLinphoneAddress: (LinphoneAddress *)address;
//  [Khai Le - 27/12/2018]
+ (NSString *)makeValidPhoneNumber: (NSString *)phoneNumber;

@end
