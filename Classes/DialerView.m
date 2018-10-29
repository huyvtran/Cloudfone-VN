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
#import "PBXSettingViewController.h"
#import "LinphoneManager.h"
#import "PhoneMainView.h"
#import <AVFoundation/AVFoundation.h>
#import "PhoneBookContactCell.h"
#import "NSData+Base64.h"
#import <objc/runtime.h>
#import "NSDatabase.h"
#import "ContactDetailObj.h"
#import "UIVIew+Toast.h"

#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import "PBXContact.h"

@interface DialerView (){
    LinphoneAppDelegate *appDelegate;
    NSMutableArray *listPhoneSearched;
    
    UITapGestureRecognizer *tapOnScreen;
    NSTimer *pressTimer;
    
    UIView *searchView;
    UIImageView *imgSearchAvatar;
    UILabel *lbSearchName;
    UILabel *lbSearchPhone;
    float hSearch;
    
    BOOL isNewSearch;
    UITextView *tvSearch;
    SearchContactPopupView *popupSearchContacts;
}
@end

@implementation DialerView
@synthesize _viewStatus, _imgLogoSmall, _lbAccount, _lbStatus, lbSearchResult;
@synthesize _viewNumber;
@synthesize _btnHotline, _btnAddCall, _btnTransferCall;

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
    
    //  Added by Khai Le on 30/09/2018
    [self checkAccountForApp];
    
    //  setup cho key login
    [[LinphoneManager instance] lpConfigSetBool:FALSE forKey:@"enable_first_login_view_preference"];
    
    // Tắt màn hình cảm biến
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled: false];
    
    
    //  setup sound và vibrate của cuộc gọi cho user hiện tại
    [self setupSoundAndVibrateForCallOfUser];
    
    // invisible icon add contact & icon delete address
    _addContactButton.hidden = YES;
    _addressField.text = @"";
    searchView.hidden = YES;
    
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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPopupWhenCallFailed:)
                                                 name:@"showPopupWhenCallFail" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registrationStateUpdate:)
                                                 name:k11RegistrationUpdate object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkDown)
                                                 name:@"NetworkDown" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenNetworkChanged)
                                                 name:networkChanged object:nil];
    
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(registrationUpdateEvent:)
                                               name:kLinphoneRegistrationUpdate object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(afterEndCallForTransfer)
                                                 name:reloadHistoryCall object:nil];
    
	// Update on show
	LinphoneCall *call = linphone_core_get_current_call(LC);
	LinphoneCallState state = (call != NULL) ? linphone_call_get_state(call) : 0;
	[self callUpdate:call state:state];

    [self enableNAT];
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
    
    appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    isNewSearch = YES;
    
    [self autoLayoutForView];
    
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
			
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			break;
		case UIInterfaceOrientationLandscapeLeft:
			break;
		case UIInterfaceOrientationLandscapeRight:
			break;
		default:
			break;
	}
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
    
    [self addBoxShadowForView:searchView withColor:[UIColor colorWithRed:(220/255.0) green:(220/255.0)
                                                                    blue:(220/255.0) alpha:1.0]];
    
    //  Check for first time, after installed app
    //  [self checkForShowFirstSettingAccount];
}

#pragma mark - Event Functions

- (void)callUpdateEvent:(NSNotification *)notif {
	LinphoneCall *call = [[notif.userInfo objectForKey:@"call"] pointerValue];
	LinphoneCallState state = [[notif.userInfo objectForKey:@"state"] intValue];
	[self callUpdate:call state:state];
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

- (void)afterEndCallForTransfer {
    _addContactButton.hidden = YES;
    _addressField.text = @"";
    searchView.hidden = YES;
}

#pragma mark - UITextFieldDelegate Functions

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
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
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"You can not add yourself to contact list"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    UIActionSheet *popupAddContact = [[UIActionSheet alloc] initWithTitle:_addressField.text delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:text_cancel] destructiveButtonTitle:nil otherButtonTitles: [appDelegate.localization localizedStringForKey:@"Create new contact"], [appDelegate.localization localizedStringForKey:@"Add to existing contact"], nil];
    popupAddContact.tag = 100;
    [popupAddContact showInView:self.view];
}

- (IBAction)onBackClick:(id)event {
	[PhoneMainView.instance popToView:CallView.compositeViewDescription];
}

