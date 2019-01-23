//
//  iPadPBXSettingViewController.m
//  linphone
//
//  Created by lam quang quan on 1/14/19.
//

#import "iPadPBXSettingViewController.h"
#import "CustomTextAttachment.h"
#import "QRCodeReaderViewController.h"
#import "QRCodeReader.h"
#import <CommonCrypto/CommonDigest.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "InfoForNewContactTableCell.h"

@interface iPadPBXSettingViewController () {
    AccountState accState;
    CustomSwitchButton *swAccount;
    
    BOOL turnOffAcc;
    BOOL turnOnAcc;
    
    BOOL clearingAccount;
    LinphoneProxyConfig *enableProxyConfig;
    int typeRegister;
    
    NSString *serverPBX;
    NSString *accountPBX;
    NSString *passwordPBX;
    NSString *ipPBX;
    NSString *portPBX;
    RegisterPBXWithPhoneView *viewPBXRegisterWithPhone;
    
    NSTimer *timeoutTimer;
    
    UIBarButtonItem *btnQRCode;
    UIButton *btnScanFromPhoto;
    QRCodeReaderViewController *scanQRCodeVC;
}

@end

@implementation iPadPBXSettingViewController
@synthesize icWaiting, viewContent, lbPBX, swChange, lbSepa, lbServerID, tfServerID, lbAccount, tfAccount, lbPassword, tfPassword, btnClear, btnSave, btnLoginWithPhone, webService;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUIForView];
    
    UITapGestureRecognizer *tapOnScreen = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard)];
    [self.view addGestureRecognizer: tapOnScreen];
    
    //  Init for webservice
    webService = [[WebServices alloc] init];
    webService.delegate = self;
    
    [self createQRCodeButtonForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [WriteLogsUtils writeForGoToScreen: @"iPadPBXSettingViewController"];
    
    clearingAccount = NO;
    
    [self showContentForView];
    [self showPBXAccountInformation];
    
    accState = [SipUtils getStateOfDefaultProxyConfig];
    switch (accState) {
        case eAccountNone:{
            [swAccount setUIForDisableStateWithActionTarget: NO];
            btnClear.enabled = NO;
            break;
        }
        case eAccountOff:{
            [swAccount setUIForDisableStateWithActionTarget:NO];
            btnClear.enabled = YES;
            break;
        }
        case eAccountOn:{
            [swAccount setUIForEnableStateWithActionTarget:NO];
            btnClear.enabled = YES;
            break;
        }
        default:
            break;
    }
    
    //  set title for button login with phone number
    NSString *phoneContent = [NSString stringWithFormat:@" %@", [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Register with phone number"]];
    NSAttributedString *phoneStr = [self createAttributeStringWithContent:phoneContent imageName:@"ic_phone_login.png" isLeadImage:YES withHeight:22.0];
    [btnLoginWithPhone setAttributedTitle:phoneStr forState:UIControlStateNormal];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(registrationUpdateEvent:)
                                               name:kLinphoneRegistrationUpdate object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    BOOL state;
    BOOL isEnabled;
    accState = [SipUtils getStateOfDefaultProxyConfig];
    if (accState == eAccountOn) {
        isEnabled = YES;
        state = YES;
    }else if (accState == eAccountOff){
        isEnabled = YES;
        state = NO;
    }else{
        isEnabled = NO;
        state = NO;
    }
    
    float tmpWidth = 70.0;
    swAccount = [[CustomSwitchButton alloc] initWithState:state frame:CGRectMake(self.view.frame.size.width-20-tmpWidth, (80.0-31.0)/2, tmpWidth, 31.0)];
    swAccount.delegate = self;
    swAccount.backgroundColor = UIColor.redColor;
    [viewContent addSubview: swAccount];
}

-(void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnClearPressed:(UIButton *)sender
{
    BOOL networkReady = [DeviceUtils checkNetworkAvailable];
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Clear proxy config with networkReady = %d", __FUNCTION__, networkReady] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    if (!networkReady) {
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Please check your internet connection!"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    [icWaiting startAnimating];
    icWaiting.hidden = NO;
    clearingAccount = YES;
    linphone_core_clear_proxy_config(LC);
    //  [[LinphoneManager instance] removeAllAccounts];
}

- (IBAction)btnSavePressed:(UIButton *)sender {
    [self.view endEditing: YES];
    
    BOOL networkReady = [DeviceUtils checkNetworkAvailable];
    
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Save proxy config with networkReady = %d", __FUNCTION__, networkReady] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    if (!networkReady) {
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Please check your internet connection!"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    if ([tfServerID.text isEqualToString:@""]) {
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Server ID can't empty"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    if ([tfAccount.text isEqualToString:@""]){
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Account can't empty"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    if ([tfPassword.text isEqualToString:@""]){
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Password can't empty"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    //  check if this account is default and registration state is okay
    BOOL same = [self checkAccount: tfAccount.text withServer: tfServerID.text];
    if (!same) {
        typeRegister = normalLogin;
        
        icWaiting.hidden = NO;
        [icWaiting startAnimating];
        
        [self getInfoForPBXWithServerName: tfServerID.text];
        
    }else{
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"This account is being registered"] duration:2.0 position:CSToastPositionCenter];
    }
}

- (IBAction)btnLoginWithPhonePressed:(UIButton *)sender {
    [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"This feature have not supported yet. Please try later!"] duration:2.0 position:CSToastPositionCenter];
    return;
    NSArray *toplevelObject = [[NSBundle mainBundle] loadNibNamed:@"RegisterPBXWithPhoneView" owner:nil options:nil];
    for(id currentObject in toplevelObject){
        if ([currentObject isKindOfClass:[RegisterPBXWithPhoneView class]]) {
            viewPBXRegisterWithPhone = (RegisterPBXWithPhoneView *) currentObject;
            break;
        }
    }
    viewPBXRegisterWithPhone.delegate = self;
    viewPBXRegisterWithPhone.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
    [viewPBXRegisterWithPhone setupUIForView];
    [self.view addSubview: viewPBXRegisterWithPhone];
    
    [UIView animateWithDuration:0.25 animations:^{
        viewPBXRegisterWithPhone.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }];
}

