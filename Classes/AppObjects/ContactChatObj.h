//
//  ContactChatObj.h
//  linphone
//
//  Created by Ei Captain on 7/15/16.
//
//

#import <Foundation/Foundation.h>

@interface ContactChatObj : NSObject

@property (nonatomic, assign) int _idContact;
@property (nonatomic, strong) NSString *_fullName;
@property (nonatomic, strong) NSString *_avatar;
@property (nonatomic, strong) NSString *_callnexID;

@end
