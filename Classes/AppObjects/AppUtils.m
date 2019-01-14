//
//  AppUtils.m
//  linphone
//
//  Created by admin on 11/5/17.
//
//

#import "AppUtils.h"
#import "NSData+Base64.h"
#import <sys/utsname.h>
#import "JSONKit.h"
#import "CustomTextAttachment.h"

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

+ (NSString *)getCurrentDateTimeToStringWithLanguage: (NSString *)lang {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if ([lang isEqualToString: key_vi]) {
        [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    }else{
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    
    // or @"yyyy-MM-dd hh:mm:ss a" if you prefer the time with AM/PM
    
    return [dateFormatter stringFromDate:[NSDate date]];
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
    
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setDateFormat:@"yyyy-MM-dd"];
    [formatter2 setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Bangkok"]];
    
    NSString *currentTime = [formatter stringFromDate: today];
    NSString *currentTime2 = [formatter2 stringFromDate: today];
    
    if ([currentTime isEqualToString: dateStr] || [currentTime2 isEqualToString: dateStr]) {
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

/*---
 Cập nhật badge và tạo notifications khi đang chạy background
 => Nếu không bị mute notifications thì tạo localnotifications và cập nhật badge
 => Nếu có thì chỉ cập nhật badge
 ---*/
+ (void)createLocalNotificationWithAlertBody: (NSString *)alertBodyStr andInfoDict: (NSDictionary *)infoDict ofUser: (NSString *)user{
    UILocalNotification *messageNotif = [[UILocalNotification alloc] init];
    messageNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow: 0.1];
    messageNotif.timeZone = [NSTimeZone defaultTimeZone];
    messageNotif.timeZone = [NSTimeZone defaultTimeZone];
    messageNotif.alertBody = alertBodyStr;
    messageNotif.userInfo = infoDict;
    messageNotif.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification: messageNotif];
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

+ (NSString *)stringTimeFromInterval: (NSTimeInterval)interval{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: interval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"HH:mm"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *currentTime = [dateFormatter stringFromDate: date];
    return currentTime;
}

+ (NSString *)stringDateFromInterval: (NSTimeInterval)interval{
    NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:language_key];
    if (language == nil) {
        language = key_en;
        [[NSUserDefaults standardUserDefaults] setObject:language forKey:language_key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: interval];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    if ([language isEqualToString: key_en]) {
        [dateFormat setDateFormat:@"MM-dd-yyyy"];
    }else{
        [dateFormat setDateFormat:@"dd-MM-yyyy"];
    }
    
    NSString *dateString = [dateFormat stringFromDate:date];
    return dateString;
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
        if (![AppUtils isNullOrEmpty: lastName]) {
            fullname = lastName;
        }
        
        if (![AppUtils isNullOrEmpty: middleName]) {
            if ([fullname isEqualToString:@""]) {
                fullname = middleName;
            }else{
                fullname = [NSString stringWithFormat:@"%@ %@", fullname, middleName];
            }
        }
        
        if (![AppUtils isNullOrEmpty: firstName]) {
            if ([firstName isEqualToString:@""]) {
                fullname = firstName;
            }else{
                fullname = [NSString stringWithFormat:@"%@ %@", fullname, firstName];
            }
        }
        return fullname;
    }
    return @"";
}

//  Get first name and last name of contact
+ (NSArray *)getFirstNameAndLastNameOfContact: (ABRecordRef)aPerson
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
        if (![lastName isEqualToString:@""]) {
            fullname = lastName;
        }
        
        if (![middleName isEqualToString:@""]) {
            if ([fullname isEqualToString:@""]) {
                fullname = middleName;
            }else{
                fullname = [NSString stringWithFormat:@"%@ %@", fullname, middleName];
            }
        }
        return @[firstName, fullname];
    }
    return @[@"", @""];
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

+ (UIImage *)getImageDataWithName: (NSString *)imageName {
    NSString *appDocDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *workSpacePath = [appDocDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"files/%@", imageName]];
    return [UIImage imageWithData:[NSData dataWithContentsOfFile:workSpacePath]];
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
    if (value == nil || [value isEqualToString: @"YES"]) {
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

//  Added by Khai Le on 04/10/2018
+ (void)addCornerRadiusTopLeftAndBottomLeftForButton: (id)view radius: (float)radius withColor: (UIColor *)borderColor border: (float)borderWidth{
    if ([view isKindOfClass:[UIView class]]) {
        CAShapeLayer * maskLayer = [CAShapeLayer layer];
        maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: [(UIView *)view bounds] byRoundingCorners: UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii: (CGSize){radius, radius}].CGPath;
        [(UIView *)view layer].mask = maskLayer;
        
        //Give Border
        //Create path for border
        UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:[(UIView *)view bounds]
                                                         byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft
                                                               cornerRadii:CGSizeMake(radius, radius)];
        // Create the shape layer and set its path
        CAShapeLayer *borderLayer = [CAShapeLayer layer];
        
        borderLayer.frame       = [(UIView *)view bounds];
        borderLayer.path        = borderPath.CGPath;
        borderLayer.strokeColor = borderColor.CGColor;
        borderLayer.fillColor   = UIColor.clearColor.CGColor;
        borderLayer.lineWidth   = borderWidth;
        
        //Add this layer to give border.
        [[(UIView *)view layer] addSublayer:borderLayer];
    }
}

