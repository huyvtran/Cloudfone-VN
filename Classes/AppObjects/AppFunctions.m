//
//  AppFunctions.m
//  linphone
//
//  Created by Hung Ho on 7/4/17.
//
//

#import "AppFunctions.h"
#import "LinphoneAppDelegate.h"
#import "AppStrings.h"
#import "NSDBCallnex.h"
#import "OTRProtocolManager.h"
#import "NSData+Base64.h"

@implementation AppFunctions

+ (CGSize)getSizeWithText: (NSString *)text withFont: (UIFont *)font {
    CGSize tmpSize = [text sizeWithAttributes: @{NSFontAttributeName: font}];
    return CGSizeMake(ceilf(tmpSize.width), ceilf(tmpSize.height));
}


+ (CGSize)getSizeWithText: (NSString *)text withFont: (UIFont *)font andMaxWidth: (float )maxWidth {
    NSDictionary *attributes = @{NSFontAttributeName: font};
    CGRect rect = [text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:attributes
                                     context:nil];
    return rect.size;
}

/* Hàm random ra chuỗi ký tự bất kỳ với length tuỳ ý */
+ (NSString *)randomStringWithLength: (int)len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int iCount=0; iCount<len; iCount++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((int)[letters length]) % [letters length]]];
    }
    return randomString;
}

+ (NSString *)getCurrentDateTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    // or @"yyyy-MM-dd hh:mm:ss a" if you prefer the time with AM/PM
    return [dateFormatter stringFromDate:[NSDate date]];
}

// Kiểm tra folder cho view chat
+ (void)checkFolderToSaveFileInViewChat
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //NSString *documentsDirectory = [paths lastObject];
    NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", @"files"]];
    BOOL isDir;
    BOOL exists = [fileManager fileExistsAtPath:databasePath isDirectory:&isDir];
    if (!exists) {
        [[NSFileManager defaultManager] createDirectoryAtPath:databasePath withIntermediateDirectories:NO attributes:nil error:&error];
        NSLog(@"Folder da duoc tao thanh cong");
    }
    
    databasePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", @"records"]];
    exists = [fileManager fileExistsAtPath:databasePath isDirectory:&isDir];
    if (!exists) {
        [[NSFileManager defaultManager] createDirectoryAtPath:databasePath withIntermediateDirectories:NO attributes:nil error:&error];
        NSLog(@"Folder da duoc tao thanh cong");
    }
    
    databasePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", @"videos"]];
    exists = [fileManager fileExistsAtPath:databasePath isDirectory:&isDir];
    if (!exists) {
        [[NSFileManager defaultManager] createDirectoryAtPath:databasePath withIntermediateDirectories:NO attributes:nil error:&error];
        NSLog(@"Folder da duoc tao thanh cong");
    }
    
    databasePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", @"avatars"]];
    exists = [fileManager fileExistsAtPath:databasePath isDirectory:&isDir];
    if (!exists) {
        [[NSFileManager defaultManager] createDirectoryAtPath:databasePath withIntermediateDirectories:NO attributes:nil error:&error];
        NSLog(@"Folder da duoc tao thanh cong");
    }
}

