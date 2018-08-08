//
//  RightChatViewController.m
//  linphone
//
//  Created by Ei Captain on 4/11/16.
//
//

#import "RightChatViewController.h"
#import "NewContactFromChatViewController.h"
#import "ChooseContactsViewController.h"
#import "ChatProfileCell.h"
#import "ChatSettingCell.h"
#import "AddParticientsViewController.h"
#import "BackgroundViewController.h"

#import "ExportConversationPopupView.h"
#import "DeleteConversationPopupView.h"
#import "PopupFriendRequest.h"
#import "KContactDetailViewController.h"
#import "PhoneMainView.h"
#import "MainChatViewController.h"
#import "NSDatabase.h"
#import "NSData+Base64.h"
#import "SettingItem.h"
#import "JSONKit.h"
#import "OTRProtocolManager.h"
#import <CommonCrypto/CommonDigest.h>

#define NUM_OF_SECTION 4

@interface RightChatViewController (){
    LinphoneAppDelegate *appDelegate;
    
    float hCellAvatar;
    float hCell;
    
    AlertPopupView *deleteMsgPopup;
    
    NSMutableArray *listOccupants;
    int numUserOfRoom;
    NSData *imgRoomAvatar;
    
    NSArray *userInfo;
    BOOL isBlocked;
    NSString *remoteParty;
    
    //  Kiểm tra contact
    int idContact;
    DeleteConversationPopupView *popupDelete;
    PopupFriendRequest *requestPopupView;
    
    BOOL transfer_popup;
    BOOL readyPress;    //  Biến ko cho block hay unblock contact liên tục
    UIFont *textFont;
    
    ChatImagesView *viewChatImages;
    NSMutableArray *listMembers;
    
    int newMsgNotif;
    int hasBurnMsg;
    int isBlockContact;
}
@end

@implementation NSString (MD5)

- (NSString *)MD5String {
    const char *cstr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, (int)strlen(cstr), result);
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end

@implementation RightChatViewController
@synthesize _listTableView;
@synthesize _menuData, _settingListGroup;

