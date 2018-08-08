/* LinphoneAppDelegate.h
 *
 * Copyright (C) 2009  Belledonne Comunications, Grenoble, France
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or   
 *  (at your option) any later version.                                 
 *                                                                      
 *  This program is distributed in the hope that it will be useful,     
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of      
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the       
 *  GNU General Public License for more details.                
 *                                                                      
 *  You should have received a copy of the GNU General Public License   
 *  along with this program; if not, write to the Free Software         
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */                                                                           

#import <UIKit/UIKit.h>
#import <PushKit/PushKit.h>
#import <AddressBookUI/ABPeoplePickerNavigationController.h>

#import "LinphoneCoreSettingsStore.h"
#import "ProviderDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

#import "Reachability.h"
#import "AppStrings.h"
#import "HMLocalization.h"
#import "ContactObject.h"
#import "FMDatabase.h"
#import "XMPPStream.h"
#import "XMPPIncomingFileTransfer.h"
#import "OTRBuddy.h"
#import "NSBubbleData.h"
#import "CallsHistoryViewController.h"
#import "UIView+Toast.h"
#import "WebServices.h"

enum messageState {
    eMessageError,
    eMessageSend,
    eMessageReceive,
};

typedef NS_ENUM(NSUInteger, AuthorType) {
    iMessageBubbleTableViewCellAuthorTypeSender = 0,
    iMessageBubbleTableViewCellAuthorTypeReceiver
};

@interface LinphoneAppDelegate : NSObject <UIApplicationDelegate, PKPushRegistryDelegate, UNUserNotificationCenterDelegate, WebServicesDelegate> {
    @private
	UIBackgroundTaskIdentifier bgStartId;
    BOOL startedInBackground;
}

- (void)registerForNotifications:(UIApplication *)app;

@property (nonatomic, retain) UIAlertController *waitingIndicator;
@property (nonatomic, retain) NSString *configURL;
@property (nonatomic, strong) UIWindow* window;
@property (nonatomic, strong) PKPushRegistry* voipRegistry;
@property (nonatomic, strong) ProviderDelegate *del;


@property (nonatomic, assign) BOOL _internetActive;
@property (strong, nonatomic) Reachability *_internetReachable;
@property (nonatomic, strong) HMLocalization *localization;

@property (nonatomic, assign) float _hRegistrationState;
@property (nonatomic, assign) float _hStatus;
@property (nonatomic, assign) float _hTabbar;
@property (nonatomic, assign) float _hHeader;
@property (nonatomic, assign) float _wSubMenu;

@property (nonatomic, strong) NSString *_deviceToken;
@property (nonatomic, assign) BOOL _updateTokenSuccess;

//  Mảng chứa các emotion
@property (nonatomic, strong) NSMutableArray *_listFace;
@property (nonatomic, strong) NSMutableArray *_listNature;
@property (nonatomic, strong) NSMutableArray *_listObject;
@property (nonatomic, strong) NSMutableArray *_listPlace;
@property (nonatomic, strong) NSMutableArray *_listSymbol;

@property (nonatomic, assign) BOOL _meEnded;

@property (nonatomic, assign) BOOL _acceptCall;

@property (nonatomic, strong) NSMutableArray *listContacts;
@property (nonatomic, strong) NSMutableArray *sipContacts;
@property (nonatomic, strong) NSMutableArray *pbxContacts;
@property (nonatomic, assign) int idContact;

//  Biến kết nối cơ sỏ dữ liệu
@property (nonatomic, strong) FMDatabase *_database;
@property (nonatomic, strong) NSString *_databasePath;
@property (nonatomic, strong) FMDatabase *_threadDatabase;

// Biến cho biết user đang có cuộc gọi (không thể nghe cuộc gọi tiếp theo)
@property (nonatomic, assign) BOOL _busyForCall;
//  Ghi am cuoc goi
@property (nonatomic, strong) NSString *_recordFile;
@property (nonatomic, assign) BOOL _hasRecordCall;

@property (nonatomic, strong, getter=theNewContact) ContactObject *_newContact;

@property (nonatomic, strong) UIImage *_cropAvatar;
@property (nonatomic, strong) NSData *_dataCrop;
// Bien cho biet truoc do o pickerViewController
@property (nonatomic, assign) BOOL fromImagePicker;

@property (nonatomic, assign) BOOL _isSyncing;
@property (nonatomic, assign) BOOL _chooseMyAvatar;

@property (nonatomic, strong) UIImage *userImage;

@property (nonatomic, strong) XMPPStream *xmppStream;
@property (nonatomic, strong) NSString *_resource;
@property (nonatomic, strong) XMPPIncomingFileTransfer *_xmppIncomingFileTransfer;

@property (nonatomic, strong) OTRBuddy *myBuddy;
@property (nonatomic, retain) OTRBuddy *friendBuddy;

//  Biến chứa cloudfone request sent
@property (nonatomic, strong) NSString *_cloudfoneRequestSent;

//  Lưu id và name của room chat
@property (nonatomic, assign) int idRoomChat;
@property (nonatomic, strong) NSString *roomChatName;
@property (nonatomic, strong) NSString *_groupNameChange;

@property (nonatomic, strong) NSMutableArray *_listFriends;

@property (nonatomic, strong) NSMutableDictionary *_statusXMPPDict;

//  Biến lưu id của videoMessage ở màn hình PlayVideo
@property (nonatomic, strong) NSString *idVideoMessage;

//  biến cho biết đang touch vào bubble nào
@property (nonatomic, assign) int typeBubbleTouch;

@property (nonatomic, strong) NSIndexPath *lastRowVisibleChat;
@property (nonatomic, assign) BOOL reloadMessageList;
@property (nonatomic, strong) NSString *titleCaption;
@property (nonatomic, strong) NSString *imageChooseName;
@property (nonatomic, strong) UIImage *imageChoose;

@property (nonatomic, assign) float _heightChatTbView;

// Nội dung message forward
@property (nonatomic, strong) NSBubbleData *_msgForward;
@property (nonatomic, strong) NSString *msgHisForward;
@property (nonatomic, retain) NSString *idMessageRecall;
@property (nonatomic, assign) BOOL imageCapture;

@property (nonatomic, strong) ALAssetsGroup *photoGroup;

@property (nonatomic, strong) NSMutableDictionary *_allPhonesDict;
//  diction mapping giữa contact id và phone number (kể cả cloudfoneiD)
@property (nonatomic, strong) NSMutableDictionary *_allIDDict;

@property (nonatomic, assign) BOOL contactLoaded;
@property (nonatomic, strong) NSString *phoneNumberEnd;

@property (nonatomic, strong) NSString *_strRequestFriend;
@property (nonatomic, assign) BOOL supportGroupChat;
@property (nonatomic, strong, readwrite) NSMutableArray *xmppChatRooms;

@property (nonatomic, strong) NSTimer *bgTimer;

+(LinphoneAppDelegate*) sharedInstance;
@property (nonatomic, strong) WebServices *webService;
@property (nonatomic, strong) NSTimer *keepAwakeTimer;
@end

