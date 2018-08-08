//
//  GroupChatViewController.m
//  linphone
//
//  Created by Ei Captain on 7/12/16.
//
//

#import "GroupChatViewController.h"
#import "GroupMainChatViewController.h"
#import "AddParticientsViewController.h"
#import "BackgroundViewController.h"
#import "PhoneMainView.h"
#import "EmotionView.h"
#import "ChatPhotosView.h"
#import "NSDatabase.h"
#import "OTRMessage.h"
#import "UIImageView+WebCache.h"
#import "KMessageViewController.h"
#import "JSONKit.h"
#import "ShowPictureViewController.h"

@interface GroupChatViewController (){
    SWRevealViewController *revealVC;
    
    LinphoneAppDelegate *appDelegate;
    UIFont *textFont;
    
    float hChatBox;
    float hKeyboard;
    
    UILabel *lbPlaceHolder;
    
    NSString *roomName;
    
    CGRect firstChatBox;
    
    // Emotion View
    EmotionView *viewEmotion;
    float hViewEmotion;
    float hTabEmotion;
    
    // Photos View
    ChatPhotosView *viewPhotos;
    float hViewPhoto;
    
    NSString *resultMessage;
    
    // View thông báo khi có new message đến
    UIView *viewNewMsg;
    
    NSDictionary *roomInfo;
    
    UILabel *lbChatComposing;
    
    HMLocalization *localization;
    int codeUpload;
    NSMutableData *uploadData;
    
    UIView *messageView;
    UILabel *lbMessage;
    
    NSMutableData *sendMsgData;
    
    NSTimer *expireTimer;
    int expireTime;
    
    NSString *idMsgImage;
    NSString *thumbURL;
    NSString *detailURL;
    
    UILabel *bgStatus;
}

@end

@implementation GroupChatViewController
@synthesize _viewHeader, _iconBack, _iconStatus, _lbGroupName, _iconSetting;
@synthesize _bgChat, _viewChat, _tbChat;
@synthesize _viewFooter, _iconEmotion, _iconPhoto, _tvMessage, _iconSend, _icCamera;
@synthesize _listHistoryMessage, _lbNoMessage;

#pragma mark - My controller

//  View không bị thay đổi sau khi vào pickerview controller
- (void)viewDidLayoutSubviews {
    if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        CGRect viewBounds = self.view.bounds;
        CGFloat topBarOffset = self.topLayoutGuide.length;
        viewBounds.origin.y = topBarOffset * -1;
        self.view.bounds = viewBounds;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //  MY CODE HERE
    appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    localization = [HMLocalization sharedInstance];
    
    revealVC = [self revealViewController];
    [revealVC panGestureRecognizer];
    [revealVC tapGestureRecognizer];
    
    hKeyboard       =   0;
    
    [self setupUIForView];
    
    bgStatus = [[UILabel alloc] initWithFrame: CGRectMake(0, -20, SCREEN_WIDTH, 20)];
    [bgStatus setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview: bgStatus];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //  Tắt màn hình cảm biến
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled: false];
    
    // Nếu login thất bại thì login lại
    if (!appDelegate.xmppStream.isConnected) {
        [AppUtils reconnectToXMPPServer];
    }
    
    // Placeholder custom cho chatbox message
    if (_tvMessage.text.length == 0) {
        [lbPlaceHolder setHidden: false];
    }else{
        [lbPlaceHolder setHidden: true];
    }
    
    // Add sự kiện double click vào màn hình để change background
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapToChangeBackground)];
    [doubleTap setNumberOfTapsRequired: 2];
    [doubleTap setNumberOfTouchesRequired: 1];
    [_viewChat addGestureRecognizer:doubleTap];
    
    // Lấy lịch sử tin nhắn
    roomName = [[NSString alloc] initWithString:[NSDatabase getRoomNameOfRoomWithRoomId:appDelegate.idRoomChat]];
    
    //  Lấy background đã được lưu cho room chat
    NSString *linkBgChat = [NSDatabase getChatBackgroundForRoom:[NSString stringWithFormat:@"%d", appDelegate.idRoomChat]];
    if ([linkBgChat isEqualToString: @""] || linkBgChat == nil) {
        [_bgChat setImage:[UIImage imageNamed:@"bg_chat_default.jpg"]];
    }else{
        [_bgChat sd_setImageWithURL:[NSURL URLWithString: linkBgChat]
                   placeholderImage:[UIImage imageNamed:@"bg_chat_default.jpg"]];
    }
    
    // Setup more view về lại trạng thái ban đầu
    [self dismissKeyboard];
    
    // set label placeholder cho expire time
    [self setExpireTimeLabelWithExpireTime: expireTime];
    
    //  Get lịch sử tin nhắn của room
    if (appDelegate.reloadMessageList) {
        [self getHistoryMessagesOfRoom: appDelegate.idRoomChat];
        [self updateFrameOfViewChatWithViewFooter];
    }
    
    [self setHeaderInfomationOfUser];
    
    //  Bắt đầu xoá tin nhắn expire
    [self startAllExpireMessageOfMe];
    
    //  user tham gia vao phong chat
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenUserJoinToRoomChat:)
                                                 name:userJoinToRoom object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenUserLeaveRoomChat:)
                                                 name:updateListMemberInRoom object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setContentForMessageTextView:)
                                                 name:mapContentForMessageTextView object:nil];
    
    //  notitications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWhenShowKeyboard:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getChatMessageTextViewInfo)
                                                 name:getTextViewMessageChatInfo object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNewRoomChatMessage:)
                                                 name:k11ReceivedRoomChatMessage object:nil];
    
    //  Subject của room chat đc thay đổi
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenSubjectOfRoomChanged:)
                                                 name:k11SubjectOfRoomChanged object:nil];
    
    //  Xoá tất cả tin nhắn
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteAllMessageOfRoomChat)
                                                 name:k11DeleteAllMessageAccept object:nil];
    
    //  Cập nhật tên mới của room nếu có thay đổi
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeGroupNameOfRoom:)
                                                 name:k11UpdateNewGroupName object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeRightChatView)
                                                 name:closeRightChatGroupVC object:nil];
    
    //  Touch vào màn hình chat để đóng bàn phím
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissKeyboard)
                                                 name:k11DismissKeyboardInViewChat object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateReceiveMessage:)
                                                 name:updateDeliveredChat object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteConversationSuccess)
                                                 name:whenDeleteConversationInChatView object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadListMessageForRoomChat)
                                                 name:@"reloadListMessageForRoomChat" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processWhenRoomDestroyed:)
                                                 name:whenRoomDestroyed object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:userJoinToRoom
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:updateListMemberInRoom
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:mapContentForMessageTextView
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:getTextViewMessageChatInfo
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k11ReceivedRoomChatMessage
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k11SubjectOfRoomChanged
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k11DeleteAllMessageAccept
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k11UpdateNewGroupName
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:closeRightChatGroupVC
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k11DismissKeyboardInViewChat
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:updateDeliveredChat
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:whenDeleteConversationInChatView
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadListMessageForRoomChat"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:whenRoomDestroyed
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)_iconBackClicked:(id)sender {
    [appDelegate setIdRoomChat: 0];
    [appDelegate setReloadMessageList: true];
    
    [[PhoneMainView instance] changeCurrentView:[KMessageViewController compositeViewDescription]];
    //  [[PhoneMainView instance] popCurrentView];
}

- (IBAction)_iconSettingClicked:(id)sender
{
    //  Gán giá trị của room chat
    [appDelegate setIdRoomChat: appDelegate.idRoomChat];
    
    AddParticientsViewController *controller = VIEW(AddParticientsViewController);
    if (controller != nil) {
        [controller updateValueForController: true];
    }
    [[PhoneMainView instance] changeCurrentView: [AddParticientsViewController compositeViewDescription] push: true];
}