- (void)viewDidLoad {
    [super viewDidLoad];
    // MY CODE HERE
    appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.view.backgroundColor = [UIColor colorWithRed:(120/255.0) green:(120/255.0)
                                                 blue:(120/255.0) alpha:1.0];
    
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
        hCellAvatar = 80.0;
        hCell = 55.0;
    }else{
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
        hCellAvatar = 60.0;
        hCell = 45.0;
    }
    
    _menuData = [[NSMutableArray alloc] init];
    _settingListGroup = [[NSMutableArray alloc] init];
    
    // Tableview
    [_listTableView setDelegate: self];
    [_listTableView setDataSource: self];
    [_listTableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
    [_listTableView setFrame: CGRectMake(60, 0, SCREEN_WIDTH-60, _listTableView.frame.size.height)];
    [_listTableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
    
    [deleteMsgPopup setDelegate: self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //  notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buddyListUpdate)
                                                 name:kOTRBuddyListUpdate object:nil];
    
    //  Bỏ sự kiện tap vào màn hình chat khi menu đang hiển thị
    [[NSNotificationCenter defaultCenter] postNotificationName:k11DisableTapGestureChat
                                                        object:[NSNumber numberWithInt:1]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptRequestedSuccessfully:)
                                                 name:k11AcceptRequestedSuccessfully object:nil];
    
    readyPress = true;
    remoteParty = [[NSString alloc] initWithString:[AppUtils getSipFoneIDFromString:appDelegate.friendBuddy.accountName]];
    
    //  Kiểm tra setting cho remoteParty hiện tại
    [self checkSettingForCurrentRemoteParty: remoteParty];
    
    //  save list member
    if (listMembers == nil) {
        listMembers = [[NSMutableArray alloc] init];
    }
    [listMembers removeAllObjects];
    [listMembers addObject: remoteParty];
    [listMembers addObject: USERNAME];
    
    //  Lấy contact id của số callnex đang chat
    idContact = idContactUnknown;
    idContact = [NSDatabase getContactIDWithCloudFoneID: remoteParty];
    
    // Kiểm tra contact có bị block hay không?
    isBlocked = [NSDatabase checkContactInBlackList: idContact andCloudfoneID:remoteParty];
    
    //  Lấy tên và avatar của user đang chat
    userInfo = [NSDatabase getNameAndAvatarOfContactWithPhoneNumber: remoteParty];
    
    [_listTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //  Bỏ sự kiện tap vào màn hình chat khi menu đang hiển thị
    [[NSNotificationCenter defaultCenter] postNotificationName:k11DisableTapGestureChat
                                                        object:[NSNumber numberWithInt:0]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return NUM_OF_SECTION;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:{
            return 1;
            break;
        }
        case 1:{
            return 5;
            break;
        }
        case 2:{
            return 1;
        }
        case 3:{
            return 3;
            break;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:{
            NSString *identifier = @"ChatProfileCell";
            ChatProfileCell *pCell = (ChatProfileCell *)[tableView dequeueReusableCellWithIdentifier: identifier];
            if (pCell == nil) {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ChatProfileCell" owner:self options:nil];
                pCell = topLevelObjects[0];
            }
            pCell.selectionStyle = UITableViewCellSelectionStyleNone;
            pCell.frame = CGRectMake(pCell.frame.origin.x, pCell.frame.origin.y, _listTableView.frame.size.width, hCellAvatar);
            [pCell setupUIForCell];
            
            // Set avatar cho user
            NSString *avatar = [userInfo objectAtIndex: 1];
            if ([avatar isEqualToString: @""] || [avatar isEqualToString: @"(null)"] || [avatar isEqualToString: @"null"] || [avatar isEqualToString: @"<null>"]) {
                pCell._imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
            }else{
                pCell._imgAvatar.image = [UIImage imageWithData:[NSData dataFromBase64String: [userInfo objectAtIndex: 1]]];
            }
            pCell._imgClock.hidden = YES;
            
            if ([[userInfo objectAtIndex: 0] isEqualToString: @""]) {
                pCell._lbName.text = remoteParty;
            }else{
                pCell._lbName.text = [userInfo objectAtIndex: 0];
            }
            
            NSString *status = [self getStatusStringOfUserOnList: remoteParty];
            if ([status isEqualToString: @""]) {
                pCell._lbStatus.text = [appDelegate.localization localizedStringForKey: text_offline];
            }else{
                pCell._lbStatus.text = status;
            }
            return pCell;
        }
        case 1:{
            NSString *identifier = @"ChatSettingCell";
            ChatSettingCell *cell = (ChatSettingCell *)[tableView dequeueReusableCellWithIdentifier: identifier];
            if (cell == nil) {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ChatSettingCell" owner:self options:nil];
                cell = topLevelObjects[0];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, _listTableView.frame.size.width, hCell);
            [cell setupUIForCell];
            
            switch (indexPath.row) {
                case 0:
                    cell._lbTitle.text = [appDelegate.localization localizedStringForKey:@"Chat images"];
                    cell._imgArrow.hidden = NO;
                    cell._swAction.hidden = YES;
                    break;
                case 1:{
                    cell._lbTitle.text = [appDelegate.localization localizedStringForKey:@"Change background"];
                    cell._imgArrow.hidden = NO;
                    cell._swAction.hidden = YES;
                    break;
                }
                case 2:{
                    cell._lbTitle.text = [appDelegate.localization localizedStringForKey:@"Receive notifications"];
                    cell._imgArrow.hidden = YES;
                    cell._swAction.hidden = NO;
                    if (newMsgNotif == 1) {
                        cell._swAction.on = YES;
                    }else{
                        cell._swAction.on = NO;
                    }
                    [cell._swAction addTarget:self
                                       action:@selector(settingForReceiveNewMsgNotif)
                             forControlEvents:UIControlEventValueChanged];
                    break;
                }
                case 3:{
                    cell._lbTitle.text = [appDelegate.localization localizedStringForKey:@"Save conversation"];
                    cell._imgArrow.hidden = YES;
                    cell._swAction.hidden = YES;
                    break;
                }
                case 4:{
                    cell._lbTitle.text = [appDelegate.localization localizedStringForKey:@"Burn messages after reading"];
                    cell._imgArrow.hidden = YES;
                    cell._swAction.hidden = NO;
                    if (hasBurnMsg == 1) {
                        cell._swAction.on = YES;
                    }else{
                        cell._swAction.on = NO;
                    }
                    [cell._swAction addTarget:self
                                       action:@selector(switchBurnMessageChanged)
                             forControlEvents:UIControlEventValueChanged];
                    break;
                }
                default:
                    break;
            }
            return cell;
        }
        case 2:{
            NSString *identifier = @"ChatMembersCell";
            ChatMembersCell *cell = (ChatMembersCell *)[tableView dequeueReusableCellWithIdentifier: identifier];
            if (cell == nil) {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ChatMembersCell" owner:self options:nil];
                cell = topLevelObjects[0];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
            
            cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, _listTableView.frame.size.width, 130);
            [cell setupUIForCell];
            cell._lbMember.text = [appDelegate.localization localizedStringForKey:@"Members"];
            [cell setListMembers: listMembers];
            
            return cell;
        }
        case 3:{
            NSString *identifier = @"ChatSettingCell";
            ChatSettingCell *cell = (ChatSettingCell *)[tableView dequeueReusableCellWithIdentifier: identifier];
            if (cell == nil) {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ChatSettingCell" owner:self options:nil];
                cell = topLevelObjects[0];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, _listTableView.frame.size.width, hCell);
            [cell setupUIForCell];
            
            switch (indexPath.row) {
                case 0:{
                    cell._lbTitle.text = [appDelegate.localization localizedStringForKey:@"Block this contact"];
                    cell._imgArrow.hidden = YES;
                    cell._swAction.hidden = NO;
                    if (isBlockContact == 1) {
                        cell._swAction.on = YES;
                    }else{
                        cell._swAction.on = NO;
                    }
                    [cell._swAction addTarget:self
                                       action:@selector(switchBlockContactChanged)
                             forControlEvents:UIControlEventValueChanged];
                    break;
                }
                case 1:{
                    BOOL isFriend = [self checkCloudfoneIDInListFriend: remoteParty];
                    if (isFriend) {
                        cell._lbTitle.text = [appDelegate.localization localizedStringForKey:text_cancel_friend];
                    }else{
                        if ([NSDatabase checkRequestFriendExistsOnList: remoteParty]) {
                            cell._lbTitle.text = [appDelegate.localization localizedStringForKey:text_accept_friend];
                        }else{
                            cell._lbTitle.text = [appDelegate.localization localizedStringForKey:text_send_request_friend];
                        }
                    }
                    cell._imgArrow.hidden = YES;
                    cell._swAction.hidden = YES;
                    
                    break;
                }
                case 2:{
                    cell._lbTitle.text = [appDelegate.localization localizedStringForKey:text_clear_chat_history];
                    cell._imgArrow.hidden = YES;
                    cell._swAction.hidden = YES;
                    break;
                }
                default:
                    break;
            }
            return cell;
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:{
            if (appDelegate.idContact > 0) {
                // Xem thông tin contact
                appDelegate.idContact = idContact;
                [[PhoneMainView instance] changeCurrentView:[KContactDetailViewController compositeViewDescription] push: true];
            }
            break;
        }
        case 1:{
            switch (indexPath.row) {
                case 0:{
                    [self onSelectedOnChatImages];
                    break;
                }
                case 1:{
                    BackgroundViewController *backgroudVC = VIEW(BackgroundViewController);
                    if (backgroudVC != nil) {
                        backgroudVC._chatGroup = NO;
                    }
                    [[PhoneMainView instance] changeCurrentView: [BackgroundViewController compositeViewDescription] push: true];
                    break;
                }
                case 2:{
                    NSLog(@"Bao tin nhan moi");
                    break;
                }
                case 3:{
                    ExportConversationPopupView *exportPopupView = [[ExportConversationPopupView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-260)/2, (SCREEN_HEIGHT-186)/2, 260, 186)];
                    
                    //  Tạo tên file cho save conversation
                    NSString *curDate = [AppUtils getCurrentDate];
                    NSString *currenTime = [AppUtils getCurrentTime];
                    currenTime = [currenTime stringByReplacingOccurrencesOfString:@" " withString:@""];
                    NSString *fileName = [NSString stringWithFormat:@"%@_%@_%@%@.html", remoteParty, USERNAME, curDate, currenTime];
                    [exportPopupView._tvFileName setText: fileName];
                    [exportPopupView showInView:appDelegate.window animated:true];
                    break;
                }
                case 4:{
                    //  Xoá conversation của 1 user
                    CGRect popupFrame = CGRectMake((SCREEN_WIDTH-260)/2, (SCREEN_HEIGHT-20-150)/2, 260, 150);
                    popupDelete = [[DeleteConversationPopupView alloc] initWithFrame:popupFrame];
                    [popupDelete._btnDelete addTarget:self
                                               action:@selector(btnDeleteConversationPressed:)
                                     forControlEvents:UIControlEventTouchUpInside];
                    [popupDelete showInView:appDelegate.window animated:YES];
                    break;
                }
            }
            break;
        }
        case 3:{
            switch (indexPath.row) {
                case 1:{
                    BOOL isFriend = [self checkCloudfoneIDInListFriend: remoteParty];
                    if (isFriend) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[appDelegate.localization localizedStringForKey:text_alert] message:[appDelegate.localization localizedStringForKey:text_unfriend_content] delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:text_cancel] otherButtonTitles:[appDelegate.localization localizedStringForKey:text_ok], nil];
                        alertView.delegate = self;
                        alertView.tag = 100;
                        [alertView show];
                    }else{
                        if ([NSDatabase checkRequestFriendExistsOnList: remoteParty]) {
                            [self acceptRequestFriendFromThisUser];
                        }else{
                            [self sendRequestToCurrentUser];
                        }
                    }
                    break;
                }
                case 2:{
                    //  Xoá conversation của 1 user
                    CGRect popupFrame = CGRectMake((SCREEN_WIDTH-260)/2, (SCREEN_HEIGHT-20-150)/2, 260, 150);
                    popupDelete = [[DeleteConversationPopupView alloc] initWithFrame:popupFrame];
                    [popupDelete._btnDelete addTarget:self
                                               action:@selector(btnDeleteConversationPressed:)
                                     forControlEvents:UIControlEventTouchUpInside];
                    [popupDelete showInView:appDelegate.window animated:YES];
                    
                    break;
                }
            }
            break;
        }
        default:
            break;
    }
    
