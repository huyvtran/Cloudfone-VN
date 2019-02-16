//
//  iPadChangePasswordViewController.m
//  linphone
//
//  Created by admin on 1/15/19.
//

#import "iPadChangePasswordViewController.h"

@interface iPadChangePasswordViewController (){
    WebServices *webService;
    
    NSString *serverPBX;
    NSString *ipPBX;
    NSString *passwordPBX;
    NSString *portPBX;
    
    LinphoneProxyConfig *enableProxyConfig;
}

@end

@implementation iPadChangePasswordViewController
@synthesize viewContent, lbPassword, tfPassword, lbNewPassword, tfNewPassword, lbConfirmPassword, tfConfirmPassword, lbPasswordDesc, btnSave, btnCancel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    webService = [[WebServices alloc] init];
    webService.delegate = self;
    
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [WriteLogsUtils writeForGoToScreen: @"iPadChangePasswordViewController"];
    
    serverPBX = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_SERVER];
    
    [[LinphoneAppDelegate sharedInstance] showWaiting: NO];
    
    [self showContentForView];
    tfPassword.text = @"";
    tfNewPassword.text = @"";
    tfConfirmPassword.text = @"";
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(registrationUpdateEvent:)
                                               name:kLinphoneRegistrationUpdate object:nil];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)viewDidLayoutSubviews {
    float height = btnCancel.frame.origin.y + btnCancel.frame.size.height + 30.0;
    [viewContent mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnCancelPressed:(UIButton *)sender {
    [self.view endEditing: YES];
    tfPassword.text = @"";
    tfNewPassword.text = @"";
    tfConfirmPassword.text = @"";
}

- (IBAction)btnSavePressed:(UIButton *)sender {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    [self.view endEditing: YES];
    if ([tfPassword.text isEqualToString:@""]) {
        tfPassword.layer.borderColor = [UIColor colorWithRed:(248/255.0) green:(83/255.0)
                                                         blue:(86/255.0) alpha:1.0].CGColor;
        [self performSelector:@selector(updateBorderColor:) withObject:tfPassword afterDelay:1.5];
    }
    else if ([tfNewPassword.text isEqualToString:@""]){
        [self performSelector:@selector(updateBorderColor:) withObject:tfNewPassword afterDelay:1.5];
    }
    else if ([tfConfirmPassword.text isEqualToString:@""]){
        [self performSelector:@selector(updateBorderColor:) withObject:tfConfirmPassword afterDelay:1.5];
    }
    else if (![tfConfirmPassword.text isEqualToString:tfNewPassword.text]){
        [[LinphoneAppDelegate sharedInstance].window makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Confirm password not match"] duration:2.0 position:CSToastPositionCenter];
    }
    else if (![tfPassword.text isEqualToString:PASSWORD]){
        [[LinphoneAppDelegate sharedInstance].window makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Current password not correct"] duration:2.0 position:CSToastPositionCenter];
    }else {
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] linphone_core_clear_proxy_config", __FUNCTION__]
                             toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        
        //  clear proxy, after will update password and register again
        [[LinphoneAppDelegate sharedInstance] showWaiting: YES];
        
        linphone_core_clear_proxy_config(LC);
    }
}

- (void)updateBorderColor: (UITextField *)textfield {
    textfield.layer.borderColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                                   blue:(230/255.0) alpha:1.0].CGColor;
}

- (void)showContentForView {
    
    self.title = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Change password"];
    lbPassword.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Current password"];
    lbNewPassword.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"New password"];
    lbConfirmPassword.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Confirm password"];
    lbPasswordDesc.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Password are at least 6 characters long"];
    
    tfPassword.placeholder = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Input password"];
    tfNewPassword.placeholder = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Input password"];
    tfConfirmPassword.placeholder = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Input password"];
    
    [btnCancel setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Reset"] forState:UIControlStateNormal];
    [btnSave setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Save"] forState:UIControlStateNormal];
}

- (void)setupUIForView {
    float marginX = 20.0;
    self.view.backgroundColor = IPAD_BG_COLOR;
    
    //  content view
    viewContent.backgroundColor = UIColor.whiteColor;
    [viewContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(0);
    }];
    
    //  Current password
    lbPassword.textColor = [UIColor colorWithRed:(80/255.0) green:(80/255.0)
                                             blue:(80/255.0) alpha:1.0];
    lbPassword.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightThin];
    [lbPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewContent).offset(20);
        make.left.equalTo(viewContent).offset(marginX);
        make.right.equalTo(viewContent).offset(-marginX);
        make.height.mas_equalTo(IPAD_HEIGHT_TF);
    }];
    
    tfPassword.borderStyle = UITextBorderStyleNone;
    tfPassword.layer.cornerRadius = 3.0;
    tfPassword.layer.borderWidth = 1.0;
    tfPassword.layer.borderColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                                     blue:(230/255.0) alpha:1.0].CGColor;
    tfPassword.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightThin];
    [tfPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbPassword.mas_bottom).offset(10.0);
        make.left.right.equalTo(lbPassword);
        make.height.mas_equalTo(IPAD_HEIGHT_TF);
    }];
    tfPassword.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8.0, 40.0)];
    tfPassword.leftViewMode = UITextFieldViewModeAlways;
    
    //  New password
    lbNewPassword.textColor = lbPassword.textColor;
    lbNewPassword.font = lbPassword.font;
    [lbNewPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tfPassword.mas_bottom).offset(20.0);
        make.left.right.equalTo(lbPassword);
        make.height.equalTo(lbPassword.mas_height);
    }];
    
    tfNewPassword.borderStyle = UITextBorderStyleNone;
    tfNewPassword.layer.cornerRadius = 3.0;
    tfNewPassword.layer.borderWidth = 1.0;
    tfNewPassword.layer.borderColor = tfPassword.layer.borderColor;
    tfNewPassword.font = tfPassword.font;
    [tfNewPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbNewPassword.mas_bottom).offset(10.0);
        make.left.right.equalTo(lbNewPassword);
        make.height.equalTo(tfPassword.mas_height);
    }];
    tfNewPassword.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8.0, 40.0)];
    tfNewPassword.leftViewMode = UITextFieldViewModeAlways;
    
    //  Confirm password
    lbConfirmPassword.textColor = lbPassword.textColor;
    lbConfirmPassword.font = lbPassword.font;
    [lbConfirmPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tfNewPassword.mas_bottom).offset(20.0);
        make.left.right.equalTo(tfNewPassword);
        make.height.equalTo(lbPassword.mas_height);
    }];
    
    tfConfirmPassword.borderStyle = UITextBorderStyleNone;
    tfConfirmPassword.layer.cornerRadius = 3.0;
    tfConfirmPassword.layer.borderWidth = 1.0;
    tfConfirmPassword.layer.borderColor = tfPassword.layer.borderColor;
    tfConfirmPassword.font = tfPassword.font;
    [tfConfirmPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbConfirmPassword.mas_bottom).offset(10.0);
        make.left.right.equalTo(lbConfirmPassword);
        make.height.equalTo(tfNewPassword.mas_height);
    }];
    tfConfirmPassword.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8.0, 40.0)];
    tfConfirmPassword.leftViewMode = UITextFieldViewModeAlways;
    
    lbPasswordDesc.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightThin];
    lbPasswordDesc.textColor = UIColor.orangeColor;
    [lbPasswordDesc mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tfConfirmPassword.mas_bottom).offset(5.0);
        make.left.right.equalTo(tfConfirmPassword);
        make.height.equalTo(lbConfirmPassword.mas_height);
    }];
    
    //  footer button
    [btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbPasswordDesc.mas_bottom).offset(35);
        make.left.equalTo(lbPasswordDesc);
        make.right.equalTo(viewContent.mas_centerX).offset(-20);
        make.height.mas_equalTo(45.0);
    }];
    btnCancel.clipsToBounds = YES;
    btnCancel.layer.cornerRadius = 45.0/2;
    [btnCancel setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnCancel.titleLabel.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightRegular];
    btnCancel.backgroundColor = [UIColor colorWithRed:(248/255.0) green:(83/255.0)
                                                  blue:(86/255.0) alpha:1.0];
    
    [btnSave mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnCancel);
        make.left.equalTo(viewContent.mas_centerX).offset(20);
        make.right.equalTo(tfConfirmPassword.mas_right);
        make.height.mas_equalTo(btnCancel.mas_height);
    }];
    btnSave.clipsToBounds = YES;
    btnSave.layer.cornerRadius = 45.0/2;
    [btnSave setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnSave.titleLabel.font = btnCancel.titleLabel.font;
    btnSave.backgroundColor = IPAD_HEADER_BG_COLOR;
}

