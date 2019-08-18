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
    RegisterPBXWithPhoneView *viewPBXRegisterWithPhone;
    float hTextfield;
    
    CustomSwitchButton *swAccount;
    AccountState accState;
    BOOL turnOffAcc;
    BOOL turnOnAcc;
    BOOL clearAcc;
    
    NSMutableDictionary *registerInfo;
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [WriteLogsUtils writeForGoToScreen: @"PBXSettingViewController"];
    
    clearAcc = FALSE;
    
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
    _icWaiting.hidden = YES;
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
    
    _tfServerID.delegate = _tfAccount.delegate = _tfPassword.delegate = self;
    _tfServerID.returnKeyType = _tfAccount.returnKeyType = _tfPassword.returnKeyType = UIReturnKeyDone;
    
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
    if (appDelegate.supportLoginWithPhoneNumber) {
        btnLoginWithPhone.hidden = NO;
    }else{
        btnLoginWithPhone.hidden = YES;
    }
}

- (IBAction)_iconBackClicked:(UIButton *)sender {
    [self.view endEditing: true];
    [[PhoneMainView instance] popCurrentView];
}

- (IBAction)_iconQRCodeClicked:(UIButton *)sender
{
    [WriteLogsUtils writeLogContent:@"USER PRESSED ON QRCODE ICON" toFilePath:appDelegate.logFilePath];
    
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

- (IBAction)_btnClearPressed:(UIButton *)sender
{
    [WriteLogsUtils writeLogContent:@">>>>>>>> USER PRESSED CLEAR ACCOUNT" toFilePath:appDelegate.logFilePath];
    
    BOOL networkReady = [DeviceUtils checkNetworkAvailable];
    
    if (!networkReady) {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Please check your internet connection!"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    [_icWaiting startAnimating];
    _icWaiting.hidden = NO;
    clearAcc = TRUE;
    
    linphone_core_clear_proxy_config(LC);
    
    NSString *server = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_SERVER];
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:key_login];
    if (![AppUtils isNullOrEmpty: server] && ![AppUtils isNullOrEmpty: username]) {
        [self updateCustomerTokenIOSForPBX:server andUsername:username withTokenValue:@""];
    }
    [self performSelector:@selector(whenClearPBXSuccessfully) withObject:nil afterDelay:3.0];
}

- (IBAction)_btnSavePressed:(UIButton *)sender
{
    [WriteLogsUtils writeLogContent:@">>>>>>>> USER PRESSED SAVE BUTTON" toFilePath:appDelegate.logFilePath];
    
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
    
    //  start register sip account
    
    _icWaiting.hidden = NO;
    [_icWaiting startAnimating];
    
    [self getInfoForPBXWithServerName: _tfServerID.text];
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
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:AuthUser forKey:@"AuthUser"];
    [jsonDict setObject:AuthKey forKey:@"AuthKey"];
    [jsonDict setObject:serverName forKey:@"ServerName"];
    [webService callWebServiceWithLink:getServerInfoFunc withParams:jsonDict];
    
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] jsonDict = %@", __FUNCTION__, @[jsonDict]] toFilePath:appDelegate.logFilePath];
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
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] jsonDict = %@", __FUNCTION__, @[jsonDict]] toFilePath:appDelegate.logFilePath];
}


#pragma mark - Webservice Delegate

- (void)failedToCallWebService:(NSString *)link andError:(NSString *)error
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] function: %@ - error: %@", __FUNCTION__, link, @[error]] toFilePath:appDelegate.logFilePath];
    
    [_icWaiting stopAnimating];
    _icWaiting.hidden = YES;
    if ([link isEqualToString:getServerInfoFunc]) {
        [self.view makeToast:error duration:2.0 position:CSToastPositionCenter];
        
    }else if ([link isEqualToString: ChangeCustomerIOSToken]){
        if (registerInfo != nil) {
            [self whenRegisterPBXSuccessfully];
            
        }else if (turnOnAcc) {
            [self whenTurnOnPBXSuccessfully];
            
        } else if (turnOffAcc) {
            [self whenTurnOffPBXSuccessfully];
            
        }else{
            [self whenRegisterPBXSuccessfully];
        }
        
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Can not update push token"]
                    duration:2.0 position:CSToastPositionCenter];
        
        
    }
}

