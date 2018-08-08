//
//  AppUtils.m
//  linphone
//
//  Created by admin on 11/5/17.
//
//

#import "AppUtils.h"
#import "NSDatabase.h"
#import "OTRProtocolManager.h"
#import "NSData+Base64.h"
#import "PBXContact.h"
#import <sys/utsname.h>
#import "JSONKit.h"

@implementation AppUtils

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

+ (UIFont *)fontRegularWithSize: (float)fontSize{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        return [UIFont fontWithName:@"MYRIADPRO-REGULAR" size:fontSize];
    }else{
        return [UIFont systemFontOfSize: fontSize-1];
    }
}

+ (UIFont *)fontBoldWithSize: (float)fontSize{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        return [UIFont fontWithName:@"MYRIADPRO-BOLD" size:fontSize];
    }else{
        return [UIFont systemFontOfSize: fontSize];
    }
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

+ (NSString *)getAvatarFromContactPerson: (ABRecordRef)person {
    return @"";
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

// Hàm chuyển chuỗi ký tự có dấu thành không dấu
+ (NSString *)convertUTF8CharacterToCharacter: (NSString *)parentStr{
    NSData *dataConvert = [parentStr dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *convertName = [[NSString alloc] initWithData:dataConvert encoding:NSASCIIStringEncoding];
    return convertName;
}

// Chuyển từ convert name sang tên seach dạng số
+ (NSString *)getNameForSearchOfConvertName: (NSString *)convertName{
    convertName = [AppUtils convertUTF8CharacterToCharacter: convertName];
    
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

+ (ContactObject *)getContactWithId: (int)idContact {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_id_contact = %d", idContact];
    NSArray *filter = [[LinphoneAppDelegate sharedInstance].listContacts filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        return [filter objectAtIndex: 0];
    }
    return nil;
}

// Lấy cloudfone id từ một chuỗi
+ (NSString *)getSipFoneIDFromString: (NSString *)string {
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
    return @"";
}

/*---
 Cập nhật badge và tạo notifications khi đang chạy background
 => Nếu không bị mute notifications thì tạo localnotifications và cập nhật badge
 => Nếu có thì chỉ cập nhật badge
 ---*/
+ (void)createLocalNotificationWithAlertBody: (NSString *)alertBodyStr andInfoDict: (NSDictionary *)infoDict ofUser: (NSString *)user{
    BOOL isMute = [NSDatabase checkUserExistsInMuteNotificationsList: user];
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

// Lấy buddy trong roster list
+ (OTRBuddy *)getBuddyOfUserOnList: (NSString *)cloudFoneID{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName CONTAINS[cd] %@", cloudFoneID];
    NSMutableDictionary *listUserDict = [[[OTRProtocolManager sharedInstance] buddyList] allBuddies];
    NSArray *listUser = [OTRBuddyList sortBuddies: listUserDict];
    NSArray *resultArr = [listUser filteredArrayUsingPredicate: predicate];
    if (resultArr.count > 0) {
        return [resultArr objectAtIndex: 0];
    }else{
        return [[OTRBuddy alloc] initWithDisplayName:cloudFoneID accountName:[NSString stringWithFormat:@"%@@%@", cloudFoneID, xmpp_cloudfone] protocol:[LinphoneAppDelegate sharedInstance].myBuddy.protocol status:-1 groupName:@""];
    }
}

+ (NSString *)getAccountNameFromString: (NSString *)string {
    NSString *result = @"";
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

//  Chuyển chuỗi có emotion thành code emoji
+ (NSMutableAttributedString *)convertMessageStringToEmojiString: (NSString *)messageString {
    NSMutableAttributedString *resultStr = [[NSMutableAttributedString alloc] initWithString: messageString];
    
    // Set font cho toan bo chieu dai
    UIFont *font = [UIFont systemFontOfSize:16.0];
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
        filterArr = [[LinphoneAppDelegate sharedInstance]._listFace filteredArrayUsingPredicate: predicate];
        if (filterArr.count > 0) {
            NSString *uCode = [(NSDictionary *)[filterArr objectAtIndex: 0] objectForKey:@"u_code"];
            NSString *totalStr = [NSString stringWithFormat:@"{\"emoji\":\"%@\"}", uCode];
            const char *jsonString = [totalStr UTF8String];
            NSData *jsonData = [NSData dataWithBytes:jsonString length:strlen(jsonString)];
            NSError *error;
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
            NSString *str = [jsonDict objectForKey:@"emoji"];
            [resultStr replaceCharactersInRange:rangeOfFirstMatch withString:str];
            [resultStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16.0] range:NSMakeRange(rangeOfFirstMatch.location, str.length)];
        }else{
            filterArr = [[LinphoneAppDelegate sharedInstance]._listNature filteredArrayUsingPredicate: predicate];
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
                                  value:[UIFont systemFontOfSize:16.0]
                                  range:NSMakeRange(rangeOfFirstMatch.location, str.length)];
            }else{
                filterArr = [[LinphoneAppDelegate sharedInstance]._listObject filteredArrayUsingPredicate: predicate];
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
                                      value:[UIFont systemFontOfSize:16.0]
                                      range:NSMakeRange(rangeOfFirstMatch.location, str.length)];
                }else{
                    filterArr = [[LinphoneAppDelegate sharedInstance]._listPlace filteredArrayUsingPredicate: predicate];
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
                                          value:[UIFont systemFontOfSize:16.0]
                                          range:NSMakeRange(rangeOfFirstMatch.location, str.length)];
                    }else{
                        filterArr = [[LinphoneAppDelegate sharedInstance]._listSymbol filteredArrayUsingPredicate: predicate];
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
                                              value:[UIFont systemFontOfSize:16.0]
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

+ (void)reconnectToXMPPServer {
    NSString *UDID = [AppUtils uniqueIDForDevice];
    NSString *accountName = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone]];
    
    OTRXMPPAccount *_myAccount = [[OTRXMPPAccount alloc] init];
    _myAccount.username = accountName;
    _myAccount.rememberPassword = YES;
    _myAccount.protocol = @"xmpp";
    _myAccount.uniqueIdentifier = UDID;
    _myAccount.password = PASSWORD;
    _myAccount.allowSelfSignedSSL = YES;
    _myAccount.allowSSLHostNameMismatch = YES;
    _myAccount.sendDeliveryReceipts = YES;
    
    id<OTRProtocol> protocol = [[OTRProtocolManager sharedInstance] protocolForAccount: _myAccount];
    [protocol connectWithPassword: _myAccount.password];
    
    [LinphoneAppDelegate sharedInstance].myBuddy = [[OTRBuddy alloc] initWithDisplayName:USERNAME accountName:accountName protocol:protocol status:0 groupName:nil];
}

+ (NSString *)stringTimeFromInterval: (NSTimeInterval)interval{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: interval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"HH:mm"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *currentTime = [dateFormatter stringFromDate: date];
    return currentTime;
}

+ (NSString *)stringDateFromInterval: (NSTimeInterval)interval{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: interval];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    NSString *dateString = [dateFormat stringFromDate:date];
    return dateString;
}

