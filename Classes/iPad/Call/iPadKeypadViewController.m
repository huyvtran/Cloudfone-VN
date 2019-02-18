//
//  iPadKeypadViewController.m
//  linphone
//
//  Created by admin on 1/11/19.
//

#import "iPadKeypadViewController.h"
#import "iPadAddContactViewController.h"
#import "iPadAllContactsListViewController.h"
#import "PBXSettingViewController.h"
#import "DeviceUtils.h"

@interface iPadKeypadViewController () {
    NSMutableArray *listPhoneSearched;
    UITapGestureRecognizer *tapOnScreen;
    NSTimer *pressTimer;
    
    SearchContactPopupView *popupSearchContacts;
}
@end

@implementation iPadKeypadViewController
@synthesize viewHeader, imgLogo, lbAccount, lbStatus;
@synthesize viewNumber, icAddContact, addressField, tvSearchResult;
@synthesize viewKeypad, oneButton, twoButton, threeButton, fourButton, fiveButton, sixButton, sevenButton, eightButton, nineButton, zeroButton, starButton, sharpButton, btnCall, btnHotline, btnBackspace;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupUIForView];
    
    //  my code here
    zeroButton.digit = '0';
    oneButton.digit = '1';
    twoButton.digit = '2';
    threeButton.digit = '3';
    fourButton.digit = '4';
    fiveButton.digit = '5';
    sixButton.digit = '6';
    sevenButton.digit = '7';
    eightButton.digit = '8';
    nineButton.digit = '9';
    starButton.digit = '*';
    sharpButton.digit = '#';
    
    
    
    UILongPressGestureRecognizer *backspaceLongGesture =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onBackspaceLongClick:)];
    [btnBackspace addGestureRecognizer:backspaceLongGesture];
    
    UILongPressGestureRecognizer *zeroLongGesture =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onZeroLongClick:)];
    [zeroButton addGestureRecognizer:zeroLongGesture];
    
    UILongPressGestureRecognizer *oneLongGesture =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onOneLongClick:)];
    [oneButton addGestureRecognizer:oneLongGesture];
    
    //  Tap tren ban phim
    tapOnScreen = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboards)];
    tapOnScreen.delegate = self;
    [self.view addGestureRecognizer: tapOnScreen];
    
    lbStatus.text = @"";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [WriteLogsUtils writeForGoToScreen: @"iPadKeypadViewController"];
    
    [self checkAccountForApp];
    
    [[LinphoneManager instance] lpConfigSetBool:FALSE forKey:@"enable_first_login_view_preference"];
    
    // Turn off proximity
    [UIDevice currentDevice].proximityMonitoringEnabled = NO;
    
    // invisible icon add contact & icon delete address
    icAddContact.hidden = YES;
    addressField.text = @"";
    
    //  update token of device if not yet
    if (![LinphoneAppDelegate sharedInstance]._updateTokenSuccess && ![AppUtils isNullOrEmpty: [LinphoneAppDelegate sharedInstance]._deviceToken])
    {
        [WriteLogsUtils writeLogContent:@"You haven't updated token device. Posted event updateTokenForXmpp" toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:updateTokenForXmpp
                                                            object:nil];
    }
    
    [self registerNotifications];
    
    // Update on show
    LinphoneCall *call = linphone_core_get_current_call(LC);
    LinphoneCallState state = (call != NULL) ? linphone_call_get_state(call) : 0;
    [self callUpdate:call state:state];
    
    [self enableNAT];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [LinphoneManager.instance shouldPresentLinkPopup];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NSNotificationCenter.defaultCenter removeObserver:self];
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
}
    

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)icAddContactClicked:(UIButton *)sender {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    if ([addressField.text isEqualToString:USERNAME]) {
        [[LinphoneAppDelegate sharedInstance].window makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"You can not add yourself to contact list"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    UIActionSheet *popupAddContact = [[UIActionSheet alloc] initWithTitle:addressField.text delegate:self cancelButtonTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Cancel"] destructiveButtonTitle:nil otherButtonTitles: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Create new contact"], [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Add to existing contact"], nil];
    popupAddContact.tag = 100;
    [popupAddContact showFromRect:addressField.bounds inView:addressField animated:YES];
    //  [popupAddContact showInView:self.view];
}

- (IBAction)btnBackspaceClicked:(id)sender {
    if (addressField.text.length > 0) {
        addressField.text = [addressField.text substringToIndex:[addressField.text length] - 1];
    }
    
    if (addressField.text.length > 0) {
        [pressTimer invalidate];
        pressTimer = nil;
        pressTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self
                                                    selector:@selector(searchPhoneBookWithThread)
                                                    userInfo:nil repeats:false];
    }else{
        icAddContact.hidden = YES;
        tvSearchResult.hidden = YES;
    }
}

- (IBAction)btnHotlineClicked:(UIButton *)sender {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Do you want to call to hotline for assistance?"] delegate:self cancelButtonTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Close"] otherButtonTitles: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Call"], nil];
    alert.delegate = self;
    alert.tag = 3;
    [alert show];
}

- (IBAction)btnNumberClicked:(id)sender {
    [self.view endEditing: true];
    //  Show or hide "add contact" button when textfield address changed
    if (addressField.text.length > 0){
        icAddContact.hidden = NO;
    }else{
        icAddContact.hidden = YES;
    }
    
    [pressTimer invalidate];
    pressTimer = nil;
    pressTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self
                                                selector:@selector(searchPhoneBookWithThread)
                                                userInfo:nil repeats:false];
}

