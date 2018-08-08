/* DialerViewController.h
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

#import <AVFoundation/AVAudioSession.h>
#import <AudioToolbox/AudioToolbox.h>
#import "NewContactViewController.h"
#import "AllContactListViewController.h"
#import "MainChatViewController.h"
#import "LinphoneManager.h"
#import "PhoneMainView.h"
#import <AVFoundation/AVFoundation.h>
#import "PhoneBookContactCell.h"
#import "NSData+Base64.h"
#import "ViewPopupTrunking.h"
#import <objc/runtime.h>
#import "NSDatabase.h"
#import "ContactDetailObj.h"
#import "UIVIew+Toast.h"
#import "HotlineViewController.h"

#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

@interface DialerView (){
    float wIcon;
    float hBgNumber;
    float minus;
    
    UIFont *textFont;
    
    NSMutableArray *listPhoneSearched;
    float heightTableCell;
    
    UITapGestureRecognizer *tapOnScreen;
    
    ViewPopupTrunking *popupTrunking;
    BOOL showResult;
    NSAttributedString *firstContactName;
    float viewSearchHeight;
    
    NSTimer *pressTimer;
    int totalAccount;
    int curIndex;
    int typeAccountChoosed;
    BOOL nextStepPBX;
    int stateLogin;
}
@end

@implementation DialerView
@synthesize _viewStatus, _imgLogoSmall, _lbAccount, _lbStatus;
@synthesize _viewNumber, _bgNumber, _iconClear;
@synthesize _viewFooter, _viewCallButton, _btnHotline;
@synthesize _btnAddCall, _btnTransferCall;
@synthesize _viewSearch, _imgAvatar, _lbName, _lbSepa, _btnSearchNum, _iconShowSearch, _tbSearch, _lbPhone;

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
	if (compositeDescription == nil) {
		compositeDescription = [[UICompositeViewDescription alloc] init:self.class
															  statusBar:StatusBarView.class
																 tabBar:TabBarView.class
															   sideMenu:SideMenuView.class
															 fullscreen:false
														 isLeftFragment:YES
														   fragmentWith:nil];
		compositeDescription.darkBackground = true;
	}
	return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
	return self.class.compositeViewDescription;
}

#pragma mark - ViewController Functions

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    typeAccountChoosed = 0;
    
    //  Add new by Khai Le on 23/02/2018
    LinphoneProxyConfig *defaultConfig = linphone_core_get_default_proxy_config(LC);
    const char *proxyUsername = linphone_address_get_username(linphone_proxy_config_get_identity_address(defaultConfig));
    NSString* defaultUsername = [NSString stringWithFormat:@"%s" , proxyUsername];
    if (defaultUsername != nil && ![defaultUsername hasPrefix:@"778899"]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:callnexPBXFlag];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSString *pbxUsername = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_USERNAME];
        _lbAccount.text = pbxUsername;
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:callnexPBXFlag];
        [[NSUserDefaults standardUserDefaults] synchronize];
        _lbAccount.text = USERNAME;
    }
    //  -----------
    
    //  setup cho key login
    [[LinphoneManager instance] lpConfigSetBool:FALSE forKey:@"enable_first_login_view_preference"];
    
    // Tắt màn hình cảm biến
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled: false];
    
    // Login xmpp neu chua connected
    if (![LinphoneAppDelegate sharedInstance].xmppStream.isConnected) {
        [AppUtils reconnectToXMPPServer];
    }
    
    //  setup sound và vibrate của cuộc gọi cho user hiện tại
    [self setupSoundAndVibrateForCallOfUser];
    
    // invisible icon add contact & icon delete address
    _viewSearch.hidden = YES;
    _tbSearch.hidden = YES;
    _addContactButton.hidden = YES;
    _iconClear.hidden = YES;
    _addressField.text = @"";
    
    [self movingDownAddressFieldNumber];
    
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
        
        minus = 10.0;
        wIcon = 40.0;
        hBgNumber = SCREEN_WIDTH * 332/1280;
        _bgNumber.image = [UIImage imageNamed:@"bg_number_ip4.png"];
    }else{
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:15.0];
        
        minus = 10.0;
        wIcon = 30.0;
        hBgNumber = SCREEN_WIDTH * 445/1280;
        _bgNumber.image = [UIImage imageNamed:@"bg_number.png"];
    }
    _lbAccount.text = USERNAME;
    [self setupUIForView];
    
    //  Cập nhật token push
    if (![LinphoneAppDelegate sharedInstance]._updateTokenSuccess && [LinphoneAppDelegate sharedInstance]._deviceToken != nil && ![[LinphoneAppDelegate sharedInstance]._deviceToken isEqualToString: @""]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:updateTokenForXmpp
                                                            object:nil];
    }
    
	_padView.hidden =
		!IPAD && UIInterfaceOrientationIsLandscape(PhoneMainView.instance.mainViewController.currentOrientation);

	// Set observer
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(callUpdateEvent:)
											   name:kLinphoneCallUpdate object:nil];

	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(coreUpdateEvent:)
											   name:kLinphoneCoreUpdate object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPopupWhenCallFailed:)
                                                 name:@"showPopupWhenCallFail" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPopupNotPBX)
                                                 name:@"showPopupNotPBX" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registrationStateUpdate:)
                                                 name:k11RegistrationUpdate object:nil];
    
    //  KHi chọn tài khoản trong popup account
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenSelectAccountForRegister:)
                                                 name:registerWithAccount object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkDown)
                                                 name:@"NetworkDown" object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(registrationUpdateEvent:)
                                               name:kLinphoneRegistrationUpdate object:nil];
    
	// Update on show
	LinphoneCall *call = linphone_core_get_current_call(LC);
    LinphoneManager *mgr = LinphoneManager.instance;
	LinphoneCallState state = (call != NULL) ? linphone_call_get_state(call) : 0;
	[self callUpdate:call state:state];

	if (IPAD) {
		BOOL videoEnabled = linphone_core_video_display_enabled(LC);
		BOOL previewPref = [mgr lpConfigBoolForKey:@"preview_preference"];

		if (videoEnabled && previewPref) {
			linphone_core_set_native_preview_window_id(LC, (__bridge void *)(_videoPreview));

			if (!linphone_core_video_preview_enabled(LC)) {
				linphone_core_enable_video_preview(LC, TRUE);
			}
            _backgroundView.hidden = NO;
			_videoCameraSwitch.hidden = NO;
		} else {
			linphone_core_set_native_preview_window_id(LC, NULL);
			linphone_core_enable_video_preview(LC, FALSE);
            _backgroundView.hidden = YES;
            _videoCameraSwitch.hidden = YES;
		}
	} else {
		linphone_core_enable_video_preview(LC, FALSE);
	}
    
    [self enableNAT];
    
    // setup account khi có và ko có PBX
    NSNumber *pbxFlag = [[NSUserDefaults standardUserDefaults] objectForKey: callnexPBXFlag];
    if (pbxFlag == nil || [pbxFlag intValue] == 0) {
        _lbAccount.text = USERNAME;
    }else{
        NSString *pbxAccount = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_USERNAME];
        if (pbxAccount == nil || [pbxAccount isEqualToString:@""]) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0]
                                                      forKey:callnexPBXFlag];
            [[NSUserDefaults standardUserDefaults] synchronize];
            _lbAccount.text = USERNAME;
        }else{
            _lbAccount.text = pbxAccount;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[NSNotificationCenter.defaultCenter removeObserver:self];
}

// Hàm trả về đường dẫn đến file record
- (NSURL *)getUrlOfRecordFile: (NSString *)fileName{
    NSString *appFolderPath = [[NSBundle mainBundle] resourcePath];
    NSString *path = [NSString stringWithFormat:@"%@/%@", appFolderPath, fileName];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath: path];
    if (!fileExists) {
        return nil;
    }else{
        return [[NSURL alloc] initFileURLWithPath: path];
    }
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
    //  my code here
    _zeroButton.digit = '0';
    _oneButton.digit = '1';
    _twoButton.digit = '2';
    _threeButton.digit = '3';
    _fourButton.digit = '4';
    _fiveButton.digit = '5';
    _sixButton.digit = '6';
    _sevenButton.digit = '7';
    _eightButton.digit = '8';
    _nineButton.digit = '9';
    _starButton.digit = '*';
    _hashButton.digit = '#';
    
    _addressField.adjustsFontSizeToFitWidth = YES;
	
	UILongPressGestureRecognizer *backspaceLongGesture =
		[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onBackspaceLongClick:)];
	[_backspaceButton addGestureRecognizer:backspaceLongGesture];

	UILongPressGestureRecognizer *zeroLongGesture =
		[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onZeroLongClick:)];
	[_zeroButton addGestureRecognizer:zeroLongGesture];

	UILongPressGestureRecognizer *oneLongGesture =
		[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onOneLongClick:)];
	[_oneButton addGestureRecognizer:oneLongGesture];
	
    //  Tap tren ban phim
	tapOnScreen = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboards)];
    tapOnScreen.delegate = self;
	[self.view addGestureRecognizer: tapOnScreen];

	if (IPAD) {
		if (LinphoneManager.instance.frontCamId != nil) {
			// only show camera switch button if we have more than 1 camera
            _videoCameraSwitch.hidden = YES;
		}
	}
    
    heightTableCell = 55.0;
    _lbStatus.text = @"";
    
    // Kiểm tra folder chứa ảnh và tạo list emotion
    [self setupForFirstLoadApp];
    //  [self firstLoadSettingForAccount];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
										 duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	switch (toInterfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			[_videoPreview setTransform:CGAffineTransformMakeRotation(0)];
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			[_videoPreview setTransform:CGAffineTransformMakeRotation(M_PI)];
			break;
		case UIInterfaceOrientationLandscapeLeft:
			[_videoPreview setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
			break;
		case UIInterfaceOrientationLandscapeRight:
			[_videoPreview setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
			break;
		default:
			break;
	}
	CGRect frame = self.view.frame;
	frame.origin = CGPointMake(0, 0);
	_videoPreview.frame = frame;
	_padView.hidden = !IPAD && UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
	if (linphone_core_get_calls_nb(LC)) {
		_backButton.hidden = NO;
		_addContactButton.hidden = YES;
	} else {
		_backButton.hidden = YES;
		_addContactButton.hidden = NO;
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[LinphoneManager.instance shouldPresentLinkPopup];
}

#pragma mark - Event Functions

- (void)callUpdateEvent:(NSNotification *)notif {
	LinphoneCall *call = [[notif.userInfo objectForKey:@"call"] pointerValue];
	LinphoneCallState state = [[notif.userInfo objectForKey:@"state"] intValue];
	[self callUpdate:call state:state];
}

- (void)coreUpdateEvent:(NSNotification *)notif {
	if (IPAD) {
		if (linphone_core_video_display_enabled(LC) && linphone_core_video_preview_enabled(LC)) {
			linphone_core_set_native_preview_window_id(LC, (__bridge void *)(_videoPreview));
            _backgroundView.hidden = NO;
            _videoCameraSwitch.hidden = NO;
		} else {
			linphone_core_set_native_preview_window_id(LC, NULL);
            _backgroundView.hidden = YES;
            _videoCameraSwitch.hidden = YES;
		}
	}
}

#pragma mark - Debug Functions

- (BOOL)displayDebugPopup:(NSString *)address {
	LinphoneManager *mgr = LinphoneManager.instance;
	NSString *debugAddress = [mgr lpConfigStringForKey:@"debug_popup_magic" withDefault:@""];
	if (![debugAddress isEqualToString:@""] && [address isEqualToString:debugAddress]) {
		UIAlertController *errView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Debug", nil)
																		 message:NSLocalizedString(@"Choose an action", nil)
																  preferredStyle:UIAlertControllerStyleAlert];
		
		UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
																style:UIAlertActionStyleDefault
															  handler:^(UIAlertAction * action) {}];
		
		[errView addAction:defaultAction];

		int debugLevel = [LinphoneManager.instance lpConfigIntForKey:@"debugenable_preference"];
		BOOL debugEnabled = (debugLevel >= ORTP_DEBUG && debugLevel < ORTP_ERROR);

		if (debugEnabled) {
			
		}
		NSString *actionLog =
			(debugEnabled ? NSLocalizedString(@"Disable logs", nil) : NSLocalizedString(@"Enable logs", nil));
		
		UIAlertAction* logAction = [UIAlertAction actionWithTitle:actionLog
															style:UIAlertActionStyleDefault
														  handler:^(UIAlertAction * action) {
																   int newDebugLevel = debugEnabled ? 0 : ORTP_DEBUG;
																   [LinphoneManager.instance lpConfigSetInt:newDebugLevel forKey:@"debugenable_preference"];
																   //   [Log enableLogs:newDebugLevel];
															   }];
		[errView addAction:logAction];
		
		UIAlertAction* remAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Remove account(s) and self destruct", nil)
															style:UIAlertActionStyleDefault
														  handler:^(UIAlertAction * action) {
															  linphone_core_clear_proxy_config([LinphoneManager getLc]);
															  linphone_core_clear_all_auth_info([LinphoneManager getLc]);
															  @try {
																  [LinphoneManager.instance destroyLinphoneCore];
															  } @catch (NSException *e) {
																  NSLog(@"Exception while destroying linphone core: %@", e);
															  } @finally {
																  if ([NSFileManager.defaultManager
																	   isDeletableFileAtPath:[LinphoneManager documentFile:@"linphonerc"]] == YES) {
																	  [NSFileManager.defaultManager
																	   removeItemAtPath:[LinphoneManager documentFile:@"linphonerc"]
																	   error:nil];
																  }
#ifdef DEBUG
																  [LinphoneManager instanceRelease];
#endif
															  }
															  [UIApplication sharedApplication].keyWindow.rootViewController = nil;
															  // make the application crash to be sure that user restart it properly
															  NSLog(@"Self-destructing in 3..2..1..0!");
														  }];
		[errView addAction:remAction];
		
		[self presentViewController:errView animated:YES completion:nil];
		return true;
	}
	return false;
}

#pragma mark -

- (void)callUpdate:(LinphoneCall *)call state:(LinphoneCallState)state {
    LinphoneCore *lc = [LinphoneManager getLc];
    // ở keypad mà số cuộc gọi lớn hơn 0 nghĩa là đang add call cho conference hoặc transfer
    if(linphone_core_get_calls_nb(lc) > 0) {
        if (LinphoneManager.instance.nextCallIsTransfer) {
            _btnAddCall.hidden = YES;
            _btnTransferCall.hidden = NO;
        }else {
            _btnAddCall.hidden = NO;
            _btnTransferCall.hidden = YES;
        }
        _callButton.hidden = YES;
        _backButton.hidden = NO;
        _btnHotline.hidden = YES;
    } else {
        _btnAddCall.hidden = YES;
        _btnTransferCall.hidden = YES;
        _btnHotline.hidden = NO;
        _callButton.hidden = NO;
        _backButton.hidden = YES;
    }
    
    /*  Leo Kelvin
	BOOL callInProgress = (linphone_core_get_calls_nb(LC) > 0);
	_addContactButton.hidden = callInProgress;
	_backButton.hidden = !callInProgress;
    */
    
    //  Close by Khai Le on 06/10/2017
	//  [_callButton updateIcon];
}