- (void)showContentForView {
    self.title = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"PBX account"];
    
    lbPBX.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"PBX"];
    lbServerID.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Server ID"];
    lbAccount.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Account"];
    lbPassword.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Password"];
    
    [btnClear setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Clear"]
               forState:UIControlStateNormal];
    [btnSave setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Save"]
              forState:UIControlStateNormal];
}

- (void)showPBXAccountInformation
{
    LinphoneProxyConfig *defaultConfig = linphone_core_get_default_proxy_config(LC);
    if (defaultConfig != NULL) {
        const char *proxyUsername = linphone_address_get_username(linphone_proxy_config_get_identity_address(defaultConfig));
        NSString* defaultUsername = [NSString stringWithFormat:@"%s" , proxyUsername];
        if (defaultUsername != nil) {
            tfAccount.text = defaultUsername;
            tfPassword.text = [[NSUserDefaults standardUserDefaults] objectForKey: key_password];
            tfServerID.text = [[NSUserDefaults standardUserDefaults] objectForKey: PBX_SERVER];
            
            btnSave.enabled = NO;
        }
    }else{
        btnSave.enabled = NO;
    }
}

- (void)whenTextfieldDidChanged {
    //  check value is empty
    if ([tfServerID.text isEqualToString: @""] || [tfAccount.text isEqualToString: @""] || [tfPassword.text isEqualToString: @""]) {
        btnSave.enabled = NO;
        return;
    }
    btnSave.enabled = YES;
}

- (void)closeKeyboard {
    [self.view endEditing: YES];
}

- (void)createQRCodeButtonForView {
    UIButton *qrCode = [UIButton buttonWithType:UIButtonTypeCustom];
    qrCode.backgroundColor = UIColor.clearColor;
    [qrCode setImage:[UIImage imageNamed:@"qr-code-scan.png"] forState:UIControlStateNormal];
    qrCode.frame = CGRectMake(17, 0, 50.0, 50.0 );
    [qrCode addTarget:self
               action:@selector(onQRCodeClicked)
     forControlEvents:UIControlEventTouchUpInside];
    
    UIView *qrCodeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50.0, 50.0)];
    [qrCodeView addSubview: qrCode];
    
    btnQRCode = [[UIBarButtonItem alloc] initWithCustomView: qrCodeView];
    btnQRCode.customView.backgroundColor = UIColor.clearColor;
    self.navigationItem.rightBarButtonItem = btnQRCode;
}

