//
//  MoreViewController.m
//  linphone
//
//  Created by user on 1/7/14.
//
//

#import "MoreViewController.h"
#import "MenuCell.h"
#import "AccountSettingsViewController.h"
#import "KSettingViewController.h"
#import "EditProfileViewController.h"
#import "FeedbackViewController.h"
#import "PolicyViewController.h"
#import "IntroduceViewController.h"
#import "PhoneMainView.h"
#import "NSDatabase.h"
#import "TabBarView.h"
#import "StatusBarView.h"
#import "OTRProtocolManager.h"
#import "NSData+Base64.h"
#import "JSONKit.h"
#import "UIView+Toast.h"

@interface MoreViewController () {
    float hInfo;
    float hCell;
    
    NSArray *listTitle;
    NSArray *listIcon;
    
    UIFont *textFont;
    
    int logoutState;
    YBHud *waitingHud;
    WebServices *webService;
}

@end

@implementation MoreViewController
@synthesize _viewHeader, _lbHeader, _viewInfo, _imgAvatar, _lbName, _lbEmail, _tbContent, _btnSignOut;

#pragma mark - UICompositeViewDelegate Functions
static UICompositeViewDescription *compositeDescription = nil;
+ (UICompositeViewDescription *)compositeViewDescription {
    if (compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:nil
                                                                 tabBar:TabBarView.class
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

#pragma mark - my controller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //  my code here
    webService = [[WebServices alloc] init];
    webService.delegate = self;
    
    //  add waiting view
    waitingHud = [[YBHud alloc] initWithHudType:DGActivityIndicatorAnimationTypeLineScale andText:@""];
    waitingHud.tintColor = [UIColor whiteColor];
    waitingHud.dimAmount = 0.5;
    
    [self createDataForMenuView];
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Tắt màn hình cảm biến
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled: NO];
    
    [self showContentWithCurrentLanguage];
    
    // relogin nếu mất kết nối
    if (![LinphoneAppDelegate sharedInstance].xmppStream.isConnected) {
        [AppUtils reconnectToXMPPServer];
    }
    
    [self updateInformationOfUser];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)_btnSignOutPressed:(UIButton *)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_alert_logout_title] message:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_alert_logout_content] delegate:self cancelButtonTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_no] otherButtonTitles:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_yes], nil];
    alertView.delegate = self;
    [alertView show];
}

#pragma mark - my functions

- (void)showContentWithCurrentLanguage {
    _lbHeader.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey: text_more];
    [_btnSignOut setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_logout]
                 forState:UIControlStateNormal];
    [self createDataForMenuView];
    [_tbContent reloadData];
}

- (void)updateInformationOfUser {
    NSDictionary *info = [NSDatabase getProfileInfoOfAccount: USERNAME];
    if (info != nil) {
        NSString *strAvatar = [info objectForKey:@"avatar"];
        if (strAvatar != nil && ![strAvatar isEqualToString: @""]) {
            NSData *myAvatar = [NSData dataFromBase64String: strAvatar];
            _imgAvatar.image = [UIImage imageWithData: myAvatar];
        }else{
            _imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
        }
        
        NSString *Name = [info objectForKey:@"name"];
        if (Name != nil && ![Name isKindOfClass:[NSNull class]] && ![Name isEqualToString: @""]) {
            _lbName.text = Name;
        }else{
            _lbName.text = USERNAME;
        }
        
        NSString *status = [info objectForKey:@"status"];
        if (status != nil && ![status isKindOfClass:[NSNull class]] && ![status isEqualToString: @""]) {
            _lbEmail.text = status;
        }else{
            _lbEmail.text = welcomeToCloudFone;
        }
    }else{
        _imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
        _lbEmail.text = welcomeToCloudFone;
    }
}

- (void)startLogout
{
    //  Cập nhật token XMPP trước
    [LinphoneAppDelegate sharedInstance]._updateTokenSuccess = NO;
    logoutState = eRemoveTokenSIP;
    
    [self updateCustomerTokenIOS: @"logout"];
}

