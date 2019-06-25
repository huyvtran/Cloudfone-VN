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
#import <AVFoundation/AVFoundation.h>
#import "PhoneBookContactCell.h"
#import "NSData+Base64.h"
#import <objc/runtime.h>
#import "ContactDetailObj.h"
#import "UIView+Toast.h"

#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import "PBXContact.h"
#import "AESCrypt.h"

#define LOG_CONTEXT_JS 1
#define DDLogJS(frmt, ...) LOG_OBJC_MAYBE(LOG_ASYNC_INFO, LOG_LEVEL_DEF, LOG_FLAG_INFO,    LOG_CONTEXT_JS, frmt, ##__VA_ARGS__)

#define LOG_CONTEXT_HTTP 2
#define DDLogHTTP(frmt, ...) LOG_OBJC_MAYBE(LOG_ASYNC_INFO, LOG_LEVEL_DEF, LOG_FLAG_INFO,    LOG_CONTEXT_HTTP, frmt, ##__VA_ARGS__)

@interface DialerView (){
    LinphoneAppDelegate *appDelegate;
    NSMutableArray *listPhoneSearched;
    
    UITapGestureRecognizer *tapOnScreen;
    NSTimer *pressTimer;
    
    UITextView *tvSearchResult;
    SearchContactPopupView *popupSearchContacts;
}
@end

@implementation DialerView
@synthesize _viewStatus, _imgLogoSmall, _lbAccount, _lbStatus;
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

- (void)setupForWriteLogFileForApp
{
    //  set logs file path
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    NSString *logFilePath = [documentsDir stringByAppendingPathComponent:@"One"];
    NSString *logFilePath2 = [documentsDir stringByAppendingPathComponent:@"Two"];
    
    DDLogFileManagerDefault *fileManagerJS = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:logFilePath];
    DDFileLogger *loggerJS = [[DDFileLogger alloc] initWithLogFileManager:fileManagerJS];
    
    DDContextWhitelistFilterLogFormatter *formatterJS = [[DDContextWhitelistFilterLogFormatter alloc] init];
    [formatterJS addToWhitelist:LOG_CONTEXT_JS];
    [loggerJS setLogFormatter:formatterJS];
    [DDLog addLogger:loggerJS];
    
    
    DDLogFileManagerDefault *fileManagerHttp = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:logFilePath2];
    DDFileLogger *loggerHttp = [[DDFileLogger alloc] initWithLogFileManager:fileManagerHttp];
    DDContextWhitelistFilterLogFormatter *formatterHttp = [[DDContextWhitelistFilterLogFormatter alloc] init];
    [formatterHttp addToWhitelist:LOG_CONTEXT_HTTP];
    [loggerHttp setLogFormatter:formatterHttp];
    [DDLog addLogger:loggerHttp];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    [WriteLogsUtils writeForGoToScreen: @"DialerView"];
    
//    [NgnFileUtils createDirectoryAndSubDirectory:@"One"];
//    [NgnFileUtils createDirectoryAndSubDirectory:@"Two"];
    
    [self setupForWriteLogFileForApp];
    
//    NSString* path = [[NSBundle mainBundle] pathForResource:@"file_encrypt"
//                                                     ofType:@"txt"];
//
//    NSString* content = [NSString stringWithContentsOfFile:path
//                                                  encoding:NSUTF8StringEncoding
//                                                     error:NULL];
//    NSString *decrypt = [AESCrypt decrypt:content password:AES_KEY];
//    NSLog(@"%@", decrypt);
    
    //  Added by Khai Le on 30/09/2018
    [self checkAccountForApp];
    
    //  setup cho key login
    [[LinphoneManager instance] lpConfigSetBool:FALSE forKey:@"enable_first_login_view_preference"];
    
    // Tắt màn hình cảm biến
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled: false];
    
    // invisible icon add contact & icon delete address
    _addContactButton.hidden = YES;
    _addressField.text = @"";
    
    //  update token of device if not yet
    if (![LinphoneAppDelegate sharedInstance]._updateTokenSuccess && ![AppUtils isNullOrEmpty: [LinphoneAppDelegate sharedInstance]._deviceToken])
    {
        [WriteLogsUtils writeLogContent:@"You haven't updated token device. Posted event updateTokenForXmpp" toFilePath:appDelegate.logFilePath];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:updateTokenForXmpp
                                                            object:nil];
    }
    
	_padView.hidden =
		!IPAD && UIInterfaceOrientationIsLandscape(PhoneMainView.instance.mainViewController.currentOrientation);

	// Set observer
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(callUpdateEvent:)
											   name:kLinphoneCallUpdate object:nil];
    
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

