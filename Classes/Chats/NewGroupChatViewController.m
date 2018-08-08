//
//  NewGroupChatViewController.m
//  linphone
//
//  Created by admin on 1/8/18.
//

#import "NewGroupChatViewController.h"
#import "SWRevealViewController.h"
#import "BackgroundViewController.h"
#import "AddParticientsViewController.h"
#import "ShowPictureViewController.h"
#import "PhoneMainView.h"
#import "ChatMediaTableViewCell.h"
#import "GroupLeftChatTableViewCell.h"
#import "ChatTableViewCell.h"
#import "NSDatabase.h"
#import "UIImageView+WebCache.h"
#import "EmotionView.h"
#import "MoreChatView.h"

#import "ChatCellSettings.h"
#import "ChatMediaTableViewCell.h"
#import "UploadPicture.h"
#import "JSONKit.h"
#import "NSData+Base64.h"
#import "OTRMessage.h"
#import "MessageEvent.h"
#import "ChatPictureDetailsView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVKit/AVKit.h>

@interface NewGroupChatViewController (){
    SWRevealViewController *revealVC;
    
    LinphoneAppDelegate *appDelegate;
    UIFont *textFont;
    float hKeyboard;
    float hChatBox;
    float hChatIcon;
    float hCell;
    
    HMLocalization *localization;
    UILabel *bgStatus;
    UILabel *lbPlaceHolder;
    UILabel *lbChatComposing;
    
    // Emotion View
    EmotionView *viewEmotion;
    float hViewEmotion;
    float hTabEmotion;
    
    MoreChatView *viewChatMore;
    NSMutableArray *_listMessages;
    
    ChatCellSettings *chatCellSettings;
    
    NSMutableData *sendMsgData;
    UIImage *myAvatar;
    
    // Lưu giá trị rect ban đầu của chatboxview: tăng chiều cao chatbox
    CGRect firstChatBox;
    
    NSString *resultMessage;
    NSMutableDictionary *avatarInfo;
    
    ChatPictureDetailsView *viewPictures;
    
    int curPage;
    int numPerPage;
    int totalPage;
    BOOL isLoadMore;
    UIView *viewLoadMore;
    UILabel *lbLoadMore;
    UIActivityIndicatorView *icLoadMore;
}

@end

