//
//  TypePhoneContact.h
//  linphone
//
//  Created by user on 19/11/14.
//
//

#import <Foundation/Foundation.h>

@interface TypePhoneContact : NSObject{
    NSString *_typePhone;
    NSString *_phoneNumber;
    int _serverID;
}

@property (nonatomic, strong) NSString *_typePhone;
@property (nonatomic, strong) NSString *_phoneNumber;
@property (nonatomic, assign) int _serverID;

- (id)initWithTypePhone: (NSString *)typePhone phoneNumber: (NSString *)phoneNumber andServerID: (int)serverID;

@end