- (void)setupUIForView
{
    //  [Khai le - 22/10/2018]: detect with iPhone 5, 5s, 5c and SE
    float hMargin = 40.0;
    float hLabel = 45.0;
    float hButton = 50.0;
    
    float marginX = 30.0;
    self.view.backgroundColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                                 blue:(230/255.0) alpha:1.0];
    
    icWaiting.backgroundColor = UIColor.whiteColor;
    icWaiting.alpha = 0.5;
    icWaiting.hidden = YES;
    [icWaiting mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    
    
    //  content view
    float hViewContent = 80.0 + 2.0 + (hLabel + IPAD_HEIGHT_TF) + 15 + (hLabel + IPAD_HEIGHT_TF) + 15 + (hLabel + IPAD_HEIGHT_TF) + 150;
    viewContent.backgroundColor = UIColor.whiteColor;
    [viewContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(hViewContent);
    }];
    
    lbPBX.textColor = [UIColor colorWithRed:(80/255.0) green:(80/255.0)
                                        blue:(80/255.0) alpha:1.0];
    lbPBX.font = [UIFont fontWithName:HelveticaNeue size:20.0];
    [lbPBX mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewContent).offset(marginX);
        make.top.equalTo(viewContent);
        make.height.mas_equalTo(80.0);
        make.right.equalTo(viewContent.mas_centerX);
    }];
    
    lbSepa.backgroundColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                               blue:(230/255.0) alpha:1.0];
    [lbSepa mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbPBX.mas_bottom);
        make.left.equalTo(lbPBX);
        make.right.equalTo(viewContent).offset(-marginX);
        make.height.mas_equalTo(1.0);
    }];
    
    //  server ID
    lbServerID.textColor = lbPBX.textColor;
    lbServerID.font = lbPBX.font;
    [lbServerID mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbSepa.mas_bottom).offset(15);
        make.left.right.equalTo(lbSepa);
        make.height.mas_equalTo(hLabel);
    }];
    
    
    tfServerID.borderStyle = UITextBorderStyleNone;
    tfServerID.layer.cornerRadius = 3.0;
    tfServerID.layer.borderWidth = 1.0;
    tfServerID.layer.borderColor = lbSepa.backgroundColor.CGColor;
    tfServerID.font = [UIFont fontWithName:HelveticaNeueBold size:20.0];
    [tfServerID mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbServerID.mas_bottom);
        make.left.right.equalTo(lbServerID);
        make.height.mas_equalTo(IPAD_HEIGHT_TF);
    }];
    [tfServerID addTarget:self
                    action:@selector(whenTextfieldDidChanged)
          forControlEvents:UIControlEventEditingChanged];
    
    tfServerID.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8.0, 40.0)];
    tfServerID.leftViewMode = UITextFieldViewModeAlways;
    
    //  account
    lbAccount.textColor = lbPBX.textColor;
    lbAccount.font = lbPBX.font;
    [lbAccount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tfServerID.mas_bottom).offset(15);
        make.left.right.equalTo(tfServerID);
        make.height.mas_equalTo(lbServerID.mas_height);
    }];
    
    tfAccount.borderStyle = UITextBorderStyleNone;
    tfAccount.layer.cornerRadius = 3.0;
    tfAccount.layer.borderWidth = 1.0;
    tfAccount.layer.borderColor = lbSepa.backgroundColor.CGColor;
    tfAccount.font = tfServerID.font;
    [tfAccount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbAccount.mas_bottom);
        make.left.right.equalTo(lbAccount);
        make.height.equalTo(tfServerID.mas_height);
    }];
    tfAccount.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8.0, 40.0)];
    tfAccount.leftViewMode = UITextFieldViewModeAlways;
    
    [tfAccount addTarget:self
                   action:@selector(whenTextfieldDidChanged)
         forControlEvents:UIControlEventEditingChanged];
    
    //  password
    lbPassword.textColor = lbPBX.textColor;
    lbPassword.font = lbPBX.font;
    [lbPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tfAccount.mas_bottom).offset(15);
        make.left.right.equalTo(tfAccount);
        make.height.mas_equalTo(lbServerID.mas_height);
    }];
    
    tfPassword.borderStyle = UITextBorderStyleNone;
    tfPassword.layer.cornerRadius = 3.0;
    tfPassword.layer.borderWidth = 1.0;
    tfPassword.layer.borderColor = lbSepa.backgroundColor.CGColor;
    tfPassword.font = tfServerID.font;
    [tfPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbPassword.mas_bottom);
        make.left.right.equalTo(lbPassword);
        make.height.equalTo(tfServerID.mas_height);
    }];
    tfPassword.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8.0, 40.0)];
    tfPassword.leftViewMode = UITextFieldViewModeAlways;
    [tfPassword addTarget:self
                    action:@selector(whenTextfieldDidChanged)
          forControlEvents:UIControlEventEditingChanged];
    
    //  footer button
    [btnClear mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tfPassword.mas_bottom).offset(hMargin);
        make.left.equalTo(tfPassword);
        make.right.equalTo(viewContent.mas_centerX).offset(-20);
        make.height.mas_equalTo(hButton);
    }];
    btnClear.clipsToBounds = YES;
    btnClear.layer.cornerRadius = hButton/2;
    [btnClear setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnClear.titleLabel.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:22.0];
    
    UIImage *bgClear = [AppUtils imageWithColor:[UIColor colorWithRed:(248/255.0) green:(83/255.0)
                                                                 blue:(86/255.0) alpha:1.0]
                                      andBounds:CGRectMake(0, 0, 100, 50)];
    UIImage *bgClearDisable = [AppUtils imageWithColor:[UIColor colorWithRed:(248/255.0) green:(83/255.0)
                                                                        blue:(86/255.0) alpha:0.5]
                                             andBounds:CGRectMake(0, 0, 100, 50)];
    
    [btnClear setBackgroundImage:bgClear forState:UIControlStateNormal];
    [btnClear setBackgroundImage:bgClearDisable forState:UIControlStateDisabled];
    
    //  save button
    UIImage *bgSave = [AppUtils imageWithColor:[UIColor colorWithRed:(27/255.0) green:(104/255.0) blue:(213/255.0) alpha:1.0] andBounds:CGRectMake(0, 0, 100, 50)];
    UIImage *bgSaveDisable = [AppUtils imageWithColor:[UIColor colorWithRed:(27/255.0) green:(104/255.0) blue:(213/255.0) alpha:0.5] andBounds:CGRectMake(0, 0, 100, 50)];
    
    [btnSave setBackgroundImage:bgSave forState:UIControlStateNormal];
    [btnSave setBackgroundImage:bgSaveDisable forState:UIControlStateDisabled];
    
    [btnSave mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnClear);
        make.left.equalTo(viewContent.mas_centerX).offset(20);
        make.right.equalTo(tfPassword.mas_right);
        make.height.mas_equalTo(btnClear.mas_height);
    }];
    btnSave.clipsToBounds = YES;
    btnSave.layer.cornerRadius = hButton/2;
    [btnSave setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnSave.titleLabel.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:22.0];
    
    //  button login with phone number
    btnLoginWithPhone.backgroundColor = [UIColor colorWithRed:(0/255.0) green:(189/255.0)
                                                         blue:(86/255.0) alpha:1.0];
    [btnLoginWithPhone setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnLoginWithPhone.clipsToBounds = YES;
    btnLoginWithPhone.layer.cornerRadius = hButton/2;
    btnLoginWithPhone.titleLabel.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:22.0];
    [btnLoginWithPhone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-30);
        make.left.equalTo(self.view).offset(30);
        make.right.equalTo(self.view).offset(-30);
        make.height.mas_equalTo(hButton);
    }];
    if ([LinphoneAppDelegate sharedInstance].supportLoginWithPhoneNumber) {
        btnLoginWithPhone.hidden = NO;
    }else{
        btnLoginWithPhone.hidden = YES;
    }
}

