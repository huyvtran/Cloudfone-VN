//
//  NewChatViewController.m
//  linphone
//
//  Created by admin on 1/3/18.
//

#import "NewChatViewController.h"
#import "ContentView.h"
#import "ChatTableViewCell.h"
#import "ChatLeftTableViewCell.h"
#import "ChatCellSettings.h"
#import "BackgroundViewController.h"
#import "ChooseContactsViewController.h"
#import "SWRevealViewController.h"
#import "NSDatabase.h"
#import "UIImageView+WebCache.h"
#import "EmotionView.h"
#import "MoreChatView.h"
#import "NSData+Base64.h"
#import "MessageEvent.h"
#import "PhoneMainView.h"
#import "JSONKit.h"
#import "OTRProtocolManager.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ShowPictureViewController.h"
#import "AddParticientsViewController.h"
#import "UploadPicture.h"
#import "SettingItem.h"
#import <AVKit/AVKit.h>
#import "UIVIew+Toast.h"

@interface iMessage: NSObject

-(id) initIMessageWithName:(NSString *)name
                   message:(NSString *)message
                      time:(NSString *)time
                      type:(NSString *)type;

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *userMessage;
@property (strong, nonatomic) NSString *userTime;
@property (strong, nonatomic) NSString *messageType;

@end

@implementation iMessage

-(id) initIMessageWithName:(NSString *)name
                   message:(NSString *)message
                      time:(NSString *)time
                      type:(NSString *)type
{
    self = [super init];
    if(self)
    {
        self.userName = name;
        self.userMessage = message;
        self.userTime = time;
        self.messageType = type;
    }
    
    return self;
}

@end

@interface NewChatViewController ()

/*Uncomment second line and comment first to use XIB instead of code*/
@property (strong,nonatomic) ChatTableViewCell *chatCell;
//@property (strong,nonatomic) ChatTableViewCellXIB *chatCell;
@property (strong,nonatomic) ChatMediaTableViewCell *chatImageCell;

@property (strong,nonatomic) ContentView *handler;

@end

@implementation NewChatViewController{
    SWRevealViewController *revealVC;
    LinphoneAppDelegate *appDelegate;
    
    float hKeyboard;
    float hChatBox;
    float hChatIcon;
    float hCell;
    
    UILabel *bgStatus;
    UIFont *textFont;
    UILabel *lbPlaceHolder;
    UILabel *lbChatComposing;
    
    NSString *remoteParty;
    // Emotion View
    EmotionView *viewEmotion;
    float hViewEmotion;
    float hTabEmotion;
    
    MoreChatView *viewChatMore;
    
    NSMutableArray *_listMessages;
    NSString *resultMessage;
    
    // Lưu giá trị rect ban đầu của chatboxview: tăng chiều cao chatbox
    CGRect firstChatBox;
    
    NSMutableData *sendMsgData;
    UIImage *friendAvatar;
    UIImage *myAvatar;
    
    ChatPictureDetailsView *viewPictures;
    NSMutableArray *touchMessageArr;
    SettingPopupView *popUpTouchMessage;
    
    int curPage;
    int numPerPage;
    int totalPage;
    BOOL isLoadMore;
    UIView *viewLoadMore;
    UILabel *lbLoadMore;
    UIActivityIndicatorView *icLoadMore;
    
    ChatCellSettings *chatCellSettings;
}
@synthesize _viewHeader, _iconBack, _icStatus, _lbUserName, _lbStatus, _icSetting;
@synthesize _viewChat, _tbChat, _bgChat, _lbNoMessage;
@synthesize _viewFooter, _tvMessage, _iconSend, _iconMore, _iconEmotion, _icCamera;

@synthesize chatCell;