//    if (indexPath.row == uChatImagesRM)
//    {
//
//    }else if (indexPath.row == uViewContactInfoRM) {
//        appDelegate.idContact = idContact;
//        [[PhoneMainView instance] changeCurrentView:[KContactDetailViewController compositeViewDescription] push: true];
//    }else if (indexPath.row == uBlockContactRM) {
//
//    }else if (indexPath.row == uNewContactRM){
//        if (idContact == idContactUnknown)
//        {
//            /*  Leo Kelvin
//            appDelegate._contactForAdd._callnexID = [AppUtils getSipFoneIDFromString: appDelegate.friendBuddy.accountName];
//            appDelegate._contactForAdd._phoneNumber = @"";
//            appDelegate._contactForAdd._accept = false;
//            */
//            [[PhoneMainView instance] changeCurrentView:[NewContactFromChatViewController compositeViewDescription] push: true];
//
//            NSString *cloudFoneID = [AppUtils getSipFoneIDFromString: appDelegate.friendBuddy.accountName];
//            [[NSNotificationCenter defaultCenter] postNotificationName:saveNewContactFromChatView
//                                                                object:cloudFoneID];
//        }else{
//            [appDelegate setIdContact: idContact];
//            [[PhoneMainView instance] changeCurrentView:[KContactDetailViewController compositeViewDescription] push: true];
//        }
//    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return hCellAvatar;
    }else if (indexPath.section == 2){
        return 130;
    }else{
        return hCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section != 0) {
        return 7;
    }
    return 0;
}