#pragma mark - Switch Custom Delegate
- (void)switchButtonEnabled
{
    BOOL networkReady = [DeviceUtils checkNetworkAvailable];
    
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] with networkReady = %d", __FUNCTION__, networkReady] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    if (!networkReady) {
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Please check your internet connection!"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    LinphoneProxyConfig *defaultConfig = linphone_core_get_default_proxy_config(LC);
    if (defaultConfig != NULL) {
        turnOffAcc = NO;
        turnOnAcc = YES;
        
        [icWaiting startAnimating];
        icWaiting.hidden = NO;
        
        [SipUtils enableProxyConfig:defaultConfig withValue:YES withRefresh:YES];
        
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Enable proxy config with accountId = %@", __FUNCTION__, [SipUtils getAccountIdOfDefaultProxyConfig]] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    }else{
        [swAccount setUIForDisableStateWithActionTarget: NO];
        
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"You have not signed your account yet"] duration:2.0 position:CSToastPositionCenter];
        
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Can not enable with defaultConfig = NULL", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    }
}

- (void)switchButtonDisabled {
    BOOL networkReady = [DeviceUtils checkNetworkAvailable];
    
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] with networkReady = %d", __FUNCTION__, networkReady] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    if (!networkReady) {
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Please check your internet connection!"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    LinphoneProxyConfig *defaultConfig = linphone_core_get_default_proxy_config(LC);
    if (defaultConfig != NULL) {
        turnOffAcc = YES;
        turnOnAcc = NO;
        
        [icWaiting startAnimating];
        icWaiting.hidden = NO;
        
        [SipUtils enableProxyConfig:defaultConfig withValue:NO withRefresh:YES];
        
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Disable proxy config with accountId = %@", __FUNCTION__, [SipUtils getAccountIdOfDefaultProxyConfig]] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    }
}

- (BOOL)checkAccount: (NSString *)account withServer: (NSString *)server {
    NSString *curServer = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_SERVER];
    NSString *curAccount = [SipUtils getAccountIdOfDefaultProxyConfig];
    
    if (![AppUtils isNullOrEmpty: curServer] && ![AppUtils isNullOrEmpty: curAccount]) {
        if ([curServer isEqualToString: server] && [curAccount isEqualToString: account]) {
            return YES;
        }
    }
    return NO;
}

- (NSMutableAttributedString *)createAttributeStringWithContent: (NSString *)content imageName: (NSString *)imageName isLeadImage: (BOOL)isLeadImage withHeight: (float)height
{
    UIImage *iconImg = [UIImage imageNamed:imageName];
    if (iconImg != nil) {
        CustomTextAttachment *attachment = [[CustomTextAttachment alloc] init];
        attachment.image = iconImg;
        [attachment setImageHeight: height];
        
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
        
        NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithString:content];
        
        if (isLeadImage) {
            NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithAttributedString: attachmentString];
            [result appendAttributedString: contentString];
            
            return result;
        }else{
            NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithAttributedString: contentString];
            [result appendAttributedString: attachmentString];
            return result;
        }
    }else{
        return [[NSMutableAttributedString alloc] initWithString:content];
    }
}

- (void)registrationUpdateEvent:(NSNotification *)notif {
    NSString *message = [notif.userInfo objectForKey:@"message"];
    [self registrationUpdate:[[notif.userInfo objectForKey:@"state"] intValue]
                    forProxy:[[notif.userInfo objectForKeyedSubscript:@"cfg"] pointerValue]
                     message:message];
}