//  View không bị thay đổi sau khi vào pickerview controller
- (void) viewDidLayoutSubviews {
    if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        CGRect viewBounds = self.view.bounds;
        CGFloat topBarOffset = self.topLayoutGuide.length;
        viewBounds.origin.y = topBarOffset * -1;
        self.view.bounds = viewBounds;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //  my code here
    revealVC = [self revealViewController];
    [revealVC panGestureRecognizer];
    [revealVC tapGestureRecognizer];
    
    appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    hKeyboard   =   0;
    hCell = 40.0;
    
    [self setupUIForView];
    
    bgStatus = [[UILabel alloc] initWithFrame: CGRectMake(0, -[UIApplication sharedApplication].statusBarFrame.size.height, SCREEN_WIDTH, [UIApplication sharedApplication].statusBarFrame.size.height)];
    [bgStatus setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview: bgStatus];
    
    chatCellSettings = [ChatCellSettings getInstance];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenSentImageForUser:)
                                                 name:@"sendImageForUser" object:nil];
    
    /**
     *  Set settings for Application. They are available in ChatCellSettings class.
     */
    
    //[chatCellSettings setSenderBubbleColor:[UIColor colorWithRed:0 green:(122.0f/255.0f) blue:1.0f alpha:1.0f]];
    //[chatCellSettings setReceiverBubbleColor:[UIColor colorWithRed:(223.0f/255.0f) green:(222.0f/255.0f) blue:(229.0f/255.0f) alpha:1.0f]];
    //[chatCellSettings setSenderBubbleNameTextColor:[UIColor colorWithRed:(255.0f/255.0f) green:(255.0f/255.0f) blue:(255.0f/255.0f) alpha:1.0f]];
    //[chatCellSettings setReceiverBubbleNameTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0f]];
    //[chatCellSettings setSenderBubbleMessageTextColor:[UIColor colorWithRed:(255.0f/255.0f) green:(255.0f/255.0f) blue:(255.0f/255.0f) alpha:1.0f]];
    //[chatCellSettings setReceiverBubbleMessageTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0f]];
    //[chatCellSettings setSenderBubbleTimeTextColor:[UIColor colorWithRed:(255.0f/255.0f) green:(255.0f/255.0f) blue:(255.0f/255.0f) alpha:1.0f]];
    //[chatCellSettings setReceiverBubbleTimeTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0f]];
    
    [chatCellSettings setSenderBubbleColorHex:@"bad976"];
    [chatCellSettings setReceiverBubbleColorHex:@"DFDEE5"];
    [chatCellSettings setSenderBubbleNameTextColorHex:@"323232"];
    [chatCellSettings setReceiverBubbleNameTextColorHex:@"000000"];
    [chatCellSettings setSenderBubbleMessageTextColorHex:@"323232"];
    [chatCellSettings setReceiverBubbleMessageTextColorHex:@"000000"];
    [chatCellSettings setSenderBubbleTimeTextColorHex:@"000000"];
    [chatCellSettings setReceiverBubbleTimeTextColorHex:@"000000"];
    
    [chatCellSettings setSenderBubbleFontWithSizeForName:[UIFont boldSystemFontOfSize:11]];
    [chatCellSettings setReceiverBubbleFontWithSizeForName:[UIFont boldSystemFontOfSize:11]];
    //  [chatCellSettings setSenderBubbleFontWithSizeForMessage:[UIFont systemFontOfSize:15]];
    [chatCellSettings setSenderBubbleFontWithSizeForMessage:[UIFont italicSystemFontOfSize:16.0]];
    [chatCellSettings setReceiverBubbleFontWithSizeForMessage:[UIFont systemFontOfSize:16]];
    [chatCellSettings setSenderBubbleFontWithSizeForTime:[UIFont systemFontOfSize:12]];
    [chatCellSettings setReceiverBubbleFontWithSizeForTime:[UIFont systemFontOfSize:12]];
    
    [chatCellSettings senderBubbleTailRequired:YES];
    [chatCellSettings receiverBubbleTailRequired:YES];
    
    //  Tap gesture on table view so that when someone taps on it, the keyboard is hidden
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self._viewChat addGestureRecognizer:gestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    //  Tắt màn hình cảm biến
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled: false];
    
    appDelegate.idRoomChat = 0;
    
    remoteParty = [[NSString alloc] initWithString:[AppUtils getSipFoneIDFromString: appDelegate.friendBuddy.accountName]];
    
    NSString *dataStr = [NSDatabase getAvatarOfContactWithPhoneNumber: remoteParty];
    if ([dataStr isEqualToString:@""]) {
        friendAvatar = [UIImage imageNamed:@"no_avatar"];
    }else{
        friendAvatar = [UIImage imageWithData:[NSData dataFromBase64String: dataStr]];
    }
    
    NSDictionary *info = [NSDatabase getProfileInfoOfAccount: USERNAME];
    if (info != nil) {
        NSString *strAvatar = [info objectForKey:@"avatar"];
        if (strAvatar != nil && ![strAvatar isEqualToString: @""]) {
            NSData *myAvatarData = [NSData dataFromBase64String: strAvatar];
            myAvatar = [UIImage imageWithData: myAvatarData];
        }else{
            myAvatar = [UIImage imageNamed:@"no_avatar"];
        }
    }else{
        myAvatar = [UIImage imageNamed:@"no_avatar"];
    }
    
    // Nếu login thất bại thì login lại
    if (!appDelegate.xmppStream.isConnected) {
        [AppUtils reconnectToXMPPServer];
    }
    
    // Placeholder custom cho chatbox message
    if ([_tvMessage.text isEqualToString:@""]) {
        lbPlaceHolder.hidden = NO;
        _iconSend.hidden = YES;
        _iconMore.hidden = NO;
    }else{
        lbPlaceHolder.hidden = YES;
        _iconSend.hidden = NO;
        _iconMore.hidden = YES;
    }
    _iconMore.selected = NO;
    
    //  Load background chat hiện tại
    NSString *linkBgChat = [NSDatabase getChatBackgroundOfUser: remoteParty];
    if ([linkBgChat isEqualToString: @""] || linkBgChat == nil) {
        _bgChat.image = [UIImage imageNamed:@"bg_chat_default.jpg"];
    }else{
        [_bgChat sd_setImageWithURL:[NSURL URLWithString: linkBgChat]
                   placeholderImage:[UIImage imageNamed:@"bg_chat_default.jpg"]];
    }
    
    // Setup more view về lại trạng thái ban đầu
    [self dismissKeyboard];
    
    // Kiểm tra nếu user này có badge thì xoá đi
    BOOL isBadge = [NSDatabase checkBadgeMessageOfUserWhenRunBackground: remoteParty];
    if (isBadge) {
        int currentBadge = (int)[[UIApplication sharedApplication] applicationIconBadgeNumber];
        if (currentBadge > 0) {
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber: currentBadge - 1];
        }
    }
    
    // Hiển thị thông tin của user chat lên màn hình
    [self setBuddy: appDelegate.friendBuddy];
    [self setHeaderInfomationOfUser];
    
    // Add sự kiện double click vào màn hình để change background
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapToChangeBackground)];
    [doubleTap setNumberOfTapsRequired: 2];
    [doubleTap setNumberOfTouchesRequired: 1];
    [_viewChat addGestureRecognizer:doubleTap];
    
    
    // Lấy lịch sử tin nhắn
    appDelegate._heightChatTbView = 0.0;
    
    isLoadMore = NO;
    curPage = 0;
    numPerPage = 20;
    int totalMessage = [NSDatabase getTotalMessagesOfMe: USERNAME withRemoteParty: remoteParty];
    totalPage = ceil((float)totalMessage/numPerPage);
    
    if (appDelegate.reloadMessageList) {
        if (_listMessages == nil) {
            _listMessages = [[NSMutableArray alloc] init];
        }
        [_listMessages removeAllObjects];
        [self._tbChat reloadData];
        
        [self getHistoryMessagesWithUser: remoteParty];
    }
    
    if (_listMessages.count > 0) {
        _lbNoMessage.hidden = YES;
        [_tbChat reloadData];
    }else{
        _lbNoMessage.hidden = NO;
    }
    
    [self updateAllFrameForController: false];
    [self updateAndGotoLastViewChat];
    
    //  gui thong bao display cho tat ca cac message
    [self sendMessageDisplayedForRemoteParty: remoteParty];
    
    // Thông báo cập nhật nội dung trong LeftMenu
    [[NSNotificationCenter defaultCenter] postNotificationName:updateUnreadMessageForUser object:nil];
    
    //  notitications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWhenShowKeyboard:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification object:nil];
    
    // Nhận message mới
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNewMessage:)
                                                 name:kOTRMessageReceived object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(afterDownloadImageSuccess:)
                                                 name:@"downloadPictureFinish" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getChatMessageTextViewInfo)
                                                 name:getTextViewMessageChatInfo object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setContentForMessageTextView:)
                                                 name:mapContentForMessageTextView object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickToPlayVideo:)
                                                 name:playVideoMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateReceiveMessage:)
                                                 name:updateDeliveredChat object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenLongGestureOnMessage:)
                                                 name:@"longGestureOnMessage" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViewChatAfterRecallMessage:)
                                                 name:k11DeleteMsgWithRecallID object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteConversationSuccess)
                                                 name:whenDeleteConversationInChatView object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSeenStatusForMessage:)
                                                 name:@"updateSeenStatusForMessage" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenSaveImageForVideoSuccess:)
                                                 name:updatePreviewImageForVideo object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageProcessedNotification:)
                                                 name:MESSAGE_PROCESSED_NOTIFICATION object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:updateDeliveredChat
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOTRMessageReceived
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k11TouchOnMessage
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:getTextViewMessageChatInfo
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:mapContentForMessageTextView
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:updateTitleAlbumForViewChat
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k11SaveConversationChat
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:whenDeleteConversationInChatView
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOTRBuddyListUpdate
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k11DismissKeyboardInViewChat
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MESSAGE_PROCESSED_NOTIFICATION
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k11UpdateMsgAfterReceivedFile
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k11DeleteMsgWithRecallID
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k11UpdateDeliveredError
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k11ProcessingLinkOnMessage
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:playVideoMessage
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"longGestureOnMessage"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateSeenStatusForMessage"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:updatePreviewImageForVideo
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - options on message delegate
- (void)selectOnMessage:(NSString *)idMessage withRow:(int)row {
    switch (row) {
        case 0:{
            //  copy
            MessageEvent *message = [NSDatabase getMessageEventWithId: idMessage];
            if (message != nil) {
                UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
                [pasteBoard setString: message.content];
                [self.view makeToast:[appDelegate.localization localizedStringForKey:TEXT_COPIED] duration:3.0 position:CSToastPositionCenter];
            }
            
            break;
        }
        case 1:{
            //  Forward
            ChooseContactsViewController *controller = VIEW(ChooseContactsViewController);
            if (controller != nil) {
                controller._isForwardMessage = YES;
                controller._idForwardMessage = idMessage;
            }
            [[PhoneMainView instance] changeCurrentView:[ChooseContactsViewController compositeViewDescription] push:true];
            break;
        }
        case 2:{
            //  Delete
            BOOL success = [NSDatabase deleteOneMessageWithId: idMessage];
            if (success) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"idMessage = %@", idMessage];
                NSArray *filter = [_listMessages filteredArrayUsingPredicate: predicate];
                if (filter.count > 0) {
                    [_listMessages removeObjectsInArray: filter];
                    [_tbChat reloadData];
                    [self updateFrameOfViewChatWithViewFooter];
                }
                if (_listMessages.count == 0) {
                    _lbNoMessage.hidden = NO;
                }else{
                    _lbNoMessage.hidden = YES;
                }
            }
            break;
        }
        case 3:{
            //  recall
            NSString *user = [NSString stringWithFormat:@"%@/%@", [NSString stringWithFormat:@"%@@%@", remoteParty, xmpp_cloudfone], appDelegate.friendBuddy.resourceStr];
            [appDelegate.myBuddy.protocol sendRequestRecallToUser:user
                                                         fromUser:appDelegate.myBuddy.accountName
                                                         andIdMsg:idMessage];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Khai Le functions

- (void)whenSaveImageForVideoSuccess: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[NSString class]]) {
        MessageEvent *message = [NSDatabase getMessageEventWithId: object];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"idMessage = %@", object];
        NSArray *filter = [_listMessages filteredArrayUsingPredicate: predicate];
        if (filter.count > 0) {
            int replaceIndex = (int)[_listMessages indexOfObject: [filter objectAtIndex: 0]];
            [_listMessages replaceObjectAtIndex:replaceIndex withObject:message];
            
            [_tbChat reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:replaceIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

- (void)updateSeenStatusForMessage: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[NSArray class]]) {
        for (int iCount=0; iCount<[(NSArray *)object count]; iCount++) {
            NSString *idMessage = [object objectAtIndex: iCount];
            MessageEvent *message = [NSDatabase getMessageEventWithId: idMessage];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"idMessage = %@", idMessage];
            NSArray *filter = [_listMessages filteredArrayUsingPredicate: predicate];
            if (filter.count > 0) {
                int replaceIndex = (int)[_listMessages indexOfObject: [filter objectAtIndex: 0]];
                [_listMessages replaceObjectAtIndex:replaceIndex withObject:message];
                
                [_tbChat reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:replaceIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    }
}

- (void)sendMessageDisplayedForRemoteParty: (NSString *)remoteParty {
    NSArray *listIdMsg = [NSDatabase getAllMessageUnseenReceivedOfRemoteParty: remoteParty];
    if (listIdMsg.count > 0) {
        NSString *content = @"";
        for (int iCount=0; iCount<listIdMsg.count; iCount++) {
            NSString *idMessage = [listIdMsg objectAtIndex: iCount];
            if ([content isEqualToString:@""]) {
                content = idMessage;
            }else{
                content = [NSString stringWithFormat:@"%@|%@", content, idMessage];
            }
        }
        
        [appDelegate.myBuddy.protocol sendDisplayedToUser:remoteParty fromUser:USERNAME andListIdMsg:content];
    }
    [NSDatabase updateAllMessageUnSeenReceivedOfRemoteParty: remoteParty];
}

- (void)deleteConversationSuccess {
    [_listMessages removeAllObjects];
    [_tbChat reloadData];
    appDelegate._heightChatTbView = 0.0;
    [_lbNoMessage setHidden: false];
}

//  Xử lý recall message
- (void)updateViewChatAfterRecallMessage: (NSNotification *)notif {
    
    id object = [notif object];
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSString *idMessage = [object objectForKey: @"idMessage"];
        //  update content database
        [NSDatabase setRecallForMessage: idMessage];
        
        MessageEvent *message = [NSDatabase getMessageEventWithId: idMessage];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"idMessage = %@", idMessage];
        NSArray *filter = [_listMessages filteredArrayUsingPredicate: predicate];
        if (filter.count > 0) {
            int replaceIndex = (int)[_listMessages indexOfObject: [filter objectAtIndex: 0]];
            [_listMessages replaceObjectAtIndex:replaceIndex withObject:message];
            
            [_tbChat reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:replaceIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
        
        int showPopup = [[object objectForKey:@"showPopup"] intValue];
        if (showPopup == 1) {
            [self.view makeToast:[appDelegate.localization localizedStringForKey:TEXT_MESSSAGE_SENT_RECALLED]
                        duration:1.5 position:CSToastPositionCenter];
        }
    }
}

- (void)whenLongGestureOnMessage: (NSNotification *)notif {
    NSString *idMessage = [notif object];
    MessageEvent *message = [NSDatabase getMessageEventWithId: idMessage];
    if ([message.sendPhone isEqualToString:USERNAME]) {
        [self createDataWhenTouchOnMyMessage];
    }else{
        [self createDataWhenTouchOnOtherMessage];
    }
    [self showPopupWhenTouchMessage: message.idMessage];
}

//  Hiển thị popup khi touch vào message
- (void)showPopupWhenTouchMessage: (NSString *)idMessage
{
    CGRect popupRect = CGRectMake((SCREEN_WIDTH-230-6)/2, (SCREEN_HEIGHT-20-(touchMessageArr.count*40+6))/2, 230+6, touchMessageArr.count*40+5);
    popUpTouchMessage = [[SettingPopupView alloc] initWithFrame: popupRect];
    popUpTouchMessage.idMessage = idMessage;
    [popUpTouchMessage saveListOptions: touchMessageArr];
    popUpTouchMessage.delegate = self;
    [popUpTouchMessage showInView:appDelegate.window animated:YES];
}

//  TẠO DỮ LIỆU KHI TOUCH VÀO MESSAGE CỦA MÌNH
- (void)createDataWhenTouchOnMyMessage {
    if (touchMessageArr == nil) {
        touchMessageArr = [[NSMutableArray alloc] init];
    }
    [touchMessageArr removeAllObjects];
    
    SettingItem *copy = [[SettingItem alloc] init];
    copy._imageStr = @"copy.png";
    copy._valueStr = [appDelegate.localization localizedStringForKey:text_message_copy];
    [touchMessageArr addObject: copy];
    
    SettingItem *forward = [[SettingItem alloc] init];
    forward._imageStr = @"forward.png";
    forward._valueStr = [appDelegate.localization localizedStringForKey:text_message_forward];
    [touchMessageArr addObject: forward];
    
    SettingItem *delete = [[SettingItem alloc] init];
    delete._imageStr = @"delete_conversation.png";
    delete._valueStr = [appDelegate.localization localizedStringForKey:text_message_delete];
    [touchMessageArr addObject: delete];
    
    SettingItem *recall = [[SettingItem alloc] init];
    recall._imageStr = @"recall.png";
    recall._valueStr = [appDelegate.localization localizedStringForKey:text_message_recall];
    [touchMessageArr addObject: recall];
}

- (void)createDataWhenTouchOnOtherMessage {
    if (touchMessageArr == nil) {
        touchMessageArr = [[NSMutableArray alloc] init];
    }
    [touchMessageArr removeAllObjects];
    
    SettingItem *copy = [[SettingItem alloc] init];
    copy._imageStr = @"copy.png";
    copy._valueStr = [appDelegate.localization localizedStringForKey:text_message_copy];
    [touchMessageArr addObject: copy];
    
    SettingItem *forward = [[SettingItem alloc] init];
    forward._imageStr = @"forward.png";
    forward._valueStr = [appDelegate.localization localizedStringForKey:text_message_forward];
    [touchMessageArr addObject: forward];
    
    SettingItem *delete = [[SettingItem alloc] init];
    delete._imageStr = @"delete_conversation.png";
    delete._valueStr = [appDelegate.localization localizedStringForKey:text_message_delete];
    [touchMessageArr addObject: delete];
}

//  Cập nhật trạng thái của message sau khi nhận delivered text message
- (void)updateReceiveMessage: (NSNotification *)notif
{
    id object = [notif object];
    if ([object isKindOfClass:[NSString class]]) {
        NSString *idMessage = (NSString *)object;
        [self updateDeliveredForMessage:idMessage withValue:2];
    }
}

- (void)updateDeliveredForMessage: (NSString *)idMessage withValue: (int)delivered 
{
    [NSDatabase updateMessageDelivered: idMessage withValue:delivered];
    
    MessageEvent *message = [NSDatabase getMessageEventWithId: idMessage];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"idMessage = %@", idMessage];
    NSArray *filter = [_listMessages filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        int replaceIndex = (int)[_listMessages indexOfObject: [filter objectAtIndex: 0]];
        [_listMessages replaceObjectAtIndex:replaceIndex withObject:message];
        
        [_tbChat reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:replaceIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)clickToPlayVideo: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[NSDictionary class]])
    {
        NSString *sendPhone = [object objectForKey:@"send_phone"];
        NSString *content = [object objectForKey:@"content"];
        NSString *idMessage = [object objectForKey:@"id_message"];
        
        if ([sendPhone isEqualToString:USERNAME]) {
            NSURL *videoURL = [NSURL fileURLWithPath: content];
            [self playVideoWithURL: videoURL];
        }else{
            BOOL downloaded = [NSDatabase checkVideoHadDownloadedFromServer: content];
            if (!downloaded) {
                [self downloadVideoFromServerWithName: content andIdMessage: idMessage];
            }else{
                NSURL *videoURL = [NSDatabase getUrlOfVideoFile: content];
                [self playVideoWithURL: videoURL];
            }
        }
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
        _iconSend.hidden = NO;
        _iconMore.hidden = YES;
        
        CGFloat fixedWidth = 200;
        CGSize newSize = [_tvMessage sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        CGRect newFrame = [_tvMessage frame];
        if (newSize.height < hChatBox-6) {
            newFrame.size = CGSizeMake(_tvMessage.frame.size.width, hChatBox-6);
        }else{
            newFrame.size = CGSizeMake(_tvMessage.frame.size.width, newSize.height);
        }
        _tvMessage.frame = newFrame;
        _viewFooter.frame = CGRectMake(0, SCREEN_HEIGHT-appDelegate._hStatus-hViewEmotion-_tvMessage.frame.size.height-6, _viewFooter.frame.size.width, _tvMessage.frame.size.height+6);
        lbChatComposing.frame = CGRectMake(10, _viewFooter.frame.origin.y-15, SCREEN_WIDTH-20, 20);
        
        //  Cập nhật vị trí view chat theo view footer
        [self updateFrameOfViewChatWithViewFooter];
    }else{
        _iconSend.hidden = YES;
        _iconMore.hidden = NO;
    }
}

