//
//  NSDatabase.m
//  linphone
//
//  Created by admin on 11/11/17.
//
//

#import "NSDatabase.h"
#import "KHistoryCallObject.h"
#import "CallHistoryObject.h"
#import "PhoneBookObject.h"
#import "PBXContact.h"
#import "NSData+Base64.h"
#import <MediaPlayer/MediaPlayer.h>
#import "contactBlackListCell.h"
#import "FriendRequestedObject.h"

static sqlite3 *db = nil;

LinphoneAppDelegate *appDelegate;
HMLocalization *localization;

@implementation NSDatabase

+ (BOOL)connectCallnexDB{
    appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    localization = [HMLocalization sharedInstance];
    
    if (appDelegate._databasePath.length > 0) {
        appDelegate._database = [[FMDatabase alloc] initWithPath: appDelegate._databasePath];
        if ([appDelegate._database open]) {
            return YES;
        }else{
            return NO;
        }
    }else{
        return NO;
    }
}

/*--Cap nhat tat cac trang thai cua missed call--*/
+ (BOOL)resetAllMissedCallOfUser: (NSString *)user
{
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE history SET unread = %d WHERE my_sip = '%@' AND unread = %d", 0, user, 1];
    return [appDelegate._database executeUpdate: tSQL];
}

// Get tất cả các section trong của history call của 1 user
+ (NSMutableArray *)getHistoryCallListOfUser: (NSString *)mySip isMissed: (BOOL)missed {
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT date FROM history WHERE my_sip = '%@' GROUP BY date ORDER BY _id DESC", mySip];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *dateStr = [rsDict objectForKey:@"date"];
        
        // Dict chứa dữ liệu cho từng ngày
        NSMutableDictionary *oneDateDict = [[NSMutableDictionary alloc] init];
        [oneDateDict setObject:dateStr forKey:@"title"];
        if (missed) {
            NSMutableArray *missedArr = [self getMissedCallListOnDate:dateStr ofUser:mySip];
            if (missedArr.count > 0) {
                [oneDateDict setObject:missedArr forKey:@"rows"];
                [resultArr addObject: oneDateDict];
            }
        }else{
            NSMutableArray *callArray = [self getAllCallOnDate:dateStr ofUser:mySip];
            if (callArray.count > 0) {
                [oneDateDict setObject:callArray forKey:@"rows"];
                [resultArr addObject: oneDateDict];
            }
        }
    }
    [rs close];
    return resultArr;
}

// Get danh sách các cuộc gọi nhỡ
+ (NSMutableArray *)getMissedCallListOnDate: (NSString *)dateStr ofUser: (NSString *)mySip{
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM history WHERE my_sip = '%@' AND call_direction = 'Incomming' AND status = 'Missed' AND date = '%@' GROUP BY phone_number ORDER BY _id DESC", mySip, dateStr];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        KHistoryCallObject *aCall = [[KHistoryCallObject alloc] init];
        int callId        = [[rsDict objectForKey:@"_id"] intValue];
        NSString *status        = [rsDict objectForKey:@"status"];
        NSString *phoneNumber = [rsDict objectForKey:@"phone_number"];
        //NSArray *phoneInfo = [self changePhoneMobileWithSavingCall: [rsDict objectForKey:@"phone_number"]];
        //NSString *prefixStr = [phoneInfo objectAtIndex: 0];
        //NSString *phoneNumber   = [phoneInfo objectAtIndex: 1];
        
        NSString *callDirection = [rsDict objectForKey:@"call_direction"];
        NSString *callTime      = [rsDict objectForKey:@"time"];
        NSString *callDate      = [rsDict objectForKey:@"date"];
        NSArray *infos = [self getNameAndAvatarOfContactWithPhoneNumber: phoneNumber];
        
        aCall._callId = callId;
        aCall._status = status;
        aCall._prefixPhone = @"";
        aCall._phoneNumber = phoneNumber;
        aCall._callDirection = callDirection;
        aCall._callTime = callTime;
        aCall._callDate = callDate;
        aCall._phoneName = [infos objectAtIndex: 0];
        aCall._phoneAvatar = [infos objectAtIndex: 1];
        
        [resultArr addObject: aCall];
    }
    return resultArr;
}