- (IBAction)onAddressChange:(id)sender {
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
        pressTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self
                                                    selector:@selector(searchPhoneBookWithThread)
                                                    userInfo:nil repeats:false];
    }else{
        _addContactButton.hidden = YES;
        searchView.hidden = YES;
    }
}

- (void)onBackspaceLongClick:(id)sender {
    _addressField.text = @"";
    _addContactButton.hidden = YES;
    searchView.hidden = YES;
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
    [SipUtils makeCallWithPhoneNumber: hotline];
}

- (IBAction)_btnNumberPressed:(id)sender {
    [self.view endEditing: true];
    //  Show or hide "add contact" button when textfield address changed
    if (_addressField.text.length > 0){
        _addContactButton.hidden = NO;
    }else{
        _addContactButton.hidden = YES;
    }
    
    [pressTimer invalidate];
    pressTimer = nil;
    pressTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self
                                                selector:@selector(searchPhoneBookWithThread)
                                                userInfo:nil repeats:false];
    //  [self searchPhoneBookWithThread];
}

- (IBAction)_btnCallPressed:(UIButton *)sender {
    [pressTimer invalidate];
    pressTimer = nil;
    pressTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self
                                                selector:@selector(searchPhoneBookWithThread)
                                                userInfo:nil repeats:false];
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
    _lbStatus.text = [appDelegate.localization localizedStringForKey:@"No network"];
    _lbStatus.textColor = UIColor.orangeColor;
}

- (void)searchPhoneBookWithThread {
    NSString *searchStr = _addressField.text;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if (listPhoneSearched == nil) {
            listPhoneSearched = [[NSMutableArray alloc] init];
        }
        [listPhoneSearched removeAllObjects];
        
        //  search name with list pbx first
        [self searchContactInPBXList: searchStr];
        if (listPhoneSearched.count <= 0) {
            //  Continue search with person list
            [self searchForContactName: searchStr];
            
            NSArray *cleanedArray = [[NSSet setWithArray: listPhoneSearched] allObjects];
            [listPhoneSearched removeAllObjects];
            [listPhoneSearched addObjectsFromArray: cleanedArray];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self afterGetContactPhoneBookSuccessfully];
        });
    });
}

- (void)searchContactInPBXList: (NSString *)search {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_name CONTAINS[cd] %@ OR _number CONTAINS[cd] %@ OR _nameForSearch CONTAINS[cd] %@", search, search, search];
    NSArray *filter = [appDelegate.pbxContacts filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        [listPhoneSearched addObjectsFromArray: filter];
    }
}

