//
//  AppUtils.h
//  linphone
//
//  Created by admin on 11/5/17.
//
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBook/ABRecord.h>

#import "ContactObject.h"
#import "LinphoneAppDelegate.h"
#import "MessageEvent.h"
#import "XMPPRoom.h"

@interface AppUtils : NSObject

+ (CGSize)getSizeWithText: (NSString *)text withFont: (UIFont *)font;
+ (CGSize)getSizeWithText: (NSString *)text withFont: (UIFont *)font andMaxWidth: (float )maxWidth;

//  Hàm random ra chuỗi ký tự bất kỳ với length tuỳ ý
+ (NSString *)randomStringWithLength: (int)len;

//  get giá trị ngày giờ hiện tại
+ (NSString *)getCurrentDateTime;

/* Kiểm tra folder cho view chat */
+ (void)checkFolderToSaveFileInViewChat;

+ (UIFont *)fontRegularWithSize: (float)fontSize;

+ (UIFont *)fontBoldWithSize: (float)fontSize;

+ (NSString *)convertUTF8StringToString: (NSString *)string;
+ (NSString *)getAvatarFromContactPerson: (ABRecordRef)person;

+ (NSString *)checkTodayForHistoryCall: (NSString *)dateStr;
+ (NSString *)checkYesterdayForHistoryCall: (NSString *)dateStr;

+ (NSString *)getCurrentDate;
/* Lấy thời gian hiện tại cho message */
+ (NSString *)getCurrentTime;

+ (NSString *)getCurrentTimeStamp;

+ (NSString *)getCurrentTimeStampNotSeconds;

/* Get UDID of device */
+ (NSString*)uniqueIDForDevice;

+ (NSString *)convertUTF8CharacterToCharacter: (NSString *)parentStr;
+ (NSString *)getNameForSearchOfConvertName: (NSString *)convertName;

/*--Hàm crop một ảnh với kích thước--*/
+ (UIImage*)cropImageWithSize:(CGSize)targetSize fromImage: (UIImage *)sourceImage;
+ (ContactObject *)getContactWithId: (int)idContact;

+ (NSString *)getSipFoneIDFromString: (NSString *)string;

+ (void)createLocalNotificationWithAlertBody: (NSString *)alertBodyStr andInfoDict: (NSDictionary *)infoDict ofUser: (NSString *)user;

/* Xoá file details của message */
+ (void)deleteDetailsFileOfMessage: (NSString *)typeMessage andDetails: (NSString *)detail andThumb: (NSString *)thumb;

// Lấy buddy trong roster list
+ (OTRBuddy *)getBuddyOfUserOnList: (NSString *)callnexUser;
+ (NSString *)getAccountNameFromString: (NSString *)string;

/*----- KIỂM TRA LOẠI CỦA FILE ĐANG NHẬN -----*/
+ (NSString *)checkFileExtension: (NSString *)fileName;

// Hàm crop image từ 1 image
+ (UIImage *)squareImageWithImage:(UIImage *)sourceImage withSizeWidth:(CGFloat)sideLength;

// Chuyển chuỗi có emotion thành code emoji
+ (NSMutableAttributedString *)convertMessageStringToEmojiString: (NSString *)messageString;

+ (UIImage *)getImageOfDirectoryWithName: (NSString *)imageName;
+ (void)reconnectToXMPPServer;
+ (NSString *)stringTimeFromInterval: (NSTimeInterval)interval;
+ (NSString *)stringDateFromInterval: (NSTimeInterval)interval;

// get data của hình ảnh với tên file
+ (NSData *)getFileDataOfMessageResend: (NSString *)fileName andFileType: (NSString *)fileType;

// Get string của hình ảnh với tên hình ảnh
+ (NSString *)getImageDataStringOfDirectoryWithName: (NSString *)imageName;

//  Tạo avatar cho group chat
+ (UIImage *)createAvatarForCurrentGroup: (NSArray *)listAvatar;

/*--Hàm save một ảnh từ view--*/
+ (NSData *) makeImageFromView: (UIView *)aView;

//  Tạo một image được crop từ một callnex
+ (UIImage *)createImageFromDataString: (NSString *)strData withCropSize: (CGSize)cropSize;

+ (void)updateBadgeForMessageOfUser: (NSString *)user isIncrease: (BOOL)increase;;

//  Get thông tin của một contact
+ (NSString *)getNameOfContact: (ABRecordRef)aPerson;

//  Get tên (custom label) của contact
+ (NSString *)getNameOfPhoneOfContact: (ABRecordRef)aPerson andPhoneNumber: (NSString *)phoneNumber;

+ (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size;

+ (NSArray *)saveImageToFiles: (UIImage *)imageSend withImage: (NSString *)imageName;

// Ghi video file vào folder document
+ (BOOL)saveVideoToFiles: (NSData *)videoData withName: (NSString *)videoName;

+ (NSString *)getPBXNameWithPhoneNumber: (NSString *)phonenumber;
+ (NSString *)getAvatarOfContact: (int)idContact;

+ (NSString *)getDateStringFromTimeInterval: (double)timeInterval;
+ (NSString *)getTimeStringFromTimeInterval:(double)timeInterval;

+ (UIImage *)getImageDataWithName: (NSString *)imageName;

+ (UIImage *)getImageFromVideo:(NSURL *)videoUrl atTime:(CGFloat)time;
+ (int)getBurnMessageValueOfRemoteParty: (NSString *)remoteParty;
+ (int)getNewMessageValueOfRemoteParty: (NSString *)remoteParty;

//  Kiểm tra setting nhận tin nhắn mới cho toàn bộ remote party
+ (BOOL)getNewMessageValueForSettingsOfAccount: (NSString *)account;
+ (BOOL)getVibrateForMessageForSettingsOfAccount: (NSString *)account;

//  save details and thumbnail image for video message
+ (void)savePictureOfVideoToDocument: (MessageEvent *)message;

//  Lấy status của user
+ (NSArray *)getStatusOfUser: (NSString *)sipPhone;
+ (UIImage *)createAvatarForRoom: (NSString *)roomID withSize: (int)size;
+ (UIImage *)imageWithView:(UIView *)aView withSize: (CGSize)resultSize;
+ (XMPPRoom *) searchRoomFromId:(NSString *)roomId;

+ (NSString *)getDeviceModel;
+ (NSString *)getDeviceNameFromModelName: (NSString *)modelName;
+ (NSString *)getCurrentOSVersionOfDevice;
+ (NSString *)getCurrentVersionApplicaton;
+ (BOOL)soundForCallIsEnable;
+ (UIColor *)randomColorWithAlpha: (float)alpha;
+ (void)sendMessageForOfflineForUser: (NSString *)IDRecipient fromSender: (NSString *)Sender withContent: (NSString *)content andTypeMessage: (NSString *)typeMessage withGroupID: (NSString *)GroupID;

@end
