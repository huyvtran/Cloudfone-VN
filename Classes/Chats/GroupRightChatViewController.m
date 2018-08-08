//
//  GroupRightChatViewController.m
//  linphone
//
//  Created by Ei Captain on 7/12/16.
//
//

#import "GroupRightChatViewController.h"
#import "KContactDetailViewController.h"
#import "GroupMainChatViewController.h"
#import "AddParticientsViewController.h"
#import "BackgroundViewController.h"
#import "ChooseContactsViewController.h"
#import "PhoneMainView.h"
#import "PopupChangeSubject.h"
#import "PopupChangeRoomName.h"
#import "PopupUserOptionChat.h"
#import "ExportConversationPopupView.h"
#import "AlertPopupView.h"
#import "ChatProfileCell.h"
#import "NSDatabase.h"
#import "MarqueeLabel.h"
#import "NSData+Base64.h"
#import "ContactChatObj.h"
#import "ChatSettingCell.h"

#define NUM_OF_SECTION 4

@interface GroupRightChatViewController ()
{
    LinphoneAppDelegate *appDelegate;
    UIFont *textFont;
    
    NSMutableArray *listData;
    NSMutableArray *listUsers;
    
    float hCell;
    float hContactCell;
    
    PopupChangeSubject *changeSubjectPopup;
    PopupChangeRoomName *changeRoomNamePopup;
    PopupUserOptionChat *optionUserPopup;
    float hKeyboard;
    
    float hCellAvatar;
    int newMsgNotif;
    NSMutableArray *listMembers;
    
    ChatImagesView *viewChatImages;
}

@end

@implementation GroupRightChatViewController
@synthesize _tbContent;

- (void)viewDidLoad {
    [super viewDidLoad];
    // MY CODE HERE
    appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
        hCell = 50;
        hCellAvatar = 80.0;
    }else{
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
        hCell = 45;
        hCellAvatar = 60.0;
    }
    
    hContactCell = 60;
    
    // Tableview
    [_tbContent setDelegate: self];
    [_tbContent setDataSource: self];
    [_tbContent setSeparatorStyle: UITableViewCellSeparatorStyleNone];
    [_tbContent setFrame: CGRectMake(65, 0, SCREEN_WIDTH-50, SCREEN_HEIGHT-20)];
    [_tbContent setShowsHorizontalScrollIndicator: false];
    [_tbContent setShowsVerticalScrollIndicator: false];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //  Bỏ sự kiện tap vào màn hình chat khi menu đang hiển thị
    [[NSNotificationCenter defaultCenter] postNotificationName:k11DisableTapGestureChat
                                                        object:[NSNumber numberWithInt:1]];
    
    //  get danh sách các user trong group chat
    [self getListCurrentUserOnRoomChat];
    
    //  Kiểm tra setting cho room hiện tại
    [self checkSettingForCurrentRoom: appDelegate.roomChatName];
    
    //  save list member
    if (listMembers == nil) {
        listMembers = [[NSMutableArray alloc] init];
    }
    [listMembers removeAllObjects];
    [listMembers addObjectsFromArray:[NSDatabase getListOccupantsInGroup:appDelegate.roomChatName ofAccount:USERNAME]];
    
    //  listener
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataForGetListUserInRoomChat:)
     name:k11GetListUserInRoomChat object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWhenShowKeyboard:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendEmailAfterSaveConversation:)
                                                 name:k11SendMailAfterSaveConversation object:nil];
    
    //  Cập nhật tên mới của room nếu có thay đổi
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeGroupNameOfRoom:)
                                                 name:k11UpdateNewGroupName object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataAfterBlockUser)
                                                 name:reloadRightGroupChatVC object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadListParticipants:)
                                                 name:updateListMemberInRoom object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSubjectFailed)
                                                 name:failedChangeRoomSubject object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leaveFromRoomChat)
                                                 name:afterLeaveFromRoomChat object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenUserLeaveFromRoomChat)
                                                 name:aUserLeaveRoomChat object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveIQLeaveRoom)
                                                 name:receiveIQResultLeaveRoom object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveErrorIQLeaveRoom)
                                                 name:receiveIQErrorLeaveRoom object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MY FUNCTIONS