- (void)viewDidLoad {
	[super viewDidLoad];
    
    appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
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
    
    //  Check for Crash
    [self checkCrashHasOccuredBefore];
}

- (void)checkCrashHasOccuredBefore {
    NSString *crashFile = [[NSUserDefaults standardUserDefaults] objectForKey:@"crash_file"];
    if (![AppUtils isNullOrEmpty: crashFile])
    {
        if ([MFMailComposeViewController canSendMail]) {
            BOOL networkReady = [DeviceUtils checkNetworkAvailable];
            if (!networkReady) {
                return;
            }
            
            NSString *crashContent = [[NSUserDefaults standardUserDefaults] objectForKey:@"crash_content"];
            
            MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
            
            NSString *emailTitle =  @"Ứng dụng của bạn đã bị crash trước đây";
            NSString *messageBody = [NSString stringWithFormat:@"Xin vui lòng gửi thông tin cho chúng tôi để cải thiện sản phầm tốt hơn.\nXin chân thành cảm ơn.\n\n%@", crashContent];
            NSArray *toRecipents = @[@"lekhai0212@gmail.com"];
            NSArray *ccRecipents = @[@"cfreport@cloudfone.vn"];
            
            //  get content file
            NSString *path = [NgnFileUtils getPathOfFileWithSubDir:[NSString stringWithFormat:@"%@/%@", logsFolderName, crashFile]];
            NSString* content = [NSString stringWithContentsOfFile:path
                                                          encoding:NSUTF8StringEncoding
                                                             error:NULL];
            NSString *encryptStr = [AESCrypt encrypt:content password:AES_KEY];
            NSData *logFileData = [encryptStr dataUsingEncoding:NSUTF8StringEncoding];
            NSString *nameForSend = [DeviceUtils convertLogFileName: crashFile];
            [mc addAttachmentData:logFileData mimeType:@"text/plain" fileName:nameForSend];
            
            mc.mailComposeDelegate = self;
            [mc setSubject:emailTitle];
            [mc setMessageBody:messageBody isHTML:NO];
            [mc setToRecipients:toRecipents];
            [mc setCcRecipients: ccRecipents];
            
            [self presentViewController:mc animated:YES completion:NULL];
            
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"crash_file"];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"crash_content"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
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
						error:(NSError *)error
{
    [controller dismissViewControllerAnimated:TRUE
                                   completion:^{
                                       [self autoLayoutForView];
                                   }];
    if (result == MFMailComposeResultSent) {
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Your email was sent. Thank you!"] duration:4.0 position:CSToastPositionCenter];
        
    }else if (result == MFMailComposeResultSaved) {
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Your email was saved. Thank you!"] duration:4.0 position:CSToastPositionCenter];
        
    }else if (result == MFMailComposeResultFailed) {
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Failed to send email. Please check again!"] duration:4.0 position:CSToastPositionCenter];
    }
    [self.view layoutIfNeeded];
}

#pragma mark - Action Functions

- (IBAction)onAddContactClick:(id)event {
    if ([_addressField.text isEqualToString:USERNAME]) {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"You can not add yourself to contact list"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    UIActionSheet *popupAddContact = [[UIActionSheet alloc] initWithTitle:_addressField.text delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:@"Cancel"] destructiveButtonTitle:nil otherButtonTitles: [appDelegate.localization localizedStringForKey:@"Create new contact"], [appDelegate.localization localizedStringForKey:@"Add to existing contact"], nil];
    popupAddContact.tag = 100;
    [popupAddContact showInView:self.view];
}

- (IBAction)onBackClick:(id)event
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"%s", __FUNCTION__]
                         toFilePath:appDelegate.logFilePath];
    
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
        tvSearchResult.hidden = YES;
    }
}