- (void)successfulToCallWebService:(NSString *)link withData:(NSDictionary *)data
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] function: %@ - data: %@", __FUNCTION__, link, @[data]] toFilePath:appDelegate.logFilePath];
    
    if ([link isEqualToString:getServerInfoFunc]) {
        [self startLoginPBXWithInfo: data];
        
    }else if ([link isEqualToString: ChangeCustomerIOSToken]){
        if (turnOnAcc) {
            [self whenTurnOnPBXSuccessfully];
            
        } else if (turnOffAcc) {
            [self whenTurnOffPBXSuccessfully];
            
        } else if (clearAcc) {
            clearAcc = FALSE;
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
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] info = %@", __FUNCTION__, @[info]] toFilePath:appDelegate.logFilePath];
    
    NSString *domain = [info objectForKey:@"ipAddress"];
    NSString *port = [info objectForKey:@"port"];
    NSString *server = [info objectForKey:@"serverName"];
    NSString *account = _tfAccount.text;
    NSString *password = _tfPassword.text;
    
    if (![AppUtils isNullOrEmpty: domain] && ![AppUtils isNullOrEmpty: port] && ![AppUtils isNullOrEmpty: server])
    {
        //  save info if must clear all before account
        [WriteLogsUtils writeLogContent:@"-----> Save register info and clear all proxy config before register sip account" toFilePath:appDelegate.logFilePath];
        
        registerInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:account, @"account", password, @"password", domain, @"domain", port, @"port", server, @"server", nil];
        linphone_core_clear_proxy_config(LC);
        [self performSelector:@selector(continueAfterClearAllProxyConfig) withObject:nil afterDelay:2.0];
        
    }else{
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Please check your information again!"] duration:2.0 position:CSToastPositionCenter];
    }
}

- (void)registerPBXAccount: (NSString *)account password: (NSString *)password domain: (NSString *)domain port: (NSString *)port
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] account: %@, password: %@, domain: %@, port: %@", __FUNCTION__, account, password, domain, port] toFilePath:appDelegate.logFilePath];
    
    BOOL success = [SipUtils loginSipWithDomain:domain username:account password:password port:port];
    if (success) {
        [SipUtils registerProxyWithUsername:account password:password domain:domain port:port];
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
            [WriteLogsUtils writeLogContent:@"----->RECEIVED STATE is LinphoneRegistrationOk" toFilePath:appDelegate.logFilePath];
            
            [timeoutTimer invalidate];
            timeoutTimer = nil;
            
            if (appDelegate._deviceToken != nil && ![_tfServerID.text isEqualToString:@""] && ![_tfAccount.text isEqualToString:@""]) {
                [self updateCustomerTokenIOSForPBX: _tfServerID.text andUsername: _tfAccount.text withTokenValue:appDelegate._deviceToken];
            }else{
                if (turnOnAcc) {
                    [self whenTurnOnPBXSuccessfully];
                }else{
                    [self whenRegisterPBXSuccessfully];
                }
            }
            break;
        }
        case LinphoneRegistrationNone:{
            [WriteLogsUtils writeLogContent:@"----->RECEIVED STATE is LinphoneRegistrationNone" toFilePath:appDelegate.logFilePath];
            break;
        }
        case LinphoneRegistrationCleared: {
            if (turnOffAcc) {
                [WriteLogsUtils writeLogContent:@"----->RECEIVED STATE is LinphoneRegistrationCleared for turn off account" toFilePath:appDelegate.logFilePath];
                
                NSString *server = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_SERVER];
                [self updateCustomerTokenIOSForPBX:server andUsername: USERNAME withTokenValue:@""];
            }
            break;
        }
        case LinphoneRegistrationFailed:
        {
            [WriteLogsUtils writeLogContent:@"----->RECEIVED STATE is LinphoneRegistrationFailed for turn off account" toFilePath:appDelegate.logFilePath];
            
            if (registerInfo != nil) {
                registerInfo = nil;
                
                //  clear info if register failed
                _icWaiting.hidden = YES;
                [_icWaiting stopAnimating];
                
                [timeoutTimer invalidate];
                timeoutTimer = nil;
                
                linphone_core_remove_proxy_config(LC, proxy);
                [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Please check your information again!"] duration:2.0 position:CSToastPositionCenter];
                
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_SERVER];
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_ID];
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_PORT];
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:key_login];
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:key_password];
                [[NSUserDefaults standardUserDefaults] synchronize];
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