@implementation NewGroupChatViewController
@synthesize _viewHeader, _iconBack, _lbUserName, _icSetting;
@synthesize _viewChat, _tbChat, _bgChat, _lbNoMessage;
@synthesize _viewFooter, _tvMessage, _iconSend, _iconMore, _iconEmotion, _icCamera;

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
    //  my code here
    revealVC = [self revealViewController];
    [revealVC panGestureRecognizer];
    [revealVC tapGestureRecognizer];
    
    appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    localization = [HMLocalization sharedInstance];
    
    hKeyboard   =   0;
    hCell = 40.0;
    
    [self setupUIForView];
    
    bgStatus = [[UILabel alloc] initWithFrame: CGRectMake(0, -[UIApplication sharedApplication].statusBarFrame.size.height, SCREEN_WIDTH, [UIApplication sharedApplication].statusBarFrame.size.height)];
    [bgStatus setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview: bgStatus];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenSentImageForUser:)
                                                 name:@"sendImageForUser" object:nil];
    
    chatCellSettings = [ChatCellSettings getInstance];
    
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
    [chatCellSettings setSenderBubbleNameTextColorHex:@"168ab9"];
    [chatCellSettings setReceiverBubbleNameTextColorHex:@"168ab9"];
    [chatCellSettings setSenderBubbleMessageTextColorHex:@"323232"];
    [chatCellSettings setReceiverBubbleMessageTextColorHex:@"000000"];
    [chatCellSettings setSenderBubbleTimeTextColorHex:@"000000"];
    [chatCellSettings setReceiverBubbleTimeTextColorHex:@"000000"];
    
    [chatCellSettings setSenderBubbleFontWithSizeForName:[UIFont boldSystemFontOfSize:12]];
    [chatCellSettings setReceiverBubbleFontWithSizeForName:[UIFont boldSystemFontOfSize:12]];
    [chatCellSettings setSenderBubbleFontWithSizeForMessage:[UIFont systemFontOfSize:16]];
    [chatCellSettings setReceiverBubbleFontWithSizeForMessage:[UIFont systemFontOfSize:16]];
    [chatCellSettings setSenderBubbleFontWithSizeForTime:[UIFont systemFontOfSize:12]];
    [chatCellSettings setReceiverBubbleFontWithSizeForTime:[UIFont systemFontOfSize:12]];
    
    [chatCellSettings senderBubbleTailRequired:YES];
    [chatCellSettings receiverBubbleTailRequired:YES];
    
    self.navigationItem.title = @"iMessageBubble Demo";
    
    //Tap gesture on table view so that when someone taps on it, the keyboard is hidden
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self._tbChat addGestureRecognizer:gestureRecognizer];
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
    //  profile
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
    
    // Add sự kiện double click vào màn hình để change background
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapToChangeBackground)];
    [doubleTap setNumberOfTapsRequired: 2];
    [doubleTap setNumberOfTouchesRequired: 1];
    [_viewChat addGestureRecognizer:doubleTap];
    
    //  Lấy background đã được lưu cho room chat
    NSString *linkBgChat = [NSDatabase getChatBackgroundForRoom: appDelegate.roomChatName];
    if ([linkBgChat isEqualToString: @""] || linkBgChat == nil) {
        [_bgChat setImage:[UIImage imageNamed:@"bg_chat_default.jpg"]];
    }else{
        [_bgChat sd_setImageWithURL:[NSURL URLWithString: linkBgChat]
                   placeholderImage:[UIImage imageNamed:@"bg_chat_default.jpg"]];
    }
    
    // Setup more view về lại trạng thái ban đầu
    [self dismissKeyboard];
    
    //  Get lịch sử tin nhắn của room
    appDelegate._heightChatTbView = 0.0;
    isLoadMore = NO;
    curPage = 0;
    numPerPage = 20;
    int totalMessage = [NSDatabase getTotalMessagesOfMe:USERNAME ofRoomName:appDelegate.roomChatName];
    totalPage = ceil((float)totalMessage/numPerPage);
    
    if (appDelegate.reloadMessageList) {
        if (_listMessages == nil) {
            _listMessages = [[NSMutableArray alloc] init];
        }
        [_listMessages removeAllObjects];
        
        [self getHistoryMessagesOfRoom: appDelegate.roomChatName];
    }
    
    if (_listMessages.count > 0) {
        _lbNoMessage.hidden = YES;
        [_tbChat reloadData];
    }else{
        _lbNoMessage.hidden = NO;
    }
    
    // Cập nhật tất cả các tin nhắn chưa đọc thành đã đọc
    [NSDatabase updateAllMessagesInRoomChat:appDelegate.roomChatName withAccount:USERNAME];
    [self updateFrameOfViewChatWithViewFooter];
    [self updateAndGotoLastViewChat];
    
    [self setHeaderInfomationOfUser];
    [self getAvatarForMembersInGroupChat:appDelegate.roomChatName ofAccount:USERNAME];
    
    //  notifications
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNewRoomChatMessage:)
                                                 name:k11ReceivedRoomChatMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWhenShowKeyboard:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getChatMessageTextViewInfo)
                                                 name:getTextViewMessageChatInfo object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setContentForMessageTextView:)
                                                 name:mapContentForMessageTextView object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateReceiveMessage:)
                                                 name:updateDeliveredChat object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(afterDownloadImageSuccess:)
                                                 name:@"downloadPictureFinish" object:nil];
    //  Subject của room chat đc thay đổi
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenSubjectOfRoomChanged:)
                                                 name:k11SubjectOfRoomChanged object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenSaveImageForVideoSuccess:)
                                                 name:updatePreviewImageForVideo object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickToPlayVideo:)
                                                 name:playVideoMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteConversationSuccess)
                                                 name:whenDeleteConversationInChatView object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processWhenRoomDestroyed:)
                                                 name:whenRoomDestroyed object:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k11ReceivedRoomChatMessage
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:getTextViewMessageChatInfo
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:mapContentForMessageTextView
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:updateDeliveredChat
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"downloadPictureFinish"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:playVideoMessage
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"longGestureOnMessage"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k11SubjectOfRoomChanged
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:updatePreviewImageForVideo
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:playVideoMessage
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:whenDeleteConversationInChatView
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:whenRoomDestroyed
                                                  object:nil];
}