- (void)onBackspaceLongClick:(id)sender {
    [self hideSearchView];
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

- (IBAction)_btnAddCallPressed:(UIButton *)sender
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] With address = %@", __FUNCTION__, _addressField.text]
                         toFilePath:appDelegate.logFilePath];
    
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
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Transfer call to %@", __FUNCTION__, _addressField.text] toFilePath:appDelegate.logFilePath];
    
    if (![_addressField.text isEqualToString:@""]) {
        LinphoneManager.instance.nextCallIsTransfer = YES;
        LinphoneAddress *addr = linphone_core_interpret_url(LC, _addressField.text.UTF8String);
        [LinphoneManager.instance call:addr];
        if (addr)
            linphone_address_destroy(addr);
    }
}

- (IBAction)_btnHotlinePressed:(UIButton *)sender
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Do you want to call to hotline for assistance?"] delegate:self cancelButtonTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Close"] otherButtonTitles: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Call"], nil];
    alert.delegate = self;
    alert.tag = 3;
    [alert show];
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
}

- (IBAction)_btnCallPressed:(UIButton *)sender {
    if (_addressField.text.length > 0) {
        tvSearchResult.hidden = YES;
        return;
    }
    
    [pressTimer invalidate];
    pressTimer = nil;
    pressTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self
                                                selector:@selector(searchPhoneBookWithThread)
                                                userInfo:nil repeats:false];
}

#pragma mark - Khai Le Functions

- (void)networkDown
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] OH SHITTTTTTTTT!", __FUNCTION__] toFilePath:appDelegate.logFilePath];
    
    _lbStatus.text = [appDelegate.localization localizedStringForKey:@"No network"];
    _lbStatus.textColor = UIColor.orangeColor;
}

- (void)searchPhoneBookWithThread {
    //  [Khai le - 01/11/2018]: Just search contact when contact was loaded
    if (!appDelegate.contactLoaded) {
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Contacts list have not loaded successful. Please wait for a momment", __FUNCTION__] toFilePath:appDelegate.logFilePath];
        
        return;
    }
    //  ----
    
    NSString *searchStr = _addressField.text;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        //  remove data before search
        if (listPhoneSearched == nil) {
            listPhoneSearched = [[NSMutableArray alloc] init];
        }
        [listPhoneSearched removeAllObjects];
        
        NSArray *searchArr = [self searchAllContactsWithString:searchStr inList:appDelegate.listInfoPhoneNumber];
        if (searchArr.count > 0) {
            [listPhoneSearched addObjectsFromArray: searchArr];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self searchContactDone];
        });
    });
}

- (NSArray *)searchAllContactsWithString: (NSString *)search inList: (NSArray *)list {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@ OR number CONTAINS[cd] %@ OR nameForSearch CONTAINS[cd] %@", search, search, search];
    NSArray *filter = [list filteredArrayUsingPredicate: predicate];
    return filter;
}

// Search duoc danh sach
- (void)searchContactDone
{
    if (_addressField.text.length == 0) {
        _addContactButton.hidden = YES;
    }else{
        _addContactButton.hidden = NO;
        
        //  [khai le - 02/11/2018]
        if (listPhoneSearched.count > 0) {
            tvSearchResult.hidden = NO;
            tvSearchResult.attributedText = [ContactUtils getSearchValueFromResultForNewSearchMethod: listPhoneSearched];
        }else{
            tvSearchResult.hidden = YES;
        }
    }
}

- (void)enableNAT
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__] toFilePath:appDelegate.logFilePath];
    
    LinphoneNatPolicy *LNP = linphone_core_get_nat_policy(LC);
    linphone_nat_policy_enable_ice(LNP, FALSE);
}

