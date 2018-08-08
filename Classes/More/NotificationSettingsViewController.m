//
//  NotificationSettingsViewController.m
//  linphone
//
//  Created by Apple on 4/26/17.
//
//

#import "NotificationSettingsViewController.h"
#import "PhoneMainView.h"
#import "SettingSoundCell.h"
#import "LinphoneManager.h"

@interface NotificationSettingsViewController (){
    UIFont *textFont;
    UIFont *descFont;
    
    float hItem;
    float hCell;
    float hSection;
}

@end

@implementation NotificationSettingsViewController
@synthesize _viewHeader, _iconBack, _lbHeader, _tbSettings;

#pragma mark - UICompositeViewDelegate Functions
static UICompositeViewDescription *compositeDescription = nil;
+ (UICompositeViewDescription *)compositeViewDescription {
    if (compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:nil
                                                                 tabBar:nil
                                                               sideMenu:nil
                                                             fullscreen:NO
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

- (void)viewDidLoad {
    [super viewDidLoad];
    //  my code here
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    _lbHeader.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_notif_setting];
    [_tbSettings reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)_iconBackClicked:(UIButton *)sender {
    [[PhoneMainView instance] popCurrentView];
}

#pragma mark - my functions

- (void)setupUIForView
{
    float hSwitch;
    if (SCREEN_WIDTH > 320) {
        hSwitch = 32.0;
        hItem = 35.0;
        [_lbHeader setFont:[UIFont fontWithName:MYRIADPRO_REGULAR size:20.0]];
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
        descFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
    }else{
        hSwitch = 27.0;
        hItem = 25.0;
        [_lbHeader setFont:[UIFont fontWithName:MYRIADPRO_REGULAR size:18.0]];
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
        descFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:14.0];
    }
    hCell = 50.0;
    hSection = 40.0;
    
    //  header view
    _viewHeader.frame = CGRectMake(0, 0, SCREEN_WIDTH, [LinphoneAppDelegate sharedInstance]._hHeader);
    _iconBack.frame = CGRectMake(0, 0, [LinphoneAppDelegate sharedInstance]._hHeader, [LinphoneAppDelegate sharedInstance]._hHeader);
    [_iconBack setBackgroundImage:[UIImage imageNamed:@"ic_back_act.png"]
                         forState:UIControlStateHighlighted];
    _lbHeader.frame = CGRectMake(_iconBack.frame.origin.x+_iconBack.frame.size.width+5, 0, _viewHeader.frame.size.width-2*(_iconBack.frame.origin.x+_iconBack.frame.size.width+5), [LinphoneAppDelegate sharedInstance]._hHeader);
    
    //  table settings
    _tbSettings.frame = CGRectMake(0, _viewHeader.frame.origin.y+_viewHeader.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT-[LinphoneAppDelegate sharedInstance]._hStatus-[LinphoneAppDelegate sharedInstance]._hHeader);
    _tbSettings.backgroundColor = [UIColor colorWithRed:(240/255.0) green:(240/255.0)
                                                   blue:(240/255.0) alpha:1.0];
    _tbSettings.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tbSettings.delegate = self;
    _tbSettings.dataSource = self;
}

- (void)switchValueChanged: (UISwitch *)switchButton {
    switch (switchButton.tag) {
        case 1:{
            NSString *soundMsgKey = [NSString stringWithFormat:@"%@_%@", key_sound_message, USERNAME];
            NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey: soundMsgKey];
            
            if (value == nil || [value isEqualToString: text_yes]) {
                [[NSUserDefaults standardUserDefaults] setObject:text_no forKey: soundMsgKey];
            }else{
                [[NSUserDefaults standardUserDefaults] setObject:text_yes forKey: soundMsgKey];
            }
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
        }
        case 2:{
            NSString *vibrateMsgKey = [NSString stringWithFormat:@"%@_%@", key_vibrate_message, USERNAME];
            NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey: vibrateMsgKey];
            
            if (value == nil || [value isEqualToString: text_yes]) {
                [[NSUserDefaults standardUserDefaults] setObject:text_no forKey: vibrateMsgKey];
            }else{
                [[NSUserDefaults standardUserDefaults] setObject:text_yes forKey: vibrateMsgKey];
            }
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
        }
        case 3:{
            NSString *soundCallKey = [NSString stringWithFormat:@"%@_%@", key_sound_call, USERNAME];
            NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:soundCallKey];
            if (value == nil || [value isEqualToString: text_yes]) {
                [[NSUserDefaults standardUserDefaults] setObject:text_no forKey:soundCallKey];
                
                const char *lRing = [[LinphoneManager bundleFile:@"silence.mp3"] cStringUsingEncoding:[NSString defaultCStringEncoding]];
                linphone_core_set_ring([LinphoneManager getLc], lRing);
                [LinphoneManager.instance lpConfigSetString:[LinphoneManager bundleFile:@"silence.mp3"] forKey:@"local_ring" inSection:@"sound"];
            }else{
                [[NSUserDefaults standardUserDefaults] setObject:text_yes forKey:soundCallKey];
                
                const char *lRing =
                [[LinphoneManager bundleFile:@"callnex_ring.wav"] cStringUsingEncoding:[NSString defaultCStringEncoding]];
                linphone_core_set_ring([LinphoneManager getLc], lRing);
                [LinphoneManager.instance lpConfigSetString:[LinphoneManager bundleFile:@"callnex_ring.wav"] forKey:@"local_ring" inSection:@"sound"];
            }
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //  update setting for callkit sound
            [[LinphoneAppDelegate sharedInstance].del config];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - Tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"SettingSoundCell";
    SettingSoundCell *cell = (SettingSoundCell *)[tableView dequeueReusableCellWithIdentifier: identifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SettingSoundCell" owner:self options:nil];
        cell = topLevelObjects[0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, _tbSettings.frame.size.width, hCell);
    [cell setupUIForCell];
    
    switch (indexPath.section) {
        case 0:{
            switch (indexPath.row) {
                case 0:{
                    cell.lbTitle.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_rung_tin_nhan];
                    //  Cập nhật gía trị vibrate swich button
                    NSString *vibrateUserKey = [NSString stringWithFormat:@"%@_%@", key_vibrate_message, USERNAME];
                    NSString *virateValue = [[NSUserDefaults standardUserDefaults] objectForKey: vibrateUserKey];
                    if (virateValue == nil || [virateValue isEqualToString: text_yes]) {
                        cell.swAction.on = YES;
                    }else{
                        cell.swAction.on = NO;
                    }
                    cell.swAction.tag = 2;
                    break;
                }
                default:
                    break;
            }
            
            break;
        }
        case 1:{
            cell.lbTitle.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_thong_bao_am_thanh];
            
            //  Cập nhật gía trị sound call
            NSString *soundCallKey = [NSString stringWithFormat:@"%@_%@", key_sound_call, USERNAME];
            NSString *soundCallValue = [[NSUserDefaults standardUserDefaults] objectForKey: soundCallKey];
            if (soundCallValue == nil || [soundCallValue isEqualToString: text_yes]) {
                cell.swAction.on = YES;
            }else{
                cell.swAction.on = NO;
            }
            cell.swAction.tag = 3;
            break;
        }
        default:
            break;
    }
    [cell.swAction addTarget:self
                      action:@selector(switchValueChanged:)
            forControlEvents:UIControlEventValueChanged];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return hCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return hSection;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *viewSection = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tbSettings.frame.size.width, hSection)];
    viewSection.backgroundColor = [UIColor whiteColor];
    
    UILabel *lbSection = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, viewSection.frame.size.width-20, hSection)];
    lbSection.textColor = [UIColor colorWithRed:(24/255.0) green:(185/255.0)
                                           blue:(153/255.0) alpha:1.0];
    if (section == 0) {
        lbSection.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_message_settings];
    }else{
        lbSection.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_call_settings];
    }
    [viewSection addSubview: lbSection];
    return viewSection;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 10;
    }
    return 0;
}

@end