- (void)registrationUpdate:(LinphoneRegistrationState)state forProxy:(LinphoneProxyConfig *)proxy message:(NSString *)message
{
    switch (state) {
        case LinphoneRegistrationOk:
        {
            if (turnOnAcc) {
                [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] state is LinphoneRegistrationOk, turnOnAcc = YES", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
                
                NSString *server = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_SERVER];
                //  Update token after registration okay
                if (![AppUtils isNullOrEmpty: server] && ![AppUtils isNullOrEmpty: [LinphoneAppDelegate sharedInstance]._deviceToken]) {
                    [self updateCustomerTokenIOSForPBX:server andUsername: USERNAME withTokenValue:[LinphoneAppDelegate sharedInstance]._deviceToken];
                }else{
                    [self whenTurnOnPBXSuccessfully];
                }
                
                break;
            }
            if (enableProxyConfig == nil) {
                //  Nếu registration thành công, backup profxy config hiện tại, sẽ remove hết các acc cũ và register lại account mới
                [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] state is LinphoneRegistrationOk --> enableProxyConfig = proxy --> call function \"linphone_core_clear_proxy_config\" to clear all proxy cofig", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
                
                enableProxyConfig = proxy;
                linphone_core_clear_proxy_config(LC);
                
            }else if (enableProxyConfig == proxy){
                [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] state is LinphoneRegistrationOk with typeRegister = %d, set enableProxyConfig = nil", __FUNCTION__, typeRegister] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
                
                enableProxyConfig = nil;
                
                if (typeRegister == normalLogin)
                {
                    if (![tfAccount.text isEqualToString:@""] && ![tfPassword.text isEqualToString:@""]) {
                        [[NSUserDefaults standardUserDefaults] setObject:tfAccount.text forKey:key_login];
                        [[NSUserDefaults standardUserDefaults] setObject:tfPassword.text forKey:key_password];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        if ([LinphoneAppDelegate sharedInstance]._deviceToken != nil && ![tfServerID.text isEqualToString:@""] && ![tfAccount.text isEqualToString:@""]) {
                            [self updateCustomerTokenIOSForPBX: tfServerID.text andUsername: tfAccount.text withTokenValue:[LinphoneAppDelegate sharedInstance]._deviceToken];
                        }else{
                            [self whenRegisterPBXSuccessfully];
                        }
                    }
                }else if (typeRegister == qrCodeLogin){
                    if (![accountPBX isEqualToString:@""] && ![passwordPBX isEqualToString:@""]) {
                        [[NSUserDefaults standardUserDefaults] setObject:accountPBX forKey:key_login];
                        [[NSUserDefaults standardUserDefaults] setObject:passwordPBX forKey:key_password];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        if ([LinphoneAppDelegate sharedInstance]._deviceToken != nil && ![tfServerID.text isEqualToString:@""] && ![tfAccount.text isEqualToString:@""]) {
                            [self updateCustomerTokenIOSForPBX: tfServerID.text andUsername: tfAccount.text withTokenValue:[LinphoneAppDelegate sharedInstance]._deviceToken];
                        }else{
                            [self whenRegisterPBXSuccessfully];
                        }
                    }
                }
                
                break;
            }
            
            break;
        }
        case LinphoneRegistrationNone:{
            if (clearingAccount) {
                NSString *server = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_SERVER];
                NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
                if (![AppUtils isNullOrEmpty: server] && ![AppUtils isNullOrEmpty: username]) {
                    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] state is LinphoneRegistrationNone with clearingAccount = YES, clear token for %@", __FUNCTION__, username] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
                    
                    [self updateCustomerTokenIOSForPBX:server andUsername:username withTokenValue:@""];
                }else{
                    [self whenClearPBXSuccessfully];
                    
                    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] state is LinphoneRegistrationNone with clearingAccount = YES, call function whenClearPBXSuccessfully", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
                }
                break;
            }
            
            if (enableProxyConfig != NULL || enableProxyConfig != nil) {
                [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] state is LinphoneRegistrationNone with enableProxyConfig != NULL. So, register with enableProxyConfig", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
                
                [self performSelector:@selector(addRegisteredProxyConfig)
                           withObject:nil afterDelay:2.0];
            }
            
            break;
        }
        case LinphoneRegistrationCleared: {
            if (turnOffAcc) {
                [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] state LinphoneRegistrationCleared, with turnOffAcc = YES, clear token pbx for account", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
                
                NSString *server = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_SERVER];
                [self updateCustomerTokenIOSForPBX:server andUsername: USERNAME withTokenValue:@""];
                return;
            }
            
            if (enableProxyConfig != NULL || enableProxyConfig != nil) {
                [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] state is LinphoneRegistrationCleared with enableProxyConfig != NULL. So, register with enableProxyConfig", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
                
                [self performSelector:@selector(addRegisteredProxyConfig)
                           withObject:nil afterDelay:2.0];
            }else{
                //  Check if clear pbx successfully, update token for user
                if (clearingAccount) {
                    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] state is LinphoneRegistrationCleared with clearingAccount = YES", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
                    
                    NSString *server = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_SERVER];
                    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
                    if (![AppUtils isNullOrEmpty: server] && ![AppUtils isNullOrEmpty: username]) {
                        [self updateCustomerTokenIOSForPBX:server andUsername:username withTokenValue:@""];
                    }else{
                        [self whenClearPBXSuccessfully];
                    }
                }
            }
            // _waitView.hidden = true;
            break;
        }
        case LinphoneRegistrationFailed:
        {
            if (proxy != NULL) {
                const char *proxyUsername = linphone_address_get_username(linphone_proxy_config_get_identity_address(proxy));
                NSString* defaultUsername = [NSString stringWithFormat:@"%s" , proxyUsername];
                if (defaultUsername != nil)
                {
                    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"\n%s: state is %@ for proxyUsername %@", __FUNCTION__, @"LinphoneRegistrationFailed", defaultUsername] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
                    
                    if ([defaultUsername isEqualToString: accountPBX]) {
                        icWaiting.hidden = YES;
                        [icWaiting stopAnimating];
                        
                        linphone_core_remove_proxy_config(LC, proxy);
                        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Please check your information again!"] duration:2.0 position:CSToastPositionCenter];
                    }else{
                        
                    }
                }
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

- (void)addRegisteredProxyConfig {
    if (enableProxyConfig != NULL && enableProxyConfig != nil) {
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"%s", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        
        linphone_core_add_proxy_config(LC, enableProxyConfig);
        linphone_core_set_default_proxy_config(LC, enableProxyConfig);
        linphone_proxy_config_enable_register(enableProxyConfig, YES);
        linphone_proxy_config_register_enabled(enableProxyConfig);
        linphone_proxy_config_done(enableProxyConfig);
        
        linphone_core_refresh_registers(LC);
    }else{
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] But enableProxyConfig == NULL", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    }
}

#pragma mark - Webservice Delegate
- (void)whenClearPBXSuccessfully {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__]
                         toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    [icWaiting stopAnimating];
    icWaiting.hidden = YES;
    
    serverPBX = @"";
    accountPBX = @"";
    passwordPBX = @"";
    ipPBX = @"";
    portPBX = @"";
    
    tfAccount.text = @"";
    tfPassword.text = @"";
    tfServerID.text = @"";
    
    typeRegister = normalLogin;
    clearingAccount = NO;
    btnClear.enabled = NO;
    btnSave.enabled = NO;
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_SERVER];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_ID];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_PORT];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:key_login];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:key_password];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [swAccount setUIForDisableStateWithActionTarget: NO];
    
    [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Your account was removed"] duration:2.0 position:CSToastPositionCenter];
    [self performSelector:@selector(popCurrentView) withObject:nil afterDelay:2.0];
}