- (void)autoLayoutForView
{
    NSString *modelName = [DeviceUtils getModelsOfCurrentDevice];
    
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
    _lbStatus.numberOfLines = 0;
    [_lbStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewStatus.mas_centerX);
        make.top.bottom.equalTo(_lbAccount);
        make.right.equalTo(_viewStatus).offset(-appDelegate._hRegistrationState/4);
    }];
    UITapGestureRecognizer *tapOnStatus = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTappedOnStatusAccount)];
    _lbStatus.userInteractionEnabled = YES;
    [_lbStatus addGestureRecognizer: tapOnStatus];
    
    //  Number view
    float hNumber = 100.0;
    float hTextField = 60.0;
    if ([modelName isEqualToString: IphoneX_1] || [modelName isEqualToString: IphoneX_2] || [modelName isEqualToString: IphoneXR] || [modelName isEqualToString: IphoneXS] || [modelName isEqualToString: IphoneXS_Max1] || [modelName isEqualToString: IphoneXS_Max2] || [modelName isEqualToString: simulator])
    {
        hNumber = 120.0;
        hTextField = 80.0;
    }
    
    [_viewNumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(_viewStatus.mas_bottom);
        make.height.mas_equalTo(hNumber);
    }];
    
    [_addressField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewNumber).offset(10);
        make.left.equalTo(self.view).offset(80);
        make.right.equalTo(self.view).offset(-80);
        make.height.mas_equalTo(hTextField);
    }];
    _addressField.keyboardType = UIKeyboardTypePhonePad;
    _addressField.enabled = YES;
    _addressField.textAlignment = NSTextAlignmentCenter;
    _addressField.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:45.0];
    _addressField.adjustsFontSizeToFitWidth = YES;
    _addressField.delegate = self;
    [_addressField addTarget:self
                      action:@selector(addressfieldDidChanged:)
            forControlEvents:UIControlEventEditingChanged];
    
    tvSearchResult = [[UITextView alloc] init];
    tvSearchResult.backgroundColor = UIColor.clearColor;
    tvSearchResult.editable = NO;
    tvSearchResult.hidden = YES;
    tvSearchResult.delegate = self;
    [_viewNumber addSubview: tvSearchResult];
    
    [tvSearchResult mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewNumber).offset(10.0);
        make.right.equalTo(_viewNumber).offset(-10.0);
        make.top.equalTo(_addressField.mas_bottom);
        make.height.mas_equalTo(30.0);
    }];
    //  tvSearchResult.linkTextAttributes = @{NSUnderlineStyleAttributeName: NSUnderlineStyleNone};
    
    [_addContactButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewNumber).offset(10.0);
        make.centerY.equalTo(_addressField.mas_centerY).offset(-3);
        make.width.height.mas_equalTo(40.0);
    }];
    
    
    //  Number keypad
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
                [self hideSearchView];
                [[PhoneMainView instance] changeCurrentView:[NewContactViewController compositeViewDescription]
                                                       push:true];
                break;
            }
            case 1:{
                AllContactListViewController *controller = VIEW(AllContactListViewController);
                if (controller != nil) {
                    controller.phoneNumber = _addressField.text;
                }
                [self hideSearchView];
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

- (void)registrationUpdateEvent:(NSNotification *)notif {
    NSString *message = [notif.userInfo objectForKey:@"message"];
    [self registrationUpdate:[[notif.userInfo objectForKey:@"state"] intValue]
                    forProxy:[[notif.userInfo objectForKeyedSubscript:@"cfg"] pointerValue]
                     message:message];
}

- (void)registrationUpdate:(LinphoneRegistrationState)state forProxy:(LinphoneProxyConfig *)proxy message:(NSString *)message
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"-------------------------\n[%s] Received registration state = %d, message = %@\n-------------------------\n", __FUNCTION__, state, message] toFilePath:appDelegate.logFilePath];
    
    switch (state) {
        case LinphoneRegistrationOk: {
            _lbStatus.textColor = UIColor.greenColor;
            _lbStatus.text = [appDelegate.localization localizedStringForKey:@"Online"];
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
            _lbStatus.textColor = UIColor.orangeColor;
            if ([SipUtils getStateOfDefaultProxyConfig] == eAccountOff) {
                _lbStatus.text = [appDelegate.localization localizedStringForKey:@"Disabled"];
            }else{
                _lbStatus.text = [appDelegate.localization localizedStringForKey:@"Offline"];
            }
            break;
        }
        case LinphoneRegistrationProgress: {
            _lbStatus.textColor = UIColor.whiteColor;
            _lbStatus.text = [appDelegate.localization localizedStringForKey:@"Connecting"];
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
- (void)checkAccountForApp
{
    AccountState curState = [SipUtils getStateOfDefaultProxyConfig];
    if (curState == eAccountNone) {
        _lbAccount.text = @"";
        _lbStatus.text = [appDelegate.localization localizedStringForKey:@"No account"];
        _lbStatus.textColor = UIColor.orangeColor;
        
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] NONE ACCOUNT", __FUNCTION__] toFilePath:appDelegate.logFilePath];
    }else {
        NSString *accountID = [SipUtils getAccountIdOfDefaultProxyConfig];
        _lbAccount.text = accountID;
        if (curState == eAccountOff) {
            _lbStatus.text = [appDelegate.localization localizedStringForKey:@"Disabled"];
            _lbStatus.textColor = UIColor.orangeColor;
            
            [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] AccountId = %@, state is OFF", __FUNCTION__, accountID] toFilePath:appDelegate.logFilePath];
        }else{
            LinphoneRegistrationState state = [SipUtils getRegistrationStateOfDefaultProxyConfig];
            if (state == LinphoneRegistrationOk) {
                //  account on
                _lbStatus.textColor = UIColor.greenColor;
                _lbStatus.text = [appDelegate.localization localizedStringForKey:@"Online"];
            }else{
                _lbStatus.textColor = UIColor.orangeColor;
                _lbStatus.text = [appDelegate.localization localizedStringForKey:@"Offline"];
            }
            
            [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] AccountId = %@, state is ON", __FUNCTION__, accountID] toFilePath:appDelegate.logFilePath];
        }
    }
}

//  Added by Khai Le on 03/10/2018
- (void)addBoxShadowForView: (UIView *)view withColor: (UIColor *)color{
    view.layer.shadowRadius  = view.layer.cornerRadius;
    view.layer.shadowColor   = color.CGColor;
    view.layer.shadowOffset  = CGSizeMake(0.0f, 0.0f);
    view.layer.shadowOpacity = 0.9f;
    view.layer.masksToBounds = NO;
    
    UIEdgeInsets shadowInsets     = UIEdgeInsetsMake(0, 0, -5.0f, 0);
    UIBezierPath *shadowPath      = [UIBezierPath bezierPathWithRect:UIEdgeInsetsInsetRect(view.bounds, shadowInsets)];
    view.layer.shadowPath    = shadowPath.CGPath;
}

- (void)whenNetworkChanged {
    NetworkStatus internetStatus = [appDelegate.internetReachable currentReachabilityStatus];
    if (internetStatus == NotReachable) {
        _lbStatus.text = [appDelegate.localization localizedStringForKey:@"No network"];
        _lbStatus.textColor = UIColor.orangeColor;
    }else{
        [self checkAccountForApp];
    }
    
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] internetStatus = %d", __FUNCTION__, internetStatus] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
}

