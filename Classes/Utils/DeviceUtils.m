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

//  [Khai le - 28/10/2018]
+ (float)getSizeOfKeypadButtonForDevice: (NSString *)deviceMode {
    if ([deviceMode isEqualToString: Iphone6] || [deviceMode isEqualToString: Iphone6s] || [deviceMode isEqualToString: Iphone7_1] || [deviceMode isEqualToString: Iphone7_2] || [deviceMode isEqualToString: Iphone8_1] || [deviceMode isEqualToString: Iphone8_2])
    {
        //  Screen width: 375.000000 - Screen height: 667.000000
        return 73.0;
    }else if ([deviceMode isEqualToString: Iphone6_Plus] || [deviceMode isEqualToString: Iphone6s_Plus] || [deviceMode isEqualToString: Iphone7_Plus1] || [deviceMode isEqualToString: Iphone7_Plus2] || [deviceMode isEqualToString: Iphone8_Plus1] || [deviceMode isEqualToString: Iphone8_Plus2] || [deviceMode isEqualToString: simulator])
    {
        //  Screen width: 414.000000 - Screen height: 736.000000
        return 75.0;
    }else if ([deviceMode isEqualToString: IphoneSE]){
        //  Screen width: 320.000000 - Screen height: 568.000000
        return 62.0;
    }else if ([deviceMode isEqualToString: IphoneX_1] || [deviceMode isEqualToString: IphoneX_2] || [deviceMode isEqualToString: IphoneXR] || [deviceMode isEqualToString: IphoneXS] || [deviceMode isEqualToString: IphoneXS_Max1] || [deviceMode isEqualToString: IphoneXS_Max2]){
        //  Screen width: 375.000000 - Screen height: 812.000000
        return 78.0;
    }else{
        return 62.0;
    }
}

+ (float)getSpaceXBetweenKeypadButtonsForDevice: (NSString *)deviceMode
{
    if ([deviceMode isEqualToString: IphoneSE]) {
        return 30.0;
    }else{
        return 27.0;
    }
}
+ (float)getSpaceYBetweenKeypadButtonsForDevice: (NSString *)deviceMode {
    if ([deviceMode isEqualToString: IphoneSE]) {
        return 15.0;
    }else{
        return 15.0;
    }
}

@end