+ (void)addCornerRadiusTopRightAndBottomRightForButton: (id)view radius: (float)radius withColor: (UIColor *)borderColor border: (float)borderWidth {
    if ([view isKindOfClass:[UIView class]]) {
        CAShapeLayer * maskLayer = [CAShapeLayer layer];
        maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: [(UIView *)view bounds] byRoundingCorners: UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii: (CGSize){radius, radius}].CGPath;
        [(UIView *)view layer].mask = maskLayer;
        
        //Give Border
        //Create path for border
        UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:[(UIView *)view bounds]
                                                         byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight
                                                               cornerRadii:CGSizeMake(radius, radius)];
        // Create the shape layer and set its path
        CAShapeLayer *borderLayer = [CAShapeLayer layer];
        
        borderLayer.frame       = [(UIView *)view bounds];
        borderLayer.path        = borderPath.CGPath;
        borderLayer.strokeColor = borderColor.CGColor;
        borderLayer.fillColor   = UIColor.clearColor.CGColor;
        borderLayer.lineWidth   = borderWidth;
        
        //Add this layer to give border.
        [[(UIView *)view layer] addSublayer:borderLayer];
    }
}

// Remove all special characters from string
+ (NSString *)removeAllSpecialInString: (NSString *)phoneString {
    NSString *resultStr = @"";
    for (int strCount=0; strCount<phoneString.length; strCount++) {
        char characterChar = [phoneString characterAtIndex: strCount];
        NSString *characterStr = [NSString stringWithFormat:@"%c", characterChar];
        if ([[LinphoneAppDelegate sharedInstance].listNumber containsObject: characterStr]) {
            resultStr = [NSString stringWithFormat:@"%@%@", resultStr, characterStr];
        }
    }
    return resultStr;
}