- (void)setAddress:(NSString *)address {
    _addressField.text = address;
}

#pragma mark - UITextFieldDelegate Functions

- (BOOL)textField:(UITextField *)textField
	shouldChangeCharactersInRange:(NSRange)range
				replacementString:(NSString *)string {
    [self performSelector:@selector(searchPhoneBookWithThread) withObject:nil afterDelay:0.25];
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == _addressField) {
		[_addressField resignFirstResponder];
	}
	if (textField.text.length > 0) {
		LinphoneAddress *addr = [LinphoneUtils normalizeSipOrPhoneAddress:textField.text];
		[LinphoneManager.instance call:addr];
		if (addr)
			linphone_address_destroy(addr);
	}
	return YES;
}

#pragma mark - MFComposeMailDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError *)error {
	[controller dismissViewControllerAnimated:TRUE
								   completion:^{
								   }];
	[self.navigationController setNavigationBarHidden:TRUE animated:FALSE];
}

#pragma mark - Action Functions

- (IBAction)onAddContactClick:(id)event {
    if ([_addressField.text isEqualToString:USERNAME]) {
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"You can not add yourself to contact list"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    UIActionSheet *popupAddContact = [[UIActionSheet alloc] initWithTitle:_addressField.text delegate:self cancelButtonTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_cancel] destructiveButtonTitle:nil otherButtonTitles:
                            [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_add_new_contact],
                            [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_add_exists_contact],
                            nil];
    popupAddContact.tag = 100;
    [popupAddContact showInView:self.view];
}