// Hàm chuyển chuỗi ký tự có dấu thành không dấu
+ (NSString *)convertUTF8CharacterToCharacter: (NSString *)parentStr{
    NSData *dataConvert = [parentStr dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *convertName = [[NSString alloc] initWithData:dataConvert encoding:NSASCIIStringEncoding];
    return convertName;
}

// Chuyển từ convert name sang tên seach dạng số
+ (NSString *)getNameForSearchOfConvertName: (NSString *)convertName{
    convertName = [convertName lowercaseString];
    NSString *result = @"";
    for (int strCount=0; strCount<convertName.length; strCount++) {
        char characterChar = [convertName characterAtIndex: strCount];
        NSString *c = [NSString stringWithFormat:@"%c", characterChar];
        if ([c isEqualToString:@"a"] || [c isEqualToString:@"b"] || [c isEqualToString:@"c"]) {
            result = [NSString stringWithFormat:@"%@%@", result, @"2"];
        }else if([c isEqualToString:@"d"] || [c isEqualToString:@"e"] || [c isEqualToString:@"f"]){
            result = [NSString stringWithFormat:@"%@%@", result, @"3"];
        }else if ([c isEqualToString:@"g"] || [c isEqualToString:@"h"] || [c isEqualToString:@"i"]){
            result = [NSString stringWithFormat:@"%@%@", result, @"4"];
        }else if ([c isEqualToString:@"j"] || [c isEqualToString:@"k"] || [c isEqualToString:@"l"]){
            result = [NSString stringWithFormat:@"%@%@", result, @"5"];
        }else if ([c isEqualToString:@"m"] || [c isEqualToString:@"n"] || [c isEqualToString:@"o"]){
            result = [NSString stringWithFormat:@"%@%@", result, @"6"];
        }else if ([c isEqualToString:@"p"] || [c isEqualToString:@"q"] || [c isEqualToString:@"r"] || [c isEqualToString:@"s"]){
            result = [NSString stringWithFormat:@"%@%@", result, @"7"];
        }else if ([c isEqualToString:@"t"] || [c isEqualToString:@"u"] || [c isEqualToString:@"v"]){
            result = [NSString stringWithFormat:@"%@%@", result, @"8"];
        }else if ([c isEqualToString:@"w"] || [c isEqualToString:@"x"] || [c isEqualToString:@"y"] || [c isEqualToString:@"z"]){
            result = [NSString stringWithFormat:@"%@%@", result, @"9"];
        }else if ([c isEqualToString:@"1"]){
            result = [NSString stringWithFormat:@"%@%@", result, @"1"];
        }else if ([c isEqualToString:@"0"]){
            result = [NSString stringWithFormat:@"%@%@", result, @"0"];
        }else if ([c isEqualToString:@" "]){
            result = [NSString stringWithFormat:@"%@%@", result, @" "];
        }else{
            result = [NSString stringWithFormat:@"%@%@", result, c];
        }
    }
    return result;
}

// Chuyển kí tự có dấu thành kí tự ko dấu
+ (NSString *)convertUTF8StringToString: (NSString *)string {
    if ([string isEqualToString:@"À"] || [string isEqualToString:@"Ã"] || [string isEqualToString:@"Ạ"]  || [string isEqualToString:@"Á"] || [string isEqualToString:@"Ả"]  || [string isEqualToString:@"Ằ"] || [string isEqualToString:@"Ẵ"] || [string isEqualToString:@"Ặ"] || [string isEqualToString:@"Ắ"] || [string isEqualToString:@"Ẳ"] || [string isEqualToString:@"Ă"] || [string isEqualToString:@"Ầ"] || [string isEqualToString:@"Ẫ"] || [string isEqualToString:@"Ậ"] || [string isEqualToString:@"Ấ"] || [string isEqualToString:@"Ẩ"] || [string isEqualToString:@"Â"]) {
        string = @"A";
    }else if ([string isEqualToString:@"Đ"]) {
        string = @"D";
    }else if ([string isEqualToString:@"È"] || [string isEqualToString:@"Ẽ"] || [string isEqualToString:@"Ẹ"] || [string isEqualToString:@"É"] || [string isEqualToString:@"Ẻ"]  || [string isEqualToString:@"Ề"] || [string isEqualToString:@"Ễ"] || [string isEqualToString:@"Ệ"] || [string isEqualToString:@"Ế"] || [string isEqualToString:@"Ể"] || [string isEqualToString:@"Ê"]) {
        string = @"E";
    }else if([string isEqualToString:@"Ì"] || [string isEqualToString:@"Ĩ"] || [string isEqualToString:@"Ị"] || [string isEqualToString:@"Í"] || [string isEqualToString:@"Ỉ"]) {
        string = @"I";
    }else if([string isEqualToString:@"Ò"] || [string isEqualToString:@"Õ"] || [string isEqualToString:@"Ọ"] || [string isEqualToString:@"Ó"] || [string isEqualToString:@"Ỏ"] || [string isEqualToString:@"Ờ"] || [string isEqualToString:@"Ở"] || [string isEqualToString:@"Ợ"] || [string isEqualToString:@"Ớ"] || [string isEqualToString:@"Ở"] || [string isEqualToString:@"Ơ"] || [string isEqualToString:@"Ồ"] || [string isEqualToString:@"Ỗ"] || [string isEqualToString:@"Ộ"] || [string isEqualToString:@"Ố"] || [string isEqualToString:@"Ổ"] || [string isEqualToString:@"Ô"]) {
        string = @"O";
    }else if ([string isEqualToString:@"Ù"] || [string isEqualToString:@"Ũ"] || [string isEqualToString:@"Ụ"] || [string isEqualToString:@"Ú"] || [string isEqualToString:@"Ủ"]) {
        string = @"U";
    }else if([string isEqualToString:@"Ỳ"] || [string isEqualToString:@"Ỹ"] || [string isEqualToString:@"Ỵ"] || [string isEqualToString:@"Ý"] || [string isEqualToString:@"Ỷ"]) {
        string = @"Y";
    }
    return string;
}

//  Lấy status của user
+ (NSArray *)getStatusOfUser: (NSString *)cloudFoneID {
    return [NSArray arrayWithObjects:@"", [NSNumber numberWithInt: 2], nil];
    
    /*  Leo Kelvin
    LinphoneAppDelegate *appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (cloudFoneID == nil || [cloudFoneID isEqualToString:text_empty]) {
        return [NSArray arrayWithObjects: cloudFoneID, [NSNumber numberWithInt:-1], nil];
    }else{
        int status = -1;
        NSString *statusStr = cloudFoneID;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName contains[cd] %@", cloudFoneID];
        
        NSMutableDictionary *listUserDict = [[[OTRProtocolManager sharedInstance] buddyList] allBuddies];
        NSArray *listUser = [OTRBuddyList sortBuddies: listUserDict];
        NSArray *resultArr = [listUser filteredArrayUsingPredicate: predicate];
        if (resultArr.count > 0) {
            OTRBuddy *curBuddy = [resultArr objectAtIndex: 0];
            if (curBuddy.status == kOTRBuddyStatusOffline) {
                statusStr = cloudFoneID;
            }else{
                statusStr = [appDelegate._statusXMPPDict objectForKey: cloudFoneID];
                if (statusStr == nil || [statusStr isEqualToString:@""]) {
                    statusStr = welcomeToCloudFone;
                }
            }
            status = curBuddy.status;
        }
        return [NSArray arrayWithObjects:statusStr,[NSNumber numberWithInt:status], nil];
    }   */
}

+ (NSString *)checkTodayForHistoryCall: (NSString *)dateStr{
    NSDate *today = [NSDate dateWithTimeIntervalSinceNow: 0];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Bangkok"]];
    NSString *currentTime = [formatter stringFromDate: today];
    if ([currentTime isEqualToString: dateStr]) {
        return @"Today";
    }else{
        return currentTime;
    }
}

/* Trả về title cho header section trong phần history call */
+ (NSString *)checkYesterdayForHistoryCall: (NSString *)dateStr{
    NSDate *yesterday = [NSDate dateWithTimeIntervalSinceNow: -(60.0f*60.0f*24.0f)];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Bangkok"]];
    NSString *currentTime = [formatter stringFromDate: yesterday];
    if ([currentTime isEqualToString: dateStr]) {
        return @"Yesterday";
    }else{
        return currentTime;
    }
}

+ (NSString *)getCurrentDate{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    NSString *dateString = [dateFormat stringFromDate:date];
    return dateString;
}

+ (NSString *)getCurrentTimeStamp{
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *currentTime = [dateFormatter stringFromDate:now];
    return currentTime;
}

+ (NSString *)getCurrentTimeStampNotSeconds{
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *currentTime = [dateFormatter stringFromDate:now];
    return currentTime;
}

/* Get UDID of device */
+ (NSString*)uniqueIDForDevice
{
    NSString* uniqueIdentifier = nil;
    if( [UIDevice instancesRespondToSelector:@selector(identifierForVendor)] ) {
        // >=iOS 7
        uniqueIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    else {  //<=iOS6, Use UDID of Device
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        uniqueIdentifier = ( NSString*)CFBridgingRelease(CFUUIDCreateString(NULL, uuid));// for ARC
        CFRelease(uuid);
    }
    return uniqueIdentifier;
}

// Lấy cloudfone id từ một chuỗi
+ (NSString *)getCloudFoneIDFromString: (NSString *)string {
    NSRange range = [string rangeOfString:[NSString stringWithFormat:@"@%@", xmpp_cloudfone]];
    if (range.location != NSNotFound) {
        return [string substringToIndex: range.location];
    }else{
        string = [string stringByReplacingOccurrencesOfString:single_cloudfone withString:xmpp_cloudfone];
        range = [string rangeOfString:[NSString stringWithFormat:@"@%@", xmpp_cloudfone]];
        if (range.location != NSNotFound) {
            return [string substringToIndex: range.location];
        }
    }
    return text_empty;
}

/*---
 Cập nhật badge và tạo notifications khi đang chạy background
 => Nếu không bị mute notifications thì tạo localnotifications và cập nhật badge
 => Nếu có thì chỉ cập nhật badge
 ---*/
+ (void)createLocalNotificationWithAlertBody: (NSString *)alertBodyStr andInfoDict: (NSDictionary *)infoDict ofUser: (NSString *)user{
    BOOL isMute = [NSDBCallnex checkUserExistsInMuteNotificationsList: user];
    if (!isMute) {
        UILocalNotification *messageNotif = [[UILocalNotification alloc] init];
        messageNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow: 0.1];
        messageNotif.timeZone = [NSTimeZone defaultTimeZone];
        messageNotif.timeZone = [NSTimeZone defaultTimeZone];
        messageNotif.alertBody = alertBodyStr;
        messageNotif.userInfo = infoDict;
        messageNotif.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] scheduleLocalNotification: messageNotif];
    }
}

