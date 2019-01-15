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
@synthesize viewHeader, lbHeader, btnAvatar, tbMenu;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupUIForView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [self showContentWithCurrentLanguage];
    [self selectDefaultForView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showContentWithCurrentLanguage {
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
    [self showDetailViewWithController: navigationVC];
}

- (void)setupUIForView {
    self.view.backgroundColor = IPAD_BG_COLOR;
    //  header view
    [viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(HEIGHT_IPAD_NAV);
    }];
    
    lbHeader.font = [UIFont fontWithName:HelveticaNeue size: IPAD_HEADER_FONT_SIZE];
    [lbHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(viewHeader);
        make.top.equalTo(viewHeader).offset(STATUS_BAR_HEIGHT);
    }];
    
    //  view info
    [btnAvatar setImage:[UIImage imageNamed:@"man_user.png"] forState:UIControlStateNormal];
    [btnAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader.mas_bottom);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(self.view.frame.size.width);
    }];
    
    
    //  tbMenu
    tbMenu.backgroundColor = UIColor.clearColor;
    tbMenu.delegate = self;
    tbMenu.dataSource = self;
    tbMenu.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tbMenu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnAvatar.mas_centerY).offset(-25.0);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-self.tabBarController.tabBar.frame.size.height);
    }];
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
        [self showDetailViewWithController: navigationVC];
        
    }else if (indexPath.row == iPadMoreSettings) {
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Go to settings view", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        
        iPadSettingsViewController *settingsVC = [[iPadSettingsViewController alloc] initWithNibName:@"iPadSettingsViewController" bundle:nil];
        UINavigationController *navigationVC = [AppUtils createNavigationWithController: settingsVC];
        [self showDetailViewWithController: navigationVC];
        
    }else if (indexPath.row == iPadMoreFeedback) {
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Go to feedback on App Store", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        
        NSURL *linkCloudfoneOnAppStore = [NSURL URLWithString: link_appstore];
        [[UIApplication sharedApplication] openURL: linkCloudfoneOnAppStore];
        
    }else if (indexPath.row == iPadMorePrivacy) {
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Go to privacy view", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        
        iPadPolicyViewController *policyVC = [[iPadPolicyViewController alloc] initWithNibName:@"iPadPolicyViewController" bundle:nil];
        UINavigationController *navigationVC = [AppUtils createNavigationWithController: policyVC];
        [self showDetailViewWithController: navigationVC];
        
    }else if (indexPath.row == iPadMoreIntrodution) {
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Go to introduction view", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        
        iPadIntroduceViewController *introduceVC = [[iPadIntroduceViewController alloc] initWithNibName:@"iPadIntroduceViewController" bundle:nil];
        UINavigationController *navigationVC = [AppUtils createNavigationWithController: introduceVC];
        [self showDetailViewWithController: navigationVC];
        
    }else if (indexPath.row == iPadMoreSendLogs) {
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Go to send logs view", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        
        iPadSendLogsViewController *sendLogsVC = [[iPadSendLogsViewController alloc] initWithNibName:@"iPadSendLogsViewController" bundle:nil];
        UINavigationController *navigationVC = [AppUtils createNavigationWithController: sendLogsVC];
        [self showDetailViewWithController: navigationVC];
        
    }else if (indexPath.row == iPadMoreAbout) {
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Go to about view", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        
        iPadAboutViewController *aboutVC = [[iPadAboutViewController alloc] initWithNibName:@"iPadAboutViewController" bundle:nil];
        UINavigationController *navigationVC = [AppUtils createNavigationWithController: aboutVC];
        [self showDetailViewWithController: navigationVC];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.0;
}

- (void)showDetailViewWithController: (UIViewController *)detailVC
{
    UITabBarController *tabbarVC = [[LinphoneAppDelegate sharedInstance].homeSplitVC.viewControllers objectAtIndex:0];
    NSArray *viewControllers = [[NSArray alloc] initWithObjects:tabbarVC, detailVC, nil];
    [LinphoneAppDelegate sharedInstance].homeSplitVC.viewControllers = viewControllers;
}

@end
