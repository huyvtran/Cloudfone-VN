//
//  ListAcceptViewController.m
//  linphone
//
//  Created by user on 10/14/15.
//
//

#import "ListAcceptViewController.h"
#import "AcceptContactViewController.h"
#import "NewContactViewController.h"
#import "AllContactListViewController.h"
#import "FriendRequestedObject.h"
#import "PhoneMainView.h"
#import "FriendForAcceptCell.h"
#import "NSDatabase.h"
#import "NSData+Base64.h"
#import "OTRProtocolManager.h"

@interface ListAcceptViewController (){
    float hCell;
    
    NSMutableDictionary *cachedImages;
    
    BOOL isFound;
    BOOL found;
    
    YBHud *waitingHud;
    NSTimer *waitTimer;
    UIFont *textFont;
    FriendRequestedObject *curRequest;
}

@end

@implementation ListAcceptViewController
@synthesize _viewHeader, _iconBack, _lbHeader, _tbListFriends, _lbNoContacts;
@synthesize _listRequest;

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;
+ (UICompositeViewDescription *)compositeViewDescription {
    if (compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:nil
                                                                 tabBar:nil
                                                               sideMenu:nil
                                                             fullscreen:false
                                                         isLeftFragment:YES
                                                           fragmentWith:nil];
        compositeDescription.darkBackground = true;
    }
    return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
    return self.class.compositeViewDescription;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // MY CODE HERE
    cachedImages = [[NSMutableDictionary alloc] init];
    
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [self showContentWithCurrentLanguage];
    
    // Tắt màn hình cảm biến
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled: NO];
    
    if (_listRequest == nil) {
        _listRequest = [[NSMutableArray alloc] init];
    }
    [_listRequest removeAllObjects];
    [_listRequest addObjectsFromArray:[NSDatabase getListFriendsForAcceptOfAccount:USERNAME]];
    
    if (_listRequest.count > 0) {
        [_tbListFriends reloadData];
        _tbListFriends.hidden = NO;
        _lbNoContacts.hidden = YES;
    }else{
        _tbListFriends.hidden = YES;
        _lbNoContacts.hidden = NO;
    }
    
    //  notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadListFriendRequested)
                                                 name:k11ReloadListFriendsRequested object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptFriendRequestedSuccessfully:)
                                                 name:k11AcceptRequestedSuccessfully object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rejectFriendRequestedSuccessfully:)
                                                 name:k11RejectFriendRequestSuccessfully object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)_iconBackClicked:(id)sender {
    [[PhoneMainView instance] popCurrentView];
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listRequest.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"FriendForAcceptCell";
    FriendForAcceptCell *cell = (FriendForAcceptCell*)[tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"FriendForAcceptCell" owner:self options:nil];
        cell = topLevelObjects[0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, _tbListFriends.frame.size.width, hCell);
    [cell setupUIForCell];
    
    FriendRequestedObject *aRequest = [_listRequest objectAtIndex: indexPath.row];
    
    //  Nếu ko có trong danh bạ thì set display name nếu có
    if ([aRequest._name isEqualToString: aRequest._cloudfoneID]) {
        NSString *strName = [self getDisplayNameForUser: aRequest._cloudfoneID];
        aRequest._name = strName;
        cell._lbName.text = strName;
    }else{
        cell._lbName.text = aRequest._name;
    }
    
    NSString *strRequest = [self getRequestStringOfUser: aRequest._cloudfoneID];
    cell._lbNumber.text = strRequest;
    cell._btnAccept.tag = indexPath.row;
    [cell._btnAccept addTarget:self
                        action:@selector(onBtnAcceptRequested:)
              forControlEvents:UIControlEventTouchUpInside];
    
    cell._btnDecline.tag = indexPath.row;
    [cell._btnDecline addTarget:self
                         action:@selector(onBtnDeclinedRequested:)
               forControlEvents:UIControlEventTouchUpInside];
    
    // set avatar
    NSString *identifier = [NSString stringWithFormat:@"Cell%ld%ld", (long)indexPath.section, (long)indexPath.row];
    if([cachedImages objectForKey:identifier] != nil){
        cell._imgAvatar.image = [cachedImages valueForKey:identifier];
    }else{
        UIImage *img = nil;
        if (![aRequest._avatar isEqualToString: @""]) {
            NSData *imageData = [NSData dataFromBase64String: aRequest._avatar];
            img = [[UIImage alloc] initWithData:imageData];
        }else{
            img = [UIImage imageNamed:@"no_avatar.png"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([tableView indexPathForCell: cell].row == indexPath.row) {
                [cachedImages setValue:img forKey:identifier];
                cell._imgAvatar.image = [cachedImages valueForKey:identifier];
            }
        });//end
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return hCell;
}

#pragma mark - My Funtions

- (void)showContentWithCurrentLanguage {
    
}

//  Reload lại danh sách kết bạn
- (void)reloadListFriendRequested{
    [_listRequest removeAllObjects];
    [_listRequest addObjectsFromArray:[NSDatabase getListFriendsForAcceptOfAccount:USERNAME]];
    if (_listRequest.count > 0) {
        _lbNoContacts.hidden = YES;
        _tbListFriends.hidden = NO;
        [_tbListFriends reloadData];
    }else{
        _lbNoContacts.hidden = NO;
        _tbListFriends.hidden = YES;
    }
}

//  Accept kết bạn thành công
- (void)acceptFriendRequestedSuccessfully: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[NSString class]]) {
        [NSDatabase removeAnUserFromRequestedList: object];
        [_listRequest removeAllObjects];
        [_listRequest addObjectsFromArray:[NSDatabase getListFriendsForAcceptOfAccount:USERNAME]];
        if (_listRequest.count == 0) {
            _tbListFriends.hidden = YES;
            _lbNoContacts.hidden = NO;
        }else{
            _tbListFriends.hidden = NO;
            _lbNoContacts.hidden = YES;
            [_tbListFriends reloadData];
        }
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_successfully]
                    duration:2.0 position:CSToastPositionCenter];
    }else{
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_failed]
                    duration:2.0 position:CSToastPositionCenter];
    }
    [waitingHud dismissAnimated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:k11UpdateBarNotifications
                                                        object:nil];
}

