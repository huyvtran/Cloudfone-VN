                                  //
//  NSDBCallnex.m
//  linphone
//
//  Created by user on 4/3/14.
//
//

#import "NSDBCallnex.h"
#import "TypePhoneContact.h"
#import "contactBlackListCell.h"
#import "MyFunctions.h"
#import "KHistoryCallObject.h"
#import "OTRConstants.h"
#import "CallHistoryObject.h"
#import "LocationHisObj.h"
#import "ConversationObject.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "FilterObject.h"
#import "RoomObject.h"
#import "NSData+Base64.h"
#import "FriendRequestedObject.h"
#import "CallnexStrings.h"

#import "PhoneObject.h"
#import "PBXContact.h"
#import "HMLocalization.h"
#import "AppFunctions.h"

#import "AppStrings.h"
#import "CallnexStrings.h"
#import "localization.h"

LinphoneAppDelegate *appDelegate;
HMLocalization *localization;

static sqlite3 *db = nil;

@implementation NSDBCallnex

//  Thêm hoặc update contact khi đồng bộ
+ (void)addNewOrUpdateContactWithCloudFoneID: (NSString *)CloudFoneID andName: (NSString *)Name andAvatar: (NSString *)Avatar andAddress: (NSString *)address andEmail: (NSString *)email
{
    BOOL exists = false;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM contact WHERE callnex_id = '%@'", CloudFoneID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        exists = true;
        NSDictionary *rsDict = [rs resultDictionary];
        
        int idContact = [[rsDict objectForKey:@"id_contact"] intValue];
        
        NSString *NameForSearch = [rsDict objectForKey:@"name_for_search"];
        NSString *ConvertName = [rsDict objectForKey:@"convert_name"];
        
        if ([Name isEqualToString: text_empty]) {
            Name = [self getFullNameOfContactWithID: idContact];
            if (Name == nil || [Name isEqualToString:text_empty]) {
                Name = CloudFoneID;
            }
        }else{
            ConvertName = [MyFunctions convertUTF8CharacterToCharacter: Name];
            NameForSearch = [MyFunctions getNameForSearchOfConvertName: ConvertName];
        }
        
        NSString *updateSQL = [NSString stringWithFormat:@"UPDATE contact SET email = '%@', address = '%@', first_name = '%@', last_name = '%@', avatar = '%@', name_for_search = '%@', convert_name = '%@'  WHERE id_contact = %d", email, address, Name, text_empty, Avatar, NameForSearch, ConvertName, idContact];
        [appDelegate._database executeUpdate: updateSQL];
    }
    [rs close];
    if (!exists) {
        int idContact = [NSDBCallnex getLastIDContactFromApp];
        idContact = idContact - 1;
        
        NSString *convertName = [MyFunctions convertUTF8CharacterToCharacter: Name];
        NSString *nameForSearch = [MyFunctions getNameForSearchOfConvertName: convertName];
        
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO contact (id_contact, first_name, last_name, convert_name, name_for_search, company, callnex_id, type, email, address, street, city, state, zip_postal, country, avatar, updated, sync_status) VALUES (%d,'%@','%@','%@','%@','%@','%@',%d,'%@','%@','%@','%@','%@','%@','%@','%@', %d, %d)", idContact, Name, text_empty, convertName, nameForSearch, text_empty, CloudFoneID, 0, email, text_empty, address, text_empty, text_empty, text_empty, text_empty, Avatar,1, 0];
        [appDelegate._database executeUpdate: insertSQL];
        
        PhoneObject *cloudPhone = [[PhoneObject alloc] init];
        [cloudPhone set_phoneNumber: CloudFoneID];
        [cloudPhone set_phoneType: type_cloudfone_id];
        
        [NSDBCallnex addPhoneOfContactToCallnexDB:@[cloudPhone] withIdContact: idContact];
    }
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

+ (NSString *)getStatusXmppOfAccount: (NSString *)account
{
    NSString *status = text_empty;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT status FROM profile WHERE account = '%@'", account];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        status = [rsDict objectForKey:@"status"];
    }
    [rs close];
    return status;
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

+ (NSString *)getAvatarDataOfAccount: (NSString *)account {
    NSString *avatar = text_empty;
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
    NSString *avatar = text_empty;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT name FROM profile WHERE account = '%@'", account];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        avatar = [rsDict objectForKey:@"name"];
    }
    [rs close];
    return avatar;
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

+ (void)InsertHistory : (NSString *)call_id status : (NSString *)status phoneNumber : (NSString *)phone_number callDirection : (NSString *)callDirection recordFiles : (NSString*) record_files duration : (int)duration date : (NSString *)date time : (NSString *)time time_int : (int)time_int rate : (float)rate sipURI : (NSString*)sipUri MySip : (NSString *)mysip kCallId: (NSString *)kCallId andFlag: (int)flag andUnread: (int)unread{
    [self openDB];
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO history(call_id,status,phone_number,call_direction,record_files,duration,date,rate,sipURI,time,time_int,my_sip, k_call_id, flag, unread) VALUES ('%@','%@','%@','%@','%@',%d,'%@',%f,'%@','%@',%d,'%@','%@',%d,%d)",call_id,status,phone_number,callDirection,record_files,duration,date,rate,sipUri,time,time_int,mysip, kCallId, flag, unread];
    NSLog(@"%@",sql);
    char *err;
    sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err);
    sqlite3_close(db);
}

+(NSMutableArray *) getDateHistory:(BOOL)missed{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    [self openDB];
    NSString *sql;
    if (missed) {
        sql = @"SELECT distinct date FROM history WHERE status = 'Missed' ORDER BY time_int DESC";
    }else{
        sql = @"SELECT distinct date FROM history ORDER BY time_int DESC";
    }
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2( db, [sql UTF8String], -1,
                           &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *field1 = (char *) sqlite3_column_text(statement, 0);
            NSString *date = [[NSString alloc] initWithUTF8String: field1];
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            [dictionary setValue:date forKey:@"Title"];
            [dictionary setValue:[self getAllRowsHistoryByDate:date Missed:missed] forKey:@"Rows"];
            [tempArray addObject:dictionary];
        }
    }
    return tempArray;
}

+ (NSMutableArray *)getDateHistoryLastTime{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    [self openDB];
    NSString *sql= [NSString stringWithFormat:@"SELECT distinct date FROM history WHERE status = 'Missed' and my_sip = '%@' ORDER BY time_int DESC LIMIT 0,1",[[NSUserDefaults standardUserDefaults] objectForKey:key_login]];
    NSLog(@"%@",sql);
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2( db, [sql UTF8String], -1,
                           &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *field1 = (char *) sqlite3_column_text(statement, 0);
            NSString *date = [[NSString alloc] initWithUTF8String: field1];
            NSLog(@"Date : %@",date);
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            [dictionary setValue:date forKey:@"Title"];
            [dictionary setValue:[self getAllRowsHistoryByDateLastTime:date] forKey:@"Rows"];
            [tempArray addObject:dictionary];
        }
    }
    return tempArray;
}

+(NSMutableArray *) getAllRowsHistoryByDateLastTime:(NSString *)date{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    [self openDB];
    NSString *sql = [NSString stringWithFormat:@"SELECT status,phone_number,call_direction,duration,time,time_int,sipURI,_id FROM history where status = 'Missed' and date = '%@' and my_sip = '%@' ORDER BY time_int DESC LIMIT 0,1",date,[[NSUserDefaults standardUserDefaults] objectForKey:key_login]] ;
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2( db, [sql UTF8String], -1,
                           &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *field1 = (char *) sqlite3_column_text(statement, 0);
            NSString *status = [[NSString alloc] initWithUTF8String: field1];
            char *field2 = (char *) sqlite3_column_text(statement, 1);
            NSString *phone_number = [[NSString alloc] initWithUTF8String: field2];
            char *field3 = (char *) sqlite3_column_text(statement, 2);
            NSString *call_direction = [[NSString alloc] initWithUTF8String: field3];
            char *field4 = (char *) sqlite3_column_text(statement, 3);
            NSString *duration = [[NSString alloc] initWithUTF8String: field4];
            char *field6 = (char *) sqlite3_column_text(statement, 4);
            NSString *time = [[NSString alloc] initWithUTF8String: field6];
            char *field7 = (char *) sqlite3_column_text(statement, 5);
            NSString *time_int = [[NSString alloc] initWithUTF8String: field7];
            char *field8 = (char *) sqlite3_column_text(statement, 6);
            NSString *sipURI = [[NSString alloc] initWithUTF8String: field8];
            char *field9 = (char *) sqlite3_column_text(statement, 7);
            NSString *_id = [[NSString alloc] initWithUTF8String: field9];
            
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            [dictionary setValue:_id forKey:@"_id"];
            [dictionary setValue:status forKey:@"status"];
            [dictionary setValue:phone_number forKey:@"phone_number"];
            [dictionary setValue:call_direction forKey:@"call_direction"];
            [dictionary setValue:duration forKey:@"duration"];
            [dictionary setValue:time forKey:@"time"];
            [dictionary setValue:sipURI forKey:@"sipURI"];
            [dictionary setValue:time_int forKey:@"time_int"];
            [tempArray addObject:dictionary];
        }
    }
    return tempArray;
}

+(NSMutableArray *) getAllRowsHistoryByDate:(NSString *)date Missed:(BOOL)missed{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    [self openDB];
    NSString *sql ;
    if (missed) {
        sql = [NSString stringWithFormat:@"SELECT status,phone_number,call_direction,duration,time,time_int,sipURI,_id FROM history where status = 'Missed' and date = '%@' and my_sip = '%@' ORDER BY time_int DESC",date,[[NSUserDefaults standardUserDefaults] objectForKey:key_login]];
    }else{
        sql = [NSString stringWithFormat:@"SELECT status,phone_number,call_direction,duration,time,time_int,sipURI,_id FROM history where date = '%@' and my_sip = '%@' ORDER BY time_int DESC",date,[[NSUserDefaults standardUserDefaults] objectForKey:key_login]];
    }
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2( db, [sql UTF8String], -1,
                           &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *field1 = (char *) sqlite3_column_text(statement, 0);
            NSString *status = [[NSString alloc] initWithUTF8String: field1];
            char *field2 = (char *) sqlite3_column_text(statement, 1);
            NSString *phone_number = [[NSString alloc] initWithUTF8String: field2];
            char *field3 = (char *) sqlite3_column_text(statement, 2);
            NSString *call_direction = [[NSString alloc] initWithUTF8String: field3];
            char *field4 = (char *) sqlite3_column_text(statement, 3);
            NSString *duration = [[NSString alloc] initWithUTF8String: field4];
            char *field6 = (char *) sqlite3_column_text(statement, 4);
            NSString *time = [[NSString alloc] initWithUTF8String: field6];
            char *field7 = (char *) sqlite3_column_text(statement, 5);
            NSString *time_int = [[NSString alloc] initWithUTF8String: field7];
            char *field8 = (char *) sqlite3_column_text(statement, 6);
            NSString *sipURI = [[NSString alloc] initWithUTF8String: field8];
            char *field9 = (char *) sqlite3_column_text(statement, 7);
            NSString *_id = [[NSString alloc] initWithUTF8String: field9];
            
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            [dictionary setValue:_id forKey:@"_id"];
            [dictionary setValue:status forKey:@"status"];
            [dictionary setValue:phone_number forKey:@"phone_number"];
            [dictionary setValue:call_direction forKey:@"call_direction"];
            [dictionary setValue:duration forKey:@"duration"];
            [dictionary setValue:time forKey:@"time"];
            [dictionary setValue:sipURI forKey:@"sipURI"];
            [dictionary setValue:time_int forKey:@"time_int"];
            [tempArray addObject:dictionary];
        }
    }
    return tempArray;
}

+(NSArray *) getAllRowsHistoryByDate:(NSString *)date{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    [self openDB];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT status,phone_number,call_direction,duration,time,time_int,sipURI FROM history where date = '%@' and my_sip = '%@' ",date,[[NSUserDefaults standardUserDefaults] objectForKey:key_login]];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2( db, [sql UTF8String], -1,
                           &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *field1 = (char *) sqlite3_column_text(statement, 0);
            NSString *status = [[NSString alloc] initWithUTF8String: field1];
            char *field2 = (char *) sqlite3_column_text(statement, 1);
            NSString *phone_number = [[NSString alloc] initWithUTF8String: field2];
            char *field3 = (char *) sqlite3_column_text(statement, 2);
            NSString *call_direction = [[NSString alloc] initWithUTF8String: field3];
            char *field4 = (char *) sqlite3_column_text(statement, 3);
            NSString *duration = [[NSString alloc] initWithUTF8String: field4];
            char *field6 = (char *) sqlite3_column_text(statement, 4);
            NSString *time = [[NSString alloc] initWithUTF8String: field6];
            //char *field7 = (char *) sqlite3_column_text(statement, 5);
            //NSString *time_int = [[NSString alloc] initWithUTF8String: field7];
            char *field8 = (char *) sqlite3_column_text(statement, 6);
            NSString *sipURI = [[NSString alloc] initWithUTF8String: field8];
            
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            [dictionary setValue:status forKey:@"status"];
            [dictionary setValue:phone_number forKey:@"phone_number"];
            [dictionary setValue:call_direction forKey:@"call_direction"];
            [dictionary setValue:duration forKey:@"duration"];
            [dictionary setValue:time forKey:@"time"];
            [dictionary setValue:sipURI forKey:@"sipURI"];
            [tempArray addObject:dictionary];
        }
    }
    return [NSArray arrayWithArray:tempArray];
}

+(NSArray *) getAllRowsHistory{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    [self openDB];
    NSString *sql = @"SELECT * FROM history";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2( db, [sql UTF8String], -1,
                           &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *field1 = (char *) sqlite3_column_text(statement, 2);
            NSString *field1Str = [[NSString alloc] initWithUTF8String: field1];
            char *field2 = (char *) sqlite3_column_text(statement, 3);
            NSString *field2Str = [[NSString alloc] initWithUTF8String: field2];
            char *field3 = (char *) sqlite3_column_text(statement, 4);
            NSString *field3Str = [[NSString alloc] initWithUTF8String: field3];
            char *field4 = (char *) sqlite3_column_text(statement, 7);
            NSString *field4Str = [[NSString alloc] initWithUTF8String: field4];
            char *field5 = (char *) sqlite3_column_text(statement, 10);
            NSString *field5Str = [[NSString alloc] initWithUTF8String: field5];
            char *field6 = (char *) sqlite3_column_text(statement, 11);
            NSString *field6Str = [[NSString alloc] initWithUTF8String: field6];
            
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            [dictionary setValue:field1Str forKey:@"status"];
            [dictionary setValue:field2Str forKey:@"phone_number"];
            [dictionary setValue:field3Str forKey:@"direction"];
            [dictionary setValue:field4Str forKey:@"date"];
            [dictionary setValue:field5Str forKey:@"time"];
            [dictionary setValue:field6Str forKey:@"time_int"];
            [tempArray addObject:dictionary];
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(db);
    return [NSArray arrayWithArray:tempArray];
}

+(NSString *) checkOutgoingHistory:(NSString *)phone{
    NSString *tmpString;
    int tmp = 0;
    [self openDB];
    NSString *sql = [NSString stringWithFormat:@"SELECT distinct call_direction FROM history WHERE phone_number = '%@' and my_sip = '%@' ",phone,[[NSUserDefaults standardUserDefaults] objectForKey:key_login]];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2( db, [sql UTF8String], -1,
                           &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *field1 = (char *) sqlite3_column_text(statement, 0);
            if (sizeof(field1) > 0) {
                tmpString = [[NSString alloc] initWithUTF8String: field1];
            }
            tmp++;
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(db);
    
    if (tmp == 2) {
        return @"All";
    }
    return tmpString;
}

+(NSArray *) getAllRowsByCallDirection : (NSString *)direction phone:(NSString *)phoneCall{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    [self openDB];
    NSString *sql = [NSString stringWithFormat:@"SELECT distinct date FROM history WHERE phone_number = '%@' AND my_sip = '%@' AND call_direction = '%@' ORDER BY time_int DESC",phoneCall,[[NSUserDefaults standardUserDefaults] objectForKey:key_login],direction];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2( db, [sql UTF8String], -1,
                           &statement, nil) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *field1 = (char *) sqlite3_column_text(statement, 0);
            NSString *date = [[NSString alloc] initWithUTF8String: field1];
            [tempArray addObject:date];
            NSString *qsql = [NSString stringWithFormat:@"SELECT time_int,duration,rate,status FROM history WHERE phone_number = '%@' AND my_sip = '%@' AND call_direction = '%@' AND date='%@' ORDER BY time_int DESC",phoneCall,[[NSUserDefaults standardUserDefaults] objectForKey:key_login],direction,date];
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

+(void) deleteRowsHistoryById: (NSString *)_id{
    [self openDB];
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM history WHERE _id = %d",[_id intValue]];
    char *err= nil;
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        sqlite3_close(db);
    }
    sqlite3_close(db);
}

+(void) deleteAllRowsHistory{
    [self openDB];
    
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM history WHERE my_sip = '%@'",[[NSUserDefaults standardUserDefaults] objectForKey:key_login]];
    char *err= nil;
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        sqlite3_close(db);
    }
    sqlite3_close(db);
}


#pragma mark - k11 functions for contact

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

+ (BOOL)connectAddContactCallnexDB{
    appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    localization = [HMLocalization sharedInstance];
    
    if (appDelegate._databasePath.length > 0) {
        appDelegate._addContactDB = [[FMDatabase alloc] initWithPath: appDelegate._databasePath];
        if ([appDelegate._addContactDB open]) {
            return YES;
        }else{
            return NO;
        }
    }else{
        return NO;
    }
}

// Thêm mới một contact vào database
+ (BOOL)addContactToCallnexDB:(ContactObject *)aContact{
    NSString *tSQL = [NSString stringWithFormat:@"INSERT INTO contact (id_contact, first_name, last_name, convert_name, name_for_search, company, callnex_id, type, email, address, street, city, state, zip_postal, country, avatar, updated, sync_status) VALUES (%d,'%@','%@','%@','%@','%@','%@',%d,'%@','%@','%@','%@','%@','%@','%@','%@', %d, %d)", aContact._id_contact, aContact._firstName, aContact._lastName, aContact._convertName, aContact._nameForSearch, aContact._company, aContact._cloudFoneID, aContact._type, aContact._email, @"", aContact._street, aContact._city, aContact._state, aContact._zip_postal, aContact._country, aContact._avatar,1, 0];
    BOOL added = [appDelegate._database executeUpdate: tSQL];
    return added;
}

// Thêm mới một contact vào database
+ (BOOL)addContactToCallnexDBWithThread:(ContactObject *)aContact{
    /*
    NSString *tSQL = [NSString stringWithFormat:@"INSERT INTO contact (id_contact, first_name, last_name, convert_name, name_for_search, company, callnex_id, type, email, address, street, city, state, zip_postal, country, avatar, updated, sync_status) VALUES (%d,'%@','%@','%@','%@','%@','%@',%d,'%@','%@','%@','%@','%@','%@','%@','%@', %d, %d)", aContact._id_contact, aContact._firstName, aContact._lastName, aContact._convertName, aContact._nameForSearch, aContact._company, aContact._callnexID, aContact._type, aContact._email, @"", aContact._street, aContact._city, aContact._state, aContact._zip_postal, aContact._country, aContact._avatar,1, 0];
    char *err;
    sqlite3_exec(db, [tSQL UTF8String], NULL, NULL, &err);
    if (err != nil) {
        NSLog(@"Add contact failed.....");
    }
    return true;
     */
    NSString *tSQL = [NSString stringWithFormat:@"INSERT INTO contact (id_contact, first_name, last_name, convert_name, name_for_search, company, callnex_id, type, email, address, street, city, state, zip_postal, country, avatar, updated, sync_status) VALUES (%d,'%@','%@','%@','%@','%@','%@',%d,'%@','%@','%@','%@','%@','%@','%@','%@', %d, %d)", aContact._id_contact, aContact._firstName, aContact._lastName, aContact._convertName, aContact._nameForSearch, aContact._company, aContact._cloudFoneID, aContact._type, aContact._email, @"", aContact._street, aContact._city, aContact._state, aContact._zip_postal, aContact._country, aContact._avatar,1, 0];
    BOOL added = [appDelegate._addContactDB executeUpdate: tSQL];
    if (!added) {
        NSLog(@"Add that bai");
    }
    return added;
}

// Thêm mới một contact vào database
+ (BOOL)addContactToCallnexDBInBackground:(ContactObject *)aContact{
    NSString *tSQL = [NSString stringWithFormat:@"INSERT INTO contact (id_contact, first_name, last_name, convert_name, name_for_search, company, callnex_id, type, email, address, street, city, state, zip_postal, country, avatar, updated, sync_status) VALUES (%d,'%@','%@','%@','%@','%@','%@',%d,'%@','%@','%@','%@','%@','%@','%@','%@', %d, %d)", aContact._id_contact, aContact._firstName, aContact._lastName, aContact._convertName, aContact._nameForSearch, aContact._company, aContact._cloudFoneID, aContact._type, aContact._email, @"", aContact._street, aContact._city, aContact._state, aContact._zip_postal, aContact._country, aContact._avatar,1, 0];
    BOOL added = [appDelegate._threadDatabase executeUpdate: tSQL];
    return added;
}

// Thêm số phone cho 1 contact
+ (void)addPhoneOfContactToCallnexDB: (NSArray *)phoneList withIdContact: (int)idContact {
    for (int iCount=0; iCount<phoneList.count; iCount++) {
        PhoneObject *aPhone = [phoneList objectAtIndex: iCount];
        NSString *tSQL = [NSString stringWithFormat:@"INSERT INTO contact_phone_number (id_contact, phone_number, type_phone, id_server, version) VALUES (%d,'%@','%@',%d,%d)", idContact, aPhone._phoneNumber, aPhone._phoneType, -1, 0];
        [appDelegate._database executeUpdate: tSQL];
    }
}

// Thêm số phone cho 1 contact
+ (void)addPhoneOfContactToCallnexDBWithThread: (NSArray *)phoneList withIdContact: (int)idContact{
    for (int iCount=0; iCount<phoneList.count; iCount++) {
        TypePhoneContact *aPhone = [phoneList objectAtIndex: iCount];
        NSString *tSQL = [NSString stringWithFormat:@"INSERT INTO contact_phone_number (id_contact, phone_number, type_phone, id_server, version) VALUES (%d,'%@','%@',%d,%d)", idContact, aPhone._phoneNumber, aPhone._typePhone, aPhone._serverID, 0];
        [appDelegate._addContactDB executeUpdate: tSQL];
    }
}

// Thêm số phone cho 1 contact
+ (BOOL)addPhoneOfContactToCallnexDBInBackground: (NSArray *)phoneList withIdContact: (int)idContact{
    BOOL result = NO;
    for (int iCount=0; iCount<phoneList.count; iCount++) {
        TypePhoneContact *aPhone = [phoneList objectAtIndex: iCount];
        NSString *tSQL = [NSString stringWithFormat:@"INSERT INTO contact_phone_number (id_contact, phone_number, type_phone, id_server, version) VALUES (%d,'%@','%@',%d,%d)", idContact, aPhone._phoneNumber, aPhone._typePhone, aPhone._serverID, 0];
        result = [appDelegate._threadDatabase executeUpdate: tSQL];
        if (!result) {
            break;
        }
    }
    return result;
}

// Add list phone cho contact
+ (BOOL)addPhoneForAContact: (NSArray *)phoneList withIdContact: (int)idContact{
    BOOL result = NO;
    for (int iCount=0; iCount<phoneList.count; iCount++) {
        PhoneObject *aPhone = [phoneList objectAtIndex: iCount];
        if (![aPhone._phoneNumber isEqualToString: text_empty] && aPhone._phoneNumber != nil) {
            NSString *tSQL = [NSString stringWithFormat:@"INSERT INTO contact_phone_number (id_contact, phone_number, type_phone, id_server, version) VALUES (%d,'%@','%@',%d,%d)", idContact, aPhone._phoneNumber, aPhone._phoneType, -1, 0];
            result = [appDelegate._database executeUpdate: tSQL];
            if (!result) {
                break;
            }
        }
        
    }
    return result;
    
}

/*--Đóng kết nối đến database--*/
+ (BOOL)disconnectToCallnexDB{
    [appDelegate._database close];
    return YES;
}

//  Đóng kết nối đến database
+ (BOOL)disconnectToAddContactCallnexDB{
    [appDelegate._addContactDB close];
    return YES;
}

/*--Đóng kết nối đến database--*/
+ (BOOL)disconnectThreadDB{
    [appDelegate._threadDatabase close];
    return YES;
}

//  Hàm get id của contact mới vừa thêm vào
+ (int)getIdOfLastContact{
    int contactId = 0;
    NSString *tSQL = @"SELECT id_contact FROM contact WHERE id_contact > 0 ORDER BY id_contact DESC LIMIT 0,1";
    FMResultSet *rs = [appDelegate._addContactDB executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        contactId  = [[dict objectForKey:@"id_contact"] intValue];
    }
    [rs close];
    return contactId;
}

//  Hàm lấy danh sách ODS contact
+ (NSMutableArray *)getODSContactInDBWithThread{
    NSString *meStr = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM contact WHERE callnex_id != '' AND callnex_id != '<null>' AND callnex_id != '(null)' AND callnex_id != 'null' AND id_contact != 0 AND callnex_id != %@", meStr];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        ContactObject *aContact = [[ContactObject alloc] init];
        NSDictionary *rsDict = [rs resultDictionary];
        aContact._id_contact = [[rsDict objectForKey:@"id_contact"] intValue];
        aContact._avatar = [rsDict objectForKey:@"avatar"];
        aContact._firstName = [rsDict objectForKey:@"first_name"];
        aContact._lastName = [rsDict objectForKey:@"last_name"];
        if ([aContact._firstName isEqualToString:text_empty] && [aContact._lastName isEqualToString:text_empty]) {
            aContact._fullName = [localization localizedStringForKey:text_unknown];
        }else if (![aContact._firstName isEqualToString:text_empty] && [aContact._lastName isEqualToString:text_empty]){
            aContact._fullName = aContact._firstName;
        }else if ([aContact._firstName isEqualToString:text_empty] && ![aContact._lastName isEqualToString:text_empty]){
            aContact._fullName = aContact._lastName;
        }else{
            aContact._fullName = [NSString stringWithFormat:@"%@ %@", aContact._firstName, aContact._lastName];
        }
        aContact._cloudFoneID = [rsDict objectForKey:@"callnex_id"];
        [result addObject: aContact];
    }
    [rs close];
    return result;
}

//  Get danh sach cloudfone binh thuong
+ (NSMutableArray *)getCloudFoneContactInDatabase{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM contact WHERE callnex_id != '' AND callnex_id != '%@' AND id_contact != 0", [[NSUserDefaults standardUserDefaults] objectForKey:key_login]];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        ContactObject *aContact = [[ContactObject alloc] init];
        NSDictionary *rsDict = [rs resultDictionary];
        aContact._id_contact = [[rsDict objectForKey:@"id_contact"] intValue];
        aContact._avatar = [rsDict objectForKey:@"avatar"];
        aContact._firstName = [rsDict objectForKey:@"first_name"];
        aContact._lastName = [rsDict objectForKey:@"last_name"];
        if ([aContact._firstName isEqualToString:@""] && [aContact._lastName isEqualToString:@""]) {
            aContact._fullName = [localization localizedStringForKey:text_unknown];
        }else if (![aContact._firstName isEqualToString:@""] && [aContact._lastName isEqualToString:@""]){
            aContact._fullName = aContact._firstName;
        }else if ([aContact._firstName isEqualToString:@""] && ![aContact._lastName isEqualToString:@""]){
            aContact._fullName = aContact._lastName;
        }else{
            aContact._fullName = [NSString stringWithFormat:@"%@ %@", aContact._firstName, aContact._lastName];
        }
        aContact._cloudFoneID = [rsDict objectForKey:@"callnex_id"];
        [result addObject: aContact];
    }
    [rs close];
    return result;
}

//  Hàm lấy danh sách Callnex contact khi dang sync
+ (NSMutableArray *)getCallnexContactInCallnexDBWhenSyncing {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSString *tSQL = @"SELECT * FROM contact WHERE callnex_id != '' AND id_contact != 0";
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        ContactObject *aContact = [[ContactObject alloc] init];
        NSDictionary *rsDict = [rs resultDictionary];
        aContact._id_contact = [[rsDict objectForKey:@"id_contact"] intValue];
        aContact._avatar = [rsDict objectForKey:@"avatar"];
        aContact._firstName = [rsDict objectForKey:@"first_name"];
        aContact._lastName = [rsDict objectForKey:@"last_name"];
        if ([aContact._firstName isEqualToString:@""] && [aContact._lastName isEqualToString:@""]) {
            aContact._fullName = [localization localizedStringForKey:text_unknown];
        }else if (![aContact._firstName isEqualToString:@""] && [aContact._lastName isEqualToString:@""]){
            aContact._fullName = aContact._firstName;
        }else if ([aContact._firstName isEqualToString:@""] && ![aContact._lastName isEqualToString:@""]){
            aContact._fullName = aContact._lastName;
        }else{
            aContact._fullName = [NSString stringWithFormat:@"%@ %@", aContact._firstName, aContact._lastName];
        }
        aContact._cloudFoneID = [rsDict objectForKey:@"callnex_id"];
        [result addObject: aContact];
    }
    [rs close];
    return result;
}

