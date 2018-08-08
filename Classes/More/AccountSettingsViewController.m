//
//  AccountSettingsViewController.m
//  linphone
//
//  Created by Apple on 4/26/17.
//
//

#import "AccountSettingsViewController.h"
#import "PhoneMainView.h"
#import "SettingCell.h"
#import "JSONKit.h"
#import <CommonCrypto/CommonDigest.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ChangePasswordPopupView.h"
#import "QRCodeReaderViewController.h"
#import "QRCodeReader.h"

@interface AccountSettingsViewController (){
    LinphoneAppDelegate *appDelegate;
    float hItem;
    float marginX;
    UILabel *bgStatus;
    
    UIActivityIndicatorView *waitingView;
    
    NSMutableData *serverInfoData;
    NSMutableData *receiveData;
    NSMutableData *qrCodeData;
    UIButton *btnScanFromPhoto;
    
    int typeReset;
    
    UIFont *textFont;
    NSString *pbxIp;
    NSString *pbxPort;
    
    NSTimer *timeoutTimer;
    
    NSString *tmpPBXID;
    NSString *tmpPBXUsername;
    NSString *tmpPBXPassword;
    
    
    float hPBXDetail;
    
    ChangePasswordPopupView *popupChangePass;
    QRCodeReaderViewController *scanQRCodeVC;
    BOOL loginWithQRCode;
    
    int typeProxyConfig;
    BOOL nextStepForTurnOnPBX;
    BOOL nextStepForQRCode;
    int totalAccount;
    int curIndex;
    
    WebServices *webService;
}
@end

@implementation NSString (MD5)
- (NSString *)MD5String {
    const char *cstr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, (int)strlen(cstr), result);
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}
@end

@implementation AccountSettingsViewController
@synthesize _viewHeader, _iconBack, _lbHeader;
@synthesize _viewTrunking, _lbTrunking, _imgTrunking, _lbPBXStatus, _viewChangePassword, _lbChangePassword, _imgChangePassword, _scrollViewContent;
@synthesize _viewPBXState, _lbPBXState, _swPBX;
@synthesize _viewPBXInfo, _tfPBXInfoID, _tfPBXInfoAcc, _tfPBXInfoPass, _btnPBXClear, _icQRCode, _btnPBXSave, _viewPBXInfoFooter;


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
                                                           fragmentWith:nil];
        compositeDescription.darkBackground = true;
    }
    return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
    return self.class.compositeViewDescription;
}

#pragma mark - My Controller Delegate

//  View không bị thay đổi sau khi vào pickerview controller
- (void) viewDidLayoutSubviews {
    if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        CGRect viewBounds = self.view.bounds;
        CGFloat topBarOffset = self.topLayoutGuide.length;
        viewBounds.origin.y = topBarOffset * -1;
        self.view.bounds = viewBounds;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //  my code here
    appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    webService = [[WebServices alloc] init];
    webService.delegate = self;
    
    [self settingForPBXAccountIfDontExists];
    
    [self setupUIForView];
    
    bgStatus = [[UILabel alloc] initWithFrame: CGRectMake(0, -[UIApplication sharedApplication].statusBarFrame.size.height, SCREEN_WIDTH, [UIApplication sharedApplication].statusBarFrame.size.height)];
    bgStatus.backgroundColor = UIColor.blackColor;
    [self.view addSubview: bgStatus];
    
    //  Thêm waiting view cho màn hình
    waitingView = [[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    waitingView.backgroundColor = UIColor.whiteColor;
    waitingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    waitingView.alpha = 0.5;
    [self.view addSubview: waitingView];
    
    hPBXDetail = 180.0;
    
    UITapGestureRecognizer *tapOnScreen = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTapOnMainScreen)];
    [self.view addGestureRecognizer: tapOnScreen];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [self showContentWithCurrentMessage];
    
    //  Add new by Khai Le on 23/02/2018
    LinphoneProxyConfig *defaultConfig = linphone_core_get_default_proxy_config(LC);
    const char *proxyUsername = linphone_address_get_username(linphone_proxy_config_get_identity_address(defaultConfig));
    NSString* defaultUsername = [NSString stringWithFormat:@"%s" , proxyUsername];
    if (defaultUsername != nil && ![defaultUsername hasPrefix:@"778899"]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:callnexPBXFlag];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    //  -----------
    
    [self showCurrentPBXInformation];
    
    //  Lưu thông tin PBX
    [self copyPBXInformation];
    
    typeReset = 0;
    loginWithQRCode = NO;
    
    //  notifications
    
    //  Hiển thị popup trunking pbx khi switch button
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenSwitchPBXChanged:)
                                                 name:k11ClickOnViewTrunkingPBX object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(registrationUpdateEvent:)
                                               name:kLinphoneRegistrationUpdate object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)viewDidUnload {
    [self set_viewHeader: nil];
    [self set_iconBack:nil];
    [self set_lbHeader: nil];
    
    [self set_scrollViewContent: nil];
    
    [self set_viewTrunking: nil];
    [self set_lbTrunking: nil];
    [self set_lbPBXStatus: nil];
    [self set_imgTrunking: nil];
    
    [self set_viewChangePassword: nil];
    [self set_imgChangePassword: nil];
    [self set_lbChangePassword: nil];
    
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)_iconBackClicked:(UIButton *)sender {
    [self.view endEditing: true];
    [[PhoneMainView instance] popCurrentView];
}

#pragma mark - my functions