- (IBAction)onBackClick:(id)event {
	[PhoneMainView.instance popToView:CallView.compositeViewDescription];
}

- (IBAction)onAddressChange:(id)sender {
	if ([self displayDebugPopup:_addressField.text]) {
		_addressField.text = @"";
	}
	_addContactButton.enabled = _backspaceButton.enabled = ([[_addressField text] length] > 0);
    if ([_addressField.text length] == 0) {
        [self.view endEditing:YES];
    }
}

- (IBAction)onBackspaceClick:(id)sender {
    if (_addressField.text.length > 0) {
        _addressField.text = [_addressField.text substringToIndex:[_addressField.text length] - 1];
    }
	
    //kiem tra do dai so nhap vao
    if (_addressField.text.length > 0) {
        [pressTimer invalidate];
        pressTimer = nil;
        pressTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self
                                                    selector:@selector(searchPhoneBookWithThread)
                                                    userInfo:nil repeats:false];
    }else{
        _iconClear.hidden = YES;
        _addContactButton.hidden = YES;
        
        showResult = false;
        [self setPhoneBookHidden];
        [_iconShowSearch setBackgroundImage:[UIImage imageNamed:@"phonebook_open.png"]
                                   forState:UIControlStateNormal];
    }
}

- (void)onBackspaceLongClick:(id)sender {
    _addressField.text = @"";
    _iconClear.hidden = YES;
    _addContactButton.hidden = YES;
    _viewSearch.hidden = YES;
    _tbSearch.hidden = YES;
    showResult = NO;
    [_iconShowSearch setBackgroundImage:[UIImage imageNamed:@"phonebook_open.png"]
                               forState:UIControlStateNormal];
    
    [self movingDownAddressFieldNumber];
}

- (void)onZeroLongClick:(id)sender {
	// replace last character with a '+'
	NSString *newAddress =
		[[_addressField.text substringToIndex:[_addressField.text length] - 1] stringByAppendingString:@"+"];
	[_addressField setText:newAddress];
	linphone_core_stop_dtmf(LC);
}

- (void)onOneLongClick:(id)sender {
	LinphoneManager *lm = LinphoneManager.instance;
	NSString *voiceMail = [lm lpConfigStringForKey:@"voice_mail_uri"];
	LinphoneAddress *addr = [LinphoneUtils normalizeSipOrPhoneAddress:voiceMail];
	if (addr) {
		linphone_address_set_display_name(addr, NSLocalizedString(@"Voice mail", nil).UTF8String);
		[lm call:addr];
		linphone_address_destroy(addr);
	} else {
		NSLog(@"Cannot call voice mail because URI not set or invalid!");
	}
	linphone_core_stop_dtmf(LC);
}

- (void)dismissKeyboards {
	[self.addressField resignFirstResponder];
}

- (IBAction)_btnAddCallPressed:(UIButton *)sender {
    LinphoneManager.instance.nextCallIsTransfer = NO;
    
    NSString *address = _addressField.text;
    if (address.length == 0) {
        LinphoneCallLog *log = linphone_core_get_last_outgoing_call_log(LC);
        if (log) {
            LinphoneAddress *to = linphone_call_log_get_to(log);
            const char *domain = linphone_address_get_domain(to);
            char *bis_address = NULL;
            LinphoneProxyConfig *def_proxy = linphone_core_get_default_proxy_config(LC);
            
            // if the 'to' address is on the default proxy, only present the username
            if (def_proxy) {
                const char *def_domain = linphone_proxy_config_get_domain(def_proxy);
                if (def_domain && domain && !strcmp(domain, def_domain)) {
                    bis_address = ms_strdup(linphone_address_get_username(to));
                }
            }
            if (bis_address == NULL) {
                bis_address = linphone_address_as_string_uri_only(to);
            }
            [_addressField setText:[NSString stringWithUTF8String:bis_address]];
            ms_free(bis_address);
            // return after filling the address, let the user confirm the call by pressing again
            return;
        }
    }
    
    if ([address length] > 0) {
        LinphoneAddress *addr = [LinphoneUtils normalizeSipOrPhoneAddress:address];
        [LinphoneManager.instance call:addr];
        if (addr)
            linphone_address_destroy(addr);
    }
}

- (IBAction)_btnTransferPressed:(UIButton *)sender {
    if (![_addressField.text isEqualToString:@""]) {
        LinphoneManager.instance.nextCallIsTransfer = YES;
        LinphoneAddress *addr = linphone_core_interpret_url(LC, _addressField.text.UTF8String);
        [LinphoneManager.instance call:addr];
        if (addr)
            linphone_address_destroy(addr);
    }
}

- (IBAction)_btnHotlinePressed:(UIButton *)sender {
    LinphoneManager.instance.nextCallIsTransfer = NO;

    LinphoneAddress *addr = [LinphoneUtils normalizeSipOrPhoneAddress:hotline];
    [LinphoneManager.instance call:addr];
    if (addr)
        linphone_address_destroy(addr);
    
    //  [[PhoneMainView instance] changeCurrentView:[HotlineViewController compositeViewDescription] push:YES];
}

- (IBAction)_iconClearClicked:(UIButton *)sender {
    _addressField.text = @"";
    _iconClear.hidden = YES;
    _addContactButton.hidden = YES;
    _viewSearch.hidden = YES;
    _tbSearch.hidden = YES;
    showResult = NO;
    [_iconShowSearch setBackgroundImage:[UIImage imageNamed:@"phonebook_open.png"]
                               forState:UIControlStateNormal];
    
    [self movingDownAddressFieldNumber];
}

- (IBAction)_btnNumberPressed:(id)sender {
    [self.view endEditing: true];
    
    [self searchPhoneBookWithThread];
}

- (IBAction)_btnCallPressed:(UIButton *)sender {
    
}

#pragma mark - Khai Le Functions