// get data của hình ảnh với tên file
+ (NSData *)getFileDataOfMessageResend: (NSString *)fileName andFileType: (NSString *)fileType{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pathFile = @"";
    if ([fileType isEqualToString: imageMessage]) {
        pathFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/files/%@", fileName]];
    }else{
        NSLog(@"...Loai file khac");
    }
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath: pathFile];
    if (!fileExists) {
        return nil;
    }else{
        NSData *fileData = [NSData dataWithContentsOfFile: pathFile];
        return fileData;
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

//  Tạo avatar cho group chat:
+ (UIImage *)createAvatarForCurrentGroup: (NSArray *)listAvatar {
    switch (listAvatar.count) {
        case 1: {
            return [UIImage imageNamed:@"group_avatar.png"];
            break;
        }
        case 2: {
            //  Tạo avatar cho user thứ nhất
            UIImage *img1 = [AppUtils createImageFromDataString:[listAvatar objectAtIndex:0]
                                                       withCropSize:CGSizeMake(200, 100)];
            UIImageView *imgView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
            [imgView1 setImage: img1];
            
            //  Tạo avatar cho user thứ 2
            UIImage *img2 = [AppUtils createImageFromDataString:[listAvatar objectAtIndex:1]
                                                       withCropSize:CGSizeMake(200, 100)];
            UIImageView *imgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 101, 200, 99)];
            [imgView2 setImage: img2];
            
            //  Gộp 2 avatar lại với nhau
            UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
            [avatarView addSubview: imgView1];
            [avatarView addSubview: imgView2];
            return [UIImage imageWithData:[AppUtils makeImageFromView: avatarView]];
            break;
        }
        case 3:{
            //  Tạo avatar cho user thứ nhất
            UIImage *img1 = [AppUtils createImageFromDataString:[listAvatar objectAtIndex:0]
                                                       withCropSize:CGSizeMake(200, 100)];
            UIImageView *imgView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
            [imgView1 setImage: img1];
            
            //  Tạo avatar cho user thứ 2
            UIImage *img2 = [AppUtils createImageFromDataString:[listAvatar objectAtIndex:1]
                                                       withCropSize:CGSizeMake(100, 100)];
            UIImageView *imgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 101, 100, 99)];
            [imgView2 setImage: img2];
            
            //  Tạo avatar cho user thứ 3
            UIImage *img3 = [AppUtils createImageFromDataString:[listAvatar objectAtIndex:2]
                                                       withCropSize:CGSizeMake(100, 100)];
            UIImageView *imgView3 = [[UIImageView alloc] initWithFrame:CGRectMake(101, 101, 99, 99)];
            [imgView3 setImage: img3];
            
            //  Gộp các avatar lại với nhau
            UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
            [avatarView addSubview: imgView1];
            [avatarView addSubview: imgView2];
            [avatarView addSubview: imgView3];
            return [UIImage imageWithData:[AppUtils makeImageFromView: avatarView]];
            
            break;
        }
        case 4:{
            //  Tạo avatar cho user thứ nhất
            UIImage *img1 = [AppUtils createImageFromDataString:[listAvatar objectAtIndex:0]
                                                       withCropSize:CGSizeMake(100, 100)];
            UIImageView *imgView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
            [imgView1 setImage: img1];
            
            //  Tạo avatar cho user thứ 2
            UIImage *img2 = [AppUtils createImageFromDataString:[listAvatar objectAtIndex:1]
                                                       withCropSize:CGSizeMake(100, 100)];
            UIImageView *imgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(101, 0, 99, 100)];
            [imgView2 setImage: img2];
            
            //  Tạo avatar cho user thứ 3
            UIImage *img3 = [AppUtils createImageFromDataString:[listAvatar objectAtIndex:2]
                                                       withCropSize:CGSizeMake(100, 100)];
            UIImageView *imgView3 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 101, 100, 99)];
            [imgView3 setImage: img3];
            
            //  Tạo avatar cho user thứ 4
            UIImage *img4 = [AppUtils createImageFromDataString:[listAvatar objectAtIndex:3]
                                                       withCropSize:CGSizeMake(100, 100)];
            UIImageView *imgView4 = [[UIImageView alloc] initWithFrame:CGRectMake(101, 101, 99, 99)];
            [imgView4 setImage: img4];
            
            //  Gộp các avatar lại với nhau
            UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
            [avatarView addSubview: imgView1];
            [avatarView addSubview: imgView2];
            [avatarView addSubview: imgView3];
            [avatarView addSubview: imgView4];
            return [UIImage imageWithData:[AppUtils makeImageFromView: avatarView]];
            
            break;
        }
        default:{
            return [UIImage imageNamed:@"group_avatar.png"];
            break;
        }
    }
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

