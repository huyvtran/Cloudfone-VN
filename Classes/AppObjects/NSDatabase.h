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

//  Connect to database
+ (BOOL)connectToDatabase;

//  get new missed call from remote
+ (int)getUnreadMissedCallHisotryWithAccount: (NSString *)account;

//  reset missed call with remote on date
+ (BOOL)resetMissedCallOfRemote: (NSString *)remote onDate: (NSString *)date ofAccount: (NSString *)account;

//  Get history call of account
+ (NSMutableArray *)getHistoryCallListOfUser: (NSString *)account isMissed: (BOOL)missed;

//  Delete call history of remote on date
+ (BOOL)deleteCallHistoryOfRemote: (NSString *)remote onDate: (NSString *)date ofAccount: (NSString *)account;

//  Get list missed call of remote in date
+ (NSMutableArray *)getMissedCallListOnDate: (NSString *)dateStr ofUser: (NSString *)account;

//  Get all history call for account
+ (NSMutableArray *)getAllCallOnDate: (NSString *)dateStr ofUser: (NSString *)account;

//  count missed unread with remote
+ (int)getMissedCallUnreadWithRemote: (NSString *)remote onDate: (NSString *)date ofAccount: (NSString *)account;

+(void) InsertHistory : (NSString *)call_id status : (NSString *)status phoneNumber : (NSString *)phone_number callDirection : (NSString *)callDirection recordFiles : (NSString*) record_files duration : (int)duration date : (NSString *)date time : (NSString *)time time_int : (int)time_int rate : (float)rate sipURI : (NSString*)sipUri MySip : (NSString *)mysip kCallId: (NSString *)kCallId andFlag: (int)flag andUnread: (int)unread;
+ (void)openDB;
+ (void)closeDB;
+ (NSString *)filePath;

<<<<<<< HEAD
+ (NSMutableArray *)getAllListCallOfMe: (NSString *)account withPhoneNumber: (NSString *)phoneNumber;
=======
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
>>>>>>> parent of b27140b1... Custom switch button

/* Get lịch sử cuộc gọi trong 1 ngày với callDirection */
+ (NSMutableArray *)getAllCallOfMe: (NSString *)mySip withPhone: (NSString *)phoneNumber onDate: (NSString *)dateStr;

/*--Get last call goi di--*/
+ (NSString *)getLastCallOfUser;

+ (NSDictionary *)getCallInfoWithHistoryCallId: (int)callId;
+ (BOOL)removeHistoryCallsOfUser: (NSString *)user onDate: (NSString *)date ofAccount: (NSString *)account;
+ (BOOL)checkMissedCallExistsWithPhoneNumber: (NSString *)phonenumber atTime: (long)time offAccount: (NSString *)account;

@end