//  Hiển thị bàn phím
- (void)keyboardDidShow: (NSNotification *) notif{
    CGSize keyboardSize = [[[notif userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.05 animations:^{
        _scrollViewContent.frame = CGRectMake(_scrollViewContent.frame.origin.x, _scrollViewContent.frame.origin.y, _scrollViewContent.frame.size.width, SCREEN_HEIGHT-appDelegate._hStatus-appDelegate._hHeader-keyboardSize.height);
        
        if (popupChangePass != nil) {
            popupChangePass.frame = CGRectMake(popupChangePass.frame.origin.x, (SCREEN_HEIGHT-appDelegate._hStatus-keyboardSize.height-popupChangePass.frame.size.height)/2, popupChangePass.frame.size.width, popupChangePass.frame.size.height);
        }
    }];
}

//  Ẩn bàn phím
- (void)keyboardDidHide: (NSNotification *) notif{
    [UIView animateWithDuration:0.05 animations:^{
        _scrollViewContent.frame = CGRectMake(_scrollViewContent.frame.origin.x, _scrollViewContent.frame.origin.y, _scrollViewContent.frame.size.width, SCREEN_HEIGHT-(appDelegate._hStatus+appDelegate._hHeader));
        
        popupChangePass.frame = CGRectMake(popupChangePass.frame.origin.x, (SCREEN_HEIGHT-20-popupChangePass.frame.size.height)/2, popupChangePass.frame.size.width, popupChangePass.frame.size.height);
    }];
}

- (void)whenTapOnChangePasswordView {
    [self.view endEditing: YES];
    
    float hPopup = 4 + 40 + 10 + 30 + 10 + 30 + 10 + 30 + 30 + 40 + 4;
    popupChangePass = [[ChangePasswordPopupView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-268)/2, (SCREEN_HEIGHT-20-hPopup)/2, 268, hPopup)];
    [popupChangePass showContentWithCurrentLanguage];
    [popupChangePass._btnConfirm addTarget:self
                                    action:@selector(btnChangePasswordPressed)
                          forControlEvents:UIControlEventTouchUpInside];
    [popupChangePass showInView: appDelegate.window animated: true];
}

- (void)btnChangePasswordPressed
{
    NSString *oldPass = popupChangePass._tfOldPass.text;
    NSString *newPass = popupChangePass._tfNewPass.text;
    NSString *confirmPass = popupChangePass._tfConfirmPass.text;
    
    if ([oldPass isEqualToString: @""] || [newPass isEqualToString: @""] || [confirmPass isEqualToString: @""])
    {
        popupChangePass._lbError.text = [appDelegate.localization localizedStringForKey:text_change_pass_empty];
    }
    else if (oldPass.length < 6 || newPass.length < 6 || confirmPass.length < 6)
    {
        popupChangePass._lbError.text = [appDelegate.localization localizedStringForKey:text_change_pass_len];
    }
    else if (![oldPass isEqualToString:PASSWORD])
    {
        popupChangePass._lbError.text = [appDelegate.localization localizedStringForKey:text_old_pass_incorrect];
    }
    else if(![newPass isEqualToString: confirmPass])
    {
        popupChangePass._lbError.text = [appDelegate.localization localizedStringForKey:text_confirm_pass_not_match];
    }
    else{
        [popupChangePass fadeOut];
        [self.view endEditing: true];
        
        [waitingView startAnimating];
        [self startChangePasswordForUser: popupChangePass._tfNewPass.text];
    }
}

- (void)startChangePasswordForUser: (NSString *)password
{
    NSString *requestString = [AppUtils randomStringWithLength: 10];
    NSString *totalString = [NSString stringWithFormat:@"%@%@%@", PASSWORD, requestString, USERNAME];
    
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:AuthUser forKey:@"AuthUser"];
    [jsonDict setObject:AuthKey forKey:@"AuthKey"];
    [jsonDict setObject:requestString forKey:@"RequestString"];
    [jsonDict setObject:USERNAME forKey:@"LoginUser"];
    [jsonDict setObject:[[totalString MD5String] lowercaseString] forKey:@"MD5String"];
    [jsonDict setObject:password forKey:@"NewPassword"];
    
    [webService callWebServiceWithLink:changePasswordFunc withParams:jsonDict];
}

- (void)registerPBXTimeOut {
    //  Clear pbx accout đã register nhưng thất bại
    NSString *pbxUsername = [_tfPBXInfoAcc text];
    if (![pbxUsername isEqualToString:@""] && pbxUsername != nil) {
        [self removeProxyConfigWithAccount: pbxUsername];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_ID];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_USERNAME];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_PASSWORD];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_IP_ADDRESSS];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_PORT];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [waitingView stopAnimating];
    [self.view makeToast:[appDelegate.localization localizedStringForKey:register_pbx_failed]
                duration:2.0 position:CSToastPositionCenter];
    [timeoutTimer invalidate];
    timeoutTimer = nil;
}



#pragma mark - LE KHAI

- (void)whenTapOnMainScreen {
    [self.view endEditing: YES];
}

- (void)scanQRCodeForPBX {
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

- (void)btnScanFromPhotoPressed {
    btnScanFromPhoto.backgroundColor = [UIColor whiteColor];
    [btnScanFromPhoto setTitleColor:[UIColor colorWithRed:(2/255.0) green:(164/255.0)
                                                     blue:(247/255.0) alpha:1.0]
                           forState:UIControlStateNormal];
    [NSTimer scheduledTimerWithTimeInterval:0.05 target:self
                                   selector:@selector(choosePictureForScanQRCode)
                                   userInfo:nil repeats:NO];
}



#pragma mark - Image picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        NSString* type = [info objectForKey:UIImagePickerControllerMediaType];
        if ([type isEqualToString: (NSString*)kUTTypeImage] ) {
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            [self getQRCodeContentFromImage: image];
        }
    }];
}

- (void)showPBXInforForView {
    _tfPBXInfoID.text = tmpPBXID;
    _tfPBXInfoAcc.text = tmpPBXUsername;
    _tfPBXInfoPass.text = tmpPBXPassword;
}

#pragma mark - Khải Lê functions

- (void)loginPBXFromStringHashCodeResult: (NSString *)message {
    NSArray *tmpArr = [message componentsSeparatedByString:@"/"];
    if (tmpArr.count == 3) {
        
        NSString *pbxID = [tmpArr objectAtIndex: 0];
        NSString *pbxUsername = [tmpArr objectAtIndex: 1];
        NSString *pbxPassword = [tmpArr objectAtIndex: 2];
        
        if (![pbxID isEqualToString:@""] && ![pbxUsername isEqualToString:@""] && ![pbxPassword isEqualToString:@""])
        {
            loginWithQRCode = YES;
            timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self
                                                          selector:@selector(registerPBXTimeOut)
                                                          userInfo:nil repeats:false];
            //  Lưu thông tin PBX nếu đăng nhập thất bại
            tmpPBXID = pbxID;
            tmpPBXUsername = pbxUsername;
            tmpPBXPassword = pbxPassword;
            //  ----------
            
            _tfPBXInfoID.text = pbxID;
            _tfPBXInfoAcc.text = pbxUsername;
            _tfPBXInfoPass.text = pbxPassword;
            
            _imgTrunking.image = [UIImage imageNamed:@"icon-next.png"];
            
            [UIView animateWithDuration:0.2 animations:^{
                _viewPBXState.frame = CGRectMake(0, _viewTrunking.frame.origin.y+_viewTrunking.frame.size.height, _viewTrunking.frame.size.width, 0);
                _viewPBXInfo.frame = CGRectMake(0, _viewPBXState.frame.origin.y+_viewPBXState.frame.size.height, _viewPBXState.frame.size.width, 0);
                _viewChangePassword.frame = CGRectMake(0, _viewPBXInfo.frame.origin.y+_viewPBXInfo.frame.size.height+1, _viewPBXState.frame.size.width, hItem);
            } completion:^(BOOL finished) {
                _scrollViewContent.contentSize = CGSizeMake(_scrollViewContent.frame.size.width, _viewChangePassword.frame.origin.y+_viewChangePassword.frame.size.height);
                [self.view endEditing: true];
                
                [waitingView startAnimating];
                
                //  Lưu thông tin PBX nếu đăng nhập thất bại
                tmpPBXID = [_tfPBXInfoID text];
                tmpPBXUsername = [_tfPBXInfoAcc text];
                tmpPBXPassword = [_tfPBXInfoPass text];
                //  ----------
                
                [self getInfoForPBXWithServerName: _tfPBXInfoID.text];
            }];
        }else {
            [self.view makeToast:[appDelegate.localization localizedStringForKey:text_dien_day_tu_thong_tin]
                        duration:2.0 position:CSToastPositionCenter];
        }
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[appDelegate.localization localizedStringForKey:text_notification] message:[appDelegate.localization localizedStringForKey:cannot_find_qrcode] delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:text_close] otherButtonTitles: nil];
        [alertView show];
    }
}