+ (void)reconnectToXMPPServer {
    NSString *UDID = [AppFunctions uniqueIDForDevice];
    NSString *accountName = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@@%@", [[NSUserDefaults standardUserDefaults] objectForKey:key_login], xmpp_cloudfone]];
    
    OTRXMPPAccount *_myAccount = [[OTRXMPPAccount alloc] init];
    _myAccount.username = accountName;
    _myAccount.rememberPassword = YES;
    _myAccount.protocol = @"xmpp";
    _myAccount.uniqueIdentifier = UDID;
    _myAccount.password = [[NSUserDefaults standardUserDefaults] objectForKey:key_password];
    _myAccount.allowSelfSignedSSL = YES;
    _myAccount.allowSSLHostNameMismatch = YES;
    _myAccount.sendDeliveryReceipts = YES;
    
    id<OTRProtocol> protocol = [[OTRProtocolManager sharedInstance] protocolForAccount: _myAccount];
    [protocol connectWithPassword: _myAccount.password];
    
    LinphoneAppDelegate *appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    appDelegate.myBuddy = [[OTRBuddy alloc] initWithDisplayName:[[NSUserDefaults standardUserDefaults] objectForKey:key_login] accountName:accountName protocol:protocol status:0 groupName:nil];
}

//  Chuyển chuỗi có emotion thành code emoji
+ (NSMutableAttributedString *)convertMessageStringToEmojiString: (NSString *)messageString {
    LinphoneAppDelegate *appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableAttributedString *resultStr = [[NSMutableAttributedString alloc] initWithString: messageString];
    
    // Set font cho toan bo chieu dai
    UIFont *font = [UIFont systemFontOfSize:15.0];
    [resultStr addAttribute:NSFontAttributeName
                      value:font
                      range:NSMakeRange(0, messageString.length)];
    
    NSRange rangeOfFirstMatch;
    // Hiển thị emoticon nếu có
    NSString *firstEmotion;
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"e[0-9]_[0-9]{3}" options:NSRegularExpressionCaseInsensitive error:&error];
    rangeOfFirstMatch = [regex rangeOfFirstMatchInString:messageString options:0 range:NSMakeRange(0, [messageString length])];
    NSArray *filterArr = nil;
    while (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0)))
    {
        firstEmotion = [resultStr.string substringWithRange:rangeOfFirstMatch];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"code LIKE[c] %@", firstEmotion];
        filterArr = [appDelegate._listFace filteredArrayUsingPredicate: predicate];
        if (filterArr.count > 0) {
            NSString *uCode = [(NSDictionary *)[filterArr objectAtIndex: 0] objectForKey:@"u_code"];
            NSString *totalStr = [NSString stringWithFormat:@"{\"emoji\":\"%@\"}", uCode];
            const char *jsonString = [totalStr UTF8String];
            NSData *jsonData = [NSData dataWithBytes:jsonString length:strlen(jsonString)];
            NSError *error;
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
            NSString *str = [jsonDict objectForKey:@"emoji"];
            [resultStr replaceCharactersInRange:rangeOfFirstMatch withString:str];
            [resultStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20.0] range:NSMakeRange(rangeOfFirstMatch.location, str.length)];
        }else{
            filterArr = [appDelegate._listNature filteredArrayUsingPredicate: predicate];
            if (filterArr.count > 0) {
                NSString *uCode = [(NSDictionary *)[filterArr objectAtIndex: 0] objectForKey:@"u_code"];
                NSString *totalStr = [NSString stringWithFormat:@"{\"emoji\":\"%@\"}", uCode];
                const char *jsonString = [totalStr UTF8String];
                NSData *jsonData = [NSData dataWithBytes:jsonString length:strlen(jsonString)];
                NSError *error;
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
                NSString *str = [jsonDict objectForKey:@"emoji"];
                
                [resultStr replaceCharactersInRange:rangeOfFirstMatch withString:str];
                [resultStr addAttribute:NSFontAttributeName
                                  value:[UIFont systemFontOfSize:20.0]
                                  range:NSMakeRange(rangeOfFirstMatch.location, str.length)];
            }else{
                filterArr = [appDelegate._listObject filteredArrayUsingPredicate: predicate];
                if (filterArr.count > 0) {
                    NSString *uCode = [(NSDictionary *)[filterArr objectAtIndex: 0] objectForKey:@"u_code"];
                    NSString *totalStr = [NSString stringWithFormat:@"{\"emoji\":\"%@\"}", uCode];
                    const char *jsonString = [totalStr UTF8String];
                    NSData *jsonData = [NSData dataWithBytes:jsonString length:strlen(jsonString)];
                    NSError *error;
                    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
                    NSString *str = [jsonDict objectForKey:@"emoji"];
                    
                    [resultStr replaceCharactersInRange:rangeOfFirstMatch withString:str];
                    [resultStr addAttribute:NSFontAttributeName
                                      value:[UIFont systemFontOfSize:20.0]
                                      range:NSMakeRange(rangeOfFirstMatch.location, str.length)];
                }else{
                    filterArr = [appDelegate._listPlace filteredArrayUsingPredicate: predicate];
                    if (filterArr.count > 0) {
                        NSString *uCode = [(NSDictionary *)[filterArr objectAtIndex: 0] objectForKey:@"u_code"];
                        NSString *totalStr = [NSString stringWithFormat:@"{\"emoji\":\"%@\"}", uCode];
                        const char *jsonString = [totalStr UTF8String];
                        NSData *jsonData = [NSData dataWithBytes:jsonString length:strlen(jsonString)];
                        NSError *error;
                        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
                        NSString *str = [jsonDict objectForKey:@"emoji"];
                        
                        [resultStr replaceCharactersInRange:rangeOfFirstMatch withString:str];
                        [resultStr addAttribute:NSFontAttributeName
                                          value:[UIFont systemFontOfSize:20.0]
                                          range:NSMakeRange(rangeOfFirstMatch.location, str.length)];
                    }else{
                        filterArr = [appDelegate._listSymbol filteredArrayUsingPredicate: predicate];
                        if (filterArr.count > 0) {
                            NSString *uCode = [(NSDictionary *)[filterArr objectAtIndex: 0] objectForKey:@"u_code"];
                            NSString *totalStr = [NSString stringWithFormat:@"{\"emoji\":\"%@\"}", uCode];
                            const char *jsonString = [totalStr UTF8String];
                            NSData *jsonData = [NSData dataWithBytes:jsonString length:strlen(jsonString)];
                            NSError *error;
                            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
                            NSString *str = [jsonDict objectForKey:@"emoji"];
                            
                            [resultStr replaceCharactersInRange:rangeOfFirstMatch withString:str];
                            [resultStr addAttribute:NSFontAttributeName
                                              value:[UIFont systemFontOfSize:20.0]
                                              range:NSMakeRange(rangeOfFirstMatch.location, str.length)];
                        }else{
                            [resultStr replaceCharactersInRange:rangeOfFirstMatch withString:@""];
                        }
                    }
                }
            }
        }
        regex = [NSRegularExpression regularExpressionWithPattern:@"e[0-9]_[0-9]{3}" options:NSRegularExpressionCaseInsensitive error:&error];
        rangeOfFirstMatch = [regex rangeOfFirstMatchInString:resultStr.string options:0 range:NSMakeRange(0, [resultStr length])];
    }
    return resultStr;
}