//  Convert time interval to nsstring
+ (NSString *)getDateStringFromTimeInterval: (double)timeInterval
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: timeInterval];
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    if ([calendar isDateInToday:date]) {
        return [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Today"];
    } else if ([calendar isDateInYesterday:date]) {
        return [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Yesterday"];
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

+(BOOL)isNullOrEmpty:(NSString*)string{
    return string == nil || string==(id)[NSNull null] || [string isEqualToString: @""];
}

+ (NSString *)getAppVersionWithBuildVersion: (BOOL)showBuildVersion {
    NSString *version = @"";
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    
    if (!showBuildVersion) {
        version = [info objectForKey:@"CFBundleShortVersionString"];
    }else{
        version = [NSString stringWithFormat:@"%@ (%@)", [info objectForKey:@"CFBundleShortVersionString"], [info objectForKey:@"CFBundleVersion"]];
    }
    return version;
}

+ (UIImage *)imageWithColor:(UIColor *)color andBounds:(CGRect)imgBounds {
    UIGraphicsBeginImageContextWithOptions(imgBounds.size, NO, 0);
    [color setFill];
    UIRectFill(imgBounds);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

+ (NSAttributedString *)getVersionStringForApp {
    CustomTextAttachment *attachment = [[CustomTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:@"ic_about.png"];
    [attachment setImageHeight: 24.0];
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    
    NSString *content = [NSString stringWithFormat:@" %@ %@", [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Version"], [AppUtils getAppVersionWithBuildVersion: NO]];
    NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithString:content];
    
    NSMutableAttributedString *verString = [[NSMutableAttributedString alloc] initWithAttributedString: attachmentString];
    //
    [verString appendAttributedString: contentString];
    return verString;
}

// Ghi video file vào folder document
+ (BOOL)saveFileToFolder: (NSData *)fileData withName: (NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *tempPath = [documentsDirectory stringByAppendingFormat:@"%@", fileName];
    BOOL success = [fileData writeToFile:tempPath atomically:NO];
    return success;
}

+ (NSData *)getFileDataFromDirectoryWithFileName: (NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pathFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", fileName]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath: pathFile];
    
    if (!fileExists) {
        return nil;
    }else{
        NSData *fileData = [NSData dataWithContentsOfFile: pathFile];
        return fileData;
    }
}

+ (PBXContact *)getPBXContactFromListWithPhoneNumber: (NSString *)pbxPhone {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_number CONTAINS[cd] %@", pbxPhone];
    NSArray *filter = [[LinphoneAppDelegate sharedInstance].pbxContacts filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        return [filter firstObject];
    }
    return nil;
}

+ (NSString *)getBuildDate
{
    NSString *dateStr = [NSString stringWithFormat:@"%@ %@", [NSString stringWithUTF8String:__DATE__], [NSString stringWithUTF8String:__TIME__]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"LLL d yyyy HH:mm:ss"];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSDate *date1 = [dateFormatter dateFromString:dateStr];
    
    NSTimeInterval time = [date1 timeIntervalSince1970];
    NSString *dateResult = [AppUtils stringDateFromInterval: time];
    NSString *timeResult = [AppUtils stringTimeFromInterval: time];
    return [NSString stringWithFormat:@"%@ %@", dateResult, timeResult];
}

+(NSDateFormatter*) historyEventDate{
    NSDateFormatter* sHistoryEventDate = [[NSDateFormatter alloc] init];
    [sHistoryEventDate setTimeStyle:NSDateFormatterNoStyle];
    [sHistoryEventDate setDateStyle:NSDateFormatterMediumStyle];
    return sHistoryEventDate;
}

+ (NSString *)getDateFromInterval: (double)timeInterval {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: timeInterval];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    return formattedDateString;
}

+ (NSString *)getFullTimeStringFromTimeInterval:(double)timeInterval {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    //    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Bangkok"]];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: timeInterval];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    return formattedDateString;
}

+ (NSString *)convertDurtationToString: (long)duration
{
    int hour = (int)(duration/3600);
    int minutes = (int)((duration - hour*3600)/60);
    int seconds = (int)(duration - hour*3600 - minutes*60);
    
    NSString *result = @"";
    if (hour > 0) {
        if (hour == 1) {
            result = [NSString stringWithFormat:@"%ld %@", (long)hour, [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"hour"]];
        }else{
            result = [NSString stringWithFormat:@"%ld %@", (long)hour, [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"hours"]];
        }
    }
    
    if (minutes > 0) {
        if (![result isEqualToString:@""]) {
            if (minutes == 1) {
                result = [NSString stringWithFormat:@"%@ %d %@", result, minutes, [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"minute"]];
            }else{
                result = [NSString stringWithFormat:@"%@ %d %@", result, minutes, [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"minutes"]];
            }
        }else{
            if (minutes == 1) {
                result = [NSString stringWithFormat:@"%d %@", minutes, [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"minute"]];
            }else{
                result = [NSString stringWithFormat:@"%d %@", minutes, [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"minutes"]];
            }
        }
    }
    
    if (seconds > 0) {
        if (![result isEqualToString:@""]) {
            result = [NSString stringWithFormat:@"%@ %d %@", result, seconds, [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"sec"]];
        }else{
            result = [NSString stringWithFormat:@"%d %@", seconds, [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"sec"]];
        }
    }
    return result;
}

+ (UINavigationController *)createNavigationWithController: (UIViewController *)viewController {
    UINavigationController *navigationVC = [[UINavigationController alloc] initWithRootViewController: viewController];
    navigationVC.navigationBar.barTintColor = IPAD_HEADER_BG_COLOR;
    navigationVC.navigationBar.translucent = NO;
    navigationVC.navigationBar.tintColor = UIColor.whiteColor;
    navigationVC.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:UIColor.whiteColor forKey:NSForegroundColorAttributeName];
    return navigationVC;
}

@end
