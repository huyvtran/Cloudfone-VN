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
#import "NSBubbleData.h"
#import "NSData+Base64.h"
#import <MediaPlayer/MediaPlayer.h>
#import "OTRProtocolManager.h"
#import "contactBlackListCell.h"
#import "MessageEvent.h"
#import "RoomObject.h"
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

// Lấy tổng số phút gọi đến 1 số
+ (NSArray *)getTotalDurationAndRateOfCallWithPhone: (NSString *)phoneNumber{
    NSString *tSQL = [NSString stringWithFormat:@"SELECT duration,rate FROM history WHERE my_sip = '%@' AND call_direction='Outgoing' AND status = 'Success' AND phone_number LIKE '%%%@%%'", USERNAME, phoneNumber];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    int totalDuration = 0;
    float totalRate = 0;
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        int duration = [[rsDict objectForKey:@"duration"] intValue];
        float rate = [[rsDict objectForKey:@"rate"] floatValue];
        totalDuration = totalDuration + duration;
        totalRate = totalRate + rate;
    }
    [rs close];
    return [[NSArray alloc] initWithObjects:[NSNumber numberWithInt: totalDuration], [NSNumber numberWithFloat: totalRate], nil];
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
+ (NSMutableArray *)getAllListCallOfMe: (NSString *)mySip withPhoneNumber: (NSString *)phoneNumber andCallDirection: (NSString *)callDirection{
    
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    
    NSString *dateSQL = @"";
    // Viết câu truy vấn cho get hotline history
    if ([phoneNumber isEqualToString: hotline]) {
        dateSQL = [NSString stringWithFormat:@"SELECT date FROM history WHERE my_sip='%@' AND phone_number = '%@' AND call_direction='%@' GROUP BY date ORDER BY _id DESC", mySip, phoneNumber, callDirection];
    }else{
        dateSQL = [NSString stringWithFormat:@"SELECT date FROM history WHERE my_sip='%@' AND phone_number LIKE '%%%@%%' AND call_direction='%@' GROUP BY date ORDER BY _id DESC", mySip, phoneNumber, callDirection];
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
        [resultArr addObjectsFromArray:[self getAllCallOfMe:mySip withPhone:phoneNumber andCallDirection:callDirection onDate:dateStr]];
    }
    [rs close];
    return resultArr;
}

+ (NSMutableArray *)getAllCallOfMe: (NSString *)mySip withPhone: (NSString *)phoneNumber andCallDirection: (NSString *)callDirection onDate: (NSString *)dateStr{
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    
    NSString *tSQL = @"";
    // Viết câu truy vấn cho get hotline history
    if ([phoneNumber isEqualToString: hotline]) {
        tSQL = [NSString stringWithFormat:@"SELECT * FROM history WHERE my_sip='%@' AND phone_number = '%@' AND call_direction='%@' AND date='%@' ORDER BY _id DESC", mySip, phoneNumber, callDirection, dateStr];
    }else{
        tSQL = [NSString stringWithFormat:@"SELECT * FROM history WHERE my_sip='%@' AND phone_number LIKE '%%%@%%' AND call_direction='%@' AND date='%@' ORDER BY _id DESC", mySip, phoneNumber, callDirection, dateStr];
    }
    
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        
        NSString *time      = [rsDict objectForKey:@"time"];
        NSString *status    = [rsDict objectForKey:@"status"];
        int duration  = [[rsDict objectForKey:@"duration"] intValue];
        float rate      = [[rsDict objectForKey:@"rate"] floatValue];
        //NSString *date      = [rsDict objectForKey:@"date"];
        
        CallHistoryObject *aCall = [[CallHistoryObject alloc] init];
        aCall._time = time;
        aCall._status= status;
        aCall._duration = duration;
        aCall._rate = rate;
        // aCall._date = date;
        aCall._date = @"date";
        
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
        NSString *recordFile = [rsDict objectForKey:@"record_files"];
        
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
        aCall._recordFile = recordFile;
        
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

+ (void)saveRoomSubject: (NSString *)subject forRoom: (NSString *)roomName {
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE room_chat SET subject='%@' WHERE room_name = '%@'", subject, roomName];
    [appDelegate._database executeUpdate: tSQL];
}

+ (NSString *)getStatusXmppOfAccount: (NSString *)account
{
    NSString *status = @"";
    NSString *tSQL = [NSString stringWithFormat:@"SELECT status FROM profile WHERE account = '%@'", account];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        status = [rsDict objectForKey:@"status"];
    }
    [rs close];
    return status;
}

//  Cập nhật profile
+ (void)saveProfileForAccount: (NSString *)account withName: (NSString *)Name andAvatar: (NSString *)Avatar andAddress: (NSString *)address andEmail: (NSString *)email withStatus: (NSString *)status
{
    BOOL exist = false;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM profile WHERE account = '%@'", account];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        exist = true;
        
        NSString *updateSQL = [NSString stringWithFormat:@"UPDATE profile SET name = '%@', email = '%@', address = '%@', avatar = '%@', status = '%@' WHERE account = '%@'", Name, email, address, Avatar, status, account];
        [appDelegate._database executeUpdate: updateSQL];
    }
    if (!exist) {
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO profile (account, status, name, email, address, avatar) VALUES ('%@','%@','%@','%@','%@','%@')", account, status, Name, email, address, Avatar];
        
        [appDelegate._database executeUpdate: insertSQL];
    }
    [rs close];
}

//  Cập nhật tên của phòng
+ (void)updateGroupNameOfRoom: (NSString *)roomName andNewGroupName: (NSString *)newGroupName {
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE room_chat SET group_name = '%@' WHERE room_name = '%@'", newGroupName, roomName];
    [appDelegate._database executeUpdate: tSQL];
}

+ (BOOL)removeAnUserFromRequestedList: (NSString *)user {
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM list_for_accept WHERE account = '%@' AND user = '%@'", USERNAME, user];
    return [appDelegate._database executeUpdate: tSQL];
}

/*
 Khi join vào room chat -> trả về 1 số tin nhắn trước đó
 -> Kiểm tra tin nhắn nhận đc hay chưa -> nếu chưa mới thêm mới vào
 */
+ (BOOL)checkMessageExistsInDatabase: (NSString *)idMessage {
    BOOL result = false;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM message WHERE id_message = '%@' AND room_id != '' LIMIT 0,1", idMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        result = true;
    }
    [rs close];
    return result;
}

/*  -> Nếu room đã tồn tại thì update trạng thái
 -> Nếu chưa tồn tại thì thêm mới
 */
+ (void)saveRoomChatIntoDatabase: (NSString *)roomName andGroupName: (NSString *)groupName {
    BOOL exists = false;
    
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM room_chat WHERE room_name = '%@' LIMIT 0,1", roomName];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        exists = true;
        NSString *updateSQL = [NSString stringWithFormat:@"UPDATE room_chat SET status = %d WHERE room_name = '%@'", 1, roomName];
        [appDelegate._database executeUpdate: updateSQL];
    }
    
    if (!exists) {
        NSString *curDate = [AppUtils getCurrentDate];
        NSString *curTime = [AppUtils getCurrentTimeStamp];
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO room_chat(room_name, group_name, date, time, status, user, subject) VALUES ('%@', '%@', '%@', '%@', %d, '%@', '%@')", roomName, groupName, curDate, curTime, 1, USERNAME, welcomeToCloudFone];
        [appDelegate._database executeUpdate: insertSQL];
    }
    [rs close];
}

//  Get id của room chat với room name
+ (int)getIdRoomChatWithRoomName: (NSString *)roomName{
    int idRoom = 0;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id FROM room_chat WHERE room_name = '%@' LIMIT 0,1", roomName];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        idRoom = [[rsDict objectForKey:@"id"] intValue];
    }
    [rs close];
    return idRoom;
}

//  Save một conversation cho room chat
+ (void)saveConversationForRoomChat: (NSString *)roomID isUnread: (BOOL)isUnread
{
    BOOL exists = false;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id FROM conversation WHERE account = '%@' AND room_id = '%@'", USERNAME, roomID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        exists = YES;
    }
    
    int numMsgUnread = 0;
    if (isUnread) {
        numMsgUnread = 1;
    }
    
    if (!exists) {
        NSString *addSQL = [NSString stringWithFormat:@"INSERT INTO conversation (account, user, room_id, message_draf, background, expire, unread, inear_mode, date, time) VALUES ('%@', '%@', '%@', '%@', '%@', %d, %d, %d, '%@', '%@')", USERNAME, @"", roomID, @"", @"", 0, numMsgUnread, 0, [AppUtils getCurrentDate], [AppUtils getCurrentTimeStamp]];
        [appDelegate._database executeUpdate: addSQL];
    }
    [rs close];
}

+ (BOOL)checkRequestFriendExistsOnList: (NSString *)cloudfoneID {
    BOOL result = false;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM list_for_accept WHERE account = '%@' AND user = '%@' LIMIT 0,1", USERNAME, cloudfoneID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        result = true;
    }
    [rs close];
    return result;
}

+ (BOOL)addUserToWaitAcceptList: (NSString *)cloudfoneID {
    NSString *tSQL = [NSString stringWithFormat:@"INSERT INTO list_for_accept (account, user) VALUES ('%@', '%@')", USERNAME, cloudfoneID];
    return [appDelegate._database executeUpdate: tSQL];
}

// Cập nhật delivered của user
+ (void)updateDeliveredMessageOfUser: (NSString *)user idMessage: (NSString *)idMessage {
    // Cập nhật delivered của message
    NSString *tSQL = [NSString stringWithFormat: @"UPDATE message SET delivered_status = 2 WHERE receive_phone = '%@' AND send_phone = '%@' AND id_message = '%@'", user, USERNAME, idMessage];
    [appDelegate._database executeUpdate: tSQL];
    
    // Xoá msg trong fail_message nếu tồn tại
    NSString *delSQL = [NSString stringWithFormat:@"DELETE FROM fail_message WHERE id_message = '%@' AND account = '%@'", idMessage, USERNAME];
    BOOL delete = [appDelegate._database executeUpdate: delSQL];
    if (!delete) {
        NSLog(@"Can not remove message on fail_message table!!!!!");
    }
}

/*--Hàm recall message--*/
+ (BOOL)updateMessageRecallMeReceive: (NSString *)idMessage{
    BOOL result = NO;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT type_message, details_url, thumb_url FROM message WHERE id_message = '%@'", idMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *typeMessage = [rsDict objectForKey:@"type_message"];
        if (![typeMessage isEqualToString:typeTextMessage]) {
            NSString *details = [rsDict objectForKey:@"details_url"];
            NSString *thumb_url = [rsDict objectForKey:@"thumb_url"];
            [AppUtils deleteDetailsFileOfMessage:typeMessage andDetails:details andThumb:thumb_url];
        }
        NSString *tSQL2 = [NSString stringWithFormat:@"UPDATE message SET content = 'Message was recalled', is_recall='YES', delivered_status = 0, type_message='%@' WHERE id_message = '%@' AND receive_phone='%@'", typeTextMessage, idMessage, USERNAME];
        result = [appDelegate._database executeUpdate: tSQL2];
    }
    return result;
}

// Cập nhật message recall
+ (BOOL)updateMessageForRecall: (NSString *)idMessage
{   // Xoá details của message nếu là message media
    [self removeDetailsMessageForRecallWithIdMessage: idMessage];
    
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE message SET content = 'Message recalled successfully', is_recall='YES', delivered_status = 0, type_message = '%@' WHERE id_message = '%@' AND send_phone='%@'", typeTextMessage, idMessage, USERNAME];
    return [appDelegate._database executeUpdate: tSQL];
}