- (void)whenClearPBXSuccessfully {
    [waitingView stopAnimating];
    
    _tfPBXInfoID.text = @"";
    _tfPBXInfoAcc.text = @"";
    _tfPBXInfoPass.text = @"";
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_ID];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_USERNAME];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_PASSWORD];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_IP_ADDRESSS];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_PORT];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0]
                                              forKey:callnexPBXFlag];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.view makeToast:[appDelegate.localization localizedStringForKey:clear_pbx_successfully]
                duration:2.0 position:CSToastPositionCenter];
    
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self
                                   selector:@selector(goBack) userInfo:nil repeats:NO];
}

- (void)whenTurnOnPBXSuccessfully {
    [timeoutTimer invalidate];
    timeoutTimer = nil;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1]
                                              forKey:callnexPBXFlag];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _lbPBXStatus.text = [appDelegate.localization localizedStringForKey:text_pbx_on];
    
    [waitingView stopAnimating];
    [self.view makeToast:[appDelegate.localization localizedStringForKey:pbx_turn_on]
                duration:2.0 position:CSToastPositionCenter];
}

- (void)whenTurnOfPBXSuccessfully {
    [timeoutTimer invalidate];
    timeoutTimer = nil;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0]
                                              forKey:callnexPBXFlag];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _lbPBXStatus.text = [appDelegate.localization localizedStringForKey:text_pbx_off];
    
    [waitingView stopAnimating];
    [self.view makeToast:[appDelegate.localization localizedStringForKey:pbx_turn_off]
                duration:2.0 position:CSToastPositionCenter];
}

- (void)whenLoginPBXSuccessfully {
    [waitingView stopAnimating];
    [self.view makeToast:[appDelegate.localization localizedStringForKey:text_successfully]
                duration:2.0 position:CSToastPositionCenter];
    _lbPBXStatus.text = [appDelegate.localization localizedStringForKey:text_pbx_on];
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self
                                   selector:@selector(goBack) userInfo:nil repeats:NO];
}

- (void)goBack {
    [[PhoneMainView instance] popCurrentView];
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

- (void)registerPBXAccount: (NSString *)pbxAccount password: (NSString *)password ipAddress: (NSString *)address port: (NSString *)portID
{
    NSArray *data = @[address, pbxAccount, password, portID];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startRegisterPBX:) userInfo:data repeats:NO];
}

- (void)reloginToSipAccount
{
    BOOL success = [SipUtils loginSipWithDomain:SIP_DOMAIN username:USERNAME password:PASSWORD port:PORT];
    if (success) {
        [SipUtils registerProxyWithUsername:USERNAME password:PASSWORD domain:SIP_DOMAIN port:PORT];
    }
}

- (void)showContentWithCurrentMessage {
    _lbHeader.text = [appDelegate.localization localizedStringForKey:text_acc_setting];
    _lbTrunking.text = [appDelegate.localization localizedStringForKey:text_trunking];
    _lbChangePassword.text = [appDelegate.localization localizedStringForKey:text_change_password];
}

- (void)showCurrentPBXInformation {
    //  reset lại view về trạng thái ban đầu
    _viewTrunking.frame = CGRectMake(0, 0, _scrollViewContent.frame.size.width, hItem);
    _imgTrunking.image = [UIImage imageNamed:@"icon-next.png"];
    
    _viewPBXState.frame = CGRectMake(0, _viewTrunking.frame.origin.y+_viewTrunking.frame.size.height+1, _viewTrunking.frame.size.width, 0);
    
    _viewPBXInfo.frame = CGRectMake(0, _viewPBXState.frame.origin.y+_viewPBXState.frame.size.height+1, _viewPBXState.frame.size.width, 0);
    _viewChangePassword.frame = CGRectMake(0, _viewPBXState.frame.origin.y+_viewPBXState.frame.size.height+1, _viewPBXState.frame.size.width, hItem);
    
    // kiểm tra trạng thái pbx hiện tại
    BOOL exists = [self checkTrunkingAccoutExists];
    if (exists) {
        _lbPBXStatus.text = [appDelegate.localization localizedStringForKey:text_pbx_on];
    }else{
        _lbPBXStatus.text = [appDelegate.localization localizedStringForKey:text_pbx_off];
    }
}

- (BOOL)checkTrunkingAccoutExists {
    NSNumber *pbxFlag = [[NSUserDefaults standardUserDefaults] objectForKey:callnexPBXFlag];
    if (pbxFlag == nil || [pbxFlag intValue] == 0) {
        return NO;
    }else {
        NSString *pbxAccount = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_USERNAME];
        if (pbxAccount == nil || [pbxAccount isEqualToString:@""]) {
            return NO;
        }else{
            return YES;
        }
    }
}

- (void)copyPBXInformation {
    NSString *pbxID = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_ID];
    NSString *pbxUsername = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_USERNAME];
    NSString *pbxPassword = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_PASSWORD];
    
    if (pbxID != nil && ![pbxID isEqualToString:@""]) {
        tmpPBXID = pbxID;
    }
    
    if (pbxUsername != nil && ![pbxUsername isEqualToString:@""]) {
        tmpPBXUsername = pbxUsername;
    }
    
    if (pbxPassword != nil && ![pbxPassword isEqualToString:@""]) {
        tmpPBXPassword = pbxPassword;
    }
}

//  Tap vào view trungking
- (void)whenTapOnTrunkingView {
    [self.view endEditing: YES];
    
    //  Update switch icon
    BOOL hasPBXAccount = [self checkTrunkingAccoutExists];
    if (hasPBXAccount) {
        [_swPBX setUIForEnableState];
        [self showPBXInforForView];
    }else{
        [_swPBX setUIForDisableState];
    }
    
    if (_viewPBXState.frame.size.height == 0) {
        //  Nếu PBX đang đc turn on thì hiển thị luôn, ngược lại thì ẩn đi
        if (hasPBXAccount) {
            [UIView animateWithDuration:0.2 animations:^{
                _viewPBXInfo.hidden = NO;
                
                _imgTrunking.image = [UIImage imageNamed:@"icon-down.png"];
                _viewPBXState.frame = CGRectMake(0, _viewTrunking.frame.origin.y+_viewTrunking.frame.size.height+1, _viewTrunking.frame.size.width, hItem);
                _viewPBXInfo.frame = CGRectMake(0, _viewPBXState.frame.origin.y+_viewPBXState.frame.size.height, _viewPBXInfo.frame.size.width, hPBXDetail);
                _viewChangePassword.frame = CGRectMake(0, _viewPBXInfo.frame.origin.y+_viewPBXInfo.frame.size.height+1, _viewPBXInfo.frame.size.width, hItem);
            }];
        }else{
            [UIView animateWithDuration:0.2 animations:^{
                _imgTrunking.image = [UIImage imageNamed:@"icon-down.png"];
                _viewPBXState.frame = CGRectMake(0, _viewTrunking.frame.origin.y+_viewTrunking.frame.size.height+1, _viewTrunking.frame.size.width, hItem);
                _viewPBXInfo.frame = CGRectMake(0, _viewPBXState.frame.origin.y+_viewPBXState.frame.size.height, _viewPBXInfo.frame.size.width, 0);
                _viewChangePassword.frame = CGRectMake(0, _viewPBXInfo.frame.origin.y+_viewPBXInfo.frame.size.height+1, _viewPBXState.frame.size.width, hItem);
            }];
        }
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            _imgTrunking.image = [UIImage imageNamed:@"icon-next.png"];
            _viewPBXState.frame = CGRectMake(0, _viewTrunking.frame.origin.y+_viewTrunking.frame.size.height, _viewTrunking.frame.size.width, 0);
            _viewPBXInfo.frame = CGRectMake(0, _viewPBXState.frame.origin.y+_viewPBXState.frame.size.height, _viewPBXState.frame.size.width, 0);
            _viewChangePassword.frame = CGRectMake(0, _viewPBXInfo.frame.origin.y+_viewPBXInfo.frame.size.height+1, _viewPBXState.frame.size.width, hItem);
        }];
    }
}

