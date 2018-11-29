//
//  NgnFileUtils.m
//  linphone
//
//  Created by lam quang quan on 10/25/18.
//

#import "NgnFileUtils.h"

@implementation NgnFileUtils

+ (void) createDirectoryAndSubDirectory:(NSString *)directory
{
    NSString* filePath= @"";
    NSArray* pathcoms= [directory componentsSeparatedByString:@"/"];
    if([pathcoms count]>1)
    {
        for(int i=0;i<[pathcoms count]-1;i++)
        {
            filePath=[filePath stringByAppendingPathComponent:[pathcoms objectAtIndex:i]];
            [self createDirectory:filePath];
        }
    }
    filePath = [filePath stringByAppendingPathComponent:[pathcoms objectAtIndex:[pathcoms count]-1]];
    [self createDirectory:filePath];
}

+ (void) createDirectory:(NSString*)directory
{
    NSString *path1;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path1 = [[paths objectAtIndex:0] stringByAppendingPathComponent:directory];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path1])    //Does directory already exist?
    {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:path1
                                       withIntermediateDirectories:NO
                                                        attributes:nil
                                                             error:&error])
        {
            NSLog(@"Create directory error: %@", error);
        }
    }
}

+ (NSString *)getPathOfFileWithSubDir: (NSString *)subDir {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *result = [[paths objectAtIndex:0] stringByAppendingPathComponent: subDir];
    return result;
}

@end