+ (void)updateBadgeForMessageOfUser: (NSString *)user isIncrease: (BOOL)increase{
    /*--Neu tang badge thi kiem tra user nay co message unread chua, co roi thi thoi--*/
    BOOL badge = [NSDBCallnex checkBadgeMessageOfUserWhenRunBackground: user];
    if (increase) {
        if (!badge) {
            int currentBadge = (int)[[UIApplication sharedApplication] applicationIconBadgeNumber];
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber: currentBadge + 1];
        }
    }else{
        if (badge) {
            int currentBadge = (int)[[UIApplication sharedApplication] applicationIconBadgeNumber];
            if (currentBadge > 0) {
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber: currentBadge - 1];
            }
        }
    }
}
/*  Close by Khai Le on 05/11/2017
// Lấy buddy trong roster list
+ (OTRBuddy *)getBuddyOfUserOnList: (NSString *)cloudFoneID{
    LinphoneAppDelegate *appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName CONTAINS[cd] %@", cloudFoneID];
    NSMutableDictionary *listUserDict = [[[OTRProtocolManager sharedInstance] buddyList] allBuddies];
    NSArray *listUser = [OTRBuddyList sortBuddies: listUserDict];
    NSArray *resultArr = [listUser filteredArrayUsingPredicate: predicate];
    if (resultArr.count > 0) {
        return [resultArr objectAtIndex: 0];
    }else{
        return [[OTRBuddy alloc] initWithDisplayName:cloudFoneID accountName:[NSString stringWithFormat:@"%@@%@", cloudFoneID, xmpp_cloudfone] protocol:appDelegate.myBuddy.protocol status:-1 groupName:text_empty];
    }
}   */

