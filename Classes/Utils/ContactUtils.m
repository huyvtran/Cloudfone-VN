//
//  ContactUtils.m
//  linphone
//
//  Created by lam quang quan on 11/2/18.
//

#import "ContactUtils.h"

@implementation ContactUtils

+ (PhoneObject *)getContactPhoneObjectWithNumber: (NSString *)number {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"number = %@", number];
    NSArray *filter = [[LinphoneAppDelegate sharedInstance].listInfoPhoneNumber filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        for (int i=0; i<filter.count; i++) {
            PhoneObject *item = [filter objectAtIndex: i];
            if (![AppUtils isNullOrEmpty: item.avatar]) {
                return item;
            }
        }
        return [filter firstObject];
    }
    return nil;
}

@end