//  Hàm lấy danh sách tất cả contact
+ (NSMutableArray *)getAllContactInCallnexDBWithThread {
    NSString *meStr = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSString *tSQL = @"SELECT * FROM contact WHERE id_contact != 0";
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        ContactObject *aContact = [[ContactObject alloc] init];
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *callnexID = [rsDict objectForKey:@"callnex_id"];
        if (![callnexID isEqualToString: meStr]) {
            aContact._id_contact = [[rsDict objectForKey:@"id_contact"] intValue];
            aContact._avatar = [rsDict objectForKey:@"avatar"];
            aContact._firstName = [rsDict objectForKey:@"first_name"];
            aContact._lastName = [rsDict objectForKey:@"last_name"];
            if ([aContact._firstName isEqualToString:@""] && [aContact._lastName isEqualToString:@""]) {
                aContact._fullName = [localization localizedStringForKey:text_unknown];
            }else if(![aContact._firstName isEqualToString:@""] && [aContact._lastName isEqualToString:@""]){
                aContact._fullName = aContact._firstName;
            }else if ([aContact._firstName isEqualToString:@""] && ![aContact._lastName isEqualToString:@""]){
                aContact._fullName = aContact._lastName;
            }else{
                aContact._fullName = [NSString stringWithFormat:@"%@ %@", [rsDict objectForKey:@"first_name"], [rsDict objectForKey:@"last_name"]];
            }
            
            // Kiem tra callnexID
            if (callnexID.length > 6) {
                NSString *prefix = [callnexID substringToIndex: 6];
                if ([prefix isEqualToString: @"778899"]) {
                    [aContact set_cloudFoneID: callnexID];
                }else{
                    [aContact set_cloudFoneID: text_empty];
                }
            }else{
                [aContact set_cloudFoneID: text_empty];
            }
            [result addObject: aContact];
        }
    }
    [rs close];
    return result;
}



//  Hàm lấy danh sách tất cả contact khi đang syncing
+ (NSMutableArray *)getAllContactInCallnexDBWhenSyncingContact{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSString *tSQL = @"SELECT * FROM contact WHERE id_contact != 0";
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        ContactObject *aContact = [[ContactObject alloc] init];
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *callnexID = [rsDict objectForKey:@"callnex_id"];
        
        aContact._id_contact = [[rsDict objectForKey:@"id_contact"] intValue];
        aContact._avatar = [rsDict objectForKey:@"avatar"];
        aContact._firstName = [rsDict objectForKey:@"first_name"];
        aContact._lastName = [rsDict objectForKey:@"last_name"];
        if ([aContact._firstName isEqualToString:@""] && [aContact._lastName isEqualToString:@""]) {
            aContact._fullName = [localization localizedStringForKey:text_unknown];
        }else if(![aContact._firstName isEqualToString:@""] && [aContact._lastName isEqualToString:@""]){
            aContact._fullName = aContact._firstName;
        }else if ([aContact._firstName isEqualToString:@""] && ![aContact._lastName isEqualToString:@""]){
            aContact._fullName = aContact._lastName;
        }else{
            aContact._fullName = [NSString stringWithFormat:@"%@ %@", [rsDict objectForKey:@"first_name"], [rsDict objectForKey:@"last_name"]];
        }
        // Kiem tra callnexID
        if (callnexID.length > 6) {
            NSString *prefix = [callnexID substringToIndex: 6];
            if ([prefix isEqualToString: @"778899"]) {
                [aContact set_cloudFoneID: callnexID];
            }else{
                [aContact set_cloudFoneID: text_empty];
            }
        }else{
            [aContact set_cloudFoneID: text_empty];
        }
        [result addObject: aContact];
    }
    [rs close];
    return result;
}

// Get contact trong database cho phần detail
+ (ContactObject *)getAContactOfDB: (int)idContact
{
    ContactObject *aContact = [[ContactObject alloc] init];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM contact WHERE id_contact = %d", idContact];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict  = [rs resultDictionary];
        int idContact = [[rsDict objectForKey:@"id_contact"] intValue];
        NSString *firstName = [rsDict objectForKey:@"first_name"];
        if (firstName == nil) {
            firstName = text_empty;
        }
        
        NSString *lastName = [rsDict objectForKey:@"last_name"];
        if (lastName == nil) {
            lastName = text_empty;
        }
        
        NSString *convertName = [rsDict objectForKey:@"convert_name"];
        if (convertName == nil) {
            convertName = text_empty;
        }
        
        NSString *nameForSearch = [rsDict objectForKey:@"name_for_search"];
        if (nameForSearch == nil) {
            nameForSearch = text_empty;
        }
        
        NSString *company = [rsDict objectForKey:@"company"];
        if (company == nil) {
            company = text_empty;
        }
        
        NSString *cloudFoneID = [rsDict objectForKey:@"callnex_id"];
        if (cloudFoneID == nil || [cloudFoneID isEqualToString:@"(null)"] || [cloudFoneID isEqualToString:@"<null>"]) {
            cloudFoneID = text_empty;
        }
        
        NSString *email = [rsDict objectForKey:@"email"];
        if (email == nil || [email isEqualToString:@"(null)"] || [email isEqualToString:@"<null>"] || [email isEqualToString:@"null"]) {
            email = text_empty;
        }
        
        NSString *avatar = [rsDict objectForKey:@"avatar"];
        if (avatar == nil || [avatar isEqualToString:@"(null)"] || [avatar isEqualToString:@"<null>"] || [avatar isEqualToString:@"null"]) {
            avatar = text_empty;
        }
        
        aContact._id_contact  = idContact;
        aContact._firstName   = firstName;
        aContact._lastName    = lastName;
        aContact._convertName = convertName;
        aContact._nameForSearch = nameForSearch;
        aContact._fullName    = [NSString stringWithFormat:@"%@ %@", aContact._firstName, aContact._lastName];
        aContact._company     =  company;
        aContact._type        = [[rsDict objectForKey:@"type"] intValue];
        aContact._email       = email;
        aContact._street      = text_empty;
        aContact._city        = text_empty;
        aContact._state       = text_empty;
        aContact._zip_postal  = text_empty;
        aContact._country     = text_empty;
        aContact._avatar      = avatar;
        aContact._cloudFoneID = cloudFoneID;
        aContact._listPhone   = [self getPhoneNumberOfAContact: idContact];
        
        /*
        if (callnexID.length > 6) {
            NSString *prefix = [callnexID substringToIndex: 6];
            if ([prefix isEqualToString:@"778899"]) {
                [aContact set_callnexID: callnexID];
            }else{
                [aContact set_callnexID: @""];
                TypePhoneContact *aPhone = [[TypePhoneContact alloc] init];
                [aPhone set_typePhone: @"mobile"];
                [aPhone set_phoneNumber: callnexID];
                [aPhone set_serverID: -1];
                [aContact._listPhone addObject: aPhone];
            }
        }else if(![callnexID isEqualToString:@""]){
            [aContact set_callnexID: @""];
            TypePhoneContact *aPhone = [[TypePhoneContact alloc] init];
            [aPhone set_typePhone: @"mobile"];
            [aPhone set_phoneNumber: callnexID];
            [aPhone set_serverID: -1];
            [aContact._listPhone addObject: aPhone];
        }
        */
    }
    [rs close];
    return  aContact;
}

/*--Get contact cho phần group--*/
+ (ContactObject *)getAContactForAddToGroup: (int)idContact{
    ContactObject *aContact = nil;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM contact WHERE id_contact = '%d'", idContact];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        aContact = [[ContactObject alloc] init];
        NSDictionary *rsDict = [rs resultDictionary];
        
        aContact._id_contact = [[rsDict objectForKey:@"id_contact"] intValue];
        aContact._avatar = [rsDict objectForKey:@"avatar"];
        aContact._firstName = [rsDict objectForKey:@"first_name"];
        aContact._lastName = [rsDict objectForKey:@"last_name"];
        aContact._fullName = [NSString stringWithFormat:@"%@ %@", [rsDict objectForKey:@"first_name"], [rsDict objectForKey:@"last_name"]];
        aContact._cloudFoneID = [rsDict objectForKey:@"callnex_id"];
    }
    [rs close];
    return  aContact;
}

// Get thông tin phone của một contact
+ (NSMutableArray *)getPhoneNumberOfAContact: (int)idContact{
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT type_phone, phone_number, id_server FROM contact_phone_number WHERE id_contact = %d AND type_phone != '%@'", idContact, type_cloudfone_id];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        
        PhoneObject *aPhone = [[PhoneObject alloc] init];
        [aPhone set_phoneType: [rsDict objectForKey:@"type_phone"]];
        [aPhone set_phoneNumber: [rsDict objectForKey:@"phone_number"]];
        [aPhone set_isNew: false];
        
        [resultArr addObject: aPhone];
    }
    [rs close];
    return resultArr;
}

// Cap nhat thong tin contact
+ (BOOL)updateContactInformation: (int)idContact andUpdateInfo: (ContactObject *)infoUpdate
{
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE contact SET first_name='%@', last_name='%@',convert_name='%@', name_for_search='%@', avatar='%@',company='%@', callnex_id='%@', 'type'=%d, 'email'='%@', address='%@', street='%@', city='%@', state='%@', zip_postal='%@', country='%@', updated=0 WHERE id_contact=%d", infoUpdate._firstName, infoUpdate._lastName, infoUpdate._convertName, infoUpdate._nameForSearch, infoUpdate._avatar,infoUpdate._company, infoUpdate._cloudFoneID, infoUpdate._type, infoUpdate._email, @"", infoUpdate._street, infoUpdate._city, infoUpdate._state, infoUpdate._zip_postal, infoUpdate._country, idContact];
    
    BOOL result = [appDelegate._database executeUpdate: tSQL];
    if (result) {
        [NSDBCallnex updatePhoneNumberOfContact:idContact andListPhone:infoUpdate._listPhone];
    }
    return result;
}

// Cập nhật thông tin của một contact
+ (void)updatePhoneNumberOfContact: (int)idContact andListPhone: (NSArray *)listPhone{
    BOOL result = NO;
    NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM contact_phone_number WHERE id_contact = %d", idContact];
    result = [appDelegate._database executeUpdate: deleteSQL];
    if (result) {
        if (listPhone.count > 0) {
            result = [NSDBCallnex addPhoneForAContact:listPhone withIdContact:idContact];
        }
    }
}

#pragma mark - Groups contacts
/*--Kiểm tra group có tồn tại trong database hay không--*/
+ (BOOL)checkGroupExistsInCallnexDB{
    BOOL result = NO;
    NSString *tSQL = @"SELECT id_group FROM groups LIMIT 0,1";
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        result = YES;
    }
    [rs close];
    return result;
}

/*--Get list phone in whitelist or Blacklist--*/
+ (NSMutableArray *)getListPhoneIsBlackList: (BOOL)isBlackList isWhiteList: (BOOL)isWhiteList {
    NSMutableArray *listPhone = [[NSMutableArray alloc] init];
        
    int groupID = 0;
    if (isWhiteList) {
        groupID = 1;
    }
        
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id_member FROM group_members WHERE id_group = %d", groupID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        int idMember = [[rsDict objectForKey:@"id_member"] intValue];
        
        NSString *tSQL2 = [NSString stringWithFormat:@"SELECT phone_number FROM contact_phone_number WHERE id_contact = %d", idMember];
        FMResultSet *rs2 = [appDelegate._database executeQuery: tSQL2];
        while ([rs2 next]) {
            NSDictionary *rsDict2 = [rs2 resultDictionary];
            NSString *aPhoneNumber = [rsDict2 objectForKey:@"phone_number"];
            [listPhone addObject: aPhoneNumber];
        }
        [rs2 close];
    }
    [rs close];
    return listPhone;
}

/*--Get danh sách callex list trong Whitelist--*/
+ (NSMutableArray *)getAllCallnexListInWhiteList {
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id_member FROM group_members WHERE id_group = 1"];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        int idMember = [[rsDict objectForKey:@"id_member"] intValue];
        NSString *tSQL2 = [NSString stringWithFormat:@"SELECT phone_number FROM contact_phone_number WHERE id_contact = %d AND phone_number LIKE '888999%%'", idMember];
        FMResultSet *rs2 = [appDelegate._database executeQuery: tSQL2];
        while ([rs2 next]) {
            NSDictionary *rsDict2 = [rs2 resultDictionary];
            NSString *callnexNumber = [rsDict2 objectForKey:@"phone_number"];
            [resultArr addObject: callnexNumber];
        }
        [rs2 close];
    }
    [rs close];
    return resultArr;
}

/*--Lưu một group vào database--*/
+ (BOOL)insertGroupRecordIntoCallnexDB: (GroupObject *)aGroup{
    BOOL result = NO;
    [appDelegate._database beginTransaction];
    NSString *tSQL = [NSString stringWithFormat:@"INSERT INTO groups(id_group, group_name, member_count, is_update, avatar, group_description) VALUES(%d, '%@', %d, %d, '%@', '%@')", aGroup._gId, aGroup._gName, aGroup._gMember, 1, @"", @""];
    result = [appDelegate._database executeUpdate: tSQL];
    if (result) {
        //Khi lưu thành công sẽ add thành viênc của group vào database
        if (aGroup._gListMember.count > 0) {
            for (int iCount=0; iCount<aGroup._gListMember.count; iCount++) {
                NSNumber *idNumber = [aGroup._gListMember objectAtIndex: iCount];
                result = [self insertPersonIntoGroup:aGroup._gId andPerson:[idNumber intValue]];
                if (!result) {
                    [appDelegate._database rollback];
                    break;
                }
            }
        }
    }
    [appDelegate._database commit];
    return result;
}

+ (BOOL)insertPersonIntoGroup: (int)groupId andPerson: (int)personId{
    NSString *tSQL = [NSString stringWithFormat:@"INSERT INTO(id_group, id_member, is_update) VALUES(%d, %d, %d)", groupId, personId, 1];
    return [appDelegate._database executeUpdate: tSQL];
}

/*--Thêm mới group vào database--*/
+ (BOOL)addNewGroupWithGroupName: (NSString *)groupName andDescription: (NSString *)groupDesc andImage: (NSString *)groupAvatar{
    NSString *tSQL = [NSString stringWithFormat:@"INSERT INTO groups (group_name, member_count, avatar, group_description) VALUES('%@', %d, '%@', '%@')", groupName, 0, groupAvatar, groupDesc];
    BOOL isAdded = [appDelegate._database executeUpdate: tSQL];
    return isAdded;
}

// Get thông tin của một group
+ (GroupObject *)getGroupInfoWithId: (int)groupId{
    GroupObject *rsGroup = nil;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM groups WHERE id_group=%d", groupId];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        rsGroup = [[GroupObject alloc] init];
        
        int idGroup = [[rsDict objectForKey:@"id_group"] intValue];
        NSString *groupName = [rsDict objectForKey:@"group_name"];
        if (groupName == nil) {
            groupName = text_empty;
        }
        
        int memberCount = [[rsDict objectForKey:@"member_count"] intValue];
        int isUpdate = [[rsDict objectForKey:@"is_update"] intValue];
        NSString *avatar = [rsDict objectForKey:@"avatar"];
        if (avatar == nil) {
            avatar = text_empty;
        }
        NSString *gDesc = [rsDict objectForKey:@"group_description"];
        if (gDesc == nil) {
            gDesc = text_empty;
        }
        rsGroup._gId            = idGroup;
        rsGroup._gName          = groupName;
        rsGroup._gMember        = memberCount;
        rsGroup._gUpdate        = isUpdate;
        rsGroup._gAvatar        = avatar;
        rsGroup._gDescription   = gDesc;
        rsGroup._gListMember    = [self getAllMemberOfGroup: groupId];
        rsGroup._gMember        = (int)rsGroup._gListMember.count;
    }
    [rs close];
    return rsGroup;
}

/*--Đếm số thành viên trong 1 groups--*/
+ (int)getNumMemberOfGroup: (int)groupId {
    int numMember = 0;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT COUNT(*) as num_member FROM group_members WHERE id_group = %d AND account = '%@'", groupId, [[NSUserDefaults standardUserDefaults] objectForKey:key_login]];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        numMember = [[rsDict objectForKey:@"num_member"] intValue];
    }
    [rs close];
    return numMember;
}

// Get danh sách các thành viên có trong group
+ (NSMutableArray *)getAllMemberOfGroup: (int)groupId{
    NSMutableArray *rsArray = [[NSMutableArray alloc] init];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM group_members WHERE id_group = %d AND account = '%@'", groupId, [[NSUserDefaults standardUserDefaults] objectForKey:key_login]];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        int idMember = [[rsDict objectForKey:@"id_member"] intValue];
        NSString *callnexStr = [rsDict objectForKey:@"callnex_id"];
        NSArray *info = [self getNameAndAvatarOfContact:idMember];
        NSString *fullName = @"";
        
        if ([[info objectAtIndex: 0] isEqualToString:@""]) {
             fullName = [localization localizedStringForKey:text_unknown];
        }else{
            fullName = [info objectAtIndex: 0];
        }
       
        ContactObject *aContact = [[ContactObject alloc] init];
        [aContact set_id_contact: idMember];
        [aContact set_fullName: fullName];
        [aContact set_cloudFoneID: callnexStr];
        [aContact set_avatar: [info objectAtIndex: 1]];
        [rsArray addObject: aContact];
    }
    [rs close];
    return rsArray;
}

/*--Lấy danh sách các sốc callnex chưa có trong group--*/
+ (NSMutableArray *)getCallnexListForAddToGroup: (int)idGroup{
    NSMutableArray *rsArr = [self getODSContactInDBWithThread];
    NSMutableArray *existsArr = [self getAllMemberOfGroup: idGroup];
    [rsArr removeObjectsInArray: existsArr];
    NSLog(@"Count after remove: %d", (int)rsArr.count);
    return rsArr;
}

/*--Hàm thêm một thành viên vào group--*/
+ (BOOL)addMemberIntoGroup: (int)idMember andGroupId: (int)idGroup{
    NSString *tSQL = [NSString stringWithFormat:@"INSERT INTO group_members(id_group, id_member, callnex_id) VALUES (%d, %d,'%@')", idGroup, idMember, @""];
    BOOL isAddSuccess = [appDelegate._database executeUpdate: tSQL];
    return isAddSuccess;
}

/*--Cập nhật member count của group với số contact thêm mới vào hoặc trừ đi--*/
+ (BOOL)updateMemberCountOfGroup: (int)newMemberCount andGroupId: (int)groupId typeUpdate: (NSString *)typeStr{
    // Lấy member hiện tại của group
    int curMemberCount = 0;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM groups WHERE id_group = '%d'", groupId];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        curMemberCount = [[rsDict objectForKey:@"member_count"] intValue];
    }
    [rs close];
    
    // Kiểm tra là thêm contact hay xoá contact ra khỏi group
    if ([typeStr isEqualToString:@"addnew"]) {
        curMemberCount = curMemberCount+newMemberCount;
    }else{
        curMemberCount = curMemberCount - newMemberCount;
    }
    // Cập nhật member count
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE groups SET member_count=%d WHERE id_group = %d", curMemberCount, groupId];
    BOOL isUpdated = [appDelegate._database executeUpdate: updateSQL];
    if (!isUpdated) {
        return NO;
    }else{
        return YES;
    }
}

/*--Xoá group trong database--*/
+ (BOOL)deleteGroupInCallnexDB: (int)groupId{
    // Xoá các thành viên có trong group ra trước
    BOOL result = NO;
    [appDelegate._database beginTransaction];
    
    NSString *deleteMemberSQL = [NSString stringWithFormat:@"DELETE FROM group_members WHERE id_group = %d", groupId];
    result = [appDelegate._database executeUpdate: deleteMemberSQL];
    if (result) {
        NSString *deleteGroupSQL = [NSString stringWithFormat:@"DELETE FROM groups WHERE id_group = %d", groupId];
        result = [appDelegate._database executeUpdate: deleteGroupSQL];
        if (!result) {
            [appDelegate._database rollback];
        }
    }
    [appDelegate._database commit];
    return result;
}

/*--Xoá các thành viên được chọn ra khỏi group--*/
+ (BOOL)removeChoosedMemberFromCallnexDB: (int)groupId withRemoveList: (NSArray *)removeList{
    BOOL result = NO;
    [appDelegate._database beginTransaction];
    
    for (int iCount=0; iCount<removeList.count; iCount++) {
        int idMember = [[removeList objectAtIndex: iCount] intValue];
        
        NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM group_members WHERE id_group = %d AND id_member = %d", groupId, idMember];
        result = [appDelegate._database executeUpdate: tSQL];
        if (!result) {
            [appDelegate._database rollback];
            break;
        }
    }
    [appDelegate._database commit];
    return result;
}

/*--Xoá tất cả các thành viên ra khỏi group--*/
+ (BOOL)removeAllMemberFromGroup: (int)groupId{
    BOOL result = NO;
    [appDelegate._database beginTransaction];
    
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM group_members WHERE id_group = %d", groupId];
    result = [appDelegate._database executeUpdate: tSQL];
    if (result) {
        NSString *tSQL = [NSString stringWithFormat:@"UPDATE groups SET member_count = 0 WHERE id_group = %d", groupId];
        result = [appDelegate._database executeUpdate: tSQL];
        if (!result) {
            [appDelegate._database rollback];
        }
    }
    [appDelegate._database commit];
    return result;
}

//  Xoá contact ra khỏi group (trường hợp xoá luôn contact)
+ (BOOL)removeContactFromAllGroup: (int)contactId{
    BOOL result = NO;
    [appDelegate._database beginTransaction];
    
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM group_members WHERE id_member = %d", contactId];
    result = [appDelegate._database executeUpdate: tSQL];
    if (result) {
        NSString *tSQL2 = [NSString stringWithFormat:@"DELETE FROM contact WHERE id_contact = %d", contactId];
        result = [appDelegate._database executeUpdate: tSQL2];
        if (!result) {
            [appDelegate._database rollback];
        }else{
            NSString *tSQL3 = [NSString stringWithFormat:@"DELETE FROM contact_phone_number WHERE id_contact = %d", contactId];
            result = [appDelegate._database executeUpdate: tSQL3];
            if (!result) {
                [appDelegate._database rollback];
            }
        }
    }
    [appDelegate._database commit];
    return result;
}

//  Lấy tất cả user trong Callnex Blacklist
+ (NSMutableArray *)getAllUserInCallnexBlacklist{
    NSMutableArray *rsArray = [[NSMutableArray alloc] init];
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    
    NSString *tSQL = [NSString stringWithFormat:@"SELECT distinct id_member, callnex_id FROM group_members WHERE id_group = 0 AND account = '%@'", account];
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

#pragma mark - history message
// Lấy nội dung cho save conversation
+ (NSString *)getContentMessageOfMeWithUser: (NSString *)userStr{
    NSString *meStr = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM message WHERE ((send_phone = '%@' AND receive_phone = '%@') OR (send_phone = '%@' AND receive_phone = '%@')) AND (room_id = 0 OR room_id = '%@')", meStr, userStr, userStr, meStr, @""];
    
    NSString *meXMPP = [NSString stringWithFormat:@"%@@%@", meStr, xmpp_cloudfone];
    NSString *userXMPP = [NSString stringWithFormat:@"%@@%@", userStr, xmpp_cloudfone];
    
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    NSString *resultStr = @"";
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *content = [rsDict objectForKey:@"content"];
        NSString *sendPhone = [rsDict objectForKey:@"send_phone"];
        int timeInterval = [[rsDict objectForKey:@"time"] intValue];
        NSString *typeMessage = [rsDict objectForKey:@"type_message"];

        if ([typeMessage isEqualToString: imageMessage]) {
            if ([sendPhone isEqualToString: userStr]) {
                content = [localization localizedStringForKey:text_message_image_received];
            }else{
                content = [localization localizedStringForKey:text_image_message_sent];
            }
        }else if ([typeMessage isEqualToString: audioMessage]){
            if ([sendPhone isEqualToString: userStr]) {
                content = [localization localizedStringForKey:text_audio_message_received];
            }else{
                content = [localization localizedStringForKey:text_audio_message_sent];
            }
        }else if ([typeMessage isEqualToString: locationMessage]){
            content = [localization localizedStringForKey:text_message_location];
        }
        
        if ([sendPhone isEqualToString: meStr]) {
            content = [NSString stringWithFormat:@"%@(%@)<br/>%@", meXMPP, [NSString stringWithFormat:@"%@ %@", [MyFunctions stringDateFromInterval: timeInterval], [MyFunctions stringTimeFromInterval: timeInterval]], content];
        }else{
            content = [NSString stringWithFormat:@"%@(%@)<br/>%@", userXMPP, [NSString stringWithFormat:@"%@ %@", [MyFunctions stringDateFromInterval: timeInterval], [MyFunctions stringTimeFromInterval: timeInterval]], content];
        }
        resultStr = [NSString stringWithFormat:@"%@<br/>%@", resultStr, content];
    }
    [rs close];
    return resultStr;
}

/*--get Id cua room chat theo room name--*/
+ (int)getRoomIDOfRoomChatWithRoomName: (NSString *)roomName {
    int idLastRoom = 0;
    NSString *me = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id FROM room_chat WHERE room_name = '%@' AND user = '%@'", roomName, me];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        idLastRoom = [[rsDict objectForKey:@"id"] intValue];
    }
    [rs close];
    return idLastRoom;
}

/*--Kiểm tra contact có trong mảng tạm hay chưa--*/
+ (BOOL)checkContact: (NSString *)userStr existsInList: (NSMutableArray *)listTmp{
    if (listTmp.count == 0) {
        return NO;
    }else{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self CONTAINS %@", userStr];
        NSArray *resultArr = [listTmp filteredArrayUsingPredicate: predicate];
        if (resultArr.count == 0) {
            return NO;
        }
        return YES;
    }
}

//  Lấy thông tin contact name và avatar image
+ (NSArray *)getContactNameOfCloudFoneID: (NSString *)cloudFoneID {
    NSString *name = [NSDBCallnex getNameOfPBXPhone: cloudFoneID];
    if (![name isEqualToString: text_empty]) {
        return [[NSArray alloc] initWithObjects: name, text_empty, nil];
    }else{
        NSString *tSQL = [NSString stringWithFormat:@"SELECT first_name, last_name, avatar FROM contact WHERE callnex_id = '%@' ORDER BY id_contact DESC LIMIT 0,1", cloudFoneID];
        FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
        NSString *fullName = text_empty;
        NSString *firstName;
        NSString *lastName;
        NSString *avatar = text_empty;
        
        while ([rs next]) {
            NSDictionary *rsDict = [rs resultDictionary];
            firstName = [rsDict objectForKey:@"first_name"];
            lastName = [rsDict objectForKey:@"last_name"];
            
            if ([firstName isEqualToString:text_empty] && [lastName isEqualToString:text_empty]) {
                // do not thing
            }else if (![firstName isEqualToString:text_empty] && [lastName isEqualToString:text_empty]){
                fullName = firstName;
            }else if ([firstName isEqualToString:text_empty] && ![lastName isEqualToString:text_empty]){
                fullName = lastName;
            }else{
                fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            }
            avatar = [rsDict objectForKey:@"avatar"];
        }
        if ([fullName isEqualToString: text_empty]) {
            fullName = cloudFoneID;
        }
        [rs close];
        return [[NSArray alloc] initWithObjects:fullName, avatar, nil];
    }
}

//  Hàm trả về tên contact (nếu tồn tại) hoặc cloudfoneID
+ (NSString *)getFullnameOfContactWithCloudFoneID: (NSString *)cloudfoneID {
    NSString *tSQL = [NSString stringWithFormat:@"SELECT first_name, last_name FROM contact WHERE callnex_id = '%@' ORDER BY id_contact DESC LIMIT 0,1", cloudfoneID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *fName = [rsDict objectForKey:@"first_name"];
        NSString *lName = [rsDict objectForKey:@"last_name"];
        if ([fName isEqualToString:text_empty] && ![lName isEqualToString:text_empty]) {
            cloudfoneID = lName;
        }else if (![fName isEqualToString:text_empty] && [lName isEqualToString:text_empty]){
            cloudfoneID = fName;
        }else if (![fName isEqualToString:text_empty] && ![lName isEqualToString:text_empty]){
            cloudfoneID = [NSString stringWithFormat:@"%@ %@", fName, lName];
        }
    }
    [rs close];
    return cloudfoneID;
}

/*--Get full name cua mot user--*/
+ (NSString *)getFullnameOfContactWithPhoneNumber: (NSString *)phoneNumber{
    BOOL isCallnexID = NO;
    
    NSString *tSQL = [NSString stringWithFormat:@"SELECT first_name, last_name, id_contact FROM contact WHERE callnex_id = '%@' ORDER BY id_contact DESC LIMIT 0,1", phoneNumber];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        isCallnexID = YES;
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *fName = [rsDict objectForKey:@"first_name"];
        NSString *lName = [rsDict objectForKey:@"last_name"];
        if ([fName isEqualToString:@""] && ![lName isEqualToString:@""]) {
            phoneNumber = lName;
        }else if (![fName isEqualToString:@""] && [lName isEqualToString:@""]){
            phoneNumber = fName;
        }else if (![fName isEqualToString:@""] && ![lName isEqualToString:@""]){
            phoneNumber = [NSString stringWithFormat:@"%@ %@", fName, lName];
        }
    }
    
    if (!isCallnexID) {
        NSString *tSQL2 = [NSString stringWithFormat:@"SELECT id_contact FROM contact_phone_number WHERE phone_number = '%@'", phoneNumber];
        FMResultSet *rs2 = [appDelegate._database executeQuery: tSQL2];
        while ([rs2 next]) {
            NSDictionary *rsDict2 = [rs2 resultDictionary];
            int idContact = [[rsDict2 objectForKey:@"id_contact"] intValue];
            phoneNumber = [self getFullNameOfContactWithID: idContact];
        }
        [rs2 close];
    }
    [rs close];
    return phoneNumber;
}

