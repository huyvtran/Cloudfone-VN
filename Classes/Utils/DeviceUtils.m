//
//  DeviceUtils.m
//  linphone
//
//  Created by lam quang quan on 10/22/18.
//

#import "DeviceUtils.h"
#import <sys/utsname.h>

@implementation DeviceUtils

//  https://www.theiphonewiki.com/wiki/Models
+ (NSString *)getModelsOfCurrentDevice {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *modelType =  [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return modelType;
}

@end