//  setup sound và vibrate của cuộc gọi cho user hiện tại
- (void)setupSoundAndVibrateForCallOfUser {
    //  Âm thanh cho cuộc gọi
    NSString *soundCallKey = [NSString stringWithFormat:@"%@_%@", key_sound_call, USERNAME];
    NSString *soundCallValue = [[NSUserDefaults standardUserDefaults] objectForKey: soundCallKey];
    if (soundCallValue == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:text_yes forKey: soundCallKey];
    }
    
    //  Âm thanh cho tin nhắn
    NSString *soundMsgKey = [NSString stringWithFormat:@"%@_%@", key_sound_message, USERNAME];
    NSString *soundMsgValue = [[NSUserDefaults standardUserDefaults] objectForKey: soundMsgKey];
    if (soundMsgValue == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:text_yes forKey: soundMsgKey];
    }
    
    //  Rung cho tin nhắn
    NSString *vibrateMsgKey = [NSString stringWithFormat:@"%@_%@", key_vibrate_message, USERNAME];
    NSString *vibrateValue = [[NSUserDefaults standardUserDefaults] objectForKey: vibrateMsgKey];
    if (vibrateValue == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:text_yes forKey:vibrateMsgKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)networkDown {
    _lbStatus.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_status_offline];
    _lbStatus.textColor = UIColor.orangeColor;
}

//  Đóng và mở kết quả seach
- (void)showSearchResultPressed:(id)sender {
    if (showResult == NO) {
        _tbSearch.hidden = NO;
        if (listPhoneSearched.count > 0) {
            [self setHeightForTableSearchResult: [listPhoneSearched count]];
        }
        showResult = YES;
        [_iconShowSearch setBackgroundImage:[UIImage imageNamed:@"phonebook_open.png"]
                                   forState:UIControlStateNormal];
    }else{
        _tbSearch.hidden = YES;
        showResult = NO;
        [_iconShowSearch setBackgroundImage:[UIImage imageNamed:@"phonebook_close.png"]
                                   forState:UIControlStateNormal];
    }
}

//  Set chiều cao cho table search result
- (void)setHeightForTableSearchResult: (long)searchCount {
    float maxHeight = _padView.frame.size.height;
    if (searchCount*heightTableCell > maxHeight) {
        [_tbSearch setFrame: _padView.frame];
        [_tbSearch setScrollEnabled: YES];
    }else{
        CGRect newFrame = CGRectMake(_padView.frame.origin.x, _padView.frame.origin.y, _padView.frame.size.width, searchCount*heightTableCell);
        [_tbSearch setFrame: newFrame];
        [_tbSearch setScrollEnabled: NO];
    }
    [_tbSearch reloadData];
}

//  Di chuyển addressField khi search có kết quả
- (void)movingUpAddressFieldNumber {
    float tmpHeight = _viewNumber.frame.size.height-_viewSearch.frame.size.height;
    [_addressField setFrame: CGRectMake(_addressField.frame.origin.x, (tmpHeight-_addressField.frame.size.height)/2, _addressField.frame.size.width, _addressField.frame.size.height)];
    [_addContactButton setFrame: CGRectMake(_addContactButton.frame.origin.x, (tmpHeight-_addContactButton.frame.size.height)/2, _addContactButton.frame.size.width, _addContactButton.frame.size.height)];
    [_iconClear setFrame: CGRectMake(_iconClear.frame.origin.x, _addContactButton.frame.origin.y, _iconClear.frame.size.width, _iconClear.frame.size.height)];
}

- (void)searchPhoneBookWithThread {
    NSString *searchStr = _addressField.text;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if (listPhoneSearched == nil) {
            listPhoneSearched = [[NSMutableArray alloc] init];
        }
        [listPhoneSearched removeAllObjects];
        
        //  search name
        [self searchForContactName: searchStr];
        
        NSArray *cleanedArray = [[NSSet setWithArray: listPhoneSearched] allObjects];
        [listPhoneSearched removeAllObjects];
        [listPhoneSearched addObjectsFromArray: cleanedArray];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self afterGetContactPhoneBookSuccessfully];
        });
    });
}

- (void)searchForContactName: (NSString *)search {
    NSArray *allName = [[LinphoneAppDelegate sharedInstance]._allPhonesDict allValues];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", search];
    NSArray *filter = [allName filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        [listPhoneSearched addObjectsFromArray: filter];
    }
}

// Search duoc danh sach
- (void)afterGetContactPhoneBookSuccessfully
{
    if ([_addressField.text length] == 0) {
        [self setPhoneBookHidden];
        
        showResult = false;
        _addContactButton.hidden = YES;
        _iconClear.hidden = YES;
        [_iconShowSearch setBackgroundImage:[UIImage imageNamed:@"phonebook_open.png"]
                                   forState:UIControlStateNormal];
    }else{
        _iconClear.hidden = NO;
        _addContactButton.hidden = NO;
        
        _tbSearch.frame = CGRectMake(_padView.frame.origin.x, _padView.frame.origin.y, _padView.frame.size.width, 0);
        if (listPhoneSearched.count > 0) {
            NSString *value = [listPhoneSearched objectAtIndex: 0];
            
            NSArray *tmpArr = [value componentsSeparatedByString:@"|"];
            if (tmpArr.count >= 3) {
                NSString *name = [tmpArr firstObject];
                NSString *phone = [tmpArr lastObject];
                
                // Tô màu cho tên contact đầu tiên được tìm thấy
                NSMutableAttributedString *nameColor = [[NSMutableAttributedString alloc] initWithString: name];
                NSString *nameForSearch = [tmpArr objectAtIndex: 1];
                NSRange firstRange = [nameForSearch rangeOfString: _addressField.text options:NSCaseInsensitiveSearch];
                
                if (firstRange.location != NSNotFound) {
                    [nameColor addAttribute:NSForegroundColorAttributeName
                                      value:[UIColor colorWithRed:(244/255.0) green:(179/255.0)
                                                             blue:(15/255.0) alpha:1.0]
                                      range:NSMakeRange(firstRange.location, _addressField.text.length)];
                    firstContactName = nameColor;
                    _lbName.attributedText = firstContactName;
                }else{
                    _lbName.text = name;
                }
                
                //  to mau cho phone number
                NSMutableAttributedString *phoneColor = [[NSMutableAttributedString alloc] initWithString: phone];
                NSRange phoneRange = [phone rangeOfString: _addressField.text options:NSCaseInsensitiveSearch];

                if (phoneRange.location != NSNotFound) {
                    [phoneColor addAttribute:NSForegroundColorAttributeName
                                      value:[UIColor colorWithRed:(244/255.0) green:(179/255.0)
                                                             blue:(15/255.0) alpha:1.0]
                                      range:NSMakeRange(phoneRange.location, _addressField.text.length)];
                    _lbPhone.attributedText = phoneColor;
                }else{
                    _lbPhone.text = phone;
                }
                
                // setup avatar
                NSString *avatar = [NSDatabase getAvatarOfContactWithPhoneNumber: phone];
                if (![avatar isEqualToString:@""]) {
                    _imgAvatar.image = [UIImage imageWithData:[NSData dataFromBase64String: avatar]];
                }else{
                    _imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
                }
            }
            _viewSearch.hidden = NO;
            
            [_btnSearchNum setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)listPhoneSearched.count]
                           forState:UIControlStateNormal];
            [_btnSearchNum addTarget:self
                              action:@selector(showSearchResultPressed:)
                    forControlEvents:UIControlEventTouchUpInside];
            [_iconShowSearch setBackgroundImage:[UIImage imageNamed:@"phonebook_close.png"]
                                       forState:UIControlStateNormal];
            [_iconShowSearch addTarget:self
                                action:@selector(showSearchResultPressed:)
                      forControlEvents:UIControlEventTouchUpInside];
            _tbSearch.hidden = YES;

            viewSearchHeight = 40.0;
            _viewSearch.frame = CGRectMake(_viewSearch.frame.origin.x, _viewNumber.frame.size.height-viewSearchHeight, _viewSearch.frame.size.width, viewSearchHeight);
            _imgAvatar.clipsToBounds = YES;
            _imgAvatar.layer.cornerRadius = _imgAvatar.frame.size.height/2;
            
            [self movingUpAddressFieldNumber];
        }else{
            [self movingDownAddressFieldNumber];
            
            _tbSearch.hidden = YES;
            _viewSearch.hidden = YES;
        }
    }
}