//  Cập nhật subject của room chat
+ (BOOL)updateSubjectOfRoom: (NSString *)roomName withSubject: (NSString *)subject {
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE room_chat SET subject = '%@' WHERE user = '%@' AND room_name = '%@'", subject, USERNAME, roomName];
    BOOL result = [appDelegate._database executeUpdate: tSQL];
    return result;
}

//  Cập nhật trạng thái deliverd của message gửi trong room chat
+ (BOOL)updateMessageDeliveredWithId: (NSString *)idMessage ofRoom: (NSString *)roomName {
    int idRoom = [NSDatabase getRoomIDOfRoomChatWithRoomName: roomName];
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE message SET delivered_status = 2 WHERE id_message = '%@' AND room_id = '%@'", idMessage, [NSString stringWithFormat:@"%d", idRoom]];
    return [appDelegate._database executeUpdate: tSQL];
}

// remove details của message media
+ (void)removeDetailsMessageForRecallWithIdMessage: (NSString *)idMessage
{
    NSString *tSQL = [NSString stringWithFormat:@"SELECT type_message, details_url, thumb_url FROM message WHERE id_message = '%@' LIMIT 0,1", idMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *typeMessage = typeMessage = [rsDict objectForKey:@"type_message"];
        if ([typeMessage isEqualToString:imageMessage]) {
            NSString *thumb_url     = [rsDict objectForKey:@"thumb_url"];
            NSString *details_url   = [rsDict objectForKey:@"details_url"];
            [AppUtils deleteDetailsFileOfMessage:typeMessage andDetails:details_url andThumb:thumb_url];
        }
    }
    [rs close];
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

/*--get Id cua room chat theo room name--*/
+ (int)getRoomIDOfRoomChatWithRoomName: (NSString *)roomName {
    int idLastRoom = 0;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id FROM room_chat WHERE room_name = '%@' AND user = '%@'", roomName, USERNAME];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        idLastRoom = [[rsDict objectForKey:@"id"] intValue];
    }
    [rs close];
    return idLastRoom;
}

// Xoá user ra khỏi bảng request
+ (BOOL)removeUserFromRequestSent: (NSString *)userStr{
    if (userStr != nil && ![userStr isEqualToString:@""]) {
        NSString *user = [AppUtils getSipFoneIDFromString:userStr];
        
        NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM request_sent WHERE account = '%@' AND user = '%@'", USERNAME, user];
        BOOL result = [appDelegate._database executeUpdate: tSQL];
        return result;
    }
    return NO;
}

// Xoá thông tin user của bảng request
+ (void)removeAllUserFromRequestSentOfAccount: (NSString *)account
{
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM request_sent WHERE account = '%@'", account];
    [appDelegate._database executeUpdate: tSQL];
}

/*--Xoa group ra khoi database--*/
+ (BOOL)deleteARoomChatWithRoomName: (NSString *)roomName {
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE room_chat SET status = '%d' WHERE room_name = '%@'", 0, roomName];
    BOOL result = [appDelegate._database executeUpdate: tSQL];
    return result;
}

+ (void)removeAllUserInGroupChat {
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM room_user WHERE account = '%@'", USERNAME];
    [appDelegate._database executeUpdate: tSQL];
}

// Xóa conversation của mình với group chat
+ (BOOL)deleteConversationOfMeWithRoomChat: (NSString *)roomID
{
    BOOL result = FALSE;
    [appDelegate._database beginTransaction];
    // Xoa text message truoc
    NSString *delMsgSQL = [NSString stringWithFormat:@"DELETE FROM message WHERE (send_phone = '%@' OR receive_phone = '%@') AND room_id = '%@'", USERNAME, USERNAME, roomID];
    result = [appDelegate._database executeUpdate: delMsgSQL];
    if (result)
    {
        NSString *tSQL = [NSString stringWithFormat:@"SELECT id_message FROM message WHERE (send_phone='%@' OR receive_phone='%@') AND room_id = '%@')", USERNAME, USERNAME, roomID];
        FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
        while ([rs next]) {
            NSDictionary *rsDict = [rs resultDictionary];
            NSString *idMessage = [rsDict objectForKey:@"id_message"];
            [self deleteOneMessageWithId: idMessage];
        }
        NSString *delConSQL = [NSString stringWithFormat:@"DELETE FROM conversation WHERE account = '%@' AND room_id = '%@'", USERNAME, roomID];
        result = [appDelegate._database executeUpdate: delConSQL];
        if (!result) {
            [appDelegate._database rollback];
        }
    }
    [appDelegate._database commit];
    return result;
}

// Hàm delete 1 message và file details
+ (BOOL)deleteOneMessageWithId: (NSString *)idMessage
{
    NSString *tSQL = [NSString stringWithFormat:@"SELECT type_message, thumb_url, details_url FROM message WHERE id_message='%@'", idMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *typeMessage = [rsDict objectForKey:@"type_message"];
        if (![typeMessage isEqualToString:typeTextMessage]) {
            NSString *thumb_url     = [rsDict objectForKey:@"thumb_url"];
            NSString *details_url   = [rsDict objectForKey:@"details_url"];
            [AppUtils deleteDetailsFileOfMessage:typeMessage andDetails:details_url andThumb:thumb_url];
        }
    }
    [rs close];
    
    NSString *tSQL2 = [NSString stringWithFormat:@"DELETE FROM message WHERE id_message='%@'", idMessage];
    BOOL deleted = [appDelegate._database executeUpdate: tSQL2];
    return deleted;
}

+ (void)removeAllUserInGroupChat: (NSString *)roomName {
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM room_user WHERE account = '%@' AND room_name = '%@'", USERNAME, roomName];
    [appDelegate._database executeUpdate: tSQL];
}

//  Xoa 1 user vao bang room chat
+ (void)removeUser: (NSString *)user fromRoomChat: (NSString *)roomName forAccount: (NSString *)account
{
    NSString *delSQL = [NSString stringWithFormat:@"DELETE FROM room_user WHERE account = '%@' AND room_name = '%@' AND chat_user = '%@'", account, roomName, user];
    [appDelegate._database executeUpdate: delSQL];
}

//  Them 1 user vao bang room chat
+ (void)saveUser: (NSString *)user toRoomChat: (NSString *)roomName forAccount: (NSString *)account
{
    NSString *delSQL = [NSString stringWithFormat:@"DELETE FROM room_user WHERE account = '%@' AND room_name = '%@' AND chat_user = '%@'", account, roomName, user];
    [appDelegate._database executeUpdate: delSQL];
    
    NSString *addSQL = [NSString stringWithFormat:@"INSERT INTO room_user (account, room_name, chat_user) VALUES ('%@', '%@', '%@')", account, roomName, user];
    [appDelegate._database executeUpdate: addSQL];
}

// Kiểm tra message có trong failed list hay chưa
+ (BOOL)checkMessageExistsOnFailedList: (NSString *)idMessage {
    BOOL result = FALSE;
    NSString *tSQL = [NSString stringWithFormat: @"SELECT id_message FROM fail_message WHERE id_message = '%@' LIMIT 0,1", idMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        result = TRUE;
    }
    [rs close];
    return result;
}

// Add msg ko thể send được vào list
+ (BOOL)addNewFailedMessageForAccountWithIdMessage: (NSString *)idMessage {
    NSString *tSQL = [NSString stringWithFormat:@"INSERT INTO fail_message(account, id_message) VALUES('%@', '%@')", USERNAME, idMessage];
    return [appDelegate._database executeUpdate: tSQL];
}

// Save message vào callnex DB với status là NO
+ (void)saveMessage: (NSString*)sendPhone toPhone: (NSString*)receivePhone withContent: (NSString*)content andStatus: (BOOL)messageStatus withDelivered: (int)typeDelivered andIdMsg: (NSString *)idMsg detailsUrl: (NSString *)detailsUrl andThumbUrl: (NSString *)thumbUrl withTypeMessage: (NSString *)typeMessage andExpireTime: (int)expireTime andRoomID: (NSString *)roomID andExtra: (NSString *)extra andDesc: (NSString *)description
{
    // Thời gian hiện tại
    NSTimeInterval curInterval = [[NSDate date] timeIntervalSince1970];
    
    int last_time_expire = 0;
    NSString *statusStr = @"";
    if (messageStatus) {
        statusStr = @"YES";
        if (![sendPhone isEqualToString: USERNAME]) {
            if ([typeMessage isEqualToString: typeTextMessage] || [typeMessage isEqualToString: locationMessage] || [typeMessage isEqualToString: descriptionMessage]) {
                if (expireTime > 0) {
                    last_time_expire = (int)curInterval + expireTime;
                }
            }
        }
    }else{
        statusStr = @"NO";
    }
    // Đổi ký tự dấu nháy đơn để add vào db
    content = [content stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    //  groupimage_92X09GoQz7eSdUBmmzyy
    NSString *tSQL = [NSString stringWithFormat: @"INSERT INTO message (send_phone, receive_phone, content, time, status, delivered_status, id_message, is_recall, details_url, thumb_url, type_message, expire_time, last_time_expire, room_id, extra, description) VALUES ('%@', '%@', '%@', %d, '%@', %d, '%@','NO', '%@', '%@', '%@',%d, %d, '%@', '%@', '%@')", sendPhone, receivePhone, content, (int)curInterval, statusStr, typeDelivered, idMsg, detailsUrl, thumbUrl, typeMessage, expireTime, last_time_expire, roomID, extra, description];
    BOOL isSaved = [appDelegate._database executeUpdate: tSQL];
    if (!isSaved) {
        NSLog(@"Can not save this message!!!");
    }
}

+ (MessageEvent *)getMessageEventWithId: (NSString *)idMessage
{
    MessageEvent *aMessage;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM message WHERE id_message = '%@'", idMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *dict  = [rs resultDictionary];
        NSString *sendPhone = [dict objectForKey:@"send_phone"];
        NSString *receivePhone = [dict objectForKey:@"receive_phone"];
        int timeInterval   = [[dict objectForKey:@"time"] intValue];
        NSString *content   = [dict objectForKey:@"content"];
        int statusMsg   = [[dict objectForKey:@"delivered_status"] intValue];
        NSString *idMessage = [dict objectForKey:@"id_message"];
        NSString *isRecall = [dict objectForKey:@"is_recall"];
        NSString *detailsUrl = [dict objectForKey:@"details_url"];
        NSString *thumbUrl = [dict objectForKey:@"thumb_url"];
        NSString *typeMessage = [dict objectForKey:@"type_message"];
        int expTime = [[dict objectForKey:@"expire_time"] intValue];
        NSString *descriptionStr = [dict objectForKey:@"description"];
        NSString *status = [dict objectForKey:@"status"];
        NSString *roomID = [dict objectForKey:@"room_id"];
        
        aMessage = [[MessageEvent alloc] init];
        aMessage.status = status;
        aMessage.idMessage = idMessage;
        aMessage.sendPhone = sendPhone;
        aMessage.receivePhone = receivePhone;
        aMessage.deliveredStatus = statusMsg;
        aMessage.content = content;
        aMessage.detailsUrl = detailsUrl;
        aMessage.thumbUrl = thumbUrl;
        aMessage.typeMessage = typeMessage;
        aMessage.time = timeInterval;
        aMessage.description = descriptionStr;
        aMessage.isRecall = isRecall;
        aMessage.roomID = roomID;
        aMessage.dateTime = [NSString stringWithFormat:@"%@ %@", [AppUtils getDateStringFromTimeInterval:timeInterval], [AppUtils getTimeStringFromTimeInterval:timeInterval]];
        if ([isRecall isEqualToString:@"YES"]) {
            NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithString: [localization localizedStringForKey:TEXT_MESSSAGE_RECEIVED_RECALLED]];
            aMessage.contentAttrString = contentString;
        }else{
            aMessage.contentAttrString = [AppUtils convertMessageStringToEmojiString: content];
        }
        if (expTime == 1) {
            aMessage.isBurn = YES;
        }else{
            aMessage.isBurn = NO;
        }
        
        if (roomID != nil && ![roomID isEqualToString:@""] && ![sendPhone isEqualToString: USERNAME]) {
            NSString *sendPhoneName = [NSDatabase getNameOfContactWithPhoneNumber: sendPhone];
            if ([sendPhoneName isEqualToString:@""]) {
                sendPhoneName = sendPhone;
            }
            aMessage.sendPhoneName = sendPhoneName;
        }
    }
    [rs close];
    return aMessage;
}