- (IBAction)_iconEmotionClicked:(id)sender {
    [self.view endEditing: true];
    
    if (viewEmotion == nil) {
        [self addEmotionViewForViewChat];
    }
    
    if (viewEmotion.frame.size.height == 0) {
        [_iconEmotion setSelected: true];
        [_iconPhoto setSelected: false];
        
        if (viewPhotos.frame.size.height > 0) {
            [viewPhotos setAlpha: 0.0];
            [viewEmotion setAlpha: 1.0];
            
            [viewEmotion setFrame: CGRectMake(viewEmotion.frame.origin.x, SCREEN_HEIGHT-(appDelegate._hStatus+hViewEmotion), viewEmotion.frame.size.width, hViewEmotion)];
            [_viewFooter setFrame: CGRectMake(_viewFooter.frame.origin.x, viewEmotion.frame.origin.y-_viewFooter.frame.size.height, _viewFooter.frame.size.width, _viewFooter.frame.size.height)];
            
            //  View footer thay đổi thì thay đổi view chat
            [self updateFrameOfViewChatWithViewFooter];
        }else{
            [UIView animateWithDuration:0.2 animations:^{
                [viewEmotion setFrame: CGRectMake(viewEmotion.frame.origin.x, SCREEN_HEIGHT-(appDelegate._hStatus+hViewEmotion), viewEmotion.frame.size.width, hViewEmotion)];
                
                [_viewFooter setFrame: CGRectMake(_viewFooter.frame.origin.x, viewEmotion.frame.origin.y-_viewFooter.frame.size.height, _viewFooter.frame.size.width, _viewFooter.frame.size.height)];
                
                //  View footer thay đổi thì thay đổi view chat
                [self updateFrameOfViewChatWithViewFooter];
            }];
        }
    }else{
        if (_iconEmotion.isSelected) {
            [UIView animateWithDuration:0.2 animations:^{
                [viewEmotion setFrame: CGRectMake(viewEmotion.frame.origin.x, SCREEN_HEIGHT-appDelegate._hStatus, viewEmotion.frame.size.width, 0)];
                [viewPhotos setFrame: CGRectMake(viewPhotos.frame.origin.x, SCREEN_HEIGHT-appDelegate._hStatus, viewPhotos.frame.size.width, 0)];
                [_viewFooter setFrame: CGRectMake(_viewFooter.frame.origin.x, viewEmotion.frame.origin.y-_viewFooter.frame.size.height, _viewFooter.frame.size.width, _viewFooter.frame.size.height)];
                
                //  View footer thay đổi thì thay đổi view chat
                [self updateFrameOfViewChatWithViewFooter];
                
            }completion:^(BOOL finished) {
                [viewEmotion setAlpha: 1.0];
                [viewPhotos setAlpha: 1.0];
            }];
        }else{
            [viewEmotion setAlpha: 1.0];
            [_iconEmotion setSelected: true];
            
            [viewPhotos setAlpha: 0.0];
            [_iconPhoto setSelected: false];
        }
    }
}

- (IBAction)_iconPhotoClicked:(UIButton *)sender {
    [self.view endEditing: true];
    
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    [self presentViewController:pickerController animated:YES completion:nil];
    
    /*  Leo Kelvin
    if (viewPhotos == nil) {
        [self addViewPhotosForViewChat];
    }
    [viewPhotos getListGroupsPhotos];
    
    if (viewPhotos.frame.size.height == 0)
    {
        [_iconPhoto setSelected: true];
        [_iconEmotion setSelected: false];
        
        if (viewEmotion.frame.size.height > 0) {
            [viewEmotion setAlpha: 0.0];
            [viewPhotos setAlpha: 1.0];
            
            [viewPhotos setFrame: CGRectMake(viewPhotos.frame.origin.x, SCREEN_HEIGHT-(appDelegate._hStatus+hViewPhoto), viewPhotos.frame.size.width, hViewPhoto)];
            [_viewFooter setFrame: CGRectMake(_viewFooter.frame.origin.x, viewPhotos.frame.origin.y-_viewFooter.frame.size.height, _viewFooter.frame.size.width, _viewFooter.frame.size.height)];
            
            //  View footer thay đổi thì thay đổi view chat
            [self updateFrameOfViewChatWithViewFooter];
        }else{
            [UIView animateWithDuration:0.2 animations:^{
                [viewPhotos setFrame: CGRectMake(viewPhotos.frame.origin.x, SCREEN_HEIGHT-(appDelegate._hStatus+hViewPhoto), viewPhotos.frame.size.width, hViewPhoto)];
                
                [_viewFooter setFrame: CGRectMake(_viewFooter.frame.origin.x, viewPhotos.frame.origin.y-_viewFooter.frame.size.height, _viewFooter.frame.size.width, _viewFooter.frame.size.height)];
                
                //  View footer thay đổi thì thay đổi view chat
                [self updateFrameOfViewChatWithViewFooter];
            }];
        }
    }else{
        if (_iconPhoto.isSelected) {
            [UIView animateWithDuration:0.2 animations:^{
                [viewPhotos setFrame: CGRectMake(viewPhotos.frame.origin.x, SCREEN_HEIGHT-appDelegate._hStatus, viewPhotos.frame.size.width, 0)];
                [viewEmotion setFrame: CGRectMake(viewEmotion.frame.origin.x, SCREEN_HEIGHT-appDelegate._hStatus, viewEmotion.frame.size.width, 0)];
                [_viewFooter setFrame: CGRectMake(_viewFooter.frame.origin.x, viewPhotos.frame.origin.y-_viewFooter.frame.size.height, _viewFooter.frame.size.width, _viewFooter.frame.size.height)];
                
                //  View footer thay đổi thì thay đổi view chat
                [self updateFrameOfViewChatWithViewFooter];
            }completion:^(BOOL finished) {
                [viewPhotos setAlpha: 1.0];
                [viewEmotion setAlpha: 1.0];
            }];
            [_iconPhoto setSelected: false];
        }else{
            [viewPhotos setAlpha: 1.0];
            [_iconPhoto setSelected: true];
            
            [viewEmotion setAlpha: 0.0];
            [_iconEmotion setSelected: false];
        }
    }
    */
}

- (IBAction)_icCameraClicked:(UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    [picker setDelegate: self];
    [picker setSourceType: UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)_iconSendClicked:(id)sender
{
    NSString *idMessage = [AppUtils randomStringWithLength: 15];
    NSString *contentMessage = [_tvMessage text];
    [appDelegate.myBuddy.protocol sendMessageWithContent:_tvMessage.text ofMe:USERNAME
                                                 toGroup:roomName withIdMessage:idMessage];
    int delivered = 0;
    if (appDelegate.xmppStream.isConnected) {
        delivered = 1;
    }
    
    [NSDatabase saveMessage:USERNAME toPhone:USERNAME withContent:contentMessage andStatus:YES withDelivered:delivered andIdMsg:idMessage detailsUrl:@"" andThumbUrl:@"" withTypeMessage:typeTextMessage andExpireTime:expireTime andRoomID:[NSString stringWithFormat:@"%d", appDelegate.idRoomChat] andExtra:nil andDesc:nil];
    
    //  push message
    sendMsgData = nil;
    [self sendMessageOfflineForGroupFromSender:USERNAME
                                   withContent:_tvMessage.text
                                andTypeMessage:@"text"
                                   withGroupID:roomName];
    
    NSBubbleData *aMessage = [[NSBubbleData alloc] initWithText:_tvMessage.text type:BubbleTypeMine time:[AppUtils getCurrentTime] status:2 idMessage:idMessage withExpireTime:expireTime isRecall:@"NO" description:@"" withTypeMessage:typeTextMessage isGroup:NO ofUser:nil];
    [_listHistoryMessage addObject: aMessage];
    
    
    // setup các UI
    [_lbNoMessage setHidden: true];
    [_tvMessage setText:@""];
    [_tvMessage setScrollEnabled: false];
    [lbPlaceHolder setHidden: false];
    
    // Hiển thị tin nhắn và scroll xuống dòng cuối
    [self updateAllFrameForController: true];
    [self updateAndGotoLastViewChat];
    [_tvMessage setFrame: CGRectMake(_tvMessage.frame.origin.x, 3, _tvMessage.frame.size.width, hChatBox-6)];
}

#pragma mark - MY FUNCTIONS

//  Nếu phòng hiện tại bị huỷ
- (void)processWhenRoomDestroyed: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[NSString class]]) {
        if ([object isEqualToString: roomName]) {
            [[PhoneMainView instance] popCurrentView];
        }
    }
}