- (void)popCurrentView {
    [icWaiting stopAnimating];
    icWaiting.hidden = YES;
    [self.navigationController popViewControllerAnimated: YES];
}

- (void)whenRegisterPBXSuccessfully
{
    //  check to download avatar
    [self downloadMyAvatar: accountPBX];
    
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__]
                         toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    [[NSUserDefaults standardUserDefaults] setObject:serverPBX forKey:PBX_SERVER];
    [[NSUserDefaults standardUserDefaults] setObject:ipPBX forKey:PBX_ID];
    [[NSUserDefaults standardUserDefaults] setObject:portPBX forKey:PBX_PORT];
    [[NSUserDefaults standardUserDefaults] setObject:accountPBX forKey:key_login];
    [[NSUserDefaults standardUserDefaults] setObject:passwordPBX forKey:key_password];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //  Added by Khai Le on 02/10/2018
    tfServerID.text = serverPBX;
    tfAccount.text = accountPBX;
    tfPassword.text = passwordPBX;
    
    portPBX = @"";
    ipPBX = @"";
    serverPBX = @"";
    accountPBX = @"";
    passwordPBX = @"";
    
    [icWaiting stopAnimating];
    icWaiting.hidden = YES;
    btnClear.enabled = YES;
    btnSave.enabled = NO;
    
    [swAccount setUIForEnableStateWithActionTarget: NO];
    
    [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Your account was registered successful."] duration:2.0 position:CSToastPositionCenter];
}

- (void)whenTurnOnPBXSuccessfully {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    turnOnAcc = NO;
    
    [icWaiting stopAnimating];
    icWaiting.hidden = YES;
    
    btnClear.enabled = YES;
    btnSave.enabled = NO;
    
    [swAccount setUIForEnableStateWithActionTarget: NO];
    
    [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Your account was enabled successful"] duration:2.0 position:CSToastPositionCenter];
}

- (void)updateCustomerTokenIOSForPBX: (NSString *)pbxService andUsername: (NSString *)pbxUsername withTokenValue: (NSString *)tokenValue
{
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:AuthUser forKey:@"AuthUser"];
    [jsonDict setObject:AuthKey forKey:@"AuthKey"];
    [jsonDict setObject:@"" forKey:@"UserName"];
    [jsonDict setObject:tokenValue forKey:@"IOSToken"];
    [jsonDict setObject:pbxService forKey:@"PBXID"];
    [jsonDict setObject:pbxUsername forKey:@"PBXExt"];
    
    [webService callWebServiceWithLink:ChangeCustomerIOSToken withParams:jsonDict];
    
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] jsonDict = %@", __FUNCTION__, @[jsonDict]] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
}

- (void)getInfoForPBXWithServerName: (NSString *)serverName
{
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:AuthUser forKey:@"AuthUser"];
    [jsonDict setObject:AuthKey forKey:@"AuthKey"];
    [jsonDict setObject:serverName forKey:@"ServerName"];
    
    [webService callWebServiceWithLink:getServerInfoFunc withParams:jsonDict];
    
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] jsonDict = %@", __FUNCTION__, @[jsonDict]]
                         toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
}

- (void)getPBXInformationWithHashString: (NSString *)hashString
{
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:AuthUser forKey:@"AuthUser"];
    [jsonDict setObject:AuthKey forKey:@"AuthKey"];
    [jsonDict setObject:hashString forKey:@"HashString"];
    
    [webService callWebServiceWithLink:DecryptRSA withParams:jsonDict];
    
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] jsonDict = %@", __FUNCTION__, @[jsonDict]] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
}

- (void)failedToCallWebService:(NSString *)link andError:(NSString *)error
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] link: %@\nResponse data: %@", __FUNCTION__, link, error] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    [icWaiting stopAnimating];
    icWaiting.hidden = YES;
    if ([link isEqualToString:getServerInfoFunc]) {
        [self.view makeToast:error duration:2.0 position:CSToastPositionCenter];
    }else if ([link isEqualToString: ChangeCustomerIOSToken]){
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Can not update push token"] duration:2.0 position:CSToastPositionCenter];
        
        [self whenRegisterPBXSuccessfully];
    }
}

- (void)successfulToCallWebService:(NSString *)link withData:(NSDictionary *)data
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] link: %@\nResponse data: %@", __FUNCTION__, link, @[data]] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    if ([link isEqualToString:getServerInfoFunc]) {
        [self startLoginPBXWithInfo: data];
    }else if ([link isEqualToString: ChangeCustomerIOSToken]){
        if (turnOnAcc) {
            [self whenTurnOnPBXSuccessfully];
            
        } else if (turnOffAcc) {
            [self whenTurnOffPBXSuccessfully];
            
        }else if (clearingAccount) {
            [self whenClearPBXSuccessfully];
            
        }else{
            [self whenRegisterPBXSuccessfully];
        }
    }else if ([link isEqualToString: DecryptRSA]) {
        [self receiveDataFromQRCode: data];
    }
}

- (void)receivedResponeCode:(NSString *)link withCode:(int)responeCode {
    NSLog(@"%d", responeCode);
}