//  Get fullname of contact with contact ID
+ (NSString *)getFullNameOfContactWithID: (int)idContact {
    NSString *fullName = @"";
    NSString *tSQL = [NSString stringWithFormat:@"SELECT first_name, last_name FROM contact WHERE id_contact = %d", idContact];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *fName = [rsDict objectForKey:@"first_name"];
        NSString *lName = [rsDict objectForKey:@"last_name"];
        if ([fName isEqualToString:@""] && ![lName isEqualToString:@""]) {
            fullName = lName;
        }else if (![fName isEqualToString:@""] && [lName isEqualToString:@""]){
            fullName = fName;
        }else if (![fName isEqualToString:@""] && ![lName isEqualToString:@""]){
            fullName = [NSString stringWithFormat:@"%@ %@", fName, lName];
        }
    }
    [rs close];
    return fullName;
}

//  Lấy thông tin contact name và avatar image
+ (NSArray *)getNameAndAvatarOfContact: (int)contactId{
    NSString *tSQL = [NSString stringWithFormat:@"SELECT first_name, last_name, avatar FROM contact WHERE id_contact = %d", contactId];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    NSString *fullName = @"";
    NSString *firstName;
    NSString *lastName;
    NSString *avatar = @"";
    
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        firstName = [rsDict objectForKey:@"first_name"];
        lastName = [rsDict objectForKey:@"last_name"];
        
        if (![firstName isEqualToString:@""] && [lastName isEqualToString:@""]) {
            fullName = firstName;
        }else if ([firstName isEqualToString:@""] && ![lastName isEqualToString:@""]){
            fullName = lastName;
        }else if (![firstName isEqualToString:@""] && ![lastName isEqualToString:@""]){
            fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        }
        avatar = [rsDict objectForKey:@"avatar"];
        return [[NSArray alloc] initWithObjects:fullName, avatar, nil];
    }
    [rs close];
    return [[NSArray alloc] initWithObjects:fullName, avatar, nil];
}

/*--Nếu hôm nay thì chỉ hiển thị giờ, nếu ngày đã qua thì hiển thị ngày--*/
+ (NSString*)getDateOrTime: (NSString*)stringDay{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Bangkok"]];
    NSString *today = [formatter stringFromDate:[NSDate date]];

    NSRange firstSpace = [stringDay rangeOfString:@" "];
    NSString *date = [stringDay substringToIndex:firstSpace.location];
    NSString *time = [stringDay substringWithRange:NSMakeRange(firstSpace.location+1, stringDay.length-11)];
    if ([date isEqualToString: today]) {   //current date
        NSString *character = [time substringWithRange:NSMakeRange(2, 1)];
        if ([character isEqualToString:@"-"]) {
            time = [time stringByReplacingOccurrencesOfString:@"-" withString:@":"];
        }
        return time;
    }else{
        return date;
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

/*--Hàm add một số lạ vào Blacklist--*/
+ (BOOL)addCallnexIDIntoBlacklist: (NSString *)callnexID{
    BOOL result = NO;
    NSString *tSQL = [NSString stringWithFormat:@"INSERT INTO group_members (id_group, id_member, callnex_id) VALUES (%d, %d, '%@')", 0, -1, callnexID];
    result = [appDelegate._database executeUpdate: tSQL];
    return result;
}

/*--Cập nhat id của contact sau khi được thêm mới chuyển từ id = -1 sang id mới thêm vào--*/
+ (BOOL)updateIdOfGroupMemberWithCallnexID: (NSString *)callnexID andIDForUpdate: (int)idUpdate{
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE group_members SET id_member = %d WHERE id_group = %d AND callnex_id = '%@'", idUpdate, 0, callnexID];
    BOOL success = [appDelegate._database executeUpdate: tSQL];
    return success;
}

/*--get message chưa đọc của một group--*/
+ (int)getNumberMessageUnreadOfGroup: (int)roomID {
    int numberMessageUnread = 0;
    NSString *meString = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT COUNT(*) as count FROM message WHERE (send_phone = '%@' OR receive_phone = '%@') AND status = 'NO' AND room_id = '%@' AND type_message != '%@'", meString, meString, [NSString stringWithFormat:@"%d", roomID], descriptionMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        numberMessageUnread = [[dict objectForKey:@"count"] intValue];
    }
    [rs close];
    return numberMessageUnread;
}

/*--Xoa tat ca message cua mot user--*/
+ (BOOL)deleteMessageOfMe: (NSString *)meString andUser: (NSString *)userString{
    BOOL result = NO;
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM message WHERE (receive_phone='%@' AND send_phone='%@') OR (receive_phone='%@' AND send_phone='%@')", userString, meString, meString, userString];
    result = [appDelegate._database executeUpdate: tSQL];
    return result;
}

// Xóa conversation của mình với group chat
+ (BOOL)deleteConversationOfMeWithRoomChat: (int)roomID
{
    BOOL result = FALSE;
    [appDelegate._database beginTransaction];
    NSString *me = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    // Xoa text message truoc
    NSString *delMsgSQL = [NSString stringWithFormat:@"DELETE FROM message WHERE (send_phone = '%@' OR receive_phone = '%@') AND room_id = %d", me, me, roomID];
    result = [appDelegate._database executeUpdate: delMsgSQL];
    if (result)
    {
        NSString *tSQL = [NSString stringWithFormat:@"SELECT id_message FROM message WHERE (send_phone='%@' OR receive_phone='%@') AND room_id = %d)", me, me, roomID];
        FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
        while ([rs next]) {
            NSDictionary *rsDict = [rs resultDictionary];
            NSString *idMessage = [rsDict objectForKey:@"id_message"];
            [self deleteOneMessageWithId: idMessage];
        }
        NSString *delConSQL = [NSString stringWithFormat:@"DELETE FROM conversation WHERE account = '%@' AND room_id = %d", me, roomID];
        result = [appDelegate._database executeUpdate: delConSQL];
        if (!result) {
            [appDelegate._database rollback];
        }
    }
    [appDelegate._database commit];
    return result;
}

// Xóa conversation của mình với user
+ (BOOL)deleteConversationOfMeWithUser: (NSString *)user
{
    BOOL result = FALSE;
    [appDelegate._database beginTransaction];
    NSString *me = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    // Xoa text message truoc
    NSString *delMsgSQL = [NSString stringWithFormat:@"DELETE FROM message WHERE ((send_phone = '%@' AND receive_phone = '%@') OR (send_phone = '%@' AND receive_phone = '%@')) AND (room_id = '0' OR room_id = '') AND type_message = '%@'", me, user, user, me, textMessage];
    result = [appDelegate._database executeUpdate: delMsgSQL];
    if (result)
    {
        NSString *tSQL = [NSString stringWithFormat:@"SELECT id_message FROM message WHERE ((send_phone='%@' AND receive_phone='%@') OR (send_phone='%@' AND receive_phone='%@')) AND (room_id = '0' OR room_id = '')", me, user, user, me];
        FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
        while ([rs next]) {
            NSDictionary *rsDict = [rs resultDictionary];
            NSString *idMessage = [rsDict objectForKey:@"id_message"];
            [self deleteOneMessageWithId: idMessage];
        }
        NSString *delConSQL = [NSString stringWithFormat:@"DELETE FROM conversation WHERE account = '%@' AND user = '%@'", me, user];
        result = [appDelegate._database executeUpdate: delConSQL];
        if (!result) {
            [appDelegate._database rollback];
        }
    }
    [appDelegate._database commit];
    return result;
}

/*--Xóa tất cả message và conversation đã được lưu--*/
+ (BOOL)deleteAllMessageAndConversationOfMe: (NSString *)myStr{
    BOOL result = NO;
    NSString *me = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    [appDelegate._database beginTransaction];
    NSString *delMsgSQL = [NSString stringWithFormat:@"DELETE FROM message WHERE (send_phone = '%@' OR receive_phone = '%@')", me, me];
    result = [appDelegate._database executeUpdate: delMsgSQL];
    if (!result) {
        [appDelegate._database rollback];
    }else{
        NSString *delConSQL = [NSString stringWithFormat:@"DELETE FROM conversation WHERE account = '%@'", me];
        result = [appDelegate._database executeUpdate: delConSQL];
        if (!result) {
            [appDelegate._database rollback];
        }
    }
    [appDelegate._database commit];
    return result;
}

/*--Get nội dung conversation--*/
+ (NSString *)getContentMessageForwardOfMe: (NSString *)meStr andUser: (NSString *)userStr{
    NSString *contentForward = @"";
    
    NSString *tSQL = [NSString stringWithFormat:@"SELECT type_message, send_phone, content FROM message WHERE (send_phone='%@' AND receive_phone='%@') OR (send_phone='%@' AND receive_phone='%@')", meStr, userStr, userStr, meStr];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        NSString *sendPhone = [dict objectForKey:@"send_phone"];
        NSString *typeMessage = [dict objectForKey:@"type_message"];
        NSString *contentStr = [dict objectForKey:@"content"];

        if ([typeMessage isEqualToString: imageMessage]) {
            if ([contentForward isEqualToString:@""]) {
                if ([sendPhone isEqualToString: userStr]) {
                    contentForward = [NSString stringWithFormat:@"%@: %@", sendPhone, [localization localizedStringForKey:text_image_message_sent]];
                }else{
                    contentForward = [NSString stringWithFormat:@"%@: %@", sendPhone, [localization localizedStringForKey:text_message_image_received]];
                }
            }else{
                if ([sendPhone isEqualToString: userStr]) {
                    contentForward = [NSString stringWithFormat:@"%@\n%@: %@", contentForward,sendPhone, [localization localizedStringForKey:text_image_message_sent]];
                }else{
                    contentForward = [NSString stringWithFormat:@"%@\n%@: %@", contentForward,sendPhone, [localization localizedStringForKey:text_message_image_received]];
                }
            }
        }else if ([typeMessage isEqualToString: audioMessage]){
            if ([contentForward isEqualToString:@""]) {
                if ([sendPhone isEqualToString: userStr]) {
                    contentForward = [NSString stringWithFormat:@"%@: %@", sendPhone, [localization localizedStringForKey:text_audio_message_sent]];
                }else{
                    contentForward = [NSString stringWithFormat:@"%@: %@", sendPhone, [localization localizedStringForKey:text_audio_message_received]];
                }
            }else{
                if ([sendPhone isEqualToString: userStr]) {
                    contentForward = [NSString stringWithFormat:@"%@\n%@: %@", contentForward,sendPhone, [localization localizedStringForKey:text_audio_message_sent]];
                }else{
                    contentForward = [NSString stringWithFormat:@"%@\n%@: %@", contentForward,sendPhone, [localization localizedStringForKey:text_audio_message_received]];
                }
            }
        }else if ([typeMessage isEqualToString: locationMessage]){
            if ([contentForward isEqualToString:@""]) {
                contentForward = [NSString stringWithFormat:@"%@: %@", sendPhone, [localization localizedStringForKey:text_message_location]];
            }else{
                contentForward = [NSString stringWithFormat:@"%@\n%@: %@", contentForward,sendPhone, [localization localizedStringForKey:text_message_location]];
            }
        }else{
            if ([contentForward isEqualToString:@""]) {
                contentForward = [NSString stringWithFormat:@"%@: %@", sendPhone, contentStr];
            }else{
                contentForward = [NSString stringWithFormat:@"%@\n%@: %@", contentForward,sendPhone, contentStr];
            }
        }
    }
    [rs close];
    return contentForward;
}

#pragma mark - show picture when click in view chat
/*--Lấy tên ảnh của một image message--*/
+ (NSArray *)getPictureURLOfMessageImage: (NSString *)idMessage{
    NSString *thumbURL = text_empty;
    int expireTime = -1;
    NSString *description = text_empty;
    NSString *sendPhone = text_empty;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT send_phone, thumb_url, content, expire_time FROM message WHERE id_message = '%@'", idMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        thumbURL = [rsDict objectForKey:@"thumb_url"];
        expireTime = [[rsDict objectForKey:@"expire_time"] intValue];
        description = [rsDict objectForKey:@"description"];
        if (description == nil) {
            description = text_empty;
        }
        sendPhone = [rsDict objectForKey:@"send_phone"];
    }
    [rs close];
    return [[NSArray alloc] initWithObjects:thumbURL, [NSNumber numberWithInt: expireTime], sendPhone, description, nil];
}

#pragma mark - search phonebook

+ (PhoneBookObject *)getAPhoneBookObjectOfContact: (int)idContact andPhoneNumber: (NSString *)phoneNumber{
    PhoneBookObject *aContact = nil;
    
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM contact WHERE id_contact = %d", idContact];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *firstName     = [rsDict objectForKey:@"first_name"];
        NSString *lastName      = [rsDict objectForKey:@"last_name"];
        NSString *avatar        = [rsDict objectForKey:@"avatar"];
        NSString *typePhone     = [rsDict objectForKey:@"type_phone"];
        NSString *nameForSearch = [rsDict objectForKey:@"name_for_search"];
        aContact = [[PhoneBookObject alloc] init];
        if ([firstName isEqualToString:@""] && [lastName isEqualToString:@""]) {
            aContact._pbName = [localization localizedStringForKey:text_unknown];
        }else{
            aContact._pbName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        }
        
        if ([typePhone isEqualToString: typePhoneCallnexID]) {
            [aContact set_isCloudFone: TRUE];
        }
        [aContact set_pbPhone: phoneNumber];
        [aContact set_pbAvatar: avatar];
        [aContact set_idContact: idContact];
        [aContact set_pbNameForSearch: nameForSearch];
    }
    [rs close];
    return aContact;
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
        [aContact set_pbAvatar: text_empty];
        [aContact set_idContact: -1];
        [aContact set_pbNameForSearch: text_empty];
        [currentList addObject: aContact];
    }
    [rs close];
}

+ (void)searchPhoneBookWithName: (NSString *)searchStr withCurrentList: (NSMutableArray *)currentList {
    // Search theo ten bat dau truoc
    NSString *beginSQL = [NSString stringWithFormat:@"SELECT c.id_contact, c.first_name, c.last_name, c.avatar, c.name_for_search, cp.phone_number, cp.type_phone FROM contact c, contact_phone_number cp WHERE (name_for_search LIKE '%@%%' OR name_for_search LIKE '%%%@' OR name_for_search LIKE '%%%@%%' OR phone_number LIKE '%@%%' OR phone_number LIKE '%%%@' OR phone_number LIKE '%%%@%%' OR callnex_id LIKE '%@%%' OR callnex_id LIKE '%%%@' OR callnex_id LIKE '%%%@%%') AND c.id_contact = cp.id_contact ORDER BY CASE WHEN name_for_search LIKE '%@%%' THEN 0 WHEN phone_number LIKE '%@%%' THEN 1 WHEN name_for_search LIKE '%%%@' THEN 2 WHEN phone_number LIKE '%%%@' THEN 3 WHEN name_for_search LIKE '%%%@%%' THEN 4 WHEN phone_number LIKE '%%%@%%' THEN 5 END", searchStr, searchStr, searchStr, searchStr, searchStr, searchStr, searchStr, searchStr, searchStr, searchStr, searchStr, searchStr, searchStr, searchStr, searchStr];
    FMResultSet *rs = [appDelegate._database executeQuery: beginSQL];
    
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        int idContact           = [[rsDict objectForKey:@"id_contact"] intValue];
        NSString *phoneNumber   = [rsDict objectForKey:@"phone_number"];
        NSString *firstName     = [rsDict objectForKey:@"first_name"];
        NSString *lastName      = [rsDict objectForKey:@"last_name"];
        NSString *avatar        = [rsDict objectForKey:@"avatar"];
        NSString *typePhone     = [rsDict objectForKey:@"type_phone"];
        NSString *nameForSearch = [rsDict objectForKey:@"name_for_search"];
        
        if (![phoneNumber isEqualToString:@""]) {
            PhoneBookObject *aContact = [[PhoneBookObject alloc] init];
            if ([firstName isEqualToString:@""] && [lastName isEqualToString:@""]) {
                aContact._pbName = [localization localizedStringForKey:text_unknown];
            }else{
                aContact._pbName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            }
            
            if ([typePhone isEqualToString: typePhoneCallnexID]) {
                aContact._isCloudFone = YES;
            }
            aContact._pbPhone = phoneNumber;
            if ([avatar isEqualToString:@""]) {
                avatar = [self getAvatarForContactWithID: idContact];
            }
            aContact._pbAvatar = avatar;
            aContact._idContact = idContact;
            aContact._pbNameForSearch = nameForSearch;
            [currentList addObject: aContact];
        }
    }
    [rs close];
}

+ (NSString *)getAvatarForContactWithID: (int)idContact {
    NSString *result = @"";
    NSString *tSQL = [NSString stringWithFormat:@"SELECT avatar FROM contact WHERE id_contact = %d", idContact];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        result = [rsDict objectForKey:@"avatar"];
    }
    [rs close];
    return result;
}

+ (NSMutableArray *)searchPhoneBookWithName: (NSString *)searchStr{
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    
    // Search theo ten bat dau truoc
    NSString *beginSQL = [NSString stringWithFormat:@"SELECT c.id_contact, c.first_name, c.last_name, c.avatar, c.name_for_search, cp.phone_number, cp.type_phone FROM contact c, contact_phone_number cp WHERE (name_for_search LIKE '%@%%' OR name_for_search LIKE '%%%@' OR name_for_search LIKE '%%%@%%' OR phone_number LIKE '%@%%' OR phone_number LIKE '%%%@' OR phone_number LIKE '%%%@%%') AND c.id_contact = cp.id_contact ORDER BY CASE WHEN name_for_search LIKE '%@%%' THEN 0 WHEN phone_number LIKE '%@%%' THEN 1 WHEN name_for_search LIKE '%%%@' THEN 2 WHEN phone_number LIKE '%%%@' THEN 3 WHEN name_for_search LIKE '%%%@%%' THEN 4 WHEN phone_number LIKE '%%%@%%' THEN 5 END", searchStr, searchStr, searchStr, searchStr, searchStr, searchStr, searchStr, searchStr, searchStr, searchStr, searchStr, searchStr];
    FMResultSet *rs = [appDelegate._database executeQuery: beginSQL];
    while ([rs next]) {
        
        NSDictionary *rsDict = [rs resultDictionary];
        int idContact           = [[rsDict objectForKey:@"id_contact"] intValue];
        NSString *phoneNumber   = [rsDict objectForKey:@"phone_number"];
        NSString *firstName     = [rsDict objectForKey:@"first_name"];
        NSString *lastName      = [rsDict objectForKey:@"last_name"];
        NSString *avatar        = [rsDict objectForKey:@"avatar"];
        NSString *typePhone     = [rsDict objectForKey:@"type_phone"];
        NSString *nameForSearch = [rsDict objectForKey:@"name_for_search"];
        
        if (![phoneNumber isEqualToString:@""]) {
            PhoneBookObject *aContact = [[PhoneBookObject alloc] init];
            if ([firstName isEqualToString:@""] && [lastName isEqualToString:@""]) {
                aContact._pbName = [localization localizedStringForKey:text_unknown];
            }else{
                aContact._pbName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            }
            
            if ([typePhone isEqualToString: typePhoneCallnexID]) {
                aContact._isCloudFone = YES;
            }
            aContact._pbPhone = phoneNumber;
            aContact._pbAvatar = avatar;
            aContact._idContact = idContact;
            aContact._pbNameForSearch = nameForSearch;
            [resultArr addObject: aContact];
        }
    }
    [rs close];
    return resultArr;
}

// Lấy tên contact theo callnex ID
+ (NSString *)getNameOfContactWithCallnexID: (NSString *)callnexID {
    NSString *fullName = text_empty;
    
    NSString *tSQL = [NSString stringWithFormat:@"SELECT first_name, last_name FROM contact WHERE callnex_id = '%@' ORDER BY id_contact DESC LIMIT 0,1", callnexID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *firstName = [rsDict objectForKey:@"first_name"];
        NSString *lastName = [rsDict objectForKey:@"last_name"];
        
        if ([firstName isEqualToString: text_empty] && [lastName isEqualToString: text_empty]) {
            fullName = callnexID;
        }else if (![firstName isEqualToString: text_empty] && [lastName isEqualToString: text_empty]){
            fullName = firstName;
        }else if ([firstName isEqualToString: text_empty] && ![lastName isEqualToString: text_empty]){
            fullName = lastName;
        }else{
            fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        }
    }
    [rs close];
    return fullName;
}

#pragma mark - chats view controller
// Get sendphone của một message
+ (NSString *)getSendPhoneOfMessage: (NSString *)idMessage{
    NSString *result = @"";
    NSString *tSQL = [NSString stringWithFormat:@"SELECT send_phone FROM message WHERE id_message = '%@' LIMIT 0,1", idMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        result = [rsDict objectForKey:@"send_phone"];
    }
    [rs close];
    return result;
}

// Hàm get tên file của message forward
+ (NSString *)getFileNameAndTypeMessageForward: (NSString *)idMessage{
    NSString *result = @"";
    NSString *tSQL = [NSString stringWithFormat:@"SELECT thumb_url, details_url, type_message FROM message WHERE id_message = '%@'", idMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *thumb_url = [rsDict objectForKey:@"thumb_url"];
        NSString *detailsUrl = [rsDict objectForKey:@"details_url"];
        NSString *typeMessage = [rsDict objectForKey:@"type_message"];
        result = [NSString stringWithFormat:@"%@|%@|%@", typeMessage, thumb_url, detailsUrl];
    }
    [rs close];
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
        
        NSString *detailData = [MyFunctions getImageDataStringOfDirectoryWithName: detailsUrl];
        NSString *thumbData = [MyFunctions getImageDataStringOfDirectoryWithName: thumbUrl];
        
        //  Save anh
        detailsName = [NSString stringWithFormat:@"forward_%@.jpg", [MyFunctions randomStringWithLength: 8]];
        thumbName = [NSString stringWithFormat:@"forward_thumb_%@.jpg", [MyFunctions randomStringWithLength:6]];
        
        [self saveImageToDocumentWithName:detailsName andImageData:detailData];
        [self saveImageToDocumentWithName:thumbName andImageData:thumbData];
    }
    [rs close];
    return [[NSDictionary alloc] initWithObjectsAndKeys:detailsName,@"detail",thumbName,@"thumb", desc, @"description", nil];
}

//  Copy file ghi âm khi forward message
+ (NSDictionary *)copyAudioFileOfMessageForward: (NSString *)idMsgForward{
    NSString *audioName = @"";
    NSData *audioData;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT thumb_url FROM message WHERE id_message = '%@'", idMsgForward];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *thumbUrl = [rsDict objectForKey:@"thumb_url"];
        
        audioName = [NSString stringWithFormat:@"forward_%@_%@.m4a", [MyFunctions getCurrentDate], [MyFunctions getCurrentTimeStamp]];
        
        audioData = [MyFunctions getAudioFileFromFile:thumbUrl andSaveWithName:audioName];
    }
    [rs close];
    return [[NSDictionary alloc] initWithObjectsAndKeys:audioName,@"name",audioData,@"data", nil];
}

/*--Save ảnh với tham số truyền vào là tên ảnh muốn save và data của ảnh--*/
+ (void)saveImageToDocumentWithName: (NSString *)imageName andImageData: (NSString *)dataStr{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *pathFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/files/%@", imageName]];
    NSData *imageData = [NSData dataFromBase64String: dataStr];
    [imageData writeToFile:pathFile atomically:YES];
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
        
        if ([typeMessage isEqualToString: textMessage])
        {
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:key_login] isEqualToString: sendPhone]) {
                messageData = [NSBubbleData dataWithText:content type:BubbleTypeMine time:[MyFunctions stringTimeFromInterval:timeInterval] status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description: @"" withTypeMessage: textMessage isGroup:NO ofUser:nil];
            }else
            {   // Kiểm tra là msg của room hay của user
                if ([roomId isEqualToString:text_empty] || [roomId isEqualToString:@"0"]) {
                    messageData = [NSBubbleData dataWithText:content type:BubbleTypeSomeoneElse time:[MyFunctions stringTimeFromInterval: timeInterval] status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:@"" withTypeMessage:textMessage isGroup:NO ofUser:nil];
                }else{
                    NSString *fullName = [self getFullnameOfContactForGroupWithCallnexID:sendPhone];
                    messageData = [NSBubbleData dataWithText:content type:BubbleTypeSomeoneElse time:[MyFunctions stringTimeFromInterval: timeInterval] status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:@"" withTypeMessage:textMessage isGroup:YES ofUser:fullName];
                    [messageData set_callnexID: sendPhone];
                }
            }
        }else if ([typeMessage isEqualToString: audioMessage]){
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:key_login] isEqualToString: sendPhone]) {
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
                [lbTimerFired setFont: [MyFunctions fontRegularWithSize: 11.0]];
                [lbTimerFired setTextAlignment:NSTextAlignmentRight];
                [recordView addSubview: lbTimerFired];
                messageData = [NSBubbleData dataWithView:recordView type:BubbleTypeMine insets:UIEdgeInsetsMake(15, 5, 15, 10) time:[MyFunctions stringTimeFromInterval: timeInterval] status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:thumbUrl withTypeMessage: audioMessage isGroup:NO ofUser:nil];
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
                [lbTimerFired setFont: [MyFunctions fontRegularWithSize: 11.0]];
                [lbTimerFired setTextAlignment:NSTextAlignmentRight];
                [recordView addSubview: lbTimerFired];
                
                messageData = [NSBubbleData dataWithView:recordView type:BubbleTypeSomeoneElse insets:UIEdgeInsetsMake(15, 12, 15, 5) time:[MyFunctions stringTimeFromInterval: timeInterval] status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:thumbUrl withTypeMessage:audioMessage isGroup:NO ofUser:nil];
            }
        }else if ([typeMessage isEqualToString:imageMessage]){
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:key_login] isEqualToString: sendPhone]) {
                if ([thumbUrl isEqualToString:@""]) {
                    messageData = [NSBubbleData dataWithImage:[UIImage imageNamed:@"unloaded.png"] type:BubbleTypeMine time:[MyFunctions stringTimeFromInterval: timeInterval] status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:descriptionStr withTypeMessage:imageMessage isGroup:NO ofUser:nil];
                }else{
                    UIImage *thumbImg;
                    if ([thumbUrl containsString:@".jpg"] || [thumbUrl containsString:@".JPG"] || [thumbUrl containsString:@".png"] || [thumbUrl containsString:@".PNG"] || [thumbUrl containsString:@".jpeg"] || [thumbUrl containsString:@".JPEG"])
                    {
                        /*  Leo Kelvin
                        NSString *urlString = [ NSString stringWithFormat:@"http://anh.ods.vn/uploads/%@", thumbUrl];
                        NSURL *strURL = [NSURL URLWithString: urlString];
                        NSData *imageData = [NSData dataWithContentsOfURL: strURL];
                        UIImage *thumbImg = nil;
                        if (imageData != nil) {
                            thumbImg = [UIImage imageWithData: imageData];
                        }
                        */
                    }else{
                        thumbImg = [MyFunctions getImageOfDirectoryWithName: thumbUrl];
                        
                    }
                    messageData = [NSBubbleData dataWithImage:thumbImg type:BubbleTypeMine time:[MyFunctions stringTimeFromInterval: timeInterval] status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:descriptionStr withTypeMessage:imageMessage isGroup:NO ofUser:nil];
                }
            }else{
                if ([thumbUrl isEqualToString:@""]) {
                    messageData = [NSBubbleData dataWithImage:[UIImage imageNamed:@"unloaded.png"] type:BubbleTypeSomeoneElse time:[MyFunctions stringTimeFromInterval: timeInterval] status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:descriptionStr withTypeMessage:imageMessage isGroup:NO ofUser:nil];
                }else{
                    UIImage *thumbImg;
                    if ([thumbUrl containsString:@".jpg"] || [thumbUrl containsString:@".JPG"] || [thumbUrl containsString:@".png"] || [thumbUrl containsString:@".PNG"] || [thumbUrl containsString:@".jpeg"] || [thumbUrl containsString:@".JPEG"])
                    {
                        /*  Leo Kelvin
                        NSString *urlString = [ NSString stringWithFormat:@"http://anh.ods.vn/uploads/%@", thumbUrl];
                        NSURL *strURL = [NSURL URLWithString: urlString];
                        NSData *imageData = [NSData dataWithContentsOfURL: strURL];
                        if (imageData != nil) {
                            thumbImg = [UIImage imageWithData: imageData];
                        }
                        */
                    }else{
                        thumbImg = [MyFunctions getImageOfDirectoryWithName: thumbUrl];
                        
                    }
                    messageData = [NSBubbleData dataWithImage:thumbImg type:BubbleTypeSomeoneElse time:[MyFunctions stringTimeFromInterval: timeInterval] status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:descriptionStr withTypeMessage:imageMessage isGroup:NO ofUser:nil];
                }
            }
        }else if ([typeMessage isEqualToString:videoMessage]){
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:key_login] isEqualToString: sendPhone]) {
                UIView *videoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 45)];
                messageData = [NSBubbleData dataWithView:videoView type:BubbleTypeMine insets:UIEdgeInsetsMake(15, 5, 15, 10) time:[MyFunctions stringTimeFromInterval: timeInterval] status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:thumbUrl withTypeMessage: videoMessage isGroup:NO ofUser:nil];
            }else{
                UIView *videoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 45)];
                
                messageData = [NSBubbleData dataWithView:videoView type:BubbleTypeSomeoneElse insets:UIEdgeInsetsMake(15, 12, 15, 5) time:[MyFunctions stringTimeFromInterval:timeInterval] status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:thumbUrl withTypeMessage:videoMessage isGroup:NO ofUser:nil];
            }
        }else if ([typeMessage isEqualToString: descriptionMessage]){
            // Tin nhắn mô tả
            messageData = [NSBubbleData dataWithText:content type:BubbleTypeMine time:[MyFunctions stringTimeFromInterval: timeInterval] status:statusMsg idMessage:idMsgStr withExpireTime:-1 isRecall:@"NO" description: @"" withTypeMessage: descriptionMessage isGroup:NO ofUser:nil];
        }else if ([typeMessage isEqualToString:locationMessage]){
            // Tin nhắn vị trí
            NSString *extraStr = [dict objectForKey:@"extra"];
            NSString *descStr = [dict objectForKey:@"description"];
            
            NSString *descriptionStr = [NSString stringWithFormat:@"%@|%@", extraStr, descStr];
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:key_login] isEqualToString: sendPhone]) {
                if ([thumbUrl isEqualToString:@""]) {
                    messageData = [NSBubbleData dataWithImage:[UIImage imageNamed:@"unloaded-map.png"] type:BubbleTypeMine time:[MyFunctions stringTimeFromInterval: timeInterval] status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:descriptionStr withTypeMessage:locationMessage isGroup:NO ofUser:nil];
                }else{
                    UIImage *thumbImg = [MyFunctions getImageOfDirectoryWithName: thumbUrl];
                    messageData = [NSBubbleData dataWithImage:thumbImg type:BubbleTypeMine time:[MyFunctions stringTimeFromInterval: timeInterval] status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:descriptionStr withTypeMessage:locationMessage isGroup:NO ofUser:nil];
                }
            }else{
                if ([thumbUrl isEqualToString:@""]) {
                    messageData = [NSBubbleData dataWithImage:[UIImage imageNamed:@"unloaded-map.png"] type:BubbleTypeSomeoneElse time:[MyFunctions stringTimeFromInterval: timeInterval] status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:descriptionStr withTypeMessage:locationMessage isGroup:NO ofUser:nil];
                }else{
                    UIImage *thumbImg = [MyFunctions getImageOfDirectoryWithName: thumbUrl];
                    messageData = [NSBubbleData dataWithImage:thumbImg type:BubbleTypeSomeoneElse time:[MyFunctions stringTimeFromInterval: timeInterval] status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:descriptionStr withTypeMessage:locationMessage isGroup:NO ofUser:nil];
                }
            }
        }else if ([typeMessage isEqualToString:contactMessage]){
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:key_login] isEqualToString:sendPhone]) {
                UIView *contactView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 140)];
                messageData = [NSBubbleData dataWithView:contactView type:BubbleTypeMine insets:UIEdgeInsetsMake(15, 12, 15, 5) time:[MyFunctions stringTimeFromInterval: timeInterval] status:statusMsg idMessage:idMsgStr  withExpireTime:expTime isRecall:isRecall description:descriptionStr withTypeMessage:contactMessage isGroup:NO ofUser:nil];
            }else{
                UIView *contactView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 140)];
                messageData = [NSBubbleData dataWithView:contactView type:BubbleTypeSomeoneElse insets:UIEdgeInsetsMake(15, 12, 15, 5) time:[MyFunctions stringTimeFromInterval: timeInterval] status:statusMsg idMessage:idMsgStr  withExpireTime:expTime isRecall:isRecall description:descriptionStr withTypeMessage:contactMessage isGroup:NO ofUser:nil];
            }
        }
    }
    [rs close];
    return messageData;
}