- (void)searchForContactName: (NSString *)search {
    NSArray *allName = [appDelegate._allPhonesDict allValues];
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
        _addContactButton.hidden = YES;
    }else{
        _addContactButton.hidden = NO;
        
        if (listPhoneSearched.count > 0) {
            NSString *name = @"";
            NSString *phone = @"";
            NSString *nameForSearch = @"";
            NSString *avatar = @"";
            
            BOOL isPBXContact = NO;
            id searchObj = [listPhoneSearched firstObject];
            if ([searchObj isKindOfClass:[PBXContact class]]) {
                name = [(PBXContact *)searchObj _name];
                phone = [(PBXContact *)searchObj _number];
                nameForSearch = [(PBXContact *)searchObj _nameForSearch];
                avatar = [(PBXContact *)searchObj _avatar];
                
                isPBXContact = YES;
            }else{
                NSArray *value = [self getValidResultFromSearchResult];
                name = [value firstObject];
                phone = [value lastObject];
                nameForSearch = [value objectAtIndex: 1];
            }
            
            if (![name isEqualToString:@""] && ![phone isEqualToString:@""]) {
                if (!isNewSearch) {
                    // Tô màu cho tên contact đầu tiên được tìm thấy
                    NSMutableAttributedString *nameColor = [[NSMutableAttributedString alloc] initWithString: name];
                    
                    NSRange firstRange = [nameForSearch rangeOfString: _addressField.text options:NSCaseInsensitiveSearch];
                    
                    if (firstRange.location != NSNotFound) {
                        [nameColor addAttribute:NSForegroundColorAttributeName
                                          value:[UIColor colorWithRed:(244/255.0) green:(179/255.0)
                                                                 blue:(15/255.0) alpha:1.0]
                                          range:NSMakeRange(firstRange.location, _addressField.text.length)];
                    }else{
                        [nameColor addAttribute:NSForegroundColorAttributeName
                                          value:[UIColor colorWithRed:(20/255.0) green:(20/255.0)
                                                                 blue:(20/255.0) alpha:1.0]
                                          range:NSMakeRange(0, name.length)];
                    }
                    lbSearchName.attributedText = nameColor;
                    
                    
                    
                    //  to mau cho phone number
                    NSMutableAttributedString *phoneColor = [[NSMutableAttributedString alloc] initWithString: phone];
                    NSRange phoneRange = [phone rangeOfString: _addressField.text options:NSCaseInsensitiveSearch];
                    
                    if (phoneRange.location != NSNotFound) {
                        [phoneColor addAttribute:NSForegroundColorAttributeName
                                           value:[UIColor colorWithRed:(244/255.0) green:(179/255.0)
                                                                  blue:(15/255.0) alpha:1.0]
                                           range:NSMakeRange(phoneRange.location, _addressField.text.length)];
                    }else{
                        [phoneColor addAttribute:NSForegroundColorAttributeName
                                           value:[UIColor colorWithRed:(20/255.0) green:(20/255.0)
                                                                  blue:(20/255.0) alpha:1.0]
                                           range:NSMakeRange(0, phone.length)];
                    }
                    lbSearchPhone.attributedText = phoneColor;
                    
                    // setup avatar
                    if (isPBXContact) {
                        if (![AppUtils isNullOrEmpty: avatar]) {
                            imgSearchAvatar.image = [UIImage imageWithData:[NSData dataFromBase64String: avatar]];
                        }else{
                            imgSearchAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
                        }
                    }else{
                        NSString *avatar = [NSDatabase getAvatarOfContactWithPhoneNumber: phone];
                        if (![avatar isEqualToString:@""]) {
                            imgSearchAvatar.image = [UIImage imageWithData:[NSData dataFromBase64String: avatar]];
                        }else{
                            imgSearchAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
                        }
                    }
                    searchView.hidden = NO;
                }else{
                    tvSearch.hidden = NO;
                    tvSearch.attributedText = [self getSearchValueFromResult: listPhoneSearched];
                    
                    lbSearchResult.hidden = YES;
                    lbSearchResult.attributedText = [self getSearchValueFromResult: listPhoneSearched];
                }
            }else{
                tvSearch.hidden = YES;
                searchView.hidden = YES;
                lbSearchResult.hidden = YES;
            }
        }else{
            tvSearch.hidden = YES;
            searchView.hidden = YES;
            lbSearchResult.hidden = YES;
        }
    }
}

- (void)registrationStateUpdate: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[NSNumber class]]) {
        LinphoneRegistrationState state = [object intValue];
        switch (state) {
            case LinphoneRegistrationOk:{
                DDLogInfo(@"%@", [NSString stringWithFormat:@"%s: State is %@", __FUNCTION__, @"LinphoneRegistrationOk"]);
                
                _lbStatus.textColor = UIColor.greenColor;
                _lbStatus.text = [appDelegate.localization localizedStringForKey:@"Online"];
                break;
            }
            case LinphoneRegistrationProgress:{
                DDLogInfo(@"%@", [NSString stringWithFormat:@"%s: State is %@", __FUNCTION__, @"LinphoneRegistrationProgress"]);
                
                _lbStatus.textColor = UIColor.whiteColor;
                _lbStatus.text = [appDelegate.localization localizedStringForKey:@"Connecting"];
                break;
            }
            case LinphoneRegistrationNone:
            case LinphoneRegistrationCleared:
            case LinphoneRegistrationFailed:{
                DDLogInfo(@"%@", [NSString stringWithFormat:@"%s: State is %@", __FUNCTION__, @"LinphoneRegistrationFailed"]);
                
                _lbStatus.textColor = UIColor.orangeColor;
                _lbStatus.text = [appDelegate.localization localizedStringForKey:@"Offline"];
                break;
            }
            default:
                break;
        }
    }
}