// Cập nhật audio message sau khi nhận thành công
+ (BOOL)updateAudioMessageAfterReceivedSuccessfullly: (NSString *)idMessage{
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE message SET delivered_status=%d WHERE id_message='%@'", 2, idMessage];
    return [appDelegate._database executeUpdate: tSQL];
}

/*--Update image message vào callnex DB--*/
+ (void)updateImageMessageWithDetailsUrl: (NSString *)detailsUrl andThumbUrl: (NSString *)thumbUrl ofImageMessage: (NSString *)idMessage{
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE message SET delivered_status = %d, details_url = '%@', thumb_url = '%@' WHERE id_message = '%@'", 2, detailsUrl, thumbUrl, idMessage];
    BOOL updated = [appDelegate._database executeUpdate: tSQL];
    if (updated) {
        NSLog(@"......Update successfully.....");
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Cannot save message" delegate:self cancelButtonTitle:@"Confirm" otherButtonTitles: nil];
        [alertView show];
    }
}

+ (NSString *)getLinkImageOfMessage: (NSString *)idMessage
{
    NSString *linkImage = @"";
    NSString *tSQL = [NSString stringWithFormat:@"SELECT thumb_url FROM message WHERE id_message = '%@'", idMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        linkImage = [rsDict objectForKey:@"thumb_url"];
        
    }
    [rs close];
    return linkImage;
}

// Cập nhật last_time_expire khi click play audio có expire time
+ (BOOL)updateExpireTimeWhenClickPlayExpireAudioMessage: (NSString *)idMessage withAudioLength: (int)expireAudio
{
    NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
    
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE message SET last_time_expire = %d + %d + expire_time WHERE id_message = '%@' AND delivered_status = 2 AND last_time_expire = 0 AND expire_time > 0 AND type_message = '%@' AND (send_phone = '%@' OR receive_phone = '%@')", (int)curTime, expireAudio, idMessage, audioMessage, USERNAME, USERNAME];
    return [appDelegate._database executeUpdate: tSQL];
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

// get id contact da send theo id message
+ (NSString *)getExtraOfMessageWithMessageId: (NSString *)idMessage
{
    NSString *result = @"";
    NSString *tSQL = [NSString stringWithFormat:@"SELECT extra FROM message WHERE id_message = '%@'", idMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        result = [rsDict objectForKey:@"extra"];
    }
    [rs close];
    return result;
}

// Get trạng thái delivered của message
+ (int)getDeliveredOfMessage: (NSString *)idMessage {
    int delivered = 0;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM message WHERE id_message = '%@' LIMIT 0,1", idMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        delivered = [[rsDict objectForKey:@"delivered_status"] intValue];
    }
    [rs close];
    return delivered;
}

// Hàm get tất cả danh sách ảnh
+ (NSMutableArray *)getAllImageIdOfMeWithUser: (NSString *)userStr{
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id_message FROM message WHERE ((send_phone = '%@' AND receive_phone = '%@') OR (send_phone = '%@' AND receive_phone = '%@')) AND type_message = '%@'", USERNAME, userStr, userStr, USERNAME, imageMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *idMessage = [rsDict objectForKey:@"id_message"];
        [resultArr addObject: idMessage];
    }
    [rs close];
    return resultArr;
}

/*--Lấy tên ảnh của một image message--*/
+ (NSArray *)getPictureURLOfMessageImage: (NSString *)idMessage{
    NSString *thumbURL = @"";
    int expireTime = -1;
    NSString *description = @"";
    NSString *sendPhone = @"";
    NSString *tSQL = [NSString stringWithFormat:@"SELECT send_phone, thumb_url, content, expire_time FROM message WHERE id_message = '%@'", idMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        thumbURL = [rsDict objectForKey:@"thumb_url"];
        expireTime = [[rsDict objectForKey:@"expire_time"] intValue];
        description = [rsDict objectForKey:@"description"];
        if (description == nil) {
            description = @"";
        }
        sendPhone = [rsDict objectForKey:@"send_phone"];
    }
    [rs close];
    return [[NSArray alloc] initWithObjects:thumbURL, [NSNumber numberWithInt: expireTime], sendPhone, description, nil];
}

// Cập nhật last_time_expire của một msg có expire_time
+ (BOOL)updateLastTimeExpireOfImageMessage: (NSString *)idMessage
{
    NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE message SET last_time_expire = %d + expire_time WHERE expire_time > 0 AND last_time_expire = 0 AND type_message = '%@' AND id_message = '%@' AND (send_phone = '%@' OR receive_phone = '%@')", (int)curTime, imageMessage, idMessage, USERNAME, USERNAME];
    return [appDelegate._database executeUpdate: tSQL];
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

//  Kiểm tra một số callnex và id contact có trong blacklist hay không
+ (BOOL)checkContactInBlackList: (int)idContact andCloudfoneID: (NSString *)cloudfoneID
{
    BOOL result = false;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM group_members WHERE id_group = %d AND id_member = %d AND callnex_id = '%@' AND account = '%@' LIMIT 0,1", 0, idContact, cloudfoneID, USERNAME];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        result = true;
        break;
    }
    [rs close];
    return result;
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

// Get tên ảnh của một tin nhắn hình ảnh
+ (NSString *)getPictureNameOfMessage: (NSString *)idMessage {
    NSString *resultStr = @"";
    NSString *tSQL = [NSString stringWithFormat:@"SELECT details_url FROM message WHERE id_message = '%@'", idMessage];
    FMResultSet *rs = [appDelegate._database executeQuery:tSQL];
    while ([rs next]) {
        NSDictionary *dict  = [rs resultDictionary];
        resultStr = [dict objectForKey:@"details_url"];
    }
    [rs close];
    return resultStr;
}

//  Get background của user
+ (NSString *)getChatBackgroundOfUser: (NSString *)user {
    NSString *result = @"";
    NSString *tSQL = [NSString stringWithFormat:@"SELECT background FROM conversation WHERE account = '%@' AND user = '%@'", USERNAME, user];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        result = [rsDict objectForKey:@"background"];
    }
    [rs close];
    return result;
}

// Kiểm tra user đã có message chưa đọc khi chạy background chưa
+ (BOOL)checkBadgeMessageOfUserWhenRunBackground: (NSString *)user{
    BOOL result = NO;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM message WHERE send_phone = '%@' AND receive_phone = '%@' AND status = 'NO' LIMIT 0,1", user, USERNAME];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        result = YES;
    }
    [rs close];
    return result;
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