//  Cập nhật vị trí cho view
- (void)setupUIForView
{
    if (SCREEN_WIDTH > 320) {
        hCell = 55.0;
        hInfo = 90.0;
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
        _lbHeader.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:20.0];
    }else{
        hCell = 45.0;
        hInfo = 70.0;
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
        _lbHeader.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }
    
    //  header view
    _viewHeader.frame = CGRectMake(0, 0, SCREEN_WIDTH, [LinphoneAppDelegate sharedInstance]._hHeader);
    _lbHeader.frame = CGRectMake(0, 0, _viewHeader.frame.size.width, _viewHeader.frame.size.height);
    
    //  view info
    _viewInfo.frame = CGRectMake(0, _viewHeader.frame.origin.y+_viewHeader.frame.size.height, SCREEN_WIDTH, hInfo);
    _imgAvatar.frame = CGRectMake(10, 10, hInfo-20, hInfo-20);
    _imgAvatar.clipsToBounds = YES;
    _imgAvatar.layer.cornerRadius = (hInfo-20)/2;
    
    _lbName.frame = CGRectMake(_imgAvatar.frame.origin.x+_imgAvatar.frame.size.width+10, _imgAvatar.frame.origin.y, _viewInfo.frame.size.width-(_imgAvatar.frame.origin.x+_imgAvatar.frame.size.width+10+10), _imgAvatar.frame.size.height/2);
    _lbName.font = textFont;
    
    _lbEmail.frame = CGRectMake(_lbName.frame.origin.x, _lbName.frame.origin.y+_lbName.frame.size.height, _lbName.frame.size.width, _lbName.frame.size.height);
    if (SCREEN_WIDTH > 320) {
        _lbEmail.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
    }else{
        _lbEmail.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:14.0];
    }
    _lbEmail.textColor = UIColor.darkGrayColor;

    //  tableview
    _tbContent.frame = CGRectMake(0, _viewInfo.frame.origin.y+_viewInfo.frame.size.height+7, SCREEN_WIDTH, (listTitle.count+1)*hCell);
    _tbContent.delegate = self;
    _tbContent.dataSource = self;
    _tbContent.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tbContent.scrollEnabled = NO;
    
    //  logout button
    _btnSignOut.frame = CGRectMake(0, SCREEN_HEIGHT-([LinphoneAppDelegate sharedInstance]._hStatus+[LinphoneAppDelegate sharedInstance]._hTabbar+50), SCREEN_WIDTH, 50);
    _btnSignOut.titleLabel.font = textFont;
    _btnSignOut.backgroundColor = UIColor.whiteColor;
    [_btnSignOut setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//  Khoi tao du lieu cho view
- (void)createDataForMenuView {
    listTitle = [[NSArray alloc] initWithObjects:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_menu_edit_profile], [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_acc_setting], [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_menu_settings], [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_menu_feedback], [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_menu_privacy_policy], [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_menu_introduce], nil];
    
    listIcon = [[NSArray alloc] initWithObjects: @"ic_edit_profile.png",  @"ic_account_settings.png", @"ic_menu_settings.png", @"ic_feedback.png", @"ic_privacy_policy.png", @"ic_introduce.png", nil];
}

#pragma mark - uitableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return listTitle.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"MenuCell";
    MenuCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MenuCell" owner:self options:nil];
        cell = topLevelObjects[0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, _tbContent.frame.size.width, hCell);
    [cell setupUIForCell];
    
    if (indexPath.row == listTitle.count) {
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        //  NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        cell._lbTitle.text = [NSString stringWithFormat:@"%@: %@", [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_version], version];
        cell._lbTitle.frame = CGRectMake(0, 0, _tbContent.frame.size.width, hCell);
        cell._lbTitle.textAlignment = NSTextAlignmentCenter;
        cell._iconImage.hidden = YES;
    }else{
        cell._iconImage.image = [UIImage imageNamed:[listIcon objectAtIndex: indexPath.row]];
        cell._lbTitle.text = [listTitle objectAtIndex:indexPath.row];
        cell._iconImage.hidden = NO;
        cell._lbTitle.textAlignment = NSTextAlignmentLeft;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case eEditProfile:{
            [[PhoneMainView instance] changeCurrentView:[EditProfileViewController compositeViewDescription] push:true];
            break;
        }
        case eSettings:{
            [[PhoneMainView instance] changeCurrentView:[KSettingViewController compositeViewDescription] push:true];
            break;
        }
        case eSettingsAccount:{
            [[PhoneMainView instance] changeCurrentView:[AccountSettingsViewController compositeViewDescription] push:true];
            break;
        }
        case eFeedback:{
            NSURL *linkCloudfoneOnAppStore = [NSURL URLWithString:@"https://itunes.apple.com/vn/app/cloudfone/id1275900068?mt=8"];
            [[UIApplication sharedApplication] openURL: linkCloudfoneOnAppStore];
            
            //  [[PhoneMainView instance] changeCurrentView:[FeedbackViewController compositeViewDescription] push:true];
            break;
        }
        case ePolicy:{
            [[PhoneMainView instance] changeCurrentView:[PolicyViewController compositeViewDescription]
                                                   push:true];
            break;
        }
        case eIntroduce:{
            [[PhoneMainView instance] changeCurrentView:[IntroduceViewController compositeViewDescription]
                                                   push:true];
            break;
        }
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return hCell;
}