- (void)setupUIForView {
    //  header
    self.view.backgroundColor = UIColor.whiteColor;
    
    float hHeader = STATUS_BAR_HEIGHT + [LinphoneAppDelegate sharedInstance].hNavigation;
    viewHeader.backgroundColor = IPAD_HEADER_BG_COLOR;
    [viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(hHeader);
    }];
    
    float top = STATUS_BAR_HEIGHT + ([LinphoneAppDelegate sharedInstance].hNavigation - HEIGHT_IPAD_HEADER_BUTTON)/2;
    [imgLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewHeader).offset(10.0);
        make.top.equalTo(viewHeader).offset(top);
        make.width.height.mas_equalTo(HEIGHT_HEADER_BTN);
    }];
    
    lbAccount.font = [UIFont fontWithName:MYRIADPRO_BOLD size:22.0];
    lbAccount.textAlignment = NSTextAlignmentCenter;
    [lbAccount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(imgLogo);
        make.centerX.equalTo(viewHeader.mas_centerX);
        make.width.mas_equalTo(150);
    }];
    
    //  status label
    lbStatus.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightRegular];
    //  lbStatus.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    lbStatus.numberOfLines = 0;
    [lbStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewHeader.mas_centerX);
        make.top.bottom.equalTo(lbAccount);
        make.right.equalTo(viewHeader).offset(-10.0);
    }];
    UITapGestureRecognizer *tapOnStatus = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTappedOnStatusAccount)];
    lbStatus.userInteractionEnabled = YES;
    [lbStatus addGestureRecognizer: tapOnStatus];
    
    
    //  view keypad
    
    //  Number keypad
    float wIcon = 78.0;
    float spaceMarginY = 18;
    float spaceMarginX = 24;
    float hKeypad = (5*wIcon + 6*spaceMarginY);
    
    viewKeypad.backgroundColor = UIColor.clearColor;
    [viewKeypad mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view.mas_centerY);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(hKeypad);
    }];
    
    //  1, 2, 3
    twoButton.backgroundColor = UIColor.clearColor;
    twoButton.layer.cornerRadius = wIcon/2;
    twoButton.clipsToBounds = YES;
    [twoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewKeypad).offset(spaceMarginY);
        make.centerX.equalTo(viewKeypad.mas_centerX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    oneButton.layer.cornerRadius = wIcon/2;
    oneButton.clipsToBounds = YES;
    [oneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(twoButton);
        make.right.equalTo(twoButton.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    threeButton.layer.cornerRadius = wIcon/2;
    threeButton.clipsToBounds = YES;
    [threeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(twoButton);
        make.left.equalTo(twoButton.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    //  4, 5, 6
    fiveButton.layer.cornerRadius = wIcon/2;
    fiveButton.clipsToBounds = YES;
    [fiveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(twoButton.mas_bottom).offset(spaceMarginY);
        make.centerX.equalTo(twoButton.mas_centerX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    fourButton.layer.cornerRadius = wIcon/2;
    fourButton.clipsToBounds = YES;
    [fourButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fiveButton.mas_top);
        make.right.equalTo(fiveButton.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    sixButton.layer.cornerRadius = wIcon/2;
    sixButton.clipsToBounds = YES;
    [sixButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fiveButton.mas_top);
        make.left.equalTo(fiveButton.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    //  7, 8, 9
    eightButton.layer.cornerRadius = wIcon/2;
    eightButton.clipsToBounds = YES;
    [eightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fiveButton.mas_bottom).offset(spaceMarginY);
        make.centerX.equalTo(viewKeypad.mas_centerX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    sevenButton.layer.cornerRadius = wIcon/2;
    sevenButton.clipsToBounds = YES;
    [sevenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(eightButton.mas_top);
        make.right.equalTo(eightButton.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    nineButton.layer.cornerRadius = wIcon/2;
    nineButton.clipsToBounds = YES;
    [nineButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(eightButton.mas_top);
        make.left.equalTo(eightButton.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    //  *, 0, #
    zeroButton.layer.cornerRadius = wIcon/2;
    zeroButton.clipsToBounds = YES;
    [zeroButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(eightButton.mas_bottom).offset(spaceMarginY);
        make.centerX.equalTo(viewKeypad.mas_centerX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    starButton.layer.cornerRadius = wIcon/2;
    starButton.clipsToBounds = YES;
    [starButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(zeroButton.mas_top);
        make.right.equalTo(zeroButton.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    sharpButton.layer.cornerRadius = wIcon/2;
    sharpButton.clipsToBounds = YES;
    [sharpButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(zeroButton.mas_top);
        make.left.equalTo(zeroButton.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    //  fifth layer
    btnCall.layer.cornerRadius = wIcon/2;
    btnCall.clipsToBounds = YES;
    [btnCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(zeroButton.mas_bottom).offset(spaceMarginY);
        make.centerX.equalTo(viewKeypad.mas_centerX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    btnHotline.layer.cornerRadius = wIcon/2;
    btnHotline.clipsToBounds = YES;
    [btnHotline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnCall.mas_top);
        make.right.equalTo(btnCall.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    btnBackspace.layer.cornerRadius = wIcon/2;
    btnBackspace.clipsToBounds = YES;
    [btnBackspace mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnCall.mas_top);
        make.left.equalTo(btnCall.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    //  view number
    float numberPadding = 20.0;
    viewNumber.backgroundColor = UIColor.clearColor;
    [viewNumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(viewKeypad.mas_top);
    }];
    
    [icAddContact mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewNumber).offset(numberPadding);
        make.centerY.equalTo(viewNumber.mas_centerY);
        make.width.height.mas_equalTo(40.0);
    }];
    
    
    [addressField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(icAddContact.mas_right).offset(10.0);
        make.right.equalTo(self.view).offset(-numberPadding-40.0-10.0);
        make.centerY.equalTo(viewNumber.mas_centerY);
        make.height.mas_equalTo(80.0);
    }];
    addressField.adjustsFontSizeToFitWidth = YES;
    addressField.backgroundColor = UIColor.clearColor;
    addressField.keyboardType = UIKeyboardTypePhonePad;
    addressField.enabled = YES;
    addressField.textAlignment = NSTextAlignmentCenter;
    addressField.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:45.0];
    addressField.adjustsFontSizeToFitWidth = YES;
    addressField.delegate = self;
    [addressField addTarget:self
                     action:@selector(addressfieldDidChanged:)
           forControlEvents:UIControlEventEditingChanged];
    
    tvSearchResult.backgroundColor = UIColor.clearColor;
    tvSearchResult.font = [UIFont systemFontOfSize:30.0 weight:UIFontWeightMedium];
    tvSearchResult.editable = NO;
    tvSearchResult.hidden = YES;
    tvSearchResult.delegate = self;
    [tvSearchResult mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewNumber).offset(numberPadding);
        make.right.equalTo(viewNumber).offset(-10.0);
        make.top.equalTo(addressField.mas_bottom);
        make.height.mas_equalTo(30.0);
    }];
}

- (void)onBackspaceLongClick:(id)sender {
    [self hideSearchView];
}

- (void)hideSearchView {
    addressField.text = @"";
    icAddContact.hidden = YES;
    tvSearchResult.hidden = YES;
}

- (void)onZeroLongClick:(id)sender {
    // replace last character with a '+'
    NSString *newAddress =
    [[addressField.text substringToIndex:[addressField.text length] - 1] stringByAppendingString:@"+"];
    [addressField setText:newAddress];
    linphone_core_stop_dtmf(LC);
}

- (void)onOneLongClick:(id)sender {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
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
    [addressField resignFirstResponder];
}

- (void)addressfieldDidChanged: (UITextField *)textfield {
    if (!textfield.isFirstResponder) {
        NSLog(@"Just search when text changed and textfield is focus");
        return;
    }
    if ([textfield.text isEqualToString:@""]) {
        icAddContact.hidden = YES;
        tvSearchResult.hidden = YES;
    }else{
        icAddContact.hidden = NO;
        
        [pressTimer invalidate];
        pressTimer = nil;
        pressTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self
                                                    selector:@selector(searchPhoneBookWithThread)
                                                    userInfo:nil repeats:false];
    }
}
    
- (void)searchPhoneBookWithThread {
    if (![LinphoneAppDelegate sharedInstance].contactLoaded) {
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Contacts list have not loaded successful. Please wait for a momment", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        return;
    }
    
    NSString *searchStr = addressField.text;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        //  remove data before search
        if (listPhoneSearched == nil) {
            listPhoneSearched = [[NSMutableArray alloc] init];
        }
        [listPhoneSearched removeAllObjects];
        
        NSArray *searchArr = [self searchAllContactsWithString:searchStr inList:[LinphoneAppDelegate sharedInstance].listInfoPhoneNumber];
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
    if (addressField.text.length == 0) {
        icAddContact.hidden = YES;
    }else{
        icAddContact.hidden = NO;
        
        if (listPhoneSearched.count > 0) {
            tvSearchResult.hidden = NO;
            tvSearchResult.attributedText = [ContactUtils getSearchValueFromResultForNewSearchMethod: listPhoneSearched];
        }else{
            tvSearchResult.hidden = YES;
        }
    }
}

- (void)checkAccountForApp
{
    AccountState curState = [SipUtils getStateOfDefaultProxyConfig];
    if (curState == eAccountNone) {
        lbAccount.text = @"";
        lbStatus.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"No account"];
        lbStatus.textColor = UIColor.orangeColor;
        
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] NONE ACCOUNT", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    }else {
        NSString *accountID = [SipUtils getAccountIdOfDefaultProxyConfig];
        lbAccount.text = accountID;
        if (curState == eAccountOff) {
            lbStatus.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Disabled"];
            lbStatus.textColor = UIColor.orangeColor;
            [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] AccountId = %@, state is OFF", __FUNCTION__, accountID] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        }else{
            LinphoneRegistrationState state = [SipUtils getRegistrationStateOfDefaultProxyConfig];
            if (state == LinphoneRegistrationOk) {
                //  account on
                lbStatus.textColor = UIColor.greenColor;
                lbStatus.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Online"];
            }else{
                if (![DeviceUtils checkNetworkAvailable]) {
                    lbStatus.textColor = UIColor.orangeColor;
                    lbStatus.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"No network"];
                    
                }else{
                    lbStatus.textColor = UIColor.orangeColor;
                    lbStatus.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Offline"];
                }
            }
            
            [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] AccountId = %@, state is ON", __FUNCTION__, accountID] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        }
    }
}

- (void)registerNotifications {
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
}

- (void)setAddress:(NSString *)address {
    addressField.text = address;
}

- (void)enableNAT
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    LinphoneNatPolicy *LNP = linphone_core_get_nat_policy(LC);
    linphone_nat_policy_enable_ice(LNP, FALSE);
}

- (void)networkDown {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] OH SHITTTTTTTTT!", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    lbStatus.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"No network"];
    lbStatus.textColor = UIColor.orangeColor;
}

- (void)whenNetworkChanged {
    NetworkStatus internetStatus = [[LinphoneAppDelegate sharedInstance].internetReachable currentReachabilityStatus];
    if (internetStatus == NotReachable) {
        lbStatus.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"No network"];
        lbStatus.textColor = UIColor.orangeColor;
    }else{
        [self checkAccountForApp];
    }
    
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] internetStatus = %d", __FUNCTION__, internetStatus] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
}

- (void)whenTappedOnStatusAccount
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    if ([LinphoneManager instance].connectivity == none){
        [[LinphoneAppDelegate sharedInstance].window makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Please check your internet connection!"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    AccountState curState = [SipUtils getStateOfDefaultProxyConfig];
    //  No account
    if (curState == eAccountNone) {
        [[LinphoneAppDelegate sharedInstance].window makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"You have not set up an account yet. Do you want to setup now?"] duration:2.5 position:CSToastPositionCenter];
        return;
    }
    
    //  account was disabled
    if (curState == eAccountOff) {
        UIAlertView *alertAcc = [[UIAlertView alloc] initWithTitle:nil message:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Do you want to enable this account?"] delegate:self cancelButtonTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"No"] otherButtonTitles: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Yes"], nil];
        alertAcc.delegate = self;
        alertAcc.tag = 2;
        [alertAcc show];
        return;
    }
    
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Call function %@", __FUNCTION__, @"refreshRegisters"] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    [LinphoneManager.instance refreshRegisters];
}

#pragma mark - Event Functions

- (void)callUpdateEvent:(NSNotification *)notif {
    LinphoneCall *call = [[notif.userInfo objectForKey:@"call"] pointerValue];
    LinphoneCallState state = [[notif.userInfo objectForKey:@"state"] intValue];
    [self callUpdate:call state:state];
}

- (void)callUpdate:(LinphoneCall *)call state:(LinphoneCallState)state {
    /*
    LinphoneCore *lc = [LinphoneManager getLc];
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
    */
}

- (void)registrationUpdateEvent:(NSNotification *)notif {
    NSString *message = [notif.userInfo objectForKey:@"message"];
    [self registrationUpdate:[[notif.userInfo objectForKey:@"state"] intValue]
                    forProxy:[[notif.userInfo objectForKeyedSubscript:@"cfg"] pointerValue]
                     message:message];
}

- (void)registrationUpdate:(LinphoneRegistrationState)state forProxy:(LinphoneProxyConfig *)proxy message:(NSString *)message
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"-------------------------\n[%s] Received registration state = %d, message = %@\n-------------------------\n", __FUNCTION__, state, message] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    switch (state) {
        case LinphoneRegistrationOk: {
            lbStatus.textColor = UIColor.greenColor;
            lbStatus.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Online"];
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
            lbStatus.textColor = UIColor.orangeColor;
            if ([SipUtils getStateOfDefaultProxyConfig] == eAccountOff) {
                lbStatus.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Disabled"];
            }else{
                lbStatus.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Offline"];
            }
            break;
        }
        case LinphoneRegistrationProgress: {
            lbStatus.textColor = UIColor.whiteColor;
            lbStatus.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Connecting"];
            break;
        }
        default:
            break;
    }
}

- (void)afterEndCallForTransfer {
    icAddContact.hidden = YES;
    addressField.text = @"";
}

#pragma mark - Actionsheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 100) {
        switch (buttonIndex) {
            case 0:{
                iPadAddContactViewController *contentVC = [[iPadAddContactViewController alloc] initWithNibName:@"iPadAddContactViewController" bundle:nil];
                
                if (contentVC) {
                    contentVC.currentPhoneNumber = addressField.text;
                    contentVC.currentName = @"";
                }
                [self hideSearchView];
                
                UINavigationController *navigationVC = [AppUtils createNavigationWithController: contentVC];
                [AppUtils showDetailViewWithController: navigationVC];
                
                break;
            }
            case 1:{
                iPadAllContactsListViewController *contentVC = [[iPadAllContactsListViewController alloc] initWithNibName:@"iPadAllContactsListViewController" bundle:nil];
                if (contentVC != nil) {
                    contentVC.phoneNumber = addressField.text;
                }
                [self hideSearchView];
                
                UINavigationController *navigationVC = [AppUtils createNavigationWithController: contentVC];
                [AppUtils showDetailViewWithController: navigationVC];
                
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - UITextview delegate
-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    // Call your method here.
    if (![URL.absoluteString containsString:@"others"]) {
        addressField.text = URL.absoluteString;
        tvSearchResult.hidden = YES;
    }else{
        float totalHeight = listPhoneSearched.count * 60.0;
        if (totalHeight > SCREEN_HEIGHT - 70.0*2) {
            totalHeight = SCREEN_HEIGHT - 70.0*2;
        }
        
        popupSearchContacts = [[SearchContactPopupView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-400)/2, (SCREEN_HEIGHT-totalHeight)/2, 400, totalHeight)];
        popupSearchContacts.contacts = listPhoneSearched;
        [popupSearchContacts.tbContacts reloadData];
        popupSearchContacts.delegate = self;
        [popupSearchContacts showInView:[LinphoneAppDelegate sharedInstance].window animated:YES];
    }
    return NO;
}

- (void)selectContactFromSearchPopup:(NSString *)phoneNumber {
    addressField.text = phoneNumber;
    tvSearchResult.hidden = YES;
}

#pragma mark - UIAlertview Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1)
    {
        if (buttonIndex == 1){
            [[PhoneMainView instance] changeCurrentView:[PBXSettingViewController compositeViewDescription] push:YES];
        }
    }
    else if (alertView.tag == 2){
        if (buttonIndex == 0) {
            [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] You don't want to enable this account with Id = %@", __FUNCTION__, [SipUtils getAccountIdOfDefaultProxyConfig]] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        }else if (buttonIndex == 1){
            LinphoneProxyConfig *defaultConfig = linphone_core_get_default_proxy_config(LC);
            if (defaultConfig != NULL) {
                linphone_proxy_config_enable_register(defaultConfig, YES);
                linphone_proxy_config_refresh_register(defaultConfig);
                linphone_proxy_config_done(defaultConfig);
                
                linphone_core_refresh_registers(LC);
                
                [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] You turned on account with Id = %@", __FUNCTION__, [SipUtils getAccountIdOfDefaultProxyConfig]] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
            }
        }
        
    }else if (alertView.tag == 3) {
        //  call to hotline
        if (buttonIndex == 1) {
            BOOL result = [SipUtils makeCallWithPhoneNumber: hotline];
            if (!result) {
                [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Can not make call to hotline", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
            }
        }
    }
}

#pragma mark - Tap Gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView: tvSearchResult]) {
        return NO;
    }
    return YES;
}

@end