#pragma mark - UISwitch
- (void)switchBlockContactChanged {
    //  for block contact
    NSString *keyBlockContact = [NSString stringWithFormat:@"%@_%@_%@", prefix_CHAT_BLOCK, USERNAME, remoteParty];
    NSString *blockValue = [[NSUserDefaults standardUserDefaults] objectForKey:keyBlockContact];
    if ([blockValue intValue] == 0) {
        isBlockContact = 1;
    }else{
        isBlockContact = 0;
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:isBlockContact]
                                              forKey:keyBlockContact];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)switchBurnMessageChanged {
    //  for burn message
    NSString *keyBurnMsg = [NSString stringWithFormat:@"%@_%@_%@", prefix_CHAT_BURN, USERNAME, remoteParty];
    NSString *burnValue = [[NSUserDefaults standardUserDefaults] objectForKey:keyBurnMsg];
    if ([burnValue intValue] == 0) {
        hasBurnMsg = 1;
    }else{
        hasBurnMsg = 0;
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:hasBurnMsg]
                                              forKey:keyBurnMsg];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - My Fucntions

- (void)settingForReceiveNewMsgNotif {
    NSString *keyMsgNotif = [NSString stringWithFormat:@"%@_%@_%@", prefix_CHAT_NOTIF, USERNAME, remoteParty];
    NSString *notifValue = [[NSUserDefaults standardUserDefaults] objectForKey:keyMsgNotif];
    if (notifValue == nil || [notifValue intValue] == 1) {
        newMsgNotif = 0;
    }else{
        newMsgNotif = 1;
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:newMsgNotif] forKey:keyMsgNotif];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//  setting cho remoteParty
- (void)checkSettingForCurrentRemoteParty: (NSString *)user {
    //  for message notification
    NSString *keyMsgNotif = [NSString stringWithFormat:@"%@_%@_%@", prefix_CHAT_NOTIF, USERNAME, user];
    NSString *notifValue = [[NSUserDefaults standardUserDefaults] objectForKey:keyMsgNotif];
    if (notifValue == nil) {
        newMsgNotif = 1;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1]
                                                  forKey:keyMsgNotif];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        newMsgNotif = [notifValue intValue];
    }
    
    //  for burn message
    NSString *keyBurnMsg = [NSString stringWithFormat:@"%@_%@_%@", prefix_CHAT_BURN, USERNAME, user];
    NSString *burnValue = [[NSUserDefaults standardUserDefaults] objectForKey:keyBurnMsg];
    if (burnValue == nil) {
        hasBurnMsg = 0;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0]
                                                  forKey:keyBurnMsg];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        hasBurnMsg = [burnValue intValue];
    }
    
    //  for block contact
    NSString *keyBlockContact = [NSString stringWithFormat:@"%@_%@_%@", prefix_CHAT_BLOCK, USERNAME, user];
    NSString *blockValue = [[NSUserDefaults standardUserDefaults] objectForKey:keyBlockContact];
    if (blockValue == nil) {
        isBlockContact = 0;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0]
                                                  forKey:keyBlockContact];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        isBlockContact = [blockValue intValue];
    }
}

