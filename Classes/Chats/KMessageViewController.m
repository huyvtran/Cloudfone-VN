//
//  KMessageViewController.m
//  linphone
//
//  Created by mac book on 30/4/15.
//
//

#import "KMessageViewController.h"
#import "ChooseContactsViewController.h"
#import "GroupMainChatViewController.h"
#import "MainChatViewController.h"
#import "SwipeableTableViewCell.h"
#import "PhoneMainView.h"
#import "NSDatabase.h"
#import "NSData+Base64.h"
#import "TabBarView.h"
#import "OTRProtocolManager.h"
#import "ConversationObject.h"
#import "ContactChatObj.h"

@interface KMessageViewController (){
    LinphoneAppDelegate *appDelegate;
    float hCell;
    
    BOOL isFiltered;
    
    NSRegularExpression *regex;
    NSRange rangeOfFirstMatch;
    
    BOOL isDelete;
    NSMutableArray *listDelete;
    
    UIFont *textFont;
}
@end

@implementation KMessageViewController

@synthesize _viewHeader, _imgSearch, _btnDelete, _tfSearch, _lbSearch, _iconClear, _btnDone, _btnNewMsg, _tbMessage, _lbNoMsg;
@synthesize listHistoryMessage, listFilterd, _listOptions;
@synthesize _fileTransfer;

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
                                                           fragmentWith:nil];
        compositeDescription.darkBackground = true;
    }
    return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
    return self.class.compositeViewDescription;
}

#pragma mark - Web services

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //  MY CODE HERE
    appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self setupUIForView];
    
    //  Cập nhật tên mới của room nếu có thay đổi
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeGroupNameOfRoom:)
                                                 name:k11UpdateNewGroupName object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAllMessageUnreadInHistory)
                                                 name:k11UpdateAllNotisWhenBecomActive object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    // Tắt màn hình cảm biến
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled: NO];
    
    isDelete = false;
    
    [self showContentWithCurrentLanguage];
    
    [_tfSearch setText: @""];
    [_iconClear setHidden: true];
    [_btnDelete setHidden: true];
    [_btnDone setHidden: true];
    
    // Login lại chat
    if (!appDelegate.xmppStream.isConnected) {
        [AppUtils reconnectToXMPPServer];
    }
    
    [self getMessageHistoryOfUser: USERNAME];
    
    if (listHistoryMessage.count == 0) {
        [_tbMessage setHidden: true];
        [_lbNoMsg setHidden: false];
    }else{
        [_tbMessage setHidden: false];
        [_tbMessage reloadData];
        [_lbNoMsg setHidden: true];
    }
    
    //  notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReceived:)
                                                 name:kOTRMessageReceived object:nil ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveAudioMessage:)
                                                 name:k11ReceiveAudioMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buddyListUpdate)
                                                 name:kOTRBuddyListUpdate object:nil ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViewChatHistoryAfterExpire)
                                                 name:@"updateViewChatHistory" object:nil];
    
    //  Show popup thêm mới contact
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPopupAddNewContact:)
                                                 name:k11ShowPopupNewContact object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadHistoryMessageForView)
                                                 name:k11ReceiveMsgOtherRoomChat object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processWhenRoomDestroyed:)
                                                 name:whenRoomDestroyed object:nil];
    
    //  user tham gia vao phong chat
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenUserJoinToRoomChat:)
                                                 name:userJoinToRoom object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)_iconSearchClicked:(id)sender {
    [self.view endEditing: true];
    
    [_tfSearch setText: @""];
    [_lbSearch setHidden: false];
    [_iconClear setHidden: true];
    
    isFiltered = false;
    [_tbMessage reloadData];
}

#pragma mark - my functions

//  User tham gia vao room chat
- (void)whenUserJoinToRoomChat: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[NSDictionary class]]) {
        [self getMessageHistoryOfUser: USERNAME];
        
        if (listHistoryMessage.count == 0) {
            [_tbMessage setHidden: true];
            [_lbNoMsg setHidden: false];
        }else{
            [_tbMessage setHidden: false];
            [_tbMessage reloadData];
            [_lbNoMsg setHidden: true];
        }
    }
}


//  Nếu phòng hiện tại bị huỷ
- (void)processWhenRoomDestroyed: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[NSString class]]) {
        [self getMessageHistoryOfUser: USERNAME];
        
        if (listHistoryMessage.count == 0) {
            [_tbMessage setHidden: true];
            [_lbNoMsg setHidden: false];
        }else{
            [_tbMessage setHidden: false];
            [_tbMessage reloadData];
            [_lbNoMsg setHidden: true];
        }
    }
}

- (void)showContentWithCurrentLanguage {
    [_btnDelete setTitle:[appDelegate.localization localizedStringForKey:text_delete] forState:UIControlStateNormal];
    [_btnDone setTitle:[appDelegate.localization localizedStringForKey:text_finish] forState:UIControlStateNormal];
    [_lbSearch setText:[appDelegate.localization localizedStringForKey:text_type_to_search]];
    [_lbNoMsg setText: [appDelegate.localization localizedStringForKey:text_no_message]];
}

