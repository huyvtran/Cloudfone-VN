//
//  RoomObject.h
//  linphone
//
//  Created by Ei Captain on 7/14/16.
//
//

#import <Foundation/Foundation.h>

@interface RoomObject : NSObject

@property (nonatomic, assign) int _roomID;
@property (nonatomic, strong) NSString *_roomName;
@property (nonatomic, strong) NSString *_gName;
@property (nonatomic, strong) NSString *_roomSubject;
@property (nonatomic, assign) int _roomMember;

@end