- (void)whenSentImageForUser: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[UIImage class]])
    {
        NSString *idMsgImage = [NSString stringWithFormat:@"userimage_%@", [AppUtils randomStringWithLength: 20]];
        NSString *detailURL = [NSString stringWithFormat:@"%@_%@.jpg", USERNAME, [AppUtils randomStringWithLength:20]];
        
        int delivered = 0;
        if (appDelegate.xmppStream.isConnected) {
            delivered = 1;
        }
        
        NSArray *fileNameArr = [AppUtils saveImageToFiles: appDelegate.imageChoose withImage: detailURL];
        detailURL = [fileNameArr objectAtIndex: 0];
        NSString *thumbURL = [fileNameArr objectAtIndex: 1];
        
        int burnMessage = [AppUtils getBurnMessageValueOfRemoteParty: remoteParty];
        [NSDatabase saveMessage:USERNAME toPhone:remoteParty withContent:@"" andStatus:NO withDelivered:delivered andIdMsg:idMsgImage detailsUrl:detailURL andThumbUrl:thumbURL withTypeMessage:imageMessage andExpireTime:burnMessage andRoomID:@"" andExtra:nil andDesc:appDelegate.titleCaption];
        
        //  Thêm message tạm vào view chat
        MessageEvent *message = [NSDatabase getMessageEventWithId: idMsgImage];
        [self updateTableView: message];
        /*  Leo Kelvin
        [self updateAllFrameForController: false];
        [self updateAndGotoLastViewChat];   */
        
        //  Upload image lên server
        [self startUploadImage:appDelegate.imageChoose toServerWithMessageId:idMsgImage andName:detailURL];
    }
}

- (void)startUploadImage: (UIImage *)uploadImage toServerWithMessageId: (NSString *)idMessage andName: (NSString *)imageName
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *imageData = UIImageJPEGRepresentation(uploadImage, 1.0);
        UploadPicture *session = [[UploadPicture alloc] init];
        session.idMessage = idMessage;
        
        [session uploadData:imageData withName:imageName beginUploadBlock:nil finishUploadBlock:^(UploadPicture *uploadSession) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateImageSendMessageWithInfo: uploadSession withType: userimage andMessageId:session.idMessage];
                NSLog(@"Da upload xong hinh anh");
            });
        }];
    });
}

- (void)startUploadVideoWithData: (NSData *)videoData toServerWithMessageId: (NSString *)idMessage andName: (NSString *)videoName
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        UploadPicture *session = [[UploadPicture alloc] init];
        session.idMessage = idMessage;
        
        [session uploadData:videoData withName:videoName beginUploadBlock:nil finishUploadBlock:^(UploadPicture *uploadSession) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([uploadSession.namePicture isEqualToString:@"error"])
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[appDelegate.localization localizedStringForKey:text_alert] message:[appDelegate.localization localizedStringForKey:text_cannot_send_video] delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:text_close] otherButtonTitles:nil];
                    [alert show];
                    
                    [self updateDeliveredForMessage:idMessage withValue:0];
                }else{
                    [self updateImageSendMessageWithInfo: uploadSession withType: @"uservideo" andMessageId:session.idMessage];
                    NSLog(@"Da upload xong hinh anh");
                }
            });
        }];
    });
}

- (void)updateImageSendMessageWithInfo: (UploadPicture *)uploadSession withType: (NSString *)typeMedia andMessageId: (NSString *)idOfMsg
{
    if ([uploadSession.namePicture isEqualToString:@"error"]) {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Send failed!!!"] duration:2.0 position:CSToastPositionCenter];
        
        [self updateDeliveredForMessage:uploadSession.idMessage withValue:0];
        
        MessageEvent *message = [NSDatabase getMessageEventWithId: uploadSession.idMessage];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"idMessage = %@", idOfMsg];
        NSArray *updateData = [_listMessages filteredArrayUsingPredicate: predicate];
        if (updateData.count > 0) {
            int replaceIndex = (int)[_listMessages indexOfObject: [updateData objectAtIndex: 0]];
            [_listMessages replaceObjectAtIndex:replaceIndex withObject:message];
            [_tbChat reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:replaceIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }else{
        if (appDelegate.xmppStream.isConnected) {
            [NSDatabase updateMessageDelivered:uploadSession.idMessage withValue:1];
        }
        
        MessageEvent *message = [NSDatabase getMessageEventWithId: uploadSession.idMessage];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"idMessage = %@", idOfMsg];
        NSArray *updateData = [_listMessages filteredArrayUsingPredicate: predicate];
        if (updateData.count > 0) {
            int replaceIndex = (int)[_listMessages indexOfObject: [updateData objectAtIndex: 0]];
            [_listMessages replaceObjectAtIndex:replaceIndex withObject:message];
            
            [self updateDeliveredForMessage:message.idMessage withValue:1];
        }
        //  set link
        [NSDatabase updateContent: uploadSession.namePicture forMessage:idOfMsg];
        
        sendMsgData = nil;
        
        NSString *displayName = [NSDatabase getProfielNameOfAccount: USERNAME];
        
        NSString *strPush = [appDelegate.localization localizedStringForKey:sent_message_to_you];
        if ([typeMedia isEqualToString:userimage]) {
            strPush = [NSString stringWithFormat:@"%@ %@", displayName, [appDelegate.localization localizedStringForKey:sent_photo_to_you]];
        }else if ([typeMedia isEqualToString:@"uservideo"]){
            strPush = [NSString stringWithFormat:@"%@ %@", displayName, [appDelegate.localization localizedStringForKey:sent_video_to_you]];
        }
        [AppUtils sendMessageForOfflineForUser:remoteParty fromSender:USERNAME withContent:strPush andTypeMessage:typeMedia withGroupID:@""];
        
        int burn = [AppUtils getBurnMessageValueOfRemoteParty: remoteParty];
        [appDelegate.myBuddy.protocol sendMessageMediaForUser:remoteParty withLinkImage:uploadSession.namePicture andDescription:appDelegate.titleCaption andIdMessage:idOfMsg andType:typeMedia withBurn:burn forGroup:NO];
    }
    appDelegate.imageChoose = nil;
}

//  Thêm view emotion cho controller
- (void)addEmotionViewForViewChat {
    hViewEmotion = 195.0;
    hTabEmotion = 40;
    
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"EmotionView" owner:nil options:nil];
    for(id currentObject in subviewArray){
        if ([currentObject isKindOfClass:[EmotionView class]]) {
            viewEmotion = (EmotionView *) currentObject;
            [viewEmotion setupBackgroundUIForView];
            break;
        }
    }
    viewEmotion.frame = CGRectMake(0, SCREEN_HEIGHT-appDelegate._hStatus, SCREEN_WIDTH, 0);
    [viewEmotion addContentForEmotionView];
    [viewEmotion._iconDelete addTarget:self
                                action:@selector(onDeleteButtonClicked:)
                      forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: viewEmotion];
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

