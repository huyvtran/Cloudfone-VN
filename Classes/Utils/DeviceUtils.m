//
//  DeviceUtils.m
//  linphone
//
//  Created by lam quang quan on 10/22/18.
//

#import "DeviceUtils.h"
#import <sys/utsname.h>
#import <AVFoundation/AVFoundation.h>

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
    if (IS_IPHONE || IS_IPOD) {
        if ([deviceMode isEqualToString: Iphone5_1] || [deviceMode isEqualToString: Iphone5_2] || [deviceMode isEqualToString: Iphone5c_1] || [deviceMode isEqualToString: Iphone5c_2] || [deviceMode isEqualToString: Iphone5s_1] || [deviceMode isEqualToString: Iphone5s_2] || [deviceMode isEqualToString: IphoneSE])
        {
            return 62.0;
        }else if ([deviceMode isEqualToString: Iphone6] || [deviceMode isEqualToString: Iphone6s] || [deviceMode isEqualToString: Iphone7_1] || [deviceMode isEqualToString: Iphone7_2] || [deviceMode isEqualToString: Iphone8_1] || [deviceMode isEqualToString: Iphone8_2])
        {
            //  Screen width: 375.000000 - Screen height: 667.000000
            return 73.0;
        }else if ([deviceMode isEqualToString: Iphone6_Plus] || [deviceMode isEqualToString: Iphone6s_Plus] || [deviceMode isEqualToString: Iphone7_Plus1] || [deviceMode isEqualToString: Iphone7_Plus2] || [deviceMode isEqualToString: Iphone8_Plus1] || [deviceMode isEqualToString: Iphone8_Plus2])
        {
            //  Screen width: 414.000000 - Screen height: 736.000000
            return 75.0;
        }else if ([deviceMode isEqualToString: IphoneX_1] || [deviceMode isEqualToString: IphoneX_2] || [deviceMode isEqualToString: IphoneXR] || [deviceMode isEqualToString: IphoneXS]){
            //  Screen width: 375.000000 - Screen height: 812.000000
            return 80.0;
        }else if ([deviceMode isEqualToString: IphoneXS_Max1] || [deviceMode isEqualToString: IphoneXS_Max2]){
            //  Screen width: 375.000000 - Screen height: 812.000000
            return 85.0;
        }else{
            return 62.0;
        }
    }else{
        return 62.0;
    }
}

+ (float)getSpaceXBetweenKeypadButtonsForDevice: (NSString *)deviceMode
{
    if ([deviceMode isEqualToString: Iphone5_1] || [deviceMode isEqualToString: Iphone5_2] || [deviceMode isEqualToString: Iphone5c_1] || [deviceMode isEqualToString: Iphone5c_2] || [deviceMode isEqualToString: Iphone5s_1] || [deviceMode isEqualToString: Iphone5s_2] || [deviceMode isEqualToString: IphoneSE])
    {
        return 20.0;
    }else if ([deviceMode isEqualToString: IphoneX_1] || [deviceMode isEqualToString: IphoneX_2] || [deviceMode isEqualToString: IphoneXR] || [deviceMode isEqualToString: IphoneXS] || [deviceMode isEqualToString: IphoneXS_Max1] || [deviceMode isEqualToString: IphoneXS_Max2])
    {
        return 30.0;
    }else{
        return 27.0;
    }
}
+ (float)getSpaceYBetweenKeypadButtonsForDevice: (NSString *)deviceMode {
    if ([deviceMode isEqualToString: Iphone5_1] || [deviceMode isEqualToString: Iphone5_2] || [deviceMode isEqualToString: Iphone5c_1] || [deviceMode isEqualToString: Iphone5c_2] || [deviceMode isEqualToString: Iphone5s_1] || [deviceMode isEqualToString: Iphone5s_2] || [deviceMode isEqualToString: IphoneSE])
    {
        return 10.0;
    }else if ([deviceMode isEqualToString: IphoneX_1] || [deviceMode isEqualToString: IphoneX_2] || [deviceMode isEqualToString: IphoneXR] || [deviceMode isEqualToString: IphoneXS])
    {
        return 17.0;
    }else if ([deviceMode isEqualToString: IphoneXS_Max1] || [deviceMode isEqualToString: IphoneXS_Max2])
    {
        return 20.0;
    }else{
        return 15.0;
    }
}

+ (BOOL)checkNetworkAvailable {
    NetworkStatus internetStatus = [[LinphoneAppDelegate sharedInstance].internetReachable currentReachabilityStatus];
    if (internetStatus == ReachableViaWiFi || internetStatus == ReachableViaWWAN) {
        return YES;
    }
    return NO;
}