// Get danh sách cho từng section call của user
+ (NSMutableArray *)getAllCallOnDate: (NSString *)dateStr ofUser: (NSString *)mySip{
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM history WHERE my_sip = '%@' AND date = '%@' GROUP BY phone_number ORDER BY _id DESC", mySip, dateStr];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        KHistoryCallObject *aCall = [[KHistoryCallObject alloc] init];
        int callId        = [[rsDict objectForKey:@"_id"] intValue];
        NSString *status        = [rsDict objectForKey:@"status"];
        NSString *callDirection = [rsDict objectForKey:@"call_direction"];
        NSString *callTime      = [rsDict objectForKey:@"time"];
        NSString *callDate      = [rsDict objectForKey:@"date"];
        NSString *phoneNumber   = [rsDict objectForKey:@"phone_number"];
        
        aCall._prefixPhone = @"";
        aCall._phoneNumber = phoneNumber;
        
        NSArray *infos = [self getNameAndAvatarOfContactWithPhoneNumber: phoneNumber];
        aCall._callId = callId;
        aCall._status = status;
        aCall._callDirection = callDirection;
        aCall._callTime = callTime;
        aCall._callDate = callDate;
        aCall._phoneName = [infos objectAtIndex: 0];
        aCall._phoneAvatar = [infos objectAtIndex: 1];
        aCall.duration = [[rsDict objectForKey:@"duration"] intValue];
        
        [resultArr addObject: aCall];
    }
    [rs close];
    return resultArr;
}

//  Get tên file ghi âm của cuộc gọi nếu có
+ (NSString *)getRecordFileNameOfCall: (int)idCall {
    NSString *recordFile = @"";
    NSString *tSQL = [NSString stringWithFormat:@"SELECT record_files FROM history WHERE _id = %d", idCall];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        recordFile = [rsDict objectForKey:@"record_files"];
    }
    [rs close];
    return recordFile;
}

//  Hàm xoá 1 record call history trong lịch sử cuộc gọi
+ (BOOL)deleteRecordCallHistory: (int)idCallRecord withRecordFile: (NSString *)recordFile {
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM history WHERE _id = %d", idCallRecord];
    if (![recordFile isEqualToString: @""] && ![recordFile isEqualToString:@"0"]) {
        [self removeRecordFileOfCall: recordFile];
    }
    BOOL result = [appDelegate._database executeUpdate: tSQL];
    return result;
}

+ (void)removeRecordFileOfCall:(NSString *)filename
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/%@", folder_call_records, filename]];
    if ([fileManager fileExistsAtPath: filePath]) {
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:filePath error:&error];
        if (success) {
            NSLog(@"---Xoa file ghi am thanh cong");
        }else {
            NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
        }
    }else{
        NSLog(@"---File ghi am khong ton tai");
    }
}

//  Hàm xoá tất cả history call
+ (BOOL)deleteAllHistoryCallOfUser: (NSString *)mySip{
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM history WHERE my_sip = '%@'", mySip];
    BOOL result = [appDelegate._database executeUpdate: tSQL];
    return result;
}

+ (void)InsertHistory : (NSString *)call_id status : (NSString *)status phoneNumber : (NSString *)phone_number callDirection : (NSString *)callDirection recordFiles : (NSString*) record_files duration : (int)duration date : (NSString *)date time : (NSString *)time time_int : (int)time_int rate : (float)rate sipURI : (NSString*)sipUri MySip : (NSString *)mysip kCallId: (NSString *)kCallId andFlag: (int)flag andUnread: (int)unread{
    [self openDB];
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO history(call_id,status,phone_number,call_direction,record_files,duration,date,rate,sipURI,time,time_int,my_sip, k_call_id, flag, unread) VALUES ('%@','%@','%@','%@','%@',%d,'%@',%f,'%@','%@',%d,'%@','%@',%d,%d)",call_id,status,phone_number,callDirection,record_files,duration,date,rate,sipUri,time,time_int,mysip, kCallId, flag, unread];
    NSLog(@"%@",sql);
    char *err;
    sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err);
    sqlite3_close(db);
}

+ (void)openDB {
    int result = sqlite3_open([[self filePath] UTF8String], &db);
    if (sqlite3_open([[self filePath] UTF8String], &db) != SQLITE_OK ) {
        //        char *errMsg;
        //
        //        const char *sql_stmt = "CREATE TABLE IF NOT EXISTS \"history\" (\"_id\" INTEGER PRIMARY KEY  NOT NULL ,\"call_id\" TEXT,\"status\" TEXT,\"phone_number\" TEXT,\"call_direction\" TEXT,\"record_files\" TEXT,\"duration\" INTEGER,\"date\" TEXT DEFAULT (null) ,\"rate\" INTEGER,\"sipURI\" TEXT,\"time\" TEXT, \"time_int\" INTEGER, \"my_sip\" TEXT)";
        //
        //        if (sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
        //        {
        //            NSLog(@"Failed to create table");
        //        }
        NSLog(@"%d", result);
        NSLog(@"Khong mo duoc database.....");
        sqlite3_close(db);
    }
}

+ (void)closeDB {
    sqlite3_close(db);
}

+(NSString *) filePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    return [documentsDir stringByAppendingPathComponent:@"callnex.sqlite"];
}

