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
    
    LinphoneProxyConfig *enableProxyConfig;
    BOOL clearingAccount;

    CustomSwitchButton *swAccount;
    AccountState accState;
    BOOL turnOffAcc;
    BOOL turnOnAcc;
}

@end

@implementation PBXSettingViewController
@synthesize _viewHeader, bgHeader, _iconBack, _lbTitle, _iconQRCode, _icWaiting, btnLoginWithPhone;
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
    
    clearingAccount = NO;
    
    [self showContentForView];
    [self showPBXAccountInformation];
    
    accState = [SipUtils getStateOfDefaultProxyConfig];
    switch (accState) {
        case eAccountNone:{
            [swAccount setUIForDisableStateWithActionTarget: NO];
            _btnClear.enabled = NO;
            break;
        }
        case eAccountOff:{
            [swAccount setUIForDisableStateWithActionTarget:NO];
            _btnClear.enabled = YES;
            break;
        }
        case eAccountOn:{
            [swAccount setUIForEnableStateWithActionTarget:NO];
            _btnClear.enabled = YES;
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
    swAccount = [[CustomSwitchButton alloc] initWithState:state frame:CGRectMake(SCREEN_WIDTH-marginX-tmpWidth, (60.0-31.0)/2, tmpWidth, 31.0)];
    swAccount.delegate = self;
    [_viewContent addSubview: swAccount];
    
    
    _lbSepa.backgroundColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                               blue:(230/255.0) alpha:1.0];
    [_lbSepa mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lbPBX.mas_bottom);
        make.left.equalTo(_lbPBX);
        make.right.equalTo(_viewContent).offset(-marginX);
        make.height.mas_equalTo(1.0);
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
    [_tfServerID addTarget:self
                    action:@selector(whenTextfieldDidChanged)
          forControlEvents:UIControlEventEditingChanged];
    
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
    
    [_tfAccount addTarget:self
                   action:@selector(whenTextfieldDidChanged)
         forControlEvents:UIControlEventEditingChanged];
    
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
    [_tfPassword addTarget:self
                    action:@selector(whenTextfieldDidChanged)
          forControlEvents:UIControlEventEditingChanged];
    
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
    
    UIImage *bgClear = [AppUtils imageWithColor:[UIColor colorWithRed:(248/255.0) green:(83/255.0)
                                                                 blue:(86/255.0) alpha:1.0]
                                      andBounds:CGRectMake(0, 0, 100, 50)];
    UIImage *bgClearDisable = [AppUtils imageWithColor:[UIColor colorWithRed:(248/255.0) green:(83/255.0)
                                                                        blue:(86/255.0) alpha:0.5]
                                             andBounds:CGRectMake(0, 0, 100, 50)];
    
    [_btnClear setBackgroundImage:bgClear forState:UIControlStateNormal];
    [_btnClear setBackgroundImage:bgClearDisable forState:UIControlStateDisabled];
    
    //  save button
    UIImage *bgSave = [AppUtils imageWithColor:[UIColor colorWithRed:(27/255.0) green:(104/255.0)
                                                                blue:(213/255.0) alpha:1.0]
                                     andBounds:CGRectMake(0, 0, 100, 50)];
    UIImage *bgSaveDisable = [AppUtils imageWithColor:[UIColor colorWithRed:(27/255.0) green:(104/255.0)
                                                                       blue:(213/255.0) alpha:0.5]
                                            andBounds:CGRectMake(0, 0, 100, 50)];
    
    [_btnSave setBackgroundImage:bgSave forState:UIControlStateNormal];
    [_btnSave setBackgroundImage:bgSaveDisable forState:UIControlStateDisabled];
    
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
    
    //  button login with phone number
    btnLoginWithPhone.backgroundColor = [UIColor colorWithRed:(0/255.0) green:(189/255.0)
                                                         blue:(86/255.0) alpha:1.0];
    [btnLoginWithPhone setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnLoginWithPhone.clipsToBounds = YES;
    btnLoginWithPhone.layer.cornerRadius = hButton/2;
    btnLoginWithPhone.titleLabel.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    [btnLoginWithPhone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-30);
        make.left.equalTo(self.view).offset(30);
        make.right.equalTo(self.view).offset(-30);
        make.height.mas_equalTo(hButton);
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
        [btnScanFromPhoto setTitle:[appDelegate.localization localizedStringForKey:@"SCAN FROM PHOTO"]
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
    BOOL networkReady = [DeviceUtils checkNetworkAvailable];
    if (!networkReady) {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Please check your internet connection!"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    DDLogInfo(@"%@", [NSString stringWithFormat:@"\n%s", __FUNCTION__]);
    
    [_icWaiting startAnimating];
    _icWaiting.hidden = NO;
    clearingAccount = YES;
    linphone_core_clear_proxy_config(LC);
    //  [[LinphoneManager instance] removeAllAccounts];
}

- (IBAction)_btnSavePressed:(UIButton *)sender {
    [self.view endEditing: YES];
    
    BOOL networkReady = [DeviceUtils checkNetworkAvailable];
    if (!networkReady) {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Please check your internet connection!"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    if ([_tfServerID.text isEqualToString:@""]) {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Server ID can't empty"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    if ([_tfAccount.text isEqualToString:@""]){
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Account can't empty"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    if ([_tfPassword.text isEqualToString:@""]){
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Password can't empty"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    typeRegister = normalLogin;
    
    _icWaiting.hidden = NO;
    [_icWaiting startAnimating];
    
    [self getInfoForPBXWithServerName: _tfServerID.text];
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

- (void)whenTextfieldDidChanged {
    //  check value is empty
    if ([_tfServerID.text isEqualToString: @""] || [_tfAccount.text isEqualToString: @""] || [_tfPassword.text isEqualToString: @""]) {
        _btnSave.enabled = NO;
        return;
    }
    _btnSave.enabled = YES;
}

- (void)getInfoForPBXWithServerName: (NSString *)serverName
{
    DDLogInfo(@"%@", [NSString stringWithFormat:@"%s: serverName = %@", __FUNCTION__, serverName]);
    
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
    DDLogInfo(@"%@", [NSString stringWithFormat:@"%s: API FUNCTION NAME is %@\nError: %@", __FUNCTION__, link, error]);
    
    [_icWaiting stopAnimating];
    _icWaiting.hidden = YES;
    if ([link isEqualToString:getServerInfoFunc]) {
        [self.view makeToast:error duration:2.0 position:CSToastPositionCenter];
    }else if ([link isEqualToString: ChangeCustomerIOSToken]){
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Can not update push token"]
                    duration:2.0 position:CSToastPositionCenter];
        
        [self whenRegisterPBXSuccessfully];
    }
}

- (void)successfulToCallWebService:(NSString *)link withData:(NSDictionary *)data {
    DDLogInfo(@"%@", [NSString stringWithFormat:@"%s: response data for function %@: %@", __FUNCTION__, link, @[data]]);
    
    [_icWaiting stopAnimating];
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
    DDLogInfo(@"%@", [NSString stringWithFormat:@"%s: %@", __FUNCTION__, @[info]]);
    
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
        
        [self registerPBXAccount:accountPBX password:passwordPBX ipAddress:ipPBX port:portPBX];
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
        
        DDLogInfo(@"%@", [NSString stringWithFormat:@"%s: pbxDomain = %@, pbxAccount = %@, pbxPort = %@", __FUNCTION__, pbxDomain, pbxAccount, pbxPort]);
        
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
        case LinphoneRegistrationOk:
        {
            NSLog(@"LinphoneRegistrationOk");
            if (turnOnAcc) {
                NSString *server = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_SERVER];
                //  Update token after registration okay
                if (![AppUtils isNullOrEmpty: server] && ![AppUtils isNullOrEmpty: appDelegate._deviceToken]) {
                    [self updateCustomerTokenIOSForPBX:server andUsername: USERNAME withTokenValue:appDelegate._deviceToken];
                }else{
                    [self whenTurnOnPBXSuccessfully];
                }
                
                break;
            }
            if (enableProxyConfig == nil) {
                DDLogInfo(@"%@", [NSString stringWithFormat:@"\n%s: state is %@ ---> gọi linphone_core_clear_proxy_config", __FUNCTION__, @"LinphoneRegistrationOk"]);
                
                enableProxyConfig = proxy;
                linphone_core_clear_proxy_config(LC);
                
            }else if (enableProxyConfig == proxy){
                DDLogInfo(@"%@", [NSString stringWithFormat:@"\n%s: state is %@ ---> register thành công sau khi clear proxy config", __FUNCTION__, @"LinphoneRegistrationOk"]);
                
                enableProxyConfig = nil;
                    
                if (typeRegister == normalLogin)
                {
                    if (![_tfAccount.text isEqualToString:@""] && ![_tfPassword.text isEqualToString:@""]) {
                        [[NSUserDefaults standardUserDefaults] setObject:_tfAccount.text forKey:key_login];
                        [[NSUserDefaults standardUserDefaults] setObject:_tfPassword.text forKey:key_password];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        if (appDelegate._deviceToken != nil && ![_tfServerID.text isEqualToString:@""] && ![_tfAccount.text isEqualToString:@""]) {
                            [self updateCustomerTokenIOSForPBX: _tfServerID.text andUsername: _tfAccount.text withTokenValue:appDelegate._deviceToken];
                        }else{
                            [self whenRegisterPBXSuccessfully];
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
                            [self whenRegisterPBXSuccessfully];
                        }
                    }
                }
                
                break;
            }
            
            break;
        }
        case LinphoneRegistrationNone:{
            DDLogInfo(@"%@", [NSString stringWithFormat:@"\n%s: state is %@,", __FUNCTION__, @"LinphoneRegistrationNone"]);
            if (clearingAccount) {
                NSString *server = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_SERVER];
                NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
                if (![AppUtils isNullOrEmpty: server] && ![AppUtils isNullOrEmpty: username]) {
                    [self updateCustomerTokenIOSForPBX:server andUsername:username withTokenValue:@""];
                }else{
                    [self whenClearPBXSuccessfully];
                }
                break;
            }
            
            if (enableProxyConfig != NULL || enableProxyConfig != nil) {
                DDLogInfo(@"%@", [NSString stringWithFormat:@"\n%s: state is %@, enableProxyConfig khác NULL --> register proxy config đã lưu", __FUNCTION__, @"LinphoneRegistrationCleared"]);
                
                [self performSelector:@selector(addRegisteredProxyConfig)
                           withObject:nil afterDelay:2.0];
            }
            
            break;
        }
        case LinphoneRegistrationCleared: {
            DDLogInfo(@"%@", [NSString stringWithFormat:@"\n%s: state is %@", __FUNCTION__, @"LinphoneRegistrationCleared"]);
            if (turnOffAcc) {
                NSString *server = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_SERVER];
                [self updateCustomerTokenIOSForPBX:server andUsername: USERNAME withTokenValue:@""];
                return;
            }
            
            if (enableProxyConfig != NULL || enableProxyConfig != nil) {
                DDLogInfo(@"%@", [NSString stringWithFormat:@"\n%s: state is %@, enableProxyConfig khác NULL --> register proxy config đã lưu", __FUNCTION__, @"LinphoneRegistrationCleared"]);
                
                [self performSelector:@selector(addRegisteredProxyConfig)
                           withObject:nil afterDelay:2.0];
            }else{
                //  Check if clear pbx successfully, update token for user
                if (clearingAccount) {
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
                if (defaultUsername != nil) {
                    DDLogInfo(@"%@", [NSString stringWithFormat:@"\n%s: state is %@ for proxyUsername %@", __FUNCTION__, @"LinphoneRegistrationFailed", defaultUsername]);
                    if ([defaultUsername isEqualToString: accountPBX]) {
                        _icWaiting.hidden = YES;
                        [_icWaiting stopAnimating];
                        
                        linphone_core_remove_proxy_config(LC, proxy);
                        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Please check your information again!"] duration:2.0 position:CSToastPositionCenter];
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

- (void)whenRegisterPBXSuccessfully {
    [[NSUserDefaults standardUserDefaults] setObject:serverPBX forKey:PBX_SERVER];
    [[NSUserDefaults standardUserDefaults] setObject:ipPBX forKey:PBX_ID];
    [[NSUserDefaults standardUserDefaults] setObject:portPBX forKey:PBX_PORT];
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
    _btnClear.enabled = YES;
    _btnSave.enabled = NO;
    
    [swAccount setUIForEnableStateWithActionTarget: NO];
    
    [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Your account was registered successful."]
                duration:2.0 position:CSToastPositionCenter];
}

- (void)whenTurnOnPBXSuccessfully {
    turnOnAcc = NO;
    
    [_icWaiting stopAnimating];
    _icWaiting.hidden = YES;
    
    _btnClear.enabled = YES;
    _btnSave.enabled = NO;
    
    [swAccount setUIForEnableStateWithActionTarget: NO];
    
    [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Your account was enabled successful"]
                duration:2.0 position:CSToastPositionCenter];
}

- (void)whenTurnOffPBXSuccessfully {
    turnOffAcc = NO;
    
    [_icWaiting stopAnimating];
    _icWaiting.hidden = YES;
    
    _btnClear.enabled = YES;
    _btnSave.enabled = NO;
    
    [swAccount setUIForDisableStateWithActionTarget: NO];
    
    [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Your account was disabled successful"]
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

- (void)whenClearPBXSuccessfully {
    [_icWaiting stopAnimating];
    _icWaiting.hidden = YES;
    
    serverPBX = @"";
    accountPBX = @"";
    passwordPBX = @"";
    ipPBX = @"";
    portPBX = @"";
    
    _tfAccount.text = @"";
    _tfPassword.text = @"";
    _tfServerID.text = @"";
    
    typeRegister = normalLogin;
    clearingAccount = NO;
    _btnClear.enabled = NO;
    _btnSave.enabled = NO;
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_SERVER];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_ID];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_PORT];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:key_login];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:key_password];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [swAccount setUIForDisableStateWithActionTarget: NO];
    
    [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Your account was removed"]
                duration:2.0 position:CSToastPositionCenter];
    //  [self performSelector:@selector(popCurrentView) withObject:nil afterDelay:2.0];
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
    [_icWaiting stopAnimating];
    _icWaiting.hidden = YES;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[appDelegate.localization localizedStringForKey:@"Notification"] message:[appDelegate.localization localizedStringForKey:@"Can not find QR Code!"] delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:@"Close"] otherButtonTitles: nil];
    [alertView show];
}

- (void)loginPBXFromStringHashCodeResult: (NSString *)message {
    DDLogInfo(@"%@", [NSString stringWithFormat:@"%s: %@", __FUNCTION__, message]);
    
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
            
            _tfAccount.text = accountPBX;
            _tfServerID.text = serverPBX;
            _tfPassword.text = passwordPBX;
            
            [self getInfoForPBXWithServerName: pbxDomain];
        }
    }else{
        [_icWaiting stopAnimating];
        _icWaiting.hidden = YES;
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[appDelegate.localization localizedStringForKey:@"Notifications"] message:[appDelegate.localization localizedStringForKey:@"Can not find QR Code!"] delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:@"Close"] otherButtonTitles: nil];
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
        DDLogInfo(@"%@", [NSString stringWithFormat:@"\n%s", __FUNCTION__]);
        
        BOOL networkReady = [DeviceUtils checkNetworkAvailable];
        if (!networkReady) {
            [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Please check your internet connection!"] duration:2.0 position:CSToastPositionCenter];
            return;
        }
        
        _icWaiting.hidden = NO;
        [_icWaiting startAnimating];
        
        [self getPBXInformationWithHashString: result];
    }];
}

