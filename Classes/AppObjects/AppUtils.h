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
#import "PBXContact.h"
#import "ContactObject.h"

@interface AppUtils : NSObject

+ (CGSize)getSizeWithText: (NSString *)text withFont: (UIFont *)font;
+ (CGSize)getSizeWithText: (NSString *)text withFont: (UIFont *)font andMaxWidth: (float )maxWidth;

//  Hàm random ra chuỗi ký tự bất kỳ với length tuỳ ý
+ (NSString *)randomStringWithLength: (int)len;

//  get giá trị ngày giờ hiện tại
+ (NSString *)getCurrentDateTime;
+ (NSString *)getCurrentDateTimeToStringWithLanguage: (NSString *)lang;
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
+ (void)createLocalNotificationWithAlertBody: (NSString *)alertBodyStr andInfoDict: (NSDictionary *)infoDict ofUser: (NSString *)user;

// Hàm crop image từ 1 image
+ (UIImage *)squareImageWithImage:(UIImage *)sourceImage withSizeWidth:(CGFloat)sideLength;
+ (NSString *)stringTimeFromInterval: (NSTimeInterval)interval;
+ (NSString *)stringDateFromInterval: (NSTimeInterval)interval;



/*--Hàm save một ảnh từ view--*/
+ (NSData *) makeImageFromView: (UIView *)aView;

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

+ (UIImage *)getImageDataWithName: (NSString *)imageName;

//  Lấy status của user
+ (UIImage *)imageWithView:(UIView *)aView withSize: (CGSize)resultSize;

+ (NSString *)getDeviceModel;
+ (NSString *)getDeviceNameFromModelName: (NSString *)modelName;
+ (NSString *)getCurrentOSVersionOfDevice;
+ (NSString *)getCurrentVersionApplicaton;
+ (BOOL)soundForCallIsEnable;
+ (UIColor *)randomColorWithAlpha: (float)alpha;

//  Added by Khai Le on 04/10/2018
+ (void)addCornerRadiusTopLeftAndBottomLeftForButton: (id)view radius: (float)radius withColor: (UIColor *)borderColor border: (float)borderWidth;
+ (void)addCornerRadiusTopRightAndBottomRightForButton: (id)view radius: (float)radius withColor: (UIColor *)borderColor border: (float)borderWidth;

// Remove all special characters from string
+ (NSString *)removeAllSpecialInString: (NSString *)phoneString;

+ (NSString *)getDateStringFromTimeInterval: (double)timeInterval;
+ (NSString *)getTimeStringFromTimeInterval:(double)timeInterval;

//  Get first name and last name of contact
+ (NSArray *)getFirstNameAndLastNameOfContact: (ABRecordRef)aPerson;
+(BOOL)isNullOrEmpty:(NSString*)string;
+ (NSString *)getAppVersionWithBuildVersion: (BOOL)showBuildVersion;
+ (UIImage *)imageWithColor:(UIColor *)color andBounds:(CGRect)imgBounds;
+ (NSAttributedString *)getVersionStringForApp;
+ (BOOL)saveFileToFolder: (NSData *)fileData withName: (NSString *)fileName;
+ (NSData *)getFileDataFromDirectoryWithFileName: (NSString *)fileName;
+ (PBXContact *)getPBXContactFromListWithPhoneNumber: (NSString *)pbxPhone;

+ (NSString *)getBuildDate;
+(NSDateFormatter*) historyEventDate;
+ (NSString *)getDateFromInterval: (double)interval;
+ (NSString *)getFullTimeStringFromTimeInterval:(double)timeInterval;

+ (NSString *)convertDurtationToString: (long)duration;

+ (UINavigationController *)createNavigationWithController: (UIViewController *)viewController;
+ (void)showDetailViewWithController: (UIViewController *)detailVC;
+ (void)setSelected: (BOOL)selected forButton: (UIButton *)button;
+ (NSString *)getTypeOfPhone: (NSString *)typePhone;

@end
