///
//  OTRBuddy.m
//  Off the Record
//
//  Created by Chris Ballinger on 9/12/11.
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

#import "OTRBuddy.h"
#import "OTRMessage.h"
#import "OTRCodec.h"
#import "OTRProtocolManager.h"
#import "NSString+HTML.h"
#import "strings.h"
#import "OTRConstants.h"
#import "TURNSocket.h"
#import <AddressBook/AddressBook.h>

@implementation OTRBuddy

@synthesize accountName;
@synthesize displayName;
@synthesize protocol;
@synthesize groupName;
@synthesize status;
@synthesize chatHistory;
@synthesize lastMessage;
@synthesize lastMessageDisconnected;
@synthesize encryptionStatus;
@synthesize chatState;
@synthesize lastSentChatState;
@synthesize pausedChatStateTimer;
@synthesize inactiveChatStateTimer;
@synthesize composingMessageString;
@synthesize SQLite_Database;
@synthesize resourceStr;

- (void) dealloc {
}

-(id)initWithDisplayName:(NSString*)buddyName accountName:(NSString*) buddyAccountName protocol:(id <OTRProtocol>)buddyProtocol status:(OTRBuddyStatus)buddyStatus groupName:(NSString*)buddyGroupName
{
    if(self = [super init])
    {
        self.numberOfMessagesSent = 0;
        self.displayName = buddyName;
        self.accountName = buddyAccountName;
        self.protocol = buddyProtocol;
        self.status = buddyStatus;
        self.groupName = buddyGroupName;
        self.chatHistory = [NSMutableString string];
        self.lastMessage = @"";
        self.lastMessageDisconnected = NO;
        self.encryptionStatus = kOTRKitMessageStatePlaintext;
        self.chatState = kOTRChatStateUnknown;
        self.lastSentChatState = kOTRChatStateUnknown;

        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(protocolDisconnected:) name:kOTRProtocolDiconnect object:buddyProtocol];
    }
    return self;
}

+(OTRBuddy*)buddyWithDisplayName:(NSString*)buddyName accountName:(NSString*) accountName protocol:(id <OTRProtocol>)buddyProtocol status:(OTRBuddyStatus)buddyStatus groupName:(NSString*)buddyGroupName
{
    OTRBuddy *newBuddy = [[OTRBuddy alloc] initWithDisplayName:buddyName accountName:accountName protocol:buddyProtocol status:buddyStatus groupName:buddyGroupName];
    return newBuddy;
}


- (void)sendMessage:(NSString *)message secure:(BOOL)secure withIdMessage: (NSString *)idMessage
{
    if (message) {
        self.numberOfMessagesSent +=1;
        lastMessageDisconnected = NO;
        OTRBuddy* theBuddy = self;
        //message = [message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        OTRMessage *newMessage = [OTRMessage messageWithBuddy:theBuddy message:message];
        OTRMessage *encodedMessage;
        if(secure)
        {
            encodedMessage = [OTRCodec encodeMessage:newMessage];
        }
        else
        {
            encodedMessage = newMessage;
        }
        encodedMessage.idMessage = idMessage;
        [OTRMessage sendMessage:encodedMessage];
    }
}

-(void)sendChatState:(OTRChatState) sendingChatState
{
    if([self.protocol respondsToSelector:@selector(sendChatState:withBuddy:)])
    {
        lastSentChatState = sendingChatState;
        [self.protocol sendChatState:sendingChatState withBuddy:self];
    }
    
}

-(void)sendComposingChatState
{
    if(self.lastSentChatState != kOTRChatStateComposing)
    {
        [self sendChatState:kOTRChatStateComposing];
    }
    [self restartPausedChatStateTimer];
    //[self.inactiveChatStateTimer invalidate];

}
-(void)sendPausedChatState
{
    [self sendChatState:kOTRChatStatePaused];
//    [self.inactiveChatStateTimer invalidate];
}