- (void)addMoreViewForViewChat {
    hViewEmotion = 195.0;
    
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"MoreChatView" owner:nil options:nil];
    for(id currentObject in subviewArray){
        if ([currentObject isKindOfClass:[MoreChatView class]]) {
            viewChatMore = (MoreChatView *) currentObject;
            break;
        }
    }
    [viewChatMore.iconPicture addTarget:self
                                 action:@selector(iconChoosePictureClicked:)
                       forControlEvents:UIControlEventTouchUpInside];
    
    [viewChatMore.iconVideo addTarget:self
                               action:@selector(iconChooseVideoClicked:)
                     forControlEvents:UIControlEventTouchUpInside];
    
    [viewChatMore.iconCamera addTarget:self
                               action:@selector(iconChooseCameraClicked:)
                     forControlEvents:UIControlEventTouchUpInside];
    
    [viewChatMore.iconCall addTarget:self
                              action:@selector(iconChooseCallClicked:)
                    forControlEvents:UIControlEventTouchUpInside];
    
    viewChatMore.frame = CGRectMake(0, SCREEN_HEIGHT-appDelegate._hStatus, SCREEN_WIDTH, 0);
    [viewChatMore setupUIForView: hViewEmotion];
    
    [self.view addSubview: viewChatMore];
}

- (void)afterDownloadImageSuccess: (NSNotification *)notif {
    NSString *idMessage = [notif object];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"idMessage = %@", idMessage];
    NSArray *listSearch = [_listMessages filteredArrayUsingPredicate: predicate];
    if (listSearch.count > 0) {
        MessageEvent *messageEvent = [NSDatabase getMessageEventWithId: idMessage];
        int index = (int)[_listMessages indexOfObject: [listSearch firstObject]];
        [_listMessages replaceObjectAtIndex:index withObject: messageEvent];
        
        [_tbChat reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

//  Thêm message mới vào view chat nếu message là của user
- (void)receiveNewMessage: (NSNotification *)notif
{
    id object = [notif userInfo];
    if ([object isKindOfClass:[NSMutableDictionary class]])
    {
        OTRMessage *message = [object objectForKey:@"message"];
        NSString *user = @"";
        if (message != nil) {
            user = [AppUtils getSipFoneIDFromString: message.buddy.accountName];
        }else{
            user = [object objectForKey:@"user"];
        }
        
        if ([user isEqualToString: remoteParty]) {
            NSString *idMessage = [object objectForKey:@"idMessage"];
            MessageEvent *message = [NSDatabase getMessageEventWithId: idMessage];
            if (message == nil) {
                NSLog(@"Why can not get data of message?");
                return;
            }
            
            if ([message.typeMessage isEqualToString: videoMessage]) {
                [AppUtils savePictureOfVideoToDocument: message];
            }
            message = [NSDatabase getMessageEventWithId: idMessage];    //  get message content again after updated
            
            //  Nếu là mesage hình ảnh or video mà có burn thì phải click vào mới send displayed
            if (message.isBurn && ([message.typeMessage isEqualToString:imageMessage] || [message.typeMessage isEqualToString:videoMessage])) {
                
            }else{
                [appDelegate.myBuddy.protocol sendDisplayedToUser:remoteParty fromUser:USERNAME andListIdMsg:idMessage];
                [NSDatabase updateAllMessageUnSeenReceivedOfRemoteParty: remoteParty];
            }
            
            [self updateTableView: message];
            
            // Post notification để lấy last row visibility
            [[NSNotificationCenter defaultCenter] postNotificationName:getRowsVisibleViewChat object:nil];
            
            [self updateAllFrameForController: false];
            if (appDelegate.lastRowVisibleChat != nil && appDelegate.lastRowVisibleChat.row < _listMessages.count-2) {
                /*  Leo Kelvin
                 CGRect cbRect = _viewFooter.frame;
                 [viewNewMsg setHidden: FALSE];
                 [viewNewMsg setFrame: CGRectMake(viewNewMsg.frame.origin.x, cbRect.origin.y-viewNewMsg.frame.size.height - 3, viewNewMsg.frame.size.width, viewNewMsg.frame.size.height)];  */
            }else{
                [self updateAndGotoLastViewChat];
            }
        }
    }
}

//  Ẩn bàn phím
- (void)keyboardDidHide: (NSNotification *) notif{
    [UIView animateWithDuration:0.05 animations:^{
        
    }];
}

//  Khi show bàn phím chat
- (void)notificationWhenShowKeyboard:(NSNotification*)notification {
    if (hKeyboard == 0) {
        NSDictionary* keyboardInfo = [notification userInfo];
        NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
        CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
        hKeyboard = keyboardFrameBeginRect.size.height;
    }
    
    viewEmotion.frame = CGRectMake(viewEmotion.frame.origin.x, SCREEN_HEIGHT-appDelegate._hStatus, viewEmotion.frame.size.width, 0);
    viewEmotion.alpha = 1.0;
    _iconEmotion.selected = NO;
    
    _viewFooter.frame = CGRectMake(0, SCREEN_HEIGHT-appDelegate._hStatus-hKeyboard-_viewFooter.frame.size.height, SCREEN_WIDTH, _viewFooter.frame.size.height);
    lbChatComposing.frame = CGRectMake(10, _viewFooter.frame.origin.y-15, SCREEN_WIDTH-20, 20);
    
    //  View footer thay đổi thì thay đổi view chat
    [self updateFrameOfViewChatWithViewFooter];
    
    [NSTimer scheduledTimerWithTimeInterval:.5 target:self
                                   selector:@selector(updateAndGotoLastViewChat)
                                   userInfo:nil repeats:NO];
    
    if (![lbChatComposing.text isEqualToString:@""]) {
        [lbChatComposing setFrame:CGRectMake(10, _viewFooter.frame.origin.y-15, SCREEN_WIDTH-20, 20)];
        [lbChatComposing setHidden: NO];
    }
}

//  Double click vào màn hình để change background
- (void)doubleTapToChangeBackground {
    BackgroundViewController *backgroudVC = VIEW(BackgroundViewController);
    if (backgroudVC != nil) {
        [backgroudVC set_chatGroup: false];
    }
    [[PhoneMainView instance] changeCurrentView: [BackgroundViewController compositeViewDescription] push: true];
}

//  Get lịch sử tin nhắn với user
- (void)getHistoryMessagesWithUser: (NSString *)user
{
//    [_listMessages addObjectsFromArray: [NSDatabase getListMessagesHistory:USERNAME withPhone: user]];
    
    [_listMessages addObjectsFromArray:[NSDatabase getListMessagesHistory:USERNAME withPhone:user withCurrentPage:curPage andNumPerPage:numPerPage]];
    
    // Forward tin nhắn nếu có
    if (appDelegate._msgForward != nil) {
        //  Leo Kelvin
        //  [self sendMessageFowardToUser];
    }
    
    // Gửi ảnh hoặc conversation nếu tồn tại
    //  Leo Kelvin
    //  [self sendMessageConversation];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSIndexPath *firstVisibleIndexPath = [[_tbChat indexPathsForVisibleRows] objectAtIndex:0];
    if (firstVisibleIndexPath.row == 1 || firstVisibleIndexPath.row == 0) {
        if (!isLoadMore) {
            if (curPage < totalPage-1) {
                curPage++;
                isLoadMore = YES;
                [self loadMoreHistoryMessages];
            }else{
                NSLog(@"Da tai trang cuoi cung");
            }
        }else{
            NSLog(@"Dang tai them data, khong tai them nua");
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSIndexPath *firstVisibleIndexPath = [[_tbChat indexPathsForVisibleRows] objectAtIndex:0];
    if (firstVisibleIndexPath.row == 1 || firstVisibleIndexPath.row == 0) {
        if (!isLoadMore) {
            if (curPage < totalPage-1) {
                curPage++;
                isLoadMore = YES;
                [self loadMoreHistoryMessages];
            }else{
                NSLog(@"Da tai trang cuoi cung");
            }
        }else{
            NSLog(@"Dang tai them data, khong tai them nua");
        }
    }
}

- (void)loadMoreHistoryMessages
{
    if (viewLoadMore == nil) {
        //  Leo Kelvin
        //  [self createLoadMoreViewForLoadingMessages];
    }
    viewLoadMore.hidden = NO;
    [icLoadMore startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        NSArray *moreData = [NSDatabase getListMessagesHistory:USERNAME withPhone:remoteParty
                                               withCurrentPage:curPage andNumPerPage:numPerPage];
        NSArray *curData = [[NSArray alloc] initWithArray: _listMessages];

        [_listMessages removeAllObjects];
        [_listMessages addObjectsFromArray: moreData];
        [_listMessages addObjectsFromArray: curData];

        dispatch_async(dispatch_get_main_queue(), ^(void){
            float plusHeight = [self getHeightOfListMessage: moreData];
            CGPoint offset = _tbChat.contentOffset;
            [_tbChat reloadData];
            [_tbChat layoutIfNeeded];
            [_tbChat setContentOffset:CGPointMake(offset.x, offset.y+plusHeight)];

            isLoadMore = NO;
            viewLoadMore.hidden = YES;
            [icLoadMore stopAnimating];
        });
    });
}

- (void)createLoadMoreViewForLoadingMessages {
    viewLoadMore = [[UIView alloc] initWithFrame: CGRectMake(0, 0, _viewChat.frame.size.width, 28)];
    viewLoadMore.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
    lbLoadMore = [[UILabel alloc] init];
    lbLoadMore.text = [appDelegate.localization localizedStringForKey:text_load_more];
    lbLoadMore.textColor = [UIColor darkGrayColor];
    [lbLoadMore sizeToFit];
    [viewLoadMore addSubview: lbLoadMore];
    
    float originX = (viewLoadMore.frame.size.width-(28 + 5 +lbLoadMore.frame.size.width))/2;
    icLoadMore = [[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(originX, 0, viewLoadMore.frame.size.height, viewLoadMore.frame.size.height)];
    icLoadMore.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [viewLoadMore addSubview: icLoadMore];
    
    lbLoadMore.frame = CGRectMake(icLoadMore.frame.origin.x+icLoadMore.frame.size.width+5, 0, lbLoadMore.frame.size.width, viewLoadMore.frame.size.height);
    lbLoadMore.font = [UIFont systemFontOfSize:14.0];
    viewLoadMore.hidden = YES;
    
    [_viewChat addSubview: viewLoadMore];
}

//  Cập nhật dữ liệu và scroll đến cuối list
- (void)updateAndGotoLastViewChat {
    //Always scroll the chat table when the user sends the message
    if([self._tbChat numberOfRowsInSection:0]!=0)
    {
        NSIndexPath* ip = [NSIndexPath indexPathForRow:[self._tbChat numberOfRowsInSection:0]-1 inSection:0];
        [self._tbChat scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:UITableViewRowAnimationLeft];
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
    }else if ([_tvMessage isFirstResponder]){
        [_viewFooter setFrame: CGRectMake(0, SCREEN_HEIGHT-appDelegate._hStatus-hKeyboard-heightChatBox, SCREEN_WIDTH, heightChatBox)];
    }else{
        [_viewFooter setFrame: CGRectMake(0, SCREEN_HEIGHT-(appDelegate._hStatus+heightChatBox), SCREEN_WIDTH, heightChatBox)];
    }
    
    //  View footer thay đổi thì thay đổi view chat
    [self updateFrameOfViewChatWithViewFooter];
}

//  set thông tin hiển thị cho phần header chat với user
- (void)setHeaderInfomationOfUser
{
    // setup username
    NSString *contactName =  [NSDatabase getNameOfContactWithPhoneNumber: remoteParty];
    if ([contactName isEqualToString:@""]) {
        contactName = remoteParty;
    }
    _lbUserName.text = contactName;
    [_lbUserName sizeToFit];
    
    NSArray *infos = [NSDatabase getContactNameOfCloudFoneID: remoteParty];
    if (infos.count >= 2) {
        if (![[infos objectAtIndex: 1] isEqualToString:@""]) {
            NSData *data = [NSData dataFromBase64String: [infos objectAtIndex: 1]];
            [appDelegate setUserImage: [UIImage imageWithData: data]];
        }
    }
    [_icSetting setHidden: false];
    
    // set trạng thái của user
    [self setStatusStringOfUser:remoteParty];
    
    if (_lbUserName.frame.size.width > 150) {
        [_lbUserName setFrame: CGRectMake((SCREEN_WIDTH-150)/2, (appDelegate._hHeader-25-20)/2, 150, 25)];
    }else{
        [_lbUserName setFrame: CGRectMake((SCREEN_WIDTH-_lbUserName.frame.size.width)/2, (appDelegate._hHeader-25-20)/2, _lbUserName.frame.size.width, 25)];
    }
    [_icStatus setFrame:CGRectMake(_lbUserName.frame.origin.x-15, _lbUserName.frame.origin.y+(_lbUserName.frame.size.height-12)/2, 12, 12)];
}

//  set trạng thái tương ứng của user
- (void)setStatusStringOfUser: (NSString *)user {
    switch (appDelegate.friendBuddy.status) {
        case -1:{
            [_icStatus setImage: [UIImage imageNamed:@"ic_status_unsubscribed.png"]];
            [_lbStatus setText: [appDelegate.localization localizedStringForKey:text_chat_offline]];
            break;
        }
        case kOTRBuddyStatusOffline:{
            [_icStatus setImage: [UIImage imageNamed:@"ic_status_unavailable.png"]];
            [_lbStatus setText: [appDelegate.localization localizedStringForKey:text_chat_offline]];
            break;
        }
        case kOTRBuddyStatusAvailable:{
            if (appDelegate.friendBuddy.encryptionStatus == kOTRKitMessageStateEncrypted) {
                [_icStatus setImage: [UIImage imageNamed:@"ic_status_encripted.png"]];
            }else{
                [_icStatus setImage: [UIImage imageNamed:@"ic_status_available.png"]];
            }
            NSString *statusStr = [appDelegate._statusXMPPDict objectForKey: remoteParty];
            if (statusStr == nil || [statusStr isEqualToString:@""]) {
                statusStr = welcomeToCloudFone;
            }
            [_lbStatus setText: statusStr];
            break;
        }
    }
    
    [_lbStatus sizeToFit];
    CGRect fitRect = [_lbStatus frame];
    if (fitRect.size.width > 220) {
        [_lbStatus setFrame: CGRectMake((SCREEN_WIDTH-220)/2, _lbUserName.frame.origin.y+_lbUserName.frame.size.height, 220, 20)];
    }else{
        [_lbStatus setFrame: CGRectMake((SCREEN_WIDTH-fitRect.size.width)/2, _lbUserName.frame.origin.y+_lbUserName.frame.size.height, fitRect.size.width, 20)];
    }
}

- (void)setBuddy:(OTRBuddy *)newBuddy {
    if(appDelegate.friendBuddy) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MESSAGE_PROCESSED_NOTIFICATION
                                                      object:appDelegate.friendBuddy];
    }
    [self saveCurrentMessageText];
    
    appDelegate.friendBuddy = newBuddy;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageProcessedNotification:)
                                                 name:MESSAGE_PROCESSED_NOTIFICATION object:appDelegate.friendBuddy];
}