- (void)onSelectedOnChatImages {
    if (viewChatImages == nil) {
        [self addViewChatImagesForView];
    }
    viewChatImages._remoteParty = remoteParty;
    viewChatImages.isGroup = NO;
    
    [UIView animateWithDuration:0.2 animations:^{
        viewChatImages.frame = CGRectMake(0, viewChatImages.frame.origin.y, viewChatImages.frame.size.width, viewChatImages.frame.size.height);
    }completion:^(BOOL finished) {
        [viewChatImages loadListPictureForView];
    }];
}

- (void)iconBackOnChatImagesClicked {
    [UIView animateWithDuration:0.2 animations:^{
        viewChatImages.frame = CGRectMake(viewChatImages.frame.size.width, viewChatImages.frame.origin.y, viewChatImages.frame.size.width, viewChatImages.frame.size.height);
    }];
}

- (void)addViewChatImagesForView {
    NSArray *toplevelObject = [[NSBundle mainBundle] loadNibNamed:@"ChatImagesView" owner:nil options:nil];
    for(id currentObject in toplevelObject){
        if ([currentObject isKindOfClass:[ChatImagesView class]]) {
            viewChatImages = (ChatImagesView *) currentObject;
            break;
        }
    }
    viewChatImages.delegate = self;
    viewChatImages.frame = CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [viewChatImages setupUIForView];
    [appDelegate.window addSubview: viewChatImages];
}

- (void)acceptRequestedSuccessfully: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[NSString class]])
    {
        if ([remoteParty isEqualToString: object]) {
            [_listTableView reloadData];
        }
    }
}