- (void)setupUIForView
{
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }else{
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
    }
    hCell = 65.0;
    
    [_viewHeader setFrame: CGRectMake(0, 0, SCREEN_WIDTH, appDelegate._hHeader)];
    [_imgSearch setFrame: CGRectMake(5, (appDelegate._hHeader-28)/2, 28, 28)];
    
    [_btnNewMsg setFrame: CGRectMake(_viewHeader.frame.size.width-appDelegate._hHeader, 0, appDelegate._hHeader, appDelegate._hHeader)];
    [_btnNewMsg setBackgroundImage:[UIImage imageNamed:@"ic_new_msg_act.png"]
                          forState:UIControlStateHighlighted];
    
    [_tfSearch setFrame: CGRectMake(_imgSearch.frame.origin.x+_imgSearch.frame.size.width+5, _imgSearch.frame.origin.y, _viewHeader.frame.size.width-(_imgSearch.frame.origin.x+_imgSearch.frame.size.width+5+5+appDelegate._hHeader), _imgSearch.frame.size.height)];
    [_tfSearch setFont: textFont];
    [_tfSearch setBorderStyle: UITextBorderStyleNone];
    [_tfSearch setTextColor:[UIColor colorWithRed:(172/255.0) green:(192/255.0)
                                             blue:(200/255.0) alpha:1.0]];
    [_tfSearch addTarget:self
                  action:@selector(onTextfieldDidChanged:)
        forControlEvents:UIControlEventEditingChanged];
    
    [_lbSearch setFrame: _tfSearch.frame];
    [_lbSearch setFont: textFont];
    
    [_tbMessage setFrame: CGRectMake(0, _viewHeader.frame.origin.y+_viewHeader.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT-(appDelegate._hStatus + appDelegate._hHeader))];
    [_tbMessage setDelegate: self];
    [_tbMessage setDataSource: self];
    [_tbMessage setSeparatorStyle: UITableViewCellSeparatorStyleNone];
    
    [_lbNoMsg setFrame: _tbMessage.frame];
    [_lbNoMsg setFont: textFont];
    
    CGSize size = [AppUtils getSizeWithText:[appDelegate.localization localizedStringForKey:text_delete]
                                       withFont:textFont];
    [_btnDelete setFrame: CGRectMake(5, 0, size.width, appDelegate._hHeader)];
    [_btnDelete.titleLabel setFont: textFont];
    
    size = [AppUtils getSizeWithText:[appDelegate.localization localizedStringForKey:text_finish]
                                withFont:textFont];
    [_btnDone setFrame: CGRectMake(_viewHeader.frame.size.width-_btnDelete.frame.origin.x-size.width, 0, size.width, appDelegate._hHeader)];
    [_btnDone.titleLabel setFont: textFont];
}

//  Tap vào toolBar để close keyboard khi search
- (void)closeKeypadForTab {
    [_tfSearch endEditing: true];
}