- (IBAction)_iconSendClicked:(UIButton *)sender
{
    NSString *idMessage = [AppUtils randomStringWithLength: 15];
    NSString *contentMessage = [self convertEmojiToString: _tvMessage.text];
    
    int delivered = 0;
    if (appDelegate.xmppStream.isConnected) {
        delivered = 1;
    }
    
    [NSDatabase saveMessage:USERNAME toPhone:appDelegate.roomChatName withContent:contentMessage andStatus:YES withDelivered:delivered andIdMsg:idMessage detailsUrl:@"" andThumbUrl:@"" withTypeMessage:typeTextMessage andExpireTime:0 andRoomID:appDelegate.roomChatName andExtra:nil andDesc:nil];
    
    MessageEvent *curMessage = [NSDatabase getMessageEventWithId: idMessage];
    if (curMessage == nil) {
        NSLog(@"Why can not get data of message?");
        return;
    }
    [self updateTableView: curMessage];
    
    [appDelegate.myBuddy.protocol sendMessageWithContent:_tvMessage.text ofMe:USERNAME
                                                 toGroup:appDelegate.roomChatName withIdMessage:idMessage];
    
    sendMsgData = nil;
    [self sendMessageOfflineForGroupFromSender:USERNAME withContent:contentMessage
                                andTypeMessage:@"text" withGroupID:appDelegate.roomChatName];
    
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
            
            //  View footer thay đổi thì thay đổi view chat
            [self updateFrameOfViewChatWithViewFooter];
        }];
    }
}

- (IBAction)_iconCameraClicked:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    [picker setDelegate: self];
    [picker setSourceType: UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)_iconBackClicked:(UIButton *)sender {
    appDelegate.reloadMessageList = YES;
    [[PhoneMainView instance] popCurrentView];
}

- (IBAction)_icSettingClicked:(UIButton *)sender {
    [revealVC rightRevealToggleAnimated: YES];
    return;
    //  Gán giá trị của room chat là 0
    appDelegate.idRoomChat = 0;
    
    AddParticientsViewController *controller = VIEW(AddParticientsViewController);
    if (controller != nil) {
        [controller updateValueForController: false];
    }
    [[PhoneMainView instance] changeCurrentView: [AddParticientsViewController compositeViewDescription] push: true];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        
        //  Cập nhật vị trí view chat theo view footer
        [self updateFrameOfViewChatWithViewFooter];
    }else{
        _iconSend.hidden = YES;
        _iconMore.hidden = NO;
    }
}

#pragma mark - Khai Le functions

//  Nếu phòng hiện tại bị huỷ
- (void)processWhenRoomDestroyed: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[NSString class]]) {
        if ([object isEqualToString: appDelegate.roomChatName]) {
            [[PhoneMainView instance] popCurrentView];
        }
    }
}

- (void)deleteConversationSuccess {
    if (_listMessages == nil) {
        _listMessages = [[NSMutableArray alloc] init];
    }
    [_listMessages removeAllObjects];
    [_tbChat reloadData];
    appDelegate._heightChatTbView = 0.0;
    [_lbNoMessage setHidden: false];
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

- (void)playVideoWithURL: (NSURL *)videoURL {
    //init player
    AVPlayer *player = [AVPlayer playerWithURL:videoURL];
    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
    playerViewController.player = player;
    [self presentViewController:playerViewController animated:YES completion:nil];
    [player play];
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

//  Lấy danh sách avatar
- (void)getAvatarForMembersInGroupChat: (NSString *)roomName ofAccount: (NSString *)curAccount
{
    if (avatarInfo == nil) {
        avatarInfo = [[NSMutableDictionary alloc] init];
    }
    [avatarInfo removeAllObjects];
    
    NSArray *listMembers = [NSDatabase getListOccupantsInGroup:roomName ofAccount:curAccount];
    for (int iCount=0; iCount<listMembers.count; iCount++) {
        NSString *member = [listMembers objectAtIndex: iCount];
        if (![member isEqualToString: USERNAME]) {
            NSString *avatar = [NSDatabase getAvatarOfContactWithPhoneNumber:member];
            if (avatar == nil || [avatar isEqualToString:@""]) {
                [avatarInfo setObject:[UIImage imageNamed:@"no_avatar"] forKey:member];
            }else{
                [avatarInfo setObject:[UIImage imageWithData:[NSData dataFromBase64String:avatar]]
                               forKey:member];
            }
        }
    }
}

//  Cập nhật subject của room chat
- (void)whenSubjectOfRoomChanged: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[NSDictionary class]])
    {
        NSString *RoomName = [object objectForKey:@"RoomName"];
        NSString *Subject = [object objectForKey:@"subject"];
        if (![RoomName isEqualToString: appDelegate.roomChatName]) {
            return;
        }
        _lbUserName.text = Subject;
    }
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

