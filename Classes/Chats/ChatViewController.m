//
//  ChatViewController.m
//  linphone
//
//  Created by Ei Captain on 3/20/17.
//
//

#import "ChatViewController.h"
#import "SWRevealViewController.h"
#import "BackgroundViewController.h"
#import "AddParticientsViewController.h"
#import "EmotionView.h"
#import "ChatPhotosView.h"
#import "PopupChoosePicture.h"
#import "SettingPopupView.h"
#import "ListChatsViewController.h"
#import "ShowPictureViewController.h"
#import "MainChatViewController.h"
#import "NSDatabase.h"
#import "NSData+Base64.h"
#import "PhoneMainView.h"
#import "OTRProtocolManager.h"
#import "SettingItem.h"

#import "OptionsCell.h"
#import "UIImageView+WebCache.h"

#import "JSONKit.h"
#import "UploadPicture.h"
#import "MoreChatView.h"

@interface ChatViewController (){
    SWRevealViewController *revealVC;
    LinphoneAppDelegate *appDelegate;
    float hChatBox;
    float hChatIcon;
    float hCell;
    
    UILabel *lbPlaceHolder;
    
    // Emotion View
    EmotionView *viewEmotion;
    float hViewEmotion;
    float hTabEmotion;
    
    // Photos View
    ChatPhotosView *viewPhotos;
    float hViewPhoto;
    
    float hKeyboard;
    UILabel *lbChatComposing;
    
    NSMutableArray *_listMessages;
    NSString *_userAccount;
    
    // View thông báo khi có new message đến
    UIView *viewNewMsg;
    
    NSTimer *expireTimer;
    int expireTime;
    
    // view thong bao
    UIView *messageView;
    UILabel *lbMessage;
    
    NSString *audioFileName;
    
    // Lưu giá trị rect ban đầu của chatboxview: tăng chiều cao chatbox
    CGRect firstChatBox;
    
    NSString *resultMessage;
    
    BOOL callOnMessage;
    BOOL transfer_popup;
    NSString *stringForCall;
    NSString *phoneNumberOnMessage;
    PopupChoosePicture *popupClickChoosePicture;
    int idMsgForward;
    SettingPopupView *popUpTouchMessage;
    NSMutableArray *touchMessageArr;
    
    float firstX, firstY;
    
    HMLocalization *localization;
    
    UILabel *bgStatus;
    UIFont *textFont;
    
    NSString *idMsgImage;
    NSString *thumbURL;
    NSString *detailURL;
    
    MoreChatView *viewChatMore;
}

@end

@implementation ChatViewController
@synthesize _viewHeader, _iconBack, _icStatus, _lbUserName, _lbStatus, _icSetting;
@synthesize _viewChat, _tbChat, _bgChat, _lbNoMessage;
@synthesize _viewFooter, _tvMessage, _iconSend, _iconMore, _iconEmotion, _icCamera;
@synthesize typeTouchOnMessage;

#pragma mark - my controller
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
}

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
    [_tvMessage addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    
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
    
    bgStatus = [[UILabel alloc] initWithFrame: CGRectMake(0, -20, SCREEN_WIDTH, 20)];
    [bgStatus setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview: bgStatus];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenSentImageForUser:)
                                                 name:@"sendImageForUser" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    //  Tắt màn hình cảm biến
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled: false];
    
    [appDelegate setIdRoomChat: 0];
    
    _userAccount = [[NSString alloc] initWithString:[AppUtils getSipFoneIDFromString: appDelegate.friendBuddy.accountName]];
    
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
    
    //  Load background chat hiện tại
    NSString *linkBgChat = [NSDatabase getChatBackgroundOfUser: _userAccount];
    if ([linkBgChat isEqualToString: @""] || linkBgChat == nil) {
        [_bgChat setImage:[UIImage imageNamed:@"bg_chat_default.jpg"]];
    }else{
        [_bgChat sd_setImageWithURL:[NSURL URLWithString: linkBgChat]
                   placeholderImage:[UIImage imageNamed:@"bg_chat_default.jpg"]];
    }
    
    // Setup more view về lại trạng thái ban đầu
    [self dismissKeyboard];
    
    // Kiểm tra nếu user này có badge thì xoá đi
    BOOL isBadge = [NSDatabase checkBadgeMessageOfUserWhenRunBackground: _userAccount];
    if (isBadge) {
        int currentBadge = (int)[[UIApplication sharedApplication] applicationIconBadgeNumber];
        if (currentBadge > 0) {
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber: currentBadge - 1];
        }
    }
    
    // set label placeholder cho expire time
    expireTime = 0;
    
    // Hiển thị thông tin của user chat lên màn hình
    [self setBuddy: appDelegate.friendBuddy];
    [self setHeaderInfomationOfUser];
    
    // Lấy lịch sử tin nhắn
    if (appDelegate.reloadMessageList) {
        [self getHistoryMessagesWithUser: _userAccount];
        if (_listMessages.count > 0) {
            [_lbNoMessage setHidden: true];
        }else{
            [_lbNoMessage setHidden: false];
        }
    }
    
    //  Bắt đầu xoá tin nhắn expire
    [self startAllExpireMessageOfMe];
    
    
    // Add sự kiện double click vào màn hình để change background
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapToChangeBackground)];
    [doubleTap setNumberOfTapsRequired: 2];
    [doubleTap setNumberOfTouchesRequired: 1];
    [_viewChat addGestureRecognizer:doubleTap];
    
    //  notitications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWhenShowKeyboard:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateReceiveMessage:)
                                                 name:updateDeliveredChat object:nil];
    
    // Nhận message mới
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNewMessage:)
                                                 name:kOTRMessageReceived object:nil];
    //  Nhẫn giữ trên tin nhắn
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(touchAMessageWithNotification:)
                                                 name:k11TouchOnMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getChatMessageTextViewInfo)
                                                 name:getTextViewMessageChatInfo object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setContentForMessageTextView:)
                                                 name:mapContentForMessageTextView object:nil];
    //  Lưu conversation chat
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveConversationAccepted:)
                                                 name:k11SaveConversationChat object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteConversationSuccess)
                                                 name:whenDeleteConversationInChatView object:nil];
    //  Cập nhật trạng thái buddy
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buddyListUpdate)
                                                 name:kOTRBuddyListUpdate object:nil];
    //  Touch vào màn hình chat để đóng bàn phím
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissKeyboard)
                                                 name:k11DismissKeyboardInViewChat object:nil];
    
    
    
    // Set hình ảnh sau khi nhận xong
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAMessageAfterReceived:)
                                                 name:k11UpdateMsgAfterReceivedFile object:nil];//Cập nhật lại sau khi recall message
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViewChatAfterRecallMessage:)
                                                 name:k11DeleteMsgWithRecallID object:nil];
    
    // Cập nhật sau khi xóa message expire
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAfterDeleteExpireMsgMeSend:)
                                                 name:k11UpdateAfterDeleteExpireMsgMeSend object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDeliveredError:)
                                                 name:k11UpdateDeliveredError object:nil];
    
    //  Xử lý link trên message
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processLinkOnMessage:)
                                                 name:k11ProcessingLinkOnMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadListMessageForUser)
                                                 name:@"reloadListMessageForUser" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(afterDownloadImageSuccess:)
                                                 name:@"downloadPictureFinish" object:nil];
    
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k11UpdateAfterDeleteExpireMsgMeSend
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k11UpdateDeliveredError
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k11ProcessingLinkOnMessage
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)_iconBackClicked:(UIButton *)sender {
    [appDelegate setReloadMessageList: true];
    
    [[PhoneMainView instance] popCurrentView];
}

- (IBAction)_iconSettingsClicked:(UIButton *)sender
{
    //  Gán giá trị của room chat là 0
    [appDelegate setIdRoomChat: 0];
    
    AddParticientsViewController *controller = VIEW(AddParticientsViewController);
    if (controller != nil) {
        [controller updateValueForController: false];
    }
    [[PhoneMainView instance] changeCurrentView: [AddParticientsViewController compositeViewDescription] push: true];
}

- (IBAction)_iconCloseClicked:(UIButton *)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        [viewPhotos setFrame: CGRectMake(viewPhotos.frame.origin.x, SCREEN_HEIGHT-appDelegate._hStatus, viewPhotos.frame.size.width, 0)];
        [viewEmotion setFrame: CGRectMake(viewEmotion.frame.origin.x, SCREEN_HEIGHT-appDelegate._hStatus, viewEmotion.frame.size.width, 0)];
        [_viewFooter setFrame: CGRectMake(_viewFooter.frame.origin.x, viewPhotos.frame.origin.y-_viewFooter.frame.size.height, _viewFooter.frame.size.width, _viewFooter.frame.size.height)];
        
        //  Cập nhật vị trí view chat theo view footer
        [self updateFrameOfViewChatWithViewFooter];
    }completion:^(BOOL finished) {
        [viewPhotos setAlpha: 1.0];
        [viewEmotion setAlpha: 1.0];
    }];
}