+ (NSString *)checkFileExtension: (NSString *)fileName{
    if (fileName.length > 3) {
        NSString *extensionStr = [fileName substringWithRange:NSMakeRange(fileName.length-3, 3)];
        if ([extensionStr isEqualToString:@"jpg"] || [extensionStr isEqualToString:@"JPG"] || [extensionStr isEqualToString:@"png"] || [extensionStr isEqualToString:@"PNG"] || [extensionStr isEqualToString:@"gif"] || [extensionStr isEqualToString:@"GIF"] || [extensionStr isEqualToString:@"jpeg"] || [extensionStr isEqualToString:@"JPEG"]) {
            return imageMessage;
        }else if([extensionStr isEqualToString:@"m4a"] || [extensionStr isEqualToString:@"M4A"] || [extensionStr isEqualToString:@"wav"] || [extensionStr isEqualToString:@"WAV"] || [extensionStr isEqualToString:@"wma"] || [extensionStr isEqualToString:@"WMA"] || [extensionStr isEqualToString:@"aiff"] ||[extensionStr isEqualToString:@"AIFF"] || [extensionStr isEqualToString:@"3gp"] || [extensionStr isEqualToString:@"3GP"] || [extensionStr isEqualToString:@"mp3"] || [extensionStr isEqualToString:@"MP3"] || [extensionStr isEqualToString:@"m4p"] || [extensionStr isEqualToString:@"MP4"] || [extensionStr isEqualToString:@"cda"] || [extensionStr isEqualToString:@"CDA"] || [extensionStr isEqualToString:@"dat"] || [extensionStr isEqualToString:@"DAT"]){
            return audioMessage;
        }else if ([extensionStr isEqualToString:@"avi"] || [extensionStr isEqualToString:@"AVI"] || [extensionStr isEqualToString:@"riff"] || [extensionStr isEqualToString:@"RIFF"] || [extensionStr isEqualToString:@"mpg"] || [extensionStr isEqualToString:@"MPG"] || [extensionStr isEqualToString:@"vob"] || [extensionStr isEqualToString:@"VOB"] || [extensionStr isEqualToString:@"mp4"] || [extensionStr isEqualToString:@"MP4"] || [extensionStr isEqualToString:@"mov"] || [extensionStr isEqualToString:@"MOV"] || [extensionStr isEqualToString:@"3gp"] || [extensionStr isEqualToString:@"3GP"] || [extensionStr isEqualToString:@"mkv"] || [extensionStr isEqualToString:@"MKV"] || [extensionStr isEqualToString:@"flv"] || [extensionStr isEqualToString:@"FLV"] || [extensionStr isEqualToString:@"3gpp"] || [extensionStr isEqualToString:@"3GPP"]){
            return videoMessage;
        }else{
            return @"";
        }
    }else{
        return @"";
    }
}

