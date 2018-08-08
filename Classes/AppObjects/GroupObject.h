//
//  GroupObject.h
//  linphone
//
//  Created by user on 20/11/14.
//
//

#import <Foundation/Foundation.h>

@interface GroupObject : NSObject

@property (nonatomic, assign) int _gId;
@property (nonatomic, strong) NSString *_gName;
@property (nonatomic, assign) int _gMember;
@property (nonatomic, assign) int _gUpdate;
@property (nonatomic, strong) NSString *_gAvatar;
@property (nonatomic, strong) NSString *_gDescription;
@property (nonatomic, strong) NSMutableArray *_gListMember;

@end