- (void)onCellClicked: (UIButton *)sender
{
    [self.view endEditing: true];
    int index = (int)[sender tag];
    
    ConversationObject *aMessage = nil;
    if (isFiltered){
        aMessage = [listFilterd objectAtIndex: index];
    }else{
        aMessage = [listHistoryMessage objectAtIndex: index];
    }
    
    if (!isDelete) {
        if (![aMessage._roomID isEqualToString: @""]) {
            [appDelegate setIdRoomChat: aMessage._idObject];
            
            appDelegate.reloadMessageList = YES;
            appDelegate.roomChatName = aMessage._roomID;
            [appDelegate.myBuddy.protocol acceptJoinToRoomChat: aMessage._roomID];
            
            [[PhoneMainView instance] changeCurrentView:[GroupMainChatViewController compositeViewDescription] push:true];
        }else{
            appDelegate.reloadMessageList = YES;
            appDelegate.friendBuddy = [AppUtils getBuddyOfUserOnList: aMessage._user];
            [[PhoneMainView instance] changeCurrentView:[MainChatViewController compositeViewDescription]
                                                   push:true];
        }
    }else{
        if (listDelete == nil) {
            listDelete = [[NSMutableArray alloc] init];
        }
        
        if ([aMessage._roomID isEqualToString: @""]) {
            if (aMessage._user != nil && ![aMessage._user isEqualToString: @""]) {
                SwipeableTableViewCell *curCell = [_tbMessage cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                
                if ([listDelete containsObject:aMessage._user]) {
                    [listDelete removeObject: aMessage._user];
                    [curCell._cbDelete setOn:false animated:true];
                }else{
                    [listDelete addObject: aMessage._user];
                    [curCell._cbDelete setOn:true animated:true];
                }
            }
        }else{
            SwipeableTableViewCell *curCell = [_tbMessage cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            
            if ([listDelete containsObject:aMessage._roomID]) {
                [listDelete removeObject: aMessage._roomID];
                [curCell._cbDelete setOn:false animated:true];
            }else{
                [listDelete addObject: aMessage._roomID];
                [curCell._cbDelete setOn:true animated:true];
            }
        }
        
        NSString *strDelete = @"";
        if (listDelete == nil || listDelete.count == 0) {
            strDelete = [appDelegate.localization localizedStringForKey:text_delete];
            [_btnDelete setTitle:strDelete forState:UIControlStateNormal];
        }else{
            strDelete = [NSString stringWithFormat:@"%@(%d)", [appDelegate.localization localizedStringForKey:text_delete], (int)listDelete.count];
            [_btnDelete setTitle:strDelete forState:UIControlStateNormal];
        }
        CGSize size = [AppUtils getSizeWithText:strDelete withFont:textFont];
        [_btnDelete setFrame: CGRectMake(_btnDelete.frame.origin.x, 0, size.width, appDelegate._hHeader)];
    }
}

- (void)btnCallConversationOnCellPressed: (UIButton *)sender {
    int index = (int)[sender tag];
    ConversationObject *aMessage = nil;
    if (isFiltered){
        aMessage = [listFilterd objectAtIndex: index];
    }else{
        aMessage = [listHistoryMessage objectAtIndex: index];
    }
    
    if (![aMessage._user isEqualToString: @""] && ![aMessage._user isEqualToString:USERNAME])
    {
        LinphoneAddress *addr = linphone_core_interpret_url(LC, aMessage._user.UTF8String);
        [LinphoneManager.instance call:addr];
        if (addr)
            linphone_address_destroy(addr);
        
        OutgoingCallViewController *controller = VIEW(OutgoingCallViewController);
        if (controller != nil) {
            [controller setPhoneNumberForView: aMessage._user];
        }
        [[PhoneMainView instance] changeCurrentView:[OutgoingCallViewController compositeViewDescription] push:TRUE];
    }
}

- (void)btnMuteConversationOnCellPressed: (UIButton *)sender {
    int index = (int)[sender tag];
    ConversationObject *aMessage = nil;
    if (isFiltered){
        aMessage = [listFilterd objectAtIndex: index];
    }else{
        aMessage = [listHistoryMessage objectAtIndex: index];
    }
    // Gán loại cell là group hay user
    if ([aMessage._roomID isEqualToString: @""]) {
        SwipeableTableViewCell *cell = [_tbMessage cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        NSString *keyMsgNotif = [NSString stringWithFormat:@"%@_%@_%@", prefix_CHAT_NOTIF, USERNAME, aMessage._user];
        int newMsgNotif;
        NSString *notifValue = [[NSUserDefaults standardUserDefaults] objectForKey:keyMsgNotif];
        if (notifValue == nil || [notifValue intValue] == 1) {
            newMsgNotif = 0;
            [cell._btnMute setBackgroundImage:[UIImage imageNamed:@"ic_slide_no_sound_def.png"]
                                     forState:UIControlStateNormal];
        }else{
            newMsgNotif = 1;
            [cell._btnMute setBackgroundImage:[UIImage imageNamed:@"ic_slide_sound_def.png"]
                                     forState:UIControlStateNormal];
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:newMsgNotif] forKey:keyMsgNotif];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else {
        
    }
}

//  Xó 1 conversation trên cell
- (void)btnDeleteConversationOnCellPressed: (UIButton *)sender {
    int index = (int)sender.tag;
    
    ConversationObject *aMessage = nil;
    if (isFiltered){
        aMessage = [listFilterd objectAtIndex: index];
    }else{
        aMessage = [listHistoryMessage objectAtIndex: index];
    }
    [NSDatabase deleteConversationOfMeWithUser: aMessage._user];
    
    //  Get lại danh sách tin nhắn
    [self getMessageHistoryOfUser: USERNAME];
    
    isDelete = false;
    [_tbMessage reloadData];
}

//  Nhấn giữ trên cell message
-  (void)onMessageLongPress:(UILongPressGestureRecognizer*)gesture {
    //  int tag = (int)[gesture.view tag];
    if ( gesture.state == UIGestureRecognizerStateBegan ) {
        isDelete = true;
        [self showOrHideDeleteView];
        [_tbMessage reloadData];
    }
}

//  Xử lý khi show hoặc hide view xoá
- (void)showOrHideDeleteView {
    if (isDelete) {
        [_btnDelete setHidden: false];
        [_btnDone setHidden: false];
        
        [_imgSearch setHidden: true];
        
        [_tfSearch setHidden: true];
        [_lbSearch setHidden: true];
        [_btnNewMsg setHidden: true];
    }else{
        [_btnDelete setHidden: true];
        [_btnDone setHidden: true];
        
        [_imgSearch setHidden: false];
        [_tfSearch setHidden: false];
        [_lbSearch setHidden: false];
        [_btnNewMsg setHidden: false];
    }
}

#pragma mark - Checkbox Delegate
- (void)didTapCheckBox:(BEMCheckBox *)checkBox {
    int index = (int)[checkBox tag];
    
    ConversationObject *aMessage = nil;
    if (isFiltered){
        aMessage = [listFilterd objectAtIndex: index];
    }else{
        aMessage = [listHistoryMessage objectAtIndex: index];
    }
    
    if (listDelete == nil) {
        listDelete = [[NSMutableArray alloc] init];
    }
    
    if (aMessage._user != nil && ![aMessage._user isEqualToString: @""]) {
        if ([listDelete containsObject:aMessage._user]) {
            [listDelete removeObject: aMessage._user];
        }else{
            [listDelete addObject: aMessage._user];
        }
    }
    if (listDelete == nil || listDelete.count == 0) {
        [_btnDelete setTitle:[appDelegate.localization localizedStringForKey:text_delete] forState:UIControlStateNormal];
    }else{
        [_btnDelete setTitle:[NSString stringWithFormat:@"%@(%d)", [appDelegate.localization localizedStringForKey:text_delete], (int)listDelete.count] forState:UIControlStateNormal];
    }
}

#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (isFiltered) {
        return [listFilterd count];
    }else{
        return [listHistoryMessage count];
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Lấy dữ liệu
    ConversationObject *aMessage = nil;
    if (isFiltered){
        aMessage = [listFilterd objectAtIndex:[indexPath row]];
    }else{
        aMessage = [listHistoryMessage objectAtIndex:[indexPath row]];
    }
    
    static NSString *cellId = @"randomCell";
    // For the purposes of this demo, just return a random cell.
    SwipeableTableViewCell *cell = (SwipeableTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [[SwipeableTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        [cell setFrame: CGRectMake(0, cell.frame.origin.y, _tbMessage.frame.size.width, hCell)];
        
        if ([aMessage._roomID isEqualToString:@""]) {
            //  button call
            [cell createButtonCallWithWidth:80 onSide:SwipeableTableViewCellSideRight];
            
            [cell._btnCall setBackgroundColor:[UIColor colorWithRed:(215/255.0) green:(215/255.0)
                                                               blue:(215/255.0) alpha:1.0]];
            [cell._btnCall setBackgroundImage:[UIImage imageNamed:@"ic_slide_call_def.png"]
                                     forState:UIControlStateNormal];
            [cell._btnCall addTarget:self
                              action:@selector(btnCallConversationOnCellPressed:)
                    forControlEvents:UIControlEventTouchUpInside];
        }
        
        //  button mute
        [cell createButtonMuteWithWidth:80 onSide:SwipeableTableViewCellSideRight];
        
        [cell._btnMute setBackgroundColor:[UIColor colorWithRed:(190/255.0) green:(190/255.0)
                                                           blue:(190/255.0) alpha:1.0]];
        [cell._btnMute setBackgroundImage:[UIImage imageNamed:@"ic_slide_sound_def.png"]
                                 forState:UIControlStateNormal];
        [cell._btnMute addTarget:self
                          action:@selector(btnMuteConversationOnCellPressed:)
                forControlEvents:UIControlEventTouchUpInside];
        
        //  button delete
        [cell createButtonDeleteWithWidth:80 onSide:SwipeableTableViewCellSideRight];
        [cell._btnDelete setBackgroundColor:[UIColor redColor]];
        [cell._btnDelete setBackgroundImage:[UIImage imageNamed:@"ic_slide_delete_def.png"]
                             forState:UIControlStateNormal];
        [cell._btnDelete addTarget:self
                            action:@selector(btnDeleteConversationOnCellPressed:)
                  forControlEvents:UIControlEventTouchUpInside];
    }
    [cell._btnCall setTag: indexPath.row];
    [cell._btnMute setTag: indexPath.row];
    [cell._btnDelete setTag: indexPath.row];
    
    [cell._btnTop addTarget:self
                     action:@selector(onCellClicked:)
           forControlEvents:UIControlEventTouchUpInside];
    
    UILongPressGestureRecognizer *longPressTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(onMessageLongPress:)];
    [longPressTap setMinimumPressDuration: 0.5];
    [cell._btnTop addGestureRecognizer: longPressTap];
    [cell._btnTop setTag: indexPath.row];
    
    
    
    // Gán loại cell là group hay user
    if ([aMessage._roomID isEqualToString: @""]) {
        [cell set_isGroup: false];
    }else {
        [cell set_isGroup: true];
    }
    
    [cell._cbDelete setTag: indexPath.row];
    [cell._cbDelete setDelegate: self];
    
    // Set avatar & callnexID
    if (cell._isGroup) {
        if (aMessage._roomID == nil || [aMessage._roomID isEqualToString: @""]) {
            cell._iconAvatar.image = [UIImage imageNamed:@"groupchat_default"];
        }else{
            UIImage *imgAvatar = [AppUtils createAvatarForRoom:aMessage._roomID withSize:200];
            cell._iconAvatar.image = imgAvatar;
        }
        
        [cell set_cloudFoneID: @""];
        [cell set_idContact: aMessage._idObject];
        [cell._imgBlock setHidden: true];
        
        NSString *subject = [NSDatabase getSubjectOfRoom: aMessage._roomID];
        if (![subject isEqualToString: @""]) {
            [cell._lbTitle setText: subject];
        }else{
            [cell._lbTitle setText: aMessage._roomID];
        }
    }else{
        if ([aMessage._contactAvatar isEqualToString:@""] || [aMessage._contactAvatar isEqualToString:@"<null>"] || [aMessage._contactAvatar isEqualToString:@"(null)"] || [aMessage._contactAvatar isEqualToString:@"null"]){
            [cell._iconAvatar setImage: [UIImage imageNamed:@"no_avatar.png"]];
            
        }else{
            NSData *avatarData = [NSData dataFromBase64String: aMessage._contactAvatar];
            [cell._iconAvatar setImage: [UIImage imageWithData: avatarData]];
        }
        
        if ([aMessage._contactName isEqualToString:@""]) {
            [cell._lbTitle setText: aMessage._user];
        }else{
            [cell._lbTitle setText: aMessage._contactName];
        }
        
        // Kiểm tra contact có đang bị block hay ko?
        BOOL contactBlock = [NSDatabase checkContactInBlackList: aMessage._idObject andCloudfoneID: aMessage._user];
        if (contactBlock) {
            [cell._imgBlock setHidden: false];
        }else{
            [cell._imgBlock setHidden: true];
        }
        [cell set_cloudFoneID: aMessage._user];
        [cell set_idContact: aMessage._idObject];
    }
    
    // Tin nhắn recall
    if (aMessage._isRecall) {
        if (aMessage._isSent) {
            [cell._lbContent setText: [appDelegate.localization localizedStringForKey:text_message_sent_recall]];
        }else{
            [cell._lbContent setText: [appDelegate.localization localizedStringForKey:text_message_received_recall]];
        }
    }else{
        // Hiển thị emoticon nếu có
        NSString *firstEmotion;
        
        NSError *error = nil;
        regex = [NSRegularExpression regularExpressionWithPattern:@"e[0-9]_[0-9]{3}" options:NSRegularExpressionCaseInsensitive error:&error];
        rangeOfFirstMatch = [regex rangeOfFirstMatchInString:aMessage._lastMessage options:0 range:NSMakeRange(0, [aMessage._lastMessage length])];
        
        if ([aMessage._typeMessage isEqualToString: imageMessage]) {
            if (aMessage._isSent) {
                [cell._lbContent setText:[appDelegate.localization localizedStringForKey:text_image_message_sent]];
            }else{
                [cell._lbContent setText:[appDelegate.localization localizedStringForKey:text_message_image_received]];
            }
        }else if ([aMessage._typeMessage isEqualToString:locationMessage])
        {
            [cell._lbContent setText: [appDelegate.localization localizedStringForKey:text_message_location]];
        }else if ([aMessage._typeMessage isEqualToString: contactMessage])
        {
            [cell._lbContent setText: [appDelegate.localization localizedStringForKey:text_contact_message]];
        }else if ([aMessage._typeMessage isEqualToString: typeTextMessage])
        {
            NSMutableString *attributedString = [[NSMutableString alloc] initWithString: aMessage._lastMessage];
            while (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
                firstEmotion = [attributedString substringWithRange:rangeOfFirstMatch];
                NSString *emoji = [self getEmojiWithEmotionName: firstEmotion];
                [attributedString replaceCharactersInRange:rangeOfFirstMatch withString:emoji];
                regex = [NSRegularExpression regularExpressionWithPattern:@"e[0-9]_[0-9]{3}" options:NSRegularExpressionCaseInsensitive error:&error];
                rangeOfFirstMatch = [regex rangeOfFirstMatchInString:attributedString options:0 range:NSMakeRange(0, [attributedString length])];
            }
            [cell._lbContent setText: attributedString];
        }else if ([aMessage._typeMessage isEqualToString: audioMessage])
        {
            if (aMessage._isSent) {
                [cell._lbContent setText:[appDelegate.localization localizedStringForKey:text_audio_message_sent]];
            }else{
                [cell._lbContent setText:[appDelegate.localization localizedStringForKey:text_audio_message_received]];
            }
        }else if ([aMessage._typeMessage isEqualToString: videoMessage])
        {
            if (aMessage._isSent) {
                [cell._lbContent setText:[appDelegate.localization localizedStringForKey:text_video_message_sent]];
            }else{
                [cell._lbContent setText:[appDelegate.localization localizedStringForKey:text_video_message_received]];
            }
        }else if ([aMessage._typeMessage isEqualToString: descriptionMessage]){
            [cell._lbContent setText: aMessage._lastMessage];
        }
    }
    
    // set up ngày giờ
    if ([aMessage._date isEqualToString:[AppUtils getCurrentDate]]) {
        [cell._lbTime setText: aMessage._time];
        [cell._lbTime setFont: [AppUtils fontRegularWithSize: 13.0]];
    }else{
        [cell._lbTime setText: [NSString stringWithFormat:@"%@ %@", aMessage._date, aMessage._time]];
        [cell._lbTime setFont: [AppUtils fontRegularWithSize: 13.0]];
    }
    
    // Message chưa đọc
    if (aMessage._unreadMsg != 0) {
        [cell._iconUnread setTitle:[NSString stringWithFormat:@"%d", aMessage._unreadMsg]
                          forState:UIControlStateNormal];
        [cell._iconUnread setHidden: false];
    }else{
        [cell._iconUnread setHidden: true];
    }
    
    // Image status của contact
    int status = [NSDatabase getStatusNumberOfUserOnList: aMessage._user];
    switch (status) {
        case -1:{
            [cell._imgState setImage:[UIImage imageNamed:@"ic_offline.png"]];
            
            [cell._imgState setTag: indexPath.row];
            break;
        }
        case kOTRBuddyStatusOffline:{
            [cell._imgState setImage:[UIImage imageNamed:@"ic_offline.png"]];
            break;
        }
        default:{
            [cell._imgState setImage:[UIImage imageNamed:@"ic_online.png"]];
            break;
        }
    }
    [cell setFrame: CGRectMake(cell.frame.origin.x, cell.frame.origin.y, _tbMessage.frame.size.width, hCell)];
    if (isDelete) {
        [cell showDeleteViewForCell];
    }else{
        [cell updateUIForCell];
    }
    
    if (cell._isGroup) {
        [cell._iconAvatar.layer setCornerRadius: 0];
    }else{
        [cell._iconAvatar.layer setCornerRadius: (hCell-14)/2];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return hCell;
}

//  Reload lại dữ liệu sau khi chọn mark unread message
- (void)reloadHistoryMessageForView {
    //  Get lịch sử tin nhắn với user
    [self getMessageHistoryOfUser: USERNAME];
    [_tbMessage reloadData];
}

#pragma mark - HÀM XỬ LÝ KHI TOUCH VÀO MESSAGE
//  Hiển thị popup thêm mới contact
- (void)showPopupAddNewContact: (NSNotification *)notif
{
    if ([[[PhoneMainView instance] currentView] isEqual:[KMessageViewController compositeViewDescription]]) {
        id object = [notif object];
        if ([object isKindOfClass:[NSString class]])
        {
            
        }
    }
}

//  Load lại nội dung sau khi xoá 1 conversation
- (void)deleteConversationAccepted {
    //  Get lịch sử tin nhắn với user
    [self getMessageHistoryOfUser: USERNAME];
    [_tbMessage reloadData];
    
    if (listHistoryMessage.count == 0) {
        [_tbMessage setHidden: true];
    }else {
        [_tbMessage setHidden: false];
        [_tbMessage reloadData];
    }
}

//  Cập nhật lại roster list
- (void)buddyListUpdate {
    if (![[[OTRProtocolManager sharedInstance] buddyList] allBuddies]) {
        return;
    }
    [_tbMessage reloadData];
}

//  Cập nhật table khi có message mới đến
- (void)messageReceived:(NSNotification*)notification
{
    OTRMessage *message = [notification.userInfo objectForKey:@"message"];
    NSString *typeMessage = [notification.userInfo objectForKey:@"typeMessage"];
    
    OTRBuddy *buddy = message.buddy;
    NSString *userStr = @"";
    
    if (buddy != nil) {
        userStr = [AppUtils getSipFoneIDFromString: buddy.accountName];
    }else{
        userStr = [notification.userInfo objectForKey:@"user"];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_user CONTAINS[cd] %@", userStr];
    NSArray *resultArr = [listHistoryMessage filteredArrayUsingPredicate: predicate];
    if (resultArr.count > 0) {
        ConversationObject *aConversation = [resultArr objectAtIndex: 0];
        [listHistoryMessage removeObject: aConversation];
        
        if ([typeMessage isEqualToString: typeTextMessage]) {
            aConversation._lastMessage = message.message;
        }else if ([typeMessage isEqualToString: locationMessage]){
            aConversation._lastMessage = [appDelegate.localization localizedStringForKey:text_message_location];
        }else if ([typeMessage isEqualToString:imageMessage]){
            aConversation._lastMessage = [appDelegate.localization localizedStringForKey:text_message_image_received];
        }else if ([typeMessage isEqualToString: audioMessage]){
            aConversation._lastMessage = [appDelegate.localization localizedStringForKey:text_audio_message_received];
        }else if ([typeMessage isEqualToString: videoMessage]){
            aConversation._lastMessage = [appDelegate.localization localizedStringForKey:text_video_message_received];
        }
        
        aConversation._unreadMsg = aConversation._unreadMsg + 1;
        aConversation._typeMessage = typeMessage;
        aConversation._isSent = FALSE;
        aConversation._isRecall = FALSE;
        aConversation._date = [AppUtils getCurrentDate];
        aConversation._time = [AppUtils getCurrentTime];
        
        [listHistoryMessage insertObject:aConversation atIndex:0];
    }else{
        ConversationObject *aConversation = [[ConversationObject alloc] init];
        aConversation._user = userStr;
        aConversation._roomID = @"";
        aConversation._messageDraf = @"";
        if ([typeMessage isEqualToString: typeTextMessage]) {
            aConversation._lastMessage = message.message;
        }else if ([typeMessage isEqualToString: locationMessage]){
            aConversation._lastMessage = [appDelegate.localization localizedStringForKey:text_message_location];
        }else if ([typeMessage isEqualToString: imageMessage]){
            aConversation._lastMessage = [appDelegate.localization localizedStringForKey:text_message_image_received];
        }else if ([typeMessage isEqualToString: audioMessage]){
            aConversation._lastMessage = [appDelegate.localization localizedStringForKey:text_audio_message_received];
        }
        
        aConversation._typeMessage = typeMessage;
        aConversation._isSent = FALSE;
        aConversation._isRecall = FALSE;
        aConversation._date = [AppUtils getCurrentDate];
        aConversation._time = [AppUtils getCurrentTime];
        
        aConversation._contactName = [NSDatabase getNameOfContactWithPhoneNumber: userStr];
        aConversation._contactAvatar = [NSDatabase getAvatarOfContactWithPhoneNumber:userStr];
        
        aConversation._idObject = [NSDatabase getContactIDWithCloudFoneID: userStr];
        aConversation._unreadMsg = 1;
        [listHistoryMessage insertObject:aConversation atIndex:0];
    }
    
    if (listHistoryMessage.count > 0) {
        [_tbMessage setHidden: false];
        [_tbMessage reloadData];
        [_lbNoMsg setHidden: true];
    }else{
        [_tbMessage setHidden: true];
        [_lbNoMsg setHidden: false];
    }
}

//  THÊM AUDIO MESSAGE VỪA NHẬN TỪ USER
- (void)receiveAudioMessage: (NSNotification *)notif
{
    id object = [notif object];
    if ([object isKindOfClass:[NSString class]]) {
        NSString *userStr = (NSString *)object;
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_user CONTAINS[cd] %@", userStr];
            NSArray *resultArr = [listHistoryMessage filteredArrayUsingPredicate: predicate];
            
            if (resultArr.count > 0) {
                ConversationObject *aConversation = [resultArr objectAtIndex: 0];
                [listHistoryMessage removeObject: aConversation];
                aConversation._lastMessage = k11AudioReceivedOnMessageHistory;
                aConversation._unreadMsg = aConversation._unreadMsg + 1;
                [listHistoryMessage insertObject:aConversation atIndex:0];
            }else{
                ConversationObject *aConversation = [[ConversationObject alloc] init];
                aConversation._user = userStr;
                aConversation._roomID = @"";
                aConversation._messageDraf = @"";
                aConversation._lastMessage = k11AudioReceivedOnMessageHistory;
                
                NSArray *infos = [NSDatabase getContactNameOfCloudFoneID:userStr];
                
                aConversation._contactName = [infos objectAtIndex: 0];
                aConversation._contactAvatar = [infos objectAtIndex: 1];
                aConversation._unreadMsg = 1;
                [listHistoryMessage insertObject:aConversation atIndex:0];
            }
            [_tbMessage setHidden: false];
            [_tbMessage reloadData];
        }
        [_tbMessage setHidden: false];
        [_tbMessage reloadData];
    }
}

//  cập nhật tên của phòng chat
- (void)changeGroupNameOfRoom: (NSNotification *)notif {
    if ([[[PhoneMainView instance] currentView] isEqual:[self compositeViewDescription]]) {
        [_tbMessage reloadData];
    }
}

//  Get lịch sử tin nhắn
- (void)updateAllMessageUnreadInHistory {
    /*  Leo Kelvin
    [listHistoryMessage removeAllObjects];
    [listHistoryMessage addObjectsFromArray:[NSDatabase getAllConversationForHistoryMessageOfUser]];
    
    if (listHistoryMessage.count == 0) {
        [_tbMessage setHidden: TRUE];
    }else{
        [_tbMessage setHidden: FALSE];
        [_tbMessage reloadData];
    }
    */
}

#pragma mark - UISearchBar Delegate Methods

- (void)onTextfieldDidChanged: (UITextField *)textField
{
    if ([textField.text length] == 0) {
        [_lbSearch setHidden: false];
        [_iconClear setHidden: true];
        isFiltered = false;
    }else{
        [_lbSearch setHidden: true];
        
        [_iconClear setHidden: daylight];
        isFiltered = true;
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"_user CONTAINS[cd] %@ OR _contactName CONTAINS[cd] %@", textField.text, textField.text];
        NSArray *tempArray = [listHistoryMessage filteredArrayUsingPredicate:predicate];
        listFilterd = [[NSMutableArray alloc] init];
        [listFilterd addObjectsFromArray: tempArray];
    }
    [_tbMessage reloadData];
}

#pragma mark - MY FUNCTIONS

//  Get lịch sử tin nhắn
- (void)getMessageHistoryOfUser: (NSString *)cloudFoneID {
    //  Get lịch sử tin nhắn với user
    if (listHistoryMessage == nil) {
        listHistoryMessage = [[NSMutableArray alloc] init];
    }
    [listHistoryMessage removeAllObjects];
    [listHistoryMessage addObjectsFromArray:[NSDatabase getAllConversationForHistoryMessageOfUser: cloudFoneID]];
    [listHistoryMessage addObjectsFromArray:[NSDatabase getAllConversationForGroupOfUser]];
    
    //  Sort lịch sử tin nhắn theo thời gian
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"_idMessage" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSArray *resultSort = [listHistoryMessage sortedArrayUsingDescriptors:sortDescriptors];
    [listHistoryMessage removeAllObjects];
    [listHistoryMessage addObjectsFromArray: resultSort];
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

//  CẬP NHẬT LỊCH SỬ TIN NHẮN KHI XOÁ EXPIRE
- (void)updateViewChatHistoryAfterExpire{
    [_tbMessage reloadData];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing: true];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self.view endEditing: true];
}

- (NSString *)getEmojiWithEmotionName: (NSString *)emotionCode
{
    NSString *result = @"";
    if (emotionCode.length > 2) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"code = %@", emotionCode];
        NSArray *filter = nil;
        NSString *typeList = [emotionCode substringWithRange: NSMakeRange(1, 1)];
        switch ([typeList intValue]) {
            case 1: {
                filter = [appDelegate._listFace filteredArrayUsingPredicate: predicate];
                break;
            }
            case 2:{
                filter = [appDelegate._listNature filteredArrayUsingPredicate: predicate];
                break;
            }
            case 3:{
                filter = [appDelegate._listObject filteredArrayUsingPredicate: predicate];
                break;
            }
            case 4:{
                filter = [appDelegate._listPlace filteredArrayUsingPredicate: predicate];
                break;
            }
            case 5:{
                filter = [appDelegate._listSymbol filteredArrayUsingPredicate: predicate];
                break;
            }
            default:
                break;
        }
        
        if (filter.count > 0) {
            NSDictionary *dict = [filter objectAtIndex: 0];
            NSString *k11Str = [dict objectForKey:@"u_code"];
            NSString *totalStr = [NSString stringWithFormat:@"{\"emoji\":\"%@\"}", k11Str];
            const char *jsonString = [totalStr UTF8String];
            
            NSData *jsonData = [NSData dataWithBytes:jsonString length:strlen(jsonString)];
            NSError *error;
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
            result = [jsonDict objectForKey:@"emoji"];
        }
    }
    return result;
}