//  Tạo một image được crop từ một callnex
+ (UIImage *)createImageFromDataString: (NSString *)strData withCropSize: (CGSize)cropSize {
    NSData *avatarData;
    if (![strData isEqualToString:@""] && ![strData isEqualToString:@"(null)"] && ![strData isEqualToString:@"<null>"] && ![strData isEqualToString:@"null"]) {
        avatarData = [NSData dataFromBase64String: strData];
    }
    UIImage *imgAvatar;
    if (avatarData != nil) {
        imgAvatar = [UIImage imageWithData: avatarData];
    }else{
        imgAvatar = [UIImage imageNamed:@"no_avatar.png"];
    }
    imgAvatar = [AppUtils cropImageWithSize:cropSize fromImage:imgAvatar];
    return imgAvatar;
}

+ (void)updateBadgeForMessageOfUser: (NSString *)user isIncrease: (BOOL)increase{
    /*--Neu tang badge thi kiem tra user nay co message unread chua, co roi thi thoi--*/
    BOOL badge = [NSDatabase checkBadgeMessageOfUserWhenRunBackground: user];
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

//  Get thông tin của một contact
+ (NSString *)getNameOfContact: (ABRecordRef)aPerson
{
    if (aPerson != nil) {
        NSString *firstName = (__bridge NSString *)ABRecordCopyValue(aPerson, kABPersonFirstNameProperty);
        if (firstName == nil) {
            firstName = @"";
        }
        firstName = [firstName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        firstName = [firstName stringByReplacingOccurrencesOfString:@"\n" withString: @""];
        
        NSString *middleName = (__bridge NSString *)ABRecordCopyValue(aPerson, kABPersonMiddleNameProperty);
        if (middleName == nil) {
            middleName = @"";
        }
        middleName = [middleName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        middleName = [middleName stringByReplacingOccurrencesOfString:@"\n" withString: @""];
        
        NSString *lastName = (__bridge NSString *)ABRecordCopyValue(aPerson, kABPersonLastNameProperty);
        if (lastName == nil) {
            lastName = @"";
        }
        lastName = [lastName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        lastName = [lastName stringByReplacingOccurrencesOfString:@"\n" withString: @""];
        
        // Lưu tên contact cho search phonebook
        NSString *fullname = @"";
        if (![firstName isEqualToString:@""]) {
            fullname = firstName;
        }
        
        if (![middleName isEqualToString:@""]) {
            if ([fullname isEqualToString:@""]) {
                fullname = middleName;
            }else{
                fullname = [NSString stringWithFormat:@"%@ %@", fullname, middleName];
            }
        }
        
        if (![lastName isEqualToString:@""]) {
            if ([fullname isEqualToString:@""]) {
                fullname = lastName;
            }else{
                fullname = [NSString stringWithFormat:@"%@ %@", fullname, lastName];
            }
        }
        return fullname;
    }
    return @"";
}

//  Get tên (custom label) của contact
+ (NSString *)getNameOfPhoneOfContact: (ABRecordRef)aPerson andPhoneNumber: (NSString *)phoneNumber
{
    if (aPerson != nil) {
        NSMutableArray *result = nil;
        ABMultiValueRef phones = ABRecordCopyValue(aPerson, kABPersonPhoneProperty);
        if (ABMultiValueGetCount(phones) > 0)
        {
            result = [[NSMutableArray alloc] init];
            
            for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
            {
                CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, j);
                CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(phones, j);
                
                NSString *curPhoneValue = (__bridge NSString *)phoneNumberRef;
                curPhoneValue = [[curPhoneValue componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
                
                NSString *nameValue = (__bridge NSString *)locLabel;
                
                if (curPhoneValue != nil && [curPhoneValue isEqualToString: phoneNumber]) {
                    if (nameValue == nil) {
                        nameValue = @"";
                    }
                    return nameValue;
                }
            }
        }
    }
    return @"";
}

+ (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

// Ghi file hình ảnh vào folder document
+ (NSArray *)saveImageToFiles: (UIImage *)imageSend withImage: (NSString *)imageName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *largeImageName = [NSString stringWithFormat:@"large_%@", imageName];
    NSData *largeData = UIImageJPEGRepresentation(imageSend, 1.0);
    
    CGRect rect = CGRectMake(0, 0, 150, 150);
    UIGraphicsBeginImageContext(rect.size );
    [imageSend drawInRect:rect];
    
    UIImage *thumbImage = [AppUtils squareImageWithImage:imageSend withSizeWidth: 150];
    UIGraphicsEndImageContext();
    NSData *thumbData = UIImagePNGRepresentation(thumbImage);
    
    NSString *largePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/files/%@", largeImageName]];
    NSString *thumbPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/files/%@", imageName]];
    [largeData writeToFile:largePath atomically:YES];
    [thumbData writeToFile:thumbPath atomically:YES];
    return [[NSArray alloc] initWithObjects: largeImageName, imageName,nil];
}

// Ghi video file vào folder document
+ (BOOL)saveVideoToFiles: (NSData *)videoData withName: (NSString *)videoName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *tempPath = [documentsDirectory stringByAppendingFormat:@"/videos/%@", videoName];
    BOOL success = [videoData writeToFile:tempPath atomically:NO];
    return success;
}

+ (NSString *)getPBXNameWithPhoneNumber: (NSString *)phonenumber {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_number = %@", phonenumber];
    NSArray *filter = [[LinphoneAppDelegate sharedInstance].pbxContacts filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        PBXContact *contact = [filter objectAtIndex: 0];
        return contact._name;
    }
    return @"";
}

+ (NSString *)getAvatarOfContact: (int)idContact {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_id_contact = %d", idContact];
    NSArray *filter = [[LinphoneAppDelegate sharedInstance].listContacts filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        ContactObject *contact = [filter objectAtIndex: 0];
        return contact._avatar;
    }
    return @"";
}

//  Convert time interval to nsstring
+ (NSString *)getDateStringFromTimeInterval: (double)timeInterval
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: timeInterval];
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    if ([calendar isDateInToday:date]) {
        return NSLocalizedString(@"Today", nil);
    } else if ([calendar isDateInYesterday:date]) {
        return NSLocalizedString(@"Yesterday", nil);
    } else {
        NSString *formattedDateString = [dateFormatter stringFromDate:date];
        return formattedDateString;
    }
}

+ (NSString *)getTimeStringFromTimeInterval:(double)timeInterval {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Bangkok"]];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: timeInterval];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    return formattedDateString;
}

+ (UIImage *)getImageDataWithName: (NSString *)imageName {
    NSString *appDocDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *workSpacePath = [appDocDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"files/%@", imageName]];
    return [UIImage imageWithData:[NSData dataWithContentsOfFile:workSpacePath]];
}

+ (UIImage *)getImageFromVideo:(NSURL *)videoUrl atTime:(CGFloat)time {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    AVAssetImageGenerator *generateImg = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generateImg.appliesPreferredTrackTransform = YES;
    NSError *error = NULL;
    CMTime cmTime = CMTimeMake(time, 1);
    CGImageRef refImg = [generateImg copyCGImageAtTime:cmTime actualTime:NULL error:&error];
    NSLog(@"error==%@, Refimage==%@", error, refImg);
    
    UIImage *FrameImage= [[UIImage alloc] initWithCGImage:refImg];
    return FrameImage;
}

+ (int)getBurnMessageValueOfRemoteParty: (NSString *)remoteParty {
    NSString *keyBurnMsg = [NSString stringWithFormat:@"%@_%@_%@", prefix_CHAT_BURN, USERNAME, remoteParty];
    NSString *burnValue = [[NSUserDefaults standardUserDefaults] objectForKey:keyBurnMsg];
    if (burnValue == nil || [burnValue intValue] == 0) {
        return 0;
    }else{
        return 1;
    }
}

//  Kiểm tra setting nhận tin nhắn mới cho remote party
+ (int)getNewMessageValueOfRemoteParty: (NSString *)remoteParty {
    NSString *keyNewMsg = [NSString stringWithFormat:@"%@_%@_%@", prefix_CHAT_NOTIF, USERNAME, remoteParty];
    NSString *newMsgValue = [[NSUserDefaults standardUserDefaults] objectForKey:keyNewMsg];
    if (newMsgValue == nil || [newMsgValue intValue] == 1) {
        return 1;
    }else{
        return 0;
    }
}

//  Kiểm tra setting nhận tin nhắn mới cho toàn bộ remote party
+ (BOOL)getNewMessageValueForSettingsOfAccount: (NSString *)account {
    NSString *soundMsgKey = [NSString stringWithFormat:@"%@_%@", key_sound_message, account];
    NSString *soundMsgValue = [[NSUserDefaults standardUserDefaults] objectForKey: soundMsgKey];
    if (soundMsgValue == nil || [soundMsgValue isEqualToString: text_yes]) {
        return YES;
    }else{
        return NO;
    }
}

+ (BOOL)getVibrateForMessageForSettingsOfAccount: (NSString *)account {
    NSString *vibrateUserKey = [NSString stringWithFormat:@"%@_%@", key_vibrate_message, account];
    NSString *virateValue = [[NSUserDefaults standardUserDefaults] objectForKey: vibrateUserKey];
    if (virateValue == nil || [virateValue isEqualToString: text_yes]) {
        return YES;
    }else{
        return NO;
    }
}

//  save details and thumbnail image for video message
+ (void)savePictureOfVideoToDocument: (MessageEvent *)message {
    NSString *strURL = [NSString stringWithFormat:@"%@/%@", link_picutre_chat_group, message.content];
    NSURL *videoUrl = [NSURL URLWithString: strURL];
    UIImage *imageVideo = [AppUtils getImageFromVideo:videoUrl atTime:1];
    
    NSString *imageName = [NSString stringWithFormat:@"%@_%@.jpg", USERNAME, [AppUtils randomStringWithLength:20]];
    
    NSArray *fileNameArr = [AppUtils saveImageToFiles: imageVideo withImage: imageName];
    NSString *details = [fileNameArr objectAtIndex: 0];
    NSString *thumbnail = [fileNameArr objectAtIndex: 1];
    [NSDatabase updateImageMessageWithDetailsUrl:details andThumbUrl:thumbnail ofImageMessage:message.idMessage];
}

//  Lấy status của user
+ (NSArray *)getStatusOfUser: (NSString *)sipPhone {
    if (sipPhone == nil || [sipPhone isEqualToString:@""]) {
        return [NSArray arrayWithObjects: sipPhone, [NSNumber numberWithInt:-1], nil];
    }else{
        int status = -1;
        NSString *statusStr = sipPhone;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName contains[cd] %@", sipPhone];
        
        NSMutableDictionary *listUserDict = [[[OTRProtocolManager sharedInstance] buddyList] allBuddies];
        NSArray *listUser = [OTRBuddyList sortBuddies: listUserDict];
        NSArray *resultArr = [listUser filteredArrayUsingPredicate: predicate];
        if (resultArr.count > 0) {
            OTRBuddy *curBuddy = [resultArr objectAtIndex: 0];
            if (curBuddy.status == kOTRBuddyStatusOffline) {
                statusStr = sipPhone;
            }else{
                statusStr = [[LinphoneAppDelegate sharedInstance]._statusXMPPDict objectForKey: sipPhone];
                if (statusStr == nil || [statusStr isEqualToString:@""]) {
                    statusStr = welcomeToCloudFone;
                }
            }
            status = curBuddy.status;
        }
        return [NSArray arrayWithObjects:statusStr,[NSNumber numberWithInt:status], nil];
    }
}

+ (UIImage *)createAvatarForRoom: (NSString *)roomID withSize: (int)size {
    UIImageView *avartarView = [[UIImageView alloc] init];
    avartarView.backgroundColor = [UIColor whiteColor];
    
    NSMutableArray *lists = [NSDatabase getListOccupantsInGroup:roomID ofAccount:USERNAME];
    float margin = 2;
    float wSmall = (size - margin)/2;
    int cornor = (int)(wSmall/2);
    
    switch (lists.count) {
        case 0:
        case 1:{
            UIImageView *iv1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
            iv1.image = [UIImage imageNamed:@"groupchat_default"];
            [avartarView addSubview:iv1];
            return [UIImage imageNamed:@"groupchat_default"];
            break;
        }
        case 2:{
            UIImageView *iv1 = [[UIImageView alloc] initWithFrame:CGRectMake((size-wSmall)/2, 0, wSmall, wSmall)];
            iv1.clipsToBounds = YES;
            iv1.layer.cornerRadius = cornor;
            
            UIImageView *iv2 = [[UIImageView alloc] initWithFrame:CGRectMake(iv1.frame.origin.x, wSmall+margin, wSmall, wSmall)];
            iv2.clipsToBounds = YES;
            iv2.layer.cornerRadius = cornor;
            
            [iv1 setImage:[UIImage imageNamed:@"no_avatar"]];
            [avartarView addSubview:iv1];
            
            [iv2 setImage:[UIImage imageNamed:@"no_avatar"]];
            [avartarView addSubview:iv2];
            
            for(int i = 0; i < (int)lists.count; i++){
                NSString *sipPhone = lists[i];
                NSString *dataStr = [NSDatabase getAvatarOfContactWithPhoneNumber: sipPhone];
                
                if (i == 0) {
                    if ([dataStr isEqualToString:@""]) {
                        iv1.image = [UIImage imageNamed:@"no_avatar"];
                    }else{
                        iv1.image = [UIImage imageWithData:[NSData dataFromBase64String: dataStr]];
                    }
                }else if (i == 1){
                    if ([dataStr isEqualToString:@""]) {
                        iv2.image = [UIImage imageNamed:@"no_avatar"];
                    }else{
                        iv2.image = [UIImage imageWithData:[NSData dataFromBase64String: dataStr]];
                    }
                }
            }
            break;
        }
        case 3:{
            UIImageView *iv1 = [[UIImageView alloc] initWithFrame:CGRectMake((size-wSmall)/2, 0, wSmall, wSmall)];
            iv1.clipsToBounds = YES;
            iv1.layer.cornerRadius = cornor;
            
            UIImageView *iv2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, wSmall+margin, wSmall, wSmall)];
            iv2.clipsToBounds = YES;
            iv2.layer.cornerRadius = cornor;
            
            UIImageView *iv3 = [[UIImageView alloc] initWithFrame:CGRectMake(wSmall+margin, wSmall+margin, wSmall, wSmall)];
            iv3.clipsToBounds = YES;
            iv3.layer.cornerRadius = cornor;
            
            [iv1 setImage:[UIImage imageNamed:@"no_avatar"]];
            [avartarView addSubview:iv1];
            
            [iv2 setImage:[UIImage imageNamed:@"no_avatar"]];
            [avartarView addSubview:iv2];
            
            [iv3 setImage:[UIImage imageNamed:@"no_avatar"]];
            [avartarView addSubview:iv3];
            
            for(int i = 0; i < (int)lists.count; i++){
                NSString *sipPhone = lists[i];
                NSString *dataStr = [NSDatabase getAvatarOfContactWithPhoneNumber: sipPhone];
                
                if (i == 0) {
                    if ([dataStr isEqualToString:@""]) {
                        iv1.image = [UIImage imageNamed:@"no_avatar"];
                    }else{
                        iv1.image = [UIImage imageWithData:[NSData dataFromBase64String: dataStr]];
                    }
                }else if (i == 1){
                    if ([dataStr isEqualToString:@""]) {
                        iv2.image = [UIImage imageNamed:@"no_avatar"];
                    }else{
                        iv2.image = [UIImage imageWithData:[NSData dataFromBase64String: dataStr]];
                    }
                }else if (i == 2){
                    if ([dataStr isEqualToString:@""]) {
                        iv3.image = [UIImage imageNamed:@"no_avatar"];
                    }else{
                        iv3.image = [UIImage imageWithData:[NSData dataFromBase64String: dataStr]];
                    }
                }
            }
            break;
        }
        case 4:{
            UIImageView *iv1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, wSmall, wSmall)];
            UIImageView *iv2 = [[UIImageView alloc] initWithFrame:CGRectMake(wSmall+margin, 0, wSmall, wSmall)];
            UIImageView *iv3 = [[UIImageView alloc] initWithFrame:CGRectMake(0, wSmall+margin, wSmall, wSmall)];
            UIImageView *iv4 = [[UIImageView alloc] initWithFrame:CGRectMake(wSmall+margin, wSmall+margin, wSmall, wSmall)];
            
            [iv1 setImage:[UIImage imageNamed:@"no_avatar"]];
            iv1.clipsToBounds = YES;
            iv1.layer.cornerRadius = cornor;
            
            [avartarView addSubview:iv1];
            
            [iv2 setImage:[UIImage imageNamed:@"no_avatar"]];
            iv2.clipsToBounds = YES;
            iv2.layer.cornerRadius = cornor;
            
            [avartarView addSubview:iv2];
            
            [iv3 setImage:[UIImage imageNamed:@"no_avatar"]];
            iv3.clipsToBounds = YES;
            iv3.layer.cornerRadius = cornor;
            [avartarView addSubview:iv3];
            
            [iv4 setImage:[UIImage imageNamed:@"no_avatar"]];
            iv4.clipsToBounds = YES;
            iv4.layer.cornerRadius = cornor;
            
            [avartarView addSubview:iv4];
            
            for(int i = 0; i < (int)lists.count; i++){
                NSString *sipPhone = lists[i];
                NSString *dataStr = [NSDatabase getAvatarOfContactWithPhoneNumber: sipPhone];
                
                if (i == 0) {
                    if ([dataStr isEqualToString:@""]) {
                        iv1.image = [UIImage imageNamed:@"no_avatar"];
                    }else{
                        iv1.image = [UIImage imageWithData:[NSData dataFromBase64String: dataStr]];
                    }
                }else if (i == 1){
                    if ([dataStr isEqualToString:@""]) {
                        iv2.image = [UIImage imageNamed:@"no_avatar"];
                    }else{
                        iv2.image = [UIImage imageWithData:[NSData dataFromBase64String: dataStr]];
                    }
                }else if (i == 2){
                    if ([dataStr isEqualToString:@""]) {
                        iv3.image = [UIImage imageNamed:@"no_avatar"];
                    }else{
                        iv3.image = [UIImage imageWithData:[NSData dataFromBase64String: dataStr]];
                    }
                }else if (i == 3){
                    if ([dataStr isEqualToString:@""]) {
                        iv4.image = [UIImage imageNamed:@"no_avatar"];
                    }else{
                        iv4.image = [UIImage imageWithData:[NSData dataFromBase64String: dataStr]];
                    }
                }
            }
            break;
        }
        default:{
            UIImageView *iv1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, wSmall, wSmall)];
            UIImageView *iv2 = [[UIImageView alloc] initWithFrame:CGRectMake(wSmall+margin, 0, wSmall, wSmall)];
            UIImageView *iv3 = [[UIImageView alloc] initWithFrame:CGRectMake(0, wSmall+margin, wSmall, wSmall)];
            UILabel *lbCount = [[UILabel alloc] initWithFrame:CGRectMake(wSmall+margin, wSmall+margin, wSmall, wSmall)];
            
            [iv1 setImage:[UIImage imageNamed:@"no_avatar"]];
            iv1.clipsToBounds = YES;
            iv1.layer.cornerRadius = cornor;
            [avartarView addSubview:iv1];
            
            [iv2 setImage:[UIImage imageNamed:@"no_avatar"]];
            iv2.clipsToBounds = YES;
            iv2.layer.cornerRadius = cornor;
            [avartarView addSubview:iv2];
            
            [iv3 setImage:[UIImage imageNamed:@"no_avatar"]];
            iv3.clipsToBounds = YES;
            iv3.layer.cornerRadius = cornor;
            [avartarView addSubview:iv3];
            
            //  [iv4 setImage:[UIImage imageNamed:@"no_avatar"]];
            [lbCount setBackgroundColor:[UIColor colorWithRed:0.169 green:0.53 blue:0.949 alpha:1.0]];
            lbCount.clipsToBounds = YES;
            lbCount.layer.cornerRadius = cornor;
            lbCount.font = [UIFont systemFontOfSize: 50.0];
            lbCount.textColor = [UIColor whiteColor];
            lbCount.textAlignment = NSTextAlignmentCenter;
            [avartarView addSubview:lbCount];
            
            for(int i = 0; i < (int)lists.count; i++){
                NSString *sipPhone = lists[i];
                NSString *dataStr = [NSDatabase getAvatarOfContactWithPhoneNumber: sipPhone];
                
                if (i == 0) {
                    if ([dataStr isEqualToString:@""]) {
                        iv1.image = [UIImage imageNamed:@"no_avatar"];
                    }else{
                        iv1.image = [UIImage imageWithData:[NSData dataFromBase64String: dataStr]];
                    }
                }else if (i == 1){
                    if ([dataStr isEqualToString:@""]) {
                        iv2.image = [UIImage imageNamed:@"no_avatar"];
                    }else{
                        iv2.image = [UIImage imageWithData:[NSData dataFromBase64String: dataStr]];
                    }
                }else if (i == 2){
                    if ([dataStr isEqualToString:@""]) {
                        iv3.image = [UIImage imageNamed:@"no_avatar"];
                    }else{
                        iv3.image = [UIImage imageWithData:[NSData dataFromBase64String: dataStr]];
                    }
                }else if (i == 3){
                    [lbCount setText:[NSString stringWithFormat:@"+%d", (int)lists.count-3]];
                }
            }
            break;
        }
    }
    return [self imageWithView:avartarView withSize:CGSizeMake(200, 200)];
    //  return avartarView;
}