#pragma mark - API

- (void)updateCustomerTokenIOS: (NSString *)token
{
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:AuthUser forKey:@"AuthUser"];
    [jsonDict setObject:AuthKey forKey:@"AuthKey"];
    [jsonDict setObject:USERNAME forKey:@"UserName"];
    [jsonDict setObject:token forKey:@"IOSToken"];
    
    [webService callWebServiceWithLink:ChangeCustomerIOSToken withParams:jsonDict];
}

- (void)updateCustomerTokenIOSForPBX: (NSString *)pbxService andUsername: (NSString *)pbxUsername withToken: (NSString *)token
{
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:AuthUser forKey:@"AuthUser"];
    [jsonDict setObject:AuthKey forKey:@"AuthKey"];
    [jsonDict setObject:USERNAME forKey:@"UserName"];
    [jsonDict setObject:token forKey:@"IOSToken"];
    [jsonDict setObject:pbxService forKey:@"PBXID"];
    [jsonDict setObject:pbxUsername forKey:@"PBXExt"];
    
    [webService callWebServiceWithLink:ChangeCustomerIOSToken withParams:jsonDict];
}

- (void)startResetValueWhenLogout
{
    //  logout SIP
    LinphoneProxyConfig* proxyCfg = linphone_core_get_default_proxy_config([LinphoneManager getLc]);
    linphone_proxy_config_edit(proxyCfg);
    linphone_proxy_config_enable_publish(proxyCfg, TRUE);
    linphone_proxy_config_set_publish_expires(proxyCfg, 0);
    linphone_proxy_config_enable_register(proxyCfg,FALSE);
    
    linphone_proxy_config_done(proxyCfg);
    
    [[LinphoneManager instance] lpConfigSetBool:true forKey:@"enable_first_login_view_preference"];
    
    [self removeSipProxyConfig: USERNAME];
    
    // insert last logout cho user
    BOOL result = [NSDatabase insertLastLogoutForUser:USERNAME passWord:PASSWORD andRelogin:1];
    if (!result) {
        NSLog(@"Can not save state logout for user....");
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key_login];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key_password];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"loginSuccess"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[[[OTRProtocolManager sharedInstance] buddyList] allBuddies] removeAllObjects];
    [[LinphoneAppDelegate sharedInstance].myBuddy.protocol disconnect];
    
    [waitingHud dismissAnimated: YES];
    [[PhoneMainView instance] changeCurrentView:[AssistantView compositeViewDescription]];
}

- (void)removeSipProxyConfig: (NSString *)username
{
    const MSList *proxies = linphone_core_get_proxy_config_list(LC);
    while (proxies) {
        if (proxies->data != NULL) {
            const char *proxyUsername = linphone_address_get_username(linphone_proxy_config_get_identity_address(proxies->data));
            if (strcmp(username.UTF8String, proxyUsername) == 0) {
                const LinphoneAuthInfo *ai = linphone_proxy_config_find_auth_info(proxies->data);
                linphone_core_remove_proxy_config(LC, proxies->data);
                if (ai) {
                    linphone_core_remove_auth_info(LC, ai);
                }
                NSLog(@"%s", proxyUsername);
                break;
            }
        }
        proxies = proxies->next;
    }
}

#pragma mark - Alertview Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [waitingHud showInView:self.view animated:YES];
        
        [self startLogout];
    }
}

#pragma mark - WebServices delegate
- (void)failedToCallWebService:(NSString *)link andError:(NSString *)error {
    if ([link isEqualToString:ChangeCustomerIOSToken]) {
        [waitingHud dismissAnimated: YES];
        
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Failed! Please try a later!"] duration:3.0 position:CSToastPositionCenter];
    }
}

- (void)successfulToCallWebService:(NSString *)link withData:(NSDictionary *)data {
    if ([link isEqualToString:ChangeCustomerIOSToken]) {
        if (logoutState == eRemoveTokenSIP)
        {
            NSLog(@"----Remove token SIP thành công");
            logoutState = eRemoveTokenPBX;
            
            NSString *pbxID = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_ID];
            NSString *pbxUsername = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_USERNAME];
            if (pbxID != nil && ![pbxID isEqualToString:@""] && pbxUsername != nil && ![pbxUsername isEqualToString:@""]) {
                [self updateCustomerTokenIOSForPBX:pbxID andUsername:pbxUsername withToken: @"tokenPBX"];
            }else{
                [self startResetValueWhenLogout];
            }
        }else if (logoutState == eRemoveTokenPBX){
            [self startResetValueWhenLogout];
        }
    }
}

- (void)receivedResponeCode:(NSString *)link withCode:(int)responeCode {
    
}

@end