- (void)saveCurrentMessageText {
    appDelegate.friendBuddy.composingMessageString = _tvMessage.text;
    if(![appDelegate.friendBuddy.composingMessageString length]) {
        [appDelegate.friendBuddy sendInactiveChatState];
    }
}

// Xử lý khi nhận được Notification
- (void)messageProcessedNotification:(NSNotification*)notification {
    id object = [notification object];
    if ([object isKindOfClass:[OTRBuddy class]]) {
        NSString *buddyStr = [self getAccountNameFromString: [(OTRBuddy *)object accountName]];
        NSString *currentStr = [self getAccountNameFromString: appDelegate.friendBuddy.accountName];
        if ([buddyStr isEqualToString: currentStr]) {
            appDelegate.friendBuddy.chatState = [(OTRBuddy *)object chatState];
            [self updateChatState:true];
        }
    }
}

//  Cập nhật trạng thái đang nhập của user
- (void)updateChatState:(BOOL)animated {
    if(appDelegate.friendBuddy.chatState == kOTRChatStateComposing) {
        [lbChatComposing setFrame:CGRectMake(10, _viewFooter.frame.origin.y-15, SCREEN_WIDTH-20, 20)];
        [lbChatComposing setText: [appDelegate.localization localizedStringForKey:text_is_typing]];
        [lbChatComposing setHidden: false];
        
        [_tbChat setFrame:CGRectMake(_tbChat.frame.origin.x, _tbChat.frame.origin.y, _tbChat.frame.size.width, _viewChat.frame.size.height-20)];
        
        // Nếu nhận composing và đang ở cuối khung chat thì đẩy tableview chat lên
        NSArray *tmpArr = [_tbChat indexPathsForVisibleRows];
        if (tmpArr.count > 0) {
            NSIndexPath *lastIndex = [tmpArr lastObject];
            if (lastIndex.row == _listMessages.count-1) {
                /*  Leo Kelvin
                NSIndexPath* ip = [NSIndexPath indexPathForRow:(_listMessages.count - 1) inSection:0];
                [_tbChat scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
                [viewNewMsg setHidden: true];
                */
            }
        }
    }else if(appDelegate.friendBuddy.chatState == kOTRChatStateActive) {
        [_tbChat setFrame:CGRectMake(_tbChat.frame.origin.x, _tbChat.frame.origin.y, _tbChat.frame.size.width, _viewChat.frame.size.height-10)];
        [lbChatComposing setHidden: true];
        [lbChatComposing setText:@""];
    }else{
        //  Hết send composing
        [_tbChat setFrame:CGRectMake(_tbChat.frame.origin.x, _tbChat.frame.origin.y, _tbChat.frame.size.width, _viewChat.frame.size.height-10)];
        [lbChatComposing setHidden: true];
    }
}

- (NSString *)getAccountNameFromString: (NSString *)string {
    NSString *result = @"";
    NSRange range = [string rangeOfString:[NSString stringWithFormat:@"@%@", xmpp_cloudfone]];
    if (range.location != NSNotFound) {
        result = [string substringToIndex: range.location+range.length];
    }else{
        string = [string stringByReplacingOccurrencesOfString:single_cloudfone withString:xmpp_cloudfone];
        range = [string rangeOfString:[NSString stringWithFormat:@"@%@", xmpp_cloudfone]];
        if (range.location != NSNotFound) {
            result = [string substringToIndex: range.location+range.length];
        }
    }
    return result;
}

//  Đóng bàn phím chat
- (void)dismissKeyboard {
    [self.view endEditing: true];
    _iconMore.selected = NO;
    
    [UIView animateWithDuration:0.2 animations:^{
        viewEmotion.frame = CGRectMake(viewEmotion.frame.origin.x, SCREEN_HEIGHT-appDelegate._hStatus, viewEmotion.frame.size.width, 0);
        viewChatMore.frame = CGRectMake(viewChatMore.frame.origin.x, SCREEN_HEIGHT-appDelegate._hStatus, viewChatMore.frame.size.width, 0);
        _viewFooter.frame = CGRectMake(_viewFooter.frame.origin.x, SCREEN_HEIGHT-appDelegate._hStatus-_viewFooter.frame.size.height, _viewFooter.frame.size.width, _viewFooter.frame.size.height);
        lbChatComposing.frame = CGRectMake(10, _viewFooter.frame.origin.y-15, SCREEN_WIDTH-20, 20);
        
        //  View footer thay đổi thì thay đổi view chat
        [self updateFrameOfViewChatWithViewFooter];
    }];
}

//  Cập nhật vị trí view chat theo view footer
- (void)updateFrameOfViewChatWithViewFooter {
    _viewChat.frame = CGRectMake(_viewChat.frame.origin.x, _viewChat.frame.origin.y, _viewChat.frame.size.width, _viewFooter.frame.origin.y-_viewChat.frame.origin.y);
    _lbNoMessage.frame = _viewChat.frame;
    
    float tmpHeight = [self getHeightOfAllMessageOfUserWithMaxHeight: _viewChat.frame.size.height];
    if (tmpHeight >= _viewChat.frame.size.height) {
        _tbChat.frame = CGRectMake(_tbChat.frame.origin.x, 5, _tbChat.frame.size.width, _viewChat.frame.size.height-5);
        _tbChat.scrollEnabled = YES;
    }else{
        _tbChat.frame = CGRectMake(_tbChat.frame.origin.x, _viewChat.frame.size.height-tmpHeight, _tbChat.frame.size.width, tmpHeight);
        _tbChat.scrollEnabled = NO;
    }
}

//  Trả về chiều cao của các tin nhắn của user
- (float)getHeightOfAllMessageOfUserWithMaxHeight: (float)maxHeight {
    float totalHeight = 0;
    for (int iCount=0; iCount<_listMessages.count; iCount++) {
        MessageEvent *curMessage = [_listMessages objectAtIndex: iCount];
        totalHeight = totalHeight + [self getHeightOfMessage: curMessage];
        if (totalHeight >= maxHeight) {
            break;
        }
    }
    return totalHeight;
}

- (float)getHeightOfListMessage: (NSArray *)listMsgs {
    float totalHeight = 0;
    for (int iCount=0; iCount<listMsgs.count; iCount++) {
        MessageEvent *curMessage = [listMsgs objectAtIndex: iCount];
        totalHeight = totalHeight + [self getHeightOfMessage: curMessage];
    }
    return totalHeight;
}