- (void)whenTappedOnStatusAccount
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__] toFilePath:appDelegate.logFilePath];
    
    if ([LinphoneManager instance].connectivity == none){
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Please check your internet connection!"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    AccountState curState = [SipUtils getStateOfDefaultProxyConfig];
    //  No account
    if (curState == eAccountNone) {
        NSString *content = [NSString stringWithFormat:@"%@", [appDelegate.localization localizedStringForKey:@"You have not set up an account yet. Do you want to setup now?"]];
        
        UIAlertView *alertAcc = [[UIAlertView alloc] initWithTitle:nil message:content delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:@"Cancel"] otherButtonTitles: [appDelegate.localization localizedStringForKey:@"Go to settings"], nil];
        alertAcc.delegate = self;
        alertAcc.tag = 1;
        [alertAcc show];
        return;
    }
    
    //  account was disabled
    if (curState == eAccountOff) {
        UIAlertView *alertAcc = [[UIAlertView alloc] initWithTitle:nil message:[appDelegate.localization localizedStringForKey:@"Do you want to enable this account?"] delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:@"No"] otherButtonTitles: [appDelegate.localization localizedStringForKey:@"Yes"], nil];
        alertAcc.delegate = self;
        alertAcc.tag = 2;
        [alertAcc show];
        return;
    }
    
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Call function %@", __FUNCTION__, @"refreshRegisters"] toFilePath:appDelegate.logFilePath];
    [LinphoneManager.instance refreshRegisters];
}