- (void)setupUIForView {
    if (SCREEN_WIDTH > 320) {
        hItem = 55.0;
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
        _lbHeader.font = [UIFont fontWithName:HelveticaNeue size:20.0];
    }else{
        hItem = 45.0;
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
        _lbHeader.font = [UIFont fontWithName:HelveticaNeue size:18.0];
    }
    //  header view
    _viewHeader.frame = CGRectMake(0, 0, SCREEN_WIDTH, appDelegate._hHeader);
    _iconBack.frame = CGRectMake(0, 0, appDelegate._hHeader, appDelegate._hHeader);
    [_iconBack setBackgroundImage:[UIImage imageNamed:@"ic_back_act.png"]
                         forState:UIControlStateHighlighted];
    
     _lbHeader.frame = CGRectMake(_iconBack.frame.origin.x+_iconBack.frame.size.width+5, 0, _viewHeader.frame.size.width-2*(_iconBack.frame.origin.x+_iconBack.frame.size.width+10), appDelegate._hHeader);
    
    //  content
    marginX = 15.0;
    
    _scrollViewContent.frame = CGRectMake(0, _viewHeader.frame.origin.y+_viewHeader.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT-(appDelegate._hStatus+appDelegate._hHeader));
    _scrollViewContent.contentSize = CGSizeMake(_scrollViewContent.frame.size.width, SCREEN_HEIGHT-(appDelegate._hStatus+appDelegate._hHeader));
    
    //  view trunking
    UITapGestureRecognizer *tapOnTrunking = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTapOnTrunkingView)];
    _viewTrunking.userInteractionEnabled = YES;
    [_viewTrunking addGestureRecognizer: tapOnTrunking];
    
    _viewTrunking.frame = CGRectMake(0, 0, _scrollViewContent.frame.size.width, hItem);
    _imgTrunking.frame = CGRectMake(_viewTrunking.frame.size.width-hItem, 0, hItem, hItem);
    _lbPBXStatus.frame = CGRectMake(_imgTrunking.frame.origin.x-7-50, _imgTrunking.frame.origin.y, 50, _imgTrunking.frame.size.height);
    _lbTrunking.frame = CGRectMake(marginX, 0, _lbPBXStatus.frame.origin.x-marginX, hItem);
    _lbTrunking.font = textFont;
    _lbPBXStatus.font = textFont;
    
    //  PBX State
    _viewPBXState.frame = CGRectMake(0, _viewTrunking.frame.origin.y+_viewTrunking.frame.size.height, _viewTrunking.frame.size.width, hItem);
    _lbPBXState.frame = CGRectMake(marginX, 0, _viewPBXState.frame.size.width/2, hItem);
    _lbPBXState.font = textFont;
    if (_swPBX == nil) {
        // switch pbx
        _swPBX = [[CallnexSwitchButton alloc] initWithState:NO frame:CGRectMake(_viewPBXState.frame.size.width-54-10, (_viewPBXState.frame.size.height-27)/2, 54, 27)];
        _swPBX._typeSwitch = eSwitchTrukingPBX;
        [_viewPBXState addSubview: _swPBX];
    }
    
    [self createViewPBXInforForMainView];
    
    //  view change password
    UITapGestureRecognizer *tapOnPassword = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTapOnChangePasswordView)];
    _viewChangePassword.userInteractionEnabled = YES;
    [_viewChangePassword addGestureRecognizer: tapOnPassword];
    
    _viewChangePassword.frame = CGRectMake(0, _viewTrunking.frame.origin.y+_viewTrunking.frame.size.height+1, _viewTrunking.frame.size.width, hItem);
    _imgChangePassword.frame = CGRectMake(_viewChangePassword.frame.size.width-hItem, 0, hItem, hItem);
    _lbChangePassword.frame = CGRectMake(marginX, 0, _imgTrunking.frame.origin.x-marginX, hItem);
    _lbChangePassword.font = textFont;
}

//  Khi click trên switch button trunking pbx
- (void)whenSwitchPBXChanged: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[NSNumber class]]) {
        if ([object intValue] == 1) {
            if (_viewPBXInfo == nil) {
                [self createViewPBXInforForMainView];
            }
            
            //  Hiển thị view trunking
            [UIView animateWithDuration:0.2 animations:^{
                _viewPBXInfo.hidden = NO;
                _viewPBXInfo.frame = CGRectMake(0, _viewPBXState.frame.origin.y+_viewPBXState.frame.size.height, _viewPBXInfo.frame.size.width, hPBXDetail);
                _viewChangePassword.frame = CGRectMake(0, _viewPBXInfo.frame.origin.y+_viewPBXInfo.frame.size.height+1, _viewPBXInfo.frame.size.width, hItem);
            }completion:^(BOOL finished) {
                _scrollViewContent.contentSize = CGSizeMake(_scrollViewContent.frame.size.width, _viewChangePassword.frame.origin.y+_viewChangePassword.frame.size.height);
            }];
            
            NSString *pbxID   = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_ID];
            NSString *pbxUsername   = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_USERNAME];
            NSString *pbxPassword   = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_PASSWORD];
            NSString *pbxAddress   = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_IP_ADDRESSS];
            NSString *tmpPbxPort   = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_PORT];
            
            if (![pbxUsername isEqualToString: @""] && ![pbxPassword isEqualToString: @""] && ![pbxAddress isEqualToString: @""] && ![tmpPbxPort isEqualToString: @""])
            {
                _tfPBXInfoID.text = pbxID;
                _tfPBXInfoAcc.text = pbxUsername;
                _tfPBXInfoPass.text = pbxPassword;
                
                [waitingView startAnimating];
                
                typeReset = eTurnOnPBX;
                [self clearAllProxyConfigAndAccount];
            }else{
                _tfPBXInfoID.text = tmpPBXID;
                _tfPBXInfoAcc.text = tmpPBXUsername;
                _tfPBXInfoPass.text = tmpPBXPassword;
            }
        }else {
            //  close view PBX
            [UIView animateWithDuration:0.2 animations:^{
                _viewPBXInfo.frame = CGRectMake(0, _viewPBXState.frame.origin.y+_viewPBXState.frame.size.height, _viewPBXInfo.frame.size.width, 0);
                _viewChangePassword.frame = CGRectMake(0, _viewPBXInfo.frame.origin.y+_viewPBXInfo.frame.size.height+1, _viewPBXInfo.frame.size.width, hItem);
            }completion:^(BOOL finished) {
                _scrollViewContent.contentSize = CGSizeMake(_scrollViewContent.frame.size.width, _viewChangePassword.frame.origin.y+_viewChangePassword.frame.size.height);
                [self.view endEditing: true];
                
                NSString *pbxID = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_ID];
                NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_USERNAME];
                NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_PASSWORD];
                if (pbxID == nil || [pbxID isEqualToString: @""] || username == nil || [username isEqualToString: @""] || password == nil || [password isEqualToString: @""])
                {
                    NSLog(@"Không đủ thông tin để turn off PBX");
                }else{
                    [waitingView startAnimating];
                    
                    typeReset = eTurnOffPBX;
                    [self clearAllProxyConfigAndAccount];
                }
            }];
        }
    }
}