- (void)reloadListMessageForRoomChat {
    //  Get lịch sử tin nhắn của room
    [self getHistoryMessagesOfRoom: appDelegate.idRoomChat];
    [self updateFrameOfViewChatWithViewFooter];
    
    if (_listHistoryMessage.count > 0) {
        [_lbNoMessage setHidden: true];
    }else{
        [_lbNoMessage setHidden: false];
    }
    
}

- (void)deleteConversationSuccess {
    if (_listHistoryMessage == nil) {
        _listHistoryMessage = [[NSMutableArray alloc] init];
    }else{
        [_listHistoryMessage removeAllObjects];
    }
    [_tbChat reloadData];
    appDelegate._heightChatTbView = 0.0;
    [_lbNoMessage setHidden: false];
}

//  Cập nhật trạng thái của message sau khi nhận delivered text message
- (void)updateReceiveMessage: (NSNotification *)notif
{
    id object = [notif object];
    if ([object isKindOfClass:[NSString class]]) {
        NSString *idMessage = (NSString *)object;
        [NSDatabase updateMessageDelivered: idMessage withValue:2];
        NSBubbleData *dataMessage = [NSDatabase getDataOfMessage: idMessage];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"idMessage = %@", idMessage];
        NSArray *updateData = [_listHistoryMessage filteredArrayUsingPredicate: predicate];
        if (updateData.count > 0) {
            int replaceIndex = (int)[_listHistoryMessage indexOfObject: [updateData objectAtIndex: 0]];
            [_listHistoryMessage replaceObjectAtIndex:replaceIndex withObject:dataMessage];
            [_tbChat reloadData];
        }
        if (dataMessage.expireTime > 0) {
            [self startAllExpireMessageOfMe];
        }
    }
}

//  Bắt đầu cập nhật các tin nhắn expire
- (void)startAllExpireMessageOfMe {
    expireTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self
                                                 selector:@selector(deleteAllMessageExpiredOfMeInGroup)
                                                 userInfo:nil
                                                  repeats:YES];
}

//  Xoá tất cả tin nhắn đã hết hạn
- (void)deleteAllMessageExpiredOfMeInGroup
{
    // danh sách tất cả các msg hết hạn
    int RoomID = [NSDatabase getIdRoomChatWithRoomName: roomName];
    
    int number = 0;
    if (number == 0) {
        [expireTimer invalidate];
        expireTimer = nil;
    }else{
        NSArray *listRemove = [NSDatabase getAllMessageExpireEndedOfMeWithGroup: RoomID];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"idMessage IN %@", listRemove];
        NSArray *rs = [_listHistoryMessage filteredArrayUsingPredicate:predicate];
        if (rs.count > 0) {
            for (int iCount=0; iCount<rs.count; iCount++) {
                NSBubbleData *data = [rs objectAtIndex: iCount];
                [_listHistoryMessage removeObject: data];
            }
            [_tbChat reloadData];
            [self updateAllFrameForController: false];
    
        }
    }
    if (_listHistoryMessage.count > 0) {
        [_lbNoMessage setHidden: true];
    }else{
        [_lbNoMessage setHidden: false];
    }
}

//  Double click vào màn hình để change background
- (void)doubleTapToChangeBackground {
    BackgroundViewController *backgroudVC = VIEW(BackgroundViewController);
    if (backgroudVC != nil) {
        [backgroudVC set_chatGroup: true];
    }
    [[PhoneMainView instance] changeCurrentView: [BackgroundViewController compositeViewDescription] push: true];
}

//  Gán content sau khi click vào emotion
- (void)setContentForMessageTextView: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[NSMutableString class]]) {
        [_tvMessage setText: object];
        [self setupWhenClickOnEmotionClicked];
    }
}

//  Cập nhật vị trí các UI khi click vào emotion
- (void)setupWhenClickOnEmotionClicked {
    if (_tvMessage.text.length > 0) {
        [lbPlaceHolder setHidden: true];
    }else{
        [lbPlaceHolder setHidden: false];
    }
    
    //  Send compositing
    if (_tvMessage.text.length == 1) {
        [(OTRXMPPAccount *)[appDelegate.friendBuddy.protocol account] setSendTypingNotifications: YES];
        [appDelegate.friendBuddy sendComposingChatState];
    }
    
    if ([_tvMessage text].length > 0) {
        CGFloat fixedWidth = 200;
        CGSize newSize = [_tvMessage sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        CGRect newFrame = [_tvMessage frame];
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
        [_tvMessage setFrame: newFrame];
        
        [_viewFooter setFrame: CGRectMake(firstChatBox.origin.x, viewEmotion.frame.origin.y-_tvMessage.frame.size.height-6, firstChatBox.size.width, _tvMessage.frame.size.height+6)];
        
        //  Cập nhật vị trí view chat theo view footer
        [self updateFrameOfViewChatWithViewFooter];
    }
}

// Get thông tin chat message textview
- (void)getChatMessageTextViewInfo {
    int curLocation = (int)_tvMessage.selectedRange.location;
    NSMutableString *curTextMessage = [[NSMutableString alloc] initWithString: _tvMessage.text];
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:curLocation],@"location", curTextMessage,@"message", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:getContentChatMessageViewInfo
                                                        object:infoDict];
}