- (void)whenRegisterPBXSuccessfully
{
    [WriteLogsUtils writeLogContent:@"----------> REGISTER PBX SUCCESSFULLY <----------" toFilePath:appDelegate.logFilePath];
    
    NSString *account = @"";
    NSString *password = @"";
    NSString *server = @"";
    
    if (registerInfo != nil) {
        account = [registerInfo objectForKey:@"account"];
        password = [registerInfo objectForKey:@"password"];
        NSString *domain = [registerInfo objectForKey:@"domain"];
        NSString *port = [registerInfo objectForKey:@"port"];
        server = [registerInfo objectForKey:@"server"];
        
        [[NSUserDefaults standardUserDefaults] setObject:server forKey:PBX_SERVER];
        [[NSUserDefaults standardUserDefaults] setObject:domain forKey:PBX_ID];
        [[NSUserDefaults standardUserDefaults] setObject:port forKey:PBX_PORT];
        [[NSUserDefaults standardUserDefaults] setObject:account forKey:key_login];
        [[NSUserDefaults standardUserDefaults] setObject:password forKey:key_password];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    //  Added by Khai Le on 02/10/2018
    _tfServerID.text = server;
    _tfAccount.text = account;
    _tfPassword.text = password;
    
    [_icWaiting stopAnimating];
    _icWaiting.hidden = YES;
    _btnClear.enabled = YES;
    _btnSave.enabled = NO;
    
    [swAccount setUIForEnableStateWithActionTarget: NO];
    [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Your account was registered successful."] duration:2.0 position:CSToastPositionCenter];
    [self performSelector:@selector(popCurrentView) withObject:nil afterDelay:2.0];
    
    [[Crashlytics sharedInstance] setUserName: account];
}

- (void)whenTurnOnPBXSuccessfully {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__]
                         toFilePath:appDelegate.logFilePath];
    
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
    [WriteLogsUtils writeLogContent:@"-------> YOUR ACCOUNT WAS TURNED OFF" toFilePath:appDelegate.logFilePath];
    
    turnOffAcc = NO;
    [_icWaiting stopAnimating];
    _icWaiting.hidden = YES;
    
    [swAccount setUIForDisableStateWithActionTarget: NO];
    [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Your account was disabled successful"]
                duration:2.0 position:CSToastPositionCenter];
}

- (void)registerPBXTimeOut {
    [WriteLogsUtils writeLogContent:@">>>>>>>>>>>>>>> CAN NOT REGISTER SIP ACCOUNT, SHOW ERROR WITH TIMER <<<<<<<<<<<<<<<<<<" toFilePath:appDelegate.logFilePath];
    
    [_icWaiting stopAnimating];
    _icWaiting.hidden = YES;
    
    [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Register PBX failed. Please check your account!"]
                duration:2.0 position:CSToastPositionCenter];
    
    if (timeoutTimer) {
        [timeoutTimer invalidate];
        timeoutTimer = nil;
    }
    registerInfo = nil;
}

- (void)whenClearPBXSuccessfully {
    [WriteLogsUtils writeLogContent:@"------> CLEAR PBX SUCCESSFULLY" toFilePath:appDelegate.logFilePath];
    
    [_icWaiting stopAnimating];
    _icWaiting.hidden = YES;
    
    _tfAccount.text = @"";
    _tfPassword.text = @"";
    _tfServerID.text = @"";
    
    _btnClear.enabled = NO;
    _btnSave.enabled = NO;
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_SERVER];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_ID];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_PORT];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:key_login];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:key_password];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [swAccount setUIForDisableStateWithActionTarget: NO];
    
    [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Your account was removed"] duration:2.0 position:CSToastPositionCenter];
    [self performSelector:@selector(popCurrentView) withObject:nil afterDelay:2.0];
}

- (void)popCurrentView {
    [_icWaiting stopAnimating];
    _icWaiting.hidden = YES;
    [[PhoneMainView instance] popCurrentView];
}

- (void)btnScanFromPhotoPressed {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__]
                         toFilePath:appDelegate.logFilePath];
    
    btnScanFromPhoto.backgroundColor = [UIColor whiteColor];
    [btnScanFromPhoto setTitleColor:[UIColor colorWithRed:(2/255.0) green:(164/255.0)
                                                     blue:(247/255.0) alpha:1.0]
                           forState:UIControlStateNormal];
    [self performSelector:@selector(choosePictureForScanQRCode) withObject:nil afterDelay:0.05];
}