+ (NSArray *)getNameAndAvatarOfContactWithPhoneNumber: (NSString *)phonenumber
{
    NSString *fullName = @"";
    NSString *avatar = @"";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_sipPhone == %@", phonenumber];
    NSArray *filter = [appDelegate.listContacts filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        ContactObject *aContact = [filter objectAtIndex: 0];
        fullName = aContact._fullName;
        avatar = aContact._avatar;
    }else{
        //  get name pbx truoc
        NSString *pbxName = [AppUtils getPBXNameWithPhoneNumber: phonenumber];
        if ([pbxName isEqualToString:@""]) {
            NSString *stringValue = [appDelegate._allPhonesDict objectForKey: phonenumber];
            if (![stringValue isEqualToString:@""]) {
                NSArray *tmpArr = [stringValue componentsSeparatedByString:@"|"];
                if (tmpArr.count > 0) {
                    NSString *name = [tmpArr objectAtIndex: 0];
                    NSString *idContact = [appDelegate._allIDDict objectForKey: phonenumber];
                    if (name != nil && idContact != nil) {
                        fullName = name;
                        avatar = [AppUtils getAvatarOfContact:[idContact intValue]];
                    }
                }
            }
        }else{
           fullName = pbxName;
        }
    }
    return [NSArray arrayWithObjects:fullName, avatar, nil];
}

+ (NSString *)getNameOfContactWithPhoneNumber: (NSString *)phonenumber
{
    NSString *fullName = @"";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_sipPhone == %@", phonenumber];
    NSArray *filter = [appDelegate.listContacts filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        ContactObject *aContact = [filter objectAtIndex: 0];
        fullName = aContact._fullName;
    }else{
        //  get name pbx truoc
        NSString *pbxName = [AppUtils getPBXNameWithPhoneNumber: phonenumber];
        if ([pbxName isEqualToString:@""]) {
            NSString *stringValue = [appDelegate._allPhonesDict objectForKey: phonenumber];
            if (![stringValue isEqualToString:@""] && stringValue != nil) {
                NSArray *tmpArr = [stringValue componentsSeparatedByString:@"|"];
                if (tmpArr.count > 0) {
                    NSString *name = [tmpArr objectAtIndex: 0];
                    if (name != nil) {
                        fullName = name;
                    }
                }
            }
        }else{
            fullName = pbxName;
        }
    }
    return fullName;
}

+ (NSString *)getAvatarOfContactWithPhoneNumber: (NSString *)phonenumber
{
    NSString *avatar = @"";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_sipPhone == %@", phonenumber];
    NSArray *filter = [appDelegate.listContacts filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        ContactObject *aContact = [filter objectAtIndex: 0];
        avatar = aContact._avatar;
    }else{
        for (int iCount=0; iCount<appDelegate.listContacts.count; iCount++) {
            ContactObject *contact = [appDelegate.listContacts objectAtIndex: iCount];
            predicate = [NSPredicate predicateWithFormat:@"_valueStr = %@", phonenumber];
            filter = [contact._listPhone filteredArrayUsingPredicate: predicate];
            if (filter.count > 0) {
                avatar = contact._avatar;
                break;
            }
        }
    }
    return avatar;
}

+ (NSDictionary *)getProfileInfoOfAccount: (NSString *)account
{
    NSDictionary *rsDict;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM profile WHERE account = '%@'", account];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        rsDict = [rs resultDictionary];
    }
    [rs close];
    return rsDict;
}

+ (NSString *)getAvatarOfAccount: (NSString *)account
{
    NSString *avatar;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT avatar FROM profile WHERE account = '%@'", account];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        avatar = [rsDict objectForKey:@"avatar"];
    }
    [rs close];
    return avatar;
}

// insert last login cho user
+ (BOOL)insertLastLogoutForUser: (NSString *)account passWord: (NSString *)password andRelogin: (int)relogin {
    [appDelegate._database beginTransaction];
    
    NSString *delSQL = [NSString stringWithFormat:@"DELETE FROM last_logout"];
    BOOL result = [appDelegate._database executeUpdate: delSQL];
    if (result) {
        NSString *newSQL = [NSString stringWithFormat:@"INSERT INTO last_logout(account, password, relogin) VALUES ('%@', '%@', %d)", account, password, relogin];
        result = [appDelegate._database executeUpdate: newSQL];
    }
    if (!result) {
        [appDelegate._database rollback];
    }
    [appDelegate._database commit];
    return result;
}

+ (NSString *)getUserAccountForLastLogin {
    NSString *userId = @"";
    NSString *tSQL = @"SELECT account FROM last_logout LIMIT 0,1";
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        userId = [rsDict objectForKey:@"account"];
    }
    [rs close];
    return userId;
}