//  Add new by Khai Le in 08/11/2017
- (void)receiveIQLeaveRoom {
    [appDelegate.myBuddy.protocol leaveConference: appDelegate.roomChatName];
}

- (void)receiveErrorIQLeaveRoom {
    [self.view makeToast:[appDelegate.localization localizedStringForKey:leave_room_failed]
                duration:2.0 position:CSToastPositionCenter];
}

- (void)onSelectedOnChatImages {
    if (viewChatImages == nil) {
        [self addViewChatImagesForView];
    }
    viewChatImages._remoteParty = appDelegate.roomChatName;
    viewChatImages.isGroup = YES;
    
    [UIView animateWithDuration:0.2 animations:^{
        viewChatImages.frame = CGRectMake(0, viewChatImages.frame.origin.y, viewChatImages.frame.size.width, viewChatImages.frame.size.height);
    }completion:^(BOOL finished) {
        [viewChatImages loadListPictureForView];
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

- (void)tapToChangeRoomSubject {
    changeSubjectPopup = [[PopupChangeSubject alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-268)/2, (SCREEN_HEIGHT-20-133)/2, 268, 133)];
    changeSubjectPopup._roomName = appDelegate.roomChatName;
    changeSubjectPopup._tfSubject.text = [NSDatabase getSubjectOfRoom: appDelegate.roomChatName];
    [changeSubjectPopup showInView: appDelegate.window animated: true];
}

//  setting cho remoteParty
- (void)checkSettingForCurrentRoom: (NSString *)room {
    //  for message notification
    NSString *keyMsgNotif = [NSString stringWithFormat:@"%@_%@_%@", prefix_CHAT_NOTIF, USERNAME, room];
    NSString *notifValue = [[NSUserDefaults standardUserDefaults] objectForKey:keyMsgNotif];
    if (notifValue == nil) {
        newMsgNotif = 1;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1]
                                                  forKey:keyMsgNotif];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        newMsgNotif = [notifValue intValue];
    }
}

- (void)whenUserLeaveFromRoomChat
{
    //  get danh sách các user trong group chat
    [self getListCurrentUserOnRoomChat];
}

- (void)leaveFromRoomChat {
    [PhoneMainView.instance popCurrentView];
}

- (void)changeSubjectFailed {
    [self.view makeToast:[appDelegate.localization localizedStringForKey:change_subject_failed]
                duration:2.0 position:CSToastPositionCenter];
}

//  Get danh sách khi có sự thay đổi
- (void)reloadListParticipants: (NSNotification *)notif {
    [self getListCurrentUserOnRoomChat];
}

//  Sau khi block hay unblock user thì reload lại dữ liệu
- (void)reloadDataAfterBlockUser {
    [_tbContent reloadData];
}

//  Khi touch trên message cell
- (void)whenLongTouchOnUser:(UILongPressGestureRecognizer *)lpt {
    if (lpt.state == UIGestureRecognizerStateBegan) {
        int tag = (int)lpt.view.tag;
        ChatProfileCell *curCell = (ChatProfileCell *)[_tbContent cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tag inSection:0]];
        
        CGRect popupFrame = CGRectMake((SCREEN_WIDTH-238)/2, (SCREEN_HEIGHT-4*40-8)/2, 238, 4*40+8);
        optionUserPopup = [[PopupUserOptionChat alloc] initWithFrame:popupFrame];
        [optionUserPopup set_callnexID: curCell._callnexID];
        [optionUserPopup set_idContact: curCell._idContact];
        [optionUserPopup setupBlockValueForUser];
        [optionUserPopup showInView:appDelegate.window animated:YES];
    }
}