- (void)enableNAT {
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

- (void)autoLayoutForView {
    self.view.backgroundColor = UIColor.whiteColor;
    //  view status
    _viewStatus.backgroundColor = [UIColor colorWithRed:(21/255.0) green:(41/255.0)
                                                   blue:(52/255.0) alpha:1.0];
    [_viewStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(appDelegate._hRegistrationState);
    }];
    
    [_imgLogoSmall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewStatus).offset(appDelegate._hRegistrationState/4);
        make.centerY.equalTo(_viewStatus.mas_centerY).offset(appDelegate._hStatus/2);
        make.width.height.mas_equalTo(30.0);
    }];
    
    //  account label
    _lbAccount.font = [UIFont fontWithName:MYRIADPRO_BOLD size:18.0];
    _lbAccount.textAlignment = NSTextAlignmentCenter;
    [_lbAccount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(_imgLogoSmall);
        make.centerX.equalTo(_viewStatus.mas_centerX);
        make.width.mas_equalTo(150);
    }];
    
    //  status label
    _lbStatus.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    [_lbStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewStatus.mas_centerX);
        make.top.bottom.equalTo(_lbAccount);
        make.right.equalTo(_viewStatus).offset(-appDelegate._hRegistrationState/4);
    }];
    UITapGestureRecognizer *tapOnStatus = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTappedOnStatusAccount)];
    _lbStatus.userInteractionEnabled = YES;
    [_lbStatus addGestureRecognizer: tapOnStatus];
    
    //  Number view
    [_viewNumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(_viewStatus.mas_bottom);
        make.height.mas_equalTo(100.0);
    }];
    
    
    [_addressField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewNumber).offset(10);
        make.left.equalTo(self.view).offset(80);
        make.right.equalTo(self.view).offset(-80);
        make.height.mas_equalTo(60.0);
    }];
    _addressField.keyboardType = UIKeyboardTypePhonePad;
    _addressField.enabled = YES;
    _addressField.textAlignment = NSTextAlignmentCenter;
    _addressField.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:45.0];
    _addressField.adjustsFontSizeToFitWidth = YES;
    _addressField.delegate = self;
    
    lbSearchResult.hidden = YES;
    lbSearchResult.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:17.0];
    [lbSearchResult mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewNumber).offset(10.0);
        make.right.equalTo(_viewNumber).offset(-10.0);
        make.top.equalTo(_addressField.mas_bottom);
        make.height.mas_equalTo(30.0);
    }];
    
    tvSearch = [[UITextView alloc] init];
    tvSearch.backgroundColor = UIColor.clearColor;
    tvSearch.editable = NO;
    tvSearch.hidden = YES;
    tvSearch.delegate = self;
    [_viewNumber addSubview: tvSearch];
    
    [tvSearch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewNumber).offset(10.0);
        make.right.equalTo(_viewNumber).offset(-10.0);
        make.top.equalTo(_addressField.mas_bottom);
        make.height.mas_equalTo(30.0);
    }];
    //  tvSearch.linkTextAttributes = @{NSUnderlineStyleAttributeName: NSUnderlineStyleNone};
    
    [_addContactButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewNumber).offset(10.0);
        make.centerY.equalTo(_addressField.mas_centerY).offset(-3);
        make.width.height.mas_equalTo(40.0);
    }];
    
    
    //  Number keypad
    NSString *modelName = [DeviceUtils getModelsOfCurrentDevice];
    float wIcon = [DeviceUtils getSizeOfKeypadButtonForDevice: modelName];
    float spaceMarginY = [DeviceUtils getSpaceYBetweenKeypadButtonsForDevice: modelName];
    float spaceMarginX = [DeviceUtils getSpaceXBetweenKeypadButtonsForDevice: modelName];
    
    _padView.backgroundColor = UIColor.clearColor;
    [_padView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewNumber.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    //  7, 8, 9
    _eightButton.layer.cornerRadius = wIcon/2;
    _eightButton.clipsToBounds = YES;
    [_eightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_padView.mas_centerX);
        make.centerY.equalTo(_padView.mas_centerY);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    _sevenButton.layer.cornerRadius = wIcon/2;
    _sevenButton.clipsToBounds = YES;
    [_sevenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_eightButton.mas_top);
        make.right.equalTo(_eightButton.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    _nineButton.layer.cornerRadius = wIcon/2;
    _nineButton.clipsToBounds = YES;
    [_nineButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_eightButton.mas_top);
        make.left.equalTo(_eightButton.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    //  4, 5, 6
    _fiveButton.layer.cornerRadius = wIcon/2;
    _fiveButton.clipsToBounds = YES;
    [_fiveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_eightButton.mas_top).offset(-spaceMarginY);
        make.centerX.equalTo(_padView.mas_centerX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    _fourButton.layer.cornerRadius = wIcon/2;
    _fourButton.clipsToBounds = YES;
    [_fourButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_fiveButton.mas_top);
        make.right.equalTo(_fiveButton.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    _sixButton.layer.cornerRadius = wIcon/2;
    _sixButton.clipsToBounds = YES;
    [_sixButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_fiveButton.mas_top);
        make.left.equalTo(_fiveButton.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    //  1, 2, 3
    _twoButton.backgroundColor = UIColor.clearColor;
    _twoButton.layer.cornerRadius = wIcon/2;
    _twoButton.clipsToBounds = YES;
    [_twoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_fiveButton.mas_top).offset(-spaceMarginY);
        make.centerX.equalTo(_padView.mas_centerX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    _oneButton.layer.cornerRadius = wIcon/2;
    _oneButton.clipsToBounds = YES;
    [_oneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_twoButton.mas_top);
        make.right.equalTo(_twoButton.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    _threeButton.layer.cornerRadius = wIcon/2;
    _threeButton.clipsToBounds = YES;
    [_threeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_twoButton.mas_top);
        make.left.equalTo(_twoButton.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    //  *, 0, #
    _zeroButton.layer.cornerRadius = wIcon/2;
    _zeroButton.clipsToBounds = YES;
    [_zeroButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_eightButton.mas_bottom).offset(spaceMarginY);
        make.centerX.equalTo(_padView.mas_centerX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    _starButton.layer.cornerRadius = wIcon/2;
    _starButton.clipsToBounds = YES;
    [_starButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_zeroButton.mas_top);
        make.right.equalTo(_zeroButton.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    _hashButton.layer.cornerRadius = wIcon/2;
    _hashButton.clipsToBounds = YES;
    [_hashButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_zeroButton.mas_top);
        make.left.equalTo(_zeroButton.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    //  fifth layer
    _callButton.layer.cornerRadius = wIcon/2;
    _callButton.clipsToBounds = YES;
    [_callButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_zeroButton.mas_bottom).offset(spaceMarginY);
        make.centerX.equalTo(_padView.mas_centerX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    //  transfer button
    _btnTransferCall.layer.cornerRadius = wIcon/2;
    _btnTransferCall.clipsToBounds = YES;
    _btnTransferCall.backgroundColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0)
                                                        blue:(235/255.0) alpha:1.0];
    [_btnTransferCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(_callButton);
    }];
    
    //  Add call button
    _btnAddCall.layer.cornerRadius = wIcon/2;
    _btnAddCall.clipsToBounds = YES;
    _btnAddCall.backgroundColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0)
                                                        blue:(235/255.0) alpha:1.0];
    [_btnAddCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(_callButton);
    }];
    
    _btnHotline.layer.cornerRadius = wIcon/2;
    _btnHotline.clipsToBounds = YES;
    [_btnHotline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_callButton.mas_top);
        make.right.equalTo(_callButton.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    _backButton.layer.cornerRadius = wIcon/2;
    _backButton.clipsToBounds = YES;
    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(_btnHotline);
    }];
    
    _backspaceButton.layer.cornerRadius = wIcon/2;
    _backspaceButton.clipsToBounds = YES;
    [_backspaceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_callButton.mas_top);
        make.left.equalTo(_callButton.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    //  search contact
    hSearch = 60.0;
    searchView = [[UIView alloc] init];
    searchView.backgroundColor = UIColor.whiteColor;
    searchView.layer.cornerRadius = 5.0;
    
    [_viewNumber addSubview: searchView];
    [searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_addressField.mas_bottom).offset(10);
        make.centerX.equalTo(_viewNumber.mas_centerX);
        make.height.mas_equalTo(hSearch);
        make.width.mas_equalTo(280);
    }];
    
    imgSearchAvatar = [[UIImageView alloc] init];
    imgSearchAvatar.backgroundColor = UIColor.redColor;
    imgSearchAvatar.clipsToBounds = YES;
    imgSearchAvatar.layer.cornerRadius = 45.0/2;
    [searchView addSubview: imgSearchAvatar];
    [imgSearchAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(searchView).offset((hSearch-45.0)/2);
        make.centerY.equalTo(searchView.mas_centerY);
        make.width.height.mas_equalTo(45.0);
    }];
    
    lbSearchName = [[UILabel alloc] init];
    lbSearchName.text = @"Khai Le";
    lbSearchName.textColor = [UIColor colorWithRed:(20/255.0) green:(20/255.0)
                                              blue:(20/255.0) alpha:1.0];
    [searchView addSubview: lbSearchName];
    [lbSearchName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgSearchAvatar.mas_right).offset(10);
        make.right.equalTo(searchView).offset(-(hSearch-45.0)/2);
        make.top.equalTo(imgSearchAvatar.mas_top);
        make.bottom.equalTo(imgSearchAvatar.mas_centerY);
    }];
    
    lbSearchPhone = [[UILabel alloc] init];
    lbSearchPhone.text = @"+841663430737";
    lbSearchPhone.textColor = [UIColor colorWithRed:(20/255.0) green:(20/255.0)
                                               blue:(20/255.0) alpha:1.0];
    [searchView addSubview: lbSearchPhone];
    
    [lbSearchPhone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(lbSearchName);
        make.top.equalTo(lbSearchName.mas_bottom);
        make.bottom.equalTo(imgSearchAvatar.mas_bottom);
    }];
    
    UITapGestureRecognizer *tapOnSearch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTapOnSearchResult)];
    [searchView addGestureRecognizer: tapOnSearch];
    searchView.hidden = YES;
}

