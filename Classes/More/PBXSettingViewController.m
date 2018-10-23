//
//  PBXSettingViewController.m
//  linphone
//
//  Created by admin on 8/4/18.
//

#import "PBXSettingViewController.h"
#import "QRCodeReaderViewController.h"
#import "QRCodeReader.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "InfoForNewContactTableCell.h"
#import <CommonCrypto/CommonDigest.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "CustomTextAttachment.h"

@interface PBXSettingViewController (){
    LinphoneAppDelegate *appDelegate;
    NSTimer *timeoutTimer;
    UIButton *btnScanFromPhoto;
    QRCodeReaderViewController *scanQRCodeVC;
    //  For register pbx with qrcode
    int typeRegister;
    NSString *serverPBX;
    NSString *accountPBX;
    NSString *passwordPBX;
    NSString *ipPBX;
    NSString *portPBX;
    RegisterPBXWithPhoneView *viewPBXRegisterWithPhone;
    float hTextfield;
}

@end

@implementation PBXSettingViewController
@synthesize _viewHeader, bgHeader, _iconBack, _lbTitle, _iconQRCode, _icWaiting, btnLoginWithPhone, lbVersion;
@synthesize _viewContent, _lbPBX, _swChange, _lbSepa, _lbServerID, _tfServerID, _lbAccount, _tfAccount, _lbPassword, _tfPassword, _btnClear, _btnSave;
@synthesize webService;

#pragma mark - UICompositeViewDelegate Functions
static UICompositeViewDescription *compositeDescription = nil;
+ (UICompositeViewDescription *)compositeViewDescription {
    if (compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:nil
                                                                 tabBar:nil
                                                               sideMenu:nil
                                                             fullscreen:FALSE
                                                         isLeftFragment:YES
                                                           fragmentWith:0];
        //        compositeDescription.darkBackground = true;
    }
    return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
    return self.class.compositeViewDescription;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //  Init for webservice
    webService = [[WebServices alloc] init];
    webService.delegate = self;
    
    [self autoLayoutForMainView];
    
    UITapGestureRecognizer *tapOnScreen = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard)];
    [self.view addGestureRecognizer: tapOnScreen];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [self showContentForView];
    [self showPBXAccountInformation];
    
    LinphoneProxyConfig *defaultConfig = linphone_core_get_default_proxy_config(LC);
    if (defaultConfig == NULL) {
        _swChange.on = NO;
    }
    
    //  set value for label version
    lbVersion.attributedText = [AppUtils getVersionStringForApp];
    
    //  set title for button login with phone number
    NSString *phoneContent = [NSString stringWithFormat:@" %@", [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Register with phone number"]];
    NSAttributedString *phoneStr = [self createAttributeStringWithContent:phoneContent imageName:@"ic_phone_login.png" isLeadImage:YES withHeight:22.0];
    [btnLoginWithPhone setAttributedTitle:phoneStr forState:UIControlStateNormal];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(registrationUpdateEvent:)
                                               name:kLinphoneRegistrationUpdate object:nil];
}