//  Cập nhật tên của group chat
- (void)changeGroupNameOfRoom: (NSNotification *)notif {
    if ([[[PhoneMainView instance] currentView] isEqual:[GroupMainChatViewController compositeViewDescription]]) {
        id object = [notif object];
        if ([object isKindOfClass:[NSString class]]) {
            NSString *currentRoom = [NSDatabase getRoomNameOfRoomWithRoomId: appDelegate.idRoomChat];
            if ([currentRoom isEqualToString: object]) {
                NSString *groupName = [NSDatabase getSubjectOfRoom: currentRoom];
                ChatProfileCell *pCell = [_tbContent cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                if (pCell != nil) {
                    pCell._lbName.text = groupName;
                }
            }
        }
    }
}

//  Gửi email sau khi save conversation thành công
- (void)sendEmailAfterSaveConversation: (NSNotification *)notif {
    if ([[[PhoneMainView instance] currentView] isEqual:[GroupMainChatViewController compositeViewDescription]]) {
        id object = [notif object];
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSData *fileData    = [object objectForKey:@"fileData"];
            NSString *fileName  = [object objectForKey:@"fileName"];
            
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            [picker setMailComposeDelegate: self];
            [picker setSubject: [appDelegate.localization localizedStringForKey:text_export_content]];
            
            // Set up recipients
            // NSArray *toRecipients = [NSArray arrayWithObject:@"first@example.com"];
            // NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
            // NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"];
            
            // [picker setToRecipients:toRecipients];
            // [picker setCcRecipients:ccRecipients];
            // [picker setBccRecipients:bccRecipients];
            
            // Attach an image to the email
            [picker addAttachmentData:fileData mimeType:@"text/html" fileName: fileName];
            
            // Fill out the email body text
            NSString *emailBody = @"";
            [picker setMessageBody:emailBody isHTML: false];
            [self presentViewController:picker animated:true completion:nil];
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Result: canceled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Result: saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Result: sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Result: failed");
            break;
        default:
            NSLog(@"Result: not sent");
            break;
    }
    [self dismissViewControllerAnimated:true completion:nil];
}

//  Hiển thị popup cập nhật tên hiển thị của phòng
- (void)showPopupChangeGroupName {
    changeRoomNamePopup = [[PopupChangeRoomName alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-268)/2, (SCREEN_HEIGHT-20-133)/2, 268, 133)];
    [changeRoomNamePopup set_roomName: appDelegate.roomChatName];
    [changeRoomNamePopup showInView: appDelegate.window animated: true];
}

//  Khi show bàn phím
- (void)notificationWhenShowKeyboard:(NSNotification*)notification {
    if (hKeyboard == 0) {
        NSDictionary* keyboardInfo = [notification userInfo];
        NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
        CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
        hKeyboard = keyboardFrameBeginRect.size.height;
    }
    if (changeSubjectPopup != nil) {
        [changeSubjectPopup setFrame: CGRectMake(changeSubjectPopup.frame.origin.x, (SCREEN_HEIGHT-20-hKeyboard-changeSubjectPopup.frame.size.height)/2, changeSubjectPopup.frame.size.width, changeSubjectPopup.frame.size.height)];
    }
    
    
    if (changeRoomNamePopup != nil) {
        [changeRoomNamePopup setFrame: CGRectMake(changeRoomNamePopup.frame.origin.x, (SCREEN_HEIGHT-20-hKeyboard-changeRoomNamePopup.frame.size.height)/2, changeRoomNamePopup.frame.size.width, changeRoomNamePopup.frame.size.height)];
    }
}

//  Lấy list avatar trong danh sách user
- (NSMutableArray *)getListAvatarOfUserInRoomChat: (NSArray *)listUser {
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    for (int iCount=0; iCount<listUser.count; iCount++) {
        ContactChatObj *curObject = [listUser objectAtIndex: iCount];
        [resultArr addObject: curObject._avatar];
        if (resultArr.count >= 4) {
            break;
        }
    }
    return resultArr;
}

//  Hàm đưa callnexID của mình lên đầu danh sách
- (void)moveMyAvatarGoToFirstInList: (NSMutableArray *)listUser {
    NSString *findStr = [NSString stringWithFormat:@"%@@%@/%@", appDelegate.roomChatName, xmpp_cloudfone_group, USERNAME];
    if ([listUser containsObject:findStr]) {
        [listUser removeObject: findStr];
        [listUser insertObject:findStr atIndex:0];
    }
}