+ (UIImage *)squareImageWithImage:(UIImage *)sourceImage withSizeWidth:(CGFloat)sideLength
{
    // input size comes from image
    CGSize inputSize = sourceImage.size;
    
    // round up side length to avoid fractional output size
    sideLength = ceilf(sideLength);
    
    // output size has sideLength for both dimensions
    CGSize outputSize = CGSizeMake(sideLength, sideLength);
    
    // calculate scale so that smaller dimension fits sideLength
    CGFloat scale = MAX(sideLength / inputSize.width,
                        sideLength / inputSize.height);
    
    // scaling the image with this scale results in this output size
    CGSize scaledInputSize = CGSizeMake(inputSize.width * scale,
                                        inputSize.height * scale);
    
    // determine point in center of "canvas"
    CGPoint center = CGPointMake(outputSize.width/2.0,
                                 outputSize.height/2.0);
    
    // calculate drawing rect relative to output Size
    CGRect outputRect = CGRectMake(center.x - scaledInputSize.width/2.0,
                                   center.y - scaledInputSize.height/2.0,
                                   scaledInputSize.width,
                                   scaledInputSize.height);
    
    // begin a new bitmap context, scale 0 takes display scale
    UIGraphicsBeginImageContextWithOptions(outputSize, YES, 0);
    
    // optional: set the interpolation quality.
    // For this you need to grab the underlying CGContext
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
    
    // draw the source image into the calculated rect
    [sourceImage drawInRect:outputRect];
    
    // create new image from bitmap context
    UIImage *outImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // clean up
    UIGraphicsEndImageContext();
    
    // pass back new image
    return outImage;
}

// Xoá file details của message
+ (void)deleteDetailsFileOfMessage: (NSString *)typeMessage andDetails: (NSString *)detail andThumb: (NSString *)thumb{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    if ([typeMessage isEqualToString: imageMessage]) {
        if (![detail isEqualToString:@""]) {
            NSString *pathDetailsFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/files/%@", detail]];
            BOOL fileDetailExists = [[NSFileManager defaultManager] fileExistsAtPath: pathDetailsFile];
            if (fileDetailExists) {
                [[NSFileManager defaultManager] removeItemAtPath:pathDetailsFile error:nil];
            }
        }
        
        if (![thumb isEqualToString:@""]) {
            NSString *pathThumbFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/files/%@", thumb]];
            BOOL fileThumbExists = [[NSFileManager defaultManager] fileExistsAtPath: pathThumbFile];
            if (fileThumbExists) {
                [[NSFileManager defaultManager] removeItemAtPath:pathThumbFile error:nil];
            }
        }
    }else if ([typeMessage isEqualToString: audioMessage]){
        if (![thumb isEqualToString:@""]) {
            NSString *pathThumbFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/records/%@", thumb]];
            BOOL fileThumbExists = [[NSFileManager defaultManager] fileExistsAtPath: pathThumbFile];
            if (fileThumbExists) {
                [[NSFileManager defaultManager] removeItemAtPath:pathThumbFile error:nil];
            }
        }
    }else if ([typeMessage isEqualToString: videoMessage]){
        NSString *pathDetailsFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/videos/%@", detail]];
        BOOL fileDetailExists = [[NSFileManager defaultManager] fileExistsAtPath: pathDetailsFile];
        if (fileDetailExists) {
            [[NSFileManager defaultManager] removeItemAtPath:pathDetailsFile error:nil];
        }
    }else{
        // do some thing
    }
}

//  Get trạng thái của user
+ (int)getStatusNumberOfUserOnList: (NSString *)cloudFoneID {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName CONTAINS[cd] %@", cloudFoneID];
    NSMutableDictionary *listUserDict = [[[OTRProtocolManager sharedInstance] buddyList] allBuddies];
    NSArray *listUser = [OTRBuddyList sortBuddies: listUserDict];
    NSArray *resultArr = [listUser filteredArrayUsingPredicate: predicate];
    if (resultArr.count > 0) {
        OTRBuddy *curBuddy = [resultArr objectAtIndex: 0];
        return curBuddy.status;
    }else{
        return -1;
    }
}

/* Lấy thời gian hiện tại cho message */
+ (NSString *)getCurrentTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy hh-mm"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Bangkok"]];
    NSString *currentTime = [formatter stringFromDate:[NSDate date]];
    NSString *time = [currentTime substringWithRange:NSMakeRange(11, currentTime.length-11)];
    NSString *separator = [time substringWithRange:NSMakeRange(2, 1)];
    if ([separator isEqualToString:@"-"]) {
        time = [time stringByReplacingOccurrencesOfString:@"-" withString:@":"];
    }
    return time;
}

+ (NSString *)stringDateFromInterval: (NSTimeInterval)interval{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: interval];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    NSString *dateString = [dateFormat stringFromDate:date];
    return dateString;
}