- (void)setupUIForView {
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }else{
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
    }
    
    //  view header
    _viewHeader.frame = CGRectMake(0, 0, SCREEN_WIDTH, appDelegate._hHeader);
    _iconBack.frame = CGRectMake(0, 0, appDelegate._hHeader, appDelegate._hHeader);
    [_iconBack setBackgroundImage:[UIImage imageNamed:@"ic_back_act.png"]
                         forState:UIControlStateHighlighted];
    _icSetting.frame = CGRectMake(_viewHeader.frame.size.width-_iconBack.frame.size.width, _iconBack.frame.origin.y, _iconBack.frame.size.width, _iconBack.frame.size.height);
    [_icSetting setBackgroundImage:[UIImage imageNamed:@"ic_menu_more_act"]
                          forState:UIControlStateHighlighted];
    
    // view footer
    if (SCREEN_WIDTH > 320) {
        hChatBox = 46.0;
        hChatIcon = 35.0;
    }else{
        hChatBox = 38.0;
        hChatIcon = 30.0;
    }
    
    _viewFooter.frame = CGRectMake(0, SCREEN_HEIGHT-(appDelegate._hStatus+hChatBox), SCREEN_WIDTH, hChatBox);
    _icCamera.frame = CGRectMake(5, (hChatBox-hChatIcon)/2, hChatIcon, hChatIcon);
    _iconSend.frame = CGRectMake(_viewFooter.frame.size.width-hChatBox, 0, hChatBox, hChatBox);
    _iconMore.frame = _iconSend.frame;
    [_iconMore setBackgroundImage:[UIImage imageNamed:@"ic_more"]
                         forState:UIControlStateNormal];
    [_iconMore setBackgroundImage:[UIImage imageNamed:@"ic_more_close"]
                         forState:UIControlStateSelected];
    
    _iconEmotion.frame = CGRectMake(_iconSend.frame.origin.x-_iconSend.frame.size.width, _iconSend.frame.origin.y, _iconSend.frame.size.width, _iconSend.frame.size.height);
    
    _tvMessage.frame = CGRectMake(_icCamera.frame.origin.x+_icCamera.frame.size.width+5, 3, _iconEmotion.frame.origin.x-5-(_icCamera.frame.origin.x+_icCamera.frame.size.width+5), hChatBox-6);
    _tvMessage.font = textFont;
    
    // label placeholder
    lbPlaceHolder = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, _tvMessage.frame.size.width-8, _tvMessage.frame.size.height)];
    lbPlaceHolder.textColor = UIColor.grayColor;
    lbPlaceHolder.text = [appDelegate.localization localizedStringForKey:text_type_to_composte];
    lbPlaceHolder.font = textFont;
    
    [_tvMessage addSubview: lbPlaceHolder];
    _tvMessage.scrollEnabled = FALSE;
    _tvMessage.delegate = self;
    
    _bgChat.frame = CGRectMake(0, _viewHeader.frame.origin.y+_viewHeader.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT-(appDelegate._hStatus+appDelegate._hHeader+hChatBox));
    _bgChat.image = [UIImage imageNamed:@"bg_chat_default.jpg"];
    
    _lbNoMessage.frame = _bgChat.frame;
    _lbNoMessage.backgroundColor = UIColor.clearColor;
    _lbNoMessage.textAlignment = NSTextAlignmentCenter;
    _lbNoMessage.font = [UIFont fontWithName:HelveticaNeue size:16.0];
    _lbNoMessage.text = [appDelegate.localization localizedStringForKey:text_no_message];
    _lbNoMessage.hidden = TRUE;
    
    _viewChat.frame = _bgChat.frame;
    _viewChat.backgroundColor = UIColor.clearColor;
    
    // chat tableview
    _tbChat.frame = CGRectMake(0, 5, _viewChat.frame.size.width, _viewChat.frame.size.height-10);
    _tbChat.backgroundColor = [UIColor clearColor];
    _tbChat.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tbChat.delegate = self;
    _tbChat.dataSource = self;
    
    /*Uncomment second para and comment first to use XIB instead of code*/
    //Registering custom Chat table view cell for both sending and receiving
    [_tbChat registerClass:[ChatMediaTableViewCell class] forCellReuseIdentifier:@"chatSend"];
    [_tbChat registerClass:[ChatTableViewCell class] forCellReuseIdentifier:@"chatSend"];
    [_tbChat registerClass:[ChatMediaTableViewCell class] forCellReuseIdentifier:@"chatReceive"];
    [_tbChat registerClass:[ChatTableViewCell class] forCellReuseIdentifier:@"chatReceive"];
    
    // Khai báo label chat composite
    lbChatComposing = [[UILabel alloc] init];
    lbChatComposing.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    lbChatComposing.tag = 888;
    lbChatComposing.textColor = [UIColor colorWithRed:(71/255.0) green:(32/255.0) blue:(102/255.0) alpha:1.0];
    lbChatComposing.backgroundColor = UIColor.clearColor;
    lbChatComposing.font = [UIFont fontWithName:HelveticaNeueItalic size:13.0];
    [self.view addSubview: lbChatComposing];
    
    //  username label and status label
    _lbUserName.marqueeType = MLContinuous;
    _lbUserName.scrollDuration = 15.0f;
    _lbUserName.animationCurve = UIViewAnimationOptionCurveEaseOut;
    _lbUserName.fadeLength = 10.0f;
    _lbUserName.continuousMarqueeExtraBuffer = 10.0f;
    _lbUserName.textColor = UIColor.whiteColor;
    _lbUserName.backgroundColor = UIColor.clearColor;
    _lbUserName.textAlignment = NSTextAlignmentCenter;
    _lbUserName.font = [UIFont fontWithName:HelveticaNeue size:15.0];
    
    
    _lbStatus.scrollDuration = 15.0f;
    _lbStatus.animationCurve = UIViewAnimationOptionCurveEaseOut;
    _lbStatus.fadeLength = 10.0f;
    _lbStatus.continuousMarqueeExtraBuffer = 10.0f;
    _lbStatus.textColor = UIColor.whiteColor;
    _lbStatus.backgroundColor = UIColor.clearColor;
    _lbStatus.textAlignment = NSTextAlignmentCenter;
    _lbStatus.font = [UIFont fontWithName:HelveticaNeue size:12.0];
}

- (IBAction)btnSendPressed:(UIButton *)sender {
    iMessage *sendMessage;
    
    sendMessage = [[iMessage alloc] initIMessageWithName:@"Prateek Grover" message:@"Hello Chao" time:@"23:14" type:@"self"];
    
    //  [self updateTableView:sendMessage];
}

- (IBAction)btnReceivePressed:(UIButton *)sender {
    iMessage *receiveMessage;
    
    receiveMessage = [[iMessage alloc] initIMessageWithName:@"Prateek Grover" message:@"Hello Chao" time:@"23:14" type:@"other"];
    
    //  [self updateTableView:receiveMessage];
}

-(void) updateTableView:(MessageEvent *)msg
{
    [self._tbChat beginUpdates];
    
    NSIndexPath *row1 = [NSIndexPath indexPathForRow:_listMessages.count inSection:0];
    [_listMessages insertObject:msg atIndex:_listMessages.count];
    [self._tbChat insertRowsAtIndexPaths:[NSArray arrayWithObjects:row1, nil] withRowAnimation:UITableViewRowAnimationBottom];
    [self._tbChat endUpdates];
    
    //Always scroll the chat table when the user sends the message
    [NSTimer scheduledTimerWithTimeInterval:.3 target:self
                                   selector:@selector(goToBottomView)
                                   userInfo:nil repeats:NO];
}

- (void)goToBottomView {
    if([self._tbChat numberOfRowsInSection:0]!=0)
    {
        NSIndexPath* ip = [NSIndexPath indexPathForRow:[self._tbChat numberOfRowsInSection:0]-1 inSection:0];
        [self._tbChat scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:UITableViewRowAnimationLeft];
    }
}