//  Khi show bàn phím chat
- (void)notificationWhenShowKeyboard:(NSNotification*)notification {
    if (hKeyboard == 0) {
        NSDictionary* keyboardInfo = [notification userInfo];
        NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
        CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
        hKeyboard = keyboardFrameBeginRect.size.height;
    }
    
    [viewEmotion setFrame: CGRectMake(viewEmotion.frame.origin.x, SCREEN_HEIGHT-appDelegate._hStatus, viewEmotion.frame.size.width, 0)];
    [viewEmotion setAlpha: 1.0];
    [_iconEmotion setSelected: false];
    
    [viewPhotos setFrame: CGRectMake(viewPhotos.frame.origin.x, SCREEN_HEIGHT-appDelegate._hStatus, viewPhotos.frame.size.width, 0)];
    [viewPhotos setAlpha: 1.0];
    [_iconPhoto setSelected: false];
    
    [_viewFooter setFrame: CGRectMake(0, SCREEN_HEIGHT-appDelegate._hStatus-hKeyboard-_viewFooter.frame.size.height, SCREEN_WIDTH, _viewFooter.frame.size.height)];
    
    //  View footer thay đổi thì thay đổi view chat
    [self updateFrameOfViewChatWithViewFooter];
    
    [self updateAndGotoLastViewChat];
    
    if (![lbChatComposing.text isEqualToString:@""]) {
        [lbChatComposing setFrame:CGRectMake(10, _viewFooter.frame.origin.y-15, SCREEN_WIDTH-20, 15)];
        [lbChatComposing setHidden: NO];
    }
    
    if (_listHistoryMessage.count > 0) {
        [_tbChat scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(_listHistoryMessage.count - 1) inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [viewNewMsg setHidden: true];
    }
}

//  User roi khoi room chat
- (void)whenUserLeaveRoomChat: (NSNotification *)notif
{
    /*  Leo Kelvin
    id object = [notif object];
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSString *curRoomName = [object objectForKey:@"roomName"];
        int roomID = [NSDatabase getIdRoomChatWithRoomName: curRoomName];
        
        NSArray *itemArr = [object objectForKey:@"item"];
        for (int iCount=0; iCount<itemArr.count; iCount++) {
            NSXMLElement *item = [itemArr objectAtIndex: iCount];
            NSString *jidString = [[item attributeForName:@"jid"] stringValue];
            NSString *cloudfoneID = [AppUtils getAccountNameFromString: jidString];
            
            if (![cloudfoneID isEqualToString:USERNAME]) {
                //  Lưu message tham gia vào phòng chat
                NSString *idMessage = [AppUtils randomStringWithLength: 10];
                NSString *time = [AppUtils getCurrentTimeStamp];
                
                NSString *username = [NSDatabase getNameOfContactWithCallnexID: cloudfoneID];
                if ([username isEqualToString: @""]) {
                    username = cloudfoneID;
                }
                
                NSString *msgContent = [NSString stringWithFormat:@"%@ %@ %@", username, [localization localizedStringForKey:left_the_room], time];
                
                int delivered = 1;
                if ([roomName isEqualToString: curRoomName]) {
                    delivered = 2;
                }
                [NSDatabase saveMessage:@"" toPhone:USERNAME withContent:msgContent andStatus:YES withDelivered:delivered andIdMsg:idMessage detailsUrl:@"" andThumbUrl:@"" withTypeMessage:descriptionMessage andExpireTime:-1 andRoomID:[NSString stringWithFormat:@"%d", roomID] andExtra:@"" andDesc: nil];
            }
            
            if ([roomName isEqualToString: curRoomName]) {
                //  Get lịch sử tin nhắn của room
                [self getHistoryMessagesOfRoom: appDelegate.idRoomChat];
                [self updateFrameOfViewChatWithViewFooter];
            }
        }
    }
    */
}

//  User tham gia vao room chat
- (void)whenUserJoinToRoomChat: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSString *curRoomName = [object objectForKey:@"roomName"];
        if ([roomName isEqualToString: curRoomName]) {
            //  Get lịch sử tin nhắn của room
            [self getHistoryMessagesOfRoom: appDelegate.idRoomChat];
            [self updateFrameOfViewChatWithViewFooter];
        }
    }
}

//  Đóng view setting bên phải
- (void)closeRightChatView {
    [revealVC rightRevealToggleAnimated: false];
}

//  Cập nhật tên của group chat
- (void)changeGroupNameOfRoom: (NSNotification *)notif {
    if ([[[PhoneMainView instance] currentView] isEqual:[GroupMainChatViewController compositeViewDescription]]) {
        id object = [notif object];
        if ([object isKindOfClass:[NSString class]]) {
            NSString *currentRoom = [NSDatabase getRoomNameOfRoomWithRoomId: appDelegate.idRoomChat];
            if ([currentRoom isEqualToString: object]) {
                [self setHeaderInfomationOfUser];
            }
        }
    }
}

//  Hàm xoá tất cả tin nhắn của room chat
- (void)deleteAllMessageOfRoomChat {
    if ([[[PhoneMainView instance] currentView] isEqual:[GroupMainChatViewController compositeViewDescription]]) {
        [appDelegate set_heightChatTbView: 0.0f];
        _listHistoryMessage = [[NSMutableArray alloc] init];
        [NSDatabase deleteAllMessageOfRoomChat:[NSString stringWithFormat:@"%d", appDelegate.idRoomChat]];
        [_tbChat reloadData];
    }
}

//  Cập nhật subject của room chat
- (void)whenSubjectOfRoomChanged: (NSNotification *)notif {
    if ([[[PhoneMainView instance] currentView] isEqual:[GroupMainChatViewController compositeViewDescription]]) {
        id object = [notif object];
        if ([object isKindOfClass:[NSDictionary class]]) {
            
            NSString *RoomName = [object objectForKey:@"RoomName"];
            NSString *CloudfoneID = [object objectForKey:@"CloudFoneID"];
            NSString *Subject = [object objectForKey:@"subject"];
            
            int delivered = 1;
            if ([RoomName isEqualToString: roomName]) {
                NSString *subject = [NSDatabase getSubjectOfRoom: roomName];
                [_lbGroupName setText: subject];
                delivered = 2;
            }
            
            NSString *username = [NSDatabase getNameOfContactWithCallnexID: CloudfoneID];
            if ([username isEqualToString: @""]) {
                username = CloudfoneID;
            }
            
            NSString *idMessage = [AppUtils randomStringWithLength: 10];
            int roomID = [NSDatabase getIdRoomChatWithRoomName: RoomName];
            NSString *msgContent = [NSString stringWithFormat:@"%@ %@ '%@'", username, [localization localizedStringForKey:text_change_subject], Subject];
            
            [NSDatabase saveMessage:@""
                            toPhone:USERNAME
                        withContent:msgContent
                          andStatus:YES
                      withDelivered:delivered
                           andIdMsg:idMessage
                         detailsUrl:@""
                        andThumbUrl:@""
                    withTypeMessage:descriptionMessage
                      andExpireTime:-1
                          andRoomID:[NSString stringWithFormat:@"%d", roomID]
                           andExtra:@"" andDesc: nil];
            
            if ([roomName isEqualToString: RoomName]) {
                //  Get lịch sử tin nhắn của room
                [self getHistoryMessagesOfRoom: appDelegate.idRoomChat];
                [self updateFrameOfViewChatWithViewFooter];
            }
        }
    }
}

//  Nhận message mới từ room chat
- (void)receivedNewRoomChatMessage: (NSNotification *)notif {
    if ([[[PhoneMainView instance] currentView] isEqual:[GroupMainChatViewController compositeViewDescription]]) {
        id object = [notif object];
        if ([object isKindOfClass:[NSMutableDictionary class]]) {
            OTRMessage *message = [object objectForKey:@"message"];
            NSString *user = @"";
            if (message != nil) {
                user = [AppUtils getSipFoneIDFromString: message.buddy.accountName];
            }else{
                user = [object objectForKey:@"user"];
            }
            
            // NSString *typeMessage = [object objectForKey:@"typeMessage"];
            
            NSString *idMessage = [object objectForKey:@"idMessage"];
            NSBubbleData *lastMsgData = [NSDatabase getDataOfMessage: idMessage];
            appDelegate._heightChatTbView = appDelegate._heightChatTbView + (lastMsgData.view.frame.size.height+8);
            [_listHistoryMessage addObject: lastMsgData];
                
            // Post notification để lấy last row visibility
            [[NSNotificationCenter defaultCenter] postNotificationName:getRowsVisibleViewChat object:nil];
                
            [self updateAllFrameForController: false];
            if (appDelegate.lastRowVisibleChat != nil && appDelegate.lastRowVisibleChat.row < _listHistoryMessage.count-2) {
                CGRect cbRect = [_viewFooter frame];
                [viewNewMsg setHidden: FALSE];
                [viewNewMsg setFrame: CGRectMake(viewNewMsg.frame.origin.x, cbRect.origin.y-viewNewMsg.frame.size.height - 3, viewNewMsg.frame.size.width, viewNewMsg.frame.size.height)];
            }else{
                [self updateAndGotoLastViewChat];
            }
                
            // Kiểm tra đk và xoá tin nhắn expire
            if (lastMsgData.expireTime > 0) {
                // [self startAllExpireMessageOfMe];
            }
        }
    }
}