//  Accept kết bạn thành công
- (void)rejectFriendRequestedSuccessfully: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[NSString class]]) {
        [NSDatabase removeAnUserFromRequestedList: object];
        
        [_listRequest removeAllObjects];
        [_listRequest addObjectsFromArray:[NSDatabase getListFriendsForAcceptOfAccount:USERNAME]];
        if (_listRequest.count == 0) {
            _tbListFriends.hidden = YES;
            _lbNoContacts.hidden = NO;
        }else{
            _tbListFriends.hidden = NO;
            _lbNoContacts.hidden = YES;
            [_tbListFriends reloadData];
        }
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_successfully]
                    duration:2.0 position:CSToastPositionCenter];
    }else{
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_failed]
                    duration:2.0 position:CSToastPositionCenter];
    }
    [waitingHud dismissAnimated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:k11UpdateBarNotifications
                                                        object:nil];
}

- (void)setupUIForView
{
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }else{
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
    }
    
    hCell = 70.0;
    
    //  view header
    _viewHeader.frame = CGRectMake(0, 0, SCREEN_WIDTH, [LinphoneAppDelegate sharedInstance]._hHeader);
    _iconBack.frame = CGRectMake(0, ([LinphoneAppDelegate sharedInstance]._hHeader-40.0)/2, 40.0, 40.0);
    [_iconBack setBackgroundImage:[UIImage imageNamed:@"ic_back_act.png"]
                         forState:UIControlStateHighlighted];
    
    _lbHeader.frame = CGRectMake(_iconBack.frame.origin.x+_iconBack.frame.size.width+5, 0, (_viewHeader.frame.size.width-2*_iconBack.frame.size.width-10), [LinphoneAppDelegate sharedInstance]._hHeader);
    _lbHeader.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_list_friend_accept];
    _lbHeader.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    
    //  tableview
    _tbListFriends.frame = CGRectMake(0, _viewHeader.frame.origin.y+_viewHeader.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT-([LinphoneAppDelegate sharedInstance]._hStatus+[LinphoneAppDelegate sharedInstance]._hHeader));
    _tbListFriends.delegate = self;
    _tbListFriends.dataSource = self;
    _tbListFriends.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //  lb contacts
    _lbNoContacts.frame = _tbListFriends.frame;
    _lbNoContacts.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_list_friend_no_contacts];
    _lbNoContacts.textColor = UIColor.grayColor;
    _lbNoContacts.backgroundColor = UIColor.whiteColor;
    _lbNoContacts.textAlignment = NSTextAlignmentCenter;
    _lbNoContacts.font = textFont;
    _lbNoContacts.hidden = YES;
    
    //  add waiting view
    waitingHud = [[YBHud alloc] initWithHudType:DGActivityIndicatorAnimationTypeLineScale andText:@""];
    waitingHud.tintColor = [UIColor whiteColor];
    waitingHud.dimAmount = 0.5;
}