- (void)createViewPBXInforForMainView {
    _viewPBXInfo = [[UIView alloc] initWithFrame: CGRectMake(0, _viewPBXState.frame.origin.y+_viewPBXState.frame.size.height, SCREEN_WIDTH, 0)];
    _viewPBXInfo.backgroundColor = [UIColor whiteColor];
    _viewPBXInfo.clipsToBounds = YES;
    
    _tfPBXInfoID = [[UITextField alloc] initWithFrame: CGRectMake(marginX, 5, _viewPBXInfo.frame.size.width-2*marginX, 35.0)];
    _tfPBXInfoID.borderStyle = UITextBorderStyleNone;
    _tfPBXInfoID.layer.cornerRadius = 4.0;
    _tfPBXInfoID.layer.borderWidth = 1.0;
    _tfPBXInfoID.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _tfPBXInfoID.placeholder = [appDelegate.localization localizedStringForKey: text_trunking_id];
    _tfPBXInfoID.font = textFont;
    [_viewPBXInfo addSubview: _tfPBXInfoID];
    
    UIView *pvID = [[UIView alloc] initWithFrame: CGRectMake(0, 0, marginX, _tfPBXInfoID.frame.size.height)];
    _tfPBXInfoID.leftView = pvID;
    _tfPBXInfoID.leftViewMode = UITextFieldViewModeAlways;
    
    
    _tfPBXInfoAcc = [[UITextField alloc] initWithFrame: CGRectMake(_tfPBXInfoID.frame.origin.x, _tfPBXInfoID.frame.origin.y+_tfPBXInfoID.frame.size.height+10, _tfPBXInfoID.frame.size.width, _tfPBXInfoID.frame.size.height)];
    _tfPBXInfoAcc.borderStyle = UITextBorderStyleNone;
    _tfPBXInfoAcc.layer.cornerRadius = 4.0;
    _tfPBXInfoAcc.layer.borderWidth = 1.0;
    _tfPBXInfoAcc.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _tfPBXInfoAcc.placeholder = [appDelegate.localization localizedStringForKey: text_trunking_user];
    _tfPBXInfoAcc.font = textFont;
    [_viewPBXInfo addSubview: _tfPBXInfoAcc];
    
    UIView *pvAcc = [[UIView alloc] initWithFrame: CGRectMake(0, 0, marginX, _tfPBXInfoAcc.frame.size.height)];
    _tfPBXInfoAcc.leftView = pvAcc;
    _tfPBXInfoAcc.leftViewMode = UITextFieldViewModeAlways;
    
    _tfPBXInfoPass = [[UITextField alloc] initWithFrame: CGRectMake(_tfPBXInfoAcc.frame.origin.x, _tfPBXInfoAcc.frame.origin.y+_tfPBXInfoAcc.frame.size.height+10, _tfPBXInfoAcc.frame.size.width, _tfPBXInfoAcc.frame.size.height)];
    _tfPBXInfoPass.borderStyle = UITextBorderStyleNone;
    _tfPBXInfoPass.layer.cornerRadius = 4.0;
    _tfPBXInfoPass.layer.borderWidth = 1.0;
    _tfPBXInfoPass.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _tfPBXInfoPass.placeholder = [appDelegate.localization localizedStringForKey: text_trunking_pass];
    _tfPBXInfoPass.font = textFont;
    _tfPBXInfoPass.secureTextEntry = YES;
    [_viewPBXInfo addSubview: _tfPBXInfoPass];
    
    UIView *pvPass = [[UIView alloc] initWithFrame: CGRectMake(0, 0, marginX, _tfPBXInfoPass.frame.size.height)];
    _tfPBXInfoPass.leftView = pvPass;
    _tfPBXInfoPass.leftViewMode = UITextFieldViewModeAlways;
    
    _viewPBXInfoFooter = [[UIView alloc] initWithFrame: CGRectMake(0, _tfPBXInfoPass.frame.origin.y+_tfPBXInfoPass.frame.size.height+5, _viewPBXInfo.frame.size.width, 45)];
    
    //  clear button
    _btnPBXClear = [UIButton buttonWithType: UIButtonTypeCustom];
    _btnPBXClear.frame = CGRectMake(marginX, 5, 100, 35);
    [_btnPBXClear setTitle:[appDelegate.localization localizedStringForKey: text_trunking_clear]
                  forState:UIControlStateNormal];
    _btnPBXClear.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(0/255.0)
                                                    blue:(0/255.0) alpha:1.0];
    [_btnPBXClear addTarget:self
                     action:@selector(btnClearTrunkingPBX:)
           forControlEvents:UIControlEventTouchUpInside];
    [_viewPBXInfoFooter addSubview: _btnPBXClear];
    
    //  save button
    _btnPBXSave = [UIButton buttonWithType: UIButtonTypeCustom];
    _btnPBXSave.frame = CGRectMake(_viewPBXInfoFooter.frame.size.width-marginX-_btnPBXClear.frame.size.width, _btnPBXClear.frame.origin.y, _btnPBXClear.frame.size.width, _btnPBXClear.frame.size.height);
    [_btnPBXSave setTitle:[appDelegate.localization localizedStringForKey: text_trunking_save]
                 forState:UIControlStateNormal];
    _btnPBXSave.backgroundColor = [UIColor colorWithRed:(154/255.0) green:(202/255.0)
                                                   blue:(61/255.0) alpha:1.0];
    [_btnPBXSave addTarget:self
                    action:@selector(btnSaveTrunkingPBX:)
          forControlEvents:UIControlEventTouchUpInside];
    [_viewPBXInfoFooter addSubview: _btnPBXSave];
    
    //  search QRCode icon
    _icQRCode = [[UIButton alloc] initWithFrame: CGRectMake((_viewPBXInfoFooter.frame.size.width-35.0)/2, (_viewPBXInfoFooter.frame.size.height-35.0)/2, 35.0, 35.0)];
    [_icQRCode setBackgroundImage:[UIImage imageNamed:@"ic_search_qrcode"] forState:UIControlStateNormal];
    [_icQRCode addTarget:self
                  action:@selector(scanQRCodeForPBX)
        forControlEvents:UIControlEventTouchUpInside];
    [_viewPBXInfoFooter addSubview: _icQRCode];
    
    [_viewPBXInfo addSubview: _viewPBXInfoFooter];
    [_scrollViewContent addSubview: _viewPBXInfo];
    _viewPBXInfo.hidden = YES;
}