//  Get data của 1 message nhận được sau cùng
+ (NSBubbleData *)getDataOfMessage: (NSString *)idMessage
{
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM message WHERE id_message = '%@'", idMessage];
    FMResultSet *rs = [appDelegate._database executeQuery:tSQL];
    NSBubbleData *messageData  = [[NSBubbleData alloc] init];
    while ([rs next]) {
        NSDictionary *dict  = [rs resultDictionary];
        NSString *roomId = [dict objectForKey:@"room_id"];
        NSString *sendPhone = [dict objectForKey:@"send_phone"];
        int timeInterval = [[dict objectForKey:@"time"] intValue];
        NSString *content   = [dict objectForKey:@"content"];
        int statusMsg   = [[dict objectForKey:@"delivered_status"] intValue];
        NSString *idMsgStr = [dict objectForKey:@"id_message"];
        NSString *isRecall = [dict objectForKey:@"is_recall"];
        NSString *detailsUrl = [dict objectForKey:@"details_url"];
        NSString *thumbUrl = [dict objectForKey:@"thumb_url"];
        NSString *typeMessage = [dict objectForKey:@"type_message"];
        int expTime = [[dict objectForKey:@"expire_time"] intValue];
        NSString *descriptionStr = [dict objectForKey:@"description"];
        
        if ([typeMessage isEqualToString: typeTextMessage])
        {
            if ([USERNAME isEqualToString: sendPhone]) {
                messageData = [NSBubbleData dataWithText:content type:BubbleTypeMine time:[AppUtils stringTimeFromInterval:timeInterval] status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description: @"" withTypeMessage: typeTextMessage isGroup:NO ofUser:nil];
            }else
            {   // Kiểm tra là msg của room hay của user
                if ([roomId isEqualToString:@""] || [roomId isEqualToString:@"0"]) {
                    messageData = [NSBubbleData dataWithText:content type:BubbleTypeSomeoneElse time:[AppUtils stringTimeFromInterval: timeInterval] status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:@"" withTypeMessage:typeTextMessage isGroup:NO ofUser:nil];
                }else{
                    NSString *fullName = [self getFullnameOfContactForGroupWithCallnexID:sendPhone];
                    messageData = [NSBubbleData dataWithText:content type:BubbleTypeSomeoneElse time:[AppUtils stringTimeFromInterval: timeInterval] status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:@"" withTypeMessage:typeTextMessage isGroup:YES ofUser:fullName];
                    [messageData set_callnexID: sendPhone];
                }
            }
        }else if ([typeMessage isEqualToString: audioMessage]){
            if ([USERNAME isEqualToString: sendPhone]) {
                UIView *recordView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 255, 55)];
                UIButton *playButton = [[UIButton alloc] initWithFrame:CGRectMake(4, 4, 30, 30)];
                [playButton setBackgroundColor:[UIColor clearColor]];
                [playButton setBackgroundImage:[UIImage imageNamed:@"play_file_transfer.png"]
                                      forState:UIControlStateNormal];
                [playButton setTitle:detailsUrl forState:UIControlStateNormal];
                [playButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
                [recordView addSubview: playButton];
                
                // add time slider
                UISlider *timeSlider = [[UISlider alloc] initWithFrame:CGRectMake(playButton.frame.origin.x+playButton.frame.size.width+18, playButton.frame.origin.y+4, 186, 30)];
                [recordView addSubview: timeSlider];
                
                UIImageView *bgAudio = [[UIImageView alloc] initWithFrame:CGRectMake(playButton.frame.origin.x+playButton.frame.size.width+5, playButton.frame.origin.y, recordView.frame.size.width-(playButton.frame.size.width+10+5), playButton.frame.size.height)];
                [bgAudio setImage:[UIImage imageNamed:@"bg_audio.png"]];
                [bgAudio setBackgroundColor:[UIColor clearColor]];
                [recordView addSubview: bgAudio];
                
                
                UILabel *lbTimerFired = [[UILabel alloc] initWithFrame:CGRectMake(bgAudio.frame.origin.x+150, bgAudio.frame.origin.y, 50, 15)];
                [lbTimerFired setFont: [AppUtils fontRegularWithSize: 11.0]];
                [lbTimerFired setTextAlignment:NSTextAlignmentRight];
                [recordView addSubview: lbTimerFired];
                messageData = [NSBubbleData dataWithView:recordView type:BubbleTypeMine insets:UIEdgeInsetsMake(15, 5, 15, 10) time:[AppUtils stringTimeFromInterval: timeInterval] status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:thumbUrl withTypeMessage: audioMessage isGroup:NO ofUser:nil];
            }else{
                UIView *recordView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 255, 55)];
                UIButton *playButton = [[UIButton alloc] initWithFrame:CGRectMake(4, 4, 30, 30)];
                [playButton setBackgroundColor:[UIColor clearColor]];
                [playButton setBackgroundImage:[UIImage imageNamed:@"play_file_transfer.png"]
                                      forState:UIControlStateNormal];
                [playButton setTitle:detailsUrl forState:UIControlStateNormal];
                [playButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
                
                [recordView addSubview: playButton];
                
                UISlider *timeSlider = [[UISlider alloc] initWithFrame:CGRectMake(playButton.frame.origin.x+playButton.frame.size.width+18, playButton.frame.origin.y+4, 186, 30)];
                [recordView addSubview: timeSlider];
                
                UIImageView *bgAudio = [[UIImageView alloc] initWithFrame:CGRectMake(playButton.frame.origin.x+playButton.frame.size.width+5, playButton.frame.origin.y, recordView.frame.size.width-(playButton.frame.size.width+10+5), playButton.frame.size.height)];
                [bgAudio setImage:[UIImage imageNamed:@"bg_audio.png"]];
                [bgAudio setBackgroundColor:[UIColor clearColor]];
                [recordView addSubview: bgAudio];
                
                UILabel *lbTimerFired = [[UILabel alloc] initWithFrame:CGRectMake(bgAudio.frame.origin.x+150, bgAudio.frame.origin.y, 50, 15)];
                [lbTimerFired setFont: [AppUtils fontRegularWithSize: 11.0]];
                [lbTimerFired setTextAlignment:NSTextAlignmentRight];
                [recordView addSubview: lbTimerFired];
                
                messageData = [NSBubbleData dataWithView:recordView type:BubbleTypeSomeoneElse insets:UIEdgeInsetsMake(15, 12, 15, 5) time:[AppUtils stringTimeFromInterval: timeInterval] status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:thumbUrl withTypeMessage:audioMessage isGroup:NO ofUser:nil];
            }
        }else if ([typeMessage isEqualToString:imageMessage]){
            if ([USERNAME isEqualToString: sendPhone]) {
                if ([thumbUrl isEqualToString:@""]) {
                    messageData = [NSBubbleData dataWithImage:[UIImage imageNamed:@"unloaded.png"] type:BubbleTypeMine time:[AppUtils stringTimeFromInterval: timeInterval] status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:descriptionStr withTypeMessage:imageMessage isGroup:NO ofUser:nil];
                }else{
                    UIImage *thumbImg = [AppUtils getImageOfDirectoryWithName: thumbUrl];
                    if (thumbImg == nil) {
                        NSString *urlString = [ NSString stringWithFormat:@"http://anh.ods.vn/uploads/%@", thumbUrl];
                        NSURL *strURL = [NSURL URLWithString: urlString];
                        NSData *imageData = [NSData dataWithContentsOfURL: strURL];
                        UIImage *thumbImg = nil;
                        if (imageData != nil) {
                            thumbImg = [UIImage imageWithData: imageData];
                        }
                    }
                    /*
                    if ([thumbUrl containsString:@".jpg"] || [thumbUrl containsString:@".JPG"] || [thumbUrl containsString:@".png"] || [thumbUrl containsString:@".PNG"] || [thumbUrl containsString:@".jpeg"] || [thumbUrl containsString:@".JPEG"])
                    {
                         NSString *urlString = [ NSString stringWithFormat:@"http://anh.ods.vn/uploads/%@", thumbUrl];
                         NSURL *strURL = [NSURL URLWithString: urlString];
                         NSData *imageData = [NSData dataWithContentsOfURL: strURL];
                         UIImage *thumbImg = nil;
                         if (imageData != nil) {
                             thumbImg = [UIImage imageWithData: imageData];
                         }
                    }else{
                        thumbImg = [AppUtils getImageOfDirectoryWithName: thumbUrl];
                        
                    }   */
                    messageData = [NSBubbleData dataWithImage:thumbImg type:BubbleTypeMine time:[AppUtils stringTimeFromInterval: timeInterval] status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:descriptionStr withTypeMessage:imageMessage isGroup:NO ofUser:nil];
                }
            }else{
                if ([thumbUrl isEqualToString:@""]) {
                    messageData = [NSBubbleData dataWithImage:[UIImage imageNamed:@"unloaded.png"] type:BubbleTypeSomeoneElse time:[AppUtils stringTimeFromInterval: timeInterval] status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:descriptionStr withTypeMessage:imageMessage isGroup:NO ofUser:nil];
                }else{
                    UIImage *thumbImg;
                    if ([thumbUrl containsString:@".jpg"] || [thumbUrl containsString:@".JPG"] || [thumbUrl containsString:@".png"] || [thumbUrl containsString:@".PNG"] || [thumbUrl containsString:@".jpeg"] || [thumbUrl containsString:@".JPEG"])
                    {
                         NSString *urlString = [ NSString stringWithFormat:@"http://anh.ods.vn/uploads/%@", thumbUrl];
                         NSURL *strURL = [NSURL URLWithString: urlString];
                         NSData *imageData = [NSData dataWithContentsOfURL: strURL];
                         if (imageData != nil) {
                             thumbImg = [UIImage imageWithData: imageData];
                         }
                    }else{
                        thumbImg = [AppUtils getImageOfDirectoryWithName: thumbUrl];
                        
                    }
                    messageData = [NSBubbleData dataWithImage:thumbImg type:BubbleTypeSomeoneElse time:[AppUtils stringTimeFromInterval: timeInterval] status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:descriptionStr withTypeMessage:imageMessage isGroup:NO ofUser:nil];
                }
            }
        }else if ([typeMessage isEqualToString:videoMessage]){
            if ([USERNAME isEqualToString: sendPhone]) {
                UIView *videoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 45)];
                messageData = [NSBubbleData dataWithView:videoView type:BubbleTypeMine insets:UIEdgeInsetsMake(15, 5, 15, 10) time:[AppUtils stringTimeFromInterval: timeInterval] status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:thumbUrl withTypeMessage: videoMessage isGroup:NO ofUser:nil];
            }else{
                UIView *videoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 45)];
                
                messageData = [NSBubbleData dataWithView:videoView type:BubbleTypeSomeoneElse insets:UIEdgeInsetsMake(15, 12, 15, 5) time:[AppUtils stringTimeFromInterval:timeInterval] status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:thumbUrl withTypeMessage:videoMessage isGroup:NO ofUser:nil];
            }
        }else if ([typeMessage isEqualToString: descriptionMessage]){
            // Tin nhắn mô tả
            messageData = [NSBubbleData dataWithText:content type:BubbleTypeMine time:[AppUtils stringTimeFromInterval: timeInterval] status:statusMsg idMessage:idMsgStr withExpireTime:-1 isRecall:@"NO" description: @"" withTypeMessage: descriptionMessage isGroup:NO ofUser:nil];
        }else if ([typeMessage isEqualToString:locationMessage]){
            // Tin nhắn vị trí
            NSString *extraStr = [dict objectForKey:@"extra"];
            NSString *descStr = [dict objectForKey:@"description"];
            
            NSString *descriptionStr = [NSString stringWithFormat:@"%@|%@", extraStr, descStr];
            if ([USERNAME isEqualToString: sendPhone]) {
                if ([thumbUrl isEqualToString:@""]) {
                    messageData = [NSBubbleData dataWithImage:[UIImage imageNamed:@"unloaded-map.png"] type:BubbleTypeMine time:[AppUtils stringTimeFromInterval: timeInterval] status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:descriptionStr withTypeMessage:locationMessage isGroup:NO ofUser:nil];
                }else{
                    UIImage *thumbImg = [AppUtils getImageOfDirectoryWithName: thumbUrl];
                    messageData = [NSBubbleData dataWithImage:thumbImg type:BubbleTypeMine time:[AppUtils stringTimeFromInterval: timeInterval] status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:descriptionStr withTypeMessage:locationMessage isGroup:NO ofUser:nil];
                }
            }else{
                if ([thumbUrl isEqualToString:@""]) {
                    messageData = [NSBubbleData dataWithImage:[UIImage imageNamed:@"unloaded-map.png"] type:BubbleTypeSomeoneElse time:[AppUtils stringTimeFromInterval: timeInterval] status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:descriptionStr withTypeMessage:locationMessage isGroup:NO ofUser:nil];
                }else{
                    UIImage *thumbImg = [AppUtils getImageOfDirectoryWithName: thumbUrl];
                    messageData = [NSBubbleData dataWithImage:thumbImg type:BubbleTypeSomeoneElse time:[AppUtils stringTimeFromInterval: timeInterval] status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:descriptionStr withTypeMessage:locationMessage isGroup:NO ofUser:nil];
                }
            }
        }else if ([typeMessage isEqualToString:contactMessage]){
            if ([USERNAME isEqualToString:sendPhone]) {
                UIView *contactView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 140)];
                messageData = [NSBubbleData dataWithView:contactView type:BubbleTypeMine insets:UIEdgeInsetsMake(15, 12, 15, 5) time:[AppUtils stringTimeFromInterval: timeInterval] status:statusMsg idMessage:idMsgStr  withExpireTime:expTime isRecall:isRecall description:descriptionStr withTypeMessage:contactMessage isGroup:NO ofUser:nil];
            }else{
                UIView *contactView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 140)];
                messageData = [NSBubbleData dataWithView:contactView type:BubbleTypeSomeoneElse insets:UIEdgeInsetsMake(15, 12, 15, 5) time:[AppUtils stringTimeFromInterval: timeInterval] status:statusMsg idMessage:idMsgStr  withExpireTime:expTime isRecall:isRecall description:descriptionStr withTypeMessage:contactMessage isGroup:NO ofUser:nil];
            }
        }
    }
    [rs close];
    return messageData;
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

// Cập nhật nội dung của message nhận
+ (BOOL)updateMessageDelivered: (NSString *)idMessage withValue: (int)status{
    BOOL result = NO;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT expire_time FROM message WHERE id_message = '%@' AND send_phone = '%@'", idMessage, USERNAME];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        int expireTime = [[rsDict objectForKey:@"expire_time"] intValue];
        if (expireTime > 0) {
            NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
            int last_time_expire = (int)curTime + expireTime;
            
            NSString *updateSQL = [NSString stringWithFormat:@"UPDATE message SET delivered_status = %d, last_time_expire = %d  WHERE id_message = '%@' AND send_phone='%@'", status, last_time_expire, idMessage, USERNAME];
            result = [appDelegate._database executeUpdate: updateSQL];
        }else{
            NSString *updateSQL = [NSString stringWithFormat:@"UPDATE message SET delivered_status = %d  WHERE id_message = '%@' AND send_phone='%@'", status, idMessage, USERNAME];
            result = [appDelegate._database executeUpdate: updateSQL];
        }
    }
    return result;
}

/*----- Cập nhật trạng thái của message bị lỗi -----*/
+ (BOOL)updateMessageDeliveredError: (NSString *)idMessage{
    BOOL result = NO;
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE message SET delivered_status = 0  WHERE id_message = '%@' AND send_phone='%@'", idMessage, USERNAME];
    result = [appDelegate._database executeUpdate: tSQL];
    return result;
}

