//
//  iPadMoreViewController.m
//  linphone
//
//  Created by lam quang quan on 1/11/19.
//

#import "iPadMoreViewController.h"
#import "iPadAccountSettingsViewController.h"
#import "iPadSettingsViewController.h"
#import "iPadPolicyViewController.h"
#import "iPadIntroduceViewController.h"
#import "iPadSendLogsViewController.h"
#import "iPadAboutViewController.h"
#import "MenuCell.h"
#import "AccountInfoCell.h"

typedef enum ipadMoreType{
    iPadMoreAccount = 1,
    iPadMoreSettings,
    iPadMoreFeedback,
    iPadMorePrivacy,
    iPadMoreIntrodution,
    iPadMoreSendLogs,
    iPadMoreAbout,
}ipadMoreType;

@interface iPadMoreViewController (){
    NSMutableArray *listTitle;
    NSMutableArray *listIcon;
}

@end

@implementation iPadMoreViewController
@synthesize btnAvatar, tbMenu;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupUIForView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [self showContentWithCurrentLanguage];
    [self selectDefaultForView];
    
    [self registerNotifications];
    
    [self showAccountInformation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showContentWithCurrentLanguage {
    self.title = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"More"];
    [self createDataForMenuView];
    [tbMenu reloadData];
}

//  Khoi tao du lieu cho view
- (void)createDataForMenuView {
    listTitle = [[NSMutableArray alloc] initWithObjects: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Account settings"], [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Settings"], [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Feedback"], [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Privacy Policy"], [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Introduction"], [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Send logs"], [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"About"], nil];
    
    listIcon = [[NSMutableArray alloc] initWithObjects: @"ic_setup.png", @"ic_setting.png", @"ic_support.png", @"ic_term.png", @"ic_introduce.png", @"ic_send_logs.png", @"ic_info.png", nil];
}

- (void)selectDefaultForView {
    [tbMenu selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    iPadAccountSettingsViewController *settingsAccVC = [[iPadAccountSettingsViewController alloc] initWithNibName:@"iPadAccountSettingsViewController" bundle:nil];
    UINavigationController *navigationVC = [AppUtils createNavigationWithController: settingsAccVC];
    [AppUtils showDetailViewWithController: navigationVC];
}

- (void)setupUIForView {
    self.view.backgroundColor = IPAD_BG_COLOR;
    
    //  view info
    btnAvatar.backgroundColor = UIColor.clearColor;
    btnAvatar.imageEdgeInsets = UIEdgeInsetsMake(15.0, 15.0, 15.0, 15.0);
    [btnAvatar setImage:[UIImage imageNamed:@"man_user.png"] forState:UIControlStateNormal];
    [btnAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(SPLIT_MASTER_WIDTH);
    }];
    
    
    //  tbMenu
    tbMenu.backgroundColor = UIColor.clearColor;
    tbMenu.delegate = self;
    tbMenu.dataSource = self;
    tbMenu.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tbMenu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnAvatar.mas_centerY).offset(25.0);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-self.tabBarController.tabBar.frame.size.height);
    }];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMyAvatarAfterDownloaded:)
                                                 name:updateAvatarAfterDownloadSuccessful object:nil];
}

- (void)showAccountInformation {
    if ([SipUtils getStateOfDefaultProxyConfig] != eAccountNone) {
        NSString *accountID = [SipUtils getAccountIdOfDefaultProxyConfig];
        
        NSString *pbxKeyName = [NSString stringWithFormat:@"%@_%@", @"pbxName", accountID];
        NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey: pbxKeyName];
        NSLog(@"%@", name);
        
        NSString *pbxKeyAvatar = [NSString stringWithFormat:@"%@_%@", @"pbxAvatar", accountID];
        NSString *avatar = [[NSUserDefaults standardUserDefaults] objectForKey: pbxKeyAvatar];
        if (![AppUtils isNullOrEmpty: avatar]){
            [btnAvatar setImage:[UIImage imageWithData: [NSData dataFromBase64String: avatar]]
                       forState:UIControlStateNormal];
        }else{
            [btnAvatar setImage:[UIImage imageNamed:@"man_user"] forState:UIControlStateNormal];
            [self downloadMyAvatar: accountID];
        }
    }
}

