//
//  MoreViewController.m
//  linphone
//
//  Created by user on 1/7/14.
//
//

#import "MoreViewController.h"
#import "MenuCell.h"
#import "EditProfileViewController.h"
#import "AccountSettingsViewController.h"
#import "KSettingViewController.h"
#import "PolicyViewController.h"
#import "IntroduceViewController.h"
#import "AboutViewController.h"
#import "TabBarView.h"
#import "StatusBarView.h"
#import "NSData+Base64.h"
#import "JSONKit.h"

@interface MoreViewController () {
    float hInfo;
    
    NSArray *listTitle;
    NSArray *listIcon;
    
    UIFont *textFont;
    
    int logoutState;
}

@end

@implementation MoreViewController
@synthesize _viewHeader, bgHeader, _imgAvatar, _lbName, lbPBXAccount, icEdit, _tbContent;

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
    
    [self createDataForMenuView];
    [self autoLayoutForMainView];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Tắt màn hình cảm biến
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled: NO];
    
    [self showContentWithCurrentLanguage];
    
    [self updateInformationOfUser];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)_btnSignOutPressed:(UIButton *)sender {
    
}

#pragma mark - my functions

- (void)showContentWithCurrentLanguage {
    [self createDataForMenuView];
    [_tbContent reloadData];
}

- (void)updateInformationOfUser
{
    if ([SipUtils getStateOfDefaultProxyConfig] == eAccountNone) {
        _lbName.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"No account"];
        lbPBXAccount.text = @"-.-";
        icEdit.hidden = YES;
    }else{
        NSString *accountID = [SipUtils getAccountIdOfDefaultProxyConfig];
        lbPBXAccount.text = accountID;
        
        NSString *pbxKeyName = [NSString stringWithFormat:@"%@_%@", @"pbxName", accountID];
        NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey: pbxKeyName];
        if (name != nil){
            _lbName.text = name;
        }else{
            _lbName.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Not set"];
        }
        
        NSString *pbxKeyAvatar = [NSString stringWithFormat:@"%@_%@", @"pbxAvatar", accountID];
        NSString *avatar = [[NSUserDefaults standardUserDefaults] objectForKey: pbxKeyAvatar];
        if (avatar != nil && ![avatar isEqualToString:@""]){
            _imgAvatar.image = [UIImage imageWithData: [NSData dataFromBase64String: avatar]];
        }else{
            _imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
            [self downloadMyAvatar: accountID];
        }
        icEdit.hidden = NO;
    }
}

//  Cập nhật vị trí cho view
- (void)autoLayoutForMainView {
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }else{
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
    }
    
    self.view.backgroundColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                                 blue:(230/255.0) alpha:1.0];
    hInfo = [LinphoneAppDelegate sharedInstance]._hRegistrationState + 50;
    
    //  Header view
    [_viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(hInfo);
    }];
    
    [bgHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(_viewHeader);
    }];
    
    [_imgAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewHeader).offset(10);
        make.centerY.equalTo(_viewHeader.mas_centerY).offset([LinphoneAppDelegate sharedInstance]._hStatus/2);
        make.width.height.mas_equalTo(55.0);
    }];
    _imgAvatar.clipsToBounds = YES;
    _imgAvatar.layer.cornerRadius = 55.0/2;
    
    //  Edit icon
    [icEdit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_imgAvatar);
        make.right.equalTo(_viewHeader).offset(-10);
        make.width.height.mas_equalTo(35.0);
    }];
    
    _lbName.textColor = UIColor.whiteColor;
    [_lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_imgAvatar);
        make.left.equalTo(_imgAvatar.mas_right).offset(5);
        make.right.equalTo(icEdit.mas_left).offset(-5);
        make.bottom.equalTo(_imgAvatar.mas_centerY);
    }];
    
    lbPBXAccount.textColor = UIColor.whiteColor;
    [lbPBXAccount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lbName.mas_bottom);
        make.left.right.equalTo(_lbName);
        make.bottom.equalTo(_imgAvatar.mas_bottom);
    }];
    
    
    _tbContent.backgroundColor = UIColor.clearColor;
    [_tbContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader.mas_bottom);
        make.left.bottom.right.equalTo(self.view);
    }];
    _tbContent.delegate = self;
    _tbContent.dataSource = self;
    _tbContent.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tbContent.scrollEnabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//  Khoi tao du lieu cho view
- (void)createDataForMenuView {
    listTitle = [[NSArray alloc] initWithObjects: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Account settings"], [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Settings"], [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Feedback"], [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Privacy Policy"], [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Introduction"], [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Send logs"], [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"About"], nil];
    
    listIcon = [[NSArray alloc] initWithObjects: @"ic_setup.png", @"ic_setting.png", @"ic_support.png", @"ic_term.png", @"ic_introduce.png", @"ic_introduce.png", @"ic_info.png", nil];
}

#pragma mark - uitableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return listTitle.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"MenuCell";
    MenuCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MenuCell" owner:self options:nil];
        cell = topLevelObjects[0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell._iconImage.image = [UIImage imageNamed:[listIcon objectAtIndex: indexPath.row]];
    cell._lbTitle.text = [listTitle objectAtIndex:indexPath.row];
    cell._iconImage.hidden = NO;
    cell._lbTitle.textAlignment = NSTextAlignmentLeft;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case eSettingsAccount:{
            [[PhoneMainView instance] changeCurrentView:[AccountSettingsViewController compositeViewDescription] push:true];
            break;
        }
        case eSettings:{
            [[PhoneMainView instance] changeCurrentView:[KSettingViewController compositeViewDescription] push:true];
            break;
        }
        case eFeedback:{
            NSURL *linkCloudfoneOnAppStore = [NSURL URLWithString:@"https://itunes.apple.com/vn/app/cloudfone/id1275900068?mt=8"];
            [[UIApplication sharedApplication] openURL: linkCloudfoneOnAppStore];
            
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
        case eSendLogs:{
            [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"We have not supported this feature yet. Please try later!"] duration:2.0 position:CSToastPositionCenter];
            break;
        }
        case eAbout:{
            [[PhoneMainView instance] changeCurrentView:[AboutViewController compositeViewDescription]
                                                   push:true];
            break;
        }
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (IBAction)icEditClicked:(UIButton *)sender {
    [[PhoneMainView instance] changeCurrentView:[EditProfileViewController compositeViewDescription]
                                           push:YES];
}

- (void)downloadMyAvatar: (NSString *)myaccount
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *pbxServer = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_ID];
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
                _imgAvatar.image = [UIImage imageWithData: data];
            });
        }
    });
}

@end