- (void)choosePictureForScanQRCode {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__]
                         toFilePath:appDelegate.logFilePath];
    
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
            [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"-----> Received data from QRCode: %@", message] toFilePath:appDelegate.logFilePath];
            
            [self loginPBXFromStringHashCodeResult: message];
        }else{
            [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Can not find QR Code!"] duration:3.0 position:CSToastPositionCenter];
        }
        return;
    }
    [_icWaiting stopAnimating];
    _icWaiting.hidden = YES;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[appDelegate.localization localizedStringForKey:@"Notification"] message:[appDelegate.localization localizedStringForKey:@"Can not find QR Code!"] delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:@"Close"] otherButtonTitles: nil];
    [alertView show];
}

- (void)loginPBXFromStringHashCodeResult: (NSString *)message {
    NSArray *tmpArr = [message componentsSeparatedByString:@"/"];
    if (tmpArr.count == 3)
    {
        NSString *server = [tmpArr objectAtIndex: 0];
        NSString *account = [tmpArr objectAtIndex: 1];
        NSString *password = [tmpArr objectAtIndex: 2];
        
        if (![AppUtils isNullOrEmpty: server] && ![AppUtils isNullOrEmpty: account] && ![AppUtils isNullOrEmpty: password])
        {
            _tfAccount.text = account;
            _tfServerID.text = server;
            _tfPassword.text = password;
            
            _icWaiting.hidden = NO;
            [_icWaiting startAnimating];
            
            [self getInfoForPBXWithServerName: server];
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
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] result = %@", __FUNCTION__, result]
                             toFilePath:appDelegate.logFilePath];
        
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
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:AuthUser forKey:@"AuthUser"];
    [jsonDict setObject:AuthKey forKey:@"AuthKey"];
    [jsonDict setObject:hashString forKey:@"HashString"];
    
    [webService callWebServiceWithLink:DecryptRSA withParams:jsonDict];
    
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] jsonDict = %@", __FUNCTION__, @[jsonDict]]
                         toFilePath:appDelegate.logFilePath];
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
            
            _btnSave.enabled = FALSE;
        }
    }else{
        _tfServerID.text = _tfAccount.text = _tfPassword.text = @"";
        _btnSave.enabled = FALSE;
    }
}

#pragma mark - Switch Custom Delegate
- (void)switchButtonEnabled
{
    [self.view endEditing: TRUE];
    //  set lại info nếu user change thông tin và bấm turn off account
    [self showPBXAccountInformation];
    
    [WriteLogsUtils writeLogContent:@"USER PRESSED TURN ON SIP ACCOUNT" toFilePath:appDelegate.logFilePath];
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
        
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Enable proxy config with accountId = %@", __FUNCTION__, [SipUtils getAccountIdOfDefaultProxyConfig]] toFilePath:appDelegate.logFilePath];
    }else{
        [swAccount setUIForDisableStateWithActionTarget: NO];
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"You have not signed your account yet"] duration:2.0 position:CSToastPositionCenter];
    }
}

- (void)switchButtonDisabled
{
    [self.view endEditing: TRUE];
    
    //  set lại info nếu user change thông tin và bấm turn off account
    [self showPBXAccountInformation];
    
    [WriteLogsUtils writeLogContent:@"USER PRESSED TURN OFF SIP ACCOUNT" toFilePath:appDelegate.logFilePath];
    
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
        
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Disable proxy config with accountId = %@", __FUNCTION__, [SipUtils getAccountIdOfDefaultProxyConfig]] toFilePath:appDelegate.logFilePath];
    }else{
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"You have not signed your account yet"] duration:2.0 position:CSToastPositionCenter];
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

- (void)continueAfterClearAllProxyConfig {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__] toFilePath:appDelegate.logFilePath];
    
    if (registerInfo != nil) {
        [WriteLogsUtils writeLogContent:@"-----> registerInfo != NULL, so continue to register SIP ACCOUNT" toFilePath:appDelegate.logFilePath];
        
        if (timeoutTimer) {
            [timeoutTimer invalidate];
            timeoutTimer = nil;
        }
        timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(registerPBXTimeOut) userInfo:nil repeats:FALSE];
        
        NSString *account = [registerInfo objectForKey:@"account"];
        NSString *password = [registerInfo objectForKey:@"password"];
        NSString *domain = [registerInfo objectForKey:@"domain"];
        NSString *port = [registerInfo objectForKey:@"port"];
        
        [self registerPBXAccount:account password:password domain:domain port:port];
    }
}

#pragma mark - UITextfield delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing: TRUE];
    return TRUE;
}

@end