- (IBAction)_iconEmotionClicked:(UIButton *)sender
{
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

- (IBAction)_iconSendClicked:(UIButton *)sender
{
    //  Tạo data cho tin nhắn và lưu vào list
    NSString *messageSend = [self convertEmojiToString: _tvMessage.text];
    
    int deliveredStatus = 0;
    if (appDelegate.xmppStream.isConnected) {
        deliveredStatus = 1;
    }
    
    NSString *idMessage = [AppUtils randomStringWithLength: 10];
    
    [NSDatabase saveMessage:USERNAME toPhone:_userAccount withContent:messageSend andStatus:YES withDelivered:deliveredStatus andIdMsg:idMessage detailsUrl:@"" andThumbUrl:@"" withTypeMessage:typeTextMessage andExpireTime:expireTime andRoomID:@"" andExtra:nil andDesc:nil];
    
    NSBubbleData *aMessage = [[NSBubbleData alloc] initWithText:messageSend type:BubbleTypeMine time:[AppUtils getCurrentTime] status:deliveredStatus idMessage:idMessage withExpireTime:expireTime isRecall:@"NO" description:@"" withTypeMessage:typeTextMessage isGroup:NO ofUser:nil];
    [_listMessages addObject: aMessage];
    
    // send message
    BOOL secure = false;
    if (appDelegate.friendBuddy.encryptionStatus == kOTRKitMessageStateEncrypted) {
        secure = true;
    }
    [appDelegate.friendBuddy sendMessage: messageSend secure:secure withIdMessage:idMessage];
    
    //  push message
    [AppUtils sendMessageForOfflineForUser:_userAccount fromSender:USERNAME withContent:messageSend andTypeMessage:@"text" withGroupID:@""];
    
    // setup các UI
    _lbNoMessage.hidden = YES;
    lbPlaceHolder.hidden = NO;
    _tvMessage.text = @"";
    _tvMessage.scrollEnabled = NO;
    _iconSend.hidden = YES;
    _iconMore.hidden = NO;
    
    // Hiển thị tin nhắn và scroll xuống dòng cuối
    [self updateAllFrameForController: true];
    [self updateAndGotoLastViewChat];
    [_tvMessage setFrame: CGRectMake(_tvMessage.frame.origin.x, 3, _tvMessage.frame.size.width, hChatBox-6)];
}

- (IBAction)_iconPhotoClicked:(UIButton *)sender
{
    /*  Leo Kelvin
    [self.view endEditing: true];
    
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    [self presentViewController:pickerController animated:YES completion:nil];
    
    if (viewPhotos == nil) {
        [self addViewPhotosForViewChat];
    }
    [viewPhotos getListGroupsPhotos];
    
    if (viewPhotos.frame.size.height == 0)
    {
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
    }   */
}

- (IBAction)_icCameraClicked:(UIButton *)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    [picker setDelegate: self];
    [picker setSourceType: UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)_iconMoreClicked:(UIButton *)sender
{
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

#pragma mark - my functions

- (void)afterDownloadImageSuccess: (NSNotification *)notif {
    NSString *idMessage = [notif object];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"idMessage = %@", idMessage];
    NSArray *listSearch = [_listMessages filteredArrayUsingPredicate: predicate];
    if (listSearch.count > 0) {
        NSBubbleData *imageMsgData = [NSDatabase getDataOfMessage: idMessage];
        int index = (int)[_listMessages indexOfObject: [listSearch firstObject]];
        [_listMessages replaceObjectAtIndex:index withObject:imageMsgData];
        
        NSString *thumbFile = [NSDatabase getLinkImageOfMessage:idMessage];
        
        UIBubbleTableViewCell *cell = [_tbChat cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        cell.data.imgContent.image = [AppUtils getImageOfDirectoryWithName:thumbFile];
    }
}

//  Reload danh sách tin nhắn khi mở từ notification
- (void)reloadListMessageForUser {
    // Lấy lịch sử tin nhắn
    [self getHistoryMessagesWithUser: _userAccount];
    if (_listMessages.count > 0) {
        [_lbNoMessage setHidden: true];
    }else{
        [_lbNoMessage setHidden: false];
    }
}

- (void)whenSentImageForUser: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[UIImage class]])
    {
        idMsgImage = [NSString stringWithFormat:@"userimage_%@", [AppUtils randomStringWithLength: 20]];
        
        detailURL = [NSString stringWithFormat:@"%@_%@.jpg", USERNAME, [AppUtils randomStringWithLength:20]];
        
        int delivered = 0;
        
        NSArray *fileNameArr = [AppUtils saveImageToFiles: appDelegate.imageChoose withImage: detailURL];
        detailURL = [fileNameArr objectAtIndex: 0];
        thumbURL = [fileNameArr objectAtIndex: 1];
        
        [NSDatabase saveMessage:USERNAME toPhone:_userAccount withContent:@"" andStatus:YES withDelivered:delivered andIdMsg:idMsgImage detailsUrl:detailURL andThumbUrl:thumbURL withTypeMessage:imageMessage andExpireTime:expireTime andRoomID:@"" andExtra:nil andDesc:appDelegate.titleCaption];
        
        //  Thêm message tạm vào view chat
        NSBubbleData *lastMsgData = [NSDatabase getDataOfMessage: idMsgImage];
        [_listMessages addObject: lastMsgData];
        
        [self updateAllFrameForController: false];
        [self updateAndGotoLastViewChat];
        
        //  Upload image lên server
        [self startUploadImageToServerWithMessageId: idMsgImage andName: detailURL];
    }
}

- (void)startUploadImageToServerWithMessageId: (NSString *)idMessage andName: (NSString *)imageName
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *imageData = UIImageJPEGRepresentation(appDelegate.imageChoose, 1.0);
        UploadPicture *session = [[UploadPicture alloc] init];
        session.idMessage = idMessage;
        
        [session uploadData:imageData withName:imageName beginUploadBlock:nil finishUploadBlock:^(UploadPicture *uploadSession) {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [self updateImageSendMessageWithInfo: uploadSession];
                NSLog(@"Da upload xong hinh anh");
            });
        }];
    });
}

//  Update message hình ảnh khi nhận xong
- (void)updateAMessageAfterReceived: (NSNotification *)notif {
    
    id object = [notif object];
    if ([object isKindOfClass:[NSString class]]) {
        NSString *idMsgUpdate = (NSString *)object;
        NSBubbleData *imageMsgData = [NSDatabase getDataOfMessage: idMsgUpdate];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"idMessage = %@", idMsgUpdate];
        NSArray *listSearch = [_listMessages filteredArrayUsingPredicate: predicate];
        if (listSearch.count > 0) {
            int index = (int)[_listMessages indexOfObject: [listSearch firstObject]];
            [_listMessages replaceObjectAtIndex:index withObject:imageMsgData];
            [_tbChat reloadData];
        }
    }
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

//  Ẩn bàn phím
- (void)keyboardDidHide: (NSNotification *) notif{
    [UIView animateWithDuration:0.05 animations:^{
        
    }];
}

//  Cập nhật lại roster list
- (void)buddyListUpdate {
    if(![[OTRProtocolManager sharedInstance] buddyList]) {
        NSLog(@"blist is nil!");
        return;
    }
    [self updateStateForBuddy: _userAccount];
}

//  Cập nhật trạng thái của  user
- (void)updateStateForBuddy: (NSString *)callnexUser
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName CONTAINS[cd] %@", callnexUser];
    NSMutableDictionary *listUserDict = [[[OTRProtocolManager sharedInstance] buddyList] allBuddies];
    NSArray *listUser = [OTRBuddyList sortBuddies: listUserDict];
    NSArray *resultArr = [listUser filteredArrayUsingPredicate: predicate];
    if (resultArr.count > 0) {
        // Kiểm tra trạng thái của của buddy
        NSString *currentStatus = [appDelegate._statusXMPPDict objectForKey: _userAccount];
        if (currentStatus == nil || [currentStatus isEqualToString: @""]) {
            currentStatus = welcomeToCloudFone;
        }
        appDelegate.friendBuddy = [resultArr objectAtIndex: 0];
        
        switch (appDelegate.friendBuddy.status) {
            case kOTRBuddyStatusOffline:{
                [_icStatus setImage: [UIImage imageNamed:@"ic_status_unavailable.png"]];
                [_lbStatus setText: [localization localizedStringForKey:text_chat_not_available]];
                break;
            }
            case kOTRBuddyStatusAway:{
                [_icStatus setImage:[UIImage imageNamed:@"ic_status_away.png"]];
                [_lbStatus setText: currentStatus];
                break;
            }
            case kOTRBuddyStatusAvailable:{
                [_icStatus setImage: [UIImage imageNamed:@"ic_status_available.png"]];
                [_lbStatus setText: currentStatus];
                break;
            }
            default:{
                [_icStatus setImage: [UIImage imageNamed:@"ic_status_unavailable.png"]];
                [_lbStatus setText: [localization localizedStringForKey:text_offline]];
                break;
            }
        }
        [_lbStatus sizeToFit];
        CGRect fitRect = [_lbStatus frame];
        if (fitRect.size.width > 220) {
            [_lbStatus setFrame: CGRectMake((SCREEN_WIDTH-220)/2, _lbUserName.frame.origin.y+_lbUserName.frame.size.height+3, 220, fitRect.size.height)];
        }else{
            [_lbStatus setFrame: CGRectMake((SCREEN_WIDTH-fitRect.size.width)/2, _lbUserName.frame.origin.y+_lbUserName.frame.size.height+3, fitRect.size.width, fitRect.size.height)];
        }
    }
}