// Get lịch sử tin nhắn giữa hai số
+ (NSMutableArray *)getListMessagesHistory: (NSString*)myID withPhone: (NSString*)friendID {
    LinphoneAppDelegate *appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray *listContentMessage = [[NSMutableArray alloc] init];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM message WHERE ((send_phone='%@' AND receive_phone='%@') OR (send_phone='%@' AND receive_phone='%@')) AND (room_id = '' OR room_id = '0')", myID, friendID, friendID, myID];
    FMResultSet *rs = [appDelegate._database executeQuery:tSQL];
    while ([rs next]) {
        NSDictionary *dict  = [rs resultDictionary];
        NSString *sendPhone = [dict objectForKey:@"send_phone"];
        NSString *receivePhone = [dict objectForKey:@"receive_phone"];
        int timeInterval   = [[dict objectForKey:@"time"] intValue];
        NSString *content   = [dict objectForKey:@"content"];
        int statusMsg   = [[dict objectForKey:@"delivered_status"] intValue];
        NSString *idMessage = [dict objectForKey:@"id_message"];
        NSString *isRecall = [dict objectForKey:@"is_recall"];
        NSString *detailsUrl = [dict objectForKey:@"details_url"];
        NSString *thumbUrl = [dict objectForKey:@"thumb_url"];
        NSString *typeMessage = [dict objectForKey:@"type_message"];
        int expTime = [[dict objectForKey:@"expire_time"] intValue];
        NSString *descriptionStr = [dict objectForKey:@"description"];
        NSString *status = [dict objectForKey:@"status"];
        
        MessageEvent *aMessage = [[MessageEvent alloc] init];
        aMessage.idMessage = idMessage;
        aMessage.status = status;
        aMessage.sendPhone = sendPhone;
        aMessage.receivePhone = receivePhone;
        aMessage.deliveredStatus = statusMsg;
        aMessage.content = content;
        aMessage.detailsUrl = detailsUrl;
        aMessage.thumbUrl = thumbUrl;
        aMessage.typeMessage = typeMessage;
        aMessage.time = timeInterval;
        aMessage.description = descriptionStr;
        aMessage.isRecall = isRecall;
        aMessage.dateTime = [NSString stringWithFormat:@"%@ %@", [AppUtils getDateStringFromTimeInterval:timeInterval], [AppUtils getTimeStringFromTimeInterval:timeInterval]];
        if ([isRecall isEqualToString:@"YES"]) {
            NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithString: [localization localizedStringForKey:TEXT_MESSSAGE_RECEIVED_RECALLED]];
            
            aMessage.contentAttrString = contentString;
        }else{
            aMessage.contentAttrString = [AppUtils convertMessageStringToEmojiString: content];
        }
        if (expTime == 1) {
            aMessage.isBurn = YES;
        }else{
            aMessage.isBurn = NO;
        }
        
        [listContentMessage addObject: aMessage];
    }
    [rs close];
    return listContentMessage;
}

// Get lịch sử tin nhắn giữa hai số
+ (NSMutableArray *)getListMessagesHistory: (NSString*)myID withPhone: (NSString*)friendID withCurrentPage: (int)curPage andNumPerPage: (int)numPerPage {
    LinphoneAppDelegate *appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray *listContentMessage = [[NSMutableArray alloc] init];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM message WHERE ((send_phone='%@' AND receive_phone='%@') OR (send_phone='%@' AND receive_phone='%@')) AND (room_id = '' OR room_id = '0') ORDER BY id DESC LIMIT %d,%d", myID, friendID, friendID, myID, curPage*numPerPage,numPerPage];
    FMResultSet *rs = [appDelegate._database executeQuery:tSQL];
    while ([rs next]) {
        NSDictionary *dict  = [rs resultDictionary];
        NSString *sendPhone = [dict objectForKey:@"send_phone"];
        NSString *receivePhone = [dict objectForKey:@"receive_phone"];
        int timeInterval   = [[dict objectForKey:@"time"] intValue];
        NSString *content   = [dict objectForKey:@"content"];
        int statusMsg   = [[dict objectForKey:@"delivered_status"] intValue];
        NSString *idMessage = [dict objectForKey:@"id_message"];
        NSString *isRecall = [dict objectForKey:@"is_recall"];
        NSString *detailsUrl = [dict objectForKey:@"details_url"];
        NSString *thumbUrl = [dict objectForKey:@"thumb_url"];
        NSString *typeMessage = [dict objectForKey:@"type_message"];
        int expTime = [[dict objectForKey:@"expire_time"] intValue];
        NSString *descriptionStr = [dict objectForKey:@"description"];
        NSString *status = [dict objectForKey:@"status"];
        
        MessageEvent *aMessage = [[MessageEvent alloc] init];
        aMessage.idMessage = idMessage;
        aMessage.status = status;
        aMessage.sendPhone = sendPhone;
        aMessage.receivePhone = receivePhone;
        aMessage.deliveredStatus = statusMsg;
        aMessage.content = content;
        aMessage.detailsUrl = detailsUrl;
        aMessage.thumbUrl = thumbUrl;
        aMessage.typeMessage = typeMessage;
        aMessage.time = timeInterval;
        aMessage.description = descriptionStr;
        aMessage.isRecall = isRecall;
        aMessage.dateTime = [NSString stringWithFormat:@"%@ %@", [AppUtils getDateStringFromTimeInterval:timeInterval], [AppUtils getTimeStringFromTimeInterval:timeInterval]];
        if ([isRecall isEqualToString:@"YES"]) {
            NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithString: [localization localizedStringForKey:TEXT_MESSSAGE_RECEIVED_RECALLED]];
            
            aMessage.contentAttrString = contentString;
        }else{
            aMessage.contentAttrString = [AppUtils convertMessageStringToEmojiString: content];
        }
        if (expTime == 1) {
            aMessage.isBurn = YES;
        }else{
            aMessage.isBurn = NO;
        }
        [listContentMessage insertObject:aMessage atIndex:0];
    }
    [rs close];
    return listContentMessage;
}

// Cập nhật trạng thái đã đọc khi vào view chat
+ (void)changeStatusMessageAFriend: (NSString*)user {
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE message SET status = 'YES' WHERE ((receive_phone='%@' AND send_phone='%@') OR (send_phone='%@' AND receive_phone='%@')) AND room_id = '%@'", USERNAME, user, USERNAME, user, @""];
    [appDelegate._database executeUpdate: tSQL];
}

// Save ảnh của tin nhắn đc forward và trả về dictionay chứa tên của thumb image và detail images
+ (NSDictionary *)copyImageOfMessageForward: (NSString *)idMsgForward{
    NSString *detailsName = @"";
    NSString *thumbName = @"";
    NSString *desc = @"";
    
    NSString *tSQL = [NSString stringWithFormat:@"SELECT details_url, thumb_url, description FROM message WHERE id_message = '%@'", idMsgForward];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *detailsUrl = [rsDict objectForKey:@"details_url"];
        NSString *thumbUrl   = [rsDict objectForKey:@"thumb_url"];
        desc = [rsDict objectForKey:@"description"];
        
        NSString *detailData = [AppUtils getImageDataStringOfDirectoryWithName: detailsUrl];
        NSString *thumbData = [AppUtils getImageDataStringOfDirectoryWithName: thumbUrl];
        
        //  Save anh
        detailsName = [NSString stringWithFormat:@"forward_%@.jpg", [AppUtils randomStringWithLength: 8]];
        thumbName = [NSString stringWithFormat:@"forward_thumb_%@.jpg", [AppUtils randomStringWithLength:6]];
        
        [self saveImageToDocumentWithName:detailsName andImageData:detailData];
        [self saveImageToDocumentWithName:thumbName andImageData:thumbData];
    }
    [rs close];
    return [[NSDictionary alloc] initWithObjectsAndKeys:detailsName,@"detail",thumbName,@"thumb", desc, @"description", nil];
}

/*--Cập nhật trạng thái message khi send file thất bại--*/
+ (BOOL)updateMessageWhenSendFileFailed: (NSString *)idMessage{
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE message SET delivered_status = 0 WHERE id_message = '%@'", idMessage];
    BOOL result = [appDelegate._database executeUpdate: tSQL];
    return result;
}

// Cập nhật nội dung của message send file sau khi send xong
+ (BOOL)updateDeliveredMessageAfterSend: (NSString *)idMessage
{
    BOOL result = NO;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT expire_time FROM message WHERE id_message = '%@' AND send_phone = '%@'", idMessage, USERNAME];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        int expireTime = [[rsDict objectForKey:@"expire_time"] intValue];
        if (expireTime > 0) {
            NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
            int last_time_expire = (int)curTime + expireTime;
            
            NSString *updateSQL = [NSString stringWithFormat:@"UPDATE message SET delivered_status = 2, last_time_expire = %d  WHERE id_message = '%@' AND send_phone='%@'", last_time_expire, idMessage, USERNAME];
            result = [appDelegate._database executeUpdate: updateSQL];
        }else{
            NSString *updateSQL = [NSString stringWithFormat:@"UPDATE message SET delivered_status = 2  WHERE id_message = '%@' AND send_phone='%@'", idMessage, USERNAME];
            result = [appDelegate._database executeUpdate: updateSQL];
        }
    }
    return result;
}

// Hàm get details url của message cho resend
+ (NSString *)getDetailUrlForMessageResend: (NSString *)idMessage {
    NSString *detailUrl = @"";
    NSString *tSQL = [NSString stringWithFormat:@"SELECT details_url FROM message WHERE id_message = '%@'", idMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        detailUrl = [rsDict objectForKey:@"details_url"];
    }
    [rs close];
    return detailUrl;
}

+ (void)updateImageMessageUserWithId: (NSString *)idMsgImage andDetailURL: (NSString *)detailURL andThumbURL: (NSString *)thumbURL andContent: (NSString *)link
{
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE message SET content = '%@', thumb_url = '%@', details_url = '%@' WHERE id_message = '%@'", link, thumbURL, detailURL, idMsgImage];
    BOOL result = [appDelegate._database executeUpdate: updateSQL];
    if (result) {
        NSLog(@"-----Update tin nhan hinh anh thanh cong");
    }else{
        NSLog(@"-----Update tin nhan hinh anh that bai");
    }
}

// Hàm remove details của 1 message
+ (void)deleteDetailsOfMessageWithId: (NSString *)idMessage{
    NSString *tSQL = [NSString stringWithFormat:@"SELECT type_message, thumb_url, details_url FROM message WHERE id_message='%@'", idMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *typeMessage = [rsDict objectForKey:@"type_message"];
        if (![typeMessage isEqualToString:typeTextMessage]) {
            NSString *thumb_url     = [rsDict objectForKey:@"thumb_url"];
            NSString *details_url   = [rsDict objectForKey:@"details_url"];
            [AppUtils deleteDetailsFileOfMessage:typeTextMessage andDetails:details_url andThumb:thumb_url];
        }
    }
    [rs close];
}

/*--Save ảnh với tham số truyền vào là tên ảnh muốn save và data của ảnh--*/
+ (void)saveImageToDocumentWithName: (NSString *)imageName andImageData: (NSString *)dataStr{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *pathFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/files/%@", imageName]];
    NSData *imageData = [NSData dataFromBase64String: dataStr];
    [imageData writeToFile:pathFile atomically:YES];
}

/*--Get ảnh đại diện của một video--*/
+ (UIImage *)getThumbImageOfVideo: (NSString *)videoName{
    NSURL *videoUrl = [self getUrlOfVideoFile: videoName];
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:videoUrl];
    UIImage  *thumbnail = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
    player = nil;
    return thumbnail;
}

/*--Hàm trả về đường dẫn đến file video--*/
+ (NSURL *)getUrlOfVideoFile: (NSString *)fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pathFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/videos/%@", fileName]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath: pathFile];
    
    if (!fileExists) {
        return nil;
    }else{
        return [[NSURL alloc] initFileURLWithPath: pathFile];
    }
}

+ (NSMutableArray *)getListOccupantsInGroup: (NSString *)roomName ofAccount: (NSString *)account {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT chat_user FROM room_user WHERE account = '%@' AND room_name = '%@' AND chat_user != ''", account, roomName];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *chat_user = [rsDict objectForKey:@"chat_user"];
        [list addObject: chat_user];
    }
    [rs close];
    return list;
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

