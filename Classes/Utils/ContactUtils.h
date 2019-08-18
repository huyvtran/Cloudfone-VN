//
//  ContactUtils.h
//  linphone
//
//  Created by lam quang quan on 11/2/18.
//

#import <Foundation/Foundation.h>

@interface ContactUtils : NSObject

+ (void)startContactUtils;
+ (PhoneObject *)getContactPhoneObjectWithNumber: (NSString *)number;
+ (NSString *)getContactNameWithNumber: (NSString *)number;
+ (NSAttributedString *)getSearchValueFromResultForNewSearchMethod: (NSArray *)searchs;
+ (void)addBorderForImageView: (UIImageView *)imageView withRectSize: (float)rectSize strokeWidth: (int)stroke strokeColor: (UIColor *)strokeColor radius: (float)radius;
+ (ABRecordRef)addNewContacts;
+ (BOOL)deleteContactFromPhoneWithId: (int)recordId;
+ (NSString *)getFullnameOfContactIfExists;
+ (NSString *)onlyGetContactNameForCallWithNumber: (NSString *)number;

+ (NSString *)getFullNameFromContact: (ABRecordRef)aPerson;
+ (NSString *)getBase64AvatarFromContact: (ABRecordRef)aPerson;
+ (UIImage *)getAvatarFromContact: (ABRecordRef)aPerson;
+ (NSString *)getCompanyFromContact: (ABRecordRef)aPerson;
+ (NSString *)getEmailFromContact: (ABRecordRef)aPerson;
+ (NSMutableArray *)getListPhoneOfContactPerson: (ABRecordRef)aPerson;

//  Get first name and last name of contact
+ (NSArray *)getFirstNameAndLastNameOfContact: (ABRecordRef)aPerson;
+ (NSString *)getFirstPhoneFromContact: (ABRecordRef)aPerson;

@end