-(void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)autoLayoutForMainView
{
    if (SCREEN_WIDTH > 320) {
        _lbTitle.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:20.0];
    }else{
        _lbTitle.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }
    //  [Khai le - 22/10/2018]: detect with iPhone 5, 5s, 5c and SE
    float hMargin = 30.0;
    float hLabel = 35.0;
    hTextfield = 40.0;
    float hButton = 45.0;
    
    NSString *modelPhone = [DeviceUtils getModelsOfCurrentDevice];
    if ([modelPhone isEqualToString:@"iPhone5,1"] || [modelPhone isEqualToString:@"iPhone5,2"] || [modelPhone isEqualToString:@"iPhone5,3"] || [modelPhone isEqualToString:@"iPhone5,4"] || [modelPhone isEqualToString:@"iPhone6,1"] || [modelPhone isEqualToString:@"iPhone6,2"] || [modelPhone isEqualToString:@"iPhone8,4"] || [modelPhone isEqualToString:@"x86_64"])
    {
        hTextfield = 32.0;
        hLabel = 30.0;
        hMargin = 20.0;
        hButton = 38.0;
    }
    
    float marginX = 20.0;
    self.view.backgroundColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                                 blue:(230/255.0) alpha:1.0];
    
    _icWaiting.backgroundColor = UIColor.whiteColor;
    _icWaiting.alpha = 0.5;
    [_icWaiting mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    
    
    //  Header view
    [_viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo([LinphoneAppDelegate sharedInstance]._hRegistrationState);
    }];
    
    [bgHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(_viewHeader);
    }];
    
    [_lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader).offset([LinphoneAppDelegate sharedInstance]._hStatus);
        make.bottom.equalTo(_viewHeader);
        make.centerX.equalTo(_viewHeader.mas_centerX);
        make.width.mas_equalTo(200);
    }];
    
    [_iconBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewHeader);
        make.centerY.equalTo(_lbTitle.mas_centerY);
        make.width.height.mas_equalTo(HEADER_ICON_WIDTH);
    }];
    
    [_iconQRCode mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_iconBack);
        make.right.equalTo(_viewHeader.mas_right);
        make.width.equalTo(_iconBack.mas_width);
        make.height.equalTo(_iconBack.mas_height);
    }];
    
    //  content view
    float hViewContent = 60.0 + 2.0 + (hLabel + hTextfield) + 15 + (hLabel + hTextfield) + 15 + (hLabel + hTextfield) + 30 + 45.0 + 30;
    _viewContent.backgroundColor = UIColor.whiteColor;
    [_viewContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader.mas_bottom);
        //  make.left.right.bottom.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(hViewContent);
    }];
    
    _lbPBX.textColor = [UIColor colorWithRed:(80/255.0) green:(80/255.0)
                                        blue:(80/255.0) alpha:1.0];
    [_lbPBX mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewContent).offset(marginX);
        make.top.equalTo(_viewContent);
        make.height.mas_equalTo(60.0);
        make.right.equalTo(_viewContent.mas_centerX);
    }];
    
    [_swChange mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_viewContent).offset(-marginX);
        make.centerY.equalTo(_lbPBX.mas_centerY);
        make.height.mas_equalTo(31.0);
        make.width.mas_equalTo(49.0);
    }];
    _swChange.enabled = NO;
    
    _lbSepa.backgroundColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0)
                                               blue:(235/255.0) alpha:1.0];
    [_lbSepa mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lbPBX.mas_bottom);
        make.left.equalTo(_lbPBX);
        make.right.equalTo(_swChange.mas_right);
        make.height.mas_equalTo(2.0);
    }];
    
    //  server ID
    _lbServerID.textColor = _lbPBX.textColor;
    [_lbServerID mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lbSepa.mas_bottom).offset(15);
        make.left.right.equalTo(_lbSepa);
        make.height.mas_equalTo(hLabel);
    }];
    
    _tfServerID.borderStyle = UITextBorderStyleNone;
    _tfServerID.layer.cornerRadius = 3.0;
    _tfServerID.layer.borderWidth = 1.0;
    _tfServerID.layer.borderColor = _lbSepa.backgroundColor.CGColor;
    _tfServerID.font = [UIFont fontWithName:MYRIADPRO_BOLD size:16.0];
    [_tfServerID mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lbServerID.mas_bottom);
        make.left.right.equalTo(_lbServerID);
        make.height.mas_equalTo(hTextfield);
    }];
    
    _tfServerID.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8.0, 40.0)];
    _tfServerID.leftViewMode = UITextFieldViewModeAlways;
    
    //  account
    _lbAccount.textColor = _lbPBX.textColor;
    [_lbAccount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_tfServerID.mas_bottom).offset(15);
        make.left.right.equalTo(_tfServerID);
        make.height.mas_equalTo(_lbServerID.mas_height);
    }];
    
    _tfAccount.borderStyle = UITextBorderStyleNone;
    _tfAccount.layer.cornerRadius = 3.0;
    _tfAccount.layer.borderWidth = 1.0;
    _tfAccount.layer.borderColor = _lbSepa.backgroundColor.CGColor;
    _tfAccount.font = [UIFont fontWithName:MYRIADPRO_BOLD size:16.0];
    [_tfAccount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lbAccount.mas_bottom);
        make.left.right.equalTo(_lbAccount);
        make.height.equalTo(_tfServerID.mas_height);
    }];
    _tfAccount.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8.0, 40.0)];
    _tfAccount.leftViewMode = UITextFieldViewModeAlways;
    
    //  password
    _lbPassword.textColor = _lbPBX.textColor;
    [_lbPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_tfAccount.mas_bottom).offset(15);
        make.left.right.equalTo(_tfAccount);
        make.height.mas_equalTo(_lbServerID.mas_height);
    }];
    
    _tfPassword.borderStyle = UITextBorderStyleNone;
    _tfPassword.layer.cornerRadius = 3.0;
    _tfPassword.layer.borderWidth = 1.0;
    _tfPassword.layer.borderColor = _lbSepa.backgroundColor.CGColor;
    _tfPassword.font = [UIFont fontWithName:MYRIADPRO_BOLD size:16.0];
    [_tfPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lbPassword.mas_bottom);
        make.left.right.equalTo(_lbPassword);
        make.height.equalTo(_tfServerID.mas_height);
    }];
    _tfPassword.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8.0, 40.0)];
    _tfPassword.leftViewMode = UITextFieldViewModeAlways;
    
    //  footer button
    [_btnClear mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_tfPassword.mas_bottom).offset(hMargin);
        make.left.equalTo(_tfPassword);
        make.right.equalTo(_viewContent.mas_centerX).offset(-20);
        make.height.mas_equalTo(hButton);
    }];
    _btnClear.clipsToBounds = YES;
    _btnClear.layer.cornerRadius = hButton/2;
    [_btnClear setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _btnClear.titleLabel.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    _btnClear.backgroundColor = [UIColor colorWithRed:(248/255.0) green:(83/255.0)
                                                 blue:(86/255.0) alpha:1.0];
    
    _btnSave.backgroundColor = UIColor.clearColor;
    [_btnSave setBackgroundImage:[UIImage imageNamed:@"bg_button.png"]
                        forState:UIControlStateNormal];
    [_btnSave mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_btnClear);
        make.left.equalTo(_viewContent.mas_centerX).offset(20);
        make.right.equalTo(_tfPassword.mas_right);
        make.height.mas_equalTo(_btnClear.mas_height);
    }];
    _btnSave.clipsToBounds = YES;
    _btnSave.layer.cornerRadius = hButton/2;
    [_btnSave setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _btnSave.titleLabel.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    _btnSave.backgroundColor = [UIColor colorWithRed:(25/255.0) green:(86/255.0)
                                                blue:(108/255.0) alpha:1.0];
    
    //  button login with phone number
    btnLoginWithPhone.backgroundColor = [UIColor colorWithRed:(0/255.0) green:(189/255.0)
                                                         blue:(86/255.0) alpha:1.0];
    [btnLoginWithPhone setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnLoginWithPhone.clipsToBounds = YES;
    btnLoginWithPhone.layer.cornerRadius = hButton/2;
    btnLoginWithPhone.titleLabel.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    [btnLoginWithPhone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewContent.mas_bottom).offset(30);
        make.left.equalTo(self.view).offset(30);
        make.right.equalTo(self.view).offset(-30);
        make.height.mas_equalTo(hButton);
    }];
    
    //  label version
    lbVersion.backgroundColor = UIColor.clearColor;
    lbVersion.textColor = [UIColor colorWithRed:(50/255.0) green:(50/255.0)
                                           blue:(50/255.0) alpha:1.0];
    [lbVersion mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(45.0);
    }];
}