- (void)startLoginPBXWithInfo: (NSDictionary *)info
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] %@", __FUNCTION__, @[info]]
                         toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    NSString *pbxIp = [info objectForKey:@"ipAddress"];
    NSString *pbxPort = [info objectForKey:@"port"];
    NSString *serverName = [info objectForKey:@"serverName"];
    
    if (pbxIp != nil && ![pbxIp isEqualToString: @""] && pbxPort != nil && ![pbxPort isEqualToString: @""] && serverName != nil)
    {
        if (typeRegister == normalLogin) {
            serverPBX = serverName;
            accountPBX = tfAccount.text;
            passwordPBX = tfPassword.text;
        }
        //  save info if must clear all before account
        ipPBX = pbxIp;
        portPBX = pbxPort;
        
        [self registerPBXAccount:accountPBX password:passwordPBX ipAddress:ipPBX port:portPBX];
    }else{
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Please check your information again!"] duration:2.0 position:CSToastPositionCenter];
    }
}

- (void)whenTurnOffPBXSuccessfully {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__]
                         toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    turnOffAcc = NO;
    
    [icWaiting stopAnimating];
    icWaiting.hidden = YES;
    
    btnClear.enabled = YES;
    btnSave.enabled = NO;
    
    [swAccount setUIForDisableStateWithActionTarget: NO];
    
    [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Your account was disabled successful"] duration:2.0 position:CSToastPositionCenter];
}

- (void)registerPBXTimeOut {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    [icWaiting stopAnimating];
    icWaiting.hidden = YES;
    
    [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Register PBX failed"] duration:2.0 position:CSToastPositionCenter];
    [timeoutTimer invalidate];
    timeoutTimer = nil;
}

- (void)receiveDataFromQRCode: (NSDictionary *)data
{
    if (data != nil) {
        NSString *result = [data objectForKey:@"result"];
        if (result != nil && [result isEqualToString:@"success"]) {
            NSString *message = [data objectForKey:@"message"];
            
            [self loginPBXFromStringHashCodeResult: message];
        }
        return;
    }
    [icWaiting stopAnimating];
    icWaiting.hidden = YES;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Notification"] message:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Can not find QR Code!"] delegate:self cancelButtonTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Close"] otherButtonTitles: nil];
    [alertView show];
}

- (void)loginPBXFromStringHashCodeResult: (NSString *)message {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] %@", __FUNCTION__, message] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    NSArray *tmpArr = [message componentsSeparatedByString:@"/"];
    if (tmpArr.count == 3)
    {
        NSString *pbxDomain = [tmpArr objectAtIndex: 0];
        NSString *pbxAccount = [tmpArr objectAtIndex: 1];
        NSString *pbxPassword = [tmpArr objectAtIndex: 2];
        
        if (![pbxDomain isEqualToString:@""] && ![pbxAccount isEqualToString:@""] && ![pbxPassword isEqualToString:@""])
        {
            typeRegister = qrCodeLogin;
            
            serverPBX = pbxDomain;
            accountPBX = pbxAccount;
            passwordPBX = pbxPassword;
            
            tfAccount.text = accountPBX;
            tfServerID.text = serverPBX;
            tfPassword.text = passwordPBX;
            
            BOOL same = [self checkAccount: tfAccount.text withServer: tfServerID.text];
            if (!same) {
                typeRegister = normalLogin;
                
                icWaiting.hidden = NO;
                [icWaiting startAnimating];
                
                [self getInfoForPBXWithServerName: tfServerID.text];
                
            }else{
                icWaiting.hidden = YES;
                [icWaiting stopAnimating];
                
                [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"This account is being registered"] duration:2.0 position:CSToastPositionCenter];
            }
        }
    }else{
        [icWaiting stopAnimating];
        icWaiting.hidden = YES;
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Notifications"] message:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Can not find QR Code!"] delegate:self cancelButtonTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Close"] otherButtonTitles: nil];
        [alertView show];
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
        
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] with info %@", __FUNCTION__, @[data]]
                             toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        
        BOOL success = [SipUtils loginSipWithDomain:pbxDomain username:pbxAccount password:pbxPassword port:pbxPort];
        if (success) {
            [SipUtils registerProxyWithUsername:pbxAccount password:pbxPassword domain:pbxDomain port:pbxPort];
        }
    }
}

#pragma mark - RegisterPBXWithPhoneViewDelegate
- (void)onIconCloseClick {
    [UIView animateWithDuration:0.25 animations:^{
        viewPBXRegisterWithPhone.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
    }];
}

- (void)onIconQRCodeScanClick {
    [UIView animateWithDuration:0.25 animations:^{
        viewPBXRegisterWithPhone.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
    }completion:^(BOOL finished) {
        //  [self _iconQRCodeClicked: nil];
    }];
}

- (void)onButtonContinuePress {
    
}

#pragma mark - QRCode
- (void)onQRCodeClicked {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__]
                         toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    if ([QRCodeReader supportsMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]]) {
        QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
        scanQRCodeVC = [QRCodeReaderViewController readerWithCancelButtonTitle:@"Cancel" codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:YES showTorchButton:YES];
        scanQRCodeVC.modalPresentationStyle = UIModalPresentationFormSheet;
        scanQRCodeVC.delegate = self;
        
        btnScanFromPhoto = [UIButton buttonWithType: UIButtonTypeCustom];
        btnScanFromPhoto.frame = CGRectMake((SCREEN_WIDTH-250)/2, SCREEN_HEIGHT-38-60, 250, 38);
        btnScanFromPhoto.backgroundColor = [UIColor colorWithRed:(2/255.0) green:(164/255.0)
                                                            blue:(247/255.0) alpha:1.0];
        [btnScanFromPhoto setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnScanFromPhoto.layer.cornerRadius = btnScanFromPhoto.frame.size.height/2;
        btnScanFromPhoto.layer.borderColor = btnScanFromPhoto.backgroundColor.CGColor;
        btnScanFromPhoto.layer.borderWidth = 1.0;
        [btnScanFromPhoto setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"SCAN FROM PHOTO"] forState:UIControlStateNormal];
        btnScanFromPhoto.titleLabel.font = [UIFont systemFontOfSize: 16.0];
        [btnScanFromPhoto addTarget:self
                             action:@selector(btnScanFromPhotoPressed)
                   forControlEvents:UIControlEventTouchUpInside];
        
        [scanQRCodeVC.view addSubview: btnScanFromPhoto];
        
        [scanQRCodeVC setCompletionWithBlock:^(NSString *resultAsString) {
            NSLog(@"Completion with result: %@", resultAsString);
        }];
        [self presentViewController:scanQRCodeVC animated:YES completion:NULL];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Reader not supported by the current device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
}