- (void)whenTapOnSearchResult {
    NSString *phoneNumber = lbSearchPhone.text;
    if (![phoneNumber isEqualToString:@""]) {
        NSString *newPhoneNumber = [AppUtils removeAllSpecialInString: phoneNumber];
        _addressField.text = newPhoneNumber;
        searchView.hidden = YES;
    }
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
    
    [thread cancel];
    if ([thread isCancelled]) {
        thread = nil;
    }
}

- (void)displayAssistantConfigurationError {
    _lbStatus.textColor = UIColor.orangeColor;
    _lbStatus.text = [appDelegate.localization localizedStringForKey:@"Offline"];
}

#pragma mark - Actionsheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 100) {
        switch (buttonIndex) {
            case 0:{
                NewContactViewController *controller = VIEW(NewContactViewController);
                if (controller) {
                    controller.currentPhoneNumber = _addressField.text;
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
//    if ([touch.view isDescendantOfView: _tbSearch]) {
//        return NO;
//    }
    return YES;
}

#pragma mark - Call Button Delegate
- (void)textfieldAddressChanged:(NSString *)number {
    [self searchPhoneBookWithThread];
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
            break;
        }
        case LinphoneRegistrationNone:{
            NSLog(@"LinphoneRegistrationNone");
            break;
        }
        case LinphoneRegistrationCleared: {
            NSLog(@"LinphoneRegistrationCleared");
            break;
        }
        case LinphoneRegistrationFailed: {
            break;
        }
        case LinphoneRegistrationProgress: {
            NSLog(@"LinphoneRegistrationProgress");
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

//  Added by Khai Le on 30/09/2018
- (void)checkAccountForApp {
    LinphoneProxyConfig *defaultConfig = linphone_core_get_default_proxy_config(LC);
    if (defaultConfig == NULL) {
        _lbAccount.text = NSLocalizedString(@"", nil);
        _lbStatus.text = [appDelegate.localization localizedStringForKey:@"No account"];
    }else{
        const char *proxyUsername = linphone_address_get_username(linphone_proxy_config_get_identity_address(defaultConfig));
        NSString* defaultUsername = [NSString stringWithFormat:@"%s" , proxyUsername];
        if (defaultUsername != nil) {
            _lbAccount.text = defaultUsername;
        }
    }
}

//  Added by Khai Le on 03/10/2018
- (void)addBoxShadowForView: (UIView *)view withColor: (UIColor *)color{
    view.layer.shadowRadius  = 5.0f;
    view.layer.shadowColor   = color.CGColor;
    view.layer.shadowOffset  = CGSizeMake(0.0f, 0.0f);
    view.layer.shadowOpacity = 0.9f;
    view.layer.masksToBounds = NO;
    
    UIEdgeInsets shadowInsets     = UIEdgeInsetsMake(0, 0, -5.0f, 0);
    UIBezierPath *shadowPath      = [UIBezierPath bezierPathWithRect:UIEdgeInsetsInsetRect(view.bounds, shadowInsets)];
    view.layer.shadowPath    = shadowPath.CGPath;
}

- (void)whenNetworkChanged {
    NetworkStatus internetStatus = [appDelegate._internetReachable currentReachabilityStatus];
    if (internetStatus == NotReachable) {
        _lbStatus.text = [appDelegate.localization localizedStringForKey:@"No network"];
        _lbStatus.textColor = UIColor.orangeColor;
    }else{
        [self checkAccountForApp];
    }
}

//  Sẽ duyệt trong kết quả search, contact nào có đầy đủ tên và số phone sẽ đc chọn
- (NSArray *)getValidResultFromSearchResult
{
    NSString *name = @"";
    NSString *phone = @"";
    NSString *nameForSearch = @"";
    
    for (int iCount=0; iCount<listPhoneSearched.count; iCount++) {
        NSString *value = [listPhoneSearched objectAtIndex: iCount];
        NSArray *tmpArr = [value componentsSeparatedByString:@"|"];
        if (tmpArr.count >= 3) {
            name = [tmpArr firstObject];
            phone = [tmpArr lastObject];
            nameForSearch = [tmpArr objectAtIndex: 1];
            
            if (![name isEqualToString:@""] && ![phone isEqualToString:@""] && ![nameForSearch isEqualToString:@""]) {
                return @[name, nameForSearch, phone];
            }
        }
    }
    return @[@"", @"", @""];
}

- (void)whenTappedOnStatusAccount
{
    if ([LinphoneManager instance].connectivity == none){
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Please check your internet connection!"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    NSString *currentTitle = _lbStatus.text;
    if ([currentTitle isEqualToString:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"No account"]]){
        NSString *content = [NSString stringWithFormat:@"%@", [appDelegate.localization localizedStringForKey:@"You have not set up an account yet. Do you want to setup now?"]];
        
        UIAlertView *alertAcc = [[UIAlertView alloc] initWithTitle:nil message:content delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:@"Cancel"] otherButtonTitles: [appDelegate.localization localizedStringForKey:@"Go to settings?"], nil];
        [alertAcc show];
        return;
    }
    [LinphoneManager.instance refreshRegisters];
}

- (void)checkForShowFirstSettingAccount {
    NSString *needSetting = [[NSUserDefaults standardUserDefaults] objectForKey:@"SHOWED_SETTINGS_ACCOUNT_FOR_FIRST"];
    if (needSetting == nil){
        LinphoneProxyConfig *defaultConfig = linphone_core_get_default_proxy_config(LC);
        if (defaultConfig == NULL) {
            NSString *content = [NSString stringWithFormat:@"%@", [appDelegate.localization localizedStringForKey:@"You have not set up an account yet. Do you want to setup now?"]];
            
            UIAlertView *alertAcc = [[UIAlertView alloc] initWithTitle:nil message:content delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:@"Cancel"] otherButtonTitles: [appDelegate.localization localizedStringForKey:@"Go to settings?"], nil];
            [alertAcc show];
        }
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"SHOWED_SETTINGS_ACCOUNT_FOR_FIRST"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSAttributedString *)getSearchValueFromResult: (NSArray *)searchs
{
    NSString *name = @"";
    NSString *phone = @"";
    
    UIFont *font = [UIFont fontWithName:MYRIADPRO_BOLD size:16.0];
    NSMutableAttributedString *attrResult = [[NSMutableAttributedString alloc] init];
    
    if (searchs.count == 1) {
        id searchObj = [listPhoneSearched firstObject];
        if ([searchObj isKindOfClass:[PBXContact class]]) {
            name = [(PBXContact *)searchObj _name];
            phone = [(PBXContact *)searchObj _number];
        }else{
            NSArray *tmpArr = [searchObj componentsSeparatedByString:@"|"];
            if (tmpArr.count >= 3) {
                name = [tmpArr firstObject];
                phone = [tmpArr lastObject];
            }
        }
        [attrResult appendAttributedString:[[NSAttributedString alloc] initWithString: name]];
        [attrResult addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, name.length)];
        [attrResult addAttribute: NSLinkAttributeName value:phone range: NSMakeRange(0, name.length)];
    }else if (searchs.count == 2)
    {
        id firstContact = [listPhoneSearched firstObject];
        if ([firstContact isKindOfClass:[PBXContact class]]) {
            name = [(PBXContact *)firstContact _name];
        }else{
            NSArray *tmpArr = [firstContact componentsSeparatedByString:@"|"];
            if (tmpArr.count >= 3) {
                name = [tmpArr firstObject];
            }
        }
        [attrResult appendAttributedString:[[NSAttributedString alloc] initWithString: name]];
        [attrResult addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, name.length)];
        [attrResult addAttribute: NSLinkAttributeName value:phone range: NSMakeRange(0, name.length)];
        
        name = @"";
        phone = @"";
        
        id secondContact = [listPhoneSearched lastObject];
        if ([secondContact isKindOfClass:[PBXContact class]]) {
            name = [(PBXContact *)secondContact _name];
        }else{
            NSArray *tmpArr = [secondContact componentsSeparatedByString:@"|"];
            if (tmpArr.count >= 3) {
                name = [tmpArr firstObject];
            }
        }
        NSString *strOR = [NSString stringWithFormat:@" %@ ", [appDelegate.localization localizedStringForKey:@"or"]];
        [attrResult appendAttributedString:[[NSAttributedString alloc] initWithString: strOR]];
        
        NSMutableAttributedString *secondAttr = [[NSMutableAttributedString alloc] initWithString: name];
        [secondAttr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, name.length)];
        [secondAttr addAttribute: NSLinkAttributeName value:phone range: NSMakeRange(0, name.length)];
        [attrResult appendAttributedString:secondAttr];
    }else{
        
        id searchObj = [listPhoneSearched firstObject];
        if ([searchObj isKindOfClass:[PBXContact class]]) {
            name = [(PBXContact *)searchObj _name];
            phone = [(PBXContact *)searchObj _number];
        }else{
            NSArray *tmpArr = [searchObj componentsSeparatedByString:@"|"];
            if (tmpArr.count >= 3) {
                name = [tmpArr firstObject];
                phone = [tmpArr lastObject];
            }
        }
        
        NSMutableAttributedString * str1 = [[NSMutableAttributedString alloc] initWithString:name];
        [str1 addAttribute: NSLinkAttributeName value:phone range: NSMakeRange(0, name.length)];
        [str1 addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleNone) range:NSMakeRange(0, name.length)];
        [str1 addAttribute: NSFontAttributeName value: font range: NSMakeRange(0, name.length)];
        [attrResult appendAttributedString:str1];
        
        NSString *strAND = [NSString stringWithFormat:@" %@ ", [appDelegate.localization localizedStringForKey:@"and"]];
        NSMutableAttributedString * attrAnd = [[NSMutableAttributedString alloc] initWithString:strAND];
        [attrAnd addAttribute: NSFontAttributeName value: [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0]
                        range: NSMakeRange(0, strAND.length)];
        [attrResult appendAttributedString:attrAnd];
        
        NSString *strOthers = [NSString stringWithFormat:@"%lu %@", searchs.count-1, [appDelegate.localization localizedStringForKey:@"others"]];
        NSMutableAttributedString * str2 = [[NSMutableAttributedString alloc] initWithString:strOthers];
        [str2 addAttribute: NSLinkAttributeName value: @"others" range: NSMakeRange(0, strOthers.length)];
        [str2 addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleNone) range:NSMakeRange(0, strOthers.length)];
        [str2 addAttribute: NSFontAttributeName value: font range: NSMakeRange(0, strOthers.length)];
        [attrResult appendAttributedString:str2];
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [attrResult addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attrResult.string.length)];
    
    return attrResult;
}