#pragma mark - UITableViewDatasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _listMessages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageEvent *message = [_listMessages objectAtIndex: indexPath.row];
    if ([message.sendPhone isEqualToString: USERNAME])
    {
        if ([message.typeMessage isEqualToString: typeTextMessage]) {
            ChatTableViewCell *cell = [[ChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"chatSend"];
            
            cell.chatTimeLabel.text = message.dateTime;
            cell.chatUserImage.image = myAvatar;
            cell.authorType = iMessageBubbleTableViewCellAuthorTypeSender;
            cell.messageId = message.idMessage;
            
            if ([message.status isEqualToString:@"YES"]) {
                cell.chatMessageStatus.image = [UIImage imageNamed:@"ic_seen"];
            }else{
                switch (message.deliveredStatus) {
                    case eMessageError:{
                        cell.chatMessageStatus.image = [UIImage imageNamed:@"chat_message_not_delivered"];
                        break;
                    }
                    case eMessageSend:{
                        cell.chatMessageStatus.image = [UIImage imageNamed:@"chat_message_inprogress"];
                        break;
                    }
                    case eMessageReceive:{
                        cell.chatMessageStatus.image = [UIImage imageNamed:@"chat_message_delivered"];
                        break;
                    }
                }
            }
            
            //  check burn message
            if (message.isBurn) {
                cell.chatMessageBurn.hidden = NO;
            }else{
                cell.chatMessageBurn.hidden = YES;
            }
            
            if ([message.isRecall isEqualToString:@"YES"]) {
                [message.contentAttrString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:15.0] range:NSMakeRange(0, message.contentAttrString.length)];
                [message.contentAttrString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, message.contentAttrString.length)];
            }
            cell.chatMessageLabel.attributedText = message.contentAttrString;
            return cell;
        }else{
            ChatMediaTableViewCell *cell = [[ChatMediaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"chatSend"];
            cell.delegate = self;
            cell.messageEvent = message;
            
            cell.chatMessageImage.image = [AppUtils getImageDataWithName: message.thumbUrl];
            cell.chatTimeLabel.text = message.dateTime;
            cell.chatUserImage.image = myAvatar;
            cell.messageId = message.idMessage;
            
            cell.authorType = iMessageBubbleTableViewCellAuthorTypeSender;
            
            if ([message.status isEqualToString:@"YES"]) {
                cell.chatMessageStatus.image = [UIImage imageNamed:@"ic_seen"];
            }else{
                switch (message.deliveredStatus) {
                    case eMessageError:{
                        cell.chatMessageStatus.image = [UIImage imageNamed:@"chat_message_not_delivered"];
                        break;
                    }
                    case eMessageSend:{
                        cell.chatMessageStatus.image = [UIImage imageNamed:@"chat_message_inprogress"];
                        break;
                    }
                    case eMessageReceive:{
                        cell.chatMessageStatus.image = [UIImage imageNamed:@"chat_message_delivered"];
                        break;
                    }
                }
            }
            
            //  check burn message
            if (message.isBurn) {
                cell.chatMessageBurn.hidden = NO;
            }else{
                cell.chatMessageBurn.hidden = YES;
            }
            
            if ([message.typeMessage isEqualToString:videoMessage]) {
                cell.playVideoImage.hidden = NO;
            }else if ([message.typeMessage isEqualToString:imageMessage]){
                cell.playVideoImage.hidden = YES;
            }
            if ([message.isRecall isEqualToString:@"YES"]) {
                [message.contentAttrString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:15.0] range:NSMakeRange(0, message.contentAttrString.length)];
                [message.contentAttrString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, message.contentAttrString.length)];
            }
            return cell;
        }
    }else{
        if ([message.typeMessage isEqualToString: typeTextMessage]) {
            ChatLeftTableViewCell *cell = [[ChatLeftTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"chatReceive"];
            cell.chatMessageLabel.attributedText = message.contentAttrString;
            cell.chatTimeLabel.text = message.dateTime;
            cell.chatUserImage.image = friendAvatar;
            cell.authorType = iMessageBubbleTableViewCellAuthorTypeReceiver;
            cell.messageId = message.idMessage;
            
            //  check burn message
            if (message.isBurn) {
                cell.chatMessageBurn.hidden = NO;
            }else{
                cell.chatMessageBurn.hidden = YES;
            }
            if ([message.isRecall isEqualToString:@"YES"]) {
                [message.contentAttrString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:15.0] range:NSMakeRange(0, message.contentAttrString.length)];
                [message.contentAttrString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, message.contentAttrString.length)];
            }
            return cell;
        }else{
            ChatLeftMediaTableViewCell *cell = [[ChatLeftMediaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"chatReceive"];
            cell.delegate = self;
            cell.messageEvent = message;
            cell.authorType = iMessageBubbleTableViewCellAuthorTypeReceiver;
            
            cell.chatTimeLabel.text = message.dateTime;
            cell.chatUserImage.image = friendAvatar;
            cell.messageId = message.idMessage;
            
            if ([message.typeMessage isEqualToString:videoMessage]) {
                cell.playVideoImage.hidden = NO;
            }else if ([message.typeMessage isEqualToString:imageMessage]){
                cell.playVideoImage.hidden = YES;
            }
            
            //  check burn message
            if (message.isBurn) {
                cell.chatMessageBurn.hidden = NO;
                if ([message.status isEqualToString:@"NO"]) {
                    cell.chatMessageImage.image = [UIImage imageNamed:[appDelegate.localization localizedStringForKey:click_to_view_img]];
                }else{
                    cell.chatMessageImage.image = [AppUtils getImageDataWithName: message.thumbUrl];
                }
            }else{
                cell.chatMessageBurn.hidden = YES;
                cell.chatMessageImage.image = [AppUtils getImageDataWithName: message.thumbUrl];
            }
            if ([message.isRecall isEqualToString:@"YES"]) {
                [message.contentAttrString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:15.0] range:NSMakeRange(0, message.contentAttrString.length)];
                [message.contentAttrString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, message.contentAttrString.length)];
            }
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageEvent *message = [_listMessages objectAtIndex:indexPath.row];
    return [self getHeightOfMessage: message];
}

- (CGFloat)getHeightOfMessage: (MessageEvent *)message {
    CGSize size;
    
    CGSize Timesize;
    CGSize Messagesize;
    
    NSArray *fontArray = [[NSArray alloc] init];
    
    //Get the chal cell font settings. This is to correctly find out the height of each of the cell according to the text written in those cells which change according to their fonts and sizes.
    //If you want to keep the same font sizes for both sender and receiver cells then remove this code and manually enter the font name with size in Namesize, Messagesize and Timesize.
    if ([message.typeMessage isEqualToString: imageMessage] || [message.typeMessage isEqualToString: videoMessage]) {
        return 194.0;
    }else{
        if([message.sendPhone isEqualToString:USERNAME])
        {
            fontArray = chatCellSettings.getSenderBubbleFontWithSize;
        }
        else
        {
            fontArray = chatCellSettings.getReceiverBubbleFontWithSize;
        }
        
        //Find the required cell height
        
        NSMutableAttributedString *msgAttributeString = [AppUtils convertMessageStringToEmojiString: message.content];
        Messagesize = [msgAttributeString.string boundingRectWithSize:CGSizeMake(220.0f, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:fontArray[1]}
                                                    context:nil].size;
        
        
        Timesize = [@"Time" boundingRectWithSize:CGSizeMake(220.0f, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:fontArray[2]}
                                         context:nil].size;
        
        //  Close by KHai Le
        //  size.height = Messagesize.height + Namesize.height + Timesize.height + 48.0f;
        size.height = Messagesize.height + Timesize.height + 32.0f;
        
        return size.height;
    }
}

- (void)clickOnPictureOfMessage:(MessageEvent *)messageEvent {
    if ([messageEvent.typeMessage isEqualToString: imageMessage]) {
        if (viewPictures == nil) {
            [self addPicturesViewForMainView];
        }
        
        if (messageEvent.isBurn && [messageEvent.status isEqualToString:@"NO"]) {
            [appDelegate.myBuddy.protocol sendDisplayedToUser:remoteParty fromUser:USERNAME andListIdMsg:messageEvent.idMessage];
            [NSDatabase updateSeenForMessage: messageEvent.idMessage];
            
            NSInteger index = [_listMessages indexOfObject: messageEvent];
            if (index != NSNotFound) {
                MessageEvent *newMessageEvent = [NSDatabase getMessageEventWithId: messageEvent.idMessage];
                if (newMessageEvent != nil) {
                    [_listMessages replaceObjectAtIndex:index withObject:newMessageEvent];
                    
                    [_tbChat reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                                   withRowAnimation:UITableViewRowAnimationNone];
                }
            }
        }
        viewPictures.isGroup = NO;
        viewPictures._remoteParty = remoteParty;
        viewPictures._idMessageShow = messageEvent.idMessage;
        viewPictures._clvPictures.hidden = YES;
        [UIView animateWithDuration:0.2 animations:^{
            viewPictures.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-appDelegate._hStatus);
        }completion:^(BOOL finished) {
            [viewPictures loadListPictureForView];
        }];
    }else if ([messageEvent.typeMessage isEqualToString: videoMessage]){
        
        if ([messageEvent.sendPhone isEqualToString:USERNAME]) {
            NSURL *videoURL = [NSURL fileURLWithPath: messageEvent.content];
            [self playVideoWithURL: videoURL];
        }else{
            BOOL downloaded = [NSDatabase checkVideoHadDownloadedFromServer: messageEvent.content];
            if (!downloaded) {
                [self downloadVideoFromServerWithName: messageEvent.content andIdMessage: messageEvent.idMessage];
            }else{
                NSURL *videoURL = [NSDatabase getUrlOfVideoFile: messageEvent.content];
                [self playVideoWithURL: videoURL];
            }
        }
    }
}

- (IBAction)_iconSendClicked:(UIButton *)sender {
    //  Tạo data cho tin nhắn và lưu vào list
    NSString *messageSend = [self convertEmojiToString: _tvMessage.text];
    
    int deliveredStatus = 0;
    if (appDelegate.xmppStream.isConnected) {
        deliveredStatus = 1;
    }
    
    NSString *idMessage = [AppUtils randomStringWithLength: 10];
    int burnMessage = [AppUtils getBurnMessageValueOfRemoteParty: remoteParty];
    
    [NSDatabase saveMessage:USERNAME toPhone:remoteParty withContent:messageSend andStatus:NO withDelivered:deliveredStatus andIdMsg:idMessage detailsUrl:@"" andThumbUrl:@"" withTypeMessage:typeTextMessage andExpireTime:burnMessage andRoomID:@"" andExtra:@"" andDesc:@""];
    
    MessageEvent *curMessage = [NSDatabase getMessageEventWithId: idMessage];
    if (curMessage == nil) {
        NSLog(@"Why can not get data of message?");
        return;
    }
    [self updateTableView: curMessage];
    
    // send message
    [appDelegate.friendBuddy sendMessage: messageSend secure:NO withIdMessage:idMessage];
    
    //  push message
    //  Leo Kelvin
    //  sendMsgData = nil;
    NSString *displayName = [NSDatabase getProfielNameOfAccount: USERNAME];
    NSString *strPush = [NSString stringWithFormat:@"%@: %@", displayName, messageSend];
    [AppUtils sendMessageForOfflineForUser:remoteParty fromSender:USERNAME withContent:strPush andTypeMessage:@"text" withGroupID:@""];
    
    // setup các UI
    _lbNoMessage.hidden = YES;
    lbPlaceHolder.hidden = NO;
    _tvMessage.text = @"";
    _tvMessage.scrollEnabled = NO;
    _iconSend.hidden = YES;
    _iconMore.hidden = NO;
    _iconMore.selected = NO;
    
    [self updateAllFrameForController: true];
    //  Leo Kelvin
    /*
    [self updateAndGotoLastViewChat];
    */
    [_tvMessage setFrame: CGRectMake(_tvMessage.frame.origin.x, 3, _tvMessage.frame.size.width, hChatBox-6)];
}

- (IBAction)_iconEmotionClicked:(UIButton *)sender {
    [self.view endEditing: true];
    
    if (viewEmotion == nil) {
        [self addEmotionViewForViewChat];
    }
    
    if (viewEmotion.frame.size.height == 0) {
        _iconEmotion.selected = YES;
        
        [UIView animateWithDuration:0.2 animations:^{
            viewEmotion.frame = CGRectMake(0, SCREEN_HEIGHT-(appDelegate._hStatus+hViewEmotion), SCREEN_WIDTH, hViewEmotion);
            [viewEmotion updateFrameForView];
            
            _viewFooter.frame = CGRectMake(_viewFooter.frame.origin.x, viewEmotion.frame.origin.y-_viewFooter.frame.size.height, _viewFooter.frame.size.width, _viewFooter.frame.size.height);
            lbChatComposing.frame = CGRectMake(10, _viewFooter.frame.origin.y-15, SCREEN_WIDTH-20, 20);
            
            //  View footer thay đổi thì thay đổi view chat
            [self updateFrameOfViewChatWithViewFooter];
        }completion:^(BOOL finished) {
            if (viewChatMore.frame.size.height > 0) {
                viewChatMore.frame = CGRectMake(viewChatMore.frame.origin.x, SCREEN_HEIGHT-appDelegate._hStatus, viewChatMore.frame.size.width, 0);
                _iconMore.selected = NO;
            }
        }];
    }else{
        _iconEmotion.selected = NO;
        
        [UIView animateWithDuration:0.2 animations:^{
            viewEmotion.frame = CGRectMake(0, SCREEN_HEIGHT-appDelegate._hStatus, SCREEN_WIDTH, 0);
            
            _viewFooter.frame = CGRectMake(_viewFooter.frame.origin.x, viewEmotion.frame.origin.y-_viewFooter.frame.size.height, _viewFooter.frame.size.width, _viewFooter.frame.size.height);
            lbChatComposing.frame = CGRectMake(10, _viewFooter.frame.origin.y-15, SCREEN_WIDTH-20, 20);
            
            //  View footer thay đổi thì thay đổi view chat
            [self updateFrameOfViewChatWithViewFooter];
        }];
    }
}