- (void)btnSendRequestPressed: (UIButton *)sender {
    [sender setBackgroundColor:[UIColor colorWithRed:(188/255.0) green:(188/255.0)
                                                blue:(188/255.0) alpha:1.0]];
    [requestPopupView fadeOut];
    
    //  Gửi request kết bạn
    NSString *toUser = [NSString stringWithFormat:@"%@@%@", requestPopupView._cloudfoneID, xmpp_cloudfone];
    NSString *idRequest = [NSString stringWithFormat:@"requestsent_%@", [AppUtils randomStringWithLength: 10]];
    BOOL added = [NSDatabase addUserToRequestSent:requestPopupView._cloudfoneID withIdRequest:idRequest];
    if (added) {
        [appDelegate set_cloudfoneRequestSent: toUser];
        [appDelegate.myBuddy.protocol removeUserFromRosterList:toUser withIdMessage:idRequest];
        
        NSString *myProfileName = [NSDatabase getProfielNameOfAccount:USERNAME];
        [appDelegate.myBuddy.protocol sendRequestUserInfoOf:appDelegate.myBuddy.accountName
                                                     toUser:toUser
                                                withContent:[requestPopupView._tfRequest text]
                                             andDisplayName:myProfileName];
    }
    [self.view makeToast:[appDelegate.localization localizedStringForKey:text_send_request_msg] duration:2.0 position:CSToastPositionCenter];
}

//  Xoá conversation của user hiện tại
- (void)btnDeleteConversationPressed: (UIButton *)sender {
    [sender setBackgroundColor: [UIColor colorWithRed:(223/255.0) green:(255/255.0)
                                                 blue:(133/255.0) alpha:1]];
    
    [NSDatabase deleteConversationOfMeWithUser: remoteParty];
    [popupDelete fadeOut];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:whenDeleteConversationInChatView
                                                        object:nil];
}

//  Bật cờ cho block hay unblock contact
- (void)waitingForDelay {
    readyPress = true;
}

- (void)btnAddTouchDown: (UIButton *)sender {
    [sender setBackgroundColor:[UIColor whiteColor]];
    [sender setTitleColor:[UIColor colorWithRed:(24/255.0) green:(185/255.0)
                                           blue:(153/255.0) alpha:1.0]
                 forState:UIControlStateNormal];
}

//  Di chuyển đến view chọn contact để add vào group chat
- (void)goToViewAddParticipants: (UIButton *)sender
{
    //  Gán giá trị của room chat là 0
    [appDelegate setIdRoomChat: 0];
    
    [sender setBackgroundColor:[UIColor colorWithRed:(24/255.0) green:(185/255.0)
                                                blue:(153/255.0) alpha:1.0]];
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    AddParticientsViewController *controller = VIEW(AddParticientsViewController);
    if (controller != nil) {
        [controller updateValueForController: false];
    }
    [[PhoneMainView instance] changeCurrentView:AddParticientsViewController.compositeViewDescription];
}

//  Kiểm tra trạng thái online, offline của user
- (int)checkStatusOfUser: (NSString *)callnexUser{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName CONTAINS[cd] %@", callnexUser];
    NSMutableDictionary *listUserDict = [[[OTRProtocolManager sharedInstance] buddyList] allBuddies];
    NSArray *listUser = [OTRBuddyList sortBuddies: listUserDict];
    NSArray *resultArr = [listUser filteredArrayUsingPredicate: predicate];
    if (resultArr.count > 0) {
        OTRBuddy *curBuddy = [resultArr objectAtIndex: 0];
        if (curBuddy.status == kOTRBuddyStatusAvailable || curBuddy.status == kOTRBuddyStatusAway) {
            return 1;
        }else{
            return 0;
        }
    }else{
        return -1;
    }
}

//  Get trạng thái của user
- (NSString *)getStatusStringOfUserOnList: (NSString *)callnexUser{
    if ([callnexUser isEqualToString: @""] || callnexUser == nil) {
        return welcomeToCloudFone;
    }else{
        NSString *statusStr = @"";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName CONTAINS[cd] %@", callnexUser];
        NSMutableDictionary *listUserDict = [[[OTRProtocolManager sharedInstance] buddyList] allBuddies];
        NSArray *listUser = [OTRBuddyList sortBuddies: listUserDict];
        NSArray *resultArr = [listUser filteredArrayUsingPredicate: predicate];
        if (resultArr.count > 0) {
            OTRBuddy *curBuddy = [resultArr objectAtIndex: 0];
            if (curBuddy.status == kOTRBuddyStatusOffline) {
                statusStr = [appDelegate.localization localizedStringForKey:text_signed_out];
            }else{
                statusStr = [appDelegate._statusXMPPDict objectForKey: callnexUser];
                if (statusStr == nil || [statusStr isEqualToString: @""]) {
                    statusStr = welcomeToCloudFone;
                }
            }
        }
        return statusStr;
    }
}