- (void)registrationStateUpdate: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[NSNumber class]]) {
        LinphoneRegistrationState state = [object intValue];
        switch (state) {
            case LinphoneRegistrationOk:{
                if (typeAccountChoosed == 1) {
                    [_lbStatus setText:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_status_online]];
                    [_lbStatus setTextColor:[UIColor greenColor]];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0]
                                                              forKey:callnexPBXFlag];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [_lbAccount setText: USERNAME];
                }else if (typeAccountChoosed == 2){
                    if (!nextStepPBX) {
                        nextStepPBX = YES;
                        
                        NSString *pbxUsername = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_USERNAME];
                        NSString *pbxPassword = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_PASSWORD];
                        NSString *ipAddress = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_IP_ADDRESSS];
                        NSString *pbxPort = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_PORT];
                        [self registerPBXAccount: pbxUsername password: pbxPassword ipAddress: ipAddress port: pbxPort];
                    }else{
                        [_lbStatus setText:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_status_online]];
                        [_lbStatus setTextColor:[UIColor greenColor]];
                        
                        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1]
                                                                                      forKey:callnexPBXFlag];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        NSString *pbxUsername = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_USERNAME];
                        [_lbAccount setText: pbxUsername];
                    }
                }else{
                    [_lbStatus setText:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_status_online]];
                    [_lbStatus setTextColor:[UIColor greenColor]];
                }
                
                break;
            }
            case LinphoneRegistrationProgress:{
                [_lbStatus setText:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_status_connecting]];
                [_lbStatus setTextColor:[UIColor whiteColor]];
                break;
            }
            case LinphoneRegistrationNone:
            case LinphoneRegistrationCleared:
            case LinphoneRegistrationFailed:{
                NSLog(@"LinphoneRegistrationFailed");
//                if (curIndex == totalAccount && totalAccount > 0) {
//                    if (stateLogin == 1) {
//                        //  Nếu chọn login SIP mà bị thất bại
//                        [self networkDown];
//                        [_lbAccount setText: USERNAME];
//                    }else if (stateLogin == 2){
//                        //  Nếu chọn login PBX mà bị thất bại
//                        [self networkDown];
//                        NSString *pbxUsername = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_USERNAME];
//                        [_lbAccount setText: pbxUsername];
//
//                        [self removeProxyConfigWithAccount: pbxUsername];
//                        [self setDefaultProxyConfigWithAccount:USERNAME];
//                    }else{
//                        if (typeAccountChoosed == 1) {
//                            stateLogin = 1;
//                        }else if (typeAccountChoosed == 2){
//                            stateLogin = 2;
//                        }
//                        [self reloginToSipAccount];
//                    }
//                }else{
//                    curIndex++;
//                }
                break;
            }
            default:
                break;
        }
    }
}


//  Tap để chọn account
- (void)showPopupRegistrationOnView {
    popupTrunking = [[ViewPopupTrunking alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 268)/2, (SCREEN_HEIGHT-163)/2 , 268, 163)];
    [popupTrunking._btnRefresh addTarget:self
                                  action:@selector(refreshTrunking)
                        forControlEvents:UIControlEventTouchUpInside];
    
    [popupTrunking showInView:[LinphoneAppDelegate sharedInstance].window animated:true];
}

//  refresh
- (void)refreshTrunking {
    [popupTrunking fadeOut];
    
    linphone_core_refresh_registers([LinphoneManager getLc]);
}

- (void)enableNAT
{
    LinphoneNatPolicy *LNP = linphone_core_get_nat_policy(LC);
    linphone_nat_policy_enable_ice(LNP, FALSE);
}

// Hiển thị thông báo khi gọi thất bại
- (void)showPopupWhenCallFailed: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[NSString class]]) {
        [self.view makeToast:object duration:2.5 position:CSToastPositionCenter];
    }
}

- (void)showPopupNotPBX {
    [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_not_setup_pbx]
                duration:2.5 position:CSToastPositionCenter];
}