//  set thông tin hiển thị cho phần header chat
- (void)setHeaderInfomationOfUser {
    // set trạng thái của user
    NSString *subject = [NSDatabase getSubjectOfRoom: roomName];
    if (![subject isEqualToString: @""]) {
        [_lbGroupName setText: subject];
    }else{
        [_lbGroupName setText: @""];
    }
    
    // setup vị trí của group name và status
    [_lbGroupName sizeToFit];
    
    if (_lbGroupName.frame.size.width > 150) {
        [_lbGroupName setFrame: CGRectMake((SCREEN_WIDTH-150)/2, 0, 150, appDelegate._hHeader)];
    }else{
        [_lbGroupName setFrame: CGRectMake((SCREEN_WIDTH-_lbGroupName.frame.size.width)/2, 0, _lbGroupName.frame.size.width, appDelegate._hHeader)];
    }
    [_iconStatus setFrame:CGRectMake(_lbGroupName.frame.origin.x-15, (appDelegate._hHeader-12)/2, 12, 12)];
}

//  Đóng bàn phím chat
- (void)dismissKeyboard {
    [self.view endEditing: true];
    
    [UIView animateWithDuration:0.2 animations:^{
        [viewEmotion setFrame: CGRectMake(viewEmotion.frame.origin.x, SCREEN_HEIGHT-appDelegate._hStatus, viewEmotion.frame.size.width, 0)];
        [viewPhotos setFrame: CGRectMake(viewPhotos.frame.origin.x, SCREEN_HEIGHT-appDelegate._hStatus, viewPhotos.frame.size.width, 0)];
        [_viewFooter setFrame: CGRectMake(_viewFooter.frame.origin.x, SCREEN_HEIGHT-appDelegate._hStatus-_viewFooter.frame.size.height, _viewFooter.frame.size.width, _viewFooter.frame.size.height)];
        
        //  View footer thay đổi thì thay đổi view chat
        [self updateFrameOfViewChatWithViewFooter];
    } completion:^(BOOL finished) {
        [viewPhotos setAlpha: 1.0];
        [viewEmotion setAlpha: 1.0];
    }];
}

//  Get danh sách tin nhắn của room
- (void)getHistoryMessagesOfRoom: (int)idRoom
{
    if (_listHistoryMessage == nil) {
        _listHistoryMessage = [[NSMutableArray alloc] init];
    }
    [_listHistoryMessage removeAllObjects];
    
    [appDelegate set_heightChatTbView: 0.0];
    
    [_listHistoryMessage addObjectsFromArray:[NSDatabase getListMessagesOfAccount:USERNAME withRoomID:appDelegate.roomChatName]];
    
    // Cập nhật tất cả các tin nhắn chưa đọc thành đã đọc
    [NSDatabase updateAllMessagesInRoomChat:appDelegate.roomChatName withAccount:USERNAME];
    
    [self updateAndGotoLastViewChat];
    
    // Thông báo cập nhật nội dung trong LeftMenu
    /*  LeoKelvin
    [[NSNotificationCenter defaultCenter] postNotificationName:updateUnreadMessageForUser object:nil];
    */
}

//  Cập nhật dữ liệu và scroll đến cuối list
- (void)updateAndGotoLastViewChat {
    
    [_tbChat reloadData];
    if (_listHistoryMessage.count > 0) {
        [_tbChat scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(_tbChat.bubbleData.count-1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        //  LeoKelvin
        // [viewNewMsg setHidden: true];
    }
}

//  Hàm cập nhật các vị trí UI trong view
- (void)updateAllFrameForController: (BOOL)defaultChatBoxHeight {
    float heightChatBox = _viewFooter.frame.size.height;
    if (defaultChatBoxHeight) {
        heightChatBox = hChatBox;
    }
    
    if (_iconEmotion.selected){
        [_viewFooter setFrame: CGRectMake(0, viewEmotion.frame.origin.y-heightChatBox, SCREEN_WIDTH, heightChatBox)];
    }else if (_iconPhoto.selected){
        [_viewFooter setFrame: CGRectMake(0, viewPhotos.frame.origin.y-heightChatBox, SCREEN_WIDTH, heightChatBox)];
    }else if ([_tvMessage isFirstResponder]){
        [_viewFooter setFrame: CGRectMake(0, SCREEN_HEIGHT-appDelegate._hStatus-hKeyboard-heightChatBox, SCREEN_WIDTH, heightChatBox)];
    }else{
        [_viewFooter setFrame: CGRectMake(0, SCREEN_HEIGHT-(appDelegate._hStatus+heightChatBox), SCREEN_WIDTH, heightChatBox)];
    }
    
    //  View footer thay đổi thì thay đổi view chat
    [self updateFrameOfViewChatWithViewFooter];
}

//  Nhập vào textview message
- (void)textViewDidChange:(UITextView *)textView
{
    // Setting placeholder
    if (textView.text.length > 0) {
        [lbPlaceHolder setHidden: true];
    }else{
        [lbPlaceHolder setHidden: false];
    }
    
    //  Send compositing
    if (textView.text.length == 1) {
        [(OTRXMPPAccount *)[appDelegate.friendBuddy.protocol account] setSendTypingNotifications: YES];
        [appDelegate.friendBuddy sendComposingChatState];
    }
    
    if ([_tvMessage text].length > 0) {
        CGFloat fixedWidth = 200;
        CGSize newSize = [_tvMessage sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        CGRect newFrame = [_tvMessage frame];
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
        [_tvMessage setFrame: newFrame];
        
        [_viewFooter setFrame: CGRectMake(firstChatBox.origin.x, SCREEN_HEIGHT-appDelegate._hStatus-hKeyboard-_tvMessage.frame.size.height-6, firstChatBox.size.width, _tvMessage.frame.size.height+6)];
        
        //  Cập nhật vị trí view chat theo view footer
        [self updateFrameOfViewChatWithViewFooter];
    }
}

//  Click vào icon xoá emotion
- (void)onDeleteButtonClicked: (UIButton *)sender
{
    NSString *currentText = [_tvMessage text];
    if ([currentText length] > 0) {
        if ([currentText length] >= 2) {
            NSString *removeStr = [currentText substringFromIndex: currentText.length - 2];
            NSString *convertStr = [self convertEmojiToString:removeStr];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"code LIKE[c] %@", convertStr];
            NSArray *searchResult = [appDelegate._listFace filteredArrayUsingPredicate: predicate];
            if (searchResult.count > 0) {
                [_tvMessage setText: [currentText substringToIndex:[currentText length] - 2]];
            }else{
                searchResult = [appDelegate._listNature filteredArrayUsingPredicate: predicate];
                if (searchResult.count > 0) {
                    [_tvMessage setText: [currentText substringToIndex:[currentText length] - 2]];
                }else{
                    searchResult = [appDelegate._listObject filteredArrayUsingPredicate: predicate];
                    if (searchResult.count > 0) {
                        [_tvMessage setText: [currentText substringToIndex:[currentText length] - 2]];
                    }else{
                        searchResult = [appDelegate._listPlace filteredArrayUsingPredicate: predicate];
                        if (searchResult.count > 0) {
                            [_tvMessage setText: [currentText substringToIndex:[currentText length] - 2]];
                        }else{
                            searchResult = [appDelegate._listSymbol filteredArrayUsingPredicate: predicate];
                            if (searchResult.count > 0) {
                                [_tvMessage setText: [currentText substringToIndex:[currentText length] - 2]];
                            }else{
                                [_tvMessage setText: [currentText substringToIndex:[currentText length] - 1]];
                            }
                        }
                    }
                }
            }
        }else{
            [_tvMessage setText: [currentText substringToIndex:[currentText length] - 1]];
        }
        
        CGFloat fixedWidth = 200;
        CGSize newSize = [_tvMessage sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        CGRect newFrame = [_tvMessage frame];
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
        [_tvMessage setFrame: newFrame];
        
        [_viewFooter setFrame: CGRectMake(firstChatBox.origin.x, viewEmotion.frame.origin.y-_tvMessage.frame.size.height-6, firstChatBox.size.width, _tvMessage.frame.size.height+6)];
        
        //  Cập nhật vị trí view chat theo view footer
        [self updateFrameOfViewChatWithViewFooter];
    }
    
    if ([_tvMessage text].length == 0) {
        [_viewFooter setFrame: CGRectMake(firstChatBox.origin.x, viewEmotion.frame.origin.y-hChatBox, firstChatBox.size.width, hChatBox)];
        [_tvMessage setFrame: CGRectMake(_tvMessage.frame.origin.x, 3, _tvMessage.frame.size.width, hChatBox-6)];
        
        //  Cập nhật vị trí view chat theo view footer
        [self updateFrameOfViewChatWithViewFooter];
    }
    
    if (_tvMessage.text.length == 0) {
        [lbPlaceHolder setHidden: false];
    }else{
        [lbPlaceHolder setHidden: true];
    }
}

//  HÀM CHUYỂN CHUỖI CÓ EMOTION THÀNH CHUỖI KÝ TỰ
- (NSString *)convertEmojiToString:(NSString *)string {
    
    __block NSString *resultStr = string;
    resultMessage = [[NSString alloc] initWithString: string];
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     resultStr = [self replaceAnEmotion:substring onString:resultStr];
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 resultStr = [self replaceAnEmotion:substring onString:resultStr];
             }
             
         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 resultStr = [self replaceAnEmotion:substring onString:resultStr];
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 resultStr = [self replaceAnEmotion:substring onString:resultStr];
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 resultStr = [self replaceAnEmotion:substring onString:resultStr];
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 resultStr = [self replaceAnEmotion:substring onString:resultStr];
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 resultStr = [self replaceAnEmotion:substring onString:resultStr];
             }
         }
     }];
    return resultMessage;
}

