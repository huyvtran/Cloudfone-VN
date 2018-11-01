//
//  DeviceUtils.h
//  linphone
//
//  Created by lam quang quan on 10/22/18.
//

#import <Foundation/Foundation.h>

@interface DeviceUtils : NSObject

+ (NSString *)getModelsOfCurrentDevice;
//  [Khai le - 28/10/2018]
+ (float)getSizeOfKeypadButtonForDevice: (NSString *)deviceMode;
+ (float)getSpaceXBetweenKeypadButtonsForDevice: (NSString *)deviceMode;
+ (float)getSpaceYBetweenKeypadButtonsForDevice: (NSString *)deviceMode;
+ (BOOL)checkNetworkAvailable;

@end