- (void)setupUIForView
{
    //  view status
    _viewStatus.frame = CGRectMake(0, 0, SCREEN_WIDTH, [LinphoneAppDelegate sharedInstance]._hRegistrationState);
    _viewStatus.backgroundColor = [UIColor colorWithRed:(21/255.0) green:(41/255.0)
                                                   blue:(52/255.0) alpha:1.0];
    
    float hStatus = _viewStatus.frame.size.height;
    [_imgLogoSmall setFrame: CGRectMake(hStatus/4, hStatus/4, hStatus/2, hStatus/2)];
    
    [_lbAccount setFrame: CGRectMake((_viewStatus.frame.size.width-150)/2, 0, 150, hStatus)];
    [_lbAccount setFont: [UIFont fontWithName:MYRIADPRO_BOLD size:18.0]];
    [_lbAccount setTextAlignment: NSTextAlignmentCenter];
    
    [_lbStatus setFrame: CGRectMake(_viewStatus.frame.size.width/2, 0, _viewStatus.frame.size.width/2-_imgLogoSmall.frame.origin.x, _viewStatus.frame.size.height)];
    [_lbStatus setFont: textFont];
    
    //  Tap tren trang thai
    [_lbStatus setUserInteractionEnabled: true];
    UITapGestureRecognizer *tapOnStatus = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPopupRegistrationOnView)];
    [_lbStatus addGestureRecognizer: tapOnStatus];
    
    //  Number view
    [_viewNumber setFrame: CGRectMake(0, _viewStatus.frame.origin.y+_viewStatus.frame.size.height, SCREEN_WIDTH, hBgNumber)];
    [_bgNumber setFrame: CGRectMake(0, 0, _viewNumber.frame.size.width, _viewNumber.frame.size.height)];
    [_addContactButton setFrame: CGRectMake(10, (hBgNumber-wIcon)/2, wIcon, wIcon)];
    [_addressField setFrame:CGRectMake(_addContactButton.frame.origin.x+_addContactButton.frame.size.width+10, 10, _viewNumber.frame.size.width-(_addContactButton.frame.origin.x+10+_addContactButton.frame.size.width+10+_addContactButton.frame.size.width+_addContactButton.frame.origin.x), hBgNumber-20)];
    [_addressField setKeyboardType: UIKeyboardTypePhonePad];
    [_addressField setEnabled: true];
    [_addressField setTextAlignment: NSTextAlignmentCenter];
    [_addressField setFont:[UIFont fontWithName:MYRIADPRO_REGULAR size:45.0]];
    [_addressField setDelegate: self];
    [_addressField setAdjustsFontSizeToFitWidth: YES]; // Not put it in IB: issue with placeholder size
    
    [_iconClear setFrame: CGRectMake(_addressField.frame.origin.x+_addressField.frame.size.width+5, _addContactButton.frame.origin.y, _addContactButton.frame.size.width, _addContactButton.frame.size.height)];
    
    
    [_tbSearch setDelegate: self];
    [_tbSearch setDataSource: self];
    [_tbSearch setHidden: YES];
    [_tbSearch setBackgroundColor:[UIColor whiteColor]];
    [_tbSearch setSeparatorStyle: UITableViewCellSeparatorStyleNone];
    [_tbSearch setSeparatorColor: [UIColor colorWithRed:(245/255.0) green:(245/255.0)
                                                   blue:(246/255.0) alpha: 1]];
    
    //  Keypad view
    float tmpHeight = (SCREEN_HEIGHT - [LinphoneAppDelegate sharedInstance]._hStatus - [LinphoneAppDelegate sharedInstance]._hTabbar - ([LinphoneAppDelegate sharedInstance]._hRegistrationState + _viewNumber.frame.size.height));
    
    //  Chiều cao của 1 button
    float hButton = (tmpHeight - minus)/5;
    float wButton = hButton * 240/148;
    
    //  Tính margin giữa các button
    float margin = (SCREEN_WIDTH - 3*wButton)/4;
    
    //  view keypad
    [_padView setFrame: CGRectMake(0, _viewNumber.frame.origin.y+_viewNumber.frame.size.height, SCREEN_WIDTH, 4*hButton)];
    
    //  1, 2, 3
    [_oneButton setFrame: CGRectMake(margin, 0, wButton, hButton)];
    [_twoButton setFrame: CGRectMake(_oneButton.frame.origin.x+_oneButton.frame.size.width+margin, 0, wButton, hButton)];
    [_threeButton setFrame: CGRectMake(_twoButton.frame.origin.x+_twoButton.frame.size.width+margin, 0, wButton, hButton)];
    
    float lineMarginX = _oneButton.frame.origin.x+_oneButton.frame.size.width/2-15;
    UILabel *lbLine1 = [[UILabel alloc] initWithFrame: CGRectMake(lineMarginX, _oneButton.frame.origin.y+_oneButton.frame.size.height, SCREEN_WIDTH-2*lineMarginX, 1)];
    [lbLine1 setBackgroundColor:[UIColor colorWithRed:(240/255.0) green:(240/255.0)
                                                 blue:(240/255.0) alpha:1.0]];
    [_padView addSubview: lbLine1];
    
    //  4, 5, 6
    [_fourButton setFrame: CGRectMake(_oneButton.frame.origin.x, lbLine1.frame.origin.y+lbLine1.frame.size.height, _oneButton.frame.size.width, hButton)];
    [_fiveButton setFrame: CGRectMake(_twoButton.frame.origin.x, _fourButton.frame.origin.y, _twoButton.frame.size.width, hButton)];
    [_sixButton setFrame: CGRectMake(_threeButton.frame.origin.x, _fourButton.frame.origin.y, _threeButton.frame.size.width, hButton)];
    
    UILabel *lbLine2 = [[UILabel alloc] initWithFrame: CGRectMake(lbLine1.frame.origin.x, _fourButton.frame.origin.y+_fourButton.frame.size.height, lbLine1.frame.size.width, lbLine1.frame.size.height)];
    [lbLine2 setBackgroundColor:[UIColor colorWithRed:(240/255.0) green:(240/255.0)
                                                 blue:(240/255.0) alpha:1.0]];
    [_padView addSubview: lbLine2];
    
    //  7, 8, 9
    [_sevenButton setFrame: CGRectMake(_fourButton.frame.origin.x, lbLine2.frame.origin.y+lbLine2.frame.size.height, _fourButton.frame.size.width, hButton)];
    [_eightButton setFrame: CGRectMake(_fiveButton.frame.origin.x, _sevenButton.frame.origin.y, _fiveButton.frame.size.width, hButton)];
    [_nineButton setFrame: CGRectMake(_sixButton.frame.origin.x, _sevenButton.frame.origin.y, _sixButton.frame.size.width, hButton)];
    
    UILabel *lbLine3 = [[UILabel alloc] initWithFrame: CGRectMake(lbLine1.frame.origin.x, _sevenButton.frame.origin.y+_sevenButton.frame.size.height, lbLine1.frame.size.width, lbLine1.frame.size.height)];
    [lbLine3 setBackgroundColor:[UIColor colorWithRed:(240/255.0) green:(240/255.0)
                                                 blue:(240/255.0) alpha:1.0]];
    [_padView addSubview: lbLine3];
    
    //  *, 0, #
    [_starButton setFrame: CGRectMake(_sevenButton.frame.origin.x, lbLine3.frame.origin.y+lbLine3.frame.size.height, _sevenButton.frame.size.width, hButton)];
    [_zeroButton setFrame: CGRectMake(_eightButton.frame.origin.x, _starButton.frame.origin.y, _eightButton.frame.size.width, hButton)];
    [_hashButton setFrame: CGRectMake(_nineButton.frame.origin.x, _starButton.frame.origin.y, _nineButton.frame.size.width, hButton)];
    
    UILabel *lbLine4 = [[UILabel alloc] initWithFrame: CGRectMake(lbLine1.frame.origin.x, _starButton.frame.origin.y+_starButton.frame.size.height, lbLine1.frame.size.width, lbLine1.frame.size.height)];
    [lbLine4 setBackgroundColor:[UIColor colorWithRed:(240/255.0) green:(240/255.0)
                                                 blue:(240/255.0) alpha:1.0]];
    [_padView addSubview: lbLine4];
    
    //  view footer
    [_viewFooter setFrame: CGRectMake(0, _padView.frame.origin.y+_padView.frame.size.height, SCREEN_WIDTH, hButton+minus)];
    
    [_backButton setFrame: CGRectMake(margin, minus/2, wButton, hButton)];
    [_btnHotline setFrame: _backButton.frame];
    
    [_viewCallButton setFrame: CGRectMake(_btnHotline.frame.origin.x+_btnHotline.frame.size.width+margin, _backButton.frame.origin.y, wButton, hButton)];
    [_callButton setFrame: CGRectMake(0, 0, _viewCallButton.frame.size.width, _viewCallButton.frame.size.height)];
    [_callButton setBackgroundColor:[UIColor whiteColor]];
    _callButton.delegate = self;
    
    [_btnAddCall setFrame: _callButton.frame];
    [_btnTransferCall setFrame: _callButton.frame];
    
    [_backspaceButton setFrame:CGRectMake(_viewCallButton.frame.origin.x+_viewCallButton.frame.size.width+margin, _viewCallButton.frame.origin.y, wButton, hButton)];
    
    // set font
    [_addressField setFont:[UIFont fontWithName:MYRIADPRO_REGULAR size:45.0]];
    [_addressField setDelegate: self];
    [_addressField setAdjustsFontSizeToFitWidth: YES]; // Not put it in IB: issue with placeholder size
    
    //  view search
    UITapGestureRecognizer *tapOnSearch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTapOnSearchResult)];
    [_viewSearch addGestureRecognizer: tapOnSearch];
}

- (void)movingDownAddressFieldNumber{
    [_addContactButton setFrame: CGRectMake(10, (hBgNumber-wIcon)/2, wIcon, wIcon)];
    [_addressField setFrame:CGRectMake(_addContactButton.frame.origin.x+_addContactButton.frame.size.width+10, 10, _viewNumber.frame.size.width-(_addContactButton.frame.origin.x+10+_addContactButton.frame.size.width+10+_addContactButton.frame.size.width+_addContactButton.frame.origin.x), _viewNumber.frame.size.height-20)];
    
    [_iconClear setFrame: CGRectMake(_addressField.frame.origin.x+_addressField.frame.size.width+5, _addContactButton.frame.origin.y, _addContactButton.frame.size.width, _addContactButton.frame.size.height)];
}

- (void)whenTapOnSearchResult {
    if (listPhoneSearched.count > 0) {
        NSString *value = [listPhoneSearched firstObject];
        NSArray *tmpArr = [value componentsSeparatedByString:@"|"];
        if (tmpArr.count >= 3) {
            NSString *phone = [tmpArr lastObject];
            _addressField.text = phone;
        }
        // ẩn search phonebook
        [self setPhoneBookHidden];
        
        [self movingDownAddressFieldNumber];
    }
}