- (IBAction)_iconBackClicked:(UIButton *)sender {
    [self.view endEditing: true];
    [[PhoneMainView instance] popCurrentView];
}

- (IBAction)_iconQRCodeClicked:(UIButton *)sender {
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
        [btnScanFromPhoto setTitle:[appDelegate.localization localizedStringForKey:scan_from_photo]
                          forState:UIControlStateNormal];
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

- (IBAction)_btnClearPressed:(UIButton *)sender {
    [self removeAllAccountLoginedBefore];
    return;
    const MSList *proxies = linphone_core_get_proxy_config_list(LC);
    int numAcc = ms_list_size(proxies);
    if (numAcc == 0) {
        NSLog(@"What the hell");
        return;
    }
    
    linphone_core_clear_proxy_config(LC);
    [[LinphoneManager instance] removeAllAccounts];
    
    
    
    timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self
                                                  selector:@selector(registerPBXTimeOut)
                                                  userInfo:nil repeats:false];
    
    [_icWaiting startAnimating];
    _icWaiting.hidden = NO;
    [self clearAllProxyConfigAndAccount];
}

- (IBAction)_btnSavePressed:(UIButton *)sender {
    [self.view endEditing: YES];
    if ([_tfServerID.text isEqualToString:@""]) {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Server ID can't empty"] duration:2.0 position:CSToastPositionCenter];
    }else if ([_tfAccount.text isEqualToString:@""]){
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Account can't empty"] duration:2.0 position:CSToastPositionCenter];
    }else if ([_tfPassword.text isEqualToString:@""]){
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Password can't empty"] duration:2.0 position:CSToastPositionCenter];
    }else{
        typeRegister = normalLogin;
        
        _icWaiting.hidden = NO;
        [_icWaiting startAnimating];
        
        [self getInfoForPBXWithServerName: _tfServerID.text];
    }
}