+ (NSString *)stringTimeFromInterval: (NSTimeInterval)interval{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: interval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"HH:mm"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *currentTime = [dateFormatter stringFromDate: date];
    return currentTime;
}

//  Get avatar của user
+ (NSData *)getMyAvatarData {
    NSDictionary *avatarDict = [[NSUserDefaults standardUserDefaults] objectForKey: userAvatar];
    NSString *user = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    if (avatarDict == nil || [avatarDict objectForKey: user] == nil) {
        return nil;
    }else {
        return [avatarDict objectForKey: user];
    }
}

//  Lấy hình ảnh với tên
+ (UIImage *)getImageOfDirectoryWithName: (NSString *)imageName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pathFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/files/%@", imageName]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath: pathFile];
    
    if (!fileExists) {
        return nil;
    }else{
        NSData *dataImage = [NSData dataWithContentsOfFile: pathFile];
        UIImage *image = [UIImage imageWithData: dataImage];
        return image;
    }
}

// Lấy hình ảnh với tên
+ (NSString *)getImageDataStringOfDirectoryWithName: (NSString *)imageName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pathFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/files/%@", imageName]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath: pathFile];
    
    if (!fileExists) {
        return nil;
    }else{
        NSData *dataImage = [NSData dataWithContentsOfFile: pathFile];
        NSString *imgDataStr = [dataImage base64EncodedStringWithOptions: 0];
        return imgDataStr;
    }
}

//  Copy file record, sau đó save với tên và trả về data của file mới
+ (NSData *)getAudioFileFromFile: (NSString *)audioFileName andSaveWithName: (NSString *)nameToSave{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pathFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/records/%@", audioFileName]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath: pathFile];
    
    if (!fileExists) {
        return nil;
    }else{
        NSData *audioData = [NSData dataWithContentsOfFile: pathFile];
        
        //  Get đường dẫn để save file mới
        NSString *pathNewFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/records/%@", nameToSave]];
        [audioData writeToFile:pathNewFile atomically:YES];
        return audioData;
    }
}

//  Get trạng thái của user
+ (NSString *)getStatusStringOfUserOnList: (NSString *)callnexUser{
    if ([callnexUser isEqualToString:text_empty] || callnexUser == nil) {
        return welcomeToCloudFone;
    }else{
        NSString *statusStr = callnexUser;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName CONTAINS[cd] %@", callnexUser];
        NSMutableDictionary *listUserDict = [[[OTRProtocolManager sharedInstance] buddyList] allBuddies];
        NSArray *listUser = [OTRBuddyList sortBuddies: listUserDict];
        NSArray *resultArr = [listUser filteredArrayUsingPredicate: predicate];
        if (resultArr.count > 0) {
            OTRBuddy *curBuddy = [resultArr objectAtIndex: 0];
            if (curBuddy.status == kOTRBuddyStatusOffline) {
                statusStr = callnexUser;
            }else{
                //                if (curBuddy.statusString == nil || [curBuddy.statusString isEqualToString:@""]) {
                //                    statusStr = welcomeToCloudFone;
                //                }else{
                //                    statusStr = curBuddy.statusString;
                //                }
            }
        }
        return statusStr;
    }
}

//  Trả về ảnh trong thư mục document
+ (UIImage *)getImageWithName: (NSString *)imageName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *getImagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/themes/%@", imageName]];
    UIImage *img = [UIImage imageWithContentsOfFile:getImagePath];
    return img;
}