#pragma mark - Web service

- (void)getPBXInformationWithHashString: (NSString *)hashString
{
    DDLogInfo(@"%@", [NSString stringWithFormat:@"\n%s: hashString = %@", __FUNCTION__, hashString]);
    
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
        
        BOOL networkReady = [DeviceUtils checkNetworkAvailable];
        if (!networkReady) {
            [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Please check your internet connection!"] duration:2.0 position:CSToastPositionCenter];
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
            _icWaiting.hidden = NO;
            [_icWaiting startAnimating];
            
            [self getPBXInformationWithHashString: qrFeature.messageString];
            break;
        }
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[appDelegate.localization localizedStringForKey:@"Notifications"] message:[appDelegate.localization localizedStringForKey:@"Can not find QR Code!"] delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:@"Close"] otherButtonTitles: nil];
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

- (void)loginPBXWithNewAccountIfNeed
{
    if (![AppUtils isNullOrEmpty: ipPBX] && ![AppUtils isNullOrEmpty: portPBX] && ![AppUtils isNullOrEmpty: accountPBX] && ![AppUtils isNullOrEmpty: passwordPBX])
    {
        DDLogInfo(@"%@", [NSString stringWithFormat:@"\n%s: accountPBX = %@, ipPBX = %@, portPBX = %@", __FUNCTION__, accountPBX, ipPBX, portPBX]);
        
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
            _tfServerID.text = [[NSUserDefaults standardUserDefaults] objectForKey: PBX_SERVER];
            
            _btnSave.enabled = NO;
        }
    }else{
        _btnSave.enabled = NO;
    }
}