- (void)deleteConversationSuccess {
    if (_listMessages == nil) {
        _listMessages = [[NSMutableArray alloc] init];
    }else{
        [_listMessages removeAllObjects];
    }
    [_tbChat reloadData];
    appDelegate._heightChatTbView = 0.0;
    [_lbNoMessage setHidden: false];
}

//  Hàm save conversation chat
- (void)saveConversationAccepted: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[NSString class]]) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", @"export"]];
        BOOL isDir;
        BOOL exists = [fileManager fileExistsAtPath:databasePath isDirectory:&isDir];
        if (!exists) {
            [[NSFileManager defaultManager] createDirectoryAtPath:databasePath withIntermediateDirectories:NO attributes:nil error:&error];
        }
        
        NSString *html = [NSString stringWithFormat:@"<html><head><meta http-equiv=\"content-type\" content=\"text/html;charset=UTF-8\"></head><body>%@</body><html>", [self createDataForSaveConversation]];
        
        NSString *fileLocation = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Export/%@", object]];
        
        [html writeToFile:fileLocation atomically:NO encoding:NSUTF8StringEncoding error:&error];
    }
    [self showMessagePopupWithString: [localization localizedStringForKey:text_export_success]];
}

//  Tạo dữ liệu để save conversation
- (NSString *)createDataForSaveConversation {
    NSString *resultStr = @"";
    NSString *meStr = [NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone];
    NSString *userStr = [NSString stringWithFormat:@"%@@%@", _userAccount, xmpp_cloudfone];
    
    for (int iCount = 0; iCount<_listMessages.count; iCount++) {
        NSBubbleData *curData = [_listMessages objectAtIndex: iCount];
        if ([curData.typeMessage isEqualToString: typeTextMessage]) {
            if ([curData.view isKindOfClass:[UILabel class]]) {
                NSString *content = [(UILabel *)curData.view text];
                if (curData.type == BubbleTypeSomeoneElse) {
                    content = [NSString stringWithFormat:@"%@(%@)<br/>%@", meStr, curData.time, content];
                }else{
                    content = [NSString stringWithFormat:@"%@(%@)<br/>%@", userStr, curData.time, content];
                }
                resultStr = [NSString stringWithFormat:@"%@<br/>%@", resultStr, content];
            }
        }else if([curData.typeMessage isEqualToString: imageMessage]){
            NSString *content = @"";
            if (curData.type == BubbleTypeSomeoneElse) {
                content = [NSString stringWithFormat:@"%@(%@)<br/> Send image", meStr, curData.time];
            }else{
                content = [NSString stringWithFormat:@"%@(%@)<br/> Send image", userStr, curData.time];
            }
            resultStr = [NSString stringWithFormat:@"%@<br/>%@", resultStr, content];
        }else if([curData.typeMessage isEqualToString: audioMessage]){
            NSString *content = @"";
            if (curData.type == BubbleTypeSomeoneElse) {
                content = [NSString stringWithFormat:@"%@(%@)<br/> Send audio", meStr, curData.time];
            }else{
                content = [NSString stringWithFormat:@"%@(%@)<br/> Send audio", userStr, curData.time];
            }
            resultStr = [NSString stringWithFormat:@"%@<br/>%@", resultStr, content];
        }else if ([curData.typeMessage isEqualToString: videoMessage]){
            NSString *content = @"";
            if (curData.type == BubbleTypeSomeoneElse) {
                content = [NSString stringWithFormat:@"%@(%@)<br/> Send video", meStr, curData.time];
            }else{
                content = [NSString stringWithFormat:@"%@(%@)<br/> Send video", userStr, curData.time];
            }
            resultStr = [NSString stringWithFormat:@"%@<br/>%@", resultStr, content];
        }
    }
    return resultStr;
}

