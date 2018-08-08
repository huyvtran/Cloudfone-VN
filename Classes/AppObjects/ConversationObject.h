//
//  ConversationObject.h
//  linphone
//
//  Created by Designer 01 on 3/9/15.
//
//

#import <Foundation/Foundation.h>

@interface ConversationObject : NSObject {
    NSString *_typeMessage;
    NSString *_user;
    NSString *_roomID;
    NSString *_messageDraf;
    NSString *_lastMessage;
    int _idMessage;
    NSString *_date;
    NSString *_time;
    NSString *_contactName;
    NSString *_contactAvatar;
    int _unreadMsg;
    int _idObject;  //  Chứa id của contact hay room
    BOOL _isSent;
    BOOL _isRecall;
}

@property (nonatomic, strong) NSString *_typeMessage;
@property (nonatomic, strong) NSString *_user;
@property (nonatomic, strong) NSString *_roomID;
@property (nonatomic, strong) NSString *_messageDraf;
@property (nonatomic, strong) NSString *_lastMessage;
@property (nonatomic, assign) int _idMessage;
@property (nonatomic, strong) NSString *_date;
@property (nonatomic, strong) NSString *_time;
@property (nonatomic, strong) NSString *_contactName;
@property (nonatomic, strong) NSString *_contactAvatar;
@property (nonatomic, assign) int _unreadMsg;
@property (nonatomic, assign) int _idObject;
@property (nonatomic, assign) BOOL _isSent;
@property (nonatomic, assign) BOOL _isRecall;

@end