- (void)onBtnAcceptRequested: (UIButton *)sender {
    if (![LinphoneAppDelegate sharedInstance]._internetActive) {
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_please_check_your_connection]
                    duration:2.0 position:CSToastPositionCenter];
    }else {
        curRequest = [_listRequest objectAtIndex: sender.tag];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_sipPhone == %@", curRequest._cloudfoneID];
        NSArray *filter = [[LinphoneAppDelegate sharedInstance].sipContacts filteredArrayUsingPredicate: predicate];
        // Nếu cloudfoneID đã tồn tại thì accept và không thêm mới
        if (filter.count > 0) {
            waitTimer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self
                                                       selector:@selector(acceptRequestTimeOut)
                                                       userInfo:nil repeats:false];
            [waitingHud showInView:self.view animated:YES];
            
            NSString *account = [NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone];
            NSString *user = [NSString stringWithFormat:@"%@@%@", curRequest._cloudfoneID, xmpp_cloudfone];
            [[LinphoneAppDelegate sharedInstance].myBuddy.protocol acceptRequestFromUser:user toMe:account];
        }else{
            UIActionSheet *popupAddContact = [[UIActionSheet alloc] initWithTitle:curRequest._cloudfoneID delegate:self cancelButtonTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_cancel] destructiveButtonTitle:nil otherButtonTitles: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_add_new_contact], [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_add_exists_contact], nil];
            popupAddContact.tag = 100;
            [popupAddContact showInView:self.view];
        }
    }
}
             
- (void)onBtnDeclinedRequested: (UIButton *)sender {
    if (![LinphoneAppDelegate sharedInstance]._internetActive) {
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_please_check_your_connection]
                    duration:2.0 position:CSToastPositionCenter];
    }else{
        if ([LinphoneAppDelegate sharedInstance].xmppStream.isConnected) {
            waitTimer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self
                                                       selector:@selector(acceptRequestTimeOut)
                                                       userInfo:nil repeats:false];
            [waitingHud showInView:self.view animated:YES];
            
            FriendRequestedObject *aRequest = [_listRequest objectAtIndex: sender.tag];
            NSString *user = [NSString stringWithFormat:@"%@@%@", aRequest._cloudfoneID, xmpp_cloudfone];
            NSString *me = [NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone];
            [[LinphoneAppDelegate sharedInstance].myBuddy.protocol rejectRequestFromUser:user toMe: me];
        }else{
            [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_failed]
                        duration:2.0 position:CSToastPositionCenter];
        }
    }
}

//  Het thoi gian accept
- (void)acceptRequestTimeOut {
    [waitTimer invalidate];
    [waitingHud dismissAnimated:YES];
}

//  Lấy lời mời kết bạn của user
- (NSString *)getRequestStringOfUser: (NSString *)user {
    NSMutableDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:callnexFriendsRequest];
    if ( dict == nil) {
        return [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_hi];
    }else{
        NSArray *tmpArr = [dict objectForKey: user];
        if (tmpArr == nil || [tmpArr count] < 2) {
            return [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_hi];
        }else{
            return [tmpArr objectAtIndex: 0];
        }
    }
}

//  Get tên hiển thị cho user khi không có trong danh bạ
- (NSString *)getDisplayNameForUser: (NSString *)cloudfoneID {
    NSMutableDictionary *infoDict = [[NSUserDefaults standardUserDefaults] objectForKey:callnexFriendsRequest];
    if (infoDict != nil) {
        NSArray *infoArr = [infoDict objectForKey: cloudfoneID];
        if (infoArr != nil && [infoArr count] >= 2) {
            if ([infoArr objectAtIndex: 1] != nil && ![[infoArr objectAtIndex: 1] isEqualToString: @""]) {
                return [infoArr objectAtIndex: 1];
            }else{
                return cloudfoneID;
            }
        }else{
            return cloudfoneID;
        }
    }else{
        return cloudfoneID;
    }
}

#pragma mark - Actionsheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 100) {
        switch (buttonIndex) {
            case 0:{
                NewContactViewController *controller = VIEW(NewContactViewController);
                if (controller) {
                    controller.currentSipPhone = curRequest._cloudfoneID;
                    controller.currentName = curRequest._name;
                }
                [[PhoneMainView instance] changeCurrentView:[NewContactViewController compositeViewDescription]
                                                       push:true];
                break;
            }
            case 1:{
                AllContactListViewController *controller = VIEW(AllContactListViewController);
                if (controller != nil) {
                    controller.phoneNumber = curRequest._cloudfoneID;
                }
                [[PhoneMainView instance] changeCurrentView:[AllContactListViewController compositeViewDescription]
                                                       push:true];
                break;
            }
            default:
                break;
        }
    }
}

@end