//  Ẩn phonebook
- (void)setPhoneBookHidden{
    [_viewSearch setHidden: YES];
    [_tbSearch setHidden: YES];
}

//  Kiểm tra folder chứa ảnh và tạo list emotion
- (void)setupForFirstLoadApp {
    NSThread *aThread = [[NSThread alloc] initWithTarget:self
                                                selector:@selector(startSetupForFirstLoadApp:)
                                                  object:nil];
    [aThread start];
}

- (void)startSetupForFirstLoadApp: (NSThread *)thread {
    [AppUtils checkFolderToSaveFileInViewChat];
    
    //  Khởi tạo danh sách emotion nếu chưa tồn tại
    [self createEmotionListIfNotExists];
    
    [thread cancel];
    if ([thread isCancelled]) {
        thread = nil;
    }
}

//  Khởi tạo danh sách emotion nếu chưa tồn tại
- (void)createEmotionListIfNotExists {
    if ([LinphoneAppDelegate sharedInstance]._listFace.count == 0) {
        NSString* facePlistPath = [[NSBundle mainBundle] pathForResource:@"PeopleEmotion" ofType:@"plist"];
        NSString* naturePlistPath = [[NSBundle mainBundle] pathForResource:@"NatureEmotion" ofType:@"plist"];
        NSString* objectPlistPath = [[NSBundle mainBundle] pathForResource:@"ObjectEmotion" ofType:@"plist"];
        NSString* placePlistPath = [[NSBundle mainBundle] pathForResource:@"PlaceEmotion" ofType:@"plist"];
        NSString* symbolPlistPath = [[NSBundle mainBundle] pathForResource:@"SymbolEmotion" ofType:@"plist"];
        
        [[LinphoneAppDelegate sharedInstance]._listFace addObjectsFromArray:[NSArray arrayWithContentsOfFile: facePlistPath]];
        [[LinphoneAppDelegate sharedInstance]._listNature addObjectsFromArray:[NSArray arrayWithContentsOfFile: naturePlistPath]];
        [[LinphoneAppDelegate sharedInstance]._listObject addObjectsFromArray:[NSArray arrayWithContentsOfFile: objectPlistPath]];
        [[LinphoneAppDelegate sharedInstance]._listPlace addObjectsFromArray:[NSArray arrayWithContentsOfFile: placePlistPath]];
        [[LinphoneAppDelegate sharedInstance]._listSymbol addObjectsFromArray:[NSArray arrayWithContentsOfFile: symbolPlistPath]];
    }
}


#pragma mark - UITableview Delegate

#pragma mark - UITableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [listPhoneSearched count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PhoneBookContactCell";
    PhoneBookContactCell *cell = (PhoneBookContactCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PhoneBookContactCell" owner:self options:nil];
        cell = topLevelObjects[0];
        [cell setupUIForCell];
    }
    [cell setFrame: CGRectMake(cell.frame.origin.x, cell.frame.origin.y, _tbSearch.frame.size.width, heightTableCell)];
    [cell setupUIForCell];
    
    NSString *value = [listPhoneSearched objectAtIndex: indexPath.row];
    NSArray *tmpArr = [value componentsSeparatedByString:@"|"];
    if (tmpArr.count >= 3) {
        NSString *name = [tmpArr firstObject];
        NSString *phone = [tmpArr lastObject];
        
        // Tô màu cho name
        NSMutableAttributedString *nameColor = [[NSMutableAttributedString alloc] initWithString:name];
        NSString *nameForSearch = [AppUtils getNameForSearchOfConvertName: name];
        NSRange nameRange = [nameForSearch rangeOfString: _addressField.text];
        if (nameRange.location != NSNotFound) {
            [nameColor addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:(244/255.0) green:(179/255.0) blue:(15/255.0) alpha:1.0] range:NSMakeRange(nameRange.location, [_addressField text].length)];
        }else{
            [nameColor addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:(244/255.0) green:(179/255.0) blue:(15/255.0) alpha:1.0] range:NSMakeRange(0, 0)];
        }
        cell.name.attributedText = nameColor;
        
        // Tô màu cho phone number
        NSMutableAttributedString *phoneColor = [[NSMutableAttributedString alloc] initWithString: phone];
        NSRange phoneRange = [phone rangeOfString: _addressField.text];
        if (phoneRange.location != NSNotFound) {
            [phoneColor addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:(244/255.0) green:(179/255.0) blue:(15/255.0) alpha:1.0] range:NSMakeRange(phoneRange.location , [_addressField text].length)];
        }else{
            [phoneColor addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:(244/255.0) green:(179/255.0) blue:(15/255.0) alpha:1.0] range:NSMakeRange(0, 0)];
        }
        cell.phone.attributedText = phoneColor;
        
        NSString *avatar = [NSDatabase getAvatarOfContactWithPhoneNumber: phone];
        if ([avatar isEqualToString:@""]) {
            [cell.imgAvatar setImage:[UIImage imageNamed:@"no_avatar.png"]];
        }else{
            NSData *imgData = [NSData dataFromBase64String: avatar];
            cell.imgAvatar.image = [UIImage imageWithData: imgData];
        }
        
        if ([phone hasPrefix:@"778899"]) {
            cell._iconChat.hidden = NO;
            cell._iconChat.tag = indexPath.row;
            [cell._iconChat addTarget:self
                               action:@selector(clickOnIconGoToViewChat:)
                     forControlEvents:UIControlEventTouchUpInside];
        }else{
            cell._iconChat.hidden = YES;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PhoneBookContactCell *cell = (PhoneBookContactCell *)[tableView cellForRowAtIndexPath:indexPath];
    // format phone string
    NSString *phoneString = cell.phone.text;
    [_addressField setText: phoneString];
    
    // ẩn search phonebook
    [self setPhoneBookHidden];
    
    [self movingDownAddressFieldNumber];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return heightTableCell;
}

- (void)clickOnIconGoToViewChat: (UIButton *)sender {
    NSString *value = [listPhoneSearched objectAtIndex:sender.tag];
    NSArray *tmpArr = [value componentsSeparatedByString:@"|"];
    if (tmpArr.count >= 3) {
        NSString *phoneNumber = [tmpArr lastObject];
        if ([phoneNumber hasPrefix:@"778899"]) {
            [LinphoneAppDelegate sharedInstance].reloadMessageList = YES;
            [LinphoneAppDelegate sharedInstance].friendBuddy = [AppUtils getBuddyOfUserOnList: phoneNumber];
            [[PhoneMainView instance] changeCurrentView:[MainChatViewController compositeViewDescription]
                                                   push:true];
        }
    }
}

//  Đăng ký lại với tài khoản
- (void)whenSelectAccountForRegister: (NSNotification *)notif
{
    id object = [notif object];
    if ([object isKindOfClass:[NSNumber class]]) {
        stateLogin = 0;
        if ([object intValue] == 0)
        {
            typeAccountChoosed = 1;
            [self clearAllProxyConfigAndAccount];
        }else{
            typeAccountChoosed = 2;
            nextStepPBX = NO;
            [self clearAllProxyConfigAndAccount];
        }
    }
    //  [LinphoneManager.instance refreshRegisters];
}

- (void)displayAssistantConfigurationError {
    [_lbStatus setTextColor:[UIColor orangeColor]];
    [_lbStatus setText: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_status_offline]];
}