-(void)sendActiveChatState
{
    //[pausedChatStateTimer invalidate];
    [self restartInactiveChatStateTimer];
    [self sendChatState:kOTRChatStateActive];
}

-(void)sendInactiveChatState
{
    //[self.inactiveChatStateTimer invalidate];
    if(self.lastSentChatState != kOTRChatStateInactive)
        [self sendChatState:kOTRChatStateInactive];
}

-(void)restartPausedChatStateTimer
{
//    [pausedChatStateTimer invalidate];
    pausedChatStateTimer = [NSTimer scheduledTimerWithTimeInterval:kOTRChatStatePausedTimeout target:self selector:@selector(sendPausedChatState) userInfo:nil repeats:NO];
}
-(void)restartInactiveChatStateTimer
{
//    [inactiveChatStateTimer invalidate];
    inactiveChatStateTimer = [NSTimer scheduledTimerWithTimeInterval:kOTRChatStateInactiveTimeout target:self selector:@selector(sendInactiveChatState) userInfo:nil repeats:NO];
}

-(void)receiveStatusMessage:(NSString *)message
{
    if (message) {
        NSString *username = [NSString stringWithFormat:@"<p><strong style=\"color:red\">%@ </strong>",self.displayName];
        [chatHistory appendFormat:@"%@ %@</p>",username,message];
        [[NSNotificationCenter defaultCenter] postNotificationName:MESSAGE_PROCESSED_NOTIFICATION object:self];
    }
}

- (void)receiveChatStateMessage:(OTRChatState) newChatState
{
    self.chatState = newChatState;
    [[NSNotificationCenter defaultCenter] postNotificationName:MESSAGE_PROCESSED_NOTIFICATION object:self];
}

- (void)setStatus:(OTRBuddyStatus)newStatus
{
    if([self.protocol.account.protocol isEqualToString:kOTRProtocolTypeXMPP])
    {
        if ([self.chatHistory length]!=0 && newStatus!=status)
        {
            if( newStatus == 0)
                [self receiveStatusMessage:OFFLINE_MESSAGE_STRING];
            else if (newStatus == 1)
                [self receiveStatusMessage:AWAY_MESSAGE_STRING];
            else if( newStatus == 2)
                [self receiveStatusMessage:AVAILABLE_MESSAGE_STRING];
            
        }
    }
    status = newStatus;
}

- (void) protocolDisconnected:(id)sender
{
    if( [self.chatHistory length]!=0 && !lastMessageDisconnected)
    {
        //[chatHistory appendFormat:@"<p><strong style=\"color:blue\"> You </strong> Disconnected </p>"];
        //[[NSNotificationCenter defaultCenter] postNotificationName:MESSAGE_PROCESSED_NOTIFICATION object:self];
        lastMessageDisconnected = YES;
        self.status = kOTRBuddyStatusOffline;
    }
}

// Cập nhật trạng thái encryption của user
- (void)setEncryptionStatus:(OTRKitMessageState)newEncryptionStatus {
    if (self.encryptionStatus != newEncryptionStatus) {
        switch (newEncryptionStatus) {
            case kOTRKitMessageStatePlaintext:
                [[NSNotificationCenter defaultCenter] postNotificationName:k11DisableEncryption
                                                                    object:self.accountName];
                break;
            case kOTRKitMessageStateEncrypted:
                [[NSNotificationCenter defaultCenter] postNotificationName:k11EnableEncryption
                                                                    object:self.accountName];
                break;
            case kOTRKitMessageStateFinished:
                break;
            default:
                NSLog(@"Unknown Encryption State");
                break;
        }
        encryptionStatus = newEncryptionStatus;
    }
}

#pragma mark - database method

- (NSString*)getCallnexIDFromNSString: (NSString*)string{
    NSRange range = [string rangeOfString:[NSString stringWithFormat:@"@%@", xmpp_cloudfone]];
    return [string substringToIndex: range.location];
}

@end