- (void)updatePasswordSuccesful
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    [[LinphoneAppDelegate sharedInstance] showWaiting: NO];
    
    [[LinphoneAppDelegate sharedInstance].window makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Your password has been updated successful"] duration:2.0 position:CSToastPositionCenter];
    
    tfPassword.text = @"";
    tfNewPassword.text = @"";
    tfConfirmPassword.text = @"";
}

#pragma mark - Registration event

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
            [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] registration state is LinphoneRegistrationOk", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
            
            [SipUtils enableProxyConfig:proxy withValue:YES withRefresh:YES];
            
            [self updatePasswordSuccesful];
            
            break;
        }
        case LinphoneRegistrationNone:{
            [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] registration state is LinphoneRegistrationNone", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
            
            break;
        }
        case LinphoneRegistrationCleared: {
            [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] registration state is LinphoneRegistrationCleared", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
            
            if (![AppUtils isNullOrEmpty: serverPBX]) {
                [self changePasswordForUser:USERNAME server:serverPBX password:tfNewPassword.text];
            }
            break;
        }
        case LinphoneRegistrationFailed: {
            [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] registration state is LinphoneRegistrationFailed", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
            
            break;
        }
        case LinphoneRegistrationProgress: {
            [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] registration state is LinphoneRegistrationProgress", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
            
            break;
        }
        default:
            break;
    }
}

