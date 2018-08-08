//
//  ContactObject.h
//  linphone
//
//  Created by user on 18/11/14.
//
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface ContactObject : NSObject

@property (nonatomic, assign) ABRecordRef person;
@property (nonatomic, assign) int _id_contact;
@property (nonatomic, strong) NSString *_firstName;
@property (nonatomic, strong) NSString *_lastName;
@property (nonatomic, strong) NSString *_fullName;
@property (nonatomic, strong) NSString *_nameForSearch;
@property (nonatomic, strong) NSString *_sipPhone;
@property (nonatomic, strong) NSMutableArray *_listPhone;
@property (nonatomic, strong) NSString *_avatar;
@property (nonatomic, strong) NSString *_company;
@property (nonatomic, strong) NSString *_email;
@property (nonatomic, assign) int _type;

@property (nonatomic, assign) BOOL _accept;

@end
