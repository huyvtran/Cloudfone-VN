//
//  OTRProtocol.h
//  Off the Record
//
//  Created by Chris Ballinger on 6/25/12.
//  Copyright (c) 2012 Chris Ballinger. All rights reserved.
//
//  This file is part of ChatSecure.
//
//  ChatSecure is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ChatSecure is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ChatSecure.  If not, see <http://www.gnu.org/licenses/>.

#import "OTRAccount.h"
#import "OTRXMPPAccount.h"
#import "XMPPIncomingFileTransfer.h"
#import "XMPPOutgoingFileTransfer.h"

@class OTRMessage, OTRBuddy;

@protocol OTRProtocol <NSObject>

@property (nonatomic, strong) OTRAccount * account;
@property (nonatomic, strong) NSMutableDictionary * protocolBuddyList;

- (void) sendMessage:(OTRMessage*)message;

#pragma mark - Blacklist & Whitelist
- (void)createBlackListOfMe: (NSArray *)blackList;
- (void)blockUserInCallnexBlacklist: (NSArray *)blackListArr;
- (void)blockAllContactNotInWhiteList: (NSString *)meXmppString whiteList: (NSArray *)whiteList;
- (void)activeBlackListOfMe;

//  Đồng ý vào group chat
- (void)acceptJoinToRoomChat: (NSString *)roomName;

- (void)pingAnUser: (NSString *)user;

//  Gửi yêu cầu kết bạn đến 1 user
- (void)sendRequestFrom:(NSString *)fromUser toUser: (NSString *)toUser;

- (void)sendRequestUserInfoOf: (NSString *)fromUser toUser: (NSString *)toUser withContent: (NSString *)content andDisplayName: (NSString *)displayName;

/*--Chấp nhận yêu cầu kết bạn của 1 user--*/
- (void)sendAcceptRequestFromMe: (NSString *)me toUser: (NSString *)user;

//  Chấp nhận yêu cầu kết bạn từ 1 user
- (void) acceptRequestFromUser:(NSString *)fromUser toMe: (NSString *)toMe;
- (void)acceptRequestFriendFromUser: (NSString *)user;

//Từ chối yêu cầu kết bạn từ 1 user
- (void) rejectRequestFromUser:(NSString *)toUser toMe: (NSString *)fromMe;

- (void)setProfileForAccountWithName: (NSString *)fullname email: (NSString *)email address: (NSString *)address avatar: (NSString *)strAvatar;

- (void)getVcard;

- (void)clearStateOfUserBeforeSendRequest: (NSString *)user;

// Gửi message recall một message
- (void)sendRequestRecallToUser: (NSString *)userXmppStr fromUser: (NSString *)fromUser andIdMsg: (NSString *)idMessage;

- (void)setStatus: (NSString *)statusText withUser: (NSString *)user;

// Xoá 1 user ra khỏi roster list
- (void)removeUserFromRosterList: (NSString *)user withIdMessage: (NSString *)idIQ;

/* Send message cho group */
- (void)sendMessageWithContent: (NSString *)contentMsg ofMe: (NSString *)meStr toGroup: (NSString *)groupName withIdMessage: (NSString *)idMessage;

/* send location to user */
- (void)sendLocationToUser: (NSString *)user withLat: (float)lat andLng: (float)lng andAddress: (NSString *)address andDescription: (NSString *)description withIdMessage: (NSString *)idMessage;

/*--Gửi request yêu cầu tracking đến user--*/
- (void)sendTrackingRequestToUser: (NSString *)userStr withLocationInfo: (NSString *)locationInfo;

/*--Gửi thông tin location nếu chấp nhận--*/
- (void)sendYourLocationToUserRequestTracking: (NSString *)userStr withLocation: (NSString *)locationInfo;

/*--send message tracking đến user--*/
- (void)sendMessageTrackingToUser: (NSString *)user withContent: (NSString *)content andIdMessage: (NSString *)idMessage;

/*--Từ chối yêu cầu tracking từ user--*/
- (void)ejectTrackingFromUser: (NSString *)user;

/*--Gửi update location đến user trong tracking list--*/
- (void)sendUpdateLocationToUser: (NSString *)user andMyLocationInfo: (NSString *)locationInfo;

- (void)sendMessageToUserInTrackingList: (NSString *)user withContent: (NSString *)contentMessage withId: (NSString *)idMessage;

//  Get danh sách user trong room chat
- (void)getListUserInRoomChat: (NSString *)roomName;
- (void) setLeaveRoomToServer:(NSString *)roomId withId: (NSString *)idIQ;

/*--Doi ten cua room chat--*/
- (void)changeNameOfTheRoom: (NSString *)roomName withNewName: (NSString *)newName;

/*--Doi ten subject cua phong--*/
- (void)changeSubjectOfTheRoom: (NSString *)roomName withSubject: (NSString *)subject;

//  Đổi description của room chat
- (void)changeDescriptionOfTheRoom: (NSString *)roomName withSubject: (NSString *)subject;

//  Huy OTR voi 1 user
- (void)destroySessionOTRWithUser: (NSString *)user andIdMessage: (NSString *)idMessage;
- (void)sendRequestOTRToUser: (NSString *)user;

/*--Chap nhan huy OTR voi mot user--*/
- (void)acceptDestroySessionOTRWithUser: (NSString *)user;

- (void)sendContactMessageToUser: (XMPPMessage *)message;

- (void)kickOccupantInRoomChat: (NSString *)roomName withNickName: (NSString *)nickName;

//  Ban một user khỏi room chat
- (void)banOccupantInRoomChat: (NSString *)roomName withUser: (NSString *)user;

/*Refresh roster list*/
- (void)refreshRosterList;

- (NSArray*) buddyList;
- (void) connectWithPassword:(NSString *)password;
- (void) disconnect;

@optional

- (void)sendChatState:(int)chatState withBuddy:(OTRBuddy *)buddy;

/* Tạo group chat */
- (void)createGroupOfMe: (NSString *)meStr andGroupName: (NSString *)groupName;

/* Mời danh sách user vào trong group */
- (void)inviteUserToGroupChat: (NSString *)groupName andListUser: (NSArray *)listUser;

- (void)setRoleForUserInGroupChat: (NSString *)roomName andListUser: (NSArray *)listUser;

/* Get số người online trong group */
- (void)getListOnlineOccupantsInGroup: (NSString *)groupName;

- (void)pingForConnectToServer;

//  Rời khỏi một room chat
- (void)leaveConference: (NSString *)roomName;

- (void)requestVCardFromAccount: (NSString *)account;

- (void)sendMessageImageForGroup: (NSString *)roomName withLinkImage: (NSString *)link andDescription: (NSString *)caption andIdMessage: (NSString *)idMessage;

- (void)sendMessageMediaForUser: (NSString *)username withLinkImage: (NSString *)link andDescription: (NSString *)caption andIdMessage: (NSString *)idMessage andType: (NSString *)type withBurn: (int)burn forGroup: (BOOL)isGroup;

- (void)sendDisplayedToUser: (NSString *)toUser fromUser: (NSString *)fromUser andListIdMsg: (NSString *)listIdMsg;
- (void)getGroupDataFromServer;
- (void)storeGroupDataToServer:(NSString *)groups;

@end