#pragma mark - Actionsheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 100) {
        switch (buttonIndex) {
            case 0:{
                NewContactViewController *controller = VIEW(NewContactViewController);
                if (controller) {
                    controller.currentSipPhone = _addressField.text;
                    controller.currentName = @"";
                }
                [[PhoneMainView instance] changeCurrentView:[NewContactViewController compositeViewDescription]
                                                       push:true];
                break;
            }
            case 1:{
                AllContactListViewController *controller = VIEW(AllContactListViewController);
                if (controller != nil) {
                    controller.phoneNumber = _addressField.text;
                }
                [[PhoneMainView instance] changeCurrentView:[AllContactListViewController compositeViewDescription]
                                                       push:true];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Tap Gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView: _tbSearch]) {
        return NO;
    }
    return YES;
}

#pragma mark - Call Button Delegate
- (void)textfieldAddressChanged:(NSString *)number {
    [self searchPhoneBookWithThread];
}

//  Clear tất cả các proxy config và account của nó
- (void)clearAllProxyConfigAndAccount {
    const MSList *proxies = linphone_core_get_proxy_config_list(LC);
    totalAccount = ms_list_size(proxies);
    if (totalAccount == 0) {
        return;
    }
    curIndex = 1;
    
    linphone_core_clear_proxy_config(LC);
    [[LinphoneManager instance] removeAllAccounts];
}

- (void)reloginToSipAccount
{
    BOOL success = [SipUtils loginSipWithDomain:SIP_DOMAIN username:USERNAME password:PASSWORD port:PORT];
    if (success) {
        [SipUtils registerProxyWithUsername:USERNAME password:PASSWORD domain:SIP_DOMAIN port:PORT];
    }
}

- (void)registerPBXAccount: (NSString *)pbxAccount password: (NSString *)password ipAddress: (NSString *)address port: (NSString *)portID
{
    NSArray *data = @[address, pbxAccount, password, portID];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startRegisterPBX:) userInfo:data repeats:NO];
}

- (void)startRegisterPBX: (NSTimer *)timer {
    id data = [timer userInfo];
    if ([data isKindOfClass:[NSArray class]] && [data count] == 4) {
        NSString *pbxDomain = [data objectAtIndex: 0];
        NSString *pbxAccount = [data objectAtIndex: 1];
        NSString *pbxPassword = [data objectAtIndex: 2];
        NSString *pbxPort = [data objectAtIndex: 3];
        
        BOOL success = [SipUtils loginSipWithDomain:pbxDomain username:pbxAccount password:pbxPassword port:pbxPort];
        if (success) {
            [SipUtils registerProxyWithUsername:pbxAccount password:pbxPassword domain:pbxDomain port:pbxPort];
        }
    }
}

//  125.253.125.196
- (void)setDefaultProxyConfigWithAccount: (NSString *)username
{
    const MSList *proxies = linphone_core_get_proxy_config_list(LC);
    while (proxies) {
        if (proxies != NULL) {
            const char *proxyUsername = linphone_address_get_username(linphone_proxy_config_get_identity_address(proxies->data));
            if (strcmp(username.UTF8String, proxyUsername) == 0) {
                linphone_core_set_default_proxy_config(LC, proxies->data);
                break;
            }
        }
        proxies = proxies->next;
    }
}

- (void)removeProxyConfigWithAccount: (NSString *)username
{
    const MSList *proxies = linphone_core_get_proxy_config_list(LC);
    while (proxies) {
        if (proxies != NULL) {
            const char *proxyUsername = linphone_address_get_username(linphone_proxy_config_get_identity_address(proxies->data));
            if (strcmp(username.UTF8String, proxyUsername) == 0) {
                const LinphoneAuthInfo *ai = linphone_proxy_config_find_auth_info(proxies->data);
                linphone_core_remove_proxy_config(LC, proxies->data);
                if (ai) {
                    linphone_core_remove_auth_info(LC, ai);
                }
                break;
            }
        }
        proxies = proxies->next;
    }
}

- (void)registrationUpdateEvent:(NSNotification *)notif {
    NSString *message = [notif.userInfo objectForKey:@"message"];
    [self registrationUpdate:[[notif.userInfo objectForKey:@"state"] intValue]
                    forProxy:[[notif.userInfo objectForKeyedSubscript:@"cfg"] pointerValue]
                     message:message];
}

- (void)registrationUpdate:(LinphoneRegistrationState)state forProxy:(LinphoneProxyConfig *)proxy message:(NSString *)message {
    switch (state) {
        case LinphoneRegistrationOk: {
            if (typeAccountChoosed == 1) {
                [_lbStatus setText:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_status_online]];
                [_lbStatus setTextColor:[UIColor greenColor]];
            }else if (typeAccountChoosed == 2){
                if (!nextStepPBX) {
                    nextStepPBX = YES;
                    
                    NSString *pbxUsername = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_USERNAME];
                    NSString *pbxPassword = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_PASSWORD];
                    NSString *ipAddress = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_IP_ADDRESSS];
                    NSString *pbxPort = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_PORT];
                    [self registerPBXAccount: pbxUsername password: pbxPassword ipAddress: ipAddress port: pbxPort];
                }else{
                    [_lbStatus setText:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_status_online]];
                    [_lbStatus setTextColor:[UIColor greenColor]];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1]
                                                              forKey:callnexPBXFlag];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    NSString *pbxUsername = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_USERNAME];
                    [_lbAccount setText: pbxUsername];
                }
            }else{
                [_lbStatus setText:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_status_online]];
                [_lbStatus setTextColor:[UIColor greenColor]];
            }
            break;
        }
        case LinphoneRegistrationNone:{
            NSLog(@"LinphoneRegistrationNone");
            break;
        }
        case LinphoneRegistrationCleared: {
            NSLog(@"LinphoneRegistrationCleared");
            // _waitView.hidden = true;
            break;
        }
        case LinphoneRegistrationFailed: {
            NSLog(@"LinphoneRegistrationFailed");
            if (curIndex == totalAccount && totalAccount > 0) {
                if (stateLogin == 1) {
                    //  Nếu chọn login SIP mà bị thất bại
                    [self networkDown];
                    [_lbAccount setText: USERNAME];
                }else if (stateLogin == 2){
                    //  Nếu chọn login PBX mà bị thất bại
                    [self networkDown];
                    NSString *pbxUsername = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_USERNAME];
                    [_lbAccount setText: pbxUsername];

                    [self removeProxyConfigWithAccount: pbxUsername];
                    [self setDefaultProxyConfigWithAccount:USERNAME];
                }else{
                    if (typeAccountChoosed == 1) {
                        stateLogin = 1;
                    }else if (typeAccountChoosed == 2){
                        stateLogin = 2;
                    }
                    [self reloginToSipAccount];
                }
            }else{
                curIndex++;
            }
            break;
        }
        case LinphoneRegistrationProgress: {
            NSLog(@"LinphoneRegistrationProgress");
            // _waitView.hidden = false;
            break;
        }
        default:
            break;
    }
}

- (void)loadAssistantConfig:(NSString *)rcFilename {
    NSString *fullPath = [@"file://" stringByAppendingString:[LinphoneManager bundleFile:rcFilename]];
    linphone_core_set_provisioning_uri(LC, fullPath.UTF8String);
    [LinphoneManager.instance lpConfigSetInt:1 forKey:@"transient_provisioning" inSection:@"misc"];
}

- (void)firstLoadSettingForAccount {
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if ([bundleIdentifier isEqualToString: cloudfoneBundleID]) {
        NSString *hasFirstSetting = [[NSUserDefaults standardUserDefaults] objectForKey:@"hasFirstSetting"];
        if (hasFirstSetting == nil) {
            linphone_core_enable_ipv6(LC, NO);
            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"hasFirstSetting"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

@end
