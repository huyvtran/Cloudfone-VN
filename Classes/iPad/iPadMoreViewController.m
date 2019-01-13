//
//  iPadMoreViewController.m
//  linphone
//
//  Created by lam quang quan on 1/11/19.
//

#import "iPadMoreViewController.h"
#import "iPadPolicyViewController.h"
#import "iPadIntroduceViewController.h"
#import "iPadAboutViewController.h"
#import "MenuCell.h"
#import "AccountInfoCell.h"

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

- (void)setupUIForView {
    self.view.backgroundColor = IPAD_BG_COLOR;
    //  header view
    [viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(HEIGHT_IPAD_NAV);
    }];
    
    lbHeader.font = [UIFont fontWithName:HelveticaNeue size:24.0];
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
    if (indexPath.row == 3) {
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Go to feedback on App Store", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        
        NSURL *linkCloudfoneOnAppStore = [NSURL URLWithString: link_appstore];
        [[UIApplication sharedApplication] openURL: linkCloudfoneOnAppStore];
        
    }else if (indexPath.row == 4) {
        iPadPolicyViewController *policyVC = [[iPadPolicyViewController alloc] initWithNibName:@"iPadPolicyViewController" bundle:nil];
        
        UITabBarController *tabbarVC = [[LinphoneAppDelegate sharedInstance].homeSplitVC.viewControllers objectAtIndex:0];
        NSArray *viewControllers = [[NSArray alloc] initWithObjects:tabbarVC, policyVC, nil];
        [LinphoneAppDelegate sharedInstance].homeSplitVC.viewControllers = viewControllers;
        
    }else if (indexPath.row == 5) {
        iPadIntroduceViewController *introduceVC = [[iPadIntroduceViewController alloc] initWithNibName:@"iPadIntroduceViewController" bundle:nil];
        
        UITabBarController *tabbarVC = [[LinphoneAppDelegate sharedInstance].homeSplitVC.viewControllers objectAtIndex:0];
        NSArray *viewControllers = [[NSArray alloc] initWithObjects:tabbarVC, introduceVC, nil];
        [LinphoneAppDelegate sharedInstance].homeSplitVC.viewControllers = viewControllers;
        
    }else if (indexPath.row == 7) {
        iPadAboutViewController *aboutVC = [[iPadAboutViewController alloc] initWithNibName:@"iPadAboutViewController" bundle:nil];
        
        UITabBarController *tabbarVC = [[LinphoneAppDelegate sharedInstance].homeSplitVC.viewControllers objectAtIndex:0];
        NSArray *viewControllers = [[NSArray alloc] initWithObjects:tabbarVC, aboutVC, nil];
        [LinphoneAppDelegate sharedInstance].homeSplitVC.viewControllers = viewControllers;
    }
    
//    
//    
//    switch (indexPath.row) {
//        case eSettingsAccount:{
//            [[PhoneMainView instance] changeCurrentView:[AccountSettingsViewController compositeViewDescription] push:true];
//            break;
//        }
//        case eSettings:{
//            [[PhoneMainView instance] changeCurrentView:[KSettingViewController compositeViewDescription] push:true];
//            break;
//        }
//        case ePolicy:{
//            [[PhoneMainView instance] changeCurrentView:[PolicyViewController compositeViewDescription]
//                                                   push:true];
//            break;
//        }
//        case eIntroduce:{
//            [[PhoneMainView instance] changeCurrentView:[IntroduceViewController compositeViewDescription]
//                                                   push:true];
//            break;
//        }
//        case eSendLogs:{
//            [[PhoneMainView instance] changeCurrentView:[SendLogsViewController compositeViewDescription]
//                                                   push:true];
//            break;
//        }
//        case eAbout:{
//            [[PhoneMainView instance] changeCurrentView:[AboutViewController compositeViewDescription]
//                                                   push:true];
//            break;
//        }
//        case eDrawLine:{
//            [[PhoneMainView instance] changeCurrentView:[DrawingViewController compositeViewDescription]
//                                                   push:true];
//            break;
//        }
//        default:
//            break;
//    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.0;
}

@end