+ (UIImage *)imageWithView:(UIView *)aView withSize: (CGSize)resultSize
{
    UIGraphicsBeginImageContext(resultSize);
    CGContextRef resizedContext = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(resizedContext, - aView.frame.origin.x, -aView.frame.origin.y);
    [aView.layer renderInContext:resizedContext];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (XMPPRoom*) searchRoomFromId:(NSString *)roomId {
    XMPPRoom *room = nil;
    @synchronized([LinphoneAppDelegate sharedInstance].xmppChatRooms) {
        for (int i = 0; i < [LinphoneAppDelegate sharedInstance].xmppChatRooms.count; i++) {
            XMPPRoom *roomObj = [LinphoneAppDelegate sharedInstance].xmppChatRooms[i];
            if ([[roomObj.roomJID bare] isEqualToString:roomId]) {
                room = roomObj;
                break;
            }
        }
    }
    return room;
}

+ (NSString *)getDeviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

+ (NSString *)getDeviceNameFromModelName: (NSString *)modelName {
    if ([modelName isEqualToString:@"iPhone7,2"]) {
        return @"iPhone 6";
    }else if ([modelName isEqualToString:@"iPhone7,1"]){
        return @"iPhone 6 Plus";
    }else if ([modelName isEqualToString:@"iPhone8,1"]){
        return @"iPhone 6s";
    }else if ([modelName isEqualToString:@"iPhone8,2"]){
        return @"iPhone 6s Plus";
    }else if ([modelName isEqualToString:@"iPhone9,1"] || [modelName isEqualToString:@"iPhone9,3"]){
        return @"iPhone 7";
    }else if ([modelName isEqualToString:@"iPhone9,2"] || [modelName isEqualToString:@"iPhone9,4"]){
        return @"iPhone 7 Plus";
    }else if ([modelName isEqualToString:@"iPhone8,4"]){
        return @"iPhone SE";
    }else if ([modelName isEqualToString:@"iPhone10,1"] || [modelName isEqualToString:@"iPhone10,4"]){
        return @"iPhone 8";
    }else if ([modelName isEqualToString:@"iPhone10,2"] || [modelName isEqualToString:@"iPhone10,5"]){
        return @"iPhone 8 Plus";
    }else if ([modelName isEqualToString:@"iPhone10,3"] || [modelName isEqualToString:@"iPhone10,6"]){
        return @"iPhone X";
    }else if ([modelName isEqualToString:@"iPhone6,1"] || [modelName isEqualToString:@"iPhone6,2"]){
        return @"iPhone 5s";
    }else if ([modelName isEqualToString:@"iPhone5,3"] || [modelName isEqualToString:@"iPhone5,4"]){
        return @"iPhone 5c";
    }else if ([modelName isEqualToString:@"iPhone5,1"] || [modelName isEqualToString:@"iPhone5,2"]){
        return @"iPhone 5";
    }else if ([modelName isEqualToString:@"iPhone4,1"]){
        return @"iPhone 4s";
    }else if ([modelName isEqualToString:@"iPhone3,1"] || [modelName isEqualToString:@"iPhone3,2"] || [modelName isEqualToString:@"iPhone3,3"]){
        return @"iPhone 4";
    }else if ([modelName isEqualToString:@"iPhone3,1"] || [modelName isEqualToString:@"iPhone3,2"] || [modelName isEqualToString:@"iPhone3,3"]){
        return @"iPhone 4";
    }else if ([modelName isEqualToString:@"iPad2,1"] || [modelName isEqualToString:@"iPad2,2"] || [modelName isEqualToString:@"iPad2,3"] || [modelName isEqualToString:@"iPad2,4"]){
        return @"iPad 2";
    }else if ([modelName isEqualToString:@"iPad3,1"] || [modelName isEqualToString:@"iPad3,2"] || [modelName isEqualToString:@"iPad3,3"]){
        return @"iPad 3";
    }else if ([modelName isEqualToString:@"iPad3,4"] || [modelName isEqualToString:@"iPad3,5"] || [modelName isEqualToString:@"iPad3,6"]){
        return @"iPad 4";
    }else if ([modelName isEqualToString:@"iPad4,1"] || [modelName isEqualToString:@"iPad4,2"] || [modelName isEqualToString:@"iPad4,3"]){
        return @"iPad Air";
    }else if ([modelName isEqualToString:@"iPad5,3"] || [modelName isEqualToString:@"iPad5,4"]){
        return @"iPad Air 2";
    }else if ([modelName isEqualToString:@"iPad6,11"] || [modelName isEqualToString:@"iPad6,12"]){
        return @"iPad 5";
    }else if ([modelName isEqualToString:@"iPad2,5"] || [modelName isEqualToString:@"iPad2,6"] || [modelName isEqualToString:@"iPad2,7"]){
        return @"iPad Mini";
    }else if ([modelName isEqualToString:@"iPad4,4"] || [modelName isEqualToString:@"iPad4,5"] || [modelName isEqualToString:@"iPad4,6"]){
        return @"iPad Mini 2";
    }else if ([modelName isEqualToString:@"iPad4,7"] || [modelName isEqualToString:@"iPad4,8"] || [modelName isEqualToString:@"iPad4,9"]){
        return @"iPad Mini 3";
    }else if ([modelName isEqualToString:@"iPad5,1"] || [modelName isEqualToString:@"iPad5,2"]){
        return @"iPad Mini 4";
    }else if ([modelName isEqualToString:@"iPad6,3"] || [modelName isEqualToString:@"iPad6,4"]){
        return @"iPad Pro 9.7 Inch";
    }else if ([modelName isEqualToString:@"iPad6,7"] || [modelName isEqualToString:@"iPad6,8"]){
        return @"iPad Pro 12.9 Inch";
    }else if ([modelName isEqualToString:@"iPad7,1"] || [modelName isEqualToString:@"iPad7,2"]){
        return @"iPad Pro 12.9 Inch 2. Generation";
    }else if ([modelName isEqualToString:@"iPad7,3"] || [modelName isEqualToString:@"iPad7,4"]){
        return @"iPad Pro 10.5 Inch";
    }else{
        return @"iPod or other device";
    }
}

+ (NSString *)getCurrentOSVersionOfDevice {
    double currentIOS = [[[UIDevice currentDevice] systemVersion] doubleValue];
    return [NSString stringWithFormat:@"%f", currentIOS];
}

+ (NSString *)getCurrentVersionApplicaton {
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    return [NSString stringWithFormat:@"%@(%@)", version, build];
}

+ (BOOL)soundForCallIsEnable {
    NSString *soundCallKey = [NSString stringWithFormat:@"%@_%@", key_sound_call, USERNAME];
    NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:soundCallKey];
    if (value == nil || [value isEqualToString: text_yes]) {
        return YES;
    }
    return NO;
}