//  Di chuyển đến view chọn contact để add vào group chat
- (void)goToViewAddParticipants
{
    //  Gán giá trị của room chat
    [appDelegate setIdRoomChat: appDelegate.idRoomChat];
    
    AddParticientsViewController *controller = VIEW(AddParticientsViewController);
    if (controller != nil) {
        [controller updateValueForController: true];
    }
    [[PhoneMainView instance] changeCurrentView: [AddParticientsViewController compositeViewDescription] push: true];
}

//  Lấy danh sách các user đang online trong room chat
- (void)getListCurrentUserOnRoomChat
{
    /*  Leo Kelvin
    [appDelegate.myBuddy.protocol getListOnlineOccupantsInGroup: roomName];
    [appDelegate.myBuddy.protocol getListUserInRoomChat:roomName];
    */
    
    if (listUsers == nil) {
        listUsers = [[NSMutableArray alloc] init];
    }else{
        [listUsers removeAllObjects];
    }
    [listUsers addObjectsFromArray:[NSDatabase getListOccupantsInGroup: appDelegate.roomChatName ofAccount: USERNAME]];
    [_tbContent reloadData];
}

//  Kết quả danh sách user của room trả về
- (void)dataForGetListUserInRoomChat: (NSNotification *)notif {
    if ([[[PhoneMainView instance] currentView] isEqual:[GroupMainChatViewController compositeViewDescription]]) {
        id object = [notif object];
        if ([object isKindOfClass:[NSMutableArray class]]) {
            [self moveMyAvatarGoToFirstInList: object];
            
            if (listUsers == nil) {
                listUsers = [[NSMutableArray alloc] init];
            }
            [listUsers removeAllObjects];
            
            NSString *finfStr = [NSString stringWithFormat:@"%@/", xmpp_cloudfone_group];
            for (int iCount=0; iCount<[(NSArray *)object count]; iCount++) {
                NSString *itemStr = [(NSArray *)object objectAtIndex:iCount];
                NSRange range = [itemStr rangeOfString:finfStr];
                if (range.location != NSNotFound) {
                    NSString *callnexID = [itemStr substringFromIndex:(range.location+range.length)];
                    if (![callnexID isEqualToString:@""]) {
                        ContactChatObj *contact = [NSDatabase getContactInfoWithCallnexID: callnexID];
                        [listUsers addObject: contact];
                    }
                }
            }
            [_tbContent reloadData];
            [self getListAvatarOfUserInRoomChat: listUsers];
        }
    }
}