//  set thông tin hiển thị cho phần header chat
- (void)setHeaderInfomationOfUser {
    // set trạng thái của user
    NSString *subject = [NSDatabase getSubjectOfRoom:appDelegate.roomChatName];
    if ([subject isEqualToString:@""]) {
        _lbUserName.text = appDelegate.roomChatName;
    }else{
        _lbUserName.text = subject;
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
        
        //  Cập nhật vị trí view chat theo view footer
        [self updateFrameOfViewChatWithViewFooter];
    }else{
        _iconSend.hidden = YES;
        _iconMore.hidden = NO;
    }
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
    
    //  View footer thay đổi thì thay đổi view chat
    [self updateFrameOfViewChatWithViewFooter];
    
    [self updateAndGotoLastViewChat];
    
    if (![lbChatComposing.text isEqualToString:@""]) {
        [lbChatComposing setFrame:CGRectMake(10, _viewFooter.frame.origin.y-15, SCREEN_WIDTH-20, 15)];
        [lbChatComposing setHidden: NO];
    }
    
    if (_listMessages.count > 0) {
        [_tbChat scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(_listMessages.count - 1) inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        //  Leo Kelvin
        //  [viewNewMsg setHidden: true];
    }
}

//  Ẩn bàn phím
- (void)keyboardDidHide: (NSNotification *) notif{
    [self dismissKeyboard];
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
    
    viewChatMore.frame = CGRectMake(0, SCREEN_HEIGHT-appDelegate._hStatus, SCREEN_WIDTH, 0);
    [viewChatMore setupUIForView: hViewEmotion];
    
    [self.view addSubview: viewChatMore];
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

//  Nhận message mới từ room chat
- (void)receivedNewRoomChatMessage: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[NSMutableDictionary class]]) {
        OTRMessage *messageReceive = [object objectForKey:@"message"];
        NSString *user = @"";
        if (messageReceive != nil) {
            user = [AppUtils getSipFoneIDFromString: messageReceive.buddy.accountName];
        }else{
            user = [object objectForKey:@"user"];
        }
        
        // NSString *typeMessage = [object objectForKey:@"typeMessage"];
        
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
        
        [NSDatabase saveMessage:USERNAME toPhone:appDelegate.roomChatName withContent:@"" andStatus:NO withDelivered:delivered andIdMsg:idMsgImage detailsUrl:detailURL andThumbUrl:thumbURL withTypeMessage:imageMessage andExpireTime:0 andRoomID:appDelegate.roomChatName andExtra:nil andDesc:appDelegate.titleCaption];
        
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

//  Get danh sách tin nhắn của room
- (void)getHistoryMessagesOfRoom: (NSString *)roomID
{
    appDelegate._heightChatTbView = 0;
    [_listMessages addObjectsFromArray:[NSDatabase getListMessagesOfAccount:USERNAME withRoomID:appDelegate.roomChatName withCurrentPage:curPage andNumPerPage:numPerPage]];
}

//  Cập nhật dữ liệu và scroll đến cuối list
- (void)updateAndGotoLastViewChat {
    if([self._tbChat numberOfRowsInSection:0]!=0)
    {
        NSIndexPath* ip = [NSIndexPath indexPathForRow:[self._tbChat numberOfRowsInSection:0]-1 inSection:0];
        [self._tbChat scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:UITableViewRowAnimationLeft];
    }
}

//  Đóng bàn phím chat
- (void)dismissKeyboard {
    [self.view endEditing: true];
    _iconMore.selected = NO;
    
    [UIView animateWithDuration:0.2 animations:^{
        viewEmotion.frame = CGRectMake(viewEmotion.frame.origin.x, SCREEN_HEIGHT-appDelegate._hStatus, viewEmotion.frame.size.width, 0);
        viewChatMore.frame = CGRectMake(viewChatMore.frame.origin.x, SCREEN_HEIGHT-appDelegate._hStatus, viewChatMore.frame.size.width, 0);
        _viewFooter.frame = CGRectMake(_viewFooter.frame.origin.x, SCREEN_HEIGHT-appDelegate._hStatus-_viewFooter.frame.size.height, _viewFooter.frame.size.width, _viewFooter.frame.size.height);
        
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

- (CGFloat)getHeightOfMessage: (MessageEvent *)message {
    CGSize size;
    
    CGSize Namesize;
    CGSize Timesize;
    CGSize Messagesize;
    
    NSArray *fontArray = [[NSArray alloc] init];
    
    //Get the chal cell font settings. This is to correctly find out the height of each of the cell according to the text written in those cells which change according to their fonts and sizes.
    //If you want to keep the same font sizes for both sender and receiver cells then remove this code and manually enter the font name with size in Namesize, Messagesize and Timesize.
    if ([message.typeMessage isEqualToString: imageMessage] || [message.typeMessage isEqualToString: videoMessage]) {
        if ([message.sendPhone isEqualToString: USERNAME]) {
            return 196.0;
        }else{
            return 220.0;
        }
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
         Namesize = [@"Name" boundingRectWithSize:CGSizeMake(220.0f, CGFLOAT_MAX)
         options:NSStringDrawingUsesLineFragmentOrigin
         attributes:@{NSFontAttributeName:fontArray[0]}
         context:nil].size;
        
        NSMutableAttributedString *msgAttributeString = [AppUtils convertMessageStringToEmojiString: message.content];
        Messagesize = [msgAttributeString.string boundingRectWithSize:CGSizeMake(220.0f, CGFLOAT_MAX)
                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                           attributes:@{NSFontAttributeName:fontArray[1]}
                                                              context:nil].size;
        
        
        Timesize = [@"Time" boundingRectWithSize:CGSizeMake(220.0f, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:fontArray[2]}
                                         context:nil].size;
        if ([message.sendPhone isEqualToString:USERNAME]) {
            size.height = Messagesize.height + Timesize.height + 32.0f;
        }else{
            size.height = Messagesize.height + Namesize.height + Timesize.height + 40.0f;
        }
        
        return size.height;
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
    
    _lbUserName.frame = CGRectMake(_iconBack.frame.origin.x+_iconBack.frame.size.width+5, 0, _viewHeader.frame.size.width-2*(_iconBack.frame.size.width+5), _viewHeader.frame.size.height);
    
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
    [lbPlaceHolder setTextColor:[UIColor grayColor]];
    [lbPlaceHolder setText:[localization localizedStringForKey:text_type_to_composte]];
    [lbPlaceHolder setFont: textFont];
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
    _tbChat.frame = CGRectMake(0, 5, _viewChat.frame.size.width, _viewChat.frame.size.height-10);
    _tbChat.backgroundColor = [UIColor clearColor];
    _tbChat.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tbChat.delegate = self;
    _tbChat.dataSource = self;
    
    /*Uncomment second para and comment first to use XIB instead of code*/
    //Registering custom Chat table view cell for both sending and receiving
    [_tbChat registerClass:[ChatMediaTableViewCell class] forCellReuseIdentifier:@"chatSend"];
    [_tbChat registerClass:[ChatTableViewCell class] forCellReuseIdentifier:@"chatSend"];
    [_tbChat registerClass:[GroupChatLeftMediaTableViewCell class] forCellReuseIdentifier:@"chatReceive"];
    [_tbChat registerClass:[GroupLeftChatTableViewCell class] forCellReuseIdentifier:@"chatReceive"];
    
    // Khai báo label chat composite
    lbChatComposing = [[UILabel alloc] init];
    [lbChatComposing setAutoresizingMask: UIViewAutoresizingFlexibleWidth];
    [lbChatComposing setTag: 888];
    [lbChatComposing setTextColor: [UIColor colorWithRed:(71/255.0) green:(32/255.0) blue:(102/255.0) alpha:1.0]];
    [lbChatComposing setBackgroundColor:[UIColor clearColor]];
    [lbChatComposing setFont:[UIFont fontWithName:HelveticaNeueItalic size:12.0]];
    [self.view addSubview: lbChatComposing];
    
    //  username label and status label
    [_lbUserName setMarqueeType:MLContinuous];
    [_lbUserName setScrollDuration: 15.0f];
    [_lbUserName setAnimationCurve:UIViewAnimationOptionCurveEaseOut];
    [_lbUserName setFadeLength: 10.0f];
    [_lbUserName setContinuousMarqueeExtraBuffer: 10.0f];
    [_lbUserName setTextColor:[UIColor whiteColor]];
    [_lbUserName setBackgroundColor:[UIColor clearColor]];
    [_lbUserName setTextAlignment:NSTextAlignmentCenter];
    [_lbUserName setFont:[UIFont fontWithName:HelveticaNeue size:15.0]];
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
            cell.chatMessageBurn.hidden = YES;
            
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
            
            if ([message.isRecall isEqualToString:@"YES"]) {
                [message.contentAttrString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:15.0] range:NSMakeRange(0, message.contentAttrString.length)];
                [message.contentAttrString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, message.contentAttrString.length)];
            }
            cell.chatMessageLabel.attributedText = message.contentAttrString;
            return cell;
        }else{
            ChatMediaTableViewCell *cell = [[ChatMediaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"chatSend"];
            cell.chatMessageBurn.hidden = YES;
            
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
            GroupLeftChatTableViewCell *cell = [[GroupLeftChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"chatReceive"];
            cell.chatMessageLabel.attributedText = message.contentAttrString;
            cell.chatTimeLabel.text = message.dateTime;
            cell.chatUserImage.image = [avatarInfo objectForKey:message.sendPhone];
            cell.authorType = iMessageBubbleTableViewCellAuthorTypeReceiver;
            cell.messageId = message.idMessage;
            cell.chatNameLabel.text = message.sendPhoneName;
            
            if ([message.isRecall isEqualToString:@"YES"]) {
                [message.contentAttrString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:15.0] range:NSMakeRange(0, message.contentAttrString.length)];
                [message.contentAttrString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, message.contentAttrString.length)];
            }
            return cell;
        }else{
            GroupChatLeftMediaTableViewCell *cell = [[GroupChatLeftMediaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"chatReceive"];
            cell.delegate = self;
            cell.messageEvent = message;
            
            cell.chatMessageImage.image = [AppUtils getImageDataWithName: message.thumbUrl];
            cell.chatTimeLabel.text = message.dateTime;
            cell.chatUserImage.image = [avatarInfo objectForKey:message.sendPhone];
            cell.chatNameLabel.text = message.sendPhoneName;
            
            if ([message.typeMessage isEqualToString:videoMessage]) {
                cell.playVideoImage.hidden = NO;
            }else if ([message.typeMessage isEqualToString:imageMessage]){
                cell.playVideoImage.hidden = YES;
            }
            
            cell.chatMessageImage.image = [AppUtils getImageDataWithName: message.thumbUrl];
            
            /*Comment this line is you are using XIB*/
            cell.authorType = iMessageBubbleTableViewCellAuthorTypeReceiver;
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageEvent *message = [_listMessages objectAtIndex:indexPath.row];
    return [self getHeightOfMessage: message];
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
            
            [NSDatabase saveMessage:USERNAME toPhone:appDelegate.roomChatName withContent:[videoUrl path] andStatus:NO withDelivered:delivered andIdMsg:idMsgImage detailsUrl:detailURL andThumbUrl:thumbURL withTypeMessage:videoMessage andExpireTime:0 andRoomID:appDelegate.roomChatName andExtra:nil andDesc:appDelegate.titleCaption];
            
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
        [AppUtils sendMessageForOfflineForUser:appDelegate.roomChatName fromSender:USERNAME withContent:strPush andTypeMessage:typeMedia withGroupID:appDelegate.roomChatName];
        
        [appDelegate.myBuddy.protocol sendMessageMediaForUser:appDelegate.roomChatName withLinkImage:uploadSession.namePicture andDescription:appDelegate.titleCaption andIdMessage:idOfMsg andType:typeMedia withBurn:0 forGroup:YES];
    }
    appDelegate.imageChoose = nil;
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

#pragma mark - Media message delegate

- (void)clickOnPictureOfMessage:(MessageEvent *)messageEvent {
    if ([messageEvent.typeMessage isEqualToString: imageMessage]) {
        if (viewPictures == nil) {
            [self addPicturesViewForMainView];
        }
        viewPictures.isGroup = YES;
        viewPictures._remoteParty = messageEvent.roomID;
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

#pragma mark - Scroll tableview

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
        
        NSArray *moreData = [NSDatabase getListMessagesOfAccount:USERNAME withRoomID:appDelegate.roomChatName
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

- (float)getHeightOfListMessage: (NSArray *)listMsgs {
    float totalHeight = 0;
    for (int iCount=0; iCount<listMsgs.count; iCount++) {
        MessageEvent *curMessage = [listMsgs objectAtIndex: iCount];
        totalHeight = totalHeight + [self getHeightOfMessage: curMessage];
    }
    return totalHeight;
}

@end