- (void)addRegisteredProxyConfig {
    if (enableProxyConfig != NULL) {
        DDLogInfo(@"%@", [NSString stringWithFormat:@"%s", __FUNCTION__]);
        
        linphone_core_add_proxy_config(LC, enableProxyConfig);
        linphone_core_set_default_proxy_config(LC, enableProxyConfig);
        linphone_proxy_config_enable_register(enableProxyConfig, YES);
        linphone_proxy_config_register_enabled(enableProxyConfig);
        linphone_proxy_config_done(enableProxyConfig);
        
        linphone_core_refresh_registers(LC);
    }
}

#pragma mark - Switch Custom Delegate
- (void)switchButtonEnabled {
    BOOL networkReady = [DeviceUtils checkNetworkAvailable];
    if (!networkReady) {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Please check your internet connection!"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    LinphoneProxyConfig *defaultConfig = linphone_core_get_default_proxy_config(LC);
    if (defaultConfig != NULL) {
        turnOffAcc = NO;
        turnOnAcc = YES;
        
        [_icWaiting startAnimating];
        _icWaiting.hidden = NO;
        
        [SipUtils enableProxyConfig:defaultConfig withValue:YES withRefresh:YES];
    }
}

- (void)switchButtonDisabled {
    BOOL networkReady = [DeviceUtils checkNetworkAvailable];
    if (!networkReady) {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Please check your internet connection!"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    LinphoneProxyConfig *defaultConfig = linphone_core_get_default_proxy_config(LC);
    if (defaultConfig != NULL) {
        turnOffAcc = YES;
        turnOnAcc = NO;
        
        [_icWaiting startAnimating];
        _icWaiting.hidden = NO;
        
        [SipUtils enableProxyConfig:defaultConfig withValue:NO withRefresh:YES];
    }
}

@end