+ (float)getHeightForAddressTextFieldDialerWithDevice: (NSString *)deviceMode {
    if ([deviceMode isEqualToString: IphoneX_1] || [deviceMode isEqualToString: IphoneX_2] || [deviceMode isEqualToString: IphoneXR] || [deviceMode isEqualToString: IphoneXS] || [deviceMode isEqualToString: IphoneXS_Max1] || [deviceMode isEqualToString: IphoneXS_Max2])
    {
        return 80.0;
    }
    return 60.0;
}

+ (void)cleanLogFolder {
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSArray *arr = [WriteLogsUtils getAllFilesInDirectory: logsFolderName];
    for (int i=0; i<arr.count; i++) {
        NSString *fileName = [arr objectAtIndex: i];
        if ([fileName hasPrefix: bundleIdentifier]) {
            NSString *path = [NgnFileUtils getPathOfFileWithSubDir:[NSString stringWithFormat:@"%@/%@", logsFolderName, fileName]];
            [WriteLogsUtils removeFileWithPath: path];
        }
    }
}

+ (NSString *)convertLogFileName: (NSString *)fileName {
    if ([fileName hasPrefix:@"."]) {
        fileName = [fileName substringFromIndex: 1];
    }
    
    if ([fileName hasSuffix:@".txt"]) {
        fileName = [fileName substringToIndex:(fileName.length - 4)];
    }
    
    fileName = [fileName stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    
    return [NSString stringWithFormat:@"Log_file_%@", fileName];
}

//  check current route used bluetooth
+ (TypeOutputRoute)getCurrentRouteForCall {
    AVAudioSessionRouteDescription *currentRoute = [[AVAudioSession sharedInstance] currentRoute];
    NSArray *outputs = currentRoute.outputs;
    for (AVAudioSessionPortDescription *route in outputs) {
        NSLog(@"%@", route.portType);
        
        if (route.portType == AVAudioSessionPortBuiltInReceiver) {
            return eReceiver;
            
        }else if (route.portType == AVAudioSessionPortBuiltInSpeaker || [[route.portType lowercaseString] containsString:@"speaker"]) {
            return eSpeaker;
            
        }else if (route.portType == AVAudioSessionPortBluetoothHFP || route.portType == AVAudioSessionPortBluetoothLE || route.portType == AVAudioSessionPortBluetoothA2DP || [[route.portType lowercaseString] containsString:@"bluetooth"]) {
            return eEarphone;
        }
    }
    return eReceiver;
}


+ (BOOL)isConnectedEarPhone {
    NSArray *bluetoothPorts = @[ AVAudioSessionPortBluetoothA2DP, AVAudioSessionPortBluetoothLE, AVAudioSessionPortBluetoothHFP ];
    
    NSArray *routes = [[AVAudioSession sharedInstance] availableInputs];
    for (AVAudioSessionPortDescription *route in routes) {
        if ([bluetoothPorts containsObject:route.portType]) {
            return YES;
        }
    }
    return NO;
}

+ (NSString *)getNameOfEarPhoneConnected {
    NSArray *bluetoothPorts = @[ AVAudioSessionPortBluetoothA2DP, AVAudioSessionPortBluetoothLE, AVAudioSessionPortBluetoothHFP ];
    
    NSArray *routes = [[AVAudioSession sharedInstance] availableInputs];
    for (AVAudioSessionPortDescription *route in routes) {
        if ([bluetoothPorts containsObject:route.portType]) {
            return route.portName;
        }
    }
    return @"";
}

+ (void)setBluetoothEarphoneForCurrentCall {
    [LinphoneManager.instance setSpeakerEnabled:TRUE];
    [self performSelector:@selector(enableBluetooth)
               withObject:nil afterDelay:0.25];
}

+ (void)setiPhoneRouteForCall {
    [LinphoneManager.instance setSpeakerEnabled:FALSE];
    [self performSelector:@selector(disableBluetooth)
               withObject:nil afterDelay:0.5];
}
+ (void)setSpeakerForCurrentCall {
    [LinphoneManager.instance setSpeakerEnabled:TRUE];
    [self performSelector:@selector(disableBluetooth)
               withObject:nil afterDelay:0.5];
}

+ (void)enableBluetooth{
    [LinphoneManager.instance setBluetoothEnabled:TRUE];
}

+ (void)disableBluetooth{
    [LinphoneManager.instance setBluetoothEnabled:FALSE];
}

@end