/* 10-08-2014 04-22 PM */
- (NSString *)changeMessageTimestamp: (NSString *)timeString{
    NSString *messageTime = [timeString substringToIndex: 10];
    //get current date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Bangkok"]];
    NSString *currentTime = [formatter stringFromDate:[NSDate date]];
    
    //Nếu tin nhắn trong ngày thì chỉ hiển thị giờ
    if ([messageTime isEqualToString:[currentTime substringToIndex: 10]]) {
        NSString *hourStr = [timeString substringWithRange:NSMakeRange(11, currentTime.length-11)];
        hourStr = [hourStr stringByReplacingOccurrencesOfString:@"-" withString:@":"];
        return hourStr;
    }else{
        return messageTime;
    }
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

// Cập nhật nội dung của message recall nhận
+ (BOOL)updateMessageRecallMeSend: (NSString *)idMessage{
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE message SET content = 'Message recalled successfully', is_recall='YES' WHERE id_message = '%@' AND send_phone='%@'", idMessage, [[NSUserDefaults standardUserDefaults] objectForKey:key_login]];
    BOOL updated = [appDelegate._database executeUpdate: tSQL];
    return updated;
}

// Cập nhật nội dung của message nhận
+ (BOOL)updateMessageDelivered: (NSString *)idMessage {
    NSString *me = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    BOOL result = NO;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT expire_time FROM message WHERE id_message = '%@' AND send_phone = '%@'", idMessage, me];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        int expireTime = [[rsDict objectForKey:@"expire_time"] intValue];
        if (expireTime > 0) {
            NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
            int last_time_expire = (int)curTime + expireTime;
            
            NSString *updateSQL = [NSString stringWithFormat:@"UPDATE message SET delivered_status = 2, last_time_expire = %d  WHERE id_message = '%@' AND send_phone='%@'", last_time_expire, idMessage, me];
            result = [appDelegate._database executeUpdate: updateSQL];
        }else{
            NSString *updateSQL = [NSString stringWithFormat:@"UPDATE message SET delivered_status = 2  WHERE id_message = '%@' AND send_phone='%@'", idMessage, me];
            result = [appDelegate._database executeUpdate: updateSQL];
        }
    }
    return result;
}

/*----- Cập nhật trạng thái của message bị lỗi -----*/
+ (BOOL)updateMessageDeliveredError: (NSString *)idMessage{
    BOOL result = NO;
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE message SET delivered_status = 0  WHERE id_message = '%@' AND send_phone='%@'", idMessage, [[NSUserDefaults standardUserDefaults] objectForKey:key_login]];
    result = [appDelegate._database executeUpdate: tSQL];
    return result;
}

/*--Kiểm tra message đã được nhận hay chưa--*/
+ (BOOL)checkMessageIsReceivedToUser: (NSString *)idMessage{
    BOOL result = NO;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT delivered_status FROM message WHERE id_message = '%@'", idMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        int statusMsg = [[dict objectForKey:@"delivered_status"] intValue];
        if (statusMsg == 2) {
            result = YES;
        }
    }
    [rs close];
    return result;
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

// Save message vào callnex DB với status là NO
+ (void)saveMessage: (NSString*)sendPhone toPhone: (NSString*)receivePhone withContent: (NSString*)content andStatus: (BOOL)messageStatus withDelivered: (int)typeDelivered andIdMsg: (NSString *)idMsg detailsUrl: (NSString *)detailsUrl andThumbUrl: (NSString *)thumbUrl withTypeMessage: (NSString *)typeMessage andExpireTime: (int)expireTime andRoomID: (NSString *)roomID andExtra: (NSString *)extra andDesc: (NSString *)description
{
    // Thời gian hiện tại
    NSTimeInterval curInterval = [[NSDate date] timeIntervalSince1970];
    NSString *me = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    
    int last_time_expire = 0;
    NSString *statusStr = text_empty;
    if (messageStatus) {
        statusStr = @"YES";
        if (![sendPhone isEqualToString: me]) {
            if ([typeMessage isEqualToString: textMessage] || [typeMessage isEqualToString: locationMessage] || [typeMessage isEqualToString: descriptionMessage]) {
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

// Cập nhật delivered của user
+ (void)updateDeliveredMessageOfUser: (NSString *)user idMessage: (NSString *)idMessage {
    // Cập nhật delivered của message
    NSString *meStr = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat: @"UPDATE message SET delivered_status = 2 WHERE receive_phone = '%@' AND send_phone = '%@' AND id_message = '%@'", user, meStr, idMessage];
    [appDelegate._database executeUpdate: tSQL];
    
    // Xoá msg trong fail_message nếu tồn tại
    NSString *delSQL = [NSString stringWithFormat:@"DELETE FROM fail_message WHERE id_message = '%@' AND account = '%@'", idMessage, meStr];
    BOOL delete = [appDelegate._database executeUpdate: delSQL];
    if (!delete) {
        NSLog(@"Can not remove message on fail_message table!!!!!");
    }
    
}

/*--Hàm chuyển trạng thái tin nhắn từ NO->YES khi vào room chat--*/
+ (BOOL)changeStatusMessageOfGroup: (int)roomID{
    NSString *meStr = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE message SET status = 'YES' WHERE (receive_phone='%@' OR send_phone='%@') AND room_id = '%@'",meStr, meStr, [NSString stringWithFormat:@"%d", roomID]];
    BOOL updated = [appDelegate._database executeUpdate: tSQL];
    return updated;
}

/*--Ham xoa 1 message expire theo id--*/
+ (void)deleteOneExpireMessageMeSend: (NSString *)mePhone andIdMsg: (NSString *)idMessage{
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM message WHERE send_phone = '%@' AND id_message = '%@'", mePhone, idMessage];
    BOOL deleted = [appDelegate._database executeUpdate: tSQL];
    if (!deleted) {
        NSLog(@"Can not delete this message!");
    }
}

/* Hàm xoá 1 expire message nhận được, nếu thành công sẽ post notification
 đến view chat để cập nhật lại nội dung
*/
+ (void)deleteOneExpireMessageMeReceive: (NSString *)mePhone withUser: (NSString *)userPhone andIdMsg: (NSString *)idMsg{
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM message WHERE send_phone = '%@' AND receive_phone = '%@' AND id_message = '%@'", userPhone, mePhone, idMsg];
    BOOL deleted = [appDelegate._database executeUpdate: tSQL];
    if (!deleted) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Can not delete this message! Please try again!" delegate:self cancelButtonTitle:@"Confirm" otherButtonTitles: nil];
        [alertView show];
    }
}

// Hàm delete 1 message và file details
+ (BOOL)deleteOneMessageWithId: (NSString *)idMessage
{
    NSString *tSQL = [NSString stringWithFormat:@"SELECT type_message, thumb_url, details_url FROM message WHERE id_message='%@'", idMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *typeMessage = [rsDict objectForKey:@"type_message"];
        if (![typeMessage isEqualToString:textMessage]) {
            NSString *thumb_url     = [rsDict objectForKey:@"thumb_url"];
            NSString *details_url   = [rsDict objectForKey:@"details_url"];
            [MyFunctions deleteDetailsFileOfMessage:typeMessage andDetails:details_url andThumb:thumb_url];
        }
    }
    [rs close];
    
    NSString *tSQL2 = [NSString stringWithFormat:@"DELETE FROM message WHERE id_message='%@'", idMessage];
    BOOL deleted = [appDelegate._database executeUpdate: tSQL2];
    return deleted;
}

// Hàm remove details của 1 message
+ (void)deleteDetailsOfMessageWithId: (NSString *)idMessage{
    NSString *tSQL = [NSString stringWithFormat:@"SELECT type_message, thumb_url, details_url FROM message WHERE id_message='%@'", idMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *typeMessage = [rsDict objectForKey:@"type_message"];
        if (![typeMessage isEqualToString:textMessage]) {
            NSString *thumb_url     = [rsDict objectForKey:@"thumb_url"];
            NSString *details_url   = [rsDict objectForKey:@"details_url"];
            [MyFunctions deleteDetailsFileOfMessage:typeMessage andDetails:details_url andThumb:thumb_url];
        }
    }
    [rs close];
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
        int timeInterval   = [[dict objectForKey:@"time"] intValue];
        NSString *content   = [dict objectForKey:@"content"];
        int statusMsg   = [[dict objectForKey:@"delivered_status"] intValue];
        NSString *idMsgStr = [dict objectForKey:@"id_message"];
        NSString *isRecall = [dict objectForKey:@"is_recall"];
        NSString *detailsUrl = [dict objectForKey:@"details_url"];
        NSString *thumbUrl = [dict objectForKey:@"thumb_url"];
        NSString *typeMessage = [dict objectForKey:@"type_message"];
        int expTime = [[dict objectForKey:@"expire_time"] intValue];
        NSString *descriptionStr = [dict objectForKey:@"description"];
        
        // Thời gian hiển thị cho message
        NSString *fullTime = @"";
        NSString *msgDate = [MyFunctions stringDateFromInterval: timeInterval];
        NSString *msgTime = [MyFunctions stringTimeFromInterval: timeInterval];
        
        if ([msgDate isEqualToString: [MyFunctions getCurrentDate]]) {
            fullTime = msgTime;
        }else{
            fullTime = [NSString stringWithFormat:@"%@ %@", msgDate, msgTime];
        }
        
        if ([typeMessage isEqualToString: textMessage] || [typeMessage isEqualToString: descriptionMessage]) {
            NSBubbleData *messageData  = [[NSBubbleData alloc] init];
            if ([myID isEqualToString: sendPhone]) {
                messageData = [NSBubbleData dataWithText:content type:BubbleTypeMine time:fullTime status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description: @"" withTypeMessage: typeMessage isGroup:NO ofUser:nil];
            }else{
                messageData = [NSBubbleData dataWithText:content type:BubbleTypeSomeoneElse time:fullTime status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:@"" withTypeMessage:typeMessage isGroup:NO ofUser:nil];
            }
            [listContentMessage addObject: messageData];
            appDelegate._heightChatTbView = appDelegate._heightChatTbView + messageData.view.frame.size.height+8;
        }else if([typeMessage isEqualToString: audioMessage]){
            if ([myID isEqualToString: sendPhone]) {
                //UIEdgeInsets(top,left,bottom,right)
                UIView *recordView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 255, 55)];
                
                // add play button
                UIButton *playButton = [[UIButton alloc] initWithFrame:CGRectMake(4, 4, 30, 30)];
                [playButton setBackgroundColor:[UIColor clearColor]];
                [playButton setBackgroundImage:[UIImage imageNamed:@"play_file_transfer.png"]
                                      forState:UIControlStateNormal];
                [playButton setTitle:detailsUrl forState:UIControlStateNormal];
                [playButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
                [recordView addSubview: playButton];
                
                // add background audio
                UIImageView *bgAudio = [[UIImageView alloc] initWithFrame:CGRectMake(playButton.frame.origin.x+playButton.frame.size.width+5, playButton.frame.origin.y, recordView.frame.size.width-(playButton.frame.size.width+10+5), playButton.frame.size.height)];
                [bgAudio setImage:[UIImage imageNamed:@"bg_audio.png"]];
                [bgAudio setBackgroundColor:[UIColor clearColor]];
                [recordView addSubview: bgAudio];
                
                // add slider time
                UISlider *timeSlider = [[UISlider alloc] initWithFrame:CGRectMake(playButton.frame.origin.x+playButton.frame.size.width+18, playButton.frame.origin.y+4, 186, 30)];
                [recordView addSubview: timeSlider];
                
                UILabel *lbTimerFired = [[UILabel alloc] initWithFrame:CGRectMake(bgAudio.frame.origin.x+150, bgAudio.frame.origin.y, 50, 15)];
                [lbTimerFired setFont: [MyFunctions fontRegularWithSize: 11.0]];
                [lbTimerFired setTextAlignment:NSTextAlignmentRight];
                [recordView addSubview: lbTimerFired];
                
                NSBubbleData *recordBubble = [NSBubbleData dataWithView:recordView type:BubbleTypeMine insets:UIEdgeInsetsMake(15, 5, 15, 10) time:fullTime status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:thumbUrl withTypeMessage: audioMessage isGroup:NO ofUser:nil];
                [listContentMessage addObject: recordBubble];
                appDelegate._heightChatTbView = appDelegate._heightChatTbView + recordBubble.view.frame.size.height+8;
            }else{
                UIView *recordView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 255, 55)];
                
                // Add play button
                UIButton *playButton = [[UIButton alloc] initWithFrame:CGRectMake(4, 4, 30, 30)];
                [playButton setBackgroundColor:[UIColor clearColor]];
                [playButton setBackgroundImage:[UIImage imageNamed:@"play_file_transfer.png"]
                                      forState:UIControlStateNormal];
                [playButton setTitle:detailsUrl forState:UIControlStateNormal];
                [playButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
                [recordView addSubview: playButton];
                
                // Add background audio
                UIImageView *bgAudio = [[UIImageView alloc] initWithFrame:CGRectMake(playButton.frame.origin.x+playButton.frame.size.width+5, playButton.frame.origin.y, recordView.frame.size.width-(playButton.frame.size.width+10+5), playButton.frame.size.height)];
                [bgAudio setImage:[UIImage imageNamed:@"bg_audio.png"]];
                [bgAudio setBackgroundColor:[UIColor clearColor]];
                [recordView addSubview: bgAudio];
                
                // Add time slider
                UISlider *timeSlider = [[UISlider alloc] initWithFrame:CGRectMake(playButton.frame.origin.x+playButton.frame.size.width+18, playButton.frame.origin.y+4, 186, 30)];
                [recordView addSubview: timeSlider];
                
                UILabel *lbTimerFired = [[UILabel alloc] initWithFrame:CGRectMake(bgAudio.frame.origin.x+150, bgAudio.frame.origin.y, 50, 15)];
                [lbTimerFired setFont: [MyFunctions fontRegularWithSize: 11.0]];
                [lbTimerFired setTextAlignment:NSTextAlignmentRight];
                [recordView addSubview: lbTimerFired];
                NSBubbleData *recordBubble = [NSBubbleData dataWithView:recordView type:BubbleTypeSomeoneElse insets:UIEdgeInsetsMake(15, 12, 15, 5) time:fullTime status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:thumbUrl withTypeMessage:audioMessage isGroup:NO ofUser:nil];
                appDelegate._heightChatTbView = appDelegate._heightChatTbView + recordBubble.view.frame.size.height+8;
                
                [listContentMessage addObject: recordBubble];
            }
        }else if ([typeMessage isEqualToString: imageMessage]){
            UIImage *thumbImg = [MyFunctions getImageOfDirectoryWithName: thumbUrl];
            if ([myID isEqualToString: sendPhone]) {
                NSBubbleData *photoBubble = [NSBubbleData dataWithImage:thumbImg type:BubbleTypeMine time:fullTime status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:descriptionStr withTypeMessage:imageMessage isGroup:NO ofUser:nil];
                appDelegate._heightChatTbView = appDelegate._heightChatTbView + photoBubble.view.frame.size.height+8;
                
                [listContentMessage addObject: photoBubble];
            }else{
                NSBubbleData *photoBubble = [NSBubbleData dataWithImage:thumbImg type:BubbleTypeSomeoneElse time:fullTime status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:descriptionStr withTypeMessage:imageMessage isGroup:NO ofUser:nil];
                appDelegate._heightChatTbView = appDelegate._heightChatTbView + photoBubble.view.frame.size.height+8;
                
                [listContentMessage addObject: photoBubble];
            }
        }else if ([typeMessage isEqualToString: videoMessage]){
            UIImage *thumbImg = [self getThumbImageOfVideo: detailsUrl];
            if ([myID isEqualToString: sendPhone]) {
                if (thumbImg != nil) {
                    NSBubbleData *photoBubble = [NSBubbleData dataWithImage:thumbImg type:BubbleTypeMine time:fullTime status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:content withTypeMessage:videoMessage isGroup:NO ofUser:nil];
                    appDelegate._heightChatTbView = appDelegate._heightChatTbView + photoBubble.view.frame.size.height+8;
                    
                    [listContentMessage addObject: photoBubble];
                }
            }else{
                if (thumbImg != nil) {
                    NSBubbleData *photoBubble = [NSBubbleData dataWithImage:thumbImg type:BubbleTypeSomeoneElse time:fullTime status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:content withTypeMessage:videoMessage isGroup:NO ofUser:nil];
                    appDelegate._heightChatTbView = appDelegate._heightChatTbView + photoBubble.view.frame.size.height+8;
                    
                    [listContentMessage addObject: photoBubble];
                }
            }
        }else if ([typeMessage isEqualToString: receivingFile]){
            if ([myID isEqualToString: sendPhone]) {
                //
            }else{
                UIView *receivingFileView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 45)];
                UIProgressView *receiveProgess = [[UIProgressView alloc] initWithFrame:CGRectMake(5, 5, 240, 50)];
                [receivingFileView addSubview: receiveProgess];
                UILabel *curPercent = [[UILabel alloc] initWithFrame:CGRectMake((receivingFileView.frame.size.width-100)/2, receiveProgess.frame.origin.y+5, 100, 20)];
                [curPercent setBackgroundColor:[UIColor orangeColor]];
                [receivingFileView addSubview: curPercent];
                
                NSBubbleData *recordBubble = [NSBubbleData dataWithView:receivingFileView type:BubbleTypeSomeoneElse insets:UIEdgeInsetsMake(15, 12, 15, 5) time:fullTime status:statusMsg idMessage:idMsgStr  withExpireTime:expTime isRecall:isRecall description:@"" withTypeMessage:audioMessage isGroup:NO ofUser:nil];
                appDelegate._heightChatTbView = appDelegate._heightChatTbView + recordBubble.view.frame.size.height+8;
                
                [listContentMessage addObject: recordBubble];
            }
        }else if([typeMessage isEqualToString: locationMessage]){
            UIImage *thumbImg = [MyFunctions getImageOfDirectoryWithName: thumbUrl];
            NSString *description = [dict objectForKey:@"description"];
            NSString *address = [dict objectForKey:@"extra"];
            NSString *locationContent = [NSString stringWithFormat:@"%@|%@", address, description];
            
            if ([myID isEqualToString: sendPhone]) {
                if (thumbImg != nil) {
                    NSBubbleData *photoBubble = [NSBubbleData dataWithImage:thumbImg type:BubbleTypeMine time:fullTime status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:locationContent withTypeMessage:locationMessage isGroup:NO ofUser:nil];
                    appDelegate._heightChatTbView = appDelegate._heightChatTbView + photoBubble.view.frame.size.height+8;
                    
                    [listContentMessage addObject: photoBubble];
                }
            }else{
                if (thumbImg != nil) {
                    NSBubbleData *photoBubble = [NSBubbleData dataWithImage:thumbImg type:BubbleTypeSomeoneElse time:fullTime status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:locationContent withTypeMessage:locationMessage isGroup:NO ofUser:nil];
                    appDelegate._heightChatTbView = appDelegate._heightChatTbView + photoBubble.view.frame.size.height+8;
                    
                    [listContentMessage addObject: photoBubble];
                }else{
                    NSBubbleData *photoBubble = [NSBubbleData dataWithImage:[UIImage imageNamed:@"unloaded-map.png"] type:BubbleTypeSomeoneElse time:fullTime status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:locationContent withTypeMessage:locationMessage isGroup:NO ofUser:nil];
                    appDelegate._heightChatTbView = appDelegate._heightChatTbView + photoBubble.view.frame.size.height+8;
                    
                    [listContentMessage addObject: photoBubble];
                }
            }
        }else if ([typeMessage isEqualToString:contactMessage]){
            UIView *contactView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 140)];
            if ([myID isEqualToString: sendPhone]) {
                NSBubbleData *recordBubble = [NSBubbleData dataWithView:contactView type:BubbleTypeMine insets:UIEdgeInsetsMake(15, 12, 15, 5) time:fullTime status:statusMsg idMessage:idMsgStr  withExpireTime:expTime isRecall:isRecall description:descriptionStr withTypeMessage:contactMessage isGroup:NO ofUser:nil];
                appDelegate._heightChatTbView = appDelegate._heightChatTbView + recordBubble.view.frame.size.height+8;
                
                [listContentMessage addObject: recordBubble];
            }else{
                NSBubbleData *recordBubble = [NSBubbleData dataWithView:contactView type:BubbleTypeSomeoneElse insets:UIEdgeInsetsMake(15, 12, 15, 5) time:fullTime status:statusMsg idMessage:idMsgStr  withExpireTime:expTime isRecall:isRecall description:descriptionStr withTypeMessage:contactMessage isGroup:NO ofUser:nil];
                appDelegate._heightChatTbView = appDelegate._heightChatTbView + recordBubble.view.frame.size.height+8;
                
                [listContentMessage addObject: recordBubble];
            }
        }
    }
    [rs close];
    return listContentMessage;
}

// Cập nhật nội dung của message send file sau khi send xong
+ (BOOL)updateDeliveredMessageAfterSend: (NSString *)idMessage
{
    NSString *me = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    BOOL result = NO;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT expire_time FROM message WHERE id_message = '%@' AND send_phone = '%@'", idMessage, me];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        int expireTime = [[rsDict objectForKey:@"expire_time"] intValue];
        if (expireTime > 0) {
            NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
            int last_time_expire = (int)curTime + expireTime;
            
            NSString *updateSQL = [NSString stringWithFormat:@"UPDATE message SET delivered_status = 2, last_time_expire = %d  WHERE id_message = '%@' AND send_phone='%@'", last_time_expire, idMessage, me];
            result = [appDelegate._database executeUpdate: updateSQL];
        }else{
            NSString *updateSQL = [NSString stringWithFormat:@"UPDATE message SET delivered_status = 2  WHERE id_message = '%@' AND send_phone='%@'", idMessage, me];
            result = [appDelegate._database executeUpdate: updateSQL];
        }
    }
    return result;
}

#pragma mark - GoogleMap location

// Get nội dung của một location mesage
+ (NSDictionary *)getContentOfLocationMessage: (NSString *)idMessage
{
    NSString *content = @"";
    NSString *extra = @"";
    NSString *description = @"";
    NSString *detailsName = @"";
    NSString *thumbName = @"";
    
    NSString *tSQL = [NSString stringWithFormat:@"SELECT content, extra, description, details_url, thumb_url FROM message WHERE id_message = '%@' AND type_message = '%@'", idMessage, locationMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        content = [rsDict objectForKey:@"content"];
        extra = [rsDict objectForKey:@"extra"];
        description = [rsDict objectForKey:@"description"];
        
        NSString *detailsUrl = [rsDict objectForKey:@"details_url"];
        NSString *thumbUrl = [rsDict objectForKey:@"thumb_url"];
        
        NSString *detailData = [MyFunctions getImageDataStringOfDirectoryWithName: detailsUrl];
        NSString *thumbData = [MyFunctions getImageDataStringOfDirectoryWithName: thumbUrl];
        
        // Save ảnh cho bản đồ
        detailsName = [NSString stringWithFormat:@"map_%@.PNG", [MyFunctions randomStringWithLength: 8]];
        thumbName = [NSString stringWithFormat:@"map_thumb_%@.PNG", [MyFunctions randomStringWithLength:6]];
        
        [self saveImageToDocumentWithName:detailsName andImageData:detailData];
        [self saveImageToDocumentWithName:thumbName andImageData:thumbData];
    }
    [rs close];
    return [[NSDictionary alloc] initWithObjectsAndKeys:content,@"content",extra,@"extra",description,@"description",detailsName,@"detail",thumbName,@"thumb", nil];
}

#pragma mark - History call
// Lấy tổng số phút gọi đến 1 số
+ (NSArray *)getTotalDurationAndRateOfCallWithPhone: (NSString *)phoneNumber{
    NSString *mySip = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT duration,rate FROM history WHERE my_sip = '%@' AND call_direction='Outgoing' AND status = 'Success' AND phone_number LIKE '%%%@%%'", mySip, phoneNumber];
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



// Get danh sách record call trong lịch sử cuộc gọi
+ (NSMutableArray *)getListRecordCallOfUser: (NSString *)mySip{
    return nil;
}



+ (NSArray *)changePhoneMobileWithSavingCall: (NSString *)phoneStr{
    NSString *prefixStr = text_empty;
    if (phoneStr.length > 3) {
        prefixStr = [phoneStr substringToIndex: 3];
        if ([prefixStr isEqualToString:@"sv-"]) {
            phoneStr = [phoneStr substringFromIndex: 3];
        }else{
            prefixStr = text_empty;
        }
    }
    return [[NSArray alloc] initWithObjects:prefixStr,phoneStr, nil];
}

// Get danh sách cho từng section call của user
+ (NSMutableArray *)getAllCallOnDate: (NSString *)dateStr ofUser: (NSString *)mySip{
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM history WHERE my_sip = '%@' AND date = '%@' ORDER BY _id DESC", mySip, dateStr];
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
        
        aCall._prefixPhone = text_empty;
        aCall._phoneNumber = phoneNumber;
        NSArray *infos = [self getContactInfosWithPhoneNumber: aCall._phoneNumber];
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

// Get danh sách cho từng section call của user

+ (NSMutableArray *)getAllRecordCallOnDate: (NSString *)dateStr ofUser: (NSString *)mySip{
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM history WHERE my_sip = '%@' AND date = '%@' AND record_files != '%@' AND record_files != '%@' ORDER BY _id DESC", mySip, dateStr, text_empty, @"0"];
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
        
        aCall._prefixPhone = text_empty;
        aCall._phoneNumber = phoneNumber;
        NSArray *infos = [self getContactInfosWithPhoneNumber: aCall._phoneNumber];
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

/*--Lấy tên contact theo callnexID, nếu ko có trả về Unknown--*/
+ (NSArray *)getCallNameAndAvatarIntoCallnexID: (NSString *)callnexID{
    
    NSString *fullName = [localization localizedStringForKey:text_unknown];
    NSString *avatarStr = text_empty;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT first_name, last_name, avatar FROM contact WHERE callnex_id = '%@'", callnexID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        NSString *firstName = [dict objectForKey:@"first_name"];
        NSString *lastName = [dict objectForKey:@"last_name"];
        avatarStr = [dict objectForKey:@"avatar"];
        if ([firstName isEqualToString:text_empty] && [lastName isEqualToString:text_empty]) {
            // Do not thing
        }else{
            fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        }
    }
    [rs close];
    return [[NSArray alloc] initWithObjects:fullName,avatarStr, nil];
}

// Lấy tất cả message chưa đọc
+ (int)getAllMessageUnreadForUIMainBar{
    int numMessage = 0;
    NSString *myStr = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT count(*) as numMessage FROM (SELECT * FROM message WHERE status = 'NO' AND (receive_phone = '%@' OR send_phone='%@') GROUP BY send_phone);", myStr, myStr];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        numMessage = [[rsDict objectForKey: @"numMessage"] intValue];
    }
    [rs close];
    return numMessage;
}

/*--Cập nhật trạng thái flag cho history call trong phần detail--*/
+ (BOOL)updateCostAndFlagForHistoryCall: (NSString *)phoneNumber andMySip: (NSString *)mySip{
    return YES;
}

#pragma mark - Blacklist & Whitelist

/*--Hàm lấy tất cả các số có trong Callnex Blacklist--*/
+ (NSMutableArray *)getAllNumberInCallnexBlacklist{
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    
    NSString *tSQL = @"SELECT id_member, callnex_id FROM group_members WHERE id_group = 0";
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        int idMemberBlock = [[rsDict objectForKey:@"id_member"] intValue];
        NSString *callnex_id = [rsDict objectForKey:@"callnex_id"];
        if (idMemberBlock <= 0) {
            [resultArr addObject: callnex_id];
        }else{
            NSString *tSQL2 = [NSString stringWithFormat:@"SELECT phone_number FROM contact_phone_number WHERE id_contact = %d", idMemberBlock];
            FMResultSet *rs2 = [appDelegate._database executeQuery: tSQL2];
            while ([rs2 next]) {
                NSDictionary *rsDict2 = [rs2 resultDictionary];
                NSString *phoneBlock = [rsDict2 objectForKey:@"phone_number"];
                [resultArr addObject: phoneBlock];
            }
            [rs2 close];
        }
    }
    [rs close];
    return resultArr;
}