//  HÀM TRUYỀN VÀO MỘT EMOTION VÀ THAY THẾ NÓ BẰNG KÝ TỰ
- (NSString *)replaceAnEmotion: (NSString *)strNeedReplace onString: (NSString *)string {
    NSString *resultStr = [[NSString alloc] initWithString: string];
    NSData *new_data=[strNeedReplace dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    NSString *emoji=[[NSString alloc] initWithData:new_data encoding:NSUTF8StringEncoding];
    emoji = [emoji stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"image LIKE[cd] %@", emoji];
    NSArray *filter = [appDelegate._listFace filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        NSString *eCode = [(NSDictionary *)[filter objectAtIndex: 0] objectForKey:@"code"];
        resultStr = [resultStr stringByReplacingOccurrencesOfString:strNeedReplace withString:eCode];
    }else{
        NSArray *filter = [appDelegate._listNature filteredArrayUsingPredicate: predicate];
        if (filter.count > 0) {
            NSString *eCode = [(NSDictionary *)[filter objectAtIndex: 0] objectForKey:@"code"];
            resultStr = [resultStr stringByReplacingOccurrencesOfString:strNeedReplace withString:eCode];
        }else{
            NSArray *filter = [appDelegate._listObject filteredArrayUsingPredicate: predicate];
            if (filter.count > 0) {
                NSString *eCode = [(NSDictionary *)[filter objectAtIndex: 0] objectForKey:@"code"];
                resultStr = [resultStr stringByReplacingOccurrencesOfString:strNeedReplace withString:eCode];
            }else{
                NSArray *filter = [appDelegate._listPlace filteredArrayUsingPredicate: predicate];
                if (filter.count > 0) {
                    NSString *eCode = [(NSDictionary *)[filter objectAtIndex: 0] objectForKey:@"code"];
                    resultStr = [resultStr stringByReplacingOccurrencesOfString:strNeedReplace withString:eCode];
                }else{
                    NSArray *filter = [appDelegate._listSymbol filteredArrayUsingPredicate: predicate];
                    if (filter.count > 0) {
                        NSString *eCode = [(NSDictionary *)[filter objectAtIndex: 0] objectForKey:@"code"];
                        resultStr = [resultStr stringByReplacingOccurrencesOfString:strNeedReplace withString:eCode];
                    }
                }
            }
        }
    }
    resultMessage = [[NSString alloc] initWithString:resultStr];
    return resultStr;
}

//  Trả về chiều cao của các tin nhắn của user
- (float)getHeightOfAllMessageOfUserWithMaxHeight: (float)maxHeight {
    float totalHeight = 0;
    for (int iCount=0; iCount<_listHistoryMessage.count; iCount++) {
        NSBubbleData *curMessage = [_listHistoryMessage objectAtIndex: iCount];
        totalHeight = totalHeight + curMessage.view.frame.size.height+8;
        if (totalHeight >= maxHeight) {
            break;
        }
    }
    return totalHeight;
}

#pragma mark - tableview chats
- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView {
    return [_listHistoryMessage count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row {
    return [_listHistoryMessage objectAtIndex:row];
}

#pragma mark - LE KHAI FUNCTIONS
//  Thêm view emotion cho controller
- (void)addEmotionViewForViewChat {
    hViewEmotion = 175.0;
    hTabEmotion = 30;
    
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"EmotionView" owner:nil options:nil];
    for(id currentObject in subviewArray){
        if ([currentObject isKindOfClass:[EmotionView class]]) {
            viewEmotion = (EmotionView *) currentObject;
            [viewEmotion setupBackgroundUIForView];
            break;
        }
    }
    [viewEmotion setFrame: CGRectMake(0, SCREEN_HEIGHT-appDelegate._hStatus, SCREEN_WIDTH, 0)];
    [viewEmotion addContentForEmotionView];
    
    [viewEmotion._iconDelete addTarget:self
                                action:@selector(onDeleteButtonClicked:)
                      forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: viewEmotion];
}

//  Cập nhật vị trí view chat theo view footer
- (void)updateFrameOfViewChatWithViewFooter {
    [_viewChat setFrame: CGRectMake(_viewChat.frame.origin.x, _viewChat.frame.origin.y, _viewChat.frame.size.width, _viewFooter.frame.origin.y-_viewChat.frame.origin.y)];
    [_lbNoMessage setFrame: _viewChat.frame];
    
    float tmpHeight = [self getHeightOfAllMessageOfUserWithMaxHeight: _viewChat.frame.size.height];
    if (tmpHeight >= _viewChat.frame.size.height) {
        [_tbChat setFrame: CGRectMake(_tbChat.frame.origin.x, 5, _tbChat.frame.size.width, _viewChat.frame.size.height-5)];
        [_tbChat setScrollEnabled: true];
    }else{
        [_tbChat setFrame: CGRectMake(_tbChat.frame.origin.x, _viewChat.frame.size.height-tmpHeight, _tbChat.frame.size.width, tmpHeight)];
        [_tbChat setScrollEnabled: false];
    }
}

//  Thêm view ghi âm vào màn hình
- (void)addViewPhotosForViewChat {
    hViewPhoto = 175.0;
    
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"ChatPhotosView" owner:nil options:nil];
    for(id currentObject in subviewArray){
        if ([currentObject isKindOfClass:[ChatPhotosView class]]) {
            viewPhotos = (ChatPhotosView *) currentObject;
            break;
        }
    }
    [viewPhotos setFrame: CGRectMake(0, SCREEN_HEIGHT-appDelegate._hStatus, SCREEN_WIDTH, 0)];
    [viewPhotos setupUIForView];
    [self.view addSubview: viewPhotos];
    
    UIPanGestureRecognizer* pgr = [[UIPanGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(handlePan:)];
    [viewPhotos addGestureRecognizer:pgr];
}

- (void)setupUIForView
{
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }else{
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
    }
    
    [_viewHeader setFrame: CGRectMake(0, 0, SCREEN_WIDTH, appDelegate._hHeader)];
    [_iconBack setFrame: CGRectMake(0, 0, appDelegate._hHeader, appDelegate._hHeader)];
    [_iconBack setBackgroundImage:[UIImage imageNamed:@"ic_back_act.png"]
                         forState:UIControlStateHighlighted];
    
    [_iconSetting setFrame: CGRectMake(_viewHeader.frame.size.width-_iconBack.frame.size.width, _iconBack.frame.origin.y, _iconBack.frame.size.width, _iconBack.frame.size.height)];
    [_iconSetting setBackgroundImage:[UIImage imageNamed:@"ic_add_user_act.png"]
                            forState:UIControlStateHighlighted];
    
    // view footer
    if (SCREEN_WIDTH > 320) {
        hChatBox = 42.0;
    }else{
        hChatBox = 38.0;
    }
    
    [_viewFooter setFrame: CGRectMake(0, SCREEN_HEIGHT-(appDelegate._hStatus+hChatBox), SCREEN_WIDTH, hChatBox)];
    firstChatBox = [_viewFooter frame];
    
    [_icCamera setFrame: CGRectMake(0, 0, hChatBox, hChatBox)];
    
    [_iconEmotion setFrame: CGRectMake(_icCamera.frame.origin.x+_icCamera.frame.size.width, _icCamera.frame.origin.y, _icCamera.frame.size.width, _icCamera.frame.size.height)];
    [_iconPhoto setFrame: CGRectMake(_iconEmotion.frame.origin.x+_iconEmotion.frame.size.width, _iconEmotion.frame.origin.y, _iconEmotion.frame.size.width, _iconEmotion.frame.size.height)];
    
    [_iconSend setFrame: CGRectMake(_viewFooter.frame.size.width-hChatBox, 0, hChatBox, hChatBox)];
    [_iconSend setBackgroundImage:[UIImage imageNamed:@"chat_send_message_over.png"]
                         forState:UIControlStateHighlighted];
    
    [_tvMessage setFrame: CGRectMake(_iconPhoto.frame.origin.x+_iconPhoto.frame.size.width, 3, _viewChat.frame.size.width-(_iconPhoto.frame.origin.x+_iconPhoto.frame.size.width+5+_iconSend.frame.size.width), hChatBox-6)];
    
    // label placeholder
    lbPlaceHolder = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, _tvMessage.frame.size.width-8, _tvMessage.frame.size.height)];
    [lbPlaceHolder setTextColor:[UIColor grayColor]];
    [lbPlaceHolder setText:[localization localizedStringForKey:text_type_to_composte]];
    [lbPlaceHolder setFont:[UIFont fontWithName:HelveticaNeueItalic size:15.0]];
    [_tvMessage addSubview: lbPlaceHolder];
    [_tvMessage setScrollEnabled: false];
    [_tvMessage setDelegate: self];
    
    [_bgChat setFrame: CGRectMake(0, _viewHeader.frame.origin.y+_viewHeader.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT-(appDelegate._hStatus+appDelegate._hHeader+hChatBox))];
    [_bgChat setImage:[UIImage imageNamed:@"bg_chat_default.jpg"]];
    
    [_lbNoMessage setFrame: _bgChat.frame];
    [_lbNoMessage setFont:[UIFont fontWithName:HelveticaNeue size:16.0]];
    [_lbNoMessage setText: [localization localizedStringForKey:text_no_message]];
    [_lbNoMessage setHidden: true];
    _lbNoMessage.textAlignment = NSTextAlignmentCenter;
    
    [_viewChat setFrame: _bgChat.frame];
    [_viewChat setBackgroundColor:[UIColor clearColor]];
    
    // chat tableview
    [_tbChat setFrame: CGRectMake(0, 5, _viewChat.frame.size.width, _viewChat.frame.size.height-10)];
    [_tbChat setBubbleDataSource: self];
    [_tbChat setSnapInterval: 200];
    [_tbChat setShowAvatars: true];
    [_tbChat setBackgroundColor:[UIColor clearColor]];
    
    // Khai báo label chat composite
    lbChatComposing = [[UILabel alloc] init];
    [lbChatComposing setAutoresizingMask: UIViewAutoresizingFlexibleWidth];
    [lbChatComposing setTag: 888];
    [lbChatComposing setTextColor: [UIColor colorWithRed:(71/255.0) green:(32/255.0) blue:(102/255.0) alpha:1.0]];
    [lbChatComposing setBackgroundColor:[UIColor clearColor]];
    [lbChatComposing setFont:[UIFont fontWithName:HelveticaNeueItalic size:12.0]];
    [self.view addSubview: lbChatComposing];
    
    // SETUP định dạng cho label contact name và  label status
    [_lbGroupName setMarqueeType:MLContinuous];
    [_lbGroupName setScrollDuration: 15.0f];
    [_lbGroupName setAnimationCurve:UIViewAnimationOptionCurveEaseOut];
    [_lbGroupName setFadeLength: 10.0f];
    [_lbGroupName setContinuousMarqueeExtraBuffer: 10.0f];
    [_lbGroupName setTextColor:[UIColor whiteColor]];
    [_lbGroupName setBackgroundColor:[UIColor clearColor]];
    [_lbGroupName setTextAlignment:NSTextAlignmentCenter];
    [_lbGroupName setFont:[UIFont fontWithName:HelveticaNeue size:15.0]];
}