//  Sẽ duyệt trong kết quả search, contact nào có đầy đủ tên và số phone sẽ đc chọn
- (NSArray *)convertContentToArrayValue: (NSString *)content
{
    NSString *name = @"";
    NSString *phone = @"";
    NSString *nameForSearch = @"";
    
    NSArray *tmpArr = [content componentsSeparatedByString:@"|"];
    if (tmpArr.count >= 3) {
        name = [tmpArr firstObject];
        phone = [tmpArr lastObject];
        nameForSearch = [tmpArr objectAtIndex: 1];
        
        if (![name isEqualToString:@""] && ![phone isEqualToString:@""] && ![nameForSearch isEqualToString:@""]) {
            return @[name, nameForSearch, phone];
        }
    }
    
    return @[@"", @"", @""];
}

#pragma mark - UIAlertview Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1){
        [[PhoneMainView instance] changeCurrentView:[PBXSettingViewController compositeViewDescription] push:YES];
    }
}

#pragma mark - UITextview delegate
-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    // Call your method here.
    if (![URL.absoluteString containsString:[appDelegate.localization localizedStringForKey:@"others"]]) {
        _addressField.text = URL.absoluteString;
        tvSearch.hidden = YES;
    }else{
        popupSearchContacts = [[SearchContactPopupView alloc] init];
        popupSearchContacts.contacts = listPhoneSearched;
        [popupSearchContacts showInView:appDelegate.window animated:YES];
        
        NSLog(@"OTHERSSSSSSSSSS");
    }
    return NO;
}


@end