- (void)btnClearTrunkingPBX: (UIButton *)sender {
    timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self
                                                  selector:@selector(registerPBXTimeOut)
                                                  userInfo:nil repeats:false];
    
    [sender setBackgroundColor:[UIColor colorWithRed:(237/255.0) green:(32/255.0)
                                                blue:(36/255.0) alpha:1.0]];
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    tmpPBXID = @"";
    tmpPBXUsername = @"";
    tmpPBXPassword = @"";
    
    NSString *pbxID = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_ID];
    NSString *pbxUsername = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_USERNAME];
    NSString *pbxPassword = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_PASSWORD];
    NSString *pbxIP = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_IP_ADDRESSS];
    NSString *pbxPort = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_PORT];
    
    if (pbxID != nil && ![pbxID isEqualToString:@""] && pbxUsername != nil && ![pbxUsername isEqualToString:@""] && pbxPassword != nil && ![pbxPassword isEqualToString:@""] && pbxIP != nil && ![pbxIP isEqualToString:@""] && pbxPort != nil && ![pbxPort isEqualToString:@""])
    {
        [UIView animateWithDuration:0.2 animations:^{
            _imgTrunking.image = [UIImage imageNamed:@"icon-next.png"];
            _viewPBXState.frame = CGRectMake(0, _viewTrunking.frame.origin.y+_viewTrunking.frame.size.height, _viewTrunking.frame.size.width, 0);
            _viewPBXInfo.frame = CGRectMake(0, _viewPBXState.frame.origin.y+_viewPBXState.frame.size.height, _viewPBXState.frame.size.width, 0);
            _viewChangePassword.frame = CGRectMake(0, _viewPBXInfo.frame.origin.y+_viewPBXInfo.frame.size.height+1, _viewPBXState.frame.size.width, hItem);
        } completion:^(BOOL finished) {
            _scrollViewContent.contentSize = CGSizeMake(_scrollViewContent.frame.size.width, _viewChangePassword.frame.origin.y+_viewChangePassword.frame.size.height);
            [self.view endEditing: true];
            
            //  Clear PBX
            typeReset = eClearPBX;
            [waitingView startAnimating];
            [self clearAllProxyConfigAndAccount];
        }];
    }
}

- (void)btnSaveTrunkingPBX: (UIButton *)sender {
    timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self
                                                  selector:@selector(registerPBXTimeOut)
                                                  userInfo:nil repeats:false];
    
    [sender setBackgroundColor:[UIColor colorWithRed:(154/255.0) green:(202/255.0)
                                                blue:(61/255.0) alpha:1.0]];
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    NSString *pbxID = _tfPBXInfoID.text;
    NSString *pbxUsername = _tfPBXInfoAcc.text;
    NSString *pbxPassword = _tfPBXInfoPass.text;
    
    if (![pbxID isEqualToString:@""] && ![pbxUsername isEqualToString:@""] && ![pbxPassword isEqualToString:@""])
    {
        //  Lưu thông tin PBX nếu đăng nhập thất bại
        tmpPBXID = pbxID;
        tmpPBXUsername = pbxUsername;
        tmpPBXPassword = pbxPassword;
        //  ----------
        _imgTrunking.image = [UIImage imageNamed:@"icon-next.png"];
        
        [UIView animateWithDuration:0.2 animations:^{
            _imgTrunking.image = [UIImage imageNamed:@"icon-next.png"];
            _viewPBXState.frame = CGRectMake(0, _viewTrunking.frame.origin.y+_viewTrunking.frame.size.height, _viewTrunking.frame.size.width, 0);
            _viewPBXInfo.frame = CGRectMake(0, _viewPBXState.frame.origin.y+_viewPBXState.frame.size.height, _viewPBXState.frame.size.width, 0);
            _viewChangePassword.frame = CGRectMake(0, _viewPBXInfo.frame.origin.y+_viewPBXInfo.frame.size.height+1, _viewPBXState.frame.size.width, hItem);
        } completion:^(BOOL finished) {
            _scrollViewContent.contentSize = CGSizeMake(_scrollViewContent.frame.size.width, _viewChangePassword.frame.origin.y+_viewChangePassword.frame.size.height);
            [self.view endEditing: true];
            
            [waitingView startAnimating];
            
            [self getInfoForPBXWithServerName: _tfPBXInfoID.text];
        }];
    }else {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:text_dien_day_tu_thong_tin]
                    duration:2.0 position:CSToastPositionCenter];
    }
}

- (void)settingForPBXAccountIfDontExists {
    NSString *pbxID = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_ID];
    if (pbxID == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_ID];
    }
    
    NSString *pbxUsername   = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_USERNAME];
    if (pbxUsername == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_USERNAME];
    }
    
    NSString *pbxPassword   = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_PASSWORD];
    if (pbxPassword == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_PASSWORD];
    }
    
    NSString *pbxAddress   = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_IP_ADDRESSS];
    if (pbxAddress == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_IP_ADDRESSS];
    }
    
    NSString *tmpPbxPort   = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_PORT];
    if (tmpPbxPort == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PBX_PORT];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
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

#pragma mark - Proxy Config update

- (void)registrationUpdateEvent:(NSNotification *)notif {
    NSString *message = [notif.userInfo objectForKey:@"message"];
    [self registrationUpdate:[[notif.userInfo objectForKey:@"state"] intValue]
                    forProxy:[[notif.userInfo objectForKeyedSubscript:@"cfg"] pointerValue]
                     message:message];
}