- (void)closeKeyboard {
    [self.view endEditing: YES];
}

- (void)showContentForView {
    _lbTitle.text = [appDelegate.localization localizedStringForKey:@"PBX account"];
    
    _lbPBX.text = [appDelegate.localization localizedStringForKey:@"PBX"];
    _lbServerID.text = [appDelegate.localization localizedStringForKey:@"Server ID"];
    _lbAccount.text = [appDelegate.localization localizedStringForKey:@"Account"];
    _lbPassword.text = [appDelegate.localization localizedStringForKey:@"Password"];
    
    [_btnClear setTitle:[appDelegate.localization localizedStringForKey:@"Clear"]
               forState:UIControlStateNormal];
    [_btnSave setTitle:[appDelegate.localization localizedStringForKey:@"Save"]
              forState:UIControlStateNormal];
    
//    _tfServerID.text = @"CF-BS-3165";
//    _tfAccount.text = @"14951";
//    _tfPassword.text = @"cloudfone@123";
    
    [_icWaiting stopAnimating];
    _icWaiting.hidden = YES;
}

- (void)getInfoForPBXWithServerName: (NSString *)serverName
{
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:AuthUser forKey:@"AuthUser"];
    [jsonDict setObject:AuthKey forKey:@"AuthKey"];
    [jsonDict setObject:serverName forKey:@"ServerName"];
    
    [webService callWebServiceWithLink:getServerInfoFunc withParams:jsonDict];
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
}


#pragma mark - Webservice Delegate

- (void)failedToCallWebService:(NSString *)link andError:(NSString *)error {
    [_icWaiting stopAnimating];
    _icWaiting.hidden = YES;
    if ([link isEqualToString:getServerInfoFunc]) {
        [self.view makeToast:error duration:2.0 position:CSToastPositionCenter];
    }else if ([link isEqualToString: ChangeCustomerIOSToken]){
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Can not update push token"]
                    duration:2.0 position:CSToastPositionCenter];
        
        [self whenTurnOnPBXSuccessfully];
    }
}

- (void)successfulToCallWebService:(NSString *)link withData:(NSDictionary *)data {
    [_icWaiting stopAnimating];
    if ([link isEqualToString:getServerInfoFunc]) {
        [self startLoginPBXWithInfo: data];
    }else if ([link isEqualToString: ChangeCustomerIOSToken]){
        [self whenTurnOnPBXSuccessfully];
    }else if ([link isEqualToString: DecryptRSA]) {
        [self receiveDataFromQRCode: data];
    }
}