//  kiểm tra cloudfoneId có trong blacklist hay ko?
+ (BOOL)checkCloudFoneIDInBlackList: (NSString *)cloudfoneID ofAccount: (NSString *)account {
    BOOL result = false;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM group_members WHERE id_group = %d AND callnex_id = '%@' AND account = '%@' LIMIT 0,1", 0, cloudfoneID, account];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        result = true;
        break;
    }
    [rs close];
    return result;
}

// Get danh sách cuộc gọi với một số
+ (NSMutableArray *)getAllListCallOfMe: (NSString *)mySip withPhoneNumber: (NSString *)phoneNumber{
    
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    
    NSString *dateSQL = @"";
    // Viết câu truy vấn cho get hotline history
    if ([phoneNumber isEqualToString: hotline]) {
        dateSQL = [NSString stringWithFormat:@"SELECT date FROM history WHERE my_sip='%@' AND phone_number = '%@' GROUP BY date ORDER BY _id DESC", mySip, phoneNumber];
    }else{
        dateSQL = [NSString stringWithFormat:@"SELECT date FROM history WHERE my_sip='%@' AND phone_number LIKE '%%%@%%' GROUP BY date ORDER BY _id DESC", mySip, phoneNumber];
    }
    
    FMResultSet *rs = [appDelegate._database executeQuery: dateSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *dateStr = [rsDict objectForKey:@"date"];
        
        CallHistoryObject *aCall = [[CallHistoryObject alloc] init];
        aCall._date = dateStr;
        aCall._rate = -1;
        aCall._duration = -1;
        [resultArr addObject: aCall];
        [resultArr addObjectsFromArray:[self getAllCallOfMe:mySip withPhone:phoneNumber onDate:dateStr]];
    }
    [rs close];
    return resultArr;
}

+ (NSMutableArray *)getAllCallOfMe: (NSString *)mySip withPhone: (NSString *)phoneNumber onDate: (NSString *)dateStr{
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    
    NSString *tSQL = @"";
    // Viết câu truy vấn cho get hotline history
    if ([phoneNumber isEqualToString: hotline]) {
        tSQL = [NSString stringWithFormat:@"SELECT * FROM history WHERE my_sip='%@' AND phone_number = '%@' AND date='%@' ORDER BY _id DESC", mySip, phoneNumber, dateStr];
    }else{
        tSQL = [NSString stringWithFormat:@"SELECT * FROM history WHERE my_sip='%@' AND phone_number LIKE '%%%@%%' AND date='%@' ORDER BY _id DESC", mySip, phoneNumber, dateStr];
    }
    
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        
        NSString *time = [rsDict objectForKey:@"time"];
        NSString *status = [rsDict objectForKey:@"status"];
        int duration = [[rsDict objectForKey:@"duration"] intValue];
        float rate = [[rsDict objectForKey:@"rate"] floatValue];
        NSString *call_direction = [rsDict objectForKey:@"call_direction"];
        
        CallHistoryObject *aCall = [[CallHistoryObject alloc] init];
        aCall._time = time;
        aCall._status= status;
        aCall._duration = duration;
        aCall._rate = rate;
        aCall._date = @"date";
        aCall._callDirection = call_direction;
        
        [resultArr addObject: aCall];
    }
    [rs close];
    return resultArr;
}

+(NSArray *) getAllRowsByCallDirection : (NSString *)direction phone:(NSString *)phoneCall{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    [self openDB];
    NSString *sql = [NSString stringWithFormat:@"SELECT distinct date FROM history WHERE phone_number = '%@' AND my_sip = '%@' AND call_direction = '%@' ORDER BY time_int DESC",phoneCall,USERNAME,direction];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2( db, [sql UTF8String], -1,
                           &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *field1 = (char *) sqlite3_column_text(statement, 0);
            NSString *date = [[NSString alloc] initWithUTF8String: field1];
            [tempArray addObject:date];
            NSString *qsql = [NSString stringWithFormat:@"SELECT time_int,duration,rate,status FROM history WHERE phone_number = '%@' AND my_sip = '%@' AND call_direction = '%@' AND date='%@' ORDER BY time_int DESC",phoneCall,USERNAME,direction,date];
            sqlite3_stmt *statement1;
            if (sqlite3_prepare_v2( db, [qsql UTF8String], -1,
                                   &statement1, nil) == SQLITE_OK)
            {
                while (sqlite3_step(statement1) == SQLITE_ROW) {
                    char *fieldn1 = (char *) sqlite3_column_text(statement1, 0);
                    NSString *field1Str = [[NSString alloc] initWithUTF8String: fieldn1];
                    char *fieldn2 = (char *) sqlite3_column_text(statement1, 1);
                    NSString *field2Str = [[NSString alloc] initWithUTF8String: fieldn2];
                    char *fieldn3 = (char *) sqlite3_column_text(statement1, 2);
                    NSString *field3Str = [[NSString alloc] initWithUTF8String: fieldn3];
                    char *fieldn4 = (char *) sqlite3_column_text(statement1, 3);
                    NSString *field4Str = [[NSString alloc] initWithUTF8String: fieldn4];
                    
                    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init] ;
                    [dictionary setValue:field1Str forKey:@"time_int"];
                    [dictionary setValue:field2Str forKey:@"duration"];
                    [dictionary setValue:field3Str forKey:@"rate"];
                    [dictionary setValue:field4Str forKey:@"status"];
                    [tempArray addObject:dictionary];
                }
                sqlite3_finalize(statement1);
            }
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(db);
    return [NSArray arrayWithArray:tempArray];
}

