//
//  AppFunctions.h
//  linphone
//
//  Created by Hung Ho on 7/4/17.
//
//

#import <Foundation/Foundation.h>
//  Leo Kelvin
//  #import "OTRBuddy.h"

@interface AppFunctions : NSObject

+ (CGSize)getSizeWithText: (NSString *)text withFont: (UIFont *)font;
+ (CGSize)getSizeWithText: (NSString *)text withFont: (UIFont *)font andMaxWidth: (float )maxWidth;

//  Hàm random ra chuỗi ký tự bất kỳ với length tuỳ ý
+ (NSString *)randomStringWithLength: (int)len;

//  get giá trị ngày giờ hiện tại
+ (NSString *)getCurrentDateTime;

/* Kiểm tra folder cho view chat */
+ (void)checkFolderToSaveFileInViewChat;

+ (NSString *)convertUTF8CharacterToCharacter: (NSString *)parentStr;
+ (NSString *)getNameForSearchOfConvertName: (NSString *)convertName;
+ (NSString *)convertUTF8StringToString: (NSString *)string;

//  Lấy status của user
+ (NSArray *)getStatusOfUser: (NSString *)callnexUser;

+ (NSString *)checkTodayForHistoryCall: (NSString *)dateStr;
+ (NSString *)checkYesterdayForHistoryCall: (NSString *)dateStr;

+ (NSString *)getCurrentDate;

+ (NSString *)getCurrentTimeStamp;

+ (NSString *)getCurrentTimeStampNotSeconds;

/* Get UDID of device */
+ (NSString*)uniqueIDForDevice;

+ (NSString *)getCloudFoneIDFromString: (NSString *)string;

+ (void)createLocalNotificationWithAlertBody: (NSString *)alertBodyStr andInfoDict: (NSDictionary *)infoDict ofUser: (NSString *)user;

+ (void)reconnectToXMPPServer;

// Chuyển chuỗi có emotion thành code emoji
+ (NSMutableAttributedString *)convertMessageStringToEmojiString: (NSString *)messageString;

+ (void)updateBadgeForMessageOfUser: (NSString *)user isIncrease: (BOOL)increase;;

// Lấy buddy trong roster list
//  Leo Kelvin
//  + (OTRBuddy *)getBuddyOfUserOnList: (NSString *)cloudfone;

/*----- KIỂM TRA LOẠI CỦA FILE ĐANG NHẬN -----*/
+ (NSString *)checkFileExtension: (NSString *)fileName;

// Hàm crop image từ 1 image
+ (UIImage *)squareImageWithImage:(UIImage *)sourceImage withSizeWidth:(CGFloat)sideLength;

/* Xoá file details của message */
+ (void)deleteDetailsFileOfMessage: (NSString *)typeMessage andDetails: (NSString *)detail andThumb: (NSString *)thumb;

// Get trạng thái của user
+ (int)getStatusNumberOfUserOnList: (NSString *)callnexUser;

/* Lấy thời gian hiện tại cho message */
+ (NSString *)getCurrentTime;

+ (NSString *)stringDateFromInterval: (NSTimeInterval)interval;
+ (NSString *)stringTimeFromInterval: (NSTimeInterval)interval;

//  Get avatar của user
+ (NSData *)getMyAvatarData;

+ (UIImage *)getImageOfDirectoryWithName: (NSString *)imageName;

// Get string của hình ảnh với tên hình ảnh
+ (NSString *)getImageDataStringOfDirectoryWithName: (NSString *)imageName;

//  Copy file record, sau đó save với tên và trả về data của file mới
+ (NSData *)getAudioFileFromFile: (NSString *)audioFileName andSaveWithName: (NSString *)nameToSave;

/*---Get trạng thái của user---*/
+ (NSString *)getStatusStringOfUserOnList: (NSString *)callnexUser;

//  Trả về ảnh trong thư mục document
+ (UIImage *)getImageWithName: (NSString *)imageName;

//  Tạo avatar cho group chat
+ (UIImage *)createAvatarForCurrentGroup: (NSArray *)listAvatar;

//  Tạo một image được crop từ một callnex
+ (UIImage *)createImageFromDataString: (NSString *)strData withCropSize: (CGSize)cropSize;

/*--Hàm save một ảnh từ view--*/
+ (NSData *) makeImageFromView: (UIView *)aView;

/*--Hàm crop một ảnh với kích thước--*/
+ (UIImage*)cropImageWithSize:(CGSize)targetSize fromImage: (UIImage *)sourceImage;

+ (NSString *)getAccountNameFromString: (NSString *)string;

+ (BOOL)isIpad;

@end
