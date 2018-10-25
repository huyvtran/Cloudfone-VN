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
#import "CallsHistoryViewController.h"
#import "UIView+Toast.h"
#import "WebServices.h"
#import "Constant.h"

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

@property (nonatomic, assign) BOOL _meEnded;

@property (nonatomic, assign) BOOL _acceptCall;

@property (nonatomic, strong) NSMutableArray *listContacts;
@property (nonatomic, strong) NSMutableArray *pbxContacts;
@property (nonatomic, assign) int idContact;

//  Biến kết nối cơ sỏ dữ liệu
@property (nonatomic, strong) FMDatabase *_database;
@property (nonatomic, strong) NSString *_databasePath;
@property (nonatomic, strong) FMDatabase *_threadDatabase;

// Biến cho biết user đang có cuộc gọi (không thể nghe cuộc gọi tiếp theo)
@property (nonatomic, assign) BOOL _busyForCall;

@property (nonatomic, strong, getter=theNewContact) ContactObject *_newContact;

@property (nonatomic, strong) UIImage *_cropAvatar;
@property (nonatomic, strong) NSData *_dataCrop;
@property (nonatomic, assign) BOOL fromImagePicker;

@property (nonatomic, assign) BOOL _isSyncing;

@property (nonatomic, strong) NSMutableDictionary *_allPhonesDict;
//  diction mapping giữa contact id và phone number (kể cả cloudfoneiD)
@property (nonatomic, strong) NSMutableDictionary *_allIDDict;

@property (nonatomic, assign) BOOL contactLoaded;
@property (nonatomic, strong) NSString *phoneNumberEnd;

+(LinphoneAppDelegate*) sharedInstance;
@property (nonatomic, strong) WebServices *webService;
@property (nonatomic, strong) NSTimer *keepAwakeTimer;

@property (nonatomic, assign) BOOL needToReloadContactList;

@property (nonatomic, strong) NSArray *listNumber;


- (ContactObject *)getContactInPhoneBookWithIdRecord: (int)idRecord;

@end

