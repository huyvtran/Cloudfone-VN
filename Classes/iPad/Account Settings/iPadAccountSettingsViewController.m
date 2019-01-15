//
//  iPadAccountSettingsViewController.m
//  linphone
//
//  Created by lam quang quan on 1/14/19.
//

#import "iPadAccountSettingsViewController.h"
#import "iPadPBXSettingViewController.h"
#import "iPadChangePasswordViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "NewSettingCell.h"

@interface iPadAccountSettingsViewController (){
    AccountState stateAccount;
}

@end

@implementation iPadAccountSettingsViewController
@synthesize tbSettings;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [WriteLogsUtils writeForGoToScreen:@"iPadAccountSettingsViewController"];
    
    self.title = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Account settings"];
    stateAccount = [SipUtils getStateOfDefaultProxyConfig];
    [tbSettings reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUIForView {
    self.view.backgroundColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                                 blue:(230/255.0) alpha:1.0];
    
    tbSettings.backgroundColor = UIColor.clearColor;
    [tbSettings mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
    tbSettings.delegate = self;
    tbSettings.dataSource = self;
    tbSettings.separatorStyle = UITableViewCellSeparatorStyleNone;
    tbSettings.scrollEnabled = NO;
}

#pragma mark - UITableview Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([SipUtils getStateOfDefaultProxyConfig] == eAccountNone) {
        return 1;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"NewSettingCell";
    NewSettingCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"NewSettingCell" owner:self options:nil];
        cell = topLevelObjects[0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (indexPath.row) {
        case 0:{
            cell.lbTitle.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"PBX account"];
            
            switch (stateAccount) {
                case eAccountNone:
                    cell.lbDescription.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"No account"];
                    break;
                case eAccountOff:{
                    cell.lbDescription.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Disabled"];
                    break;
                }
                case eAccountOn:{
                    cell.lbDescription.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Enabled"];
                    break;
                }
            }
            
            break;
        }
        case 1:{
            cell.lbTitle.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Change password"];
            [cell.lbTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(cell).offset(10);
                make.right.equalTo(cell.imgArrow).offset(-10);
                make.top.bottom.equalTo(cell);
            }];
            cell.lbDescription.text = @"";
            
            UILabel *lbSepa = [[UILabel alloc] init];
            lbSepa.backgroundColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0)
                                                      blue:(235/255.0) alpha:1.0];
            [cell addSubview: lbSepa];
            [lbSepa mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.equalTo(cell);
                make.height.mas_equalTo(1.0);
            }];
            
            
            break;
        }
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] indexPath row = %d", __FUNCTION__, (int)indexPath.row] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    if (indexPath.row == 0) {
        UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationItem.backBarButtonItem = newBackButton;
        
        iPadPBXSettingViewController *pbxSettingsVC = [[iPadPBXSettingViewController alloc] init];
        [self.navigationController pushViewController:pbxSettingsVC animated:YES];

    }else if (indexPath.row == 1){
        if (stateAccount == eAccountNone) {
            [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"No account"] duration:3.0 position:CSToastPositionCenter];
        }else{
            UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
            self.navigationItem.backBarButtonItem = newBackButton;
            
            iPadChangePasswordViewController *changePassVC = [[iPadChangePasswordViewController alloc] init];
            [self.navigationController pushViewController:changePassVC animated:YES];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0;
}

@end