// Xóa conversation của mình với user
+ (BOOL)deleteConversationOfMeWithUser: (NSString *)user
{
    BOOL result = FALSE;
    [appDelegate._database beginTransaction];
    // Xoa text message truoc
    NSString *delMsgSQL = [NSString stringWithFormat:@"DELETE FROM message WHERE ((send_phone = '%@' AND receive_phone = '%@') OR (send_phone = '%@' AND receive_phone = '%@')) AND (room_id = '0' OR room_id = '') AND type_message = '%@'", USERNAME, user, user, USERNAME, typeTextMessage];
    result = [appDelegate._database executeUpdate: delMsgSQL];
    if (result)
    {
        NSString *tSQL = [NSString stringWithFormat:@"SELECT id_message FROM message WHERE ((send_phone='%@' AND receive_phone='%@') OR (send_phone='%@' AND receive_phone='%@')) AND (room_id = '0' OR room_id = '')", USERNAME, user, user, USERNAME];
        FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
        while ([rs next]) {
            NSDictionary *rsDict = [rs resultDictionary];
            NSString *idMessage = [rsDict objectForKey:@"id_message"];
            [self deleteOneMessageWithId: idMessage];
        }
        NSString *delConSQL = [NSString stringWithFormat:@"DELETE FROM conversation WHERE account = '%@' AND user = '%@'", USERNAME, user];
        result = [appDelegate._database executeUpdate: delConSQL];
        if (!result) {
            [appDelegate._database rollback];
        }
    }
    [appDelegate._database commit];
    return result;
}

//  Get room name của phòng
+ (NSString *)getRoomNameOfRoomWithRoomId: (int)roomId{
    NSString *roomName = @"";
    NSString *tSQL = [NSString stringWithFormat:@"SELECT room_name FROM room_chat WHERE id = %d AND user = '%@'", roomId, USERNAME];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        roomName = [rsDict objectForKey:@"room_name"];
    }
    [rs close];
    return roomName;
}

//  Get subject của room chat
+ (NSString *)getSubjectOfRoom: (NSString *)roomName {
    NSString *resultStr = welcomeToCloudFone;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT subject FROM room_chat WHERE user = '%@' AND room_name = '%@'", USERNAME, roomName];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        resultStr = [rsDict objectForKey:@"subject"];
    }
    [rs close];
    return resultStr;
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







//  Get tất cả các message chưa đọc của 1 room chat
+ (int)getNumberMessageUnreadOfRoom: (NSString *)roomID {
    int number = 0;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT COUNT(*) as count FROM message WHERE (send_phone = '%@' OR receive_phone = '%@') AND status = 'NO' AND room_id = '%@'", USERNAME, USERNAME, roomID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        number = [[dict objectForKey:@"count"] intValue];
    }
    [rs close];
    return number;
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

//  Lưu background chat của group vào conversation
+ (BOOL)saveBackgroundChatForRoom: (NSString *)roomID withBackground: (NSString *)background {
    BOOL result = false;
    BOOL exists = false;
    
    //  kiểm tra record đã tồn tại hay chưa: chưa thì thêm mới, tồn tại thì update
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id FROM conversation WHERE account = '%@' AND room_id = '%@' LIMIT 0,1", USERNAME, roomID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        exists = true;
    }
    [rs close];
    
    if (exists) {
        NSString *tSQL2 = [NSString stringWithFormat:@"UPDATE conversation SET background = '%@' WHERE account = '%@' AND room_id = '%@'", background, USERNAME, roomID];
        result = [appDelegate._database executeUpdate: tSQL2];
    }else{
        NSString *tSQL2 = [NSString stringWithFormat:@"INSERT INTO conversation (account, user, room_id, background, expire, inear_mode) VALUES ('%@', '%@', '%@', '%@', %d, %d)", USERNAME, @"", roomID, background, -1, 0];
        result = [appDelegate._database executeUpdate: tSQL2];
    }
    return result;
}

//  Lưu background chat của user vào conversation
+ (BOOL)saveBackgroundChatForUser: (NSString *)user withBackground: (NSString *)background {
    BOOL result = false;
    BOOL exists = false;
    
    //  kiểm tra record đã tồn tại hay chưa: chưa thì thêm mới, tồn tại thì update
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id FROM conversation WHERE account = '%@' AND user = '%@' LIMIT 0,1", USERNAME, user];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        exists = true;
    }
    [rs close];
    
    if (exists) {
        NSString *tSQL2 = [NSString stringWithFormat:@"UPDATE conversation SET background = '%@' WHERE account = '%@' AND user = '%@'", background, USERNAME, user];
        result = [appDelegate._database executeUpdate: tSQL2];
    }else{
        NSString *tSQL2 = [NSString stringWithFormat:@"INSERT INTO conversation (account, user, room_id, background, expire, inear_mode) VALUES ('%@', '%@', '%@', '%@', %d, %d)", USERNAME, user, @"0", background, -1, 0];
        result = [appDelegate._database executeUpdate: tSQL2];
    }
    return result;
}

// Get danh sách ID của các message hết hạn của một group (để remove khỏi list chat)
+ (NSArray *)getAllMessageExpireEndedOfMeWithGroup: (int)groupID
{
    NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
    
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id_message FROM message WHERE (send_phone='%@' OR receive_phone='%@') AND status = 'YES' AND delivered_status = 2 AND last_time_expire > 0 AND last_time_expire <= %d AND room_id = %d", USERNAME, USERNAME, (int)curTime, groupID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *idMessage = [rsDict objectForKey:@"id_message"];
        [resultArr addObject: idMessage];
    }
    [rs close];
    return  resultArr;
}

//  Lấy background đã lưu cho view chat room
+ (NSString *)getChatBackgroundForRoom: (NSString *)roomID {
    NSString *result = @"";
    NSString *tSQL = [NSString stringWithFormat:@"SELECT background FROM conversation WHERE account = '%@' AND room_id = '%@'", USERNAME, roomID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        result = [rsDict objectForKey:@"background"];
    }
    [rs close];
    return result;
}

//  Hàm delete tất cả message của 1 user
+ (void)deleteAllMessageOfRoomChat:(NSString *)roomID {
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM message WHERE (send_phone = '%@' OR receive_phone = '%@') AND room_id = '%@'", USERNAME, USERNAME, roomID];
    [appDelegate._database executeUpdate: tSQL];
}

//  Get lịch sử message của room chat
+ (NSMutableArray *)getListMessagesOfAccount: (NSString *)account withRoomID: (NSString *)roomID {
    NSMutableArray *listContentMessage = [[NSMutableArray alloc] init];
    
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM message WHERE room_id = '%@' AND (send_phone = '%@' OR receive_phone = '%@')", roomID, account, account];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *idMessage = [rsDict objectForKey:@"id_message"];
        NSString *sendPhone = [rsDict objectForKey:@"send_phone"];
        int timeInterval   = [[rsDict objectForKey:@"time"] intValue];
        NSString *content   = [rsDict objectForKey:@"content"];
        int statusMsg   = [[rsDict objectForKey:@"delivered_status"] intValue];
        
        NSString *isRecall = [rsDict objectForKey:@"is_recall"];
        NSString *typeMessage = [rsDict objectForKey:@"type_message"];
        NSString *detailsUrl = [rsDict objectForKey:@"details_url"];
        NSString *thumbUrl = [rsDict objectForKey:@"thumb_url"];
        NSString *descriptionStr = [rsDict objectForKey:@"description"];
        NSString *roomID = [rsDict objectForKey:@"room_id"];
        
        MessageEvent *aMessage = [[MessageEvent alloc] init];
        aMessage.idMessage = idMessage;
        aMessage.sendPhone = sendPhone;
        aMessage.receivePhone = @"";
        aMessage.deliveredStatus = statusMsg;
        aMessage.content = content;
        aMessage.detailsUrl = detailsUrl;
        aMessage.thumbUrl = thumbUrl;
        aMessage.typeMessage = typeMessage;
        aMessage.time = timeInterval;
        aMessage.description = descriptionStr;
        aMessage.isRecall = isRecall;
        aMessage.dateTime = [NSString stringWithFormat:@"%@ %@", [AppUtils getDateStringFromTimeInterval:timeInterval], [AppUtils getTimeStringFromTimeInterval:timeInterval]];
        aMessage.contentAttrString = [AppUtils convertMessageStringToEmojiString: content];
        aMessage.roomID = roomID;
        
        if (![sendPhone isEqualToString: account]) {
            NSString *sendPhoneName = [NSDatabase getNameOfContactWithPhoneNumber: sendPhone];
            if ([sendPhoneName isEqualToString:@""]) {
                sendPhoneName = sendPhone;
            }
            aMessage.sendPhoneName = sendPhoneName;
        }
        
        [listContentMessage addObject: aMessage];
    }
    [rs close];
    return listContentMessage;
}

//  Get lịch sử message của room chat
+ (NSMutableArray *)getListMessagesOfAccount: (NSString *)account withRoomID: (NSString *)roomID withCurrentPage: (int)curPage andNumPerPage: (int)numPerPage {
    NSMutableArray *listContentMessage = [[NSMutableArray alloc] init];
    
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM message WHERE room_id = '%@' AND (send_phone = '%@' OR receive_phone = '%@') ORDER BY id DESC LIMIT %d,%d", roomID, account, account, curPage*numPerPage,numPerPage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *idMessage = [rsDict objectForKey:@"id_message"];
        NSString *sendPhone = [rsDict objectForKey:@"send_phone"];
        int timeInterval   = [[rsDict objectForKey:@"time"] intValue];
        NSString *content   = [rsDict objectForKey:@"content"];
        int statusMsg   = [[rsDict objectForKey:@"delivered_status"] intValue];
        
        NSString *isRecall = [rsDict objectForKey:@"is_recall"];
        NSString *typeMessage = [rsDict objectForKey:@"type_message"];
        NSString *detailsUrl = [rsDict objectForKey:@"details_url"];
        NSString *thumbUrl = [rsDict objectForKey:@"thumb_url"];
        NSString *descriptionStr = [rsDict objectForKey:@"description"];
        NSString *roomID = [rsDict objectForKey:@"room_id"];
        
        MessageEvent *aMessage = [[MessageEvent alloc] init];
        aMessage.idMessage = idMessage;
        aMessage.sendPhone = sendPhone;
        aMessage.receivePhone = @"";
        aMessage.deliveredStatus = statusMsg;
        aMessage.content = content;
        aMessage.detailsUrl = detailsUrl;
        aMessage.thumbUrl = thumbUrl;
        aMessage.typeMessage = typeMessage;
        aMessage.time = timeInterval;
        aMessage.description = descriptionStr;
        aMessage.isRecall = isRecall;
        aMessage.dateTime = [NSString stringWithFormat:@"%@ %@", [AppUtils getDateStringFromTimeInterval:timeInterval], [AppUtils getTimeStringFromTimeInterval:timeInterval]];
        aMessage.contentAttrString = [AppUtils convertMessageStringToEmojiString: content];
        aMessage.roomID = roomID;
        
        if (![sendPhone isEqualToString: account]) {
            NSString *sendPhoneName = [NSDatabase getNameOfContactWithPhoneNumber: sendPhone];
            if ([sendPhoneName isEqualToString:@""]) {
                sendPhoneName = sendPhone;
            }
            aMessage.sendPhoneName = sendPhoneName;
        }
        [listContentMessage insertObject:aMessage atIndex:0];
    }
    [rs close];
    return listContentMessage;
}

