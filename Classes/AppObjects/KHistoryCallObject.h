//
//  KHistoryCallObject.h
//  linphone
//
//  Created by user on 17/11/14.
//
//

#import <Foundation/Foundation.h>

@interface KHistoryCallObject : NSObject{
    int _callId;
    NSString *_phoneNumber;
    NSString *_status;
    NSString *_callDirection;
    NSString *_callTime;
    NSString *_callDate;
    NSString *_phoneName;
    NSString *_prefixPhone;
    NSString *_phoneAvatar;
}

@property (nonatomic, assign) int _callId;
@property (nonatomic, strong) NSString *_phoneNumber;
@property (nonatomic, strong) NSString *_status;
@property (nonatomic, strong) NSString *_callDirection;
@property (nonatomic, strong) NSString *_callTime;
@property (nonatomic, strong) NSString *_callDate;
@property (nonatomic, strong) NSString *_phoneName;
@property (nonatomic, strong) NSString *_prefixPhone;
@property (nonatomic, strong) NSString *_phoneAvatar;
@property (nonatomic, strong) NSString *_recordFile;

@end