//  Xoá lịch sử các cuộc gọi nhỡ của user
+ (BOOL)deleteAllMissedCallOfUser: (NSString *)user {
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM history WHERE my_sip = '%@' AND call_direction = 'Incomming' AND status = 'Missed'", user];
    return [appDelegate._database executeUpdate:tSQL];
}

// Get tất cả các section trong của cuoc goi ghi am của 1 user
+ (NSMutableArray *)getHistoryRecordCallListOfUser: (NSString *)mySip {
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT date FROM history WHERE my_sip = '%@' GROUP BY date ORDER BY _id DESC", mySip];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *dateStr = [rsDict objectForKey:@"date"];
        
        // Dict chứa dữ liệu cho từng ngày
        NSMutableDictionary *oneDateDict = [[NSMutableDictionary alloc] init];
        [oneDateDict setObject:dateStr forKey:@"title"];
        
        NSMutableArray *callArray = [self getAllRecordCallOnDate:dateStr ofUser:mySip];
        if (callArray.count > 0) {
            [oneDateDict setObject:callArray forKey:@"rows"];
            [resultArr addObject: oneDateDict];
        }
    }
    [rs close];
    return resultArr;
}

// Get danh sách cho từng section call của user

+ (NSMutableArray *)getAllRecordCallOnDate: (NSString *)dateStr ofUser: (NSString *)mySip{
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM history WHERE my_sip = '%@' AND date = '%@' AND record_files != '%@' AND record_files != '%@' ORDER BY _id DESC", mySip, dateStr, @"", @"0"];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        KHistoryCallObject *aCall = [[KHistoryCallObject alloc] init];
        int callId        = [[rsDict objectForKey:@"_id"] intValue];
        NSString *status        = [rsDict objectForKey:@"status"];
        NSString *callDirection = [rsDict objectForKey:@"call_direction"];
        NSString *callTime      = [rsDict objectForKey:@"time"];
        NSString *callDate      = [rsDict objectForKey:@"date"];
        NSString *phoneNumber = [rsDict objectForKey:@"phone_number"];
        
        aCall._prefixPhone = @"";
        aCall._phoneNumber = phoneNumber;
        NSArray *infos = [self getNameAndAvatarOfContactWithPhoneNumber: aCall._phoneNumber];
        aCall._callId = callId;
        aCall._status = status;
        aCall._callDirection = callDirection;
        aCall._callTime = callTime;
        aCall._callDate = callDate;
        aCall._phoneName = [infos objectAtIndex: 0];
        aCall._phoneAvatar = [infos objectAtIndex: 1];
        
        [resultArr addObject: aCall];
    }
    [rs close];
    return resultArr;
}

//  Search contact trong danh bạ PBX
+ (void)searchPhoneNumberInPBXContact: (NSString *)searchStr withCurrentList: (NSMutableArray *)currentList {
    // Search theo ten bat dau truoc
    NSString *beginSQL = [NSString stringWithFormat:@"SELECT * FROM pbx_contacts WHERE (number LIKE '%@%%' OR number LIKE '%%%@' OR number LIKE '%%%@%%' OR name LIKE '%@%%' OR name LIKE '%%%@' OR name LIKE '%%%@%%')", searchStr, searchStr, searchStr, searchStr, searchStr, searchStr];
    FMResultSet *rs = [appDelegate._database executeQuery: beginSQL];
    
    while ([rs next]) {
        //  CREATE TABLE "pbx_contacts" ("id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , "account" VARCHAR, "number" VARCHAR NOT NULL , "name" VARCHAR)
        
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *phoneNumber   = [rsDict objectForKey:@"number"];
        NSString *fullName     = [rsDict objectForKey:@"name"];
        
        PhoneBookObject *aContact = [[PhoneBookObject alloc] init];
        [aContact set_pbName: fullName];
        [aContact set_isCloudFone: false];
        [aContact set_pbPhone: phoneNumber];
        [aContact set_pbAvatar: @""];
        [aContact set_idContact: -1];
        [aContact set_pbNameForSearch: @""];
        [currentList addObject: aContact];
    }
    [rs close];
}

