//
//  KSettingViewController.m
//  linphone
//
//  Created by mac book on 10/4/15.
//
//

#import "KSettingViewController.h"
#import "NotificationSettingsViewController.h"
#import "LanguageViewController.h"
#import "PhoneMainView.h"
#import "NSDatabase.h"
#import "SettingCell.h"
#import "OTRProtocolManager.h"

@interface KSettingViewController (){
    NSMutableArray *listTitle;
    NSArray *listIcon;
    AlertPopupView *logoutPopupView;
    float hCell;
    UIFont *textFont;
}

@end

@implementation KSettingViewController
@synthesize _iconBack, _lbHeader, _tbSettings, _viewHeader;

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

    // MY CODE HERE
    listIcon = [[NSArray alloc] initWithObjects: @"ic_notif_settings.png", @"ic_language.png", @"ic_menu_settings.png", @"ic_account_settings.png", nil];
    
    [self setupUIForView];
    
    //  Logout popup
    [logoutPopupView setDelegate: self];
}

- (void)viewWillAppear:(BOOL)animated {
    // Tắt màn hình cảm biến
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled: NO];
    
    [self showContentWithCurrentLanguage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)_iconBackClicked:(id)sender {
    [[PhoneMainView instance] popCurrentView];
}

#pragma mark - My functions

- (void)showContentWithCurrentLanguage {
    _lbHeader.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_settings];
    
    listTitle = [[NSMutableArray alloc] initWithObjects: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_notif_setting], [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_lang_setting], [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_app_settings], [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_outbot_proxy], nil];
    [_tbSettings reloadData];
}

- (void)setupUIForView
{
    if (SCREEN_WIDTH > 320) {
        hCell = 55.0;
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
        _lbHeader.font = [UIFont fontWithName:HelveticaNeue size:20.0];
    }else{
        hCell = 45.0;
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
        _lbHeader.font = [UIFont fontWithName:HelveticaNeue size:18.0];
    }
    
    //  header view
    _viewHeader.frame = CGRectMake(0, 0, SCREEN_WIDTH, [LinphoneAppDelegate sharedInstance]._hHeader);
    _iconBack.frame = CGRectMake(0, 0, [LinphoneAppDelegate sharedInstance]._hHeader, [LinphoneAppDelegate sharedInstance]._hHeader);
    [_iconBack setBackgroundImage:[UIImage imageNamed:@"ic_back_act.png"]
                         forState:UIControlStateHighlighted];
    
    _lbHeader.frame = CGRectMake(_iconBack.frame.origin.x+_iconBack.frame.size.width+5, 0, _viewHeader.frame.size.width-(2*_iconBack.frame.origin.x+2*_iconBack.frame.size.width+10), [LinphoneAppDelegate sharedInstance]._hHeader);
    
    //  tableview
    _tbSettings.frame = CGRectMake(0, _viewHeader.frame.origin.y+_viewHeader.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT-([LinphoneAppDelegate sharedInstance]._hStatus+[LinphoneAppDelegate sharedInstance]._hHeader));
    _tbSettings.delegate = self;
    _tbSettings.dataSource = self;
    _tbSettings.scrollEnabled = NO;
    _tbSettings.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, _tbSettings.frame.size.width, hCell);
    
    [cell setupUIForView];
    cell._lbTitle.font = textFont;
    
    cell._lbTitle.text = [listTitle objectAtIndex: indexPath.row];
    cell._iconImage.image = [UIImage imageNamed:[listIcon objectAtIndex: indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:{
            [[PhoneMainView instance] changeCurrentView:[NotificationSettingsViewController compositeViewDescription]
                                                   push:true];
            break;
        }
        case 1:{
            [[PhoneMainView instance] changeCurrentView:[LanguageViewController compositeViewDescription]
                                                   push:true];
            break;
        }
        case 2:{
            [[PhoneMainView instance] changeCurrentView:[SettingsView compositeViewDescription]
                                                   push:true];
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