- (void)registrationUpdate:(LinphoneRegistrationState)state forProxy:(LinphoneProxyConfig *)proxy message:(NSString *)message {
    switch (state) {
        case LinphoneRegistrationOk: {
            if (typeReset == eClearPBX || typeReset == eTurnOffPBX) {
                [timeoutTimer invalidate];
                timeoutTimer = nil;
                
                //  update token PBX
                NSString *pbxUsername = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_USERNAME];
                NSString *pbxID = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_ID];
                [self updateCustomerTokenIOSForPBX:pbxID andUsername:pbxUsername withTokenValue:@""];
                
                break;
            }else if (typeReset == eTurnOnPBX){
                if (!nextStepForTurnOnPBX) {
                    NSLog(@"-------> Login SIP thành công, tiếp tục login PBX");
                    
                    NSString *pbxUsername = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_USERNAME];
                    NSString *pbxPassword = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_PASSWORD];
                    NSString *ipAddress = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_IP_ADDRESSS];
                    NSString *pbxPort = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_PORT];
                    
                    nextStepForTurnOnPBX = YES;
                    [self registerPBXAccount: pbxUsername password: pbxPassword ipAddress: ipAddress port: pbxPort];
                }else{
                    nextStepForTurnOnPBX = NO;
                    if (appDelegate._deviceToken != nil) {
                        [self updateCustomerTokenIOSForPBX: _tfPBXInfoID.text andUsername: _tfPBXInfoAcc.text withTokenValue:appDelegate._deviceToken];
                    }else{
                        [self whenTurnOnPBXSuccessfully];
                    }
                }
                break;
            }else if (loginWithQRCode){
                if (!nextStepForQRCode) {
                    nextStepForQRCode = YES;
                    [self registerPBXAccount: tmpPBXUsername password: tmpPBXPassword ipAddress: pbxIp port: pbxPort];
                }else{
                    [timeoutTimer invalidate];
                    timeoutTimer = nil;
                    
                    [[NSUserDefaults standardUserDefaults] setObject:[_tfPBXInfoID text] forKey:PBX_ID];
                    [[NSUserDefaults standardUserDefaults] setObject:[_tfPBXInfoAcc text] forKey:PBX_USERNAME];
                    [[NSUserDefaults standardUserDefaults] setObject:[_tfPBXInfoPass text] forKey:PBX_PASSWORD];
                    [[NSUserDefaults standardUserDefaults] setObject:pbxIp forKey:PBX_IP_ADDRESSS];
                    [[NSUserDefaults standardUserDefaults] setObject:pbxPort forKey:PBX_PORT];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1]
                                                              forKey:callnexPBXFlag];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    nextStepForQRCode = NO;
                    if (appDelegate._deviceToken != nil) {
                        [self updateCustomerTokenIOSForPBX: tmpPBXID andUsername: _tfPBXInfoAcc.text withTokenValue:appDelegate._deviceToken];
                    }else{
                        [self whenLoginPBXSuccessfully];
                    }
                }
                break;
            }else{
                if (typeProxyConfig == loginSIP) {
                    typeProxyConfig = loginPBX;
                    [self registerPBXAccount: [_tfPBXInfoAcc text] password: [_tfPBXInfoPass text] ipAddress: pbxIp port: pbxPort];
                    break;
                }else if (typeProxyConfig == loginPBX){
                    NSLog(@"Login PBX thanh cong");
                    [timeoutTimer invalidate];
                    timeoutTimer = nil;
                    
                    [[NSUserDefaults standardUserDefaults] setObject:[_tfPBXInfoID text] forKey:PBX_ID];
                    [[NSUserDefaults standardUserDefaults] setObject:[_tfPBXInfoAcc text] forKey:PBX_USERNAME];
                    [[NSUserDefaults standardUserDefaults] setObject:[_tfPBXInfoPass text] forKey:PBX_PASSWORD];
                    [[NSUserDefaults standardUserDefaults] setObject:pbxIp forKey:PBX_IP_ADDRESSS];
                    [[NSUserDefaults standardUserDefaults] setObject:pbxPort forKey:PBX_PORT];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1]
                                                              forKey:callnexPBXFlag];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    if (appDelegate._deviceToken != nil) {
                        [self updateCustomerTokenIOSForPBX: _tfPBXInfoID.text andUsername: _tfPBXInfoAcc.text withTokenValue:appDelegate._deviceToken];
                    }else{
                        [self whenLoginPBXSuccessfully];
                    }
                    
                    break;
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
        case LinphoneRegistrationFailed: {
            NSLog(@"LinphoneRegistrationFailed");
            if (curIndex == totalAccount) {
                if (typeReset == eClearPBX || typeReset == eTurnOffPBX) {
                    [self reloginToSipAccount];
                    break;
                }else if (typeReset == eTurnOnPBX){
                    nextStepForTurnOnPBX = NO;
                    [self reloginToSipAccount];
                    break;
                }else if (loginWithQRCode){
                    nextStepForQRCode = NO;
                    [self reloginToSipAccount];
                    break;
                }else{
                    if (typeProxyConfig == clearAll) {
                        NSLog(@"All proxy config has removed");
                        typeProxyConfig = loginSIP;
                        [self reloginToSipAccount];
                        
                        break;
                    }else if (typeProxyConfig == loginSIP){
                        NSLog(@"Fail to login SIP");
                    }else if (typeProxyConfig == loginPBX){
                        NSLog(@"Fail to login PBX");
                        [waitingView stopAnimating];
                        [self.view makeToast:[appDelegate.localization localizedStringForKey:check_pbx_account]
                                    duration:2.0 position:CSToastPositionCenter];
                        
                        NSString *pbxUsername = [_tfPBXInfoAcc text];
                        [self removeProxyConfigWithAccount: pbxUsername];
                        [self setDefaultProxyConfigWithAccount:USERNAME];
                        
                        break;
                    }
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

#pragma mark - API Processs

- (void)getPBXInformationWithHashString: (NSString *)hashString
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@", link_api, DecryptRSA];
    NSURL *URL = [NSURL URLWithString:strURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: URL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
    [request setTimeoutInterval: 60];
    
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:AuthUser forKey:@"AuthUser"];
    [jsonDict setObject:AuthKey forKey:@"AuthKey"];
    [jsonDict setObject:hashString forKey:@"HashString"];
    
    NSString *jsonRequest = [jsonDict JSONString];
    NSData *requestData = [jsonRequest dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [request setValue:[NSString stringWithFormat:@"%d", (int)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if(connection) {
        NSLog(@"Connection Successful");
    }else {
        [waitingView stopAnimating];
        [self.view makeToast:[appDelegate.localization localizedStringForKey:text_error_connection]
                    duration:2.0 position:CSToastPositionCenter];
    }
}

- (void)getInfoForPBXWithServerName: (NSString *)serverName
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@", link_api, getServerInfoFunc];
    NSURL *URL = [NSURL URLWithString:strURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: URL];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval: 60];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
    
    NSString *strBody = [NSString stringWithFormat:@"AuthUser=%@&AuthKey=%@&ServerName=%@", AuthUser, AuthKey, serverName];
    NSData *postData = [strBody dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody: postData];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if(connection) {
        NSLog(@"Connection Successful");
    }else {
        [waitingView stopAnimating];
        [self.view makeToast:[appDelegate.localization localizedStringForKey:text_error_connection]
                    duration:2.0 position:CSToastPositionCenter];
    }
}

- (void)updateCustomerTokenIOSForPBX: (NSString *)pbxService andUsername: (NSString *)pbxUsername withTokenValue: (NSString *)tokenValue
{
    receiveData = nil;
    
    NSString *strURL = [NSString stringWithFormat:@"%@/%@", link_api, ChangeCustomerIOSToken];
    NSURL *URL = [NSURL URLWithString:strURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: URL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
    [request setTimeoutInterval: 60];
    
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:AuthUser forKey:@"AuthUser"];
    [jsonDict setObject:AuthKey forKey:@"AuthKey"];
    [jsonDict setObject:USERNAME forKey:@"UserName"];
    [jsonDict setObject:tokenValue forKey:@"IOSToken"];
    [jsonDict setObject:pbxService forKey:@"PBXID"];
    [jsonDict setObject:pbxUsername forKey:@"PBXExt"];
    
    NSString *jsonRequest = [jsonDict JSONString];
    NSData *requestData = [jsonRequest dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [request setValue:[NSString stringWithFormat:@"%d", (int)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if(connection) {
        NSLog(@"Connection Successful");
    }
}

// This method receives the error report in case of connection is not made to server.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [waitingView stopAnimating];
    NSLog(@"%@", error.userInfo);
    NSLog(@"%@", [error.userInfo objectForKey:@"NSLocalizedDescription"]);
}

// This method is used to receive the data which we get using post method.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data {
    NSString *strURL = [[[connection currentRequest] URL] absoluteString];
    NSString *strLogin = [NSString stringWithFormat:@"%@/%@", link_api, getServerInfoFunc];
    NSString *updateToken = [NSString stringWithFormat:@"%@/%@", link_api, ChangeCustomerIOSToken];
    NSString *strDecryptRSA = [NSString stringWithFormat:@"%@/%@", link_api, DecryptRSA];
    
    if ([strURL isEqualToString: strLogin]) {
        if (serverInfoData == nil) {
            serverInfoData = [[NSMutableData alloc] init];
        }
        [serverInfoData appendData: data];
    }else if ([strURL isEqualToString: updateToken]){
        if (receiveData == nil) {
            receiveData = [[NSMutableData alloc] init];
        }
        [receiveData appendData: data];
    }else if ([strURL isEqualToString: strDecryptRSA]){
        if (qrCodeData == nil) {
            qrCodeData = [[NSMutableData alloc] init];
        }
        [qrCodeData appendData: data];
    }
    else{
        [waitingView stopAnimating];
    }
}

// This method is used to process the data after connection has made successfully.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *strURL = [[[connection currentRequest] URL] absoluteString];
    NSString *strServerInfo = [NSString stringWithFormat:@"%@/%@", link_api, getServerInfoFunc];
    NSString *updateToken = [NSString stringWithFormat:@"%@/%@", link_api, ChangeCustomerIOSToken];
    NSString *strDecryptRSA = [NSString stringWithFormat:@"%@/%@", link_api, DecryptRSA];
    
    if ([strURL isEqualToString: strServerInfo]) {
        NSString *value = [[NSString alloc] initWithData:serverInfoData encoding:NSUTF8StringEncoding];
        
        id object = [value objectFromJSONString];
        if (object != nil && [object isKindOfClass:[NSDictionary class]]) {
            id result = [object objectForKey:@"result"];
            if (result != nil && [result isKindOfClass:[NSString class]]) {
                if ([result isEqualToString:@"success"]) {
                    id data = [object objectForKey:@"data"];
                    if (data != nil && [data isKindOfClass:[NSDictionary class]]) {
                        pbxIp = [data objectForKey:@"ipAddress"];
                        pbxPort = [data objectForKey:@"port"];
                        
                        if (pbxIp != nil && ![pbxIp isEqualToString: @""] && pbxPort != nil && ![pbxPort isEqualToString: @""])
                        {
                            if (loginWithQRCode) {
                                [self clearAllProxyConfigAndAccount];
                            }else{
                                //  Đủ điều kiện login PBX
                                typeProxyConfig = clearAll;
                                [self clearAllProxyConfigAndAccount];
                            }
                        }else{
                            [waitingView stopAnimating];
                            [self.view makeToast:[appDelegate.localization localizedStringForKey:text_error]
                                        duration:2.0 position:CSToastPositionCenter];
                        }
                    }else{
                        [waitingView stopAnimating];
                        [self.view makeToast:[appDelegate.localization localizedStringForKey:check_pbx_account]
                                    duration:2.0 position:CSToastPositionCenter];
                    }
                }else{
                    [waitingView stopAnimating];
                    if (loginWithQRCode) {
                        _tfPBXInfoID.text = @"";
                        _tfPBXInfoAcc.text = @"";
                        _tfPBXInfoPass.text = @"";
                        
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[appDelegate.localization localizedStringForKey:text_notification] message:[appDelegate.localization localizedStringForKey:cannot_find_qrcode] delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:text_close] otherButtonTitles: nil];
                        [alertView show];
                    }else{
                        [self.view makeToast:[appDelegate.localization localizedStringForKey:check_pbx_account]
                                    duration:2.0 position:CSToastPositionCenter];
                    }
                }
            }else{
                [waitingView stopAnimating];
                [self.view makeToast:[appDelegate.localization localizedStringForKey:check_pbx_account]
                            duration:2.0 position:CSToastPositionCenter];
            }
        }else{
            [waitingView stopAnimating];
            [self.view makeToast:[appDelegate.localization localizedStringForKey:text_error]
                        duration:2.0 position:CSToastPositionCenter];
        }
        //  reset data for call api next time
        serverInfoData = nil;
    }else if ([strURL isEqualToString: updateToken]){
        NSString *value = [[NSString alloc] initWithData:receiveData encoding:NSUTF8StringEncoding];
        id object = [value objectFromJSONString];
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSString *result = [object objectForKey:@"result"];
            if (result != nil && [result isEqualToString:@"success"]) {
                
            }else{
                [waitingView stopAnimating];
                [self.view makeToast:[appDelegate.localization localizedStringForKey:login_pbx_success_not_update_token]
                            duration:2.0 position:CSToastPositionCenter];
            }
            
            if (typeReset == eClearPBX) {
                [self whenClearPBXSuccessfully];
            }else if (typeReset == eTurnOffPBX){
                [self whenTurnOfPBXSuccessfully];
            }else if (typeReset == eTurnOnPBX){
                [self whenTurnOnPBXSuccessfully];
            }else if (loginWithQRCode){
                [self whenLoginPBXSuccessfully];
            }else{
                if (typeProxyConfig == loginPBX) {
                    [self whenLoginPBXSuccessfully];
                }else{
                    [self whenLoginPBXSuccessfully];
                }
            }
        }else{
            [waitingView stopAnimating];
            [self.view makeToast:[appDelegate.localization localizedStringForKey:text_update_failed]
                        duration:2.0 position:CSToastPositionCenter];
        }
        //  reset data
        receiveData = nil;
    }else if ([strURL isEqualToString:strDecryptRSA]){
        NSString *value = [[NSString alloc] initWithData:qrCodeData encoding:NSUTF8StringEncoding];
        qrCodeData = nil;
        id object = [value objectFromJSONString];
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSString *result = [object objectForKey:@"result"];
            if (result != nil && [result isEqualToString:@"success"]) {
                NSString *message = [object objectForKey:@"message"];
                
                [self loginPBXFromStringHashCodeResult: message];
            }else{
                [waitingView stopAnimating];
                [self.view makeToast:[appDelegate.localization localizedStringForKey:login_pbx_success_not_update_token] duration:2.0 position:CSToastPositionCenter];
            }
        }else{
            [waitingView stopAnimating];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[appDelegate.localization localizedStringForKey:text_notification] message:[appDelegate.localization localizedStringForKey:cannot_find_qrcode] delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:text_close] otherButtonTitles: nil];
            [alertView show];
        }
    }
    else{
        [waitingView stopAnimating];
        [self.view makeToast:[appDelegate.localization localizedStringForKey:text_failed] duration:2.0 position:CSToastPositionCenter];
    }
}

