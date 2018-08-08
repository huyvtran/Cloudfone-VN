//
//  OTROscarManager.m
//  Off the Record
//
//  Created by Chris Ballinger on 9/4/11.
//  Copyright (c) 2011 Chris Ballinger. All rights reserved.
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

#import "OTROscarManager.h"
#import "OTRProtocolManager.h"
#import "OTRConstants.h"
#import "XMPPOutgoingFileTransfer.h"

@implementation OTROscarManager

@synthesize accountName;
@synthesize loginFailed;
@synthesize loggedIn;
@synthesize protocolBuddyList,account;

BOOL loginFailed;

-(id)init
{
    self = [super init];
    if(self)
    {
        mainThread = [NSThread currentThread];
        protocolBuddyList = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)blockingCheck {
	static NSDate * lastTime = nil;
	if (!lastTime) {
		lastTime = [NSDate date];
	} else {
		NSDate * newTime = [NSDate date];
		NSTimeInterval ti = [newTime timeIntervalSinceDate:lastTime];
		if (ti > 0.2) {
			//NSLog(@"Main thread blocked for %d milliseconds.", (int)round(ti * 1000.0));
		}
		lastTime = newTime;
	}
	[self performSelector:@selector(blockingCheck) withObject:nil afterDelay:0.05];
}

- (void)checkThreading {
	if ([NSThread currentThread] != mainThread) {
		//NSLog(@"warning: NOT RUNNING ON MAIN THREAD!");
	}
}


#pragma mark Login Delegate

-(void)authorizer:(id)authorizer didFailWithError:(NSError *)error {
    //NSLog(@"Authorizer Error: %@",[error description]);
}

#pragma mark Session Delegate

#pragma mark Buddy List Methods

#pragma mark Message Handler

#pragma mark Status Handler

#pragma mark Rate Handlers

#pragma mark File Transfers

#pragma mark Commands

- (NSString *)removeBuddy:(NSString *)username {
//	AIMBlistBuddy * buddy = [theSession.session.buddyList buddyWithUsername:username];
//	if (buddy && [buddy group]) {
//		FTRemoveBuddy * remove = [[FTRemoveBuddy alloc] initWithBuddy:buddy];
//		[theSession.feedbagHandler pushTransaction:remove];
//		return @"Remove (buddy) request sent.";
//	} else {
//		return @"Err: buddy not found.";
//	}
    return @"";
}

- (NSString *)addBuddy:(NSString *)username toGroup:(NSString *)groupName {
//	AIMBlistGroup * group = [theSession.session.buddyList groupWithName:groupName];
//	if (!group) {
//		return @"Err: group not found.";
//	}
//	AIMBlistBuddy * buddy = [group buddyWithUsername:username];
//	if (buddy) {
//		return @"Err: buddy exists.";
//	}
//	FTAddBuddy * addBudd = [[FTAddBuddy alloc] initWithUsername:username group:group];
//	[theSession.feedbagHandler pushTransaction:addBudd];
	return @"Add (buddy) request sent.";
}
- (NSString *)deleteGroup:(NSString *)groupName {
//	AIMBlistGroup * group = [theSession.session.buddyList groupWithName:groupName];
//	if (!group) {
//		return @"Err: group not found.";
//	}
//	FTRemoveGroup * delGrp = [[FTRemoveGroup alloc] initWithGroup:group];
//	[theSession.feedbagHandler pushTransaction:delGrp];
	return @"Delete (group) request sent.";
}
- (NSString *)addGroup:(NSString *)groupName {
//	AIMBlistGroup * group = [theSession.session.buddyList groupWithName:groupName];
//	if (group) {
//		return @"Err: group exists.";
//	}
//	FTAddGroup * addGrp = [[FTAddGroup alloc] initWithName:groupName];
//	[theSession.feedbagHandler pushTransaction:addGrp];
	return @"Add (group) request sent.";
}
- (NSString *)denyUser:(NSString *)username {
	NSString * msg = @"Deny add sent!";
//	if ([theSession.feedbagHandler currentPDMode:NULL] != PD_MODE_DENY_SOME) {
//		FTSetPDMode * pdMode = [[FTSetPDMode alloc] initWithPDMode:PD_MODE_DENY_SOME pdFlags:PD_FLAGS_APPLIES_IM];
//		[theSession.feedbagHandler pushTransaction:pdMode];
//		msg = @"Set PD_MODE and sent add deny";
//	}
//	FTAddDeny * deny = [[FTAddDeny alloc] initWithUsername:username];
//	[theSession.feedbagHandler pushTransaction:deny];
	return msg;
}
- (NSString *)undenyUser:(NSString *)username {
	NSString * msg = @"Deny delete sent!";
//	if ([theSession.feedbagHandler currentPDMode:NULL] != PD_MODE_DENY_SOME) {
//		msg = @"Warning: Deny delete sent but PD_MODE isn't DENY_SOME";
//	}
//	FTDelDeny * delDeny = [[FTDelDeny alloc] initWithUsername:username];
//	[theSession.feedbagHandler pushTransaction:delDeny];
	return msg;
}

/*+(AIMSessionManager*) AIMSession
{
    return s_AIMSession;
}*/

-(void)sendMessage:(OTRMessage *)theMessage
{
//    NSString *recipient = theMessage.buddy.accountName;
//    NSString *message = theMessage.message;
//    
//    AIMMessage * msg = [AIMMessage messageWithBuddy:[theSession.session.buddyList buddyWithUsername:recipient] message:message];
//    
//    // use delay to prevent OSCAR rate-limiting problem
//    //NSDate *future = [NSDate dateWithTimeIntervalSinceNow: delay ];
//    //[NSThread sleepUntilDate:future];
//    
//	[theSession.messageHandler sendMessage:msg];
}

- (void)pingAnUser: (NSString *)user{}

//  Gửi yêu cầu kết bạn đến user
- (void) sendRequestFrom:(NSString *)fromUser toUser: (NSString *)toUser{}

//  Gửi thông tin kết bạn của user
- (void)sendRequestUserInfoOf: (NSString *)fromUser toUser: (NSString *)toUser withContent: (NSString *)content andDisplayName: (NSString *)displayName{}

/*--Chấp nhận yêu cầu kết bạn của 1 user--*/
- (void)sendAcceptRequestFromMe: (NSString *)me toUser: (NSString *)user{}

- (void) acceptRequestFromUser:(NSString *)fromUser toMe: (NSString *)toMe{}
- (void)acceptRequestFriendFromUser: (NSString *)user {}

- (void) rejectRequestFromUser:(NSString *)toUser toMe: (NSString *)fromMe{}

- (void)getVcard{}

- (void)setProfileForAccountWithName: (NSString *)fullname email: (NSString *)email address: (NSString *)address avatar: (NSString *)strAvatar{}

- (void)clearStateOfUserBeforeSendRequest: (NSString *)user{}

- (void)setStatus: (NSString *)statusText withUser: (NSString *)user{}

- (void)sendContactMessageToUser: (XMPPMessage *)message{}

#pragma mark - Blacklist & Whitelist
- (void)createBlackListOfMe: (NSArray *)blackList{}
- (void)blockAllContactNotInWhiteList: (NSString *)meXmppString whiteList: (NSArray *)whiteList{}
- (void)activeBlackListOfMe{}
- (void)blockUserInCallnexBlacklist: (NSArray *)blackListArr{}

- (void) pingForConnectToServer{}

- (void)sendRequestRecallToUser: (NSString *)userXmppStr fromUser: (NSString *)fromUser andIdMsg: (NSString *)idMessage{}

// Xoá 1 user ra khỏi roster list
- (void)removeUserFromRosterList: (NSString *)user withIdMessage: (NSString *)idIQ{}

/* Tạo group chat */
- (void)createGroupOfMe: (NSString *)meStr andGroupName: (NSString *)groupName{}

- (void)inviteUserToGroupChat: (NSString *)groupName andListUser: (NSArray *)listUser{}
- (void)setRoleForUserInGroupChat: (NSString *)roomName andListUser: (NSArray *)listUser{}

/* Get số người online trong group */
- (void)getListOnlineOccupantsInGroup: (NSString *)groupName{}

/* Send message cho group */
- (void)sendMessageWithContent: (NSString *)contentMsg ofMe: (NSString *)meStr toGroup: (NSString *)groupName withIdMessage: (NSString *)idMessage{}

/* send location to user */
- (void)sendLocationToUser: (NSString *)user withLat: (float)lat andLng: (float)lng andAddress: (NSString *)address andDescription: (NSString *)description withIdMessage: (NSString *)idMessage{}

/*--Gửi request yêu cầu tracking đến user--*/
- (void)sendTrackingRequestToUser: (NSString *)userStr withLocationInfo: (NSString *)locationInfo{}

/*--Gửi thông tin location nếu chấp nhận--*/
- (void)sendYourLocationToUserRequestTracking: (NSString *)userStr withLocation: (NSString *)locationInfo{}

/*--send message tracking đến user--*/
- (void)sendMessageTrackingToUser: (NSString *)user withContent: (NSString *)content andIdMessage: (NSString *)idMessage{}

/*--Từ chối yêu cầu tracking từ user--*/
- (void)ejectTrackingFromUser: (NSString *)user{}

/*--Gửi update location đến user trong tracking list--*/
- (void)sendUpdateLocationToUser: (NSString *)user andMyLocationInfo: (NSString *)locationInfo{}

- (void)sendMessageToUserInTrackingList: (NSString *)user withContent: (NSString *)contentMessage withId: (NSString *)idMessage{}

/*--Get danh sách user trong room chat--*/
- (void)getListUserInRoomChat: (NSString *)roomName{}
- (void) setLeaveRoomToServer:(NSString *)roomId withId: (NSString *)idIQ{}

/*--Doi ten cua room chat--*/
- (void)changeNameOfTheRoom: (NSString *)roomName withNewName: (NSString *)newName{}

/*--Doi ten subject cua phong--*/
- (void)changeSubjectOfTheRoom: (NSString *)roomName withSubject: (NSString *)subject{}

//  Đổi description của room chat
- (void)changeDescriptionOfTheRoom: (NSString *)roomName withSubject: (NSString *)subject{}

//  Huy OTR voi 1 user
- (void)destroySessionOTRWithUser: (NSString *)user andIdMessage: (NSString *)idMessage{}

- (void)sendRequestOTRToUser: (NSString *)user{}

/*--Chap nhan huy OTR voi mot user--*/
- (void)acceptDestroySessionOTRWithUser: (NSString *)user{}

- (void)refreshRosterList{}

//  Rời khỏi một room chat
- (void)leaveConference: (NSString *)roomName{}

- (void)kickOccupantInRoomChat: (NSString *)roomName withNickName: (NSString *)nickName{}

//  Ban một user khỏi room chat
- (void)banOccupantInRoomChat: (NSString *)roomName withUser: (NSString *)user{}

#pragma mark - MY FUNCTIONS
//  Đồng ý vào group chat
- (void)acceptJoinToRoomChat: (NSString *)roomName{}
- (NSArray*) buddyList
{ 
//    NSMutableSet *otrBuddyListSet = [NSMutableSet set];
//    AIMBlist *blist = self.aimBuddyList;
//    
//    for(AIMBlistGroup *group in blist.groups)
//    {
//        for(AIMBlistBuddy *buddy in group.buddies)
//        {
//            OTRBuddyStatus buddyStatus;
//            
//            switch (buddy.status.statusType) 
//            {
//                case AIMBuddyStatusAvailable:
//                    buddyStatus = kOTRBuddyStatusAvailable;
//                    break;
//                case AIMBuddyStatusAway:
//                    buddyStatus = kOTRBuddyStatusAway;
//                    break;
//                default:
//                    buddyStatus = kOTRBuddyStatusOffline;
//                    break;
//            }
//            
//            OTRBuddy *otrBuddy = [protocolBuddyList objectForKey:buddy.username];
//            
//            if(otrBuddy)
//            {
//                otrBuddy.status = buddyStatus;
//                otrBuddy.groupName = group.name;
//            }
//            else
//            {
//                otrBuddy = [OTRBuddy buddyWithDisplayName:buddy.username accountName:buddy.username protocol:self status:buddyStatus groupName:group.name];
//                [protocolBuddyList setObject:otrBuddy forKey:buddy.username];
//            }
//            [otrBuddyListSet addObject:otrBuddy];
//        }
//    }
//    return [otrBuddyListSet allObjects];
    return nil;
}

- (OTRBuddy *) getBuddyByAccountName:(NSString *)buddyAccountName
{
    if (protocolBuddyList)
        return [protocolBuddyList objectForKey:buddyAccountName];
    else
        return nil;
}

-(void)connectWithPassword:(NSString *)myPassword
{
//    self.login = [[AIMLogin alloc] initWithUsername:account.username password:myPassword];
//    [self.login setDelegate:self];
//    [self.login beginAuthorization];
}
-(void)disconnect
{
//    [[self theSession].session closeConnection];
//    OTRProtocolManager *protocolManager = [OTRProtocolManager sharedInstance];
//    [protocolManager.protocolManagers removeObjectForKey:self.account.uniqueIdentifier];
//    self.protocolBuddyList = nil;
    
}

- (void)requestVCardFromAccount: (NSString *)account {
    
}

- (void)sendMessageImageForGroup: (NSString *)roomName withLinkImage: (NSString *)link andDescription: (NSString *)caption andIdMessage: (NSString *)idMessage{}

- (void)sendMessageMediaForUser: (NSString *)username withLinkImage: (NSString *)link andDescription: (NSString *)caption andIdMessage: (NSString *)idMessage andType: (NSString *)type withBurn: (int)burn forGroup: (BOOL)isGroup{}

- (void)sendDisplayedToUser: (NSString *)toUser fromUser: (NSString *)fromUser andListIdMsg: (NSString *)listIdMsg{}
- (void)getGroupDataFromServer{}
- (void)storeGroupDataToServer:(NSString *)groups{}

@end