- (void)receivedResponeCode:(NSString *)link withCode:(int)responeCode {
    NSLog(@"%d", responeCode);
}

- (void)startLoginPBXWithInfo: (NSDictionary *)info
{
    NSString *pbxIp = [info objectForKey:@"ipAddress"];
    NSString *pbxPort = [info objectForKey:@"port"];
    NSString *serverName = [info objectForKey:@"serverName"];
    
    if (pbxIp != nil && ![pbxIp isEqualToString: @""] && pbxPort != nil && ![pbxPort isEqualToString: @""] && serverName != nil)
    {
        if (typeRegister == normalLogin) {
            serverPBX = serverName;
            accountPBX = _tfAccount.text;
            passwordPBX = _tfPassword.text;
        }
        //  save info if must clear all before account
        ipPBX = pbxIp;
        portPBX = pbxPort;
        
        //  Check to make sure if have any account, remove it before login
        const MSList *proxies = linphone_core_get_proxy_config_list(LC);
        int curAccNum = ms_list_size(proxies);
        if (curAccNum > 0) {
            NSLog(@"%@ - Exists %d accounts, please wait for us clear all before login your pbx account", SHOW_LOGS, curAccNum);
            [self removeAllAccountLoginedBefore];
        }else{
            NSLog(@"%@ - Start login with PBX account %@ with server %@", SHOW_LOGS, accountPBX, serverPBX);
            [self registerPBXAccount:accountPBX password:passwordPBX ipAddress:ipPBX port:portPBX];
        }
    }else{
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Please check your information again!"] duration:2.0 position:CSToastPositionCenter];
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

- (void)registrationUpdateEvent:(NSNotification *)notif {
    NSString *message = [notif.userInfo objectForKey:@"message"];
    [self registrationUpdate:[[notif.userInfo objectForKey:@"state"] intValue]
                    forProxy:[[notif.userInfo objectForKeyedSubscript:@"cfg"] pointerValue]
                     message:message];
}

- (void)registrationUpdate:(LinphoneRegistrationState)state forProxy:(LinphoneProxyConfig *)proxy message:(NSString *)message
{
    switch (state) {
        case LinphoneRegistrationOk: {
            NSLog(@"%@ - LinphoneRegistrationOk", SHOW_LOGS);
            
            if (typeRegister == normalLogin)
            {
                if (![_tfAccount.text isEqualToString:@""] && ![_tfPassword.text isEqualToString:@""]) {
                    [[NSUserDefaults standardUserDefaults] setObject:_tfAccount.text forKey:key_login];
                    [[NSUserDefaults standardUserDefaults] setObject:_tfPassword.text forKey:key_password];
                    [[NSUserDefaults standardUserDefaults] synchronize];

                    if (appDelegate._deviceToken != nil && ![_tfServerID.text isEqualToString:@""] && ![_tfAccount.text isEqualToString:@""]) {
                        [self updateCustomerTokenIOSForPBX: _tfServerID.text andUsername: _tfAccount.text withTokenValue:appDelegate._deviceToken];
                    }else{
                        [self whenTurnOnPBXSuccessfully];
                    }
                }
            }else if (typeRegister == qrCodeLogin){
                if (![accountPBX isEqualToString:@""] && ![passwordPBX isEqualToString:@""]) {
                    [[NSUserDefaults standardUserDefaults] setObject:accountPBX forKey:key_login];
                    [[NSUserDefaults standardUserDefaults] setObject:passwordPBX forKey:key_password];
                    [[NSUserDefaults standardUserDefaults] synchronize];

                    if (appDelegate._deviceToken != nil && ![_tfServerID.text isEqualToString:@""] && ![_tfAccount.text isEqualToString:@""]) {
                        [self updateCustomerTokenIOSForPBX: _tfServerID.text andUsername: _tfAccount.text withTokenValue:appDelegate._deviceToken];
                    }else{
                        [self whenTurnOnPBXSuccessfully];
                    }
                }
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
        case LinphoneRegistrationFailed:
        {
            NSLog(@"%@ - LinphoneRegistrationFailed", SHOW_LOGS);
            //  Check if clear all account for login new pbx account
            const MSList *proxies = linphone_core_get_proxy_config_list(LC);
            int curAccNum = ms_list_size(proxies);
            if (curAccNum == 0) {
                [self loginPBXWithNewAccountIfNeed];
            }else{
                NSLog(@"%@ - Exists %d accounts, please wait for us clear all before login your pbx account", SHOW_LOGS, curAccNum);
                [self removeAllAccountLoginedBefore];
            }
//            const MSList *proxies = linphone_core_get_proxy_config_list(LC);
//            int numAccount = ms_list_size(proxies);
//            if (numAccount == 0) {
//                [self whenClearPBXSuccessfully];
//            }
            
            
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

- (void)whenTurnOnPBXSuccessfully {
    [[NSUserDefaults standardUserDefaults] setObject:serverPBX forKey:PBX_ID];
    [[NSUserDefaults standardUserDefaults] setObject:accountPBX forKey:key_login];
    [[NSUserDefaults standardUserDefaults] setObject:passwordPBX forKey:key_password];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //  Added by Khai Le on 02/10/2018
    _tfServerID.text = serverPBX;
    _tfAccount.text = accountPBX;
    _tfPassword.text = passwordPBX;
    
    portPBX = @"";
    ipPBX = @"";
    serverPBX = @"";
    accountPBX = @"";
    passwordPBX = @"";
    
    [_icWaiting stopAnimating];
    _icWaiting.hidden = YES;
    [_swChange setOn:YES animated:YES];
    
    [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Turn on PBX account successful."]
                duration:2.0 position:CSToastPositionCenter];
}

- (void)registerPBXTimeOut {
    [_icWaiting stopAnimating];
    _icWaiting.hidden = YES;
    
    [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Register PBX failed"]
                duration:2.0 position:CSToastPositionCenter];
    [timeoutTimer invalidate];
    timeoutTimer = nil;
}

//  Clear tất cả các proxy config và account của nó
- (void)clearAllProxyConfigAndAccount {
    linphone_core_clear_proxy_config(LC);
    [[LinphoneManager instance] removeAllAccounts];
}

- (void)whenClearPBXSuccessfully {
    [_icWaiting stopAnimating];
    _icWaiting.hidden = YES;
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:key_login];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:key_password];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Clear PBX successfully"]
                duration:2.0 position:CSToastPositionCenter];
    [self performSelector:@selector(popCurrentView) withObject:nil afterDelay:2.0];
}

- (void)popCurrentView {
    [[PhoneMainView instance] popCurrentView];
}

- (void)btnScanFromPhotoPressed {
    btnScanFromPhoto.backgroundColor = [UIColor whiteColor];
    [btnScanFromPhoto setTitleColor:[UIColor colorWithRed:(2/255.0) green:(164/255.0)
                                                     blue:(247/255.0) alpha:1.0]
                           forState:UIControlStateNormal];
    [self performSelector:@selector(choosePictureForScanQRCode) withObject:nil afterDelay:0.05];
}

- (void)choosePictureForScanQRCode {
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

- (void)receiveDataFromQRCode: (NSDictionary *)data {
    [_icWaiting stopAnimating];
    _icWaiting.hidden = YES;
    
    if (data != nil) {
        NSString *result = [data objectForKey:@"result"];
        if (result != nil && [result isEqualToString:@"success"]) {
            NSString *message = [data objectForKey:@"message"];
            
            [self loginPBXFromStringHashCodeResult: message];
        }
        return;
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[appDelegate.localization localizedStringForKey:@"Notification"] message:[appDelegate.localization localizedStringForKey:@"Can not find QR Code!"] delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:@"Close"] otherButtonTitles: nil];
    [alertView show];
}

- (void)loginPBXFromStringHashCodeResult: (NSString *)message {
    NSArray *tmpArr = [message componentsSeparatedByString:@"/"];
    if (tmpArr.count == 3)
    {
        NSString *pbxDomain = [tmpArr objectAtIndex: 0];
        NSString *pbxAccount = [tmpArr objectAtIndex: 1];
        NSString *pbxPassword = [tmpArr objectAtIndex: 2];
        
        if (![pbxDomain isEqualToString:@""] && ![pbxAccount isEqualToString:@""] && ![pbxPassword isEqualToString:@""])
        {
            if ([pbxAccount isEqualToString:USERNAME]) {
                //  Hiển thị thông báo nếu account từ QRCode trùng với account đã đc login hiện tại
                [self.view makeToast:[appDelegate.localization localizedStringForKey:@"This account has been registered"] duration:3.0 position:CSToastPositionCenter];
            }else{
                typeRegister = qrCodeLogin;
                
                serverPBX = pbxDomain;
                accountPBX = pbxAccount;
                passwordPBX = pbxPassword;
                
                [self getInfoForPBXWithServerName: pbxDomain];
            }
        }else {
            [self.view makeToast:[appDelegate.localization localizedStringForKey:text_dien_day_tu_thong_tin]
                        duration:2.0 position:CSToastPositionCenter];
        }
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[appDelegate.localization localizedStringForKey:text_notification] message:[appDelegate.localization localizedStringForKey:cannot_find_qrcode] delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:text_close] otherButtonTitles: nil];
        [alertView show];
    }
}

#pragma mark - QR CODE
- (void)readerDidCancel:(QRCodeReaderViewController *)reader {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result {
    [reader stopScanning];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self getPBXInformationWithHashString: result];
    }];
}