+ (UIColor *)randomColorWithAlpha: (float)alpha {
    CGFloat red = arc4random() % 256 / 255.0;
    //  CGFloat red = arc4random_uniform(256) / 255.0;
    CGFloat green = arc4random() % 256 / 255.0;
    CGFloat blue = arc4random() % 256 / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (void)sendMessageForOfflineForUser: (NSString *)IDRecipient fromSender: (NSString *)Sender withContent: (NSString *)content andTypeMessage: (NSString *)typeMessage withGroupID: (NSString *)GroupID
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@", link_api, PushSharp];
    NSURL *URL = [NSURL URLWithString:strURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: URL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
    [request setTimeoutInterval: 60];
    
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:AuthUser forKey:@"AuthUser"];
    [jsonDict setObject:AuthKey forKey:@"AuthKey"];
    [jsonDict setObject:IDRecipient forKey:@"IDRecipient"];
    [jsonDict setObject:@"yes" forKey:@"Xmpp"];
    [jsonDict setObject:Sender forKey:@"Sender"];
    [jsonDict setObject:typeMessage forKey:@"Type"];
    [jsonDict setObject:content forKey:@"Content"];
    [jsonDict setObject:GroupID forKey:@"GroupID"];
    
    NSString *jsonRequest = [jsonDict JSONString];
    NSData *requestData = [jsonRequest dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [request setValue:[NSString stringWithFormat:@"%d", (int)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if(connection) {
        NSLog(@"Connection Successful");
    }
}

@end