//  Kiểm tra trùng tên và contact trong phonebook
+ (ContactObject *)checkContactExistsInDatabase: (NSString *)contactName andCloudFone: (NSString *)cloudFoneID {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_fullName = %@ AND _sipPhone = %@", contactName, cloudFoneID];
    NSArray *filter = [appDelegate.listContacts filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        return [filter firstObject];
    }
    return nil;
}

// Kết nối csdl cho sync contact
+ (BOOL)connectDatabaseForSyncContact{
    appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate._databasePath.length > 0) {
        appDelegate._threadDatabase = [[FMDatabase alloc] initWithPath: appDelegate._databasePath];
        if ([appDelegate._threadDatabase open]) {
            return YES;
        }else{
            return NO;
        }
    }else{
        return NO;
    }
}

// Lấy số phone cuối cùng gọi đi
+ (NSString *)getLastCallOfUser {
    NSString *phone = @"";
    NSString *tSQL = [NSString stringWithFormat:@"SELECT phone_number FROM history WHERE my_sip = '%@' AND call_direction = '%@' ORDER BY _id DESC LIMIT 0,1", USERNAME, outgoing_call];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        phone = [rsDict objectForKey:@"phone_number"];
        if (phone.length > 3) {
            NSString *headerPrefix = [phone substringToIndex: 3];
            if ([headerPrefix isEqualToString:@"sv-"]) {
                phone = [phone substringFromIndex: 3];
            }else{
                NSRange range = [phone rangeOfString:@",,"];
                if (range.location != NSNotFound) {
                    NSString *tmpStr = [phone substringFromIndex: range.location+range.length];
                    phone = [tmpStr substringToIndex: tmpStr.length-1];
                }
            }
        }
    }
    [rs close];
    return phone;
}

//  Kiểm tra user có nằm trong danh sách tắt thông báo hay không
+ (BOOL)checkUserExistsInMuteNotificationsList: (NSString *)user {
    BOOL result = false;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT mutes FROM conversation WHERE account = '%@' AND user = '%@' LIMIT 0,1", USERNAME, user];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        int mutes = [[rsDict objectForKey:@"mutes"] intValue];
        if (mutes == 0) {
            result = false;
        }else{
            result = true;
        }
    }
    [rs close];
    return result;
}


// get callnex id cua contact nhan duoc
+ (NSString *)getCallnexIDOfContactReceived: (NSString *)idMessage{
    NSString *callnexID = @"";
    NSString *tSQL = [NSString stringWithFormat:@"SELECT content FROM message WHERE id_message = '%@' LIMIT 0,1", idMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *content = [rsDict objectForKey:@"content"];
        if (![content isEqualToString:@""]) {
            content = [content stringByReplacingOccurrencesOfString:@"{" withString:@""];
            content = [content stringByReplacingOccurrencesOfString:@"}" withString:@""];
            content = [content stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            content = [content stringByReplacingOccurrencesOfString:@"," withString:@":"];
            
            NSArray *tmpArr = [content componentsSeparatedByString:@":"];
            for (int iCount=0; iCount<tmpArr.count-1; iCount++) {
                NSString *key = [tmpArr objectAtIndex: iCount];
                if ([key isEqualToString:@"callnexId"]) {
                    if (iCount < tmpArr.count-1) {
                        callnexID = [tmpArr objectAtIndex: iCount+1];
                        break;
                    }
                }
            }
        }
    }
    [rs close];
    return callnexID;
}

+ (NSData *)getAvatarDataFromCacheFolderForUser: (NSString *)callnexID {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pathFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/avatars/%@.jpg", callnexID]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath: pathFile];
    
    if (!fileExists) {
        return nil;
    }else{
        NSData *dataImage = [NSData dataWithContentsOfFile: pathFile];
        return dataImage;
    }
}

/*--Hàm trả về id của contact tương ứng với callnexID (contact có id sau cùng)--*/
+ (int)getContactIDWithCloudFoneID: (NSString *)cloudFoneID {
    int idContact = idContactUnknown;
    BOOL isCloundFoneID = false;
    
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id_contact FROM contact WHERE callnex_id = '%@' ORDER BY id_contact DESC LIMIT 0,1", cloudFoneID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        idContact = [[rsDict objectForKey:@"id_contact"] intValue];
        isCloundFoneID = true;
    }
    [rs close];
    
    if (!isCloundFoneID) {
        NSString *tSQL2 = [NSString stringWithFormat:@"SELECT id_contact FROM contact_phone_number WHERE phone_number = '%@' ORDER BY id DESC LIMIT 0,1", cloudFoneID];
        FMResultSet *rs2 = [appDelegate._database executeQuery: tSQL2];
        while ([rs2 next]) {
            NSDictionary *rsDict2 = [rs2 resultDictionary];
            idContact = [[rsDict2 objectForKey:@"id_contact"] intValue];
        }
        [rs2 close];
    }
    return idContact;
}