#pragma mark - Web service

- (void)getPBXInformationWithHashString: (NSString *)hashString
{
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:AuthUser forKey:@"AuthUser"];
    [jsonDict setObject:AuthKey forKey:@"AuthKey"];
    [jsonDict setObject:hashString forKey:@"HashString"];
    
    [webService callWebServiceWithLink:DecryptRSA withParams:jsonDict];
}

#pragma mark - Image picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        [self dismissViewControllerAnimated:YES completion:NULL];
        
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
        for (CIQRCodeFeature* qrFeature in qrcodeContent) {
            [self getPBXInformationWithHashString: qrFeature.messageString];
        }
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[appDelegate.localization localizedStringForKey:text_notification] message:[appDelegate.localization localizedStringForKey:cannot_find_qrcode] delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:text_close] otherButtonTitles: nil];
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

- (void)removeAllAccountLoginedBefore {
    linphone_core_clear_proxy_config(LC);
    [[LinphoneManager instance] removeAllAccounts];
}

- (void)loginPBXWithNewAccountIfNeed
{
    if (![AppUtils isNullOrEmpty: ipPBX] && ![AppUtils isNullOrEmpty: portPBX] && ![AppUtils isNullOrEmpty: accountPBX] && ![AppUtils isNullOrEmpty: passwordPBX])
    {
        NSLog(@"%@ - Login after finished clear all account", SHOW_LOGS);
        [self registerPBXAccount:accountPBX password:passwordPBX ipAddress:ipPBX port:portPBX];
    }
}


- (IBAction)btnLoginWithPhonePress:(UIButton *)sender {
    [self.view makeToast:[appDelegate.localization localizedStringForKey:@"This feature have not supported yet. Please try later!"] duration:2.0 position:CSToastPositionCenter];
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
        [self _iconQRCodeClicked: nil];
    }];
}

- (void)onButtonContinuePress {
    
}

- (void)showPBXAccountInformation
{
    LinphoneProxyConfig *defaultConfig = linphone_core_get_default_proxy_config(LC);
    if (defaultConfig != NULL) {
        const char *proxyUsername = linphone_address_get_username(linphone_proxy_config_get_identity_address(defaultConfig));
        NSString* defaultUsername = [NSString stringWithFormat:@"%s" , proxyUsername];
        if (defaultUsername != nil) {
            _tfAccount.text = defaultUsername;
            _tfPassword.text = [[NSUserDefaults standardUserDefaults] objectForKey: key_password];
            _tfServerID.text = [[NSUserDefaults standardUserDefaults] objectForKey: PBX_ID];
        }
    }
}

@end