- (void)updateMyAvatarAfterDownloaded: (NSNotification *)notif {
    NSString *avatar = [notif object];
    if (avatar != nil && [avatar isKindOfClass:[NSString class]]) {
        [btnAvatar setImage:[UIImage imageWithData: [NSData dataFromBase64String: avatar]]
                   forState:UIControlStateNormal];
    }
}

#pragma mark - Webservice
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
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [btnAvatar setImage:[UIImage imageWithData: data] forState:UIControlStateNormal];
            });
        }
    });
}

#pragma mark - uitableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return listTitle.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        static NSString *identifier = @"AccountInfoCell";
        AccountInfoCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"AccountInfoCell" owner:self options:nil];
            cell = topLevelObjects[0];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor colorWithRed:(50/255.0) green:(50/255.0)
                                                blue:(50/255.0) alpha:0.3];
        
        return cell;
    }else{
        static NSString *identifier = @"MenuCell";
        MenuCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MenuCell" owner:self options:nil];
            cell = topLevelObjects[0];
        }
        //  cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell._iconImage.image = [UIImage imageNamed:[listIcon objectAtIndex: indexPath.row-1]];
        cell._lbTitle.text = [listTitle objectAtIndex:indexPath.row-1];
        cell._iconImage.hidden = NO;
        cell._lbTitle.textAlignment = NSTextAlignmentLeft;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == iPadMoreAccount) {
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Go to account settings view", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        
        iPadAccountSettingsViewController *settingsAccVC = [[iPadAccountSettingsViewController alloc] initWithNibName:@"iPadAccountSettingsViewController" bundle:nil];
        UINavigationController *navigationVC = [AppUtils createNavigationWithController: settingsAccVC];
        [AppUtils showDetailViewWithController: navigationVC];
        
    }else if (indexPath.row == iPadMoreSettings) {
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Go to settings view", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        
        iPadSettingsViewController *settingsVC = [[iPadSettingsViewController alloc] initWithNibName:@"iPadSettingsViewController" bundle:nil];
        UINavigationController *navigationVC = [AppUtils createNavigationWithController: settingsVC];
        [AppUtils showDetailViewWithController: navigationVC];
        
    }else if (indexPath.row == iPadMoreFeedback) {
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Go to feedback on App Store", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        
        NSURL *linkCloudfoneOnAppStore = [NSURL URLWithString: link_appstore];
        [[UIApplication sharedApplication] openURL: linkCloudfoneOnAppStore];
        
    }else if (indexPath.row == iPadMorePrivacy) {
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Go to privacy view", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        
        iPadPolicyViewController *policyVC = [[iPadPolicyViewController alloc] initWithNibName:@"iPadPolicyViewController" bundle:nil];
        UINavigationController *navigationVC = [AppUtils createNavigationWithController: policyVC];
        [AppUtils showDetailViewWithController: navigationVC];
        
    }else if (indexPath.row == iPadMoreIntrodution) {
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Go to introduction view", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        
        iPadIntroduceViewController *introduceVC = [[iPadIntroduceViewController alloc] initWithNibName:@"iPadIntroduceViewController" bundle:nil];
        UINavigationController *navigationVC = [AppUtils createNavigationWithController: introduceVC];
        [AppUtils showDetailViewWithController: navigationVC];
        
    }else if (indexPath.row == iPadMoreSendLogs) {
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Go to send logs view", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        
        iPadSendLogsViewController *sendLogsVC = [[iPadSendLogsViewController alloc] initWithNibName:@"iPadSendLogsViewController" bundle:nil];
        UINavigationController *navigationVC = [AppUtils createNavigationWithController: sendLogsVC];
        [AppUtils showDetailViewWithController: navigationVC];
        
    }else if (indexPath.row == iPadMoreAbout) {
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Go to about view", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        
        iPadAboutViewController *aboutVC = [[iPadAboutViewController alloc] initWithNibName:@"iPadAboutViewController" bundle:nil];
        UINavigationController *navigationVC = [AppUtils createNavigationWithController: aboutVC];
        [AppUtils showDetailViewWithController: navigationVC];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.0;
}



@end