//  Lấy thông tin contact name và avatar image
+ (NSArray *)getContactNameOfCloudFoneID: (NSString *)cloudFoneID {
    NSString *name = [NSDatabase getNameOfPBXPhone: cloudFoneID];
    if (![name isEqualToString: @""]) {
        return [[NSArray alloc] initWithObjects: name, @"", nil];
    }else{
        NSString *tSQL = [NSString stringWithFormat:@"SELECT first_name, last_name, avatar FROM contact WHERE callnex_id = '%@' ORDER BY id_contact DESC LIMIT 0,1", cloudFoneID];
        FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
        NSString *fullName = @"";
        NSString *firstName;
        NSString *lastName;
        NSString *avatar = @"";
        
        while ([rs next]) {
            NSDictionary *rsDict = [rs resultDictionary];
            firstName = [rsDict objectForKey:@"first_name"];
            lastName = [rsDict objectForKey:@"last_name"];
            
            if ([firstName isEqualToString:@""] && [lastName isEqualToString:@""]) {
                // do not thing
            }else if (![firstName isEqualToString:@""] && [lastName isEqualToString:@""]){
                fullName = firstName;
            }else if ([firstName isEqualToString:@""] && ![lastName isEqualToString:@""]){
                fullName = lastName;
            }else{
                fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            }
            avatar = [rsDict objectForKey:@"avatar"];
        }
        if ([fullName isEqualToString: @""]) {
            fullName = cloudFoneID;
        }
        [rs close];
        return [[NSArray alloc] initWithObjects:fullName, avatar, nil];
    }
}

+ (NSString *)getNameOfPBXPhone: (NSString *)phoneNumber {
    NSString *name = @"";
    NSString *tSQL = [NSString stringWithFormat:@"SELECT name FROM pbx_contacts WHERE number = '%@' ORDER BY id DESC LIMIT 0,1", phoneNumber];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        name = [rsDict objectForKey:@"name"];
    }
    [rs close];
    return name;
}

// Lấy tên contact theo callnex ID
+ (NSString *)getNameOfContactWithCallnexID: (NSString *)callnexID {
    NSString *fullName = @"";
    
    NSString *tSQL = [NSString stringWithFormat:@"SELECT first_name, last_name FROM contact WHERE callnex_id = '%@' ORDER BY id_contact DESC LIMIT 0,1", callnexID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *firstName = [rsDict objectForKey:@"first_name"];
        NSString *lastName = [rsDict objectForKey:@"last_name"];
        
        if ([firstName isEqualToString: @""] && [lastName isEqualToString: @""]) {
            fullName = callnexID;
        }else if (![firstName isEqualToString: @""] && [lastName isEqualToString: @""]){
            fullName = firstName;
        }else if ([firstName isEqualToString: @""] && ![lastName isEqualToString: @""]){
            fullName = lastName;
        }else{
            fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        }
    }
    [rs close];
    return fullName;
}

// Lấy avatar của một contact theo callnexID
+ (NSString *)getAvatarDataStringOfCallnexID: (NSString *)callnexID {
    NSString *resultStr = @"";
    NSString *tSQL = [NSString stringWithFormat:@"SELECT avatar FROM contact WHERE callnex_id = '%@' ORDER BY id_contact DESC LIMIT 0,1", callnexID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        resultStr = [rsDict objectForKey:@"avatar"];
    }
    [rs close];
    return resultStr;
}


//  Hàm trả về tên contact (nếu tồn tại) hoặc callnexID
+ (NSString *)getFullnameOfContactForGroupWithCallnexID: (NSString *)callnexID{
    NSString *tSQL = [NSString stringWithFormat:@"SELECT first_name, last_name FROM contact WHERE callnex_id = '%@' ORDER BY id_contact DESC LIMIT 0,1", callnexID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *fName = [rsDict objectForKey:@"first_name"];
        NSString *lName = [rsDict objectForKey:@"last_name"];
        if ([fName isEqualToString:@""] && ![lName isEqualToString:@""]) {
            callnexID = lName;
        }else if (![fName isEqualToString:@""] && [lName isEqualToString:@""]){
            callnexID = fName;
        }else if (![fName isEqualToString:@""] && ![lName isEqualToString:@""]){
            callnexID = [NSString stringWithFormat:@"%@ %@", fName, lName];
        }
    }
    [rs close];
    return callnexID;
}

+ (NSString *)getAvatarDataOfAccount: (NSString *)account {
    NSString *avatar = @"";
    NSString *tSQL = [NSString stringWithFormat:@"SELECT avatar FROM profile WHERE account = '%@'", account];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        avatar = [rsDict objectForKey:@"avatar"];
    }
    [rs close];
    return avatar;
}