#pragma mark - UITableview Delegate
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
            return 3;
            break;
        }
        case 2:{
            return 1;
            break;
        }
        case 3:{
            return 2;
            break;
        }
        default:{
            return 0;
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
            pCell.frame = CGRectMake(pCell.frame.origin.x, pCell.frame.origin.y, _tbContent.frame.size.width, hCellAvatar);
            [pCell setupUIForCell];
            pCell._imgAvatar.layer.cornerRadius = 0;
            
            pCell._imgClock.hidden = YES;
            
            NSString *subject = [NSDatabase getSubjectOfRoom: appDelegate.roomChatName];
            if (![subject isEqualToString: @""]) {
                pCell._lbName.text = subject;
            }else{
                pCell._lbName.text = appDelegate.roomChatName;
            }
            pCell._lbStatus.text = [appDelegate.localization localizedStringForKey:text_change_subject];
            pCell._lbStatus.font = [UIFont systemFontOfSize: 15.0];
            
            UITapGestureRecognizer *changeSubject = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToChangeRoomSubject)];
            pCell._lbStatus.userInteractionEnabled = YES;
            [pCell._lbStatus addGestureRecognizer: changeSubject];
            pCell._lbStatus.textColor = [UIColor colorWithRed:0.169 green:0.53 blue:0.949 alpha:1.0];
            
            UIImage *imgAvatar = [AppUtils createAvatarForRoom:appDelegate.roomChatName withSize:200];
            if (imgAvatar != nil) {
                pCell._imgAvatar.image = imgAvatar;
            }else{
                pCell._imgAvatar.image = [UIImage imageNamed:@"groupchat_default"];
            }
            
            return pCell;
            break;
        }
        case 1:{
            NSString *identifier = @"ChatSettingCell";
            ChatSettingCell *cell = (ChatSettingCell *)[tableView dequeueReusableCellWithIdentifier: identifier];
            if (cell == nil) {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ChatSettingCell" owner:self options:nil];
                cell = topLevelObjects[0];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, _tbContent.frame.size.width, hCell);
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
            
            float hMember = [self getHeightForListMember];
            cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, _tbContent.frame.size.width, hMember+35);
            [cell setupUIForCell];
            cell._lbMember.text = [appDelegate.localization localizedStringForKey:@"Members"];
            [cell setupListMember: listMembers];
            
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
            
            cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, _tbContent.frame.size.width, hCell);
            [cell setupUIForCell];
            
            switch (indexPath.row) {
                case 0:{
                    cell._lbTitle.text = [appDelegate.localization localizedStringForKey:@"Clear chat history"];
                    cell._imgArrow.hidden = YES;
                    cell._swAction.hidden = YES;
                    break;
                    break;
                }
                case 1:{
                    cell._lbTitle.text = [appDelegate.localization localizedStringForKey:text_leave_room];
                    cell._imgArrow.hidden = YES;
                    cell._swAction.hidden = YES;
                    break;
                }
                default:
                    break;
            }
            return cell;
        }
        default:{
            return nil;
        }
    }
    /*
    if (indexPath.row < listData.count) {
        
        return cell;
    }else if (indexPath.row == listData.count){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:@"Cell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setTag: indexPath.row];
        
        [cell.textLabel setText: [localization localizedStringForKey:text_participants]];
        [cell.textLabel setFont: textFont];
        
        UIButton *btnAdd = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-appDelegate._wSubMenu-20-60, 8, 60, 28)];
        [btnAdd setBackgroundImage:[UIImage imageNamed:@"active_button.png"]
                          forState:UIControlStateNormal];
        
        [btnAdd setBackgroundImage:[UIImage imageNamed:@"active_button_press.png"]
                          forState:UIControlStateHighlighted];
        [btnAdd setTitle: [localization localizedStringForKey:text_add]
                forState:UIControlStateNormal];
        [btnAdd.titleLabel setFont: textFont];
        [btnAdd addTarget:self
                   action:@selector(goToViewAddParticipants)
         forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview: btnAdd];
        return cell;
    }else{
        NSString *avatarCell = @"ChatProfileCell";
        ChatProfileCell *cell = (ChatProfileCell *)[tableView dequeueReusableCellWithIdentifier: avatarCell];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ChatProfileCell" owner:self options:nil];
            cell = topLevelObjects[0];
        }
        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
        [cell setTag: indexPath.row];
        
        NSString *cloudfoneID = [listUsers objectAtIndex: (indexPath.row-listData.count-1)];
        if ([cloudfoneID isEqualToString:USERNAME]) {
            [cell._lbName setText: [localization localizedStringForKey:text_you]];
        }else
        {
            NSString *name = [NSDatabase getNameOfContactWithCallnexID: cloudfoneID];
            [cell._lbName setText: name];
            
            //  Add sự kiện touch vào message
            UILongPressGestureRecognizer *longPressTap =
            [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                          action:@selector(whenLongTouchOnUser:)];
            [longPressTap setMinimumPressDuration: 1.0];
            [cell addGestureRecognizer: longPressTap];
     
            [cell set_callnexID: contact._callnexID];
            [cell set_idContact: contact._idContact];
        }
        
        NSString *avatar = [NSDatabase getAvatarDataStringOfCallnexID: cloudfoneID];
        if ([avatar isEqualToString:@""]) {
            [cell._imgAvatar setImage:[UIImage imageNamed:@"no_avatar.png"]];
        }else{
            [cell._imgAvatar setImage:[UIImage imageWithData:[NSData dataFromBase64String: avatar]]];
        }
        
        NSString *statusStr = [appDelegate._statusXMPPDict objectForKey: cloudfoneID];
        if (statusStr == nil || [statusStr isEqualToString: @""]) {
            [cell._lbStatus setText: welcomeToCloudFone];
        }else{
            [cell._lbStatus setText: statusStr];
        }
        
        [cell._imgClock setHidden: true];
        BOOL isBlock = [NSDatabase checkContactInBlackList:contact._idContact andCloudfoneID:contact._callnexID];
        if (isBlock) {
            [cell._imgClock setHidden: false];
        }else{
            [cell._imgClock setHidden: true];
        }
        
        return cell;
    }   */
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 1:{
            switch (indexPath.row) {
                case 0:{
                    [self onSelectedOnChatImages];
                    break;
                }
                case 1:{
                    BackgroundViewController *backgroudVC = VIEW(BackgroundViewController);
                    if (backgroudVC != nil) {
                        backgroudVC._chatGroup = YES;
                    }
                    [[PhoneMainView instance] changeCurrentView: [BackgroundViewController compositeViewDescription] push: true];
                    break;
                }
                case 2:{
                    NSLog(@"Bao tin nhan moi");
                    break;
                }
            }
            break;
        }
        case 3:{
            switch (indexPath.row) {
                case 0:{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[appDelegate.localization localizedStringForKey:TEXT_CONFIRM] message:[appDelegate.localization localizedStringForKey:text_clear_history_group_chat] delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:TEXT_NONE] otherButtonTitles:[appDelegate.localization localizedStringForKey:text_delete], nil];
                    alertView.delegate = self;
                    alertView.tag = 100;
                    [alertView show];
                    break;
                }
                case 1:{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[appDelegate.localization localizedStringForKey:TEXT_CONFIRM] message:[appDelegate.localization localizedStringForKey:text_leave_and_clear_history_group] delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:text_cancel] otherButtonTitles:[appDelegate.localization localizedStringForKey:text_leave_room], nil];
                    alertView.delegate = self;
                    alertView.tag = 101;
                    [alertView show];
                    break;
                }
                default:
                    break;
            }
            break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return hCellAvatar;
    }else if (indexPath.section == 2){
        float hMember = [self getHeightForListMember];
        return hMember+35;
    }else{
        return hCell;
    }
}

