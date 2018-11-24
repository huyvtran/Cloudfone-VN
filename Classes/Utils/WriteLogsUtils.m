//
//  WriteLogsUtils.m
//  iMomeet
//
//  Created by lam quang quan on 11/12/18.
//  Copyright © 2018 Softfoundry. All rights reserved.
//

#import "WriteLogsUtils.h"

@implementation WriteLogsUtils

+ (BOOL)createLogFileWithName: (NSString *)filePathName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:filePathName];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:path
                                       withIntermediateDirectories:NO
                                                        attributes:nil
                                                             error:&error])
        {
            NSLog(@"Create directory error: %@", error);
            return NO;
        }else{
            return YES;
        }
    }
    //  This file is exists
    return NO;
}

+ (NSString *)makeFilePathWithFileName:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *url = [paths objectAtIndex:0];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", url, fileName];
    return filePath;
}

+ (NSString *)getLogContentIfExistsFromFile: (NSString *)filePath isFullPath: (BOOL)isFullPath{
    if (!isFullPath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *url = [paths objectAtIndex:0];
        filePath = [NSString stringWithFormat:@"%@/%@", url, filePath];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath: filePath]) {
        NSString *contents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        return contents;
    }
    return @"";
}

+ (void)writeLogContent: (NSString *)logContent toFilePath: (NSString *)pathFile
{
    if(![[NSFileManager defaultManager] fileExistsAtPath:pathFile]) {
        [[NSFileManager defaultManager] createFileAtPath:pathFile contents:nil attributes:nil];
    }
    
    NSString *content = [self getLogContentIfExistsFromFile: pathFile isFullPath: YES];
    
    content = [NSString stringWithFormat:@"%@\n%@: %@", content, [AppUtils getCurrentDateTimeToStringWithLanguage:key_vi], logContent];
    NSData* data = [content dataUsingEncoding:NSUTF8StringEncoding];
    if (data != nil) {
        [data writeToFile:pathFile atomically:YES];
    }
}

//  [Khai le - 16/11/2018]: Clear logs file
+ (void)clearLogFilesAfterExpireTime: (long)expireTime
{
    NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                 NSUserDomainMask, YES) objectAtIndex:0];
    NSString *pathDir = [documentDir stringByAppendingPathComponent: logsFolderName];
    NSArray *pFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pathDir error:NULL];
    for (int count = 0; count < (int)[pFiles count]; count++)
    {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", pathDir, [pFiles objectAtIndex: count]];
        NSDictionary* fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        NSDate *createdDate = [fileAttribs objectForKey:NSFileCreationDate]; //or NSFileModificationDate
        if (createdDate != nil) {
            NSTimeInterval secondsBetween = [[NSDate date] timeIntervalSinceDate:createdDate];
            if (secondsBetween >= expireTime) {
                [self removeFileWithPath: filePath];
                NSLog(@"Expire");
            }
        }
    }
}

+ (void)removeFileWithPath: (NSString *)path {
    // remove file if exist
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath: path];
    if (fileExists) {
        BOOL success = [fileManager removeItemAtPath:path error:&error];
        if (success) {
            NSLog(@"Deleted file of event");
        }
    }
}



@end