/*--Hàm lấy tất cả danh sách của Whitelist--*/
+ (NSMutableArray *)getAllNumberInCallnexWhitelist{
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    
    NSString *tSQL = @"SELECT id_member, callnex_id FROM group_members WHERE id_group = 1";
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        int idMemberBlock = [[rsDict objectForKey:@"id_member"] intValue];
        NSString *callnex_id = [rsDict objectForKey:@"callnex_id"];
        if (idMemberBlock <= 0) {
            [resultArr addObject: callnex_id];
        }else{
            NSString *tSQL2 = [NSString stringWithFormat:@"SELECT phone_number FROM contact_phone_number WHERE id_contact = %d", idMemberBlock];
            FMResultSet *rs2 = [appDelegate._database executeQuery: tSQL2];
            while ([rs2 next]) {
                NSDictionary *rsDict2 = [rs2 resultDictionary];
                NSString *phoneBlock = [rsDict2 objectForKey:@"phone_number"];
                [resultArr addObject: phoneBlock];
            }
            [rs2 close];
        }
    }
    [rs close];
    return resultArr;
}

+ (NSString *)getNameOfPBXPhone: (NSString *)phoneNumber {
    NSString *name = text_empty;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT name FROM pbx_contacts WHERE number = '%@' ORDER BY id DESC LIMIT 0,1", phoneNumber];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        name = [rsDict objectForKey:@"name"];
    }
    [rs close];
    return name;
}

//  Lấy tên contact với phonenumber
+ (NSArray *)getContactInfosWithPhoneNumber: (NSString *)phoneNumber {
    
    NSString *fullName = text_empty;
    NSString *avatar = text_empty;
    
    NSString *name = [NSDBCallnex getNameOfPBXPhone: phoneNumber];
    if (![name isEqualToString: text_empty]) {
        return [[NSArray alloc] initWithObjects: name, text_empty, nil];
    }else{
        NSString *tSQL = [NSString stringWithFormat:@"SELECT first_name, last_name, avatar FROM contact WHERE callnex_id = '%@' ORDER BY id_contact DESC LIMIT 0,1", phoneNumber];
        FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
        while ([rs next]) {
            NSDictionary *rsDict = [rs resultDictionary];
            NSString *firstName = [rsDict objectForKey:@"first_name"];
            NSString *lastName = [rsDict objectForKey:@"last_name"];
            avatar = [rsDict objectForKey:@"avatar"];
            if (![firstName isEqualToString:text_empty] && [lastName isEqualToString:text_empty]) {
                fullName = firstName;
            }else if ([firstName isEqualToString:text_empty] && ![lastName isEqualToString:text_empty]){
                fullName = lastName;
            }else if (![firstName isEqualToString:text_empty] && ![lastName isEqualToString:text_empty]){
                fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            }
        }
        if ([fullName isEqualToString:text_empty]) {
            fullName = phoneNumber;
        }
        [rs close];
        
        return [[NSArray alloc] initWithObjects:fullName,avatar, nil];
    }
}

/*--Get số section cho tableview trong history call--*/
+ (int)getSectionForHistoryCall: (NSString *)mySip withPhone: (NSString *)phoneNumber andCallDirection: (NSString *)callDirection{
    int numRows = 0;
    NSString *checkIncommingSQL = [NSString stringWithFormat:@"SELECT COUNT(*) as numRows FROM history WHERE my_sip='%@' AND phone_number='%@' AND call_direction='%@'", mySip, phoneNumber, callDirection];
    FMResultSet *rs = [appDelegate._database executeQuery: checkIncommingSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        numRows = [[rsDict objectForKey:@"numRows"] intValue];
    }
    [rs close];
    return numRows;
}

// Get danh sách cuộc gọi với một số
+ (NSMutableArray *)getAllListCallOfMe: (NSString *)mySip withPhoneNumber: (NSString *)phoneNumber andCallDirection: (NSString *)callDirection{
    
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    
    NSString *dateSQL = text_empty;
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

//  Get danh sách các contact trong ds cuộc gọi cuối cùng
+ (NSMutableArray *)getContactInHistoryCallWithRow: (int)numGet andSeachNumber: (NSString *)searchStr{
    if (searchStr.length == 7) {
        if ([searchStr isEqualToString:@"hotline"]) {
            searchStr = @"999";
        }
    }
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT DISTINCT phone_number FROM history WHERE phone_number LIKE '%%%@%%' ORDER BY _id DESC LIMIT 0,%d", searchStr, numGet];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    //  sv-841659419119
    while ([rs next]) {
        BOOL isCallnex = NO;
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *phoneNumber = [rsDict objectForKey:@"phone_number"];
        NSString *tSQL2 = [NSString stringWithFormat:@"SELECT * FROM contact WHERE callnex_id = '%@' ORDER BY id_contact DESC LIMIT 0,1", phoneNumber];
        FMResultSet *rs2 = [appDelegate._database executeQuery: tSQL2];
        while ([rs2 next]) {
            NSDictionary *rsDict2 = [rs2 resultDictionary];
            
            int idContact = [[rsDict2 objectForKey:@"id_contact"] intValue];
            NSString *fullName = @"";
            NSString *avatar = [rsDict2 objectForKey:@"avatar"];
            
            NSString *firstName = [rsDict2 objectForKey:@"first_name"];
            NSString *lastName = [rsDict2 objectForKey:@"last_name"];
            if (![firstName isEqualToString:@""] && [lastName isEqualToString:@""]) {
                fullName = firstName;
            }else if ([firstName isEqualToString:@""] && ![lastName isEqualToString:@""]){
                fullName = lastName;
            }else if (![firstName isEqualToString:@""] && ![lastName isEqualToString:@""]){
                fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            }
            NSString *nameForSearch = [rsDict2 objectForKey:@"name_for_search"];
            
            PhoneBookObject *aContact = [[PhoneBookObject alloc] init];
            
            if (phoneNumber.length > 6 && [[phoneNumber substringToIndex: 6] isEqualToString:@"778899"]) {
                aContact._isCloudFone = YES;
            }
            aContact._pbPhone = phoneNumber;
            aContact._pbAvatar = avatar;
            aContact._idContact = idContact;
            aContact._pbName = fullName;
            aContact._pbNameForSearch = nameForSearch;
            [resultArr addObject: aContact];
            
            isCallnex = YES;
        }
        [rs2 close];
        
        if (!isCallnex) {
            BOOL exists = NO;
            
            if ([[phoneNumber substringToIndex:3] isEqualToString:@"sv-"]) {
                phoneNumber = [phoneNumber substringFromIndex:3];
            }
            
            // Lấy id contact của phoneNumber
            NSString *tSQL3 = [NSString stringWithFormat:@"SELECT id_contact FROM contact_phone_number WHERE phone_number = '%@' ORDER BY id DESC LIMIT 0,1", phoneNumber];
            FMResultSet *rs3 = [appDelegate._database executeQuery: tSQL3];
            while ([rs3 next]) {
                NSString *fullName = [localization localizedStringForKey:text_unknown];
                NSString *avatar = @"";
                
                NSDictionary *rsDict3 = [rs3 resultDictionary];
                int idContact = [[rsDict3 objectForKey:@"id_contact"] intValue];
                NSString *tSQL4 = [NSString stringWithFormat:@"SELECT DISTINCT first_name, last_name, avatar, name_for_search FROM contact c, contact_phone_number cp WHERE c.id_contact = %d AND c.id_contact = cp.id_contact AND (name_for_search LIKE '%@%%' OR name_for_search LIKE '%%%@' OR name_for_search LIKE '%%%@%%' OR phone_number LIKE '%@%%' OR phone_number LIKE '%%%@' OR phone_number LIKE '%%%@%%')  ORDER BY CASE WHEN name_for_search LIKE '%@%%' THEN 0 WHEN phone_number LIKE '%@%%' THEN 1 WHEN name_for_search LIKE '%%%@' THEN 2 WHEN phone_number LIKE '%%%@' THEN 3 WHEN name_for_search LIKE '%%%@%%' THEN 4 WHEN phone_number LIKE '%%%@%%' THEN 5 END", idContact, searchStr, searchStr, searchStr, searchStr, searchStr, searchStr, searchStr, searchStr, searchStr, searchStr, searchStr, searchStr];
                FMResultSet *rs4 = [appDelegate._database executeQuery: tSQL4];
                
                while ([rs4 next]) {
                    PhoneBookObject *aContact = [[PhoneBookObject alloc] init];
                    
                    NSDictionary *rsDict4 = [rs4 resultDictionary];
                    NSString *firstName = [rsDict4 objectForKey:@"first_name"];
                    NSString *lastName = [rsDict4 objectForKey:@"last_name"];
                    NSString *nameForSearch = [rsDict4 objectForKey:@"name_for_search"];
                    
                    if (![firstName isEqualToString:@""] || ![lastName isEqualToString:@""]) {
                        fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                    }else if (![firstName isEqualToString:@""] && [lastName isEqualToString:@""]){
                        fullName = firstName;
                    }else if ([firstName isEqualToString:@""] && ![lastName isEqualToString:@""]){
                        fullName = lastName;
                    }
                    avatar = [rsDict4 objectForKey:@"avatar"];
                    
                    if (phoneNumber.length > 6 && [[phoneNumber substringToIndex: 6] isEqualToString:@"778899"]) {
                        aContact._isCloudFone = YES;
                    }
                    aContact._pbPhone = phoneNumber;
                    aContact._pbAvatar = avatar;
                    aContact._idContact = idContact;
                    aContact._pbName = fullName;
                    aContact._pbNameForSearch = nameForSearch;
                    [resultArr addObject: aContact];
                    exists = YES;
                }
                [rs4 close];
            }
            [rs3 close];
            
            // Nếu contact không tồn tại thì tạo contact rỗng thêm vào
            if (!exists) {
                NSRange range = [phoneNumber rangeOfString: searchStr];
                if (range.location != NSNotFound) {
                    PhoneBookObject *aContact = [[PhoneBookObject alloc] init];
                    aContact._pbPhone = phoneNumber;
                    aContact._pbAvatar = @"";
                    aContact._idContact = 0;
                    aContact._pbNameForSearch = @"";
                    aContact._pbName = [localization localizedStringForKey:text_unknown];
                    [resultArr addObject: aContact];
                }
            }
        }
    }
    [rs close];
    return resultArr;
}

#pragma mark - Access Number
// Kiểm tra một quốc gia có trong list hay không?
+ (BOOL)checkCountryCodeExistsInCurrentList: (NSString *)countryCode {
    BOOL result = NO;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM country WHERE code = '%@' LIMIT 0,1", countryCode];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        result = YES;
    }
    [rs close];
    return result;
}

// Lấy state name theo access number
+ (NSString *)getStateNameOfCountryWithAccessNumber: (NSString *)accessNum {
    NSString *stateName = @"";
    NSString *tSQL = [NSString stringWithFormat:@"SELECT name FROM locals WHERE number = '%@'", accessNum];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        stateName = [rsDict objectForKey:@"name"];
    }
    [rs close];
    return stateName;
}


// Lấy state và access number của một country
+ (NSString *)getAccessNumberDefaultWithCountry: (NSString *)country{
    NSString *accessNum = @"";
    
    NSString *tSQL = [NSString stringWithFormat:@"SELECT number FROM locals WHERE country = '%@' ORDER BY id ASC LIMIT 0,1", country];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        accessNum = [rsDict objectForKey:@"number"];
    }
    [rs close];
    return accessNum;
}

// Hàm get tên của country theo  code country: US -> United States
+ (NSString *)getCountryNameFromCountryCode: (NSString *)countryCode{
    
    NSString *resultStr = @"";
    NSString *tSQL = [NSString stringWithFormat:@"SELECT name FROM country WHERE code = '%@'", countryCode];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        resultStr = [rsDict objectForKey:@"name"];
    }
    [rs close];
    return resultStr;
}

// Kiểm tra 1 access number có thuộc country đó hay không
+ (BOOL)checkAnAccessNumber: (NSString *)accessNum mapWithCountry: (NSString *)country {
    BOOL result = NO;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM locals WHERE number = '%@' AND country = '%@' LIMIT 0,1", accessNum, country];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        result = YES;
    }
    [rs close];
    return result;
}

// Đếm số contact hiện tại trong list
+ (int)getNumberCurrentOfCountryInList {
    int result = 0;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT COUNT(*) as numCountry FROM country"];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        result = [[rsDict objectForKey:@"numCountry"] intValue];
    }
    [rs close];
    return result;
}
#pragma mark - Expire message
// Cập nhật last_time_expire của một msg có expire_time
+ (BOOL)updateLastTimeExpireOfImageMessage: (NSString *)idMessage
{
    NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
    NSString *me = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE message SET last_time_expire = %d + expire_time WHERE expire_time > 0 AND last_time_expire = 0 AND type_message = '%@' AND id_message = '%@' AND (send_phone = '%@' OR receive_phone = '%@')", (int)curTime, imageMessage, idMessage, me, me];
    return [appDelegate._database executeUpdate: tSQL];
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

// Đếm các tin nhắn expire đã đọc text của 1 room chat
+ (int)getAllMessageExpireOfMeInRoomChat: (int)roomID {
    int result = 0;
    NSString *me = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT COUNT(*) as numMessage FROM message WHERE (send_phone = '%@' OR receive_phone = '%@') AND room_id = %d AND expire_time > %d AND last_time_expire > 0 AND status = 'YES' AND delivered_status = 2", me, me, roomID, 0];
    FMResultSet *rs = [appDelegate._database executeQuery:tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        result = [[rsDict objectForKey:@"numMessage"] intValue];
    }
    [rs close];
    return result;
}

// Đếm các tin nhắn expire đã đọc text của 1 user
+ (int)getAllMessageExpireOfMe {
    int result = 0;
    NSString *me = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT COUNT(*) as numMessage FROM message WHERE (send_phone = '%@' OR receive_phone = '%@') AND (room_id = '' OR room_id = '0') AND expire_time > %d AND last_time_expire > 0 AND status = 'YES' AND delivered_status = 2", me, me, 0];
    FMResultSet *rs = [appDelegate._database executeQuery:tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        result = [[rsDict objectForKey:@"numMessage"] intValue];
    }
    [rs close];
    return result;
}

// Cập nhật last_time_expire cho message của user hiện tại
+ (void)updateLastTimeExpireForMessageOfUser: (NSString *)user {
    NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
    NSString *me = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    
    // Xoá các tin nhắn đã hết hạn trước
    NSString *delSQL = [NSString stringWithFormat:@"DELETE FROM message WHERE last_time_expire > 0 AND last_time_expire <= %d AND status = 'YES' AND delivered_status = 2 AND (send_phone = '%@' OR receive_phone='%@')", (int)curTime, me, me];
    BOOL delete = [appDelegate._database executeUpdate: delSQL];
    if (!delete) {
        NSLog(@".....Xoa khong thanh cong");
    }
    // Cập nhật tất cả các msg chưa có last_time_expire
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE message SET last_time_expire = %d + expire_time WHERE ((send_phone = '%@' AND receive_phone = '%@') OR (send_phone = '%@' AND receive_phone = '%@')) AND expire_time > 0 AND last_time_expire = 0 AND delivered_status = 2 AND (type_message = '%@' OR type_message = '%@' OR type_message = '%@')", (int)curTime, me, user, user, me, textMessage, locationMessage, descriptionMessage];
    BOOL update = [appDelegate._database executeUpdate: tSQL];
    if (!update) {
        NSLog(@"update failed....");
    }
}

// Xoá tất cả tin nhắn expire đã hết hạn (Thời gian hiện tại >= thời gian hết hạn)
+ (void)deleteAllMesageExpiredOfMe {
    NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
    NSString *me = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    
    // select tất cả msg hết hạn
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM message WHERE (send_phone = '%@' OR receive_phone = '%@') AND (room_id = '' OR room_id = '0') AND status = 'YES' AND delivered_status = 2 AND last_time_expire > 0 AND last_time_expire <= %d", me, me, (int)curTime];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *idMessage = [rsDict objectForKey:@"id_message"];
        [self deleteDetailsOfMessageWithId: idMessage];
    }
    [rs close];
    
    NSString *delSQL = [NSString stringWithFormat:@"DELETE FROM message WHERE (send_phone = '%@' OR receive_phone = '%@') AND (room_id = '' OR room_id = '0') AND status = 'YES' AND last_time_expire > 0 AND last_time_expire <= %d", me, me, (int)curTime];
     BOOL result = [appDelegate._database executeUpdate: delSQL];
    if (result) {
        NSLog(@"update success...");
    }else{
        NSLog(@"update failed....");
    }
}

// Get danh sách ID của các message hết hạn của một user (để remove khỏi list chat)
+ (NSArray *)getAllMessageExpireEndedOfMeWithUser: (NSString *)user
{
    NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
    
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    NSString *me = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id_message FROM message WHERE ((send_phone='%@' AND receive_phone='%@') OR (send_phone='%@' AND receive_phone='%@')) AND status = 'YES' AND delivered_status = 2 AND last_time_expire > 0 AND last_time_expire <= %d", me, user, user, me, (int)curTime];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *idMessage = [rsDict objectForKey:@"id_message"];
        [resultArr addObject: idMessage];
    }
    [rs close];
    return  resultArr;
}

// Get danh sách ID của các message hết hạn của một group (để remove khỏi list chat)
+ (NSArray *)getAllMessageExpireEndedOfMeWithGroup: (int)groupID
{
    NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
    
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    NSString *me = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id_message FROM message WHERE (send_phone='%@' OR receive_phone='%@') AND status = 'YES' AND delivered_status = 2 AND last_time_expire > 0 AND last_time_expire <= %d AND room_id = %d", me, me, (int)curTime, groupID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *idMessage = [rsDict objectForKey:@"id_message"];
        [resultArr addObject: idMessage];
    }
    [rs close];
    return  resultArr;
}

// Hàm get tất cả danh sách ảnh
+ (NSMutableArray *)getAllImageIdOfMeWithUser: (NSString *)userStr{
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    NSString *meStr = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id_message FROM message WHERE ((send_phone = '%@' AND receive_phone = '%@') OR (send_phone = '%@' AND receive_phone = '%@')) AND type_message = '%@'", meStr, userStr, userStr, meStr, imageMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *idMessage = [rsDict objectForKey:@"id_message"];
        [resultArr addObject: idMessage];
    }
    [rs close];
    return resultArr;
}

// Cập nhật last_time_expire khi click play audio có expire time
+ (BOOL)updateExpireTimeWhenClickPlayExpireAudioMessage: (NSString *)idMessage withAudioLength: (int)expireAudio
{
    NSString *me = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
    
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE message SET last_time_expire = %d + %d + expire_time WHERE id_message = '%@' AND delivered_status = 2 AND last_time_expire = 0 AND expire_time > 0 AND type_message = '%@' AND (send_phone = '%@' OR receive_phone = '%@')", (int)curTime, expireAudio, idMessage, audioMessage, me, me];
    return [appDelegate._database executeUpdate: tSQL];
}

#pragma mark - recall message
/*--Hàm recall message--*/
+ (BOOL)updateMessageRecallMeReceive: (NSString *)idMessage{
    BOOL result = NO;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT type_message, details_url, thumb_url FROM message WHERE id_message = '%@'", idMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *typeMessage = [rsDict objectForKey:@"type_message"];
        if (![typeMessage isEqualToString:textMessage]) {
            NSString *details = [rsDict objectForKey:@"details_url"];
            NSString *thumb_url = [rsDict objectForKey:@"thumb_url"];
            [MyFunctions deleteDetailsFileOfMessage:typeMessage andDetails:details andThumb:thumb_url];
        }
        NSString *tSQL2 = [NSString stringWithFormat:@"UPDATE message SET content = 'Message was recalled', is_recall='YES', delivered_status = 0, type_message='%@' WHERE id_message = '%@' AND receive_phone='%@'", textMessage, idMessage, [[NSUserDefaults standardUserDefaults] objectForKey:key_login]];
        result = [appDelegate._database executeUpdate: tSQL2];
    }
    return result;
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

#pragma mark - PlacesViewController functions
/*--Get danh sách location đã send--*/
+ (NSMutableArray *)getLocationListMeSend{
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    NSString *meStr = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT DISTINCT date FROM message WHERE send_phone = '%@' AND type_message = '%@' ORDER BY id DESC", meStr, locationMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *date = [rsDict objectForKey:@"date"];
        NSDictionary *listDict = [self getListLocationSendOnDate: date];
        [resultArr addObject: listDict];
    }
    [rs close];
    return resultArr;
}

/*--Get list location send trong ngày--*/
+ (NSMutableDictionary *)getListLocationSendOnDate: (NSString *)date
{
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    [resultDict setObject:date forKey:@"date"];
    
    NSMutableArray *listLocation = [[NSMutableArray alloc] init];
    NSString *meStr = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT receive_phone, time, description, id_message FROM message WHERE send_phone = '%@' AND type_message = '%@' AND date = '%@' ORDER BY id DESC", meStr, locationMessage, date];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *idMessage = [rsDict objectForKey:@"id_message"];
        NSString *receivePhone = [rsDict objectForKey:@"receive_phone"];
        NSString *time = [rsDict objectForKey:@"time"];
        NSString *description = [rsDict objectForKey:@"description"];
        
        LocationHisObj *aLocObj = [[LocationHisObj alloc] init];
        aLocObj._userCallnex = receivePhone;
        aLocObj._isReceived = NO;
        aLocObj._date = date;
        aLocObj._time = time;
        aLocObj._description = description;
        aLocObj._idLocMessage = idMessage;
        [listLocation addObject: aLocObj];
    }
    [resultDict setObject:listLocation forKey:@"list"];
    return resultDict;
}

/*--Get danh sách location nhận--*/
+ (NSMutableArray *)getLocationListMeReceive{
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    NSString *meStr = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT DISTINCT date FROM message WHERE receive_phone = '%@' AND type_message = '%@' ORDER BY id DESC", meStr, locationMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *date = [rsDict objectForKey:@"date"];
        NSDictionary *listDict = [self getListLocationReceiveOnDate: date];
        [resultArr addObject: listDict];
    }
    [rs close];
    return resultArr;
}

/*--Get list location nhận trong ngày--*/
+ (NSMutableDictionary *)getListLocationReceiveOnDate: (NSString *)date
{
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    [resultDict setObject:date forKey:@"date"];
    
    NSMutableArray *listLocation = [[NSMutableArray alloc] init];
    NSString *meStr = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT send_phone, time, description, id_message FROM message WHERE receive_phone = '%@' AND type_message = '%@' AND date = '%@' ORDER BY id DESC", meStr, locationMessage, date];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *sendPhone = [rsDict objectForKey:@"send_phone"];
        NSString *time = [rsDict objectForKey:@"time"];
        NSString *description = [rsDict objectForKey:@"description"];
        NSString *idMessage = [rsDict objectForKey:@"id_message"];
        
        LocationHisObj *aLocObj = [[LocationHisObj alloc] init];
        aLocObj._userCallnex = sendPhone;
        aLocObj._isReceived = YES;
        aLocObj._date = date;
        aLocObj._time = time;
        aLocObj._description = description;
        aLocObj._idLocMessage = idMessage;
        [listLocation addObject: aLocObj];
    }
    [resultDict setObject:listLocation forKey:@"list"];
    return resultDict;
}

/*--Get danh sách location đã save--*/
+ (NSMutableArray *)getListLocationSaved{
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    
    NSString *meStr = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT DISTINCT date FROM locations WHERE (from_user = '%@' OR to_user = '%@')", meStr, meStr];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *date = [rsDict objectForKey:@"date"];
        NSDictionary *listDict = [self getListLocationSavedOnDate: date];
        [resultArr addObject: listDict];
    }
    [rs close];
    return resultArr;
}

/*--Get danh sách location theo ngày--*/
+ (NSMutableDictionary *)getListLocationSavedOnDate: (NSString *)date
{
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    [resultDict setObject:date forKey:@"date"];
    
    NSMutableArray *listLocation = [[NSMutableArray alloc] init];
    
    NSString *meStr = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM locations WHERE date = '%@' AND (from_user = '%@' OR to_user = '%@') ORDER BY id DESC", date, meStr, meStr];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        
        NSString *from = [rsDict objectForKey:@"from_user"];
        NSString *time = [rsDict objectForKey:@"time"];
        NSString *description = [rsDict objectForKey:@"description"];
        NSString *idMessage = [rsDict objectForKey:@"id_message"];
        
        LocationHisObj *aLocObj = [[LocationHisObj alloc] init];
        aLocObj._userCallnex = from;
        aLocObj._isReceived = YES;
        aLocObj._date = date;
        aLocObj._time = time;
        aLocObj._description = description;
        aLocObj._idLocMessage = idMessage;
        [listLocation addObject: aLocObj];
    }
    [resultDict setObject:listLocation forKey:@"list"];
    return resultDict;
}

/*--Save locaion hiện tại của user--*/
+ (BOOL)saveLocationWithLat: (NSString *)latitude lng: (NSString *)longtitude address: (NSString *)address description: (NSString *)description from: (NSString *)from to: (NSString *)to{
    NSString *currentDate = [MyFunctions getCurrentDate];
    NSString *currentTime = [MyFunctions getCurrentTimeStamp];
    
    NSString *tSQL = [NSString stringWithFormat:@"INSERT INTO locations(latitude, longtitude, date, time, description, address, from_user, to_user) VALUES ('%@','%@','%@','%@','%@','%@','%@','%@')", latitude, longtitude, currentDate, currentTime, description, address, from, to];
    BOOL result = [appDelegate._database executeUpdate:tSQL];
    return result;
}

/*--get danh sách group có thể tham gia--*/
+ (NSMutableArray *)getListGroupOfMe {
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT room_name FROM room_chat WHERE status = 1 AND user = '%@'", [[NSUserDefaults standardUserDefaults] objectForKey:key_login]];
    appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
//    FMResultSet *rs = [database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *roomName = [rsDict objectForKey: @"room_name"];
        [resultArr addObject: roomName];
    }
    [rs close];
    return resultArr;
}

/*--Xoa group ra khoi database--*/
+ (BOOL)deleteARoomChatWithRoomName: (NSString *)roomName {
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE room_chat SET status = '%d' WHERE room_name = '%@'", 0, roomName];
    BOOL result = [appDelegate._database executeUpdate: tSQL];
    return result;
}

#pragma mark - CONVERSATIONS
/*--Save một conversation cho user trong view chat--*/
+ (void)saveConversationForViewChatForUser: (NSString *)user withUnread: (BOOL)isUnread {
    
    BOOL isExists = NO;
    int numMsgUnread = 0;
    
    NSString *me = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT unread FROM conversation WHERE account = '%@' AND user = '%@'", me, user];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        numMsgUnread = [[rsDict objectForKey:@"unread"] intValue];
        isExists = YES;
    }
    
    if (isUnread) {
        numMsgUnread = numMsgUnread + 1;
    }
    
    
    if (!isExists) {
        NSString *addSQL = [NSString stringWithFormat:@"INSERT INTO conversation (account, user, room_id, message_draf, background, expire, unread, inear_mode) VALUES ('%@', '%@', '%@', '%@', '%@', %d, %d, %d)", me, user, @"0", @"", @"", 0, numMsgUnread, 0];
        [appDelegate._database executeUpdate: addSQL];
    }
    [rs close];
}

/*--Get nội dung message cuối cùng của một room chat--*/
+ (NSArray *)getContentOfLastMessageOfRoomChat: (int)roomID
{
    int idMessage = 0;
    NSString *content = @"";
    NSString *typeMessage = @"";
    int timeInterval;
    
    NSString *me = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *room = [NSString stringWithFormat:@"%d", roomID];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id, content, time, type_message FROM message WHERE (send_phone = '%@' OR receive_phone = '%@') AND room_id = '%@'", me, me, room];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        idMessage = [[rsDict objectForKey:@"id"] intValue];
        content = [rsDict objectForKey:@"content"];
        typeMessage = [rsDict objectForKey:@"type_message"];
        timeInterval = [[rsDict objectForKey:@"time"] intValue];
        
        if ([typeMessage isEqualToString:imageMessage]) {
            content = @"Image sent";
        }else if ([typeMessage isEqualToString: locationMessage]){
            content = @"Location message";
        }
    }
    [rs close];
    return [[NSArray alloc] initWithObjects:content, [MyFunctions stringDateFromInterval: timeInterval], [MyFunctions stringTimeFromInterval: timeInterval], [NSNumber numberWithInt: idMessage], nil];
}