- (float)getHeightForListMember {
    int numPerLine = (_tbContent.frame.size.width)/70;
    float num = (float)listMembers.count/numPerLine;
    int totalLine = ceil(num);
    return totalLine*90;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section != 0) {
        return 7;
    }
    return 0;
}

#pragma mark - ChatsViewImages Delegate

- (void)iconBackOnChatImagesClicked {
    [UIView animateWithDuration:0.2 animations:^{
        viewChatImages.frame = CGRectMake(viewChatImages.frame.size.width, viewChatImages.frame.origin.y, viewChatImages.frame.size.width, viewChatImages.frame.size.height);
    }];
}

#pragma mark - Member Cell Delegate
- (void)addNewMembersToRoomChat {
    ChooseContactsViewController *controller = VIEW(ChooseContactsViewController);
    if (controller != nil) {
        controller._isForwardMessage = NO;
        controller._idForwardMessage = @"";
        controller.addFromRoomChat = YES;
        controller.listMembers = [[NSArray alloc] initWithArray: listMembers];
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

#pragma mark - Alertview Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100) {
        if (buttonIndex == 1) {
            [NSDatabase deleteConversationOfMeWithRoomChat: appDelegate.roomChatName];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:whenDeleteConversationInChatView
                                                                object:nil];
        }
    }else if (alertView.tag == 101){
        if (buttonIndex == 1) {
            NSString *idIQ = [NSString stringWithFormat:@"leaveroom_id_%@", [AppUtils randomStringWithLength:10]];
            [appDelegate.myBuddy.protocol setLeaveRoomToServer:appDelegate.roomChatName withId:idIQ];
            
            //  [appDelegate.myBuddy.protocol leaveConference: appDelegate.roomChatName];
        }
    }
}

@end
