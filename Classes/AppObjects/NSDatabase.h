//
//  NSDatabase.h
//  linphone
//
//  Created by admin on 11/11/17.
//
//

#import <Foundation/Foundation.h>
#import "ContactObject.h"

@interface NSDatabase : NSObject

/* Connect to database */
+ (BOOL)connectCallnexDB;

/*--Cap nhat tat cac trang thai cua missed call--*/
+ (BOOL)resetAllMissedCallOfUser: (NSString *)user;

/* Get tất cả history call của 1 user */
+ (NSMutableArray *)getHistoryCallListOfUser: (NSString *)mySip isMissed: (BOOL)missed;

/* Get danh sách các cuộc gọi nhỡ trong 1 ngày */
+ (NSMutableArray *)getMissedCallListOnDate: (NSString *)dateStr ofUser: (NSString *)mySip;

/* Get danh sách cho từng section call của user */
+ (NSMutableArray *)getAllCallOnDate: (NSString *)dateStr ofUser: (NSString *)mySip;

//  Get tên file ghi âm của cuộc gọi nếu có
+ (NSString *)getRecordFileNameOfCall: (int)idCall;

/* Hàm xoá 1 record call history trong lịch sử cuộc gọi */
+ (BOOL)deleteRecordCallHistory: (int)idCallRecord withRecordFile: (NSString *)recordFile;

/* Hàm xoá tất cả history calll */
+ (BOOL)deleteAllHistoryCallOfUser: (NSString *)mySip;

+(void) InsertHistory : (NSString *)call_id status : (NSString *)status phoneNumber : (NSString *)phone_number callDirection : (NSString *)callDirection recordFiles : (NSString*) record_files duration : (int)duration date : (NSString *)date time : (NSString *)time time_int : (int)time_int rate : (float)rate sipURI : (NSString*)sipUri MySip : (NSString *)mysip kCallId: (NSString *)kCallId andFlag: (int)flag andUnread: (int)unread;
+ (void)openDB;
+ (void)closeDB;
+ (NSString *)filePath;

+ (NSArray *)getNameAndAvatarOfContactWithPhoneNumber: (NSString *)phonenumber;
+ (NSDictionary *)getProfileInfoOfAccount: (NSString *)account;
+ (NSString *)getAvatarOfAccount: (NSString *)account;
+ (NSString *)getNameOfContactWithPhoneNumber: (NSString *)phonenumber;
+ (NSString *)getAvatarOfContactWithPhoneNumber: (NSString *)phonenumber;

// insert last login cho user
+ (BOOL)insertLastLogoutForUser: (NSString *)account passWord: (NSString *)password andRelogin: (int)relogin;
+ (NSString *)getUserAccountForLastLogin;

//  kiểm tra cloudfoneId có trong blacklist hay ko?
+ (BOOL)checkCloudFoneIDInBlackList: (NSString *)cloudfoneID ofAccount: (NSString *)account ;

+ (NSMutableArray *)getAllListCallOfMe: (NSString *)mySip withPhoneNumber: (NSString *)phoneNumber;

/* Get lịch sử cuộc gọi trong 1 ngày với callDirection */
+ (NSMutableArray *)getAllCallOfMe: (NSString *)mySip withPhone: (NSString *)phoneNumber onDate: (NSString *)dateStr;

+(NSArray *) getAllRowsByCallDirection : (NSString *)direction phone:(NSString *)phoneCall;

//  Xoá lịch sử các cuộc gọi nhỡ của user
+ (BOOL)deleteAllMissedCallOfUser: (NSString *)user;

// Get tất cả các section trong của cuoc goi ghi am của 1 user
+ (NSMutableArray *)getHistoryRecordCallListOfUser: (NSString *)mySip;

// Get danh sách cho từng section call của user
+ (NSMutableArray *)getAllRecordCallOnDate: (NSString *)dateStr ofUser: (NSString *)mySip;

//  Search contact trong danh bạ PBX
+ (void)searchPhoneNumberInPBXContact: (NSString *)searchStr withCurrentList: (NSMutableArray *)currentList;

//  Kiểm tra trùng tên và contact trong phonebook
+ (ContactObject *)checkContactExistsInDatabase: (NSString *)contactName andCloudFone: (NSString *)cloudFoneID;

// Kết nối CSDL cho sync contact
+ (BOOL)connectDatabaseForSyncContact;

/*--Get last call goi di--*/
+ (NSString *)getLastCallOfUser;

// get callnex id cua contact nhan duoc
+ (NSString *)getCallnexIDOfContactReceived: (NSString *)idMessage;

+ (NSData *)getAvatarDataFromCacheFolderForUser: (NSString *)callnexID;

/* get id contact with callnexID (this id of last contact) */
+ (int)getContactIDWithCloudFoneID: (NSString *)cloudFoneID;

/* get contact name */
+ (NSArray *)getContactNameOfCloudFoneID: (NSString *)cloudFoneID;
+ (NSString *)getNameOfPBXPhone: (NSString *)phoneNumber;

// Lấy tên contact theo callnex ID
+ (NSString *)getNameOfContactWithCallnexID: (NSString *)callnexID;

/*--get avatar string của một callnex id--*/
+ (NSString *)getAvatarDataStringOfCallnexID: (NSString *)callnexID;

/*--Hàm trả về tên contact (nếu tồn tại) hoặc callnexID--*/
+ (NSString *)getFullnameOfContactForGroupWithCallnexID: (NSString *)callnexID;

+ (NSString *)getAvatarDataOfAccount: (NSString *)account;
+ (NSString *)getProfielNameOfAccount: (NSString *)account;

+ (NSMutableArray *)getAllCloudFoneContactWithSearch: (NSString *)search;

//  Thêm một contact vào Blacklist
+ (BOOL)addContactToBlacklist: (int)idContact andCloudFoneID: (NSString *)cloudFoneID;

/*----Lấy tất cả user trong Callnex Blacklist----*/
+ (NSMutableArray *)getAllUserInCallnexBlacklist;

// Xoá một contact vào Blacklist
+ (BOOL)removeContactFromBlacklist: (int)idContact andCloudFoneID: (NSString *)cloudFoneID;

@end