/*--save expire time cho một group--*/
+ (BOOL)saveExpireTimeForGroup: (NSString *)groupId withExpireTime: (int)expireTime
{
    BOOL result;
    BOOL exists = NO;
    NSString *me = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id FROM conversation WHERE account = '%@' AND room_id = '%@' LIMIT 0,1", me, groupId];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        exists = YES;
    }
    if (exists) {
        NSString *tSQL2 = [NSString stringWithFormat:@"UPDATE conversation SET expire = %d WHERE account = '%@' AND room_id = '%@'", expireTime, me, groupId];
        result = [appDelegate._database executeUpdate: tSQL2];
    }else{
        NSString *tSQL2 = [NSString stringWithFormat:@"INSERT INTO conversation (account, user, room_id, background, expire, inear_mode) VALUES ('%@', '%@', '%@', '%@', %d, %d)", me, text_empty, groupId, text_empty, expireTime, 0];
        result = [appDelegate._database executeUpdate: tSQL2];
    }
    return result;
}

/*--save expire time cho một user--*/
+ (BOOL)saveExpireTimeForUser: (NSString *)user withExpireTime: (int)expireTime {
    BOOL result;
    BOOL exists = NO;
    NSString *me = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id FROM conversation WHERE account = '%@' AND user = '%@' LIMIT 0,1", me, user];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        exists = YES;
    }
    if (exists) {
        NSString *tSQL2 = [NSString stringWithFormat:@"UPDATE conversation SET expire = %d WHERE account = '%@' AND user = '%@'", expireTime, me, user];
        result = [appDelegate._database executeUpdate: tSQL2];
    }else{
        NSString *tSQL2 = [NSString stringWithFormat:@"INSERT INTO conversation (account, user, room_id, background, expire, inear_mode) VALUES ('%@', '%@', '%@', '%@', %d, %d)", me, user, @"0", @"", expireTime, 0];
        result = [appDelegate._database executeUpdate: tSQL2];
    }
    return result;
}

/*--Get expire time cua một user--*/
+ (int)getExpireTimeForUser: (NSString *)user {
    NSString *me = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT expire FROM conversation WHERE account = '%@' AND user = '%@'", me, user];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    
    int result = 0;
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        result = [[rsDict objectForKey:@"expire"] intValue];
    }
    [rs close];
    return result;
}

/*--Get expire time cua một group--*/
+ (int)getExpireTimeForGroup: (int)groupID {
    NSString *me = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT expire FROM conversation WHERE account = '%@' AND room_id = %d", me, groupID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    
    int result = 0;
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        result = [[rsDict objectForKey:@"expire"] intValue];
    }
    [rs close];
    return result;
}

//  Get background của user
+ (NSString *)getChatBackgroundOfUser: (NSString *)user {
    NSString *result = @"";
    NSString *me = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT background FROM conversation WHERE account = '%@' AND user = '%@'", me, user];
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
    NSString *me = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM message WHERE send_phone = '%@' AND receive_phone = '%@' AND status = 'NO' LIMIT 0,1", user, me];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        result = YES;
    }
    [rs close];
    return result;
}

/*--Cập nhật trạng thái message khi send file thất bại--*/
+ (BOOL)updateMessageWhenSendFileFailed: (NSString *)idMessage{
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE message SET delivered_status = 0 WHERE id_message = '%@'", idMessage];
    BOOL result = [appDelegate._database executeUpdate: tSQL];
    return result;
}

// Cập nhật audio message sau khi nhận thành công
+ (BOOL)updateAudioMessageAfterReceivedSuccessfullly: (NSString *)idMessage{
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE message SET delivered_status=%d WHERE id_message='%@'", 2, idMessage];
    return [appDelegate._database executeUpdate: tSQL];
}

// Kiểm tra số cloudFoneID tồn tại trong db hay chưa
+ (BOOL)checkACloudFoneIDInPhoneBook: (NSString *)cloudfoneID {
    BOOL result = false;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM contact WHERE callnex_id = '%@' LIMIT 0,1", cloudfoneID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        result = true;
    }
    [rs close];
    return result;
}

#pragma mark - SYNC PHONEBOOK

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

//  Get IDs của contact cho sync phonebook
+ (NSString *)sync_pb_getIdsOfContactForSyncPhoneBook {
    NSString *resultStr = @"[";
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id_server FROM contact_phone_number WHERE id_server != -1"];
    FMResultSet *rs = [appDelegate._threadDatabase executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        int idServer = [[rsDict objectForKey:@"id_server"] intValue];
        if ([resultStr isEqualToString:@"["]) {
            resultStr = [NSString stringWithFormat:@"%@%d", resultStr, idServer];
        }else{
            resultStr = [NSString stringWithFormat:@"%@,%d", resultStr, idServer];
        }
    }
    [rs close];
    resultStr = [NSString stringWithFormat:@"%@%@", resultStr, @"]"];
    return resultStr;
}

//  Kiểm tra một tên có trong phone book hay chưa
+ (BOOL)sync_pb_checkAContactNameInPhoneBook: (NSString *)contactName {
    BOOL result = NO;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM contact WHERE (first_name = '%@' AND last_name = '') OR (last_name = '%@' AND first_name = '') OR (first_name || ' ' || last_name) = '%@' LIMIT 0,1", contactName, contactName, contactName];
    FMResultSet *rs = [appDelegate._threadDatabase executeQuery: tSQL];
    while ([rs next]) {
        result = YES;
    }
    [rs close];
    return result;
}

// Thêm mới contact khi sync phonebook
+ (void)sync_pb_addNewContact:(ContactObject *)aContact {
    NSString *tSQL = [NSString stringWithFormat:@"INSERT INTO contact (id_contact, first_name, last_name, convert_name, name_for_search, company, callnex_id, type, email, address, street, city, state, zip_postal, country, avatar, updated, sync_status) VALUES (%d,'%@','%@','%@','%@','%@','%@',%d,'%@','%@','%@','%@','%@','%@','%@','%@', %d, %d)", aContact._id_contact, aContact._firstName, aContact._lastName, aContact._convertName, aContact._nameForSearch, aContact._company, aContact._cloudFoneID, aContact._type, aContact._email, @"", aContact._street, aContact._city, aContact._state, aContact._zip_postal, aContact._country, aContact._avatar,1, 0];
    BOOL added = [appDelegate._threadDatabase executeUpdate: tSQL];
    if (added) {
        for (int iCount=0; iCount<aContact._listPhone.count; iCount++) {
            TypePhoneContact *aPhone = [aContact._listPhone objectAtIndex: iCount];
            NSString *tSQL = [NSString stringWithFormat:@"INSERT INTO contact_phone_number (id_contact, phone_number, type_phone, id_server, version) VALUES (%d,'%@','%@',%d,%d)", aContact._id_contact, aPhone._phoneNumber, aPhone._typePhone, aPhone._serverID, 0];
            [appDelegate._threadDatabase executeUpdate: tSQL];
        }
    }else{
        NSLog(@".....add that bai contact co id: %d", aContact._id_contact);
    }
}

// Lấy contact id theo tên khi sync phonebook
+ (int)sync_pb_getContactIDWithFullname: (NSString *)fullname {
    int idContact = -1;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM contact WHERE first_name = '%@' OR last_name = '%@' OR (first_name || ' ' || last_name) = '%@' LIMIT 0,1", fullname, fullname, fullname];
    FMResultSet *rs = [appDelegate._threadDatabase executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        idContact = [[rsDict objectForKey:@"id_contact"] intValue];
    }
    [rs close];
    return idContact;
}

// Cập nhật hoặc thêm mới số phone cho contact
+ (void)sync_pb_addNewOrUpdateIDServerPhoneForContact: (int)idContact listPhone: (NSArray *)listPhone {
    for (int iCount=0; iCount<listPhone.count; iCount++) {
        TypePhoneContact *aPhone = [listPhone objectAtIndex: iCount];
        BOOL exists = NO;
        NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM contact_phone_number WHERE id_contact=%d AND phone_number='%@' AND type_phone='%@'", idContact, aPhone._phoneNumber, aPhone._typePhone];
        FMResultSet *rs = [appDelegate._threadDatabase executeQuery: tSQL];
        //  Cập nhật idserver khi số phone đã tồn tại
        while ([rs next]) {
            NSString *updateSQL = [NSString stringWithFormat:@"UPDATE contact_phone_number SET id_server = %d WHERE id_contact=%d AND phone_number='%@' AND type_phone='%@'", aPhone._serverID, idContact, aPhone._phoneNumber, aPhone._typePhone];
            [appDelegate._threadDatabase executeUpdate: updateSQL];
            exists = YES;
        }
        //  Nếu số phone trên server chưa tồn tại dưới local thì add mới
        if (!exists) {
            NSString *addSQL = [NSString stringWithFormat:@"INSERT INTO contact_phone_number(id_contact, phone_number, type_phone, id_server, version) VALUES (%d, '%@', '%@', %d, %d)", idContact, aPhone._phoneNumber, aPhone._typePhone, aPhone._serverID, 0];
            [appDelegate._threadDatabase executeUpdate: addSQL];
        }
    }
}

// Get danh sách số phone chưa được sync
+ (NSString *)getListNewPhoneNumberForSyncContact {
    NSString *resultStr = @"";
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id_contact FROM contact_phone_number WHERE id_server = -1 GROUP BY id_contact"];
    FMResultSet *rs = [appDelegate._threadDatabase executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        int idContact = [[rsDict objectForKey:@"id_contact"] intValue];
        NSString *nameStr   = [self threadGetFullNameOfContactWithID: idContact];
        nameStr = [nameStr stringByReplacingOccurrencesOfString:@"&" withString:@"._."];
        NSString *phoneStr  = [NSDBCallnex getStringPhoneNumberForSyncOfContact: idContact];
        
        if ([resultStr isEqualToString:@""]) {
            resultStr = [NSString stringWithFormat:@"\"%@\":\"%@\"", nameStr, phoneStr];
        }else{
            resultStr = [NSString stringWithFormat:@"%@,\"%@\":\"%@\"", resultStr, nameStr, phoneStr];
        }
    }
    [rs close];
    return resultStr;
}

+ (NSMutableArray *)getListPhonesForSyncNewContact {
    NSMutableArray *tmpArr = [[NSMutableArray alloc] init];
    
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id_contact FROM contact_phone_number WHERE id_server = -1 GROUP BY id_contact"];
    FMResultSet *rs = [appDelegate._threadDatabase executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        int idContact = [[rsDict objectForKey:@"id_contact"] intValue];
        NSString *nameStr   = [self threadGetFullNameOfContactWithID: idContact];
        nameStr = [nameStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        nameStr = [nameStr stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        
        NSString *phoneStr  = [NSDBCallnex getStringPhoneNumberForSyncOfContact: idContact];
        
        NSString *object = [NSString stringWithFormat:@"\"%@\":\"%@\"", nameStr, phoneStr];
        [tmpArr addObject: object];
    }
    [rs close];
    
    NSString *resultStr = @"";
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    if (tmpArr.count <= 5) {
        for (int iCount=0; iCount<tmpArr.count; iCount++) {
            NSString *str = [tmpArr objectAtIndex:iCount];
            if ([resultStr isEqualToString:@""]) {
                resultStr = str;
            }else{
                resultStr = [NSString stringWithFormat:@"%@,%@", resultStr, str];
            }
        }
        [resultArr addObject: resultStr];
    }else{
        for (int iCount=0; iCount<tmpArr.count; iCount++) {
            NSString *str = [tmpArr objectAtIndex:iCount];
            if ([resultStr isEqualToString:@""]) {
                resultStr = str;
            }else{
                resultStr = [NSString stringWithFormat:@"%@,%@", resultStr, str];
            }
            if ((iCount+1)%5 == 0 || iCount == (tmpArr.count-1)) {
                [resultArr addObject:resultStr];
                resultStr = @"";
            }
        }
    }
    return resultArr;
}

//  Get fullname of contact with contact ID
+ (NSString *)threadGetFullNameOfContactWithID: (int)idContact {
    NSString *fullName = @"";
    NSString *tSQL = [NSString stringWithFormat:@"SELECT first_name, last_name FROM contact WHERE id_contact = %d", idContact];
    FMResultSet *rs = [appDelegate._threadDatabase executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *fName = [rsDict objectForKey:@"first_name"];
        NSString *lName = [rsDict objectForKey:@"last_name"];
        if ([fName isEqualToString:@""] && ![lName isEqualToString:@""]) {
            fullName = lName;
        }else if (![fName isEqualToString:@""] && [lName isEqualToString:@""]){
            fullName = fName;
        }else if (![fName isEqualToString:@""] && ![lName isEqualToString:@""]){
            fullName = [NSString stringWithFormat:@"%@ %@", fName, lName];
        }
    }
    [rs close];
    return fullName;
}

//  Lấy string phone có id_server = -1 của một contact
+ (NSString *)getStringPhoneNumberForSyncOfContact: (int)idContact {
    NSString *resultStr = @"";
    NSString *tSQL = [NSString stringWithFormat:@"SELECT type_phone, phone_number FROM contact_phone_number WHERE id_server = -1 AND id_contact = %d", idContact];
    FMResultSet *rs = [appDelegate._threadDatabase executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *phoneNumber = [rsDict objectForKey:@"phone_number"];
        NSString *typePhone = [rsDict objectForKey:@"type_phone"];
        NSString *phoneStr = @"";
        if ([typePhone isEqualToString: typePhoneMobile]) {
            phoneStr = [NSString stringWithFormat:@"m%@", phoneNumber];
        }else if ([typePhone isEqualToString: typePhoneWork]){
            phoneStr = [NSString stringWithFormat:@"w%@", phoneNumber];
        }else if ([typePhone isEqualToString: typePhoneFax]){
            phoneStr = [NSString stringWithFormat:@"f%@", phoneNumber];
        }else if ([typePhone isEqualToString: typePhoneCallnexID]){
            phoneStr = [NSString stringWithFormat:@"c%@", phoneNumber];
        }else{
            phoneStr = [NSString stringWithFormat:@"h%@", phoneNumber];
        }
        if (phoneStr.length > 16) {
            phoneStr = [phoneStr substringToIndex:16];
        }
        
        if ([resultStr isEqualToString:@""]) {
            resultStr = phoneStr;
        }else{
            resultStr = [NSString stringWithFormat:@"%@|%@", resultStr, phoneStr];
        }
    }
    [rs close];
    return resultStr;
}

// Get fullname của một contact khi sync phonebook
+ (NSString *)sync_pb_getFullNameOfContactWithID: (int)idContact {
    NSString *fullName = @"";
    NSString *tSQL = [NSString stringWithFormat:@"SELECT first_name, last_name FROM contact WHERE id_contact = %d", idContact];
    FMResultSet *rs = [appDelegate._threadDatabase executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *fName = [rsDict objectForKey:@"first_name"];
        NSString *lName = [rsDict objectForKey:@"last_name"];
        if ([fName isEqualToString:@""] && ![lName isEqualToString:@""]) {
            fullName = lName;
        }else if (![fName isEqualToString:@""] && [lName isEqualToString:@""]){
            fullName = fName;
        }else if (![fName isEqualToString:@""] && ![lName isEqualToString:@""]){
            fullName = [NSString stringWithFormat:@"%@ %@", fName, lName];
        }
    }
    [rs close];
    return fullName;
}

//  Update id server cho contact name va phone
+ (BOOL)updateIDServerForNewContactAfterSync: (int)idServer name: (NSString *)name phone: (NSString *)phone{
    BOOL result = NO;
    int idContact = [NSDBCallnex sync_pb_getContactIDWithFullname: name];
    if (idContact != -1) {
        NSString *tSQL = [NSString stringWithFormat:@"UPDATE contact_phone_number SET id_server = %d WHERE phone_number = '%@' AND id_contact = %d", idServer, phone, idContact];
        result = [appDelegate._threadDatabase executeUpdate: tSQL];
    }
    return result;
}

/*--Get tat ca message chua doc khi chay backgound--*/
+ (int)getAllNumberMessageUnreadForBackground
{
    int result = 0;
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT COUNT(*) as num_unread FROM message WHERE (send_phone='%@' OR receive_phone='%@') AND status = '%@'", account, account, @"NO"];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        result = [[rsDict objectForKey:@"num_unread"] intValue];
    }
    [rs close];
    return result;
}

/*--Get danh sach message sau 1 message--*/
+ (NSMutableArray *)getListMessageAfterAMessage: (NSString *)idMessage ofUser: (NSString *)user
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSString *meStr = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id FROM message WHERE id_message='%@'", idMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        int idOrder = [[rsDict objectForKey:@"id"] intValue];
        NSString *tSQL2 = [NSString stringWithFormat:@"SELECT id_message FROM message WHERE id > %d AND ((send_phone = '%@' AND receive_phone = '%@') OR (send_phone = '%@' AND receive_phone = '%@'))", idOrder, meStr, user, user, meStr];
        FMResultSet *rs2 = [appDelegate._database executeQuery: tSQL2];
        while ([rs2 next]) {
            NSDictionary *rsDict2 = [rs2 resultDictionary];
            NSString *idMessage = [rsDict2 objectForKey:@"id_message"];
            NSBubbleData *aMessage = [self getDataOfMessage: idMessage];
            [result addObject: aMessage];
        }
        [rs2 close];
    }
    [rs close];
    return result;
}

// Lấy số phone cuối cùng gọi đi
+ (NSString *)getLastCallOfUser {
    NSString *phone = @"";
    NSString *mySip = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT phone_number FROM history WHERE my_sip = '%@' AND call_direction = '%@' ORDER BY _id DESC LIMIT 0,1", mySip, outgoing_call];
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

// Kiểm tra user có trong list request hay không
+ (BOOL)checkRequestOfUser: (NSString *)userStr {
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    BOOL result = false;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM request_sent WHERE account = '%@' AND user = '%@' LIMIT 0,1", account, userStr];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    if ([rs next]) {
        result = true;
    }
    [rs close];
    return result;
}

// Xoá user ra khỏi bảng request
+ (BOOL)removeUserFromRequestSent: (NSString *)userStr{
    NSString *me = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    if (userStr != nil && ![userStr isEqualToString:@""]) {
        NSString *user = [MyFunctions getCloudFoneIDFromString:userStr];
        
        NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM request_sent WHERE account = '%@' AND user = '%@'", me, user];
        BOOL result = [appDelegate._database executeUpdate: tSQL];
        return result;
    }
    return NO;
}

// Kiểm tra user có trong danh sách request hay chưa
+ (BOOL)checkUserExistsInRequestList: (NSString *)user
{
    BOOL result = FALSE;
    NSString *me = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM request_sent WHERE account = '%@' AND user = '%@' LIMIT 0,1", me, user];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        result = TRUE;
    }
    [rs close];
    return result;
}

// Thêm user đang chờ request vào bảng
+ (BOOL)addUserToRequestSent: (NSString *)user withIdRequest: (NSString *)idRequeset {
    BOOL result = false;
    [appDelegate._database beginTransaction];
    NSString *me = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *delSQL = [NSString stringWithFormat:@"DELETE FROM request_sent WHERE account = '%@' AND user = '%@'", me, user];
    result = [appDelegate._database executeUpdate: delSQL];
    if (result) {
        NSString *newSQL = [NSString stringWithFormat:@"INSERT INTO request_sent(account, user, id_request) VALUES ('%@', '%@', '%@')", me, user, idRequeset];
        result = [appDelegate._database executeUpdate: newSQL];
        if (!result) {
            [appDelegate._database rollback];
        }
    }
    [appDelegate._database commit];
    return result;
}

// Get xmpp của user ứng với id_request
+ (NSString *)getStringOfUserWithRequestID: (NSString *)requestID
{
    NSString *result = @"";
    NSString *tSQL = [NSString stringWithFormat:@"SELECT user FROM request_sent WHERE id_request = '%@' LIMIT 0,1", requestID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *user = [rsDict objectForKey:@"user"];
        result = [NSString stringWithFormat:@"%@@%@", user, xmpp_cloudfone];
    }
    [rs close];
    return result;
}

/*--Get missed call--*/
+ (int)getNumberMissedCallInHistoryOfUser: (NSString *)user
{
    int numberMissedCall = 0;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT count(*) AS missedCall FROM history WHERE my_sip = '%@' AND unread = %d", user, 1];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        numberMissedCall = [[rsDict objectForKey:@"missedCall"] intValue];
    }
    [rs close];
    return numberMissedCall;
}

/*--Cap nhat tat cac trang thai cua missed call--*/
+ (BOOL)resetAllMissedCallOfUser: (NSString *)user
{
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE history SET unread = %d WHERE my_sip = '%@' AND unread = %d", 0, user, 1];
    return [appDelegate._database executeUpdate: tSQL];
}

// Cap nhat serverID cua so phone cua mot user
+ (BOOL)updateIDServerOfPhone: (NSString *)phone ofUserID: (int)userID withServerID: (long)idServer
{
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE contact_phone_number SET id_server = %ld WHERE id_contact = %d AND phone_number = '%@'", idServer, userID, phone];
    BOOL result = [appDelegate._database executeUpdate: tSQL];
    return result;
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

// Get thong tin cua contact voi id message
+ (NSArray *)getContactInfoOfMessage: (NSString *)idMessage
{
    NSString *content = @"";
    NSString *description = @"";
    NSString *tSQL = [NSString stringWithFormat:@"SELECT content, description FROM message WHERE id_message = '%@' LIMIT 0,1", idMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        content = [rsDict objectForKey:@"content"];
        description = [rsDict objectForKey:@"description"];
    }
    [rs close];
    return [NSArray arrayWithObjects:content,description, nil];
}

// Them moi contact tu bubble chat
+ (BOOL)addNewContactFromBubbleChat: (NSMutableDictionary *)contactInfoDict
{
    int idContact = [[contactInfoDict objectForKey:@"idContact"] intValue];
    NSString *firstName = [contactInfoDict valueForKey: [localization localizedStringForKey:text_first_name]];
    if (firstName == nil) {
        firstName = text_empty;
    }
    
    NSString *lastName = [contactInfoDict valueForKey: [localization localizedStringForKey:text_last_name]];
    if (lastName == nil) {
        lastName = text_empty;
    }
    
    NSString *company = [contactInfoDict valueForKey: [localization localizedStringForKey:text_company]];
    if (company == nil) {
        company = text_empty;
    }
    
    // Cập nhật lại convert_name và name_for_search cho contact
    NSString *fullName = text_empty;
    
    if ([firstName isEqualToString: text_empty] && [lastName isEqualToString: text_empty]) {
        fullName = [localization localizedStringForKey:text_unknown];
    }else if(![firstName isEqualToString: text_empty] && [lastName isEqualToString: text_empty]){
        fullName = firstName;
    }else if ([firstName isEqualToString: text_empty] && ![lastName isEqualToString: text_empty]){
        fullName = lastName;
    }else{
        fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    }
    
    NSString *convertName = [MyFunctions convertUTF8CharacterToCharacter: fullName];
    NSString *nameForSearch = [MyFunctions getNameForSearchOfConvertName: convertName];
    NSString *callnexID = [contactInfoDict valueForKey: [localization localizedStringForKey:text_cloundfoneid]];
    if (callnexID == nil) {
        callnexID = text_empty;
    }
    
    int typeContact = 0;
    if ([contactInfoDict objectForKey: [localization localizedStringForKey:text_type]] != nil) {
        typeContact = [[contactInfoDict valueForKey:[localization localizedStringForKey:text_type]] intValue];
    }
    
    NSString *email = [contactInfoDict valueForKey:[localization localizedStringForKey:text_email]];
    if (email == nil) {
        email = text_empty;
    }
    NSString *avatar = [contactInfoDict valueForKey:@"imgAvatar"];
    if (avatar == nil) {
        avatar = text_empty;
    }
    
    NSString *tSQL = [NSString stringWithFormat:@"INSERT INTO contact (id_contact, first_name, last_name, convert_name, name_for_search, company, callnex_id, type, email, address, street, city, state, zip_postal, country, avatar, updated, sync_status) VALUES (%d, '%@','%@','%@','%@','%@','%@',%d,'%@','%@','%@','%@','%@','%@','%@','%@', %d, %d)", idContact, firstName, lastName, convertName, nameForSearch, company, callnexID, typeContact, email, text_empty, text_empty, text_empty, text_empty, text_empty, text_empty, text_empty, 1, 0];
    BOOL added = [appDelegate._database executeUpdate: tSQL];
    return added;
}

// Thêm mới hoặc cập nhật một country
+ (void)addNewOrUpdateCountryOnList: (NSString *)countryName andCode: (NSString *)countryCode {
    BOOL isExists = NO;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM country WHERE code = '%@' LIMIT 0,1", countryCode];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        isExists = YES;
    }
    [rs close];
    
    if (!isExists) {
        NSString *tSQL2 = [NSString stringWithFormat:@"INSERT INTO country(name, code) VALUES('%@', '%@')", countryName, countryCode];
        [appDelegate._database executeUpdate: tSQL2];
    }else{
        NSString *tSQL2 = [NSString stringWithFormat:@"UPDATE country SET name = '%@' WHERE code = '%@'", countryName, countryCode];
        [appDelegate._database executeUpdate: tSQL2];
    }
}

// Xoá list accessNumber của một country
+ (BOOL)deleteAllAccessNumberOfCountry: (NSString *)countryCode{
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM locals WHERE country = '%@'", countryCode];
    return [appDelegate._database executeUpdate: tSQL];
}

// Thêm mới một access number của state cho country
+ (void)addNewAccessNumber: (NSString *)accessNum ofState: (NSString *)stateName forCountry: (NSString *)countryCode {
    NSString *tSQL = [NSString stringWithFormat:@"INSERT INTO locals(number, name, country) VALUES('%@', '%@', '%@')", accessNum, stateName, countryCode];
    [appDelegate._database executeUpdate: tSQL];
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

// check trang thai relogin
+ (BOOL)checkReloginStateForUser{
    BOOL result = YES;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT relogin FROM last_logout LIMIT 0,1"];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        int relogin = [[rsDict objectForKey:@"relogin"] intValue];
        if (relogin == 1) {
            result = YES;
        }else{
            result = NO;
        }
    }
    [rs close];
    return result;
}

// Get thong tin register cho user
+ (NSArray *)getBackupInfoReloginForUser {
    NSString *account = @"";
    NSString *password = @"";
    
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM last_logout LIMIT 0,1"];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        account = [rsDict objectForKey:@"account"];
        password = [rsDict objectForKey:@"password"];
    }
    [rs close];
    return [NSArray arrayWithObjects:account, password, nil];
}

// Cập nhật id mới cho message transfer file
+ (BOOL)updateMessageIdOfMessageWithNewMessage: (NSString *)newMessageID andOldMessageID: (NSString *)oldMessageID
{
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE message SET id_message = '%@' WHERE id_message = '%@'", newMessageID, oldMessageID];
    return [appDelegate._database executeUpdate: tSQL];
}

// Cập nhật message recall
+ (BOOL)updateMessageForRecall: (NSString *)idMessage
{   // Xoá details của message nếu là message media
    [self removeDetailsMessageForRecallWithIdMessage: idMessage];
    
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE message SET content = 'Message recalled successfully', is_recall='YES', delivered_status = 0, type_message = '%@' WHERE id_message = '%@' AND send_phone='%@'", textMessage, idMessage, [[NSUserDefaults standardUserDefaults] objectForKey:key_login]];
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
            [MyFunctions deleteDetailsFileOfMessage:typeMessage andDetails:details_url andThumb:thumb_url];
        }
    }
    [rs close];
}

#pragma mark - Failed message
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
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"INSERT INTO fail_message(account, id_message) VALUES('%@', '%@')", account, idMessage];
    return [appDelegate._database executeUpdate: tSQL];
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
            OTRBuddy *userBuddy = [MyFunctions getBuddyOfUserOnList: [msgInfo objectAtIndex: 0]];
            if (userBuddy.encryptionStatus == kOTRKitMessageStateEncrypted) {
                secure = true;
            }
            [userBuddy sendMessage: [msgInfo objectAtIndex: 1] secure:secure withIdMessage:idMsg];
        }
    }
    [rs close];
}

// Kiểm tra số phone có tồn tại trong contact hay chưa?
+ (BOOL)checkAPhoneNumber: (NSString *)phoneNumer isExistsOnContact: (int)idContact {
    if (phoneNumer.length > 2) {
        BOOL result = FALSE;
        NSString *convertPhone = @"";
        NSString *prefix = [phoneNumer substringToIndex: 2];
        if ([prefix isEqualToString:@"84"]) {
            convertPhone = [NSString stringWithFormat:@"0%@", [phoneNumer substringFromIndex: 2]];
        }
        
        NSString *tSQL =  @"";
        if (![convertPhone isEqualToString:@""]) {
            tSQL = [NSString stringWithFormat:@"SELECT id_contact FROM contact_phone_number WHERE id_contact = %d AND (phone_number = '%@' OR phone_number = '%@') LIMIT 0,1", idContact, phoneNumer, convertPhone];
        }else{
            tSQL = [NSString stringWithFormat:@"SELECT id_contact FROM contact_phone_number WHERE id_contact = %d AND phone_number = '%@' LIMIT 0,1", idContact, phoneNumer];
        }
        FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
        while ([rs next]) {
            result = TRUE;
        }
        [rs close];
        return result;
    }
    return TRUE;
}

// Get danh sách tất cả các callnex list
+ (NSMutableArray *)getListUserCallnex {
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    NSString *tSQL = @"SELECT callnex_id FROM contact WHERE callnex_id != '' AND id_contact != 0";
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *callnexStr = [rsDict objectForKey:@"callnex_id"];
        [resultArr addObject: callnexStr];
    }
    [rs close];
    return resultArr;
}