- (IBAction)_iconMoreClicked:(UIButton *)sender {
    [self.view endEditing: true];
    
    if (viewChatMore == nil) {
        [self addMoreViewForViewChat];
    }
    
    if (viewChatMore.frame.size.height == 0) {
        _iconMore.selected = YES;
        
        [UIView animateWithDuration:0.2 animations:^{
            viewChatMore.frame = CGRectMake(0, SCREEN_HEIGHT-(appDelegate._hStatus+hViewEmotion), SCREEN_WIDTH, hViewEmotion);
            _viewFooter.frame = CGRectMake(_viewFooter.frame.origin.x, viewChatMore.frame.origin.y-_viewFooter.frame.size.height, _viewFooter.frame.size.width, _viewFooter.frame.size.height);
            lbChatComposing.frame = CGRectMake(10, _viewFooter.frame.origin.y-15, SCREEN_WIDTH-20, 20);
            
            //  View footer thay đổi thì thay đổi view chat
            [self updateFrameOfViewChatWithViewFooter];
        }completion:^(BOOL finished) {
            if (viewEmotion.frame.size.height > 0) {
                viewEmotion.frame = CGRectMake(viewEmotion.frame.origin.x, SCREEN_HEIGHT-appDelegate._hStatus, viewEmotion.frame.size.width, 0);
            }
        }];
    }else{
        _iconMore.selected = NO;
        [UIView animateWithDuration:0.2 animations:^{
            viewChatMore.frame = CGRectMake(0, SCREEN_HEIGHT-appDelegate._hStatus, SCREEN_WIDTH, 0);
            _viewFooter.frame = CGRectMake(_viewFooter.frame.origin.x, viewChatMore.frame.origin.y-_viewFooter.frame.size.height, _viewFooter.frame.size.width, _viewFooter.frame.size.height);
            lbChatComposing.frame = CGRectMake(10, _viewFooter.frame.origin.y-15, SCREEN_WIDTH-20, 20);
            
            //  View footer thay đổi thì thay đổi view chat
            [self updateFrameOfViewChatWithViewFooter];
        }];
    }
}

- (IBAction)_iconBackClicked:(UIButton *)sender {
    appDelegate.reloadMessageList = YES;
    
    //  Clear all all burn message of remoteParty
    [NSDatabase deleteTextAndLocationBurnMessageOfRemoteParty: remoteParty];
    [NSDatabase deleteMediaBurnMessageOfRemoteParty: remoteParty];
    
    [[PhoneMainView instance] popCurrentView];
}

- (IBAction)_iconCameraClicked:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    [picker setDelegate: self];
    [picker setSourceType: UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)_icSettingClicked:(UIButton *)sender {
    //  Gán giá trị của room chat là 0
    appDelegate.idRoomChat = 0;
    
    [revealVC rightRevealToggleAnimated: YES];
    return;
    
    AddParticientsViewController *controller = VIEW(AddParticientsViewController);
    if (controller != nil) {
        [controller updateValueForController: false];
    }
    [[PhoneMainView instance] changeCurrentView: [AddParticientsViewController compositeViewDescription] push: true];
}

#pragma mark - Emoji

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
- (NSString *)replaceAnEmotion: (NSString *)strNeedReplace onString: (NSString *)string
{
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

#pragma mark - UITextview Delegate
- (void)textViewDidChange:(UITextView *)textView
{
    // Setting placeholder
    if (textView.text.length > 0) {
        lbPlaceHolder.hidden = YES;
    }else{
        lbPlaceHolder.hidden = NO;
    }
    
    //  Send compositing
    if (textView.text.length == 1) {
        [(OTRXMPPAccount *)[appDelegate.friendBuddy.protocol account] setSendTypingNotifications: YES];
        [appDelegate.friendBuddy sendComposingChatState];
    }
    
    if ([_tvMessage text].length > 0) {
        _iconSend.hidden = NO;
        _iconMore.hidden = YES;
        
        CGFloat fixedWidth = 200;
        CGSize newSize = [_tvMessage sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        CGRect newFrame = [_tvMessage frame];
        if (newSize.height < hChatBox-6) {
            newFrame.size = CGSizeMake(_tvMessage.frame.size.width, hChatBox-6);
        }else{
            newFrame.size = CGSizeMake(_tvMessage.frame.size.width, newSize.height);
        }
        _tvMessage.frame = newFrame;
        _viewFooter.frame = CGRectMake(0, SCREEN_HEIGHT-appDelegate._hStatus-hKeyboard-_tvMessage.frame.size.height-6, _viewFooter.frame.size.width, _tvMessage.frame.size.height+6);
        lbChatComposing.frame = CGRectMake(10, _viewFooter.frame.origin.y-15, SCREEN_WIDTH-20, 20);
        
        //  Cập nhật vị trí view chat theo view footer
        [self updateFrameOfViewChatWithViewFooter];
    }else{
        _iconSend.hidden = YES;
        _iconMore.hidden = NO;
    }
}

#pragma mark - More functions

- (void)iconChoosePictureClicked: (UIButton *)sender {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    pickerController.allowsEditing = NO;
    pickerController.delegate = self;
    [self presentViewController:pickerController animated:YES completion:nil];
}

- (void)iconChooseVideoClicked: (UIButton *)sender {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    pickerController.allowsEditing = NO;
    pickerController.delegate = self;
    [self presentViewController:pickerController animated:YES completion:nil];
}

- (void)iconChooseCameraClicked: (UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    [picker setDelegate: self];
    [picker setSourceType: UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)iconChooseCallClicked: (UIButton *)sender {
    [self makeCallWithPhoneNumber: remoteParty];
}

- (void)makeCallWithPhoneNumber: (NSString *)phoneNumber {
    if (phoneNumber != nil && phoneNumber.length > 0)
    {
        LinphoneAddress *addr = linphone_core_interpret_url(LC, phoneNumber.UTF8String);
        [LinphoneManager.instance call:addr];
        if (addr)
            linphone_address_destroy(addr);
        
        OutgoingCallViewController *controller = VIEW(OutgoingCallViewController);
        if (controller != nil) {
            [controller setPhoneNumberForView: phoneNumber];
        }
        [[PhoneMainView instance] changeCurrentView:[OutgoingCallViewController compositeViewDescription] push:TRUE];
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        NSString* type = [info objectForKey:UIImagePickerControllerMediaType];
        if ([type isEqualToString: (NSString*)kUTTypeImage] ) {
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            appDelegate.imageChoose = image;
            [appDelegate setReloadMessageList: false];
            
            [[PhoneMainView instance] changeCurrentView: ShowPictureViewController.compositeViewDescription
                                                   push: TRUE];
        }else if ([type isEqualToString: (NSString*)kUTTypeMovie] ) {
            NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
            UIImage *imageVideo = [AppUtils getImageFromVideo:videoUrl atTime:1];
            
            NSString *idMsgImage = [NSString stringWithFormat:@"userimage_%@", [AppUtils randomStringWithLength: 20]];
            NSString *detailURL = [NSString stringWithFormat:@"%@_%@.jpg", USERNAME, [AppUtils randomStringWithLength:20]];
            
            int delivered = 0;
            if (appDelegate.xmppStream.isConnected) {
                delivered = 1;
            }
            
            NSArray *fileNameArr = [AppUtils saveImageToFiles: imageVideo withImage: detailURL];
            detailURL = [fileNameArr objectAtIndex: 0];
            NSString *thumbURL = [fileNameArr objectAtIndex: 1];
            
            int burnMessage = [AppUtils getBurnMessageValueOfRemoteParty: remoteParty];
            [NSDatabase saveMessage:USERNAME toPhone:remoteParty withContent:[videoUrl path] andStatus:NO withDelivered:delivered andIdMsg:idMsgImage detailsUrl:detailURL andThumbUrl:thumbURL withTypeMessage:videoMessage andExpireTime:burnMessage andRoomID:@"" andExtra:nil andDesc:appDelegate.titleCaption];
            
            //  Thêm message tạm vào view chat
            MessageEvent *message = [NSDatabase getMessageEventWithId: idMsgImage];
            [self updateTableView: message];
            
            //  Upload image lên server
            NSData *videoData = [NSData dataWithContentsOfURL: videoUrl];
            if (videoData != nil) {
                NSArray *tmpArr = [[videoUrl path] componentsSeparatedByString:@"/"];
                if (tmpArr.count > 0) {
                    NSString *videoName = [NSString stringWithFormat:@"%@_%@", [AppUtils randomStringWithLength:8], [tmpArr lastObject]];
                    [self startUploadVideoWithData:videoData toServerWithMessageId:idMsgImage andName:videoName];
                }
            }
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [appDelegate setReloadMessageList: false];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Add subview for main view
- (void)addPicturesViewForMainView {
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"ChatPictureDetailsView" owner:nil options:nil];
    for(id currentObject in subviewArray){
        if ([currentObject isKindOfClass:[ChatPictureDetailsView class]]) {
            viewPictures = (ChatPictureDetailsView *) currentObject;
            break;
        }
    }
    viewPictures.frame = CGRectMake(0, SCREEN_HEIGHT-appDelegate._hStatus, SCREEN_WIDTH, SCREEN_HEIGHT-appDelegate._hStatus);
    [viewPictures setupUIForView];
    [self.view addSubview: viewPictures];
}

//  Download picture from server
- (void)downloadVideoFromServerWithName: (NSString *)videoName andIdMessage: (NSString *)idMessage {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *strURL = [NSString stringWithFormat:@"%@/%@", link_picutre_chat_group, videoName];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString: strURL]];
        if (data != nil) {
            BOOL success = [AppUtils saveVideoToFiles:data withName:videoName];
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    NSURL *videoURL = [NSDatabase getUrlOfVideoFile: videoName];
                    [self playVideoWithURL: videoURL];
                });
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[appDelegate.localization localizedStringForKey:text_alert] message:[appDelegate.localization localizedStringForKey:@"Can not download this video!"] delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:text_close] otherButtonTitles:nil];
                [alert show];
            }
        }
    });
}

- (void)playVideoWithURL: (NSURL *)videoURL {
    //init player
    AVPlayer *player = [AVPlayer playerWithURL:videoURL];
    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
    playerViewController.player = player;
    [self presentViewController:playerViewController animated:YES completion:nil];
    [player play];
}

@end
