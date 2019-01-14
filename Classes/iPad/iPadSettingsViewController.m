//
//  iPadSettingsViewController.m
//  linphone
//
//  Created by lam quang quan on 1/14/19.
//

#import "iPadSettingsViewController.h"
#import "iPadLanguageViewController.h"
#import "SettingCell.h"
#import "CustomSwitchButton.h"

@interface iPadSettingsViewController (){
    NSMutableArray *listTitle;
    CustomSwitchButton *swVoiceControl;
    float hCell;
}

@end

@implementation iPadSettingsViewController
@synthesize tbSettings;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated {
    // Tắt màn hình cảm biến
    
    [WriteLogsUtils writeForGoToScreen:@"iPadSettingsViewController"];
    
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled: NO];
    
    [self showContentWithCurrentLanguage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showContentWithCurrentLanguage {
    self.title = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Settings"];
    
    listTitle = [[NSMutableArray alloc] init];
    [listTitle addObject:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Change language"]];
    
    if (([LinphoneAppDelegate sharedInstance].enableForTest)) {
        [listTitle addObject:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Call settings"]];
    }
    
    if (([LinphoneAppDelegate sharedInstance].supportVoice)) {
        [listTitle addObject:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Voice control"]];
    }
    
    [tbSettings reloadData];
}

- (void)setupUIForView
{
    hCell = 68.0;
    
    self.view.backgroundColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                                 blue:(230/255.0) alpha:1.0];
    //  tableview
    tbSettings.backgroundColor = UIColor.clearColor;
    [tbSettings mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    tbSettings.delegate = self;
    tbSettings.dataSource = self;
    tbSettings.scrollEnabled = NO;
    tbSettings.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - TableView Delegate & DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return listTitle.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"SettingCell";
    SettingCell *cell = (SettingCell *)[tableView dequeueReusableCellWithIdentifier: identifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SettingCell" owner:self options:nil];
        cell = topLevelObjects[0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *content = [listTitle objectAtIndex: indexPath.row];
    cell._lbTitle.text = content;
    if ([content isEqualToString:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Voice control"]]) {
        cell._iconArrow.hidden = YES;
        
        BOOL state = NO;
        NSNumber *hasVoiceControl = [[NSUserDefaults standardUserDefaults] objectForKey:VOICE_CONTROL];
        if (hasVoiceControl != nil) {
            state = [hasVoiceControl intValue];
        }
        swVoiceControl = [[CustomSwitchButton alloc] initWithState:state frame:CGRectMake(SCREEN_WIDTH-70.0-20, (hCell-31.0)/2, 70.0, 31.0)];
        
        //  swAccount.delegate = self;
        [cell addSubview: swVoiceControl];
    }else{
        cell._iconArrow.hidden = NO;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:{
            iPadLanguageViewController *languageVC = [[iPadLanguageViewController alloc] init];
            [self.navigationController pushViewController:languageVC animated:YES];
            break;
        }
        case 1:{
            /*
            if ([LinphoneAppDelegate sharedInstance].enableForTest) {
                [[PhoneMainView instance] changeCurrentView:[SettingsView compositeViewDescription]
                                                       push:true];
            }   */
            break;
        }
        case 2:{
            
            break;
        }
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return hCell;
}

@end