+ (void)updateAvatarForUserWithThread: (NSString *)callnexID withAvatarData: (NSData *)imgData {
    NSString *avatarStr = [imgData base64EncodedStringWithOptions:0];
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE contact SET avatar = '%@' WHERE callnex_id = '%@'", avatarStr, callnexID];
    BOOL rs = [appDelegate._addContactDB executeUpdate: tSQL];
    if (rs) {
        NSLog(@"Cap nhat avatar thanh cong....");
    }
}

// Kiểm tra user upload thành công hay thất bại
+ (BOOL)checkUploadAvatarFailed: (NSString *)account {
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM callnex_settings WHERE account = '%@' LIMIT 0,1", account];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    BOOL result = FALSE;
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *extra = [rsDict objectForKey:@"extra"];
        if (extra != nil && [extra class] != [NSNull class]) {
            if ([extra isEqualToString:@"avatar"]) {
                result = TRUE;
            }
        }
    }
    [rs close];
    return result;
}

+ (void)updateProfileFailedToServer: (NSString *)account {
    BOOL isExists = FALSE;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM callnex_settings WHERE account=''%@", account];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        isExists = TRUE;
        NSString *updateSQL = [NSString stringWithFormat:@"UPDATE callnex_settings SET extra = 'avatar' WHERE account='%@'", account];
        BOOL result = [appDelegate._database executeUpdate: updateSQL];
        if (!result) {
            NSLog(@"Can not update for upload avatar failed...");
        }
    }
    [rs close];
    
    if (!isExists) {
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO callnex_settings(account, whitelist, nat, dnd, auto_answer, extra) VALUES ('%@', %d, %d, %d, %d, '%@')", account, 0, 0, 0, 0, @"avatar"];
        BOOL result = [appDelegate._database executeUpdate: insertSQL];
        if (!result) {
            NSLog(@"Can not insert for upload avatar failed...");
        }
    }
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

#pragma mark - Friends list for accept

+ (BOOL)checkRequestFriendExistsOnList: (NSString *)cloudfoneID {
    BOOL result = false;
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM list_for_accept WHERE account = '%@' AND user = '%@' LIMIT 0,1", account, cloudfoneID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        result = true;
    }
    [rs close];
    return result;
}

+ (BOOL)addUserToWaitAcceptList: (NSString *)cloudfoneID {
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"INSERT INTO list_for_accept (account, user) VALUES ('%@', '%@')", account, cloudfoneID];
    return [appDelegate._database executeUpdate: tSQL];
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

//  Xoá tất cả các user trong request list hiện tại
+ (void)removeAllUserFromRequestList {
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM list_for_accept WHERE account = '%@'", account];
    [appDelegate._database executeUpdate: tSQL];
}

+ (BOOL)removeAnUserFromRequestedList: (NSString *)user {
    NSString *meStr = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM list_for_accept WHERE account = '%@' AND user = '%@'", meStr, user];
    return [appDelegate._database executeUpdate: tSQL];
}

+ (int)getCountOfRequestedOnList {
    int result = 0;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT COUNT(*) as numCount FROM list_for_accept WHERE account = '%@'", [[NSUserDefaults standardUserDefaults] objectForKey:key_login]];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        result = [[rsDict objectForKey:@"numCount"] intValue];
    }
    [rs close];
    return result;
}

+ (void)removeIDServer {
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE contact_phone_number SET id_server = -1"];
    [appDelegate._database executeUpdate: tSQL];
}

// Xoá tất cả các contact cho re add
+ (BOOL)removeAllContactForReAdd {
    BOOL result = NO;
    [appDelegate._database beginTransaction];
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM contact_phone_number"];
    result = [appDelegate._database executeUpdate: tSQL];
    if (result) {
        NSString *tSQL2 = [NSString stringWithFormat:@"DELETE FROM contact"];
        result = [appDelegate._database executeUpdate: tSQL2];
    }
    if (!result) {
        [appDelegate._database rollback];
    }
    [appDelegate._database commit];
    return result;
}

#pragma mark - Contacts

// Lấy avatar của một contact theo callnexID
+ (NSString *)getAvatarDataStringOfCallnexID: (NSString *)callnexID {
    NSString *resultStr = text_empty;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT avatar FROM contact WHERE callnex_id = '%@' ORDER BY id_contact DESC LIMIT 0,1", callnexID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        resultStr = [rsDict objectForKey:@"avatar"];
    }
    [rs close];
    return resultStr;
}

+ (NSMutableArray *)getListRequestSent: (NSString *)callnexID {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSString *tSQL = [NSString stringWithFormat: @"SELECT user FROM request_sent WHERE account = %@", callnexID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *user = [rsDict objectForKey:@"user"];
        [result addObject: user];
    }
    [rs close];
    return result;
}

+ (BOOL)checkPendingOfMeWithUser: (NSString *)user {
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM request_sent WHERE account = %@ AND user = %@ LIMIT 0,1", account, user];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    BOOL result = NO;
    while ([rs next]) {
        result = YES;
    }
    [rs close];
    return result;
}

#pragma mark - other functions

+ (NSString *)getLastLoginUsername {
    NSString *username = @"";
    NSString *tSQL = @"SELECT account FROM last_logout ORDER BY id DESC LIMIT 0,1";
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        username = [rsDict objectForKey: @"account"];
    }
    [rs close];
    return username;
}

//  Kiểm tra trùng tên và contact trong phonebook
+ (NSArray *)checkContactExistsInPhoneBook: (NSString *)contactName andCloudFone: (NSString *)cloudFoneID {
    NSString *firstName = text_empty;
    NSString *lastName = text_empty;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT first_name, last_name FROM contact WHERE ((LOWER(first_name) = '%@' AND last_name = '') OR (LOWER(last_name) = '%@' AND first_name = '') OR (LOWER(first_name) || ' ' || LOWER(last_name)) = '%@') AND callnex_id = '%@' LIMIT 0,1", contactName, contactName, contactName, cloudFoneID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        firstName   = [rsDict objectForKey:@"first_name"];
        lastName    = [rsDict objectForKey:@"last_name"];
    }
    [rs close];
    if ([firstName isEqualToString: text_empty] && [lastName isEqualToString: text_empty]) {
        return nil;
    }else{
        return [[NSArray alloc] initWithObjects:firstName, lastName, nil];
    }
}

//  Kiểm tra trùng tên và contact trong phonebook
+ (NSString *)checkContactExistsInDatabase: (NSString *)contactName andCloudFone: (NSString *)cloudFoneID {
    NSString *result = text_empty;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id_contact FROM contact WHERE ((LOWER(first_name) = '%@' AND last_name = '') OR (LOWER(last_name) = '%@' AND first_name = '') OR (LOWER(first_name) || ' ' || LOWER(last_name)) = '%@') AND callnex_id = '%@' LIMIT 0,1", contactName, contactName, contactName, cloudFoneID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        result = [NSString stringWithFormat:@"%d", [[rsDict objectForKey:@"id_contact"] intValue]];
    }
    [rs close];
    return result;
}

#pragma mark - My Functions

//  Hàm lấy danh sách tất cả contact
+ (NSMutableArray *)getAllContactInCallnexDB {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSString *tSQL = @"SELECT * FROM contact WHERE id_contact != 0";
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        ContactObject *aContact = [[ContactObject alloc] init];
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *callnexID = [rsDict objectForKey:@"callnex_id"];
        
        aContact._id_contact = [[rsDict objectForKey:@"id_contact"] intValue];
        aContact._avatar = [rsDict objectForKey:@"avatar"];
        aContact._firstName = [rsDict objectForKey:@"first_name"];
        aContact._lastName = [rsDict objectForKey:@"last_name"];
        if ([aContact._firstName isEqualToString:@""] && [aContact._lastName isEqualToString:@""]) {
            aContact._fullName = [localization localizedStringForKey:text_unknown];
        }else if(![aContact._firstName isEqualToString:@""] && [aContact._lastName isEqualToString:@""]){
            aContact._fullName = aContact._firstName;
        }else if ([aContact._firstName isEqualToString:@""] && ![aContact._lastName isEqualToString:@""]){
            aContact._fullName = aContact._lastName;
        }else{
            aContact._fullName = [NSString stringWithFormat:@"%@ %@", [rsDict objectForKey:@"first_name"], [rsDict objectForKey:@"last_name"]];
        }
        
        // Kiem tra callnexID
        if (callnexID.length > 6) {
            NSString *prefix = [callnexID substringToIndex: 6];
            if ([prefix isEqualToString: @"778899"]) {
                [aContact set_cloudFoneID: callnexID];
            }else{
                [aContact set_cloudFoneID: @""];
            }
        }else{
            [aContact set_cloudFoneID: @""];
        }
        [result addObject: aContact];
    }
    [rs close];
    return result;
}

//  Get tất cả các contact theo search string
+ (NSMutableArray *)getAllContactInCallnexDBWithSearch: (NSString *)search
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSString *tSQL;
    if ([search isEqualToString: text_empty]) {
        tSQL = [NSString stringWithFormat:@"SELECT * FROM contact WHERE id_contact != 0"];
    }else{
        tSQL = [NSString stringWithFormat:@"SELECT * FROM contact WHERE (first_name LIKE '%@%%' OR first_name LIKE '%%%@' OR first_name LIKE '%%%@%%') OR (last_name LIKE '%@%%' OR last_name LIKE '%%%@' OR last_name LIKE '%%%@%%') OR (first_name || ' ' || last_name) LIKE '%@%%' OR (first_name || ' ' || last_name) LIKE '%%%@' OR (first_name || ' ' || last_name) LIKE '%%%@%%'", search, search, search, search, search, search, search, search, search];
    }
    
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        ContactObject *aContact = [[ContactObject alloc] init];
        NSDictionary *rsDict = [rs resultDictionary];
        aContact._id_contact = [[rsDict objectForKey:@"id_contact"] intValue];
        aContact._avatar = [rsDict objectForKey:@"avatar"];
        aContact._firstName = [rsDict objectForKey:@"first_name"];
        aContact._lastName = [rsDict objectForKey:@"last_name"];
        if (![aContact._firstName isEqualToString:text_empty] && [aContact._lastName isEqualToString:text_empty]) {
            aContact._fullName = aContact._firstName;
        }else if ([aContact._firstName isEqualToString:text_empty] && ![aContact._lastName isEqualToString:text_empty]){
            aContact._fullName = aContact._lastName;
        }else if (![aContact._firstName isEqualToString:text_empty] && ![aContact._lastName isEqualToString:text_empty]){
            aContact._fullName = [NSString stringWithFormat:@"%@ %@", aContact._firstName, aContact._lastName];
        }
        
        aContact._cloudFoneID = [rsDict objectForKey:@"callnex_id"];
        [result addObject: aContact];
    }
    [rs close];
    return result;
}

//  Hàm get tất cả các id contact ko nằm trong blacklist để đưa vào whitelist
+ (BOOL)addAllContactsToWhiteList {
    [appDelegate._database beginTransaction];

    BOOL result = false;
    [appDelegate._database beginTransaction];
    
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM group_members WHERE id_group = 1"];
    result = [appDelegate._database executeUpdate: tSQL];
    if (!result) {
        [appDelegate._database rollback];
    }else {
        NSString *tSQL2 = @"SELECT DISTINCT id_contact, callnex_id FROM contact WHERE callnex_id != '' AND id_contact NOT IN (SELECT DISTINCT id_member FROM group_members WHERE id_group= 0)";
        FMResultSet *rs = [appDelegate._database executeQuery: tSQL2];
        while ([rs next]) {
            NSDictionary *rsDict = [rs resultDictionary];
            int idContact = [[rsDict objectForKey:@"id_contact"] intValue];
            NSString *callnexID = [rsDict objectForKey:@"callnex_id"];
            
            NSString *newSQL = [NSString stringWithFormat:@"INSERT INTO group_members(id_group, id_member, callnex_id) VALUES (%d, %d, '%@')", 1, idContact, callnexID];
            result = [appDelegate._database executeUpdate: newSQL];
            if (!result) {
                [appDelegate._database rollback];
                break;
            }
        }
        [rs close];
    }
    [appDelegate._database commit];
    return result;
}

//  Lấy danh sách các số callnex chưa có trong group hiện tại
+ (NSMutableArray *)getCallnexUserNotExistsInGroup: (int)groupId {
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id_contact, avatar, first_name, last_name, callnex_id FROM contact WHERE callnex_id != '%@' AND callnex_id != ''  AND id_contact != 0 AND id_contact NOT IN (SELECT DISTINCT id_member FROM group_members WHERE id_group = %d AND account = '%@')", account, groupId, [[NSUserDefaults standardUserDefaults] objectForKey:key_login]];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        ContactObject *aContact = [[ContactObject alloc] init];
        
        NSDictionary *rsDict = [rs resultDictionary];
        aContact._id_contact = [[rsDict objectForKey:@"id_contact"] intValue];
        aContact._avatar = [rsDict objectForKey:@"avatar"];
        aContact._firstName = [rsDict objectForKey:@"first_name"];
        aContact._lastName = [rsDict objectForKey:@"last_name"];
        
        if ([aContact._firstName isEqualToString:@""] && [aContact._lastName isEqualToString:@""]) {
            aContact._fullName = [localization localizedStringForKey:text_unknown];
        }else if (![aContact._firstName isEqualToString:@""] && [aContact._lastName isEqualToString:@""]){
            aContact._fullName = aContact._firstName;
        }else if ([aContact._firstName isEqualToString:@""] && ![aContact._lastName isEqualToString:@""]){
            aContact._fullName = aContact._lastName;
        }else{
            aContact._fullName = [NSString stringWithFormat:@"%@ %@", aContact._firstName, aContact._lastName];
        }
        aContact._cloudFoneID = [rsDict objectForKey:@"callnex_id"];
        [resultArr addObject: aContact];
    }
    [rs close];
    return resultArr;
}

//  Thêm các thành viên đã chọn vào group
+ (BOOL)addAllMemberIntoGroupWith: (int)idGroup andListMember: (NSArray *)listMember{
    BOOL result = false;
    [appDelegate._database beginTransaction];
    
    for (int iCount=0; iCount<listMember.count; iCount++) {
        int idMember = [[listMember objectAtIndex: iCount] intValue];
        NSString *tSQL = [NSString stringWithFormat:@"SELECT callnex_id FROM contact WHERE id_contact = %d", idMember];
        FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
        
        NSString *cloudFoneID = text_empty;
        while ([rs next]) {
            NSDictionary *rsDict = [rs resultDictionary];
            cloudFoneID = [rsDict objectForKey:@"callnex_id"];
        }
        [rs close];
        
        NSString *tSQL2 = [NSString stringWithFormat:@"INSERT INTO group_members(id_group, id_member, callnex_id, account) VALUES (%d, %d,'%@', '%@')", idGroup, idMember, cloudFoneID, [[NSUserDefaults standardUserDefaults] objectForKey:key_login]];
        result = [appDelegate._database executeUpdate: tSQL2];
        
        if (!result) {
            [appDelegate._database rollback];
            break;
        }
    }
    [appDelegate._database commit];
    return result;
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
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM history WHERE my_sip = '%@' AND call_direction = 'Incomming' AND status = 'Missed' AND date = '%@' ORDER BY _id DESC", mySip, dateStr];
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
        
        NSArray *infos = [self getContactNameOfCloudFoneID: phoneNumber];
        
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

//  Hàm xoá 1 record call history trong lịch sử cuộc gọi
+ (BOOL)deleteRecordCallHistory: (int)idCallRecord withRecordFile: (NSString *)recordFile {
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM history WHERE _id = %d", idCallRecord];
    if (![recordFile isEqualToString: text_empty] && ![recordFile isEqualToString:@"0"]) {
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

//  Get tên file ghi âm của cuộc gọi nếu có
+ (NSString *)getRecordFileNameOfCall: (int)idCall {
    NSString *recordFile = text_empty;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT record_files FROM history WHERE _id = %d", idCall];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        recordFile = [rsDict objectForKey:@"record_files"];
    }
    [rs close];
    return recordFile;
}

//  Xoá lịch sử các cuộc gọi nhỡ của user
+ (BOOL)deleteAllMissedCallOfUser: (NSString *)user {
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM history WHERE my_sip = '%@' AND call_direction = 'Incomming' AND status = 'Missed'", user];
    return [appDelegate._database executeUpdate:tSQL];
}

//  Hàm xoá tất cả history call
+ (BOOL)deleteAllHistoryCallOfUser: (NSString *)mySip{
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM history WHERE my_sip = '%@'", mySip];
    BOOL result = [appDelegate._database executeUpdate: tSQL];
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
        NSString *strAvatar = text_empty;
        NSData *avatarData = [self getAvatarDataFromCacheFolderForUser: user];
        if (avatarData != nil) {
            strAvatar = [avatarData base64EncodedStringWithOptions: 0];
        }
        FriendRequestedObject *aRequest = [[FriendRequestedObject alloc] init];
        [aRequest set_cloudfoneID: user];
        [aRequest set_avatar: strAvatar];
        NSString *fullName = [self getFullnameOfContactWithCloudFoneID: user];
        [aRequest set_name: fullName];
        
        [result addObject: aRequest];
    }
    [rs close];
    return result;
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
        NSString *curDate = [MyFunctions getCurrentDate];
        NSString *curTime = [MyFunctions getCurrentTimeStamp];
        if ([subject isEqualToString:text_empty]) {
            subject = welcomeToCloudFone;
        }
        
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO room_chat(room_name, group_name, date, time, status, user, subject) VALUES ('%@', '%@', '%@', '%@', %d, '%@', '%@')", roomName, groupName, curDate, curTime, 1, [[NSUserDefaults standardUserDefaults] objectForKey:key_login], subject];
        result = [appDelegate._database executeUpdate: insertSQL];
    }
    return result;
}

//  Get cloudFoneID của contact trong database theo contactID
+ (NSString *)getCallnexIDOfContact: (int)idContact{
    NSString *resultStr = text_empty;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT callnex_id FROM contact WHERE id_contact = '%d'", idContact];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        resultStr = [rsDict objectForKey:@"callnex_id"];
    }
    [rs close];
    return resultStr;
}

//  Get lịch sử message của room chat
+ (NSMutableArray *)getListMessagesOfAccount: (NSString *)account withRoomID: (int)roomID {
    NSMutableArray *listContentMessage = [[NSMutableArray alloc] init];
    
    NSString *myID = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    
    //  NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM message WHERE room_id = %d AND (send_phone = '%@' OR receive_phone = '%@') AND type_message != '%@'", roomID, account, account, descriptionMessage];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM message WHERE room_id = %d AND (send_phone = '%@' OR receive_phone = '%@')", roomID, account, account];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *sendPhone = [rsDict objectForKey:@"send_phone"];
        int timeInterval   = [[rsDict objectForKey:@"time"] intValue];
        NSString *content   = [rsDict objectForKey:@"content"];
        int statusMsg   = [[rsDict objectForKey:@"delivered_status"] intValue];
        NSString *idMsgStr = [rsDict objectForKey:@"id_message"];
        NSString *isRecall = [rsDict objectForKey:@"is_recall"];
        NSString *typeMessage = [rsDict objectForKey:@"type_message"];
        int expTime = [[rsDict objectForKey:@"expire_time"] intValue];
        //  NSString *detailsUrl = [rsDict objectForKey:@"details_url"];
        NSString *thumbUrl = [rsDict objectForKey:@"thumb_url"];
        NSString *description = [rsDict objectForKey:@"description"];
        
        
        NSString *fullTime = @"";
        NSString *msgDate = [MyFunctions stringDateFromInterval: timeInterval];
        NSString *msgTime = [MyFunctions stringTimeFromInterval: timeInterval];
        if ([msgDate isEqualToString: [MyFunctions getCurrentDate]]) {
            fullTime = msgTime;
        }else{
            fullTime = [NSString stringWithFormat:@"%@ %@", msgDate, msgTime];
        }
        
        if ([typeMessage isEqualToString: textMessage]) {
            NSBubbleData *messageData  = [[NSBubbleData alloc] init];
            // Get thời gian expire của msg nếu có
            if ([myID isEqualToString: sendPhone]) {
                messageData = [NSBubbleData dataWithText:content type:BubbleTypeMine time:fullTime status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:text_empty withTypeMessage:typeMessage isGroup:true ofUser:text_empty];
                [messageData set_callnexID: text_empty];
            }else{
                NSString *userName = [self getFullnameOfContactForGroupWithCallnexID: sendPhone];
                messageData = [NSBubbleData dataWithText:content type:BubbleTypeSomeoneElse time:fullTime status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:text_empty withTypeMessage:typeMessage isGroup:true ofUser:userName];
                [messageData set_callnexID: sendPhone];
            }
            appDelegate._heightChatTbView = appDelegate._heightChatTbView + messageData.view.frame.size.height+8;
            
            [listContentMessage addObject: messageData];
        }else if ([typeMessage isEqualToString: descriptionMessage]){
            NSBubbleData *messageData  = [[NSBubbleData alloc] init];
            // Get thời gian expire của msg nếu có
            if ([myID isEqualToString: sendPhone]) {
                messageData = [NSBubbleData dataWithText:content type:BubbleTypeMine time:fullTime status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:text_empty withTypeMessage:typeMessage isGroup:true ofUser:text_empty];
                [messageData set_callnexID: text_empty];
            }else{
                messageData = [NSBubbleData dataWithText:content type:BubbleTypeSomeoneElse time:fullTime status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:text_empty withTypeMessage:typeMessage isGroup:true ofUser:text_empty];
                [messageData set_callnexID: sendPhone];
            }
            appDelegate._heightChatTbView = appDelegate._heightChatTbView + messageData.view.frame.size.height+8;
            
            [listContentMessage addObject: messageData];
            
        }else if ([typeMessage isEqualToString: imageMessage])
        {
            NSBubbleData *photoBubble = [[NSBubbleData alloc] init];
            
            if ([thumbUrl containsString:@".jpg"] || [thumbUrl containsString:@".JPG"] || [thumbUrl containsString:@".png"] || [thumbUrl containsString:@".PNG"] || [thumbUrl containsString:@".jpeg"] || [thumbUrl containsString:@".JPEG"])
            {
                UIImage *thumbImg = nil;
                if ([myID isEqualToString: sendPhone]) {
                    photoBubble = [NSBubbleData dataWithImage:thumbImg type:BubbleTypeMine time:fullTime status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:description withTypeMessage:imageMessage isGroup:true ofUser:nil];
                    
                    [listContentMessage addObject: photoBubble];
                }else{
                    photoBubble = [NSBubbleData dataWithImage:thumbImg type:BubbleTypeSomeoneElse time:fullTime status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:description withTypeMessage:imageMessage isGroup:true ofUser:nil];
                    
                    [listContentMessage addObject: photoBubble];
                }
            }else{
                UIImage *thumbImg = [MyFunctions getImageOfDirectoryWithName: thumbUrl];
                if ([myID isEqualToString: sendPhone]) {
                    if (thumbImg != nil) {
                        photoBubble = [NSBubbleData dataWithImage:thumbImg type:BubbleTypeMine time:fullTime status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:content withTypeMessage:imageMessage isGroup:true ofUser:nil];
                        
                        [listContentMessage addObject: photoBubble];
                    }
                }else{
                    if (thumbImg != nil) {
                        photoBubble = [NSBubbleData dataWithImage:thumbImg type:BubbleTypeSomeoneElse time:fullTime status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:content withTypeMessage:imageMessage isGroup:true ofUser:nil];
                        
                        [listContentMessage addObject: photoBubble];
                    }else{
                        photoBubble = [NSBubbleData dataWithImage:[UIImage imageNamed:@"unloaded.png"] type:BubbleTypeSomeoneElse time:fullTime status:statusMsg idMessage:idMsgStr withExpireTime:expTime isRecall:isRecall description:content withTypeMessage:imageMessage isGroup:NO ofUser:nil];
                        
                        [listContentMessage addObject: photoBubble];
                    }
                }
            }
            appDelegate._heightChatTbView = appDelegate._heightChatTbView + photoBubble.view.frame.size.height+8;
        }
    }
    [rs close];
    return listContentMessage;
}

//  Cập nhật các tin nhắn chưa đọc thành đã đọc cho room chat
+ (void)updateAllMessagesInRoomChat: (int)roomID withAccount: (NSString *)account {
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE message SET status = 'YES' WHERE (receive_phone = '%@' OR send_phone = '%@') AND room_id = %d", account, account, roomID];
    [appDelegate._database executeUpdate: tSQL];
}

//  Get danh sách conversation của account
+ (NSMutableArray *)getAllConversationForHistoryMessageOfUser: (NSString *)user {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    NSString *tSQL = [NSString stringWithFormat:@"SELECT DISTINCT send_phone FROM message WHERE (receive_phone = '%@' AND room_id = '') UNION SELECT DISTINCT receive_phone FROM message WHERE (send_phone = '%@' AND room_id = '')", user, user];
    
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *sendPhone = [rsDict objectForKey:@"send_phone"];
        if (![sendPhone isEqualToString: text_empty] && ![sendPhone isEqualToString: user]) {
            ConversationObject *aConversation = [NSDBCallnex getConversationOfUser: sendPhone];
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

//  Get conversation của các group chat
+ (NSMutableArray *)getAllConversationForGroupOfUser {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    //  NSString *tSQL = [NSString stringWithFormat:@"SELECT room_id FROM message WHERE (send_phone = '%@' OR receive_phone = '%@') AND type_message != '%@' AND room_id != '' GROUP BY room_id", account, account, descriptionMessage];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT room_id FROM message WHERE (send_phone = '%@' OR receive_phone = '%@') AND room_id != '' GROUP BY room_id", account, account];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *roomID = [rsDict objectForKey:@"room_id"];
        ConversationObject *aConversation = [NSDBCallnex getConversationForGroup: roomID];
        if (aConversation != nil) {
            [result addObject: aConversation];
        }
    }
    [rs close];
    return result;
}

//  Get 1 conversation cho group chat
+ (ConversationObject *)getConversationForGroup: (NSString *)roomID {
    ConversationObject *aConversation  = nil;
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM message WHERE (send_phone = '%@' OR receive_phone='%@') AND room_id = '%@' ORDER BY id DESC LIMIT 0,1", account, account, roomID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        // Thông tin message
        NSDictionary *rsDict = [rs resultDictionary];
        
        NSString *sendPhone = [rsDict objectForKey:@"send_phone"];
        NSString *typeMessage = [rsDict objectForKey:@"type_message"];
        NSString *content = [rsDict objectForKey:@"content"];
        if (![typeMessage isEqualToString: descriptionMessage]) {
            if ([sendPhone isEqualToString:account]) {
                content = [NSString stringWithFormat:@"(%@)%@", [localization localizedStringForKey:text_you], content];
            }else{
                NSString *userName = [NSDBCallnex getFullnameOfContactWithCloudFoneID: sendPhone];
                content = [NSString stringWithFormat:@"(%@)%@", userName, content];
            }
        }
        
        int timeInterval = [[rsDict objectForKey:@"time"] intValue];
        int idRecord = [[rsDict objectForKey:@"id"] intValue];
        NSString *typeMesssage = [rsDict objectForKey:@"type_message"];
        NSString *isRecall = [rsDict objectForKey:@"is_recall"];
        
        // Tạo conversation
        aConversation = [[ConversationObject alloc] init];
        [aConversation set_user: account];
        [aConversation set_roomID: roomID];
        [aConversation set_messageDraf: text_empty];
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
        if ([sendPhone isEqualToString: account]) {
            [aConversation set_isSent: false];
        }else{
            [aConversation set_isSent: true];
        }
        
        [aConversation set_date: [MyFunctions stringDateFromInterval: timeInterval]];
        [aConversation set_time: [MyFunctions stringTimeFromInterval: timeInterval]];
        [aConversation set_idMessage: idRecord];
        
        // get tên của user
        NSString *groupName = [NSDBCallnex getGroupNameOfRoomWithId:[roomID intValue]];
        [aConversation set_contactName: groupName];
        [aConversation set_contactAvatar: @""];
        
        [aConversation set_unreadMsg: [NSDBCallnex getNumberMessageUnreadOfRoom:roomID]];
        [aConversation set_idObject: [roomID intValue]];
    }
    [rs close];
    return aConversation;
}

// Get 1 conversation của user
+ (ConversationObject *)getConversationOfUser: (NSString *)user{
    ConversationObject *aConversation  = nil;
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT send_phone, content, time, id, type_message, is_recall FROM message WHERE ((send_phone = '%@' AND receive_phone='%@') OR (send_phone='%@' AND receive_phone='%@')) AND room_id = '' ORDER BY id DESC LIMIT 0,1", account, user, user, account];
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
        [aConversation set_user: user];
        [aConversation set_roomID: text_empty];
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
            [aConversation set_isRecall: YES];
        }else{
            [aConversation set_isRecall: NO];
        }
        
        // Biến cho biết message gửi hay nhận
        if ([sendPhone isEqualToString: user]) {
            [aConversation set_isSent: NO];
        }else{
            [aConversation set_isSent: YES];
        }
        
        [aConversation set_date: [MyFunctions stringDateFromInterval: timeInterval]];
        [aConversation set_time: [MyFunctions stringTimeFromInterval: timeInterval]];
        [aConversation set_idMessage: idRecord];
        
        // get tên của user
        NSArray *infos = [NSDBCallnex getContactNameOfCloudFoneID:user];
        if (infos.count >= 2) {
            [aConversation set_contactName: [infos objectAtIndex: 0]];
            [aConversation set_contactAvatar: [infos objectAtIndex: 1]];
        }else{
            [aConversation set_contactName: @""];
            [aConversation set_contactAvatar: @""];
        }
        [aConversation set_unreadMsg: [NSDBCallnex getNumberMessageUnread:account andUser:user]];
        [aConversation set_idObject: [NSDBCallnex getContactIDWithCloudFoneID: user]];
    }
    [rs close];
    return aConversation;
}

