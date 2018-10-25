//
//  NgnFileUtils.h
//  linphone
//
//  Created by lam quang quan on 10/25/18.
//

#import <Foundation/Foundation.h>

@interface NgnFileUtils : NSObject

+ (void) createDirectoryAndSubDirectory:(NSString *)directory;
+ (void) createDirectory:(NSString*)directory;

@end