//  Cập nhật lại roster list
- (void)buddyListUpdate {
    if(![[OTRProtocolManager sharedInstance] buddyList]) {
        return;
    }
    [_listTableView reloadData];
}

//  get callnex id tu chuoi conference
- (NSString *)getCallnexIDFromConferenceString: (NSString *)conferenceStr{
    NSRange range = [conferenceStr rangeOfString:[NSString stringWithFormat:@"@%@/", xmpp_cloudfone_group] options:NSCaseInsensitiveSearch];
    NSString *resultStr = @"";
    if (range.location != NSNotFound) {
        resultStr = [conferenceStr substringFromIndex: range.location+range.length];
    }
    return resultStr;
}

//  Kiểm tra cloudfone có nằm trong ds bạn hay ko?
- (BOOL)checkCloudfoneIDInListFriend: (NSString *)cloudfone {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self CONTAINS[cd] %@", cloudfone];
    NSArray *filter = [appDelegate._listFriends filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        return true;
    }else{
        return false;
    }
}

#pragma mark - Member Cell Delegate
- (void)addNewMembersToRoomChat {
    ChooseContactsViewController *controller = VIEW(ChooseContactsViewController);
    if (controller != nil) {
        controller._isForwardMessage = NO;
        controller._idForwardMessage = @"";
    }
    [[PhoneMainView instance] changeCurrentView:[ChooseContactsViewController compositeViewDescription] push:true];
}

- (void)viewContactDetailsWithInfo:(NSString *)sipPhone {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", sipPhone];
    NSArray *filter = [appDelegate._listFriends filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        NSLog(@"Khong phai ban be");
    }else{
        NSLog(@"------Khong phai ban be");
    }
}

#pragma mark - UIAlertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100) {
        if (buttonIndex == 0) {
            NSLog(@"Cancel unfriend");
        }else if (buttonIndex == 1){
            if (!appDelegate._internetActive) {
                [appDelegate.window makeToast:[appDelegate.localization localizedStringForKey:text_please_check_your_connection]
                                     duration:2.0 position:CSToastPositionCenter];
            }else{
                NSString *strUser = [NSString stringWithFormat:@"%@@%@", remoteParty, xmpp_cloudfone];
                [appDelegate.myBuddy.protocol removeUserFromRosterList:strUser
                                                         withIdMessage:[AppUtils randomStringWithLength: 10]];
            }
        }
    }
}

- (void)sendRequestToCurrentUser {
    if (!appDelegate._internetActive) {
        [appDelegate.window makeToast:[appDelegate.localization localizedStringForKey:text_please_check_your_connection]
                             duration:2.0 position:CSToastPositionCenter];
    }else{
        float hPopup = 133; // 4 + 40 + 10 + 30 + 10 + 35 + 4;
        if (SCREEN_WIDTH > 320) {
            hPopup = 4 + 40 + 10 + 40 + 10 + 40 + 4;
        }else{
            hPopup = 4 + 40 + 10 + 35 + 10 + 35 + 4;
        }
        NSString *fullName = [NSDatabase getNameOfContactWithPhoneNumber: remoteParty];
        requestPopupView = [[PopupFriendRequest alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-268)/2, (SCREEN_HEIGHT-20-hPopup)/2, 268, hPopup)];
        [requestPopupView._btnSend addTarget:self
                                      action:@selector(btnSendRequestPressed:)
                            forControlEvents:UIControlEventTouchUpInside];
        requestPopupView._lbHeader.text = [NSString stringWithFormat:@"%@ %@", [appDelegate.localization localizedStringForKey:TEXT_ADD_FRIEND_TITLE], fullName];
        [requestPopupView set_cloudfoneID: remoteParty];
        [requestPopupView showInView: appDelegate.window animated: true];
    }
}

- (void)acceptRequestFriendFromThisUser {
    if (!appDelegate._internetActive) {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:text_please_check_your_connection]
                    duration:2.0 position:CSToastPositionCenter];
    }else {
        NSString *account = [NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone];
        NSString *user = [NSString stringWithFormat:@"%@@%@", remoteParty, xmpp_cloudfone];
        [appDelegate.myBuddy.protocol acceptRequestFromUser:user toMe:account];
    }
}

@end
