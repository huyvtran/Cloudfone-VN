//
//  ContactUtils.h
//  linphone
//
//  Created by lam quang quan on 11/2/18.
//

#import <Foundation/Foundation.h>

@interface ContactUtils : NSObject

+ (PhoneObject *)getContactPhoneObjectWithNumber: (NSString *)number;
+ (NSString *)getContactNameWithNumber: (NSString *)number;
+ (NSAttributedString *)getSearchValueFromResultForNewSearchMethod: (NSArray *)searchs;
+ (ContactObject *)getContactWithId: (int)idContact;
+ (PBXContact *)getPBXContactWithId: (int)idContact;
+ (void)addBorderForImageView: (UIImageView *)imageView withRectSize: (float)rectSize strokeWidth: (int)stroke strokeColor: (UIColor *)strokeColor radius: (float)radius;

@end