#pragma mark - Webservice Delegate
- (void)changePasswordForUser: (NSString *)UserExt server: (NSString *)server password: (NSString *)newPassword
{
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:AuthUser forKey:@"AuthUser"];
    [jsonDict setObject:AuthKey forKey:@"AuthKey"];
    [jsonDict setObject:UserExt forKey:@"UserExt"];
    [jsonDict setObject:server forKey:@"ServerName"];
    [jsonDict setObject:PASSWORD forKey:@"PasswordOld"];
    [jsonDict setObject:newPassword forKey:@"PasswordNew"];
    
    [webService callWebServiceWithLink:ChangeExtPass withParams:jsonDict];
    
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] jSonDict = %@", __FUNCTION__, @[jsonDict]] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
}

- (void)failedToCallWebService:(NSString *)link andError:(NSString *)error {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] link: %@.\n Response data: %@", __FUNCTION__, link, error] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    [[LinphoneAppDelegate sharedInstance] showWaiting: NO];
    
    [[LinphoneAppDelegate sharedInstance].window makeToast:error duration:2.0 position:CSToastPositionCenter];
}

- (void)successfulToCallWebService:(NSString *)link withData:(NSDictionary *)data {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] link: %@.\n Response data: %@", __FUNCTION__, link, @[data]] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    if ([link isEqualToString:ChangeExtPass]) {
        [[NSUserDefaults standardUserDefaults] setObject:tfNewPassword.text forKey:key_password];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self registerPBXAfterChangePasswordSuccess];
        
    }else if ([link isEqualToString:getServerInfoFunc]) {
        [self startLoginPBXWithInfo: data];
    }
}

- (void)receivedResponeCode:(NSString *)link withCode:(int)responeCode {
    NSLog(@"%d", responeCode);
}

- (void)registerPBXAfterChangePasswordSuccess
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    if (![AppUtils isNullOrEmpty: serverPBX]) {
        [self getInfoForPBXWithServerName: serverPBX];
    }else{
        [self updatePasswordSuccesful];
    }
}

- (void)startLoginPBXWithInfo: (NSDictionary *)info
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] info = %@", __FUNCTION__, @[info]] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    NSString *pbxIp = [info objectForKey:@"ipAddress"];
    NSString *pbxPort = [info objectForKey:@"port"];
    NSString *serverName = [info objectForKey:@"serverName"];
    
    if (pbxIp != nil && ![pbxIp isEqualToString: @""] && pbxPort != nil && ![pbxPort isEqualToString: @""] && serverName != nil)
    {
        passwordPBX = tfNewPassword.text;
        ipPBX = pbxIp;
        portPBX = pbxPort;
        
        [self registerPBXAccount:USERNAME password:passwordPBX ipAddress:ipPBX port:portPBX];
    }else{
        [[LinphoneAppDelegate sharedInstance].window makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Please check your information again!"] duration:2.0 position:CSToastPositionCenter];
    }
}

- (void)registerPBXAccount: (NSString *)pbxAccount password: (NSString *)password ipAddress: (NSString *)address port: (NSString *)portID
{
    NSArray *data = @[address, pbxAccount, password, portID];
    [self performSelector:@selector(startRegisterPBX:) withObject:data afterDelay:1.0];
}

- (void)startRegisterPBX: (NSArray *)data {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] data = %@", __FUNCTION__, @[data]] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    if (data.count == 4) {
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

- (void)getInfoForPBXWithServerName: (NSString *)serverName
{
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:AuthUser forKey:@"AuthUser"];
    [jsonDict setObject:AuthKey forKey:@"AuthKey"];
    [jsonDict setObject:serverName forKey:@"ServerName"];
    
    [webService callWebServiceWithLink:getServerInfoFunc withParams:jsonDict];
    
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] jSonDict = %@", __FUNCTION__, @[jsonDict]] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
}




@end