//  Cập nhật các tin nhắn chưa đọc thành đã đọc cho room chat
+ (void)updateAllMessagesInRoomChat: (NSString *)roomID withAccount: (NSString *)account {
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE message SET status = 'YES' WHERE (receive_phone = '%@' OR send_phone = '%@') AND room_id = '%@'", account, account, roomID];
    [appDelegate._database executeUpdate: tSQL];
}

//  Tạo mới room chat trong database nếu chưa tồn tại
+ (BOOL)createRoomChatInDatabase: (NSString *)roomName andGroupName: (NSString *)groupName withSubject: (NSString *)subject {
    int count = 0;
    BOOL result = false;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT COUNT(*) as numResult  FROM room_chat WHERE room_name = '%@'", roomName];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *resultDict = [rs resultDictionary];
        count = [[resultDict objectForKey:@"numResult"] intValue];
    }
    [rs close];
    
    //  count = 0: room chưa tồn tại trong database
    if (count == 0) {
        NSString *curDate = [AppUtils getCurrentDate];
        NSString *curTime = [AppUtils getCurrentTimeStamp];
        if ([subject isEqualToString:@""]) {
            subject = welcomeToCloudFone;
        }
        
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO room_chat(room_name, group_name, date, time, status, user, subject) VALUES ('%@', '%@', '%@', '%@', %d, '%@', '%@')", roomName, groupName, curDate, curTime, 1, USERNAME, subject];
        result = [appDelegate._database executeUpdate: insertSQL];
    }
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

//  Hàm trả về contact với callnexID
+ (ContactChatObj *)getContactInfoWithCallnexID: (NSString *)callnexID {
    ContactChatObj *aObject = nil;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM contact WHERE callnex_id = '%@' ORDER BY id_contact DESC LIMIT 0,1", callnexID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        
        int idContact = [[rsDict objectForKey:@"id_contact"] intValue];
        NSString *firstName = [rsDict objectForKey:@"first_name"];
        NSString *lastName  = [rsDict objectForKey:@"last_name"];
        NSString *fullName  = @"";
        if (![firstName isEqualToString:@""] && [lastName isEqualToString:@""]) {
            fullName = firstName;
        }else if ([firstName isEqualToString:@""] && ![lastName isEqualToString:@""]){
            fullName = lastName;
        }else if (![firstName isEqualToString:@""] && ![lastName isEqualToString:@""]){
            fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        }
        NSString *avatar    = [rsDict objectForKey:@"avatar"];
        NSString *callnexID = [rsDict objectForKey:@"callnex_id"];
        
        aObject = [[ContactChatObj alloc] init];
        [aObject set_idContact: idContact];
        [aObject set_fullName: fullName];
        [aObject set_callnexID: callnexID];
        [aObject set_avatar: avatar];
    }
    
    if (aObject == nil) {
        aObject = [[ContactChatObj alloc] init];
        [aObject set_idContact: -1];
        [aObject set_fullName: callnexID];
        [aObject set_callnexID: callnexID];
        [aObject set_avatar: @""];
    }
    return aObject;
}

// Kiểm tra user có trong list request hay không
+ (BOOL)checkRequestOfUser: (NSString *)userStr {
    BOOL result = false;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM request_sent WHERE account = '%@' AND user = '%@' LIMIT 0,1", USERNAME, userStr];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    if ([rs next]) {
        result = true;
    }
    [rs close];
    return result;
}

+ (BOOL)checkListAcceptOfUser: (NSString *)account withSendUser: (NSString *)sendUser {
    BOOL result = NO;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM list_for_accept WHERE account = '%@' AND user = '%@' LIMIT 0,1", account, sendUser];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        result = YES;
    }
    [rs close];
    return result;
}

/*--save expire time cho một user--*/
+ (BOOL)saveExpireTimeForUser: (NSString *)user withExpireTime: (int)expireTime {
    BOOL result;
    BOOL exists = NO;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id FROM conversation WHERE account = '%@' AND user = '%@' LIMIT 0,1", USERNAME, user];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        exists = YES;
    }
    if (exists) {
        NSString *tSQL2 = [NSString stringWithFormat:@"UPDATE conversation SET expire = %d WHERE account = '%@' AND user = '%@'", expireTime, USERNAME, user];
        result = [appDelegate._database executeUpdate: tSQL2];
    }else{
        NSString *tSQL2 = [NSString stringWithFormat:@"INSERT INTO conversation (account, user, room_id, background, expire, inear_mode) VALUES ('%@', '%@', '%@', '%@', %d, %d)", USERNAME, user, @"0", @"", expireTime, 0];
        result = [appDelegate._database executeUpdate: tSQL2];
    }
    return result;
}

+ (BOOL)updateMessage: (NSString *)idMessage withImageName: (NSString *)imageName andThumbnail: (NSString *)thumbnail {
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE message SET details_url = '%@', thumb_url = '%@' WHERE id_message = '%@'", imageName, thumbnail, idMessage];
    return [appDelegate._database executeUpdate: tSQL];
}

//  Xoá tất cả các user trong request list hiện tại
+ (void)removeAllUserFromRequestList {
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM list_for_accept WHERE account = '%@'", USERNAME];
    [appDelegate._database executeUpdate: tSQL];
}

// resend tất cả msg đã send thất bại của user
+ (void)resendAllFailedMessageOfAccount: (NSString *)account {
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id_message FROM fail_message WHERE account = '%@'", account];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *idMsg = [rsDict objectForKey:@"id_message"];
        NSArray *msgInfo = [self getInfoForSendFailedMessage: idMsg];
        if (![[msgInfo objectAtIndex: 0] isEqualToString:@""]) {
            BOOL secure = false;
            OTRBuddy *userBuddy = [AppUtils getBuddyOfUserOnList: [msgInfo objectAtIndex: 0]];
            if (userBuddy.encryptionStatus == kOTRKitMessageStateEncrypted) {
                secure = true;
            }
            [userBuddy sendMessage: [msgInfo objectAtIndex: 1] secure:secure withIdMessage:idMsg];
        }
    }
    [rs close];
}

//  Get tất cả các room chat hiện tại
+ (NSMutableArray *)getAllRoomChatOfAccount: (NSString *)account {
    NSMutableArray *rsArray = [[NSMutableArray alloc] init];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM room_chat WHERE user = '%@' AND status = 1", account];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        RoomObject *aRoom = [[RoomObject alloc] init];
        NSDictionary *resultDict = [rs resultDictionary];
        
        int roomID          = [[resultDict objectForKey:@"id"] intValue];
        NSString *roomName  = [resultDict objectForKey:@"room_name"];
        NSString *groupName = [resultDict objectForKey:@"group_name"];
        NSString *subject   = [resultDict objectForKey:@"subject"];
        
        [aRoom set_roomID: roomID];
        [aRoom set_roomName: roomName];
        [aRoom set_gName: groupName];
        [aRoom set_roomMember: 0];
        [aRoom set_roomSubject: subject];
        
        [rsArray addObject: aRoom];
    }
    [rs close];
    return rsArray;
}

// Get receivePhone và nội dung của message fail
+ (NSArray *)getInfoForSendFailedMessage: (NSString *)idMessage
{
    NSString *receivePhone = @"";
    NSString *content = @"";
    
    NSString *tSQL = [NSString stringWithFormat:@"SELECT receive_phone, content FROM message WHERE id_message = '%@' LIMIT 0,1", idMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        receivePhone = [rsDict objectForKey:@"receive_phone"];
        content = [rsDict objectForKey:@"content"];
    }
    [rs close];
    return [NSArray arrayWithObjects:receivePhone, content, nil];
}

+ (NSMutableArray *)getListPictureFromMessageOf: (NSString *)account withRemoteParty: (NSString *)remoteParty
{
    NSMutableArray *listPicture = [[NSMutableArray alloc] init];
    
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id_message, expire_time, status, type_message, details_url, thumb_url, description, content, send_phone  FROM message WHERE (type_message = '%@' OR type_message = '%@') AND ((send_phone = '%@' AND receive_phone = '%@') OR (send_phone = '%@' AND receive_phone = '%@')) ORDER BY id DESC", imageMessage, videoMessage, account, remoteParty, remoteParty, account];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        [listPicture addObject: rsDict];
    }
    [rs close];
    return listPicture;
}

+ (NSMutableArray *)getListPictureFromMessageOf: (NSString *)account withRoomChat: (NSString *)roomName
{
    NSMutableArray *listPicture = [[NSMutableArray alloc] init];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id_message, status, type_message, details_url, thumb_url, description, content, send_phone  FROM message WHERE (type_message = '%@' OR type_message = '%@') AND room_id = '%@' ORDER BY id DESC", imageMessage, videoMessage, roomName];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        [listPicture addObject: rsDict];
    }
    [rs close];
    return listPicture;
}

+ (BOOL)checkVideoHadDownloadedFromServer: (NSString *)videoName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pathFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/videos/%@", videoName]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath: pathFile];
    if (fileExists) {
        return YES;
    }
    return NO;
}

+ (BOOL)updateContent: (NSString *)content forMessage: (NSString *)idMessage {
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE message SET content = '%@' WHERE id_message = '%@'", content, idMessage];
    return [appDelegate._database executeUpdate: tSQL];
}

+ (BOOL)setRecallForMessage: (NSString *)idMessage {
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE message SET content = '%@', is_recall = '%@' WHERE id_message = '%@'", @"", @"YES", idMessage];
    return [appDelegate._database executeUpdate: tSQL];
}

+ (NSMutableArray *)getAllMessageUnseenReceivedOfRemoteParty: (NSString *)remoteParty
{
    NSMutableArray *listIds = [[NSMutableArray alloc] init];
    
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id_message FROM message WHERE status = 'NO' AND (send_phone = '%@'  AND receive_phone = '%@') AND (expire_time != 1 OR (expire_time = 1 AND type_message = '%@'))", remoteParty, USERNAME, typeTextMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *idMessage = [rsDict objectForKey:@"id_message"];
        [listIds addObject: idMessage];
    }
    [rs close];
    return listIds;
}

+ (void)updateAllMessageUnSeenReceivedOfRemoteParty: (NSString *)remoteParty
{
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE message SET status = 'YES' WHERE (send_phone = '%@'  AND receive_phone = '%@') AND status = 'NO' AND (expire_time != 1 OR (expire_time = 1 AND type_message = '%@'))", remoteParty, USERNAME, typeTextMessage];
    [appDelegate._database executeUpdate: tSQL];
}

// Cập nhật trạng thái đã đọc cho message
+ (void)updateSeenStatusForMessage: (NSString*)idMessage {
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE message SET status = 'YES' WHERE id_message = '%@'", idMessage];
    [appDelegate._database executeUpdate: tSQL];
}

+ (void)deleteTextAndLocationBurnMessageOfRemoteParty: (NSString *)remoteParty {
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM Message WHERE ((send_phone = '%@' AND receive_phone = '%@') OR (send_phone = '%@' AND receive_phone = '%@')) AND expire_time != 0 AND status = 'YES' AND type_message = '%@'", USERNAME, remoteParty, remoteParty, USERNAME, typeTextMessage];
    [appDelegate._database executeUpdate: tSQL];
}

+ (void)deleteMediaBurnMessageOfRemoteParty: (NSString *)remoteParty {
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id_message FROM Message WHERE ((send_phone = '%@' AND receive_phone = '%@') OR (send_phone = '%@' AND receive_phone = '%@')) AND expire_time != 0 AND status = 'YES' AND (type_message = '%@' OR type_message = '%@')", USERNAME, remoteParty, remoteParty, USERNAME, imageMessage, videoMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *idMessage = [rsDict objectForKey:@"id_message"];
        [self deleteOneMessageWithId: idMessage];
    }
}

#pragma mark - new message