//  Kéo di chuyển list hình ảnh
- (void)handlePan:(UIPanGestureRecognizer*)pgr;
{
    /*  Leo Kelvin
    CGPoint translation = [pgr translationInView:pgr.view];
    
    if (pgr.state == UIGestureRecognizerStateChanged) {
        if (pgr.view.frame.origin.y+translation.y > SCREEN_HEIGHT-appDelegate._hStatus-hViewPhoto) {
            [pgr.view setFrame: CGRectMake(pgr.view.frame.origin.x, pgr.view.frame.origin.y+translation.y, pgr.view.frame.size.width, SCREEN_HEIGHT-appDelegate._hStatus-(pgr.view.frame.origin.y+translation.y))];
            
            [_viewFooter setFrame: CGRectMake(_viewFooter.frame.origin.x, pgr.view.frame.origin.y-_viewFooter.frame.size.height, _viewFooter.frame.size.width, _viewFooter.frame.size.height)];
        }else{
            [pgr.view setFrame: CGRectMake(pgr.view.frame.origin.x, pgr.view.frame.origin.y+translation.y, pgr.view.frame.size.width, SCREEN_HEIGHT-appDelegate._hStatus-(pgr.view.frame.origin.y+translation.y))];
        }
        [pgr setTranslation:CGPointZero inView:pgr.view];
    }else if (pgr.state == UIGestureRecognizerStateEnded){
        if (pgr.view.frame.origin.y+translation.y < SCREEN_HEIGHT-appDelegate._hStatus-hViewPhoto) {
            [UIView animateWithDuration:0.2 animations:^{
                [pgr.view setFrame: CGRectMake(pgr.view.frame.origin.x, _viewHeader.frame.origin.y+_viewHeader.frame.size.height, pgr.view.frame.size.width, SCREEN_HEIGHT-(appDelegate._hStatus+hHeader))];
            }completion:^(BOOL finished) {
                [_viewAlbum setHidden: false];
            }];
        }else if (pgr.view.frame.origin.y+translation.y >= SCREEN_HEIGHT-appDelegate._hStatus-hViewPhoto/2){
            [UIView animateWithDuration:0.2 animations:^{
                [_viewFooter setFrame: CGRectMake(_viewFooter.frame.origin.x, SCREEN_HEIGHT-(appDelegate._hStatus+_viewFooter.frame.size.height), _viewFooter.frame.size.width, _viewFooter.frame.size.height)];
                [pgr.view setFrame: CGRectMake(pgr.view.frame.origin.x, SCREEN_HEIGHT-appDelegate._hStatus, pgr.view.frame.size.width, 0)];
            }];
        }else{
            [UIView animateWithDuration:0.2 animations:^{
                [pgr.view setFrame: CGRectMake(pgr.view.frame.origin.x, SCREEN_HEIGHT-appDelegate._hStatus-hViewPhoto, pgr.view.frame.size.width, hViewPhoto)];
                [_viewFooter setFrame: CGRectMake(_viewFooter.frame.origin.x, pgr.view.frame.origin.y-_viewFooter.frame.size.height, _viewFooter.frame.size.width, _viewFooter.frame.size.height)];
            }];
        }
    }
    */
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    codeUpload = (int)[httpResponse statusCode];
}