//  tap tren label album de chon album anh khac
- (void)whenTapOnLabelAlbum {
    [[NSNotificationCenter defaultCenter] postNotificationName:showListAlbumForView
                                                        object:nil];
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

/*--Hàm xử lý khi touch vào message--*/
/*
 Đối với message nhận được:
 + Text message: -> msg recall, transfer money, expire -> delete
 -> msg thông thường -> copy, forward, delete
 + Image messsage    -> forward, delete
 
 Đối với message send:
 + Text message: -> recall, transfermoney -> delete
 + Image message: forward, delete
 */
- (void)touchAMessageWithNotification: (NSNotification *)touchNotification {
    id tagNum = [touchNotification object];
    if ([tagNum isKindOfClass:[NSNumber class]]) {
        idMsgForward = [tagNum intValue];
        NSBubbleData *data = [_listMessages objectAtIndex: idMsgForward];
        
        [self createDataWhenTouchOnMessage:data.typeMessage
                             andExpireTime:data.expireTime
                                 andRecall:data.isRecall
                                  ofBubble:appDelegate.typeBubbleTouch
                       andDeliveredMessage:data.status];
    }
}

- (void)createDataWhenTouchOnMessage: (NSString *)typeMessage andExpireTime: (int)expire andRecall: (NSString *)recall ofBubble: (int)typeBubble andDeliveredMessage: (int)deliveredMsg
{
    // Nếu message là text message mà có expire time hay recall thì chỉ có thể DELETE
    if (([typeMessage isEqualToString: typeTextMessage] && (expire > 0 || [recall isEqualToString:@"YES"]))) {
        [self createDataWhenTouchOnMessageRecallReceive];
        [self showPopupWhenTouchMessage];
    }else {
        if (typeBubble == BubbleTypeSomeoneElse) {
            // Đối với textMessage nhận được thì không có recall
            if ([typeMessage isEqualToString: typeTextMessage]) {
                [self createDataWhenTouchOnMessageNoRecall];
            }else if ([typeMessage isEqualToString: audioMessage] || [typeMessage isEqualToString: imageMessage] || [typeMessage isEqualToString: videoMessage]) {
                // Đối với media message nhận được mà có recall thì chỉ có thể DELETE
                if (expire > 0) {
                    [self createDataWhenTouchOnImageReceiveWithExpireTime];
                }else{
                    [self createDataWhenTouchOnImageReceive];
                }
            }else if ([typeMessage isEqualToString: locationMessage]){
                [self createDataWhenTouchOnImageReceive];
            }
            [self showPopupWhenTouchMessage];
        }else{
            // textMessage send đi sẽ có recall
            if ([typeMessage isEqualToString: typeTextMessage]) {
                // Nếu delivered = 0 thì sẽ có resend
                [self createDataWhenTouchOnMessageWithDelivered:deliveredMsg];
            }else if ([typeMessage isEqualToString: imageMessage ] || [typeMessage isEqualToString:audioMessage] || [typeMessage isEqualToString: videoMessage]){
                [self createDataWhenTouchOnImageMeSend: deliveredMsg];
            }else if ([typeMessage isEqualToString: locationMessage]){
                [self createDataWhenTouchOnImageMeSend: deliveredMsg];
            }
            [self showPopupWhenTouchMessage];
        }
    }
}

//  Call trong view chat
- (void)onCallForUserInViewChat {
    if (!callOnMessage) {
        stringForCall = [[NSString alloc] initWithString: _userAccount];
    }else{
        stringForCall = [[NSString alloc] initWithString: phoneNumberOnMessage];
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
        
        NSString *typeMessage = [object objectForKey:@"typeMessage"];
        if ([typeMessage isEqualToString:contactMessage]) {
            if ([user isEqualToString: _userAccount]) {
                NSString *idMessage = [object objectForKey:@"idMessage"];
                NSBubbleData *lastMsgData = [NSDatabase getDataOfMessage: idMessage];
                [_listMessages addObject: lastMsgData];
                
                // Post notification để lấy last row visibility
                [[NSNotificationCenter defaultCenter] postNotificationName:getRowsVisibleViewChat object:nil];
                
                [self updateAllFrameForController: false];
                if (appDelegate.lastRowVisibleChat.row < _listMessages.count-2) {
                    CGRect cbRect = _viewFooter.frame;
                    [viewNewMsg setHidden: false];
                    [viewNewMsg setFrame: CGRectMake(viewNewMsg.frame.origin.x, cbRect.origin.y-viewNewMsg.frame.size.height - 3, viewNewMsg.frame.size.width, viewNewMsg.frame.size.height)];
                }else{
                    [self updateAndGotoLastViewChat];
                }
            }
        }else{
            if ([user isEqualToString: _userAccount]) {
                NSString *idMessage = [object objectForKey:@"idMessage"];
                NSBubbleData *lastMsgData = [NSDatabase getDataOfMessage: idMessage];
                appDelegate._heightChatTbView = appDelegate._heightChatTbView + (lastMsgData.view.frame.size.height+8);
                [_listMessages addObject: lastMsgData];
                
                // Post notification để lấy last row visibility
                [[NSNotificationCenter defaultCenter] postNotificationName:getRowsVisibleViewChat object:nil];
                
                [self updateAllFrameForController: false];
                if (appDelegate.lastRowVisibleChat != nil && appDelegate.lastRowVisibleChat.row < _listMessages.count-2) {
                    CGRect cbRect = _viewFooter.frame;
                    [viewNewMsg setHidden: FALSE];
                    [viewNewMsg setFrame: CGRectMake(viewNewMsg.frame.origin.x, cbRect.origin.y-viewNewMsg.frame.size.height - 3, viewNewMsg.frame.size.width, viewNewMsg.frame.size.height)];
                }else{
                    [self updateAndGotoLastViewChat];
                }
                
                // Kiểm tra đk và xoá tin nhắn expire
                if (lastMsgData.expireTime > 0) {
                    [self startAllExpireMessageOfMe];
                }
            }
        }
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

//  Cập nhật trạng thái của message sau khi nhận delivered text message
- (void)updateReceiveMessage: (NSNotification *)notif
{
    id object = [notif object];
    if ([object isKindOfClass:[NSString class]]) {
        NSString *idMessage = (NSString *)object;
        [NSDatabase updateMessageDelivered: idMessage withValue:2];
        NSBubbleData *dataMessage = [NSDatabase getDataOfMessage: idMessage];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"idMessage = %@", idMessage];
        NSArray *updateData = [_listMessages filteredArrayUsingPredicate: predicate];
        if (updateData.count > 0) {
            int replaceIndex = (int)[_listMessages indexOfObject: [updateData objectAtIndex: 0]];
            [_listMessages replaceObjectAtIndex:replaceIndex withObject:dataMessage];
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
                                                 selector:@selector(deleteAllMessageExpiredOfMe)
                                                 userInfo:_userAccount
                                                  repeats:YES];
}

//  Xoá tất cả tin nhắn đã hết hạn
- (void)deleteAllMessageExpiredOfMe
{
    
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

- (void)setupUIForView {
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }else{
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
    }
    
    //  view header
    [_viewHeader setFrame: CGRectMake(0, 0, SCREEN_WIDTH, appDelegate._hHeader)];
    [_iconBack setFrame: CGRectMake(0, 0, appDelegate._hHeader, appDelegate._hHeader)];
    [_iconBack setBackgroundImage:[UIImage imageNamed:@"ic_back_act.png"]
                         forState:UIControlStateHighlighted];
    
    [_icSetting setFrame: CGRectMake(_viewHeader.frame.size.width-_iconBack.frame.size.width, _iconBack.frame.origin.y, _iconBack.frame.size.width, _iconBack.frame.size.height)];
    [_icSetting setBackgroundImage:[UIImage imageNamed:@"ic_add_user_def.png"]
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
}

- (void)setupUIForViewOld
{
    /*  Leo Kelvin
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }else{
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
    }
    
    //  view header
    [_viewHeader setFrame: CGRectMake(0, 0, SCREEN_WIDTH, appDelegate._hHeader)];
    [_iconBack setFrame: CGRectMake(0, 0, appDelegate._hHeader, appDelegate._hHeader)];
    [_iconBack setBackgroundImage:[UIImage imageNamed:@"ic_back_act.png"]
                         forState:UIControlStateHighlighted];
    
    [_icSetting setFrame: CGRectMake(_viewHeader.frame.size.width-_iconBack.frame.size.width, _iconBack.frame.origin.y, _iconBack.frame.size.width, _iconBack.frame.size.height)];
    [_icSetting setBackgroundImage:[UIImage imageNamed:@"ic_add_user_def.png"]
                            forState:UIControlStateHighlighted];
    
    //  view album cho gui hinh anh
    [_viewAlbum setFrame: _viewHeader.frame];
    [_iconClose setFrame: CGRectMake((_viewAlbum.frame.size.height-30)/2, (_viewAlbum.frame.size.height-30)/2, 30, 30)];
    [_lbAlbumName setFont:[UIFont fontWithName:HelveticaNeue size:15.0]];
    [_lbAlbumName setUserInteractionEnabled: true];
    UITapGestureRecognizer *tapOnAlbum = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTapOnLabelAlbum)];
    [_lbAlbumName addGestureRecognizer: tapOnAlbum];
    [_viewAlbum setHidden: true];
    
    // view footer
    if (SCREEN_WIDTH > 320) {
        hChatBox = 46.0;
        hChatIcon = 35.0;
    }else{
        hChatBox = 38.0;
        hChatIcon = 30.0;
    }
    
    [_viewFooter setFrame: CGRectMake(0, SCREEN_HEIGHT-(appDelegate._hStatus+hChatBox), SCREEN_WIDTH, hChatBox)];
    firstChatBox = [_viewFooter frame];
    
    [_icCamera setFrame: CGRectMake(0, (hChatBox-hChatIcon)/2, hChatIcon, hChatIcon)];
    
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
    
    // View nhận tin nhắn mới
    viewNewMsg = [[UIView alloc] init];
    [viewNewMsg setClipsToBounds: true];
    [viewNewMsg.layer setCornerRadius: 10.0f];
    [viewNewMsg setBackgroundColor:[UIColor colorWithRed:(120/255.0) green:(79/255.0)
                                                    blue:(159/255.0) alpha:1.0]];
    [viewNewMsg setHidden: true];
    
    UILabel *lbNewMsg = [[UILabel alloc] init];
    [lbNewMsg setText: [localization localizedStringForKey:text_new_message]];
    [lbNewMsg setTextAlignment: NSTextAlignmentLeft];
    [lbNewMsg setFont:[UIFont fontWithName:HelveticaNeue size:14.0]];
    [lbNewMsg setTextColor:[UIColor whiteColor]];
    [lbNewMsg setUserInteractionEnabled:true];
    [lbNewMsg sizeToFit];
    [lbNewMsg setFrame: CGRectMake(10, 0, lbNewMsg.frame.size.width, 30)];
    [viewNewMsg addSubview: lbNewMsg];
    
    // icon cho new message
    UIImageView *iconNewMsg = [[UIImageView alloc] initWithFrame: CGRectMake(lbNewMsg.frame.origin.x+lbNewMsg.frame.size.width+5, 8, 9, 14)];
    [iconNewMsg setImage:[UIImage imageNamed:@"ic_new_message.png"]];
    [viewNewMsg addSubview: iconNewMsg];
    
    UITapGestureRecognizer *tapGotoLastRow = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateAndGotoLastViewChat)];
    [viewNewMsg addGestureRecognizer: tapGotoLastRow];
    [self.view addSubview: viewNewMsg];
    
    // SETUP định dạng cho label contact name và  label status
    [_lbUserName setMarqueeType:MLContinuous];
    [_lbUserName setScrollDuration: 15.0f];
    [_lbUserName setAnimationCurve:UIViewAnimationOptionCurveEaseOut];
    [_lbUserName setFadeLength: 10.0f];
    [_lbUserName setContinuousMarqueeExtraBuffer: 10.0f];
    [_lbUserName setTextColor:[UIColor whiteColor]];
    [_lbUserName setBackgroundColor:[UIColor clearColor]];
    [_lbUserName setTextAlignment:NSTextAlignmentCenter];
    [_lbUserName setFont:[UIFont fontWithName:HelveticaNeue size:15.0]];
    
    [_lbStatus setScrollDuration: 15.0f];
    [_lbStatus setAnimationCurve:UIViewAnimationOptionCurveEaseOut];
    [_lbStatus setFadeLength: 10.0f];
    [_lbStatus setContinuousMarqueeExtraBuffer: 10.0f];
    [_lbStatus setTextColor:[UIColor whiteColor]];
    [_lbStatus setBackgroundColor:[UIColor clearColor]];
    [_lbStatus setTextAlignment:NSTextAlignmentCenter];
    [_lbStatus setFont:[UIFont fontWithName:HelveticaNeue size:12.0]];
    */
}

//  Đóng bàn phím chat
- (void)dismissKeyboard {
    [self.view endEditing: true];
    
    [UIView animateWithDuration:0.2 animations:^{
        viewEmotion.frame = CGRectMake(viewEmotion.frame.origin.x, SCREEN_HEIGHT-appDelegate._hStatus, viewEmotion.frame.size.width, 0);
        viewChatMore.frame = CGRectMake(viewChatMore.frame.origin.x, SCREEN_HEIGHT-appDelegate._hStatus, viewChatMore.frame.size.width, 0);
        _viewFooter.frame = CGRectMake(_viewFooter.frame.origin.x, SCREEN_HEIGHT-appDelegate._hStatus-_viewFooter.frame.size.height, _viewFooter.frame.size.width, _viewFooter.frame.size.height);
        
        //  View footer thay đổi thì thay đổi view chat
        [self updateFrameOfViewChatWithViewFooter];
    }];
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

- (void)addMoreViewForViewChat {
    hViewEmotion = 195.0;
    
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"MoreChatView" owner:nil options:nil];
    for(id currentObject in subviewArray){
        if ([currentObject isKindOfClass:[MoreChatView class]]) {
            viewChatMore = (MoreChatView *) currentObject;
            break;
        }
    }
    viewChatMore.frame = CGRectMake(0, SCREEN_HEIGHT-appDelegate._hStatus, SCREEN_WIDTH, 0);
    [self.view addSubview: viewChatMore];
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
    
    [viewPhotos setFrame: CGRectMake(viewPhotos.frame.origin.x, SCREEN_HEIGHT-appDelegate._hStatus, viewPhotos.frame.size.width, 0)];
    [viewPhotos setAlpha: 1.0];
    
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
        [viewNewMsg setHidden: true];
    }
}

//  Trả về chiều cao của các tin nhắn của user
- (float)getHeightOfAllMessageOfUserWithMaxHeight: (float)maxHeight {
    float totalHeight = 0;
    for (int iCount=0; iCount<_listMessages.count; iCount++) {
        NSBubbleData *curMessage = [_listMessages objectAtIndex: iCount];
        totalHeight = totalHeight + curMessage.view.frame.size.height+8;
        if (totalHeight >= maxHeight) {
            break;
        }
    }
    return totalHeight;
}

//  Cập nhật dữ liệu và scroll đến cuối list
- (void)updateAndGotoLastViewChat {
    [_tbChat reloadData];
    if (_listMessages.count > 0) {
        [_tbChat scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(_tbChat.bubbleData.count-1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        [viewNewMsg setHidden: true];
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

//  Cập nhật trạng thái đang nhập của user
- (void)updateChatState:(BOOL)animated {
    if(appDelegate.friendBuddy.chatState == kOTRChatStateComposing) {
        [lbChatComposing setFrame:CGRectMake(10, _viewFooter.frame.origin.y-15, SCREEN_WIDTH-20, 15)];
        [lbChatComposing setText: [localization localizedStringForKey:text_is_typing]];
        [lbChatComposing setHidden: false];
        
        [_tbChat setFrame:CGRectMake(_tbChat.frame.origin.x, _tbChat.frame.origin.y, _tbChat.frame.size.width, _viewChat.frame.size.height-20)];
        
        // Nếu nhận composing và đang ở cuối khung chat thì đẩy tableview chat lên
        NSArray *tmpArr = [_tbChat indexPathsForVisibleRows];
        if (tmpArr.count > 0) {
            NSIndexPath *lastIndex = [tmpArr lastObject];
            if (lastIndex.row == _listMessages.count-1) {
                NSIndexPath* ip = [NSIndexPath indexPathForRow:(_listMessages.count - 1) inSection:0];
                [_tbChat scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
                [viewNewMsg setHidden: true];
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

//  set thông tin hiển thị cho phần header chat với user
- (void)setHeaderInfomationOfUser
{
    // setup username
    NSString *contactName =  [NSDatabase getNameOfContactWithPhoneNumber: _userAccount];
    [_lbUserName setText: contactName];
    [_lbUserName sizeToFit];
    
    NSArray *infos = [NSDatabase getContactNameOfCloudFoneID: _userAccount];
    if (infos.count >= 2) {
        if (![[infos objectAtIndex: 1] isEqualToString:@""]) {
            NSData *data = [NSData dataFromBase64String: [infos objectAtIndex: 1]];
            [appDelegate setUserImage: [UIImage imageWithData: data]];
        }
    }
    [_icSetting setHidden: false];
    
    // set trạng thái của user
    [self setStatusStringOfUser:_userAccount];
    
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
            [_lbStatus setText: [localization localizedStringForKey:text_chat_offline]];
            break;
        }
        case kOTRBuddyStatusOffline:{
            [_icStatus setImage: [UIImage imageNamed:@"ic_status_unavailable.png"]];
            [_lbStatus setText: [localization localizedStringForKey:text_chat_offline]];
            break;
        }
        case kOTRBuddyStatusAvailable:{
            if (appDelegate.friendBuddy.encryptionStatus == kOTRKitMessageStateEncrypted) {
                [_icStatus setImage: [UIImage imageNamed:@"ic_status_encripted.png"]];
            }else{
                [_icStatus setImage: [UIImage imageNamed:@"ic_status_available.png"]];
            }
            NSString *statusStr = [appDelegate._statusXMPPDict objectForKey: _userAccount];
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

//  Get lịch sử tin nhắn với user
- (void)getHistoryMessagesWithUser: (NSString *)user {
    if (_listMessages == nil) {
        _listMessages = [[NSMutableArray alloc] init];
    }else{
        [_listMessages removeAllObjects];
    }
    
    appDelegate._heightChatTbView = 0.0;
    
    [_listMessages addObjectsFromArray: [NSDatabase getListMessagesHistory:USERNAME withPhone: user]];
    
    // Cập nhật tất cả các tin nhắn chưa đọc thành đã đọc
    [NSDatabase changeStatusMessageAFriend: user];
    
    // Forward tin nhắn nếu có
    if (appDelegate._msgForward != nil) {
        [self sendMessageFowardToUser];
    }
    
    // Gửi ảnh hoặc conversation nếu tồn tại
    [self sendMessageConversation];
    
    [self updateAllFrameForController: false];
    [self updateAndGotoLastViewChat];
    
    // Thông báo cập nhật nội dung trong LeftMenu
    [[NSNotificationCenter defaultCenter] postNotificationName:updateUnreadMessageForUser object:nil];
}

//  Gửi message đã được forward trước đó
- (void)sendMessageFowardToUser {
    int deliveredStatus = 0;
    if (appDelegate.xmppStream.isConnected) {
        deliveredStatus = 1;
    }
    
    // Send nội dung message forward: message
    if ([appDelegate._msgForward.typeMessage isEqualToString: typeTextMessage])
    {
        NSString *msgContent = [appDelegate._msgForward.lbContent text];
        [self sendTextMessageForward: msgContent];
    }else if([appDelegate._msgForward.typeMessage isEqualToString: imageMessage])
    {
        NSString *idMessageStr = [AppUtils randomStringWithLength: 10];
        
        // Sao chép hình ảnh forward
        NSDictionary *infoDict = [NSDatabase copyImageOfMessageForward: appDelegate._msgForward.idMessage];
        NSString *thumb_url = [infoDict objectForKey:@"thumb"];
        NSString *details_url = [infoDict objectForKey:@"detail"];
        NSString *description = [infoDict objectForKey:@"description"];
        
        // send image forward
        UIImage *imgForward = [AppUtils getImageOfDirectoryWithName: details_url];
        if (imgForward != nil) {
            // save message forward
            [NSDatabase saveMessage:USERNAME toPhone:_userAccount withContent:description andStatus:YES withDelivered:deliveredStatus andIdMsg:idMessageStr detailsUrl:details_url andThumbUrl:thumb_url withTypeMessage:appDelegate._msgForward.typeMessage andExpireTime:0 andRoomID:@"" andExtra:@"" andDesc:@""];
            
            //  Thêm message tạm vào view chat
            NSBubbleData *lastMsgData = [NSDatabase getDataOfMessage: idMessageStr];
            [_listMessages addObject: lastMsgData];
            
            [self updateAllFrameForController: false];
            [self updateAndGotoLastViewChat];
            
            NSData *dataSend = UIImageJPEGRepresentation(imgForward, 1);
            NSString *userStr = [NSString stringWithFormat:@"%@/%@", appDelegate.friendBuddy.accountName, appDelegate.friendBuddy.resourceStr];
            [self sendFileToUser:userStr data:dataSend fileName:details_url description:description idMessage:idMessageStr];
        }else{
            [self showMessagePopupWithString: [localization localizedStringForKey:text_failed]];
        }
    }
    appDelegate._msgForward = nil;
}

//  Send image message hoặc message conversation nếu tồn tại
- (void)sendMessageConversation {
    if (![appDelegate.msgHisForward isEqualToString:@""] && appDelegate.msgHisForward != nil){
        int deliveredStatus = 0;
        if (appDelegate.xmppStream.isConnected) {
            deliveredStatus = 1;
        }
        
        NSString *idMessage = [AppUtils randomStringWithLength: 8];
        [NSDatabase saveMessage:USERNAME toPhone:_userAccount withContent:appDelegate.msgHisForward andStatus:YES withDelivered:deliveredStatus andIdMsg:idMessage detailsUrl:@"" andThumbUrl:@"" withTypeMessage:typeTextMessage andExpireTime:0 andRoomID:@"" andExtra:nil andDesc:nil];
        
        NSBubbleData *aMessage = [[NSBubbleData alloc] initWithText:appDelegate.msgHisForward type:BubbleTypeMine time:[AppUtils getCurrentTime] status:deliveredStatus idMessage:idMessage withExpireTime:0 isRecall:@"NO" description:@"" withTypeMessage:typeTextMessage isGroup:NO ofUser:nil];
        
        [_listMessages addObject: aMessage];
        
        //  Hiển thị tin nhắn và scroll xuống dòng cuối
        [self updateAllFrameForController: false];
        [self updateAndGotoLastViewChat];
        
        BOOL secure = false;
        if (appDelegate.friendBuddy.encryptionStatus == kOTRKitMessageStateEncrypted) {
            secure = true;
        }
        [appDelegate.friendBuddy sendMessage: appDelegate.msgHisForward secure:secure withIdMessage:idMessage];
        [appDelegate setMsgHisForward:@""];
    }
}

//  Hàm gửi tin nhắn đã được forward trước đó
- (void)sendTextMessageForward: (NSString *)msgContent {
    int deliveredStatus = 0;
    if (appDelegate.xmppStream.isConnected) {
        deliveredStatus = 1;
    }
    NSString *idMessage = [AppUtils randomStringWithLength: 8];
    NSString *receivePhone = [AppUtils getSipFoneIDFromString: appDelegate.friendBuddy.accountName];
    
    [NSDatabase saveMessage:USERNAME toPhone:receivePhone withContent:msgContent andStatus:true withDelivered:deliveredStatus andIdMsg:idMessage detailsUrl:@"" andThumbUrl:@"" withTypeMessage:typeTextMessage andExpireTime:-1 andRoomID:@"" andExtra:@"" andDesc:@""];
    
    // Hiển thị tin nhắn
    NSBubbleData *aMessage = [[NSBubbleData alloc] initWithText: msgContent type:BubbleTypeMine time: [AppUtils getCurrentTime] status: 1 idMessage:idMessage withExpireTime:0 isRecall:@"NO" description:@"" withTypeMessage:typeTextMessage isGroup:NO ofUser:nil];
    
    [_listMessages addObject: aMessage];
    
    // Tính lại chiều cao
    [self updateAllFrameForController: false];
    [self updateAndGotoLastViewChat];
    
    // Gửi message
    BOOL secure = false;
    if (appDelegate.friendBuddy.encryptionStatus == kOTRKitMessageStateEncrypted) {
        secure = true;
    }
    [appDelegate.friendBuddy sendMessage: msgContent secure: secure withIdMessage:idMessage];
    
    //  Xoá message forward
    [appDelegate set_msgForward: nil];
}

// Hiển thị popup khi send request thành công
- (void)showMessagePopupWithString: (NSString *)contentString {
    if (messageView == nil) {
        messageView = [[UIView alloc] init];
        [messageView setBackgroundColor:[UIColor blackColor]];
        [messageView.layer setCornerRadius:10.0];
        [_viewChat addSubview: messageView];
    }
    
    if (lbMessage == nil) {
        lbMessage = [[UILabel alloc] init];
        [lbMessage setBackgroundColor:[UIColor clearColor]];
        [lbMessage setFont: [UIFont fontWithName:HelveticaNeue size:13.0]];
        [lbMessage setTextAlignment: NSTextAlignmentCenter];
        [lbMessage setTextColor:[UIColor whiteColor]];
        [messageView addSubview: lbMessage];
    }
    [lbMessage setText: contentString];
    [lbMessage sizeToFit];
    
    [messageView setFrame: CGRectMake((SCREEN_WIDTH-(lbMessage.frame.size.width+20))/2, _viewChat.frame.size.height-40, lbMessage.frame.size.width+20, 30)];
    [lbMessage setFrame: CGRectMake(10, 0, lbMessage.frame.size.width, 30)];
    
    [messageView setTransform: CGAffineTransformMakeScale(1.0, 1.0)];
    [messageView setAlpha: 0.0];
    [UIView animateWithDuration:1.0f animations:^{
        [messageView setAlpha: 1.0];
    }completion:^(BOOL finish){
        [UIView animateWithDuration:4.5f animations:^{
            [messageView setTransform: CGAffineTransformMakeScale(1.0, 1.0)];
            [messageView setAlpha: 0.0];
        } completion:^(BOOL finished) {
        }];
    }];
}

#pragma mark - tableview chats
- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView {
    return [_listMessages count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row {
    return [_listMessages objectAtIndex:row];
}

#pragma mark - XMPPOutgoingFileTransferDelegate Methods

//  Gửi file
- (void)sendFileToUser: (NSString *)user data: (NSData *)data fileName: (NSString *)fileName description: (NSString *)desc idMessage: (NSString *)idMessage
{
    XMPPOutgoingFileTransfer *_fileTransfer = [[XMPPOutgoingFileTransfer alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    [[NSNotificationCenter defaultCenter] postNotificationName:activeOutgoingFileTransfer object:_fileTransfer];
    [_fileTransfer addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *err;
    if (![_fileTransfer sendData:data named:fileName
                     toRecipient:[XMPPJID jidWithString:user]
                     description:desc error:&err andIdMessage:idMessage]) {
        NSLog(@"You messed something up: %@", err);
    }
}

#pragma mark - UITextview Delegate
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

#pragma mark - file transfer

- (void)xmppOutgoingFileTransfer:(XMPPOutgoingFileTransfer *)sender didFailWithError:(NSError *)error {
    BOOL success = [NSDatabase updateMessageWhenSendFileFailed: sender.idMessage];
    if (success) {
        NSBubbleData *dataMessage = [NSDatabase getDataOfMessage: sender.idMessage];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"idMessage = %@", sender.idMessage];
        NSArray *updateData = [_listMessages filteredArrayUsingPredicate: predicate];
        if (updateData.count > 0) {
            int replaceIndex = (int)[_listMessages indexOfObject: [updateData objectAtIndex: 0]];
            [_listMessages replaceObjectAtIndex:replaceIndex withObject:dataMessage];
            
            [_tbChat reloadData];
        }
    }
}

- (void)updateMessageWhenSendFileFailed: (NSString *)idMessage {
    [NSDatabase updateMessageWhenSendFileFailed: idMessage];
}

//  Sau khi send file thành công thì cập nhật trạng thái tin nhắn
- (void)xmppOutgoingFileTransferDidSucceed:(XMPPOutgoingFileTransfer *)sender {
    NSString *idMessage = sender.idMessage;
    NSString *user = sender.recipientJID.user;
    [self afterSendFileSuccessfullyToUser:user withIdMessage:idMessage];
}

//  Sau khi send file thành công
- (void)afterSendFileSuccessfullyToUser: (NSString *)user withIdMessage: (NSString *)idMessage
{
    [NSDatabase updateDeliveredMessageAfterSend: idMessage];
    
    NSBubbleData *dataMessage = [NSDatabase getDataOfMessage: idMessage];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"idMessage = %@", idMessage];
    NSArray *rsArr = [_listMessages filteredArrayUsingPredicate: predicate];
    if (rsArr.count > 0) {
        int replaceIndex = (int)[_listMessages indexOfObject: [rsArr objectAtIndex: 0]];
        [_listMessages replaceObjectAtIndex:replaceIndex withObject:dataMessage];
        [_tbChat reloadData];
    }
    // Xoá tin nhắn expire
    if (expireTimer == nil && dataMessage.expireTime > 0) {
        [self startAllExpireMessageOfMe];
    }
}

//  TẠO DỮ LIỆU KHI TOUCH VÀO TRANSFER MONEY VÀ RECALL MESSAGE
- (void)createDataWhenTouchOnMessageRecallReceive {
    typeTouchOnMessage = eTextRecallOrExpireTime;
    touchMessageArr = [[NSMutableArray alloc] init];
    SettingItem *itemSet = [[SettingItem alloc] init];
    itemSet = [[SettingItem alloc] init];
    itemSet._imageStr = @"delete_conversation.png";
    itemSet._valueStr = [localization localizedStringForKey:text_message_delete];
    [touchMessageArr addObject: itemSet];
}

//  Hiển thị popup khi touch vào message
- (void)showPopupWhenTouchMessage
{
    CGRect popupRect = CGRectMake((SCREEN_WIDTH-230-6)/2, (SCREEN_HEIGHT-20-(touchMessageArr.count*40+6))/2, 230+6, touchMessageArr.count*40+5);
    popUpTouchMessage = [[SettingPopupView alloc] initWithFrame: popupRect];
    [popUpTouchMessage._settingTableView setDelegate: self];
    [popUpTouchMessage._settingTableView setDataSource: self];
    if ([popUpTouchMessage._settingTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [popUpTouchMessage._settingTableView setSeparatorInset: UIEdgeInsetsZero];
    }
    [popUpTouchMessage._settingTableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
    [popUpTouchMessage showInView:appDelegate.window animated:YES];
}

//  TẠO DỮ LIỆU KHI TOUCH VÀO MESSAGE NHẬN ĐƯỢC
- (void)createDataWhenTouchOnMessageNoRecall{
    typeTouchOnMessage = eNormalMessageReceived;
    touchMessageArr = [[NSMutableArray alloc] init];
    SettingItem *itemSet = [[SettingItem alloc] init];
    itemSet._imageStr = @"copy.png";
    itemSet._valueStr = [localization localizedStringForKey:text_message_copy];
    [touchMessageArr addObject: itemSet];
    
    itemSet = [[SettingItem alloc] init];
    itemSet._imageStr = @"forward.png";
    itemSet._valueStr = [localization localizedStringForKey:text_message_forward];
    [touchMessageArr addObject: itemSet];
    
    itemSet = [[SettingItem alloc] init];
    itemSet._imageStr = @"delete_conversation.png";
    itemSet._valueStr = [localization localizedStringForKey:text_message_delete];
    [touchMessageArr addObject: itemSet];
}

//  TẠO DỮ LIỆU KHI TOUCH VÀO IMAGE CÓ EXPIRE TIME
- (void)createDataWhenTouchOnImageReceiveWithExpireTime{
    typeTouchOnMessage = eImageReceivedWithExpireTime;
    
    touchMessageArr = [[NSMutableArray alloc] init];
    SettingItem *itemSet = [[SettingItem alloc] init];
    itemSet = [[SettingItem alloc] init];
    itemSet._imageStr = @"delete_conversation.png";
    itemSet._valueStr = [localization localizedStringForKey:text_message_delete];
    [touchMessageArr addObject: itemSet];
}

//  TẠO DỮ LIỆU KHI TOUCH VÀO IMAGE NHẬN ĐƯỢC
- (void)createDataWhenTouchOnImageReceive {
    typeTouchOnMessage  = eImageReceived;
    touchMessageArr = [[NSMutableArray alloc] init];
    SettingItem *itemSet = [[SettingItem alloc] init];
    itemSet = [[SettingItem alloc] init];
    itemSet._imageStr = @"forward.png";
    itemSet._valueStr = [localization localizedStringForKey:text_message_forward];
    [touchMessageArr addObject: itemSet];
    
    itemSet = [[SettingItem alloc] init];
    itemSet._imageStr = @"delete_conversation.png";
    itemSet._valueStr = [localization localizedStringForKey:text_message_delete];
    [touchMessageArr addObject: itemSet];
}

//  TẠO DỮ LIỆU KHI TOUCH VÀO MESSAGE CỦA MÌNH
- (void)createDataWhenTouchOnMessageWithDelivered: (int)delivered {
    touchMessageArr = [[NSMutableArray alloc] init];
    SettingItem *itemSet;
    if (delivered == 0) {
        itemSet = [[SettingItem alloc] init];
        itemSet._imageStr = @"icon_phone_sync.png";
        itemSet._valueStr = [localization localizedStringForKey:text_message_resend];
        [touchMessageArr addObject: itemSet];
        typeTouchOnMessage = eMyMessageWithResend;
    }else{
        typeTouchOnMessage = eMyMessageNoResend;
    }
    
    itemSet = [[SettingItem alloc] init];
    itemSet._imageStr = @"copy.png";
    itemSet._valueStr = [localization localizedStringForKey:text_message_copy];
    [touchMessageArr addObject: itemSet];
    
    itemSet = [[SettingItem alloc] init];
    itemSet._imageStr = @"forward.png";
    itemSet._valueStr = [localization localizedStringForKey:text_message_forward];
    [touchMessageArr addObject: itemSet];
    
    itemSet = [[SettingItem alloc] init];
    itemSet._imageStr = @"delete_conversation.png";
    itemSet._valueStr = [localization localizedStringForKey:text_message_delete];
    [touchMessageArr addObject: itemSet];
    
    itemSet = [[SettingItem alloc] init];
    itemSet._imageStr = @"recall.png";
    itemSet._valueStr = [localization localizedStringForKey:text_message_recall];
    [touchMessageArr addObject: itemSet];
}

//  TẠO MẢNG DỮ LIỆU KHI TOUCH VÀO MESSAGE ẢNH GỬI ĐI
- (void)createDataWhenTouchOnImageMeSend: (int)delivered {
    touchMessageArr = [[NSMutableArray alloc] init];
    
    SettingItem *itemSet;
    if (delivered == 0) {
        itemSet = [[SettingItem alloc] init];
        itemSet._imageStr = @"icon_phone_sync.png";
        itemSet._valueStr = [localization localizedStringForKey:text_message_resend];
        [touchMessageArr addObject: itemSet];
        
        typeTouchOnMessage = eMyImageSendWithResend;
    }else{
        typeTouchOnMessage = eMyImageSendNoReSend;
    }
    
    itemSet = [[SettingItem alloc] init];
    itemSet = [[SettingItem alloc] init];
    itemSet._imageStr = @"forward.png";
    itemSet._valueStr = [localization localizedStringForKey:text_message_forward];
    [touchMessageArr addObject: itemSet];
    
    itemSet = [[SettingItem alloc] init];
    itemSet._imageStr = @"delete_conversation.png";
    itemSet._valueStr = [localization localizedStringForKey:text_message_delete];
    [touchMessageArr addObject: itemSet];
    
    itemSet = [[SettingItem alloc] init];
    itemSet._imageStr = @"recall.png";
    itemSet._valueStr = [localization localizedStringForKey:text_message_recall];
    [touchMessageArr addObject: itemSet];
}

#pragma mark - UITableview Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [touchMessageArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"OptionsCell";
    OptionsCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"OptionsCell" owner:self options:nil];
        cell = topLevelObjects[0];
    }
    [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
    [cell setFrame: CGRectMake(cell.frame.origin.x, cell.frame.origin.y, _tbChat.frame.size.width, hCell)];
    [cell setupUIForCell];
    
    SettingItem *aItem = [touchMessageArr objectAtIndex: indexPath.row];
    [cell._imgIcon setImage:[UIImage imageNamed: aItem._imageStr]];
    [cell._lbTitle setText: aItem._valueStr];
    [cell setTag: indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *curCell = [tableView cellForRowAtIndexPath: indexPath];
    NSBubbleData *messageData = [_listMessages objectAtIndex: idMsgForward];
    
    switch (typeTouchOnMessage)
    {
        case eImageReceived:{
            //  0: forward 1: delete
            if (indexPath.row == 0) {
                [self forwardMessage: messageData];
            }else{
                [self deleteMessage: messageData];
            }
            break;
        }
        case eImageReceivedWithExpireTime:{
            [self deleteMessage: messageData];
            break;
        }
        case eNormalMessageReceived:{
            if (indexPath.row == 0) {
                [self copyMessageContent: messageData];
            }else if (indexPath.row == 1){
                [self forwardMessage: messageData];
            }else{
                [self deleteMessage: messageData];
            }
            break;
        }
        case eMyMessageWithResend:{
            if (indexPath.row == eMmrResend) {
                //  rensend message
                NSBubbleData *aMessage = [_listMessages objectAtIndex: idMsgForward];
                [self resendMessage:aMessage];
            }else if (indexPath.row == eMmrCopy){
                [self copyMessageContent: messageData];
            }else if (indexPath.row == eMmrForward){
                [self forwardMessage: messageData];
            }else if (indexPath.row == eMmrDelete){
                [self deleteMessage: messageData];
            }else{
                [self recallMessage: messageData];
            }
            break;
        }
        case eMyMessageNoResend:{
            if (indexPath.row == eMmnrCopy) {
                [self copyMessageContent: messageData];
            }else if (indexPath.row == eMmnrForward){
                [self forwardMessage: messageData];
            }else if (indexPath.row == eMmnrDelete){
                [self deleteMessage: messageData];
            }else{
                [self recallMessage: messageData];
            }
            break;
        }
        case eMyImageSendNoReSend:{
            if (indexPath.row == 0) {
                [self forwardMessage: messageData];
            }else if (indexPath.row == 1){
                [self deleteMessage: messageData];
            }else{
                [self recallMessage: messageData];
            }
            break;
        }
        case eMyImageSendWithResend:{
            if (indexPath.row == 0) {
                [self resendMediaMessageWithMessageId: messageData];
            }else if (indexPath.row == 1){
                [self forwardMessage: messageData];
            }else if (indexPath.row == 2){
                [self deleteMessage: messageData];
            }else{
                [self recallMessage: messageData];
            }
            break;
        }
        default:
            break;
    }
    [popUpTouchMessage fadeOut];
    
    UIView *selected_bg = [[UIView alloc] init];
    selected_bg.backgroundColor = [UIColor colorWithRed:(223/255.0) green:(255/255.0)
                                                   blue:(133/255.0) alpha:1];
    curCell.selectedBackgroundView = selected_bg;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return hCell;
}

//  Xoá message
- (void)deleteMessage: (NSBubbleData *)messageData {
    
    BOOL isDelete = [NSDatabase deleteOneMessageWithId: messageData.idMessage];
    if (isDelete) {
        appDelegate._heightChatTbView = 0.0;
        _listMessages = [[NSMutableArray alloc] init];
        [_listMessages addObjectsFromArray:[NSDatabase getListMessagesHistory:USERNAME withPhone:_userAccount]];
        [_tbChat reloadData];
        [self updateAllFrameForController: false];
    }else{
        [self showMessagePopupWithString: [localization localizedStringForKey:TEXT_FAILED_FOR_DELETE_MESSAGE]];
    }
}

//  forward một message
- (void)forwardMessage: (NSBubbleData *)messageData {
    [appDelegate set_msgForward: messageData];
    [[PhoneMainView instance] changeCurrentView:[ListChatsViewController compositeViewDescription]];
}

//  Copy message
- (void)copyMessageContent: (NSBubbleData *)messageData {
    
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    [pasteBoard setString: [messageData.lbContent text]];
    [self showMessagePopupWithString: [localization localizedStringForKey:TEXT_COPIED]];
}

//  Gửi lại tin nhắn
- (void)resendMessage: (NSBubbleData *)messageData {
    
    if ([messageData.typeMessage isEqualToString: typeTextMessage]) {
        NSString *contentMsg = [messageData.lbContent text];
        BOOL secure = false;
        if (appDelegate.friendBuddy.encryptionStatus == kOTRKitMessageStateEncrypted) {
            secure = true;
        }
        [appDelegate.friendBuddy sendMessage:contentMsg secure:secure withIdMessage:messageData.idMessage];
    }
}

//  Recall mot message
- (void)recallMessage: (NSBubbleData *)messageData {
    appDelegate.idMessageRecall = messageData.idMessage;
    
    NSString *user = [NSString stringWithFormat:@"%@/%@", appDelegate.friendBuddy.accountName, appDelegate.friendBuddy.resourceStr];
    [appDelegate.myBuddy.protocol sendRequestRecallToUser:user
                                                 fromUser:appDelegate.myBuddy.accountName
                                                 andIdMsg:messageData.idMessage];
}

//  Resend lại một media message
- (void)resendMediaMessageWithMessageId: (NSBubbleData *)messageData{
    
    NSString *detailUrl = [NSDatabase getDetailUrlForMessageResend: messageData.idMessage];
    if (![detailUrl isEqualToString:@""]) {
        NSString *userStr = [NSString stringWithFormat:@"%@/%@", appDelegate.friendBuddy.accountName, appDelegate.friendBuddy.resourceStr];
        NSData *dataSend = [AppUtils getFileDataOfMessageResend:detailUrl andFileType:messageData.typeMessage];
        if (dataSend != nil) {
            [self sendFileToUser:userStr data:dataSend fileName:detailUrl description:messageData.descriptionStr idMessage:messageData.idMessage];
        }
        NSLog(@"Continude.....");
    }else{
        [self showMessagePopupWithString: [localization localizedStringForKey:TEXT_RESEND_FAILED]];
    }
}

//  Xử lý recall message
- (void)updateViewChatAfterRecallMessage: (NSNotification *)notif {
    
    if ([[[PhoneMainView instance] currentView] isEqual:[MainChatViewController compositeViewDescription]])
    {
        id object = [notif object];
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSString *idMsgUpdate = [object objectForKey: @"idMessage"];
            int showPopup = [[object objectForKey:@"showPopup"] intValue];
            
            NSBubbleData *recallMsgData = [NSDatabase getDataOfMessage: idMsgUpdate];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"idMessage = %@", idMsgUpdate];
            NSArray *listSearch = [_listMessages filteredArrayUsingPredicate: predicate];
            if (listSearch.count > 0) {
                int index = (int)[_listMessages indexOfObject: [listSearch firstObject]];
                [_listMessages replaceObjectAtIndex: index withObject: recallMsgData];
                [_tbChat reloadData];
                
                // Hiển thị popup recall thành công
                if (showPopup == 1) {
                    [self showMessagePopupWithString: [localization localizedStringForKey:TEXT_MESSSAGE_SENT_RECALLED]];
                }
            }
        }
    }
}

//  Cập nhật lại table chat khi xoá 1 expire message thành công
- (void)updateAfterDeleteExpireMsgMeSend: (NSNotification *)notif {
    
    id object = [notif object];
    if ([object isKindOfClass:[NSString class]]) {
        NSString *idMsgDelete = object;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"idMessage = %@", idMsgDelete];
        NSArray *messageList = [_listMessages filteredArrayUsingPredicate: predicate];
        if (messageList.count > 0) {
            NSBubbleData *deleteMessage = [messageList objectAtIndex: 0];
            [_listMessages removeObject: deleteMessage];
            [self updateAndGotoLastViewChat];
        }
    }
}

//  Cập nhật lại trạng thái của message nếu bị lỗi
- (void)updateDeliveredError: (NSNotification *)notif {
    
    id object = [notif object];
    if ([object isKindOfClass:[NSString class]]) {
        NSString *idMessage = (NSString *)object;
        [NSDatabase updateMessageDeliveredError: idMessage];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"idMessage = %@", idMessage];
        NSArray *updateData = [_listMessages filteredArrayUsingPredicate: predicate];
        if (updateData.count > 0) {
            NSBubbleData *data = [updateData objectAtIndex: 0];
            int index = (int)[_listMessages indexOfObject: data];
            data.status = 0;
            [_listMessages replaceObjectAtIndex:index withObject:data];
            [_tbChat reloadData];
        }
    }
}

//  Khi click chọn vào message link
- (void)processLinkOnMessage: (NSNotification *)notif {
    
    id object = [notif object];
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)object;
        int typeAction = [[dict objectForKey:@"typeAction"] intValue];
        //  0: copy
        if (typeAction == 0) {
            UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
            [pasteBoard setString: [dict objectForKey:@"value"]];
            [self showMessagePopupWithString: [localization localizedStringForKey:TEXT_COPIED]];
        }else{
            int typeData = [[dict objectForKey:@"typeData"] intValue];
            // click call
            if (typeData == phoneNumber) {
                callOnMessage = YES;
                phoneNumberOnMessage = [[NSString alloc] initWithString:[dict objectForKey:@"value"]];
                [self startCallWithPhoneNumber];
            }else if (typeData == linkWebsite) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[dict objectForKey:@"value"]]];
            }else {
                // send email
                NSString *totalEmail = [NSString stringWithFormat:@"mailto:%@", [dict objectForKey:@"value"]];
                NSString *url = [totalEmail stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
                [[UIApplication sharedApplication]  openURL: [NSURL URLWithString: url]];
            }
        }
    }
}

//  Call trong view chat
- (void)startCallWithPhoneNumber {
    
    if (!callOnMessage) {
        stringForCall = [[NSString alloc] initWithString: _userAccount];
    }else{
        stringForCall = [[NSString alloc] initWithString: phoneNumberOnMessage];
    }
    LinphoneAddress *addr = linphone_core_interpret_url(LC, stringForCall.UTF8String);
    [LinphoneManager.instance call:addr];
    if (addr)
        linphone_address_destroy(addr);
    
    OutgoingCallViewController *controller = VIEW(OutgoingCallViewController);
    if (controller != nil) {
        [controller setPhoneNumberForView: stringForCall];
    }
    [[PhoneMainView instance] changeCurrentView:[OutgoingCallViewController compositeViewDescription] push:TRUE];
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

- (void)updateImageSendMessageWithInfo: (UploadPicture *)uploadSession
{
    if (appDelegate.xmppStream.isConnected) {
        [NSDatabase updateMessageDelivered:uploadSession.idMessage withValue:1];
    }
    
    NSBubbleData *dataMessage = [NSDatabase getDataOfMessage: idMsgImage];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"idMessage = %@", idMsgImage];
    NSArray *updateData = [_listMessages filteredArrayUsingPredicate: predicate];
    if (updateData.count > 0) {
        int replaceIndex = (int)[_listMessages indexOfObject: [updateData objectAtIndex: 0]];
        [_listMessages replaceObjectAtIndex:replaceIndex withObject:dataMessage];
        [_tbChat reloadData];
    }
    if (dataMessage.expireTime > 0) {
        [self startAllExpireMessageOfMe];
    }
    
    [AppUtils sendMessageForOfflineForUser:_userAccount fromSender:USERNAME withContent:uploadSession.namePicture andTypeMessage:@"image" withGroupID:@""];
    //  Leo Kelvin
    //  [appDelegate.myBuddy.protocol sendMessageImageForUser:_userAccount withLinkImage:uploadSession.namePicture andDescription:appDelegate.titleCaption andIdMessage:idMsgImage];
    
    appDelegate.imageChoose = nil;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UITextView *txtview = object;
    CGFloat topoffset = ([txtview bounds].size.height - [txtview contentSize].height * [txtview zoomScale])/2.0;
    topoffset = ( topoffset < 0.0 ? 0.0 : topoffset );
    txtview.contentOffset = (CGPoint){.x = 0, .y = -topoffset};
}

@end