//  Get danh sách conversation của account
+ (NSMutableArray *)getAllConversationForHistoryMessageOfUser: (NSString *)user {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    NSString *tSQL = [NSString stringWithFormat:@"SELECT DISTINCT send_phone FROM message WHERE (receive_phone = '%@' AND room_id = '') UNION SELECT DISTINCT receive_phone FROM message WHERE (send_phone = '%@' AND room_id = '')", user, user];
    //  load message tu group ko co tin nhan 27/01/2018
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *sendPhone = [rsDict objectForKey:@"send_phone"];
        if (![sendPhone isEqualToString: @""] && ![sendPhone isEqualToString: user]) {
            ConversationObject *aConversation = [NSDatabase getConversationOfUser: sendPhone];
            if (aConversation != nil) {
                [result addObject: aConversation];
            }
        }else{
            NSLog(@"User rong");
        }
    }
    [rs close];
    return result;
}

// Get 1 conversation của user
+ (ConversationObject *)getConversationOfUser: (NSString *)user {
    ConversationObject *aConversation  = nil;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT send_phone, content, time, id, type_message, is_recall FROM message WHERE ((send_phone = '%@' AND receive_phone='%@') OR (send_phone='%@' AND receive_phone='%@')) AND room_id = '' ORDER BY id DESC LIMIT 0,1", USERNAME, user, user, USERNAME];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        // Thông tin message
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *sendPhone = [rsDict objectForKey:@"send_phone"];
        NSString *content = [rsDict objectForKey:@"content"];
        int timeInterval = [[rsDict objectForKey:@"time"] intValue];
        int idRecord = [[rsDict objectForKey:@"id"] intValue];
        NSString *typeMesssage = [rsDict objectForKey:@"type_message"];
        NSString *isRecall = [rsDict objectForKey:@"is_recall"];
        
        // Tạo conversation
        aConversation = [[ConversationObject alloc] init];
        aConversation._user = user;
        aConversation._roomID = @"";
        aConversation._messageDraf = @"";
        aConversation._typeMessage = typeMesssage;
        
        if ([typeMesssage isEqualToString:imageMessage]) {
            aConversation._lastMessage = k11ImageReceivedOnMessageHistory;
        }else if ([typeMesssage isEqualToString: audioMessage]){
            aConversation._lastMessage = k11AudioReceivedOnMessageHistory;
        }else if ([typeMesssage isEqualToString: locationMessage]){
            aConversation._lastMessage = k11LocationReceivedMessage;
        }else{
            aConversation._lastMessage = content;
        }
        if ([isRecall isEqualToString:@"YES"]) {
            aConversation._isRecall = YES;
        }else{
            aConversation._isRecall = NO;
        }
        
        // Biến cho biết message gửi hay nhận
        if ([sendPhone isEqualToString: user]) {
            aConversation._isSent = NO;
        }else{
            aConversation._isSent = YES;
        }
        aConversation._date = [AppUtils stringDateFromInterval: timeInterval];
        aConversation._time = [AppUtils stringTimeFromInterval: timeInterval];
        aConversation._idMessage = idRecord;
        
        // get tên của user
        NSArray *infos = [NSDatabase getNameAndAvatarOfContactWithPhoneNumber: user];
        if (infos.count >= 2) {
            aConversation._contactName = [infos objectAtIndex: 0];
            aConversation._contactAvatar = [infos objectAtIndex: 1];
        }else{
            aConversation._contactName = @"";
            aConversation._contactAvatar = @"";
        }
        aConversation._unreadMsg = [NSDatabase getNumberMessageUnread:USERNAME andUser:user];
        aConversation._idObject = 0;
    }
    [rs close];
    return aConversation;
}

//  Get tất cả message chưa đọc của mình với 1 user
+ (int)getNumberMessageUnread: (NSString*)account andUser: (NSString*)user {
    int numberMessageUnread = 0;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT COUNT(*) as count FROM message WHERE (send_phone = '%@' AND receive_phone = '%@') AND status = 'NO' AND (room_id = '' OR room_id = '0') ", user, account];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        numberMessageUnread = [[dict objectForKey:@"count"] intValue];
    }
    [rs close];
    return numberMessageUnread;
}

// Lấy tất cả message chưa đọc
+ (int)getAllMessageUnreadForUIMainBar{
    int numMessage = 0;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT count(*) as numMessage FROM (SELECT * FROM message WHERE status = 'NO' AND receive_phone = '%@' GROUP BY send_phone);", USERNAME];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        numMessage = [[rsDict objectForKey: @"numMessage"] intValue];
    }
    [rs close];
    return numMessage;
}

+ (void)updateSeenForMessage: (NSString *)idMessage {
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE message SET status = 'YES' WHERE id_message = '%@'", idMessage];
    [appDelegate._database executeUpdate: tSQL];
}

+ (int)getTotalMessagesOfMe: (NSString *)account withRemoteParty: (NSString *)remoteParty {
    int numMessage = 0;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT count(*) as numMessage FROM message WHERE (send_phone = '%@' AND receive_phone = '%@') OR (send_phone = '%@' AND receive_phone = '%@')", account, remoteParty, remoteParty, account];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        numMessage = [[rsDict objectForKey: @"numMessage"] intValue];
    }
    [rs close];
    return numMessage;
}

+ (int)getTotalMessagesOfMe: (NSString *)account ofRoomName: (NSString *)roomName
{
    int numMessage = 0;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT count(*) as numMessage FROM message WHERE room_id = '%@'", roomName];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        numMessage = [[rsDict objectForKey: @"numMessage"] intValue];
    }
    [rs close];
    return numMessage;
}

// Thêm user đang chờ request vào bảng
+ (BOOL)addUserToRequestSent: (NSString *)user withIdRequest: (NSString *)idRequeset {
    BOOL result = false;
    [appDelegate._database beginTransaction];
    NSString *delSQL = [NSString stringWithFormat:@"DELETE FROM request_sent WHERE account = '%@' AND user = '%@'", USERNAME, user];
    result = [appDelegate._database executeUpdate: delSQL];
    if (result) {
        NSString *newSQL = [NSString stringWithFormat:@"INSERT INTO request_sent(account, user, id_request) VALUES ('%@', '%@', '%@')", USERNAME, user, idRequeset];
        result = [appDelegate._database executeUpdate: newSQL];
        if (!result) {
            [appDelegate._database rollback];
        }
    }
    [appDelegate._database commit];
    return result;
}

//  Đếm số lượng user kết bạn
+ (int)getCountListFriendsForAcceptOfAccount: (NSString *)account {
    int result = 0;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT count(*) AS number FROM list_for_accept WHERE account = '%@' ORDER BY id DESC", account];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        result = [[rsDict objectForKey:@"number"] intValue];
    }
    [rs close];
    return result;
}

//  Get danh sách kết bạn của một user
+ (NSMutableArray *)getListFriendsForAcceptOfAccount: (NSString *)account {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT user FROM list_for_accept WHERE user != '' AND account = '%@' ORDER BY id DESC", account];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        
        NSString *user = [rsDict objectForKey:@"user"];
        NSString *strAvatar = @"";
        NSData *avatarData = [self getAvatarDataFromCacheFolderForUser: user];
        if (avatarData != nil) {
            strAvatar = [avatarData base64EncodedStringWithOptions: 0];
        }
        FriendRequestedObject *aRequest = [[FriendRequestedObject alloc] init];
        [aRequest set_cloudfoneID: user];
        [aRequest set_avatar: strAvatar];
        NSString *fullName = [self getNameOfContactWithPhoneNumber: user];
        if ([fullName isEqualToString:@""]) {
            fullName = user;
        }
        [aRequest set_name: fullName];
        
        [result addObject: aRequest];
    }
    [rs close];
    return result;
}

//  Get conversation của các group chat
+ (NSMutableArray *)getAllConversationForGroupOfUser {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    NSString *tSQL = [NSString stringWithFormat:@"SELECT room_id FROM message WHERE (send_phone = '%@' OR receive_phone = '%@') AND room_id != '' GROUP BY room_id", USERNAME, USERNAME];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *roomID = [rsDict objectForKey:@"room_id"];
        ConversationObject *aConversation = [NSDatabase getConversationForGroup: roomID];
        if (aConversation != nil) {
            [result addObject: aConversation];
        }else{
            ConversationObject *aConversation = [[ConversationObject alloc] init];
            [aConversation set_user: USERNAME];
            [aConversation set_roomID: roomID];
            [aConversation set_messageDraf: @""];
            [aConversation set_typeMessage: typeTextMessage];
            aConversation._lastMessage = @"";
            [aConversation set_isRecall: false];
            [result addObject: aConversation];
        }
    }
    [rs close];
    return result;
}

//  Get 1 conversation cho group chat
+ (ConversationObject *)getConversationForGroup: (NSString *)roomID {
    ConversationObject *aConversation  = nil;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM message WHERE (send_phone = '%@' OR receive_phone='%@') AND room_id = '%@' ORDER BY id DESC LIMIT 0,1", USERNAME, USERNAME, roomID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        // Thông tin message
        NSDictionary *rsDict = [rs resultDictionary];
        
        NSString *sendPhone = [rsDict objectForKey:@"send_phone"];
        NSString *typeMessage = [rsDict objectForKey:@"type_message"];
        NSString *content = [rsDict objectForKey:@"content"];
        if (![typeMessage isEqualToString: descriptionMessage]) {
            if ([sendPhone isEqualToString:USERNAME]) {
                content = [NSString stringWithFormat:@"(%@)%@", [localization localizedStringForKey:text_you], content];
            }else{
                NSString *userName = [NSDatabase getNameOfContactWithPhoneNumber: sendPhone];
                if ([userName isEqualToString:@""]) {
                    userName = sendPhone;
                }
                content = [NSString stringWithFormat:@"(%@)%@", userName, content];
            }
        }
        
        int timeInterval = [[rsDict objectForKey:@"time"] intValue];
        int idRecord = [[rsDict objectForKey:@"id"] intValue];
        NSString *typeMesssage = [rsDict objectForKey:@"type_message"];
        NSString *isRecall = [rsDict objectForKey:@"is_recall"];
        
        // Tạo conversation
        aConversation = [[ConversationObject alloc] init];
        [aConversation set_user: USERNAME];
        [aConversation set_roomID: roomID];
        [aConversation set_messageDraf: @""];
        [aConversation set_typeMessage: typeMesssage];
        if ([typeMesssage isEqualToString:imageMessage]) {
            aConversation._lastMessage = k11ImageReceivedOnMessageHistory;
        }else if ([typeMesssage isEqualToString: audioMessage]){
            aConversation._lastMessage = k11AudioReceivedOnMessageHistory;
        }else if ([typeMesssage isEqualToString: locationMessage]){
            aConversation._lastMessage = k11LocationReceivedMessage;
        }else{
            aConversation._lastMessage = content;
        }
        if ([isRecall isEqualToString:@"YES"]) {
            [aConversation set_isRecall: true];
        }else{
            [aConversation set_isRecall: false];
        }
        
        // Biến cho biết message gửi hay nhận
        if ([sendPhone isEqualToString: USERNAME]) {
            [aConversation set_isSent: false];
        }else{
            [aConversation set_isSent: true];
        }
        
        [aConversation set_date: [AppUtils stringDateFromInterval: timeInterval]];
        [aConversation set_time: [AppUtils stringTimeFromInterval: timeInterval]];
        [aConversation set_idMessage: idRecord];
        
        // get tên của user
        NSString *groupName = [NSDatabase getSubjectOfRoom:roomID];
        [aConversation set_contactName: groupName];
        [aConversation set_contactAvatar: @""];
        
        [aConversation set_unreadMsg: [NSDatabase getNumberMessageUnreadOfRoom:roomID]];
        [aConversation set_idObject: [roomID intValue]];
    }
    [rs close];
    return aConversation;
}

@end