#pragma mark - UITextField Delegate & ScrollView Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return true;
}

- (IBAction)_btnDeletePressed:(UIButton *)sender {
    
}

- (IBAction)_btnDonePressed:(UIButton *)sender {
    if (listDelete.count > 0) {
        //  Xoá tin nhắn đã chọn
        for (int iCount=0; iCount<listDelete.count; iCount++) {
            NSString *user = [listDelete objectAtIndex: iCount];
            if ([user hasPrefix:@"778899"] && user.length <= 11) {
                [NSDatabase deleteConversationOfMeWithUser: user];
            }else{
                [NSDatabase deleteConversationOfMeWithRoomChat: user];
            }
        }
        //  Get lại danh sách tin nhắn
        [self getMessageHistoryOfUser: USERNAME];
    }
    
    if (listDelete != nil) {
        [listDelete removeAllObjects];
    }
    
    isDelete = false;
    [self showOrHideDeleteView];
    [_tbMessage reloadData];
}

- (IBAction)_btnNewMsgPressed:(UIButton *)sender {
    ChooseContactsViewController *controller = VIEW(ChooseContactsViewController);
    if (controller != nil) {
        controller._isForwardMessage = NO;
        controller._idForwardMessage = @"";
    }
    [[PhoneMainView instance] changeCurrentView:[ChooseContactsViewController compositeViewDescription] push:true];
}

@end