- (void)addressfieldDidChanged: (UITextField *)textfield {
    if (!textfield.isFirstResponder) {
        NSLog(@"Just search when text changed and textfield is focus");
        return;
    }
    if ([textfield.text isEqualToString:@""]) {
        _addContactButton.hidden = YES;
        tvSearchResult.hidden = YES;
        
        _addContactButton.hidden = YES;
    }else{
        _addContactButton.hidden = NO;
        
        [pressTimer invalidate];
        pressTimer = nil;
        pressTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self
                                                    selector:@selector(searchPhoneBookWithThread)
                                                    userInfo:nil repeats:false];
    }
}

- (void)hideSearchView {
    _addressField.text = @"";
    _addContactButton.hidden = YES;
    tvSearchResult.hidden = YES;
}

#pragma mark - UIAlertview Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"alertView.tag = %d, buttonIndex = %d", (int)alertView.tag, (int)buttonIndex] toFilePath:appDelegate.logFilePath];
    
    if (alertView.tag == 1)
    {
        if (buttonIndex == 1){
            [[PhoneMainView instance] changeCurrentView:[PBXSettingViewController compositeViewDescription] push:YES];
        }
    }
    else if (alertView.tag == 2){
        if (buttonIndex == 0) {
            [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] You don't want to enable this account with Id = %@", __FUNCTION__, [SipUtils getAccountIdOfDefaultProxyConfig]] toFilePath:appDelegate.logFilePath];
        }else if (buttonIndex == 1){
            LinphoneProxyConfig *defaultConfig = linphone_core_get_default_proxy_config(LC);
            if (defaultConfig != NULL) {
                linphone_proxy_config_enable_register(defaultConfig, YES);
                linphone_proxy_config_refresh_register(defaultConfig);
                linphone_proxy_config_done(defaultConfig);
                
                linphone_core_refresh_registers(LC);
                
                [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] You turned on account with Id = %@", __FUNCTION__, [SipUtils getAccountIdOfDefaultProxyConfig]] toFilePath:appDelegate.logFilePath];
            }
        }
        
    }else if (alertView.tag == 3 && buttonIndex == 1){
        [WriteLogsUtils writeLogContent:@"Make call to hotline" toFilePath:appDelegate.logFilePath];
        [SipUtils makeCallWithPhoneNumber: hotline];
    }
}

#pragma mark - UITextview delegate
-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    // Call your method here.
    if (![URL.absoluteString containsString:@"others"]) {
        _addressField.text = URL.absoluteString;
        tvSearchResult.hidden = YES;
    }else{
        float totalHeight = listPhoneSearched.count * 60.0;
        if (totalHeight > SCREEN_HEIGHT - 70.0*2) {
            totalHeight = SCREEN_HEIGHT - 70.0*2;
        }
        popupSearchContacts = [[SearchContactPopupView alloc] initWithFrame:CGRectMake(30.0, (SCREEN_HEIGHT-totalHeight)/2, SCREEN_WIDTH-60.0, totalHeight)];
        popupSearchContacts.contacts = listPhoneSearched;
        [popupSearchContacts.tbContacts reloadData];
        popupSearchContacts.delegate = self;
        [popupSearchContacts showInView:appDelegate.window animated:YES];
    }
    return NO;
}

- (void)selectContactFromSearchPopup:(NSString *)phoneNumber {
    _addressField.text = phoneNumber;
    tvSearchResult.hidden = YES;
}

@end