+ (NSString *)getProfielNameOfAccount: (NSString *)account {
    NSString *avatar = @"";
    NSString *tSQL = [NSString stringWithFormat:@"SELECT name FROM profile WHERE account = '%@'", account];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        avatar = [rsDict objectForKey:@"name"];
    }
    [rs close];
    return avatar;
}

//  Get tất cả các contact có cloudfone
+ (NSMutableArray *)getAllCloudFoneContactWithSearch: (NSString *)search {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSString *tSQL;
    if ([search isEqualToString: @""]) {
        tSQL = [NSString stringWithFormat:@"SELECT * FROM contact WHERE callnex_id != '' AND callnex_id != '%@' AND id_contact != 0", USERNAME];
    }else{
        tSQL = [NSString stringWithFormat:@"SELECT * FROM contact WHERE callnex_id != '' AND callnex_id != '%@' AND id_contact != 0 AND (callnex_id LIKE '%@%%' OR callnex_id LIKE '%%%@' OR callnex_id LIKE '%%%@%%')", USERNAME, search, search, search];
    }
    
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        ContactObject *aContact = [[ContactObject alloc] init];
        NSDictionary *rsDict = [rs resultDictionary];
        aContact._id_contact = [[rsDict objectForKey:@"id_contact"] intValue];
        aContact._avatar = [rsDict objectForKey:@"avatar"];
        aContact._firstName = [rsDict objectForKey:@"first_name"];
        aContact._lastName = [rsDict objectForKey:@"last_name"];
        if (![aContact._firstName isEqualToString:@""] && [aContact._lastName isEqualToString:@""]) {
            aContact._fullName = aContact._firstName;
        }else if ([aContact._firstName isEqualToString:@""] && ![aContact._lastName isEqualToString:@""]){
            aContact._fullName = aContact._lastName;
        }else if (![aContact._firstName isEqualToString:@""] && ![aContact._lastName isEqualToString:@""]){
            aContact._fullName = [NSString stringWithFormat:@"%@ %@", aContact._firstName, aContact._lastName];
        }
        aContact._sipPhone = [rsDict objectForKey:@"callnex_id"];
        if (aContact._fullName != nil) {
            [result addObject: aContact];
        }
    }
    [rs close];
    return result;
}

//  Thêm một contact vào Blacklist
+ (BOOL)addContactToBlacklist: (int)idContact andCloudFoneID: (NSString *)cloudfoneID{
    BOOL result = false;
    NSString *tSQL = [NSString stringWithFormat:@"INSERT INTO group_members (id_group, id_member, callnex_id, account) VALUES (%d, %d, '%@', '%@')", 0, idContact, cloudfoneID, USERNAME];
    result = [appDelegate._database executeUpdate: tSQL];
    return result;
}

//  Lấy tất cả user trong Callnex Blacklist
+ (NSMutableArray *)getAllUserInCallnexBlacklist{
    NSMutableArray *rsArray = [[NSMutableArray alloc] init];
    
    NSString *tSQL = [NSString stringWithFormat:@"SELECT distinct id_member, callnex_id FROM group_members WHERE id_group = 0 AND account = '%@'", USERNAME];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        int idMember = [[rsDict objectForKey:@"id_member"] intValue];
        NSString *callnexStr = [rsDict objectForKey:@"callnex_id"];
        
        if (idMember != -1 && idMember != idContactUnknown) {
            NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM contact WHERE id_contact=%d", idMember];
            FMResultSet *rs1 = [appDelegate._database executeQuery: tSQL];
            while ([rs1 next]) {
                NSDictionary *rsDict = [rs1 resultDictionary];
                NSString *jidStr = [rsDict objectForKey:@"callnex_id"];
                if (![jidStr isEqualToString:@""]) {
                    contactBlackListCell *blContact = [[contactBlackListCell alloc] init];
                    blContact._idContact = idMember;
                    blContact._callnexContact = jidStr;
                    [rsArray addObject: blContact];
                }
            }
            [rs1 close];
        }else{
            // So callnex lạ
            contactBlackListCell *blContact = [[contactBlackListCell alloc] init];
            blContact._idContact = -1;
            blContact._callnexContact = callnexStr;
            [rsArray addObject: blContact];
        }
    }
    [rs close];
    return rsArray;
}

//  Xoá một contact cua Blacklist
+ (BOOL)removeContactFromBlacklist: (int)idContact andCloudFoneID: (NSString *)cloudFoneID {
    BOOL result = NO;
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM group_members WHERE id_group = %d AND id_member = %d AND callnex_id = %@ AND account = '%@'", 0, idContact, cloudFoneID, USERNAME];
    result = [appDelegate._database executeUpdate: tSQL];
    return result;
}

@end