#pragma mark - QR CODE

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    [reader stopScanning];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self getPBXInformationWithHashString: result];
    }];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self dismissViewControllerAnimated:YES completion:NULL];
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

- (void)getQRCodeContentFromImage: (UIImage *)image {
    NSArray *qrcodeContent = [self detectQRCode: image];
    if (qrcodeContent != nil && qrcodeContent.count > 0) {
        NSString *qrCodeStr = @"";
        for (CIQRCodeFeature* qrFeature in qrcodeContent) {
            qrCodeStr = qrFeature.messageString;
        }
        [self dismissViewControllerAnimated:YES completion:^{
            [self getPBXInformationWithHashString: qrCodeStr];
        }];
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

#pragma mark - WebServices delegate
- (void)failedToCallWebService:(NSString *)link andError:(NSString *)error {
    if ([link isEqualToString:changePasswordFunc]) {
        [waitingView stopAnimating];
        [self.view makeToast:error duration:2.0 position:CSToastPositionCenter];
    }
}

- (void)successfulToCallWebService:(NSString *)link withData:(NSDictionary *)data {
    if ([link isEqualToString:changePasswordFunc]) {
        if ([data isKindOfClass:[NSString class]]) {
            NSLog(@"%@", popupChangePass._tfNewPass);
            [[NSUserDefaults standardUserDefaults] setObject:[popupChangePass._tfNewPass text]
                                                      forKey:key_password];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [waitingView stopAnimating];
            [self.view makeToast:(NSString *)data duration:2.0 position:CSToastPositionCenter];
        }
    }
}

- (void)receivedResponeCode:(NSString *)link withCode:(int)responeCode {
    
}

@end