//  Tạo avatar cho group chat:
+ (UIImage *)createAvatarForCurrentGroup: (NSArray *)listAvatar {
    switch (listAvatar.count) {
        case 1: {
            return [UIImage imageNamed:@"group_avatar.png"];
            break;
        }
        case 2: {
            //  Tạo avatar cho user thứ nhất
            UIImage *img1 = [AppFunctions createImageFromDataString:[listAvatar objectAtIndex:0]
                                                      withCropSize:CGSizeMake(200, 100)];
            UIImageView *imgView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
            [imgView1 setImage: img1];
            
            //  Tạo avatar cho user thứ 2
            UIImage *img2 = [AppFunctions createImageFromDataString:[listAvatar objectAtIndex:1]
                                                      withCropSize:CGSizeMake(200, 100)];
            UIImageView *imgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 101, 200, 99)];
            [imgView2 setImage: img2];
            
            //  Gộp 2 avatar lại với nhau
            UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
            [avatarView addSubview: imgView1];
            [avatarView addSubview: imgView2];
            return [UIImage imageWithData:[AppFunctions makeImageFromView: avatarView]];
            break;
        }
        case 3:{
            //  Tạo avatar cho user thứ nhất
            UIImage *img1 = [AppFunctions createImageFromDataString:[listAvatar objectAtIndex:0]
                                                      withCropSize:CGSizeMake(200, 100)];
            UIImageView *imgView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
            [imgView1 setImage: img1];
            
            //  Tạo avatar cho user thứ 2
            UIImage *img2 = [AppFunctions createImageFromDataString:[listAvatar objectAtIndex:1]
                                                      withCropSize:CGSizeMake(100, 100)];
            UIImageView *imgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 101, 100, 99)];
            [imgView2 setImage: img2];
            
            //  Tạo avatar cho user thứ 3
            UIImage *img3 = [AppFunctions createImageFromDataString:[listAvatar objectAtIndex:2]
                                                      withCropSize:CGSizeMake(100, 100)];
            UIImageView *imgView3 = [[UIImageView alloc] initWithFrame:CGRectMake(101, 101, 99, 99)];
            [imgView3 setImage: img3];
            
            //  Gộp các avatar lại với nhau
            UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
            [avatarView addSubview: imgView1];
            [avatarView addSubview: imgView2];
            [avatarView addSubview: imgView3];
            return [UIImage imageWithData:[AppFunctions makeImageFromView: avatarView]];
            
            break;
        }
        case 4:{
            //  Tạo avatar cho user thứ nhất
            UIImage *img1 = [AppFunctions createImageFromDataString:[listAvatar objectAtIndex:0]
                                                      withCropSize:CGSizeMake(100, 100)];
            UIImageView *imgView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
            [imgView1 setImage: img1];
            
            //  Tạo avatar cho user thứ 2
            UIImage *img2 = [AppFunctions createImageFromDataString:[listAvatar objectAtIndex:1]
                                                      withCropSize:CGSizeMake(100, 100)];
            UIImageView *imgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(101, 0, 99, 100)];
            [imgView2 setImage: img2];
            
            //  Tạo avatar cho user thứ 3
            UIImage *img3 = [AppFunctions createImageFromDataString:[listAvatar objectAtIndex:2]
                                                      withCropSize:CGSizeMake(100, 100)];
            UIImageView *imgView3 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 101, 100, 99)];
            [imgView3 setImage: img3];
            
            //  Tạo avatar cho user thứ 4
            UIImage *img4 = [AppFunctions createImageFromDataString:[listAvatar objectAtIndex:3]
                                                      withCropSize:CGSizeMake(100, 100)];
            UIImageView *imgView4 = [[UIImageView alloc] initWithFrame:CGRectMake(101, 101, 99, 99)];
            [imgView4 setImage: img4];
            
            //  Gộp các avatar lại với nhau
            UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
            [avatarView addSubview: imgView1];
            [avatarView addSubview: imgView2];
            [avatarView addSubview: imgView3];
            [avatarView addSubview: imgView4];
            return [UIImage imageWithData:[AppFunctions makeImageFromView: avatarView]];
            
            break;
        }
        default:{
            return [UIImage imageNamed:@"group_avatar.png"];
            break;
        }
    }
}

//  Tạo một image được crop từ một callnex
+ (UIImage *)createImageFromDataString: (NSString *)strData withCropSize: (CGSize)cropSize {
    NSData *avatarData;
    if (![strData isEqualToString:text_empty] && ![strData isEqualToString:@"(null)"] && ![strData isEqualToString:@"<null>"] && ![strData isEqualToString:@"null"]) {
        avatarData = [NSData dataFromBase64String: strData];
    }
    UIImage *imgAvatar;
    if (avatarData != nil) {
        imgAvatar = [UIImage imageWithData: avatarData];
    }else{
        imgAvatar = [UIImage imageNamed:@"no_avatar.png"];
    }
    imgAvatar = [AppFunctions cropImageWithSize:cropSize fromImage:imgAvatar];
    return imgAvatar;
}

//  Hàm save một ảnh từ view
+ (NSData *)makeImageFromView: (UIView *)aView {
    CGSize pageSize = CGSizeMake(200, 200);
    UIGraphicsBeginImageContext(pageSize);
    CGContextRef resizedContext = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(resizedContext, - aView.frame.origin.x, -aView.frame.origin.y);
    [aView.layer renderInContext:resizedContext];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *data = UIImagePNGRepresentation(image);
    
    return data;
}

// Hàm crop một ảnh với kích thước-
+ (UIImage*)cropImageWithSize:(CGSize)targetSize fromImage: (UIImage *)sourceImage
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
        {
            scaleFactor = widthFactor; // scale to fit height
        }
        else
        {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 1;
        }
        else
        {
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 1;
            }
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil)
    {
        NSLog(@"could not scale image");
    }
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    return newImage;
}


+ (NSString *)getAccountNameFromString: (NSString *)string {
    NSString *result = text_empty;
    NSRange range = [string rangeOfString:[NSString stringWithFormat:@"@%@", xmpp_cloudfone]];
    
    if (range.location != NSNotFound) {
        result = [string substringToIndex: range.location];
    }else{
        string = [string stringByReplacingOccurrencesOfString:single_cloudfone withString:xmpp_cloudfone];
        range = [string rangeOfString:[NSString stringWithFormat:@"@%@", xmpp_cloudfone]];
        if (range.location != NSNotFound) {
            result = [string substringToIndex: range.location];
        }
    }
    return result;
}

+ (BOOL)isIpad {
    UIDevice *device = [UIDevice currentDevice];
    NSString *model = [device.model lowercaseString];
    if (![model hasPrefix:@"ipad"]) {
        return false;
    }else{
        return true;
    }
}

@end
