//
//  PhoneBookObject.h
//  linphone
//
//  Created by user on 26/11/14.
//
//

#import <Foundation/Foundation.h>

@interface PhoneBookObject : NSObject{
    NSString *_pbName;
    NSString *_pbPhone;
    NSString *_pbAvatar;
    NSString *_pbNameForSearch;
    BOOL _isCallnex;
    int _idContact;
}

@property (nonatomic, strong) NSString *_pbName;
@property (nonatomic, strong) NSString *_pbPhone;
@property (nonatomic, strong) NSString *_pbAvatar;
@property (nonatomic, strong) NSString *_pbNameForSearch;
@property (nonatomic, assign) BOOL _isCloudFone;
@property (nonatomic, assign) int _idContact;

@end