// Hiển thị popup khi send request thành công
- (void)showPopupWithContent: (NSString *)strContent withTimeShow: (float)showValue andTimeHide: (float)hideValue {
    if (messageView == nil) {
        messageView = [[UIView alloc] init];
        [messageView setBackgroundColor:[UIColor blackColor]];
        [messageView.layer setCornerRadius: 5.0];
        
        lbMessage = [[UILabel alloc] init];
        [lbMessage setNumberOfLines: 10];
        [lbMessage setTextColor:[UIColor whiteColor]];
        [lbMessage setTextAlignment: NSTextAlignmentCenter];
        [messageView addSubview: lbMessage];
        [self.view addSubview: messageView];
    }
    [lbMessage setText: strContent];
    
    CGSize size = [AppUtils getSizeWithText:strContent
                                       withFont:textFont
                                    andMaxWidth:(SCREEN_WIDTH-40)];
    
    [lbMessage setFont: textFont];
    [messageView setFrame: CGRectMake((self.view.frame.size.width-size.width-20)/2, (self.view.frame.size.height-size.height-20)-40, size.width+20, size.height+20)];
    [lbMessage setFrame: CGRectMake(10, 10, size.width, size.height)];
    
    [messageView setHidden: NO];
    [UIView animateWithDuration:showValue animations:^{
        [messageView setAlpha: 1.0];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:hideValue animations:^{
            [messageView setAlpha: 0];
        }];
    }];
}

// This method is used to receive the data which we get using post method.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data
{
    NSString *strURL = [[[connection currentRequest] URL] absoluteString];
    NSString *strPushSharp = [NSString stringWithFormat:@"%@/%@", link_api, PushSharp];
    NSString *strUpload = [ NSString stringWithFormat:@"%@/ios_upload_file.php", link_picutre_chat_group];
    
    if ([strURL isEqualToString: strPushSharp]) {
        if (sendMsgData == nil) {
            sendMsgData = [[NSMutableData alloc] init];
        }
        [sendMsgData appendData: data];
    }else if ([strURL isEqualToString: strUpload]){
        if (uploadData == nil) {
            uploadData = [[NSMutableData alloc] init];
        }
        [uploadData appendData: data];
    }
}


// This method receives the error report in case of connection is not made to server.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@", error.userInfo);
    NSLog(@"%@", [error.userInfo objectForKey:@"NSLocalizedDescription"]);
}

// This method is used to process the data after connection has made successfully.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *strURL = [[[connection currentRequest] URL] absoluteString];
    NSString *strPushSharp = [NSString stringWithFormat:@"%@/%@", link_api, PushSharp];
    NSString *strUpload = [ NSString stringWithFormat:@"%@/ios_upload_file.php", link_picutre_chat_group];
    
    if ([strURL isEqualToString: strPushSharp])
    {
        NSString *value = [[NSString alloc] initWithData:sendMsgData encoding:NSUTF8StringEncoding];
        id object = [value objectFromJSONString];
        NSLog(@"%@", object);
    }else if ([strURL isEqualToString: strUpload]){
        NSString *value = [[NSString alloc] initWithData:uploadData encoding:NSUTF8StringEncoding];
        uploadData = nil;
        if (![value isEqualToString:@"error"])
        {
            NSString *idMessage = [NSString stringWithFormat:@"groupimage_%@", [AppUtils randomStringWithLength: 20]];
            NSArray *fileNameArr = [AppUtils saveImageToFiles: appDelegate.imageChoose withImage: value];
            detailURL = [fileNameArr objectAtIndex: 0];
            thumbURL = [fileNameArr objectAtIndex: 1];
            
            int delivered = 0;
            if (appDelegate.xmppStream.isConnected) {
                delivered = 1;
            }
            
            [NSDatabase updateImageMessageUserWithId: idMsgImage andDetailURL: detailURL andThumbURL: thumbURL andContent: value];
            
            NSBubbleData *dataMessage = [NSDatabase getDataOfMessage: idMsgImage];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"idMessage = %@", idMsgImage];
            NSArray *updateData = [_listHistoryMessage filteredArrayUsingPredicate: predicate];
            if (updateData.count > 0) {
                int replaceIndex = (int)[_listHistoryMessage indexOfObject: [updateData objectAtIndex: 0]];
                [_listHistoryMessage replaceObjectAtIndex:replaceIndex withObject:dataMessage];
                [_tbChat reloadData];
            }
            if (dataMessage.expireTime > 0) {
                [self startAllExpireMessageOfMe];
            }
            
            [self updateAllFrameForController: false];
            [self updateAndGotoLastViewChat];
            
            [appDelegate.myBuddy.protocol sendMessageImageForGroup:appDelegate.roomChatName withLinkImage:value andDescription:appDelegate.titleCaption andIdMessage: idMessage];
            appDelegate.imageChoose = nil;
        }else{
            [self showPopupWithContent:[localization localizedStringForKey:text_can_not_send_image_for_group]
                          withTimeShow:1.0 andTimeHide:3.5];
        }
    }
}

- (void)sendMessageOfflineForGroupFromSender: (NSString *)Sender withContent: (NSString *)content andTypeMessage: (NSString *)typeMessage withGroupID: (NSString *)GroupID
{
    NSString *strURL = [NSString stringWithFormat:@"%@/%@", link_api, PushSharp];
    NSURL *URL = [NSURL URLWithString:strURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: URL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
    [request setTimeoutInterval: 60];
    
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:AuthUser forKey:@"AuthUser"];
    [jsonDict setObject:AuthKey forKey:@"AuthKey"];
    [jsonDict setObject:@"" forKey:@"IDRecipient"];
    [jsonDict setObject:@"yes" forKey:@"Xmpp"];
    [jsonDict setObject:Sender forKey:@"Sender"];
    [jsonDict setObject:typeMessage forKey:@"Type"];
    [jsonDict setObject:content forKey:@"Content"];
    [jsonDict setObject:GroupID forKey:@"GroupID"];
    
    NSString *jsonRequest = [jsonDict JSONString];
    NSData *requestData = [jsonRequest dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [request setValue:[NSString stringWithFormat:@"%d", (int)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if(connection) {
        NSLog(@"Connection Successful");
    }
}

//  Hiển thị label expire cho useer
- (void)setExpireTimeLabelWithExpireTime: (int)expireValue {
    switch (expireValue) {
        case 0:{
            [lbPlaceHolder setText: [localization localizedStringForKey:text_type_to_composte]];
            break;
        }
        case 5:{
            [lbPlaceHolder setText: [localization localizedStringForKey:text_destructs_5s]];
            break;
        }
        case 10:{
            [lbPlaceHolder setText: [localization localizedStringForKey:text_destructs_10s]];
            break;
        }
        case 30:{
            [lbPlaceHolder setText: [localization localizedStringForKey:text_destructs_30s]];
            break;
        }
        case 60:{
            [lbPlaceHolder setText: [localization localizedStringForKey:text_destructs_1m]];
            break;
        }
        case 1800:{
            [lbPlaceHolder setText: [localization localizedStringForKey:text_destructs_30m]];
            break;
        }
        case 3600:{
            [lbPlaceHolder setText: [localization localizedStringForKey:text_destructs_1h]];
            break;
        }
        case 86400:{
            [lbPlaceHolder setText: [localization localizedStringForKey:text_destructs_24h]];
            break;
        }
    }
}

#pragma mark - ContactDetailsImagePickerDelegate Functions

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    appDelegate.imageChoose = image;
    [appDelegate setReloadMessageList: false];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [[PhoneMainView instance] changeCurrentView: ShowPictureViewController.compositeViewDescription
                                               push: TRUE];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [appDelegate setReloadMessageList: false];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