//  Lấy tất cả danh sách group trong database

+ (NSMutableArray *)getAllGroupListInCallnexDB
{
    NSMutableArray *rsArray = [[NSMutableArray alloc] init];
    NSString *tSQL = [NSString stringWithFormat: @"SELECT * FROM groups WHERE id_group != %d AND id_group != %d ORDER BY id_group ASC", idWhitelist, idFavoritelist];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        GroupObject *aGroup = [[GroupObject alloc] init];
        NSDictionary *rsDict = [rs resultDictionary];
        int groupID         = [[rsDict objectForKey:@"id_group"] intValue];
        NSString *gName     = [rsDict objectForKey:@"group_name"];
        int gMember         = [[rsDict objectForKey:@"member_count"] intValue];
        NSString *gAvatar   = [rsDict objectForKey:@"avatar"];
        NSString *gDesc     = [rsDict objectForKey:@"group_description"];
        
        [aGroup set_gId: groupID];
        [aGroup set_gName: gName];
        [aGroup set_gMember: gMember];
        [aGroup set_gAvatar: gAvatar];
        [aGroup set_gDescription: gDesc];
        
        [rsArray addObject: aGroup];
    }
    [rs close];
    return rsArray;
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
        NSString *curDate = [MyFunctions getCurrentDate];
        NSString *curTime = [MyFunctions getCurrentTimeStamp];
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO room_chat(room_name, group_name, date, time, status, user, subject) VALUES ('%@', '%@', '%@', '%@', %d, '%@', '%@')", roomName, groupName, curDate, curTime, 1, [[NSUserDefaults standardUserDefaults] objectForKey:key_login], welcomeToCloudFone];
        [appDelegate._database executeUpdate: insertSQL];
    }
    [rs close];
}

//  Save một conversation cho room chat
+ (void)saveConversationForRoomChat: (int)roomID isUnread: (BOOL)isUnread
{
    BOOL exists = false;
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    
    NSString *roomIDStr = [NSString stringWithFormat:@"%d", roomID];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id FROM conversation WHERE account = '%@' AND room_id = '%@'", account, roomIDStr];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        exists = YES;
    }
    
    int numMsgUnread = 0;
    if (isUnread) {
        numMsgUnread = 1;
    }
    
    if (!exists) {
        NSString *addSQL = [NSString stringWithFormat:@"INSERT INTO conversation (account, user, room_id, message_draf, background, expire, unread, inear_mode, date, time) VALUES ('%@', '%@', '%@', '%@', '%@', %d, %d, %d, '%@', '%@')", account, @"", roomIDStr, @"", @"", 0, numMsgUnread, 0, [MyFunctions getCurrentDate], [MyFunctions getCurrentTimeStamp]];
        [appDelegate._database executeUpdate: addSQL];
    }
    [rs close];
}

//  Cập nhật tên của phòng
+ (void)updateGroupNameOfRoom: (NSString *)roomName andNewGroupName: (NSString *)newGroupName {
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE room_chat SET group_name = '%@' WHERE room_name = '%@'", newGroupName, roomName];
    [appDelegate._database executeUpdate: tSQL];
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

//  get list user trong room hiệnt tại (theo các tin nhắn -> lấy avatar cho bubble cell)
+ (NSMutableArray *)listUserInGroup: (int)roomID {
    NSMutableArray *rsArr = [[NSMutableArray alloc] init];
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT send_phone, receive_phone FROM message WHERE (send_phone = '%@' OR receive_phone = '%@') AND room_id = '%@' AND type_message != '%@' ORDER BY id DESC", account, account, [NSString stringWithFormat:@"%d", roomID], descriptionMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        NSString *sendPhone = [rsDict objectForKey:@"send_phone"];
        NSString *recvPhone = [rsDict objectForKey:@"receive_phone"];
        if (![sendPhone isEqualToString:account]) {
            if (![rsArr containsObject: sendPhone]) {
                [rsArr addObject: sendPhone];
            }
        }else{
            if (![rsArr containsObject: recvPhone]) {
                [rsArr addObject:recvPhone];
            }
        }
    }
    [rs close];
    return rsArr;
}

//  Cập nhật trạng thái deliverd của message gửi trong room chat
+ (BOOL)updateMessageDeliveredWithId: (NSString *)idMessage ofRoom: (NSString *)roomName {
    int idRoom = [NSDBCallnex getRoomIDOfRoomChatWithRoomName: roomName];
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE message SET delivered_status = 2 WHERE id_message = '%@' AND room_id = '%@'", idMessage, [NSString stringWithFormat:@"%d", idRoom]];
    return [appDelegate._database executeUpdate: tSQL];
}

//  Get room name của phòng
+ (NSString *)getRoomNameOfRoomWithRoomId: (int)roomId{
    NSString *roomName = text_empty;
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT room_name FROM room_chat WHERE id = %d AND user = '%@'", roomId, account];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        roomName = [rsDict objectForKey:@"room_name"];
    }
    [rs close];
    return roomName;
}

//  Lấy tên đại diện của room chat
+ (NSString *)getGroupNameOfRoom: (NSString *)roomName {
    NSString *resultStr = roomName;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT group_name FROM room_chat WHERE room_name = '%@'",roomName];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        resultStr = [rsDict objectForKey:@"group_name"];
    }
    [rs close];
    return resultStr;
}

//  Lấy tên đại diện của room với roomID
+ (NSString *)getGroupNameOfRoomWithId: (int)roomID {
    NSString *resultStr = @"";
    NSString *tSQL = [NSString stringWithFormat:@"SELECT group_name FROM room_chat WHERE id = %d",roomID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        resultStr = [rsDict objectForKey:@"group_name"];
    }
    [rs close];
    return resultStr;
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
        NSString *fullName  = text_empty;
        if (![firstName isEqualToString:text_empty] && [lastName isEqualToString:text_empty]) {
            fullName = firstName;
        }else if ([firstName isEqualToString:text_empty] && ![lastName isEqualToString:text_empty]){
            fullName = lastName;
        }else if (![firstName isEqualToString:text_empty] && ![lastName isEqualToString:text_empty]){
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
        [aObject set_avatar: text_empty];
    }
    return aObject;
}

// Kiểm tra có message unread giữa 2 user hay không?
+ (BOOL)checkUnreadMessageOfMeWithUser: (NSString *)callnexUser {
    BOOL result = false;
    NSString *me = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM message WHERE ((send_phone='%@' AND receive_phone='%@') OR (send_phone='%@' AND receive_phone='%@')) AND status='NO' AND room_id = '' LIMIT 0,1", me, callnexUser, callnexUser, me];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        result = true;
    }
    [rs close];
    return result;
}

// Kiểm tra có message unread trong room chat hay không?
+ (BOOL)checkUnreadMessageInRoom: (NSString *)roomID
{
    BOOL result = false;
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM message WHERE (send_phone='%@' OR receive_phone='%@') AND status='NO' AND room_id = '%@' LIMIT 0,1", account, account, roomID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        result = true;
    }
    [rs close];
    return result;
}

//  Kiểm tra user có nằm trong danh sách tắt thông báo hay không
+ (BOOL)checkUserExistsInMuteNotificationsList: (NSString *)user {
    BOOL result = false;
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT mutes FROM conversation WHERE account = '%@' AND user = '%@' LIMIT 0,1", account, user];
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

//  Kiểm tra group có trong danh sách mute hay ko
+ (BOOL)checkRoomInMutesNotificationsList: (NSString *)roomID {
    BOOL result = false;
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT mutes FROM conversation WHERE account = '%@' AND room_id = '%@' LIMIT 0,1", account, roomID];
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

// Chuyển message thành unread
+ (void)markUnreadMessageOfMeWithUser: (NSString *)userStr{
    NSString *meStr = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id FROM message WHERE ((send_phone='%@' AND receive_phone='%@') OR (send_phone='%@' AND receive_phone='%@')) AND room_id = '' ORDER BY id DESC LIMIT 0,1", userStr, meStr, meStr, userStr];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        int idMessage = [[dict objectForKey:@"id"] intValue];
        NSString *updateSQL = [NSString stringWithFormat:@"UPDATE message SET status='NO' WHERE id=%d", idMessage];
        [appDelegate._database executeUpdate: updateSQL];
    }
    [rs close];
}

//  chuyển message của room chat thành chưa đọc
+ (void)markUnReadMessageForRoomChat: (NSString *)roomID {
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id FROM message WHERE (send_phone='%@' OR receive_phone='%@') AND room_id = '%@' AND type_message != '%@'  ORDER BY id DESC LIMIT 0,1", account, account, roomID, descriptionMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        int idMessage = [[dict objectForKey:@"id"] intValue];
        NSString *updateSQL = [NSString stringWithFormat:@"UPDATE message SET status='NO' WHERE id=%d", idMessage];
        [appDelegate._database executeUpdate: updateSQL];
    }
    [rs close];
}

//  Get tất cả message chưa đọc của mình với 1 user
+ (int)getNumberMessageUnread: (NSString*)account andUser: (NSString*)user {
    int numberMessageUnread = 0;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT COUNT(*) as count FROM message WHERE ((send_phone = '%@' AND receive_phone = '%@') OR (send_phone='%@' AND receive_phone='%@')) AND status = 'NO' AND (room_id = '' OR room_id = '0') ", account, user, user, account];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        numberMessageUnread = [[dict objectForKey:@"count"] intValue];
    }
    [rs close];
    return numberMessageUnread;
}

//  Get tất cả các message chưa đọc của 1 room chat
+ (int)getNumberMessageUnreadOfRoom: (NSString *)roomID {
    int number = 0;
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT COUNT(*) as count FROM message WHERE (send_phone = '%@' OR receive_phone = '%@') AND status = 'NO' AND room_id = '%@'", account, account, roomID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        number = [[dict objectForKey:@"count"] intValue];
    }
    [rs close];
    return number;
}

//  Cập nhật trạng thái mute notification của user
+ (void)updateMuteNotificationsOfUser: (NSString *)user {
    BOOL addNew = true;
    BOOL result = false;
    
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT mutes FROM conversation WHERE account='%@' AND user='%@'", account, user];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        addNew = false;
        NSDictionary *rsDict = [rs resultDictionary];
        int mutes = [[rsDict objectForKey:@"mutes"] intValue];
        mutes = 1 - mutes;
        NSString *updateSQL = [NSString stringWithFormat:@"UPDATE conversation SET mutes = %d WHERE account='%@' AND user='%@'", mutes, account, user];
        result = [appDelegate._database executeUpdate: updateSQL];
    }
    
    if (addNew) {
        NSString *addSQL = [NSString stringWithFormat:@"INSERT INTO conversation (account, user, room_id, message_draf, background, expire, unread, inear_mode, mutes) VALUES ('%@','%@','%@','%@','%@',%d,%d,%d,%d)", account, user,@"",@"",@"",0,0,0,1];
        result = [appDelegate._database executeUpdate: addSQL];
    }
    [rs close];
}

//  Cập nhật bật tắt thông báo tin nhắn cho room chat
+ (void)updateMuteNotificationForRoomChat: (NSString *)roomID {
    BOOL addNew = true;
    BOOL result = false;
    
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT mutes FROM conversation WHERE account='%@' AND room_id='%@'", account, roomID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        addNew = false;
        NSDictionary *rsDict = [rs resultDictionary];
        int mutes = [[rsDict objectForKey:@"mutes"] intValue];
        mutes = 1 - mutes;
        NSString *updateSQL = [NSString stringWithFormat:@"UPDATE conversation SET mutes = %d WHERE account='%@' AND room_id='%@'", mutes, account, roomID];
        result = [appDelegate._database executeUpdate: updateSQL];
    }
    
    if (addNew) {
        NSString *addSQL = [NSString stringWithFormat:@"INSERT INTO conversation (account, user, room_id, message_draf, background, expire, unread, inear_mode, mutes) VALUES ('%@','%@','%@','%@','%@',%d,%d,%d,%d)", account, text_empty, roomID,text_empty,text_empty,0,0,0,1];
        result = [appDelegate._database executeUpdate: addSQL];
    }
    [rs close];
}

// Cập nhật trạng thái đã đọc khi vào view chat
+ (void)changeStatusMessageAFriend: (NSString*)user {
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE message SET status = 'YES' WHERE ((receive_phone='%@' AND send_phone='%@') OR (send_phone='%@' AND receive_phone='%@')) AND room_id = '%@'", account, user, account, user, text_empty];
    [appDelegate._database executeUpdate: tSQL];
}

//  Cập nhật subject của room chat
+ (BOOL)updateSubjectOfRoom: (NSString *)roomName withSubject: (NSString *)subject {
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE room_chat SET subject = '%@' WHERE user = '%@' AND room_name = '%@'", subject, account, roomName];
    BOOL result = [appDelegate._database executeUpdate: tSQL];
    return result;
}

//  Get subject của room chat
+ (NSString *)getSubjectOfRoom: (NSString *)roomName {
    NSString *resultStr = welcomeToCloudFone;
    NSString *meStr = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT subject FROM room_chat WHERE user = '%@' AND room_name = '%@'", meStr, roomName];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        resultStr = [rsDict objectForKey:@"subject"];
    }
    [rs close];
    return resultStr;
}

//  Lưu background chat của user vào conversation
+ (BOOL)saveBackgroundChatForUser: (NSString *)user withBackground: (NSString *)background {
    BOOL result = false;
    BOOL exists = false;
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    
    //  kiểm tra record đã tồn tại hay chưa: chưa thì thêm mới, tồn tại thì update
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id FROM conversation WHERE account = '%@' AND user = '%@' LIMIT 0,1", account, user];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        exists = true;
    }
    [rs close];
    
    if (exists) {
        NSString *tSQL2 = [NSString stringWithFormat:@"UPDATE conversation SET background = '%@' WHERE account = '%@' AND user = '%@'", background, account, user];
        result = [appDelegate._database executeUpdate: tSQL2];
    }else{
        NSString *tSQL2 = [NSString stringWithFormat:@"INSERT INTO conversation (account, user, room_id, background, expire, inear_mode) VALUES ('%@', '%@', '%@', '%@', %d, %d)", account, user, @"0", background, -1, 0];
        result = [appDelegate._database executeUpdate: tSQL2];
    }
    return result;
}

//  Lưu background chat của group vào conversation
+ (BOOL)saveBackgroundChatForRoom: (NSString *)roomID withBackground: (NSString *)background {
    BOOL result = false;
    BOOL exists = false;
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    
    //  kiểm tra record đã tồn tại hay chưa: chưa thì thêm mới, tồn tại thì update
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id FROM conversation WHERE account = '%@' AND room_id = '%@' LIMIT 0,1", account, roomID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        exists = true;
    }
    [rs close];
    
    if (exists) {
        NSString *tSQL2 = [NSString stringWithFormat:@"UPDATE conversation SET background = '%@' WHERE account = '%@' AND room_id = '%@'", background, account, roomID];
        result = [appDelegate._database executeUpdate: tSQL2];
    }else{
        NSString *tSQL2 = [NSString stringWithFormat:@"INSERT INTO conversation (account, user, room_id, background, expire, inear_mode) VALUES ('%@', '%@', '%@', '%@', %d, %d)", account, text_empty, roomID, background, -1, 0];
        result = [appDelegate._database executeUpdate: tSQL2];
    }
    return result;
}

//  Lấy background đã lưu cho view chat room
+ (NSString *)getChatBackgroundForRoom: (NSString *)roomID {
    NSString *result = text_empty;
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT background FROM conversation WHERE account = '%@' AND room_id = '%@'", account, roomID];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        result = [rsDict objectForKey:@"background"];
    }
    [rs close];
    return result;
}

//  Hàm delete tất cả message của 1 user
+ (void)deleteAllMessageWithUser: (NSString *)user {
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM message WHERE (send_phone='%@' AND receive_phone='%@') OR (send_phone='%@' AND receive_phone='%@')", account, user, user, account];
    [appDelegate._database executeUpdate: tSQL];
}

//  Hàm delete tất cả message của 1 user
+ (void)deleteAllMessageOfRoomChat:(NSString *)roomID {
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM message WHERE (send_phone = '%@' OR receive_phone = '%@') AND room_id = '%@'", account, account, roomID];
    [appDelegate._database executeUpdate: tSQL];
}

//  Kiểm tra một số callnex và id contact có trong blacklist hay không
+ (BOOL)checkContactInBlackList: (int)idContact andCloudfoneID: (NSString *)cloudfoneID
{
    BOOL result = false;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM group_members WHERE id_group = %d AND id_member = %d AND callnex_id = '%@' AND account = '%@' LIMIT 0,1", 0, idContact, cloudfoneID, [[NSUserDefaults standardUserDefaults] objectForKey:key_login]];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        result = true;
        break;
    }
    [rs close];
    return result;
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

//  Thêm một contact vào Blacklist
+ (BOOL)addContactToBlacklist: (int)idContact andCloudFoneID: (NSString *)cloudfoneID{
    BOOL result = false;
    NSString *tSQL = [NSString stringWithFormat:@"INSERT INTO group_members (id_group, id_member, callnex_id, account) VALUES (%d, %d, '%@', '%@')", 0, idContact, cloudfoneID, [[NSUserDefaults standardUserDefaults] objectForKey:key_login]];
    result = [appDelegate._database executeUpdate: tSQL];
    return result;
}

//  Xoá một contact cua Blacklist
+ (BOOL)removeContactFromBlacklist: (int)idContact andCloudFoneID: (NSString *)cloudFoneID {
    BOOL result = NO;
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM group_members WHERE id_group = %d AND id_member = %d AND callnex_id = %@ AND account = '%@'", 0, idContact, cloudFoneID, [[NSUserDefaults standardUserDefaults] objectForKey:key_login]];
    result = [appDelegate._database executeUpdate: tSQL];
    return result;
}

#pragma mark - new functions

//  Get tất cả các contact có cloudfone
+ (NSMutableArray *)getAllCloudFoneContactWithSearch: (NSString *)search {
    NSString *login = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSString *tSQL;
    if ([search isEqualToString: text_empty]) {
        tSQL = [NSString stringWithFormat:@"SELECT * FROM contact WHERE callnex_id != '' AND callnex_id != '%@' AND id_contact != 0", login];
    }else{
        tSQL = [NSString stringWithFormat:@"SELECT * FROM contact WHERE callnex_id != '' AND callnex_id != '%@' AND id_contact != 0 AND (callnex_id LIKE '%@%%' OR callnex_id LIKE '%%%@' OR callnex_id LIKE '%%%@%%')", login, search, search, search];
    }
    
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        ContactObject *aContact = [[ContactObject alloc] init];
        NSDictionary *rsDict = [rs resultDictionary];
        aContact._id_contact = [[rsDict objectForKey:@"id_contact"] intValue];
        aContact._avatar = [rsDict objectForKey:@"avatar"];
        aContact._firstName = [rsDict objectForKey:@"first_name"];
        aContact._lastName = [rsDict objectForKey:@"last_name"];
        if (![aContact._firstName isEqualToString:text_empty] && [aContact._lastName isEqualToString:text_empty]) {
            aContact._fullName = aContact._firstName;
        }else if ([aContact._firstName isEqualToString:text_empty] && ![aContact._lastName isEqualToString:text_empty]){
            aContact._fullName = aContact._lastName;
        }else if (![aContact._firstName isEqualToString:text_empty] && ![aContact._lastName isEqualToString:text_empty]){
            aContact._fullName = [NSString stringWithFormat:@"%@ %@", aContact._firstName, aContact._lastName];
        }
        aContact._cloudFoneID = [rsDict objectForKey:@"callnex_id"];
        if (aContact._fullName != nil) {
            [result addObject: aContact];
        }
    }
    [rs close];
    return result;
}

//  Xoá 1 cloudfoneID ra khỏi blacklist
+ (void)removeCloudFoneFromBlackList: (NSString *)cloudfoneID ofAccount: (NSString *)account
{
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM group_members WHERE id_group = %d AND callnex_id = %@ AND account = '%@'", 0, cloudfoneID, account];
    [appDelegate._database executeUpdate: tSQL];
}

+ (void)addCloudFoneIDToBlackList: (NSString *)cloudfoneID andIdContact: (int)idContact ofAccount: (NSString *)account {
    NSString *tSQL = [NSString stringWithFormat:@"INSERT INTO group_members (id_group, id_member, callnex_id, account) VALUES (%d, %d, '%@', '%@')", 0, idContact, cloudfoneID, account];
    [appDelegate._database executeUpdate: tSQL];
}

+ (void)addPBXContactToDBWithName: (NSString *)name andNumber: (NSString *)number {
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"INSERT INTO pbx_contacts (account, name, number) VALUES ('%@', '%@', '%@')", account, name, number];
    BOOL result = [appDelegate._threadDatabase executeUpdate: tSQL];
    if (result) {
        NSLog(@"---Thêm pbx contact thành công...");
    }
}

//  Xoá tất cả các PBX contacts trước khi thêm
+ (void)removeAllPBXContacts {
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM pbx_contacts"];
    BOOL result = [appDelegate._threadDatabase executeUpdate: tSQL];
    if (result) {
        NSLog(@"---Xoá tất cả các PBX contacts thành công");
    }
}

+ (NSMutableArray *)getPBXContactsOfUser {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM pbx_contacts"];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        PBXContact *aContact = [[PBXContact alloc] init];
        [aContact set_name:[rsDict objectForKey:@"name"]];
        [aContact set_number:[rsDict objectForKey:@"number"]];
        [aContact set_idContact:[[rsDict objectForKey:@"id"] intValue]];
        [list addObject: aContact];
    }
    [rs close];
    return list;
}

+ (NSMutableArray *)getPBXContactsWithName: (NSString *)name andNumber: (NSString *)number {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM pbx_contacts WHERE name LIKE '%@%%' OR name LIKE '%%%@' OR name LIKE '%%%@%%' OR number LIKE '%@%%' OR number LIKE '%%%@' OR number LIKE '%%%@%%'", name, name, name, number, number, number];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        PBXContact *aContact = [[PBXContact alloc] init];
        [aContact set_name:[rsDict objectForKey:@"name"]];
        [aContact set_number:[rsDict objectForKey:@"number"]];
        [aContact set_idContact:[[rsDict objectForKey:@"id"] intValue]];
        [list addObject: aContact];
    }
    [rs close];
    return list;
}

//  cập nhật PBX
+ (BOOL)updatePBXContactWithName: (NSString *)name andNumber: (NSString *)number withID: (int)idContact {
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE pbx_contacts SET name = '%@', number = '%@' WHERE id = %d", name, number, idContact];
    return [appDelegate._database executeUpdate: tSQL];
}

+ (BOOL)checkPBXContactExistInDBWithName: (NSString *)name andNumber: (NSString *)number {
    BOOL result = false;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT * FROM pbx_contacts WHERE name = '%@' AND number = '%@'", name, number];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        result = true;
    }
    [rs close];
    return result;
}

//  Lấy pbx name
+ (NSString *)getnameOfContactIfIsPBXContact: (NSString *)number {
    NSString *pbxName = text_empty;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT name FROM pbx_contacts WHERE number = '%@' LIMIT 0,1", number];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        pbxName = [rsDict objectForKey:@"name"];
    }
    [rs close];
    return pbxName;
}

+ (BOOL)deletePBXContactWithID: (int)idContact {
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM pbx_contacts WHERE id = %d", idContact];
    return [appDelegate._database executeUpdate: tSQL];
}

//  get id cuoi cung them vao app
+ (int)getLastIDContactFromApp {
    int contactId = 0;
    NSString *tSQL = @"SELECT id_contact FROM contact WHERE id_contact < 0 ORDER BY id_contact ASC LIMIT 0,1";
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *dict = [rs resultDictionary];
        contactId  = [[dict objectForKey:@"id_contact"] intValue];
    }
    [rs close];
    return contactId;
    
}

// Lọc callnex contact bị trùng trong danh sách
+ (NSMutableArray *)getAllCallnexListForFilterContact {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSString *tSQL = [NSString stringWithFormat:@"SELECT id_contact, first_name, last_name, callnex_id FROM contact contact WHERE callnex_id != '' AND id_contact != 0"];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        int idContact = [[rsDict objectForKey:@"id_contact"] intValue];
        NSString *firstName = [rsDict objectForKey:@"first_name"];
        NSString *latsName = [rsDict objectForKey:@"last_name"];
        NSString *cloudFoneID = [rsDict objectForKey:@"callnex_id"];
        
        FilterObject *aContact = [[FilterObject alloc] init];
        aContact._idContact = idContact;
        aContact._firstName = firstName;
        aContact._lastName = latsName;
        aContact._cloudFoneID = cloudFoneID;
        [result addObject: aContact];
    }
    [rs close];
    return result;
}

#pragma mark - ODS

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

+ (void)saveRoomSubject: (NSString *)subject forRoom: (NSString *)roomName {
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE room_chat SET subject='%@' WHERE room_name = '%@'", subject, roomName];
    [appDelegate._database executeUpdate: tSQL];
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

+ (void)removeAllUserInGroupChat {
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM room_user WHERE account = '%@'", account];
    [appDelegate._database executeUpdate: tSQL];
}

+ (void)removeAllUserInGroupChat: (NSString *)roomName {
    NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    NSString *tSQL = [NSString stringWithFormat:@"DELETE FROM room_user WHERE account = '%@' AND room_name = '%@'", account, roomName];
    [appDelegate._database executeUpdate: tSQL];
}

+ (void)updateContactInfo: (int)idContact withInfo: (NSDictionary *)info
{
    NSString *Name = [info objectForKey:@"Name"];
    NSString *Avatar = [info objectForKey:@"Avatar"];
    NSString *Address = [info objectForKey:@"Address"];
    NSString *Email = [info objectForKey:@"Email"];
    
    NSString *ConvertName = [AppFunctions convertUTF8CharacterToCharacter:Name];
    NSString *NameForSearch = [AppFunctions getNameForSearchOfConvertName: ConvertName];
    
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE contact SET email = '%@', address = '%@', first_name = '%@', last_name = '%@', avatar = '%@', name_for_search = '%@', convert_name = '%@'  WHERE id_contact = %d", Email, Address, Name, text_empty, Avatar, NameForSearch, ConvertName, idContact];
    [appDelegate._database executeUpdate: updateSQL];
}

+ (void)updateContactInfo: (int)idContact withInfo: (NSDictionary *)info andNewId: (int)newContactId
{
    NSString *Name = [info objectForKey:@"Name"];
    NSString *Avatar = [info objectForKey:@"Avatar"];
    NSString *Address = [info objectForKey:@"Address"];
    NSString *Email = [info objectForKey:@"Email"];
    
    NSString *ConvertName = [AppFunctions convertUTF8CharacterToCharacter:Name];
    NSString *NameForSearch = [AppFunctions getNameForSearchOfConvertName: ConvertName];
    
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE contact SET id_contact = %d, email = '%@', address = '%@', first_name = '%@', last_name = '%@', avatar = '%@', name_for_search = '%@', convert_name = '%@'  WHERE id_contact = %d", newContactId, Email, Address, Name, text_empty, Avatar, NameForSearch, ConvertName, idContact];
    BOOL update = [appDelegate._database executeUpdate: updateSQL];
    if (update) {
        NSLog(@"Update thanh cong");
    }else{
        NSLog(@"Failed!!!");
    }
    
    NSString *updateSQL2 = [NSString stringWithFormat:@"UPDATE contact_phone_number SET id_contact = %d WHERE id_contact = %d", newContactId, idContact];
    BOOL update2 = [appDelegate._database executeUpdate: updateSQL2];
    if (update2) {
        NSLog(@"Update thanh cong");
    }else{
        NSLog(@"Failed!!!");
    }
}

+ (NSString *)getLinkImageOfMessage: (NSString *)idMessage
{
    NSString *linkImage = text_empty;
    NSString *tSQL = [NSString stringWithFormat:@"SELECT thumb_url FROM message WHERE id_message = '%@'", idMessage];
    FMResultSet *rs = [appDelegate._database executeQuery: tSQL];
    while ([rs next]) {
        NSDictionary *rsDict = [rs resultDictionary];
        linkImage = [rsDict objectForKey:@"thumb_url"];
        
    }
    [rs close];
    return linkImage;
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

// Cập nhật last_time_expire cho message của group hiện tại
+ (void)updateLastTimeExpireForMessageOfGroupId: (int)idGroup
{
    NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
    NSString *me = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    
    // Xoá các tin nhắn đã hết hạn trước
    NSString *delSQL = [NSString stringWithFormat:@"DELETE FROM message WHERE last_time_expire > 0 AND last_time_expire <= %d AND status = 'YES' AND delivered_status = 2 AND (send_phone = '%@' OR receive_phone='%@') AND room_id = %d", (int)curTime, me, me, idGroup];
    BOOL delete = [appDelegate._database executeUpdate: delSQL];
    if (!delete) {
        NSLog(@".....Xoa khong thanh cong");
    }
    // Cập nhật tất cả các msg chưa có last_time_expire
    NSString *tSQL = [NSString stringWithFormat:@"UPDATE message SET last_time_expire = %d + expire_time WHERE (send_phone = '%@' OR receive_phone = '%@') AND expire_time > 0 AND last_time_expire = 0 AND delivered_status = 2 AND (type_message = '%@' OR type_message = '%@' OR type_message = '%@')", (int)curTime, me, me, textMessage, locationMessage, descriptionMessage];
    BOOL update = [appDelegate._database executeUpdate: tSQL];
    if (!update) {
        NSLog(@"update failed....");
    }
}

@end