- (void)btnScanFromPhotoPressed {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    btnScanFromPhoto.backgroundColor = [UIColor whiteColor];
    [btnScanFromPhoto setTitleColor:[UIColor colorWithRed:(2/255.0) green:(164/255.0)
                                                     blue:(247/255.0) alpha:1.0]
                           forState:UIControlStateNormal];
    [self performSelector:@selector(choosePictureForScanQRCode) withObject:nil afterDelay:0.05];
}

- (void)choosePictureForScanQRCode {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    btnScanFromPhoto.backgroundColor = [UIColor colorWithRed:(2/255.0) green:(164/255.0)
                                                        blue:(247/255.0) alpha:1.0];
    [btnScanFromPhoto setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    pickerController.allowsEditing = NO;
    pickerController.delegate = self;
    [scanQRCodeVC presentViewController:pickerController animated:YES completion:nil];
}

#pragma mark - QR CODE
- (void)readerDidCancel:(QRCodeReaderViewController *)reader {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result {
    [reader stopScanning];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] result = %@", __FUNCTION__, result] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        
        BOOL networkReady = [DeviceUtils checkNetworkAvailable];
        if (!networkReady) {
            [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Please check your internet connection!"] duration:2.0 position:CSToastPositionCenter];
            return;
        }
        
        icWaiting.hidden = NO;
        [icWaiting startAnimating];
        
        [self getPBXInformationWithHashString: result];
    }];
}

#pragma mark - Image picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        [self dismissViewControllerAnimated:YES completion:NULL];
        
        BOOL networkReady = [DeviceUtils checkNetworkAvailable];
        if (!networkReady) {
            [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Please check your internet connection!"] duration:2.0 position:CSToastPositionCenter];
            return;
        }
        
        NSString* type = [info objectForKey:UIImagePickerControllerMediaType];
        if ([type isEqualToString: (NSString*)kUTTypeImage] ) {
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            [self getQRCodeContentFromImage: image];
        }
    }];
}

- (void)getQRCodeContentFromImage: (UIImage *)image {
    NSArray *qrcodeContent = [self detectQRCode: image];
    if (qrcodeContent != nil && qrcodeContent.count > 0) {
        for (CIQRCodeFeature* qrFeature in qrcodeContent)
        {
            icWaiting.hidden = NO;
            [icWaiting startAnimating];
            
            [self getPBXInformationWithHashString: qrFeature.messageString];
            break;
        }
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Notifications"] message:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Can not find QR Code!"] delegate:self cancelButtonTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Close"] otherButtonTitles: nil];
        [alertView show];
    }
}

- (NSArray *)detectQRCode:(UIImage *) image
{
    @autoreleasepool {
        CIImage* ciImage = [[CIImage alloc] initWithCGImage: image.CGImage]; // to use if the underlying data is a CGImage
        NSDictionary* options;
        CIContext* context = [CIContext context];
        options = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh }; // Slow but thorough
        //options = @{ CIDetectorAccuracy : CIDetectorAccuracyLow}; // Fast but superficial
        
        CIDetector* qrDetector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                                    context:context
                                                    options:options];
        if ([[ciImage properties] valueForKey:(NSString*) kCGImagePropertyOrientation] == nil) {
            options = @{ CIDetectorImageOrientation : @1};
        } else {
            options = @{ CIDetectorImageOrientation : [[ciImage properties] valueForKey:(NSString*) kCGImagePropertyOrientation]};
        }
        NSArray * features = [qrDetector featuresInImage:ciImage
                                                 options:options];
        return features;
    }
}

- (void)downloadMyAvatar: (NSString *)myaccount
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *pbxServer = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_SERVER];
        NSString *avatarName = [NSString stringWithFormat:@"%@_%@.png", pbxServer, myaccount];
        NSString *linkAvatar = [NSString stringWithFormat:@"%@/%@", link_picture_chat_group, avatarName];
        NSData *data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: linkAvatar]];
        
        if (data != nil) {
            NSString *folder = [NSString stringWithFormat:@"/avatars/%@", avatarName];
            [AppUtils saveFileToFolder:data withName: folder];
            
            //  save avatar to get from local
            NSString *pbxKeyAvatar = [NSString stringWithFormat:@"%@_%@", @"pbxAvatar", myaccount];
            
            NSString *strAvatar = @"";
            if ([data respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
                strAvatar = [data base64EncodedStringWithOptions: 0];
            } else {
                strAvatar = [data base64Encoding];
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:strAvatar forKey:pbxKeyAvatar];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateAvatarAfterDownloadSuccessful" object:strAvatar];
        }
    });
}

@end
