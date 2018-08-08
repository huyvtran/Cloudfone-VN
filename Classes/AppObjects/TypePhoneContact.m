//
//  TypePhoneContact.m
//  linphone
//
//  Created by user on 19/11/14.
//
//

#import "TypePhoneContact.h"

@implementation TypePhoneContact
@synthesize _typePhone, _phoneNumber, _serverID;

- (id)initWithTypePhone: (NSString *)typePhone phoneNumber: (NSString *)phoneNumber andServerID: (int)serverID {
    [self set_typePhone: typePhone];
    [self set_phoneNumber: phoneNumber];
    [self set_serverID: serverID];
    return self;
}

@end
