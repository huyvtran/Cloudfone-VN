//
//  ChatPictureViewController.m
//  linphone
//
//  Created by user on 23/12/14.
//
//

#import "ChatPictureViewController.h"
#import "NSDatabase.h"
#import "PhoneMainView.h"
#import "OTRConstants.h"
#import "UIImageView+WebCache.h"
#import "SavePicturePopupView.h"

@interface ChatPictureViewController ()
{
    HMLocalization *localization;
    SavePicturePopupView *popupSaveImage;
    UIImage *currentImage;
    NSString *descriptionImage;
    NSArray *infosArr;
    UIButton *touchButton;
    UILabel *lbClickToView;
    
    UIButton *nextButton;
    UIButton *prevButton;
    BOOL isClicked;
    int curIndex;
    
    // View hiển thị thông báo lên màn hình
    UIView *showMessageView;
}

@end

@implementation ChatPictureViewController
@synthesize _iconBack, _lbName, _lbImageIndex, _iconCopy, _picture, _lbDescImage, _viewHeader;
@synthesize _listPicture, _curIdPicture;

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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // MY CODE HERE
    localization = [HMLocalization sharedInstance];
    
    [self setupUIForView];
    
    [_viewHeader setFrame: CGRectMake(0, 0, SCREEN_WIDTH, [LinphoneAppDelegate sharedInstance]._hHeader)];
    [_iconBack setBackgroundImage:[UIImage imageNamed:@"history_back_over.png"]
                         forState:UIControlStateHighlighted];
    [_iconBack setFrame: CGRectMake(0, 0, [LinphoneAppDelegate sharedInstance]._hHeader, [LinphoneAppDelegate sharedInstance]._hHeader)];
    
    [_iconCopy setFrame: CGRectMake(_viewHeader.frame.size.width-[LinphoneAppDelegate sharedInstance]._hHeader, 0, [LinphoneAppDelegate sharedInstance]._hHeader, [LinphoneAppDelegate sharedInstance]._hHeader)];
    [_iconCopy setBackgroundImage:[UIImage imageNamed:@"ic_save_act.png"]
                         forState:UIControlStateHighlighted];
    
    [_lbName setFrame: CGRectMake(_iconBack.frame.origin.x+_iconBack.frame.size.width+5, 0, _viewHeader.frame.size.width-2*(_iconBack.frame.origin.x+_iconBack.frame.size.width), [LinphoneAppDelegate sharedInstance]._hHeader/2)];
    [_lbName setFont:[AppUtils fontRegularWithSize: 19.0]];
    
    [_lbImageIndex setFrame: CGRectMake(_lbName.frame.origin.x, _lbName.frame.origin.y+_lbName.frame.size.height, _lbName.frame.size.width, _lbName.frame.size.height)];
    [_lbImageIndex setFont: [AppUtils fontRegularWithSize: 12.0]];
    
    [_lbDescImage setFont: [AppUtils fontRegularWithSize: 14.0]];
    [_lbDescImage setTextColor:[UIColor whiteColor]];
    [_lbDescImage setAlpha: 0.5];
    
    // Add button touch và giữ vào ảnh
    touchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _picture.frame.size.width, _picture.frame.size.height)];
    [touchButton setBackgroundColor:[UIColor clearColor]];
    [_picture addSubview: touchButton];
    
    // Add label click to view vào ảnh
    lbClickToView = [[UILabel alloc] initWithFrame: touchButton.frame];
    [lbClickToView setBackgroundColor:[UIColor clearColor]];
    [lbClickToView setText: [localization localizedStringForKey:TEXT_HOLD_TO_VIEW]];
    [lbClickToView setFont: [AppUtils fontRegularWithSize: 16.0]];
    [lbClickToView setTextColor:[UIColor grayColor]];
    [lbClickToView setTextAlignment:NSTextAlignmentCenter];
    [lbClickToView setHidden: YES];
    [_picture addSubview: lbClickToView];
    
    [_picture setUserInteractionEnabled: YES];
    
    // Tạo 2 button next và previous để xem hình
    [self createNextAndPreviousButtonToViewPicture];
}

- (void)viewWillAppear:(BOOL)animated {
    // Tắt màn hình cảm biến
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled: NO];
    
    // Biến cho biết đã click vào image
    isClicked = NO;
    [_viewHeader setHidden: YES];
    [prevButton setHidden: YES];
    [nextButton setHidden: YES];
}

- (void)setupUIForView {
    
}

- (void)updateImageAfterReceiveIdPicture {
    // Get danh sach idMessage
    NSString *userStr = [AppUtils getSipFoneIDFromString: [LinphoneAppDelegate sharedInstance].friendBuddy.accountName];
    _listPicture = [NSDatabase getAllImageIdOfMeWithUser: userStr];
    if ([_listPicture containsObject: _curIdPicture]) {
        curIndex = (int)[_listPicture indexOfObject: _curIdPicture];
    }else{
        curIndex = 0;
    }
    // Hiển thị ảnh đã chọn
    [self showImage];
}

//  Hiển thị ảnh đã chọn
- (void)showImage {
    // Lấy thông tin của ảnh hiện tại
    infosArr = [NSDatabase getPictureURLOfMessageImage: _curIdPicture];
    if (infosArr.count >= 4) {
        int imgExpireTime = [[infosArr objectAtIndex: 1] intValue];
        NSString *sendPhone = [infosArr objectAtIndex: 2];

        // Get tên của người send ảnh
        NSString *name = [NSDatabase getNameOfContactWithPhoneNumber: sendPhone];
        [_lbName setText: name];
        [_lbImageIndex setText:[NSString stringWithFormat:@"%d/%d", curIndex+1, (int)_listPicture.count]];
        
        NSString *detailURL = [infosArr objectAtIndex: 0];
        if ([detailURL containsString:@".jpg"] || [detailURL containsString:@".JPG"] || [detailURL containsString:@".png"] || [detailURL containsString:@".PNG"] || [detailURL containsString:@".jpeg"] || [detailURL containsString:@".JPEG"])
        {
            // Nếu ảnh có expire nhận được thì touch vào ảnh mới xem được
            if (imgExpireTime > 0) {
                if (![USERNAME isEqualToString: sendPhone]) {
                    [_picture setImage:[UIImage imageNamed:@"unloaded.png"]];
                    
                    // Add sự kiện touch và giữ vào ảnh expire
                    UILongPressGestureRecognizer *longPressTap =
                    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                  action:@selector(handleLongPress:)];
                    longPressTap.minimumPressDuration = .5;
                    [touchButton addGestureRecognizer: longPressTap];
                    [lbClickToView setHidden: NO];
                }else{
                    [lbClickToView setHidden: NO];
                    [_picture setImage: currentImage];
                    [lbClickToView setHidden: YES];
                }
            }else{
                NSString *urlStr = [NSString stringWithFormat:@"%@/%@", link_picutre_chat_group, detailURL];
                [_picture sd_setImageWithURL:[NSURL URLWithString: urlStr]
                            placeholderImage:[UIImage imageNamed:@"unloaded.png"]];
                NSData *imageData = [NSData dataWithContentsOfURL: [NSURL URLWithString:urlStr]];
                if (imageData != nil) {
                    currentImage = [UIImage imageWithData: imageData];
                }
                [lbClickToView setHidden: YES];
                [touchButton removeTarget:self action:@selector(handleLongPress:) forControlEvents:UIControlEventTouchUpInside];
            }
        }else{
            currentImage = [AppUtils getImageOfDirectoryWithName: [infosArr firstObject]];
            // Nếu ảnh có expire nhận được thì touch vào ảnh mới xem được
            if (imgExpireTime > 0) {
                if (![USERNAME isEqualToString: sendPhone]) {
                    [_picture setImage:[UIImage imageNamed:@"unloaded.png"]];
                    
                    // Add sự kiện touch và giữ vào ảnh expire
                    UILongPressGestureRecognizer *longPressTap =
                    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                  action:@selector(handleLongPress:)];
                    longPressTap.minimumPressDuration = .5;
                    [touchButton addGestureRecognizer: longPressTap];
                    [lbClickToView setHidden: NO];
                }else{
                    [lbClickToView setHidden: NO];
                    [_picture setImage: currentImage];
                    [lbClickToView setHidden: YES];
                }
            }else{
                
                [_picture setImage: currentImage];
                [lbClickToView setHidden: YES];
                [touchButton removeTarget:self action:@selector(handleLongPress:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        
        [touchButton addTarget:self
                        action:@selector(clickToChangePicture)
              forControlEvents:UIControlEventTouchUpInside];
        
        // Nếu image có description thì hiển thị, không thì ẩn label đi
        if (![[infosArr lastObject] isEqualToString:@""]) {
            [_lbDescImage setText: [infosArr lastObject]];
            [_lbDescImage setFrame:CGRectMake(0, SCREEN_HEIGHT-20-_lbDescImage.frame.size.height, SCREEN_WIDTH, _lbDescImage.frame.size.height)];
            [_lbDescImage setHidden: NO];
        }else{
            [_lbDescImage setHidden: YES];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
}

- (void)viewDidUnload {
    [self set_iconBack:nil];
    [self set_iconCopy:nil];
    [self set_picture:nil];
    [self set_lbDescImage:nil];
    [self set_viewHeader:nil];
    [self set_lbName:nil];
    [self set_lbImageIndex:nil];
    [super viewDidUnload];
}

- (IBAction)_iconBackClicked:(id)sender {
    [[PhoneMainView instance] popCurrentView];
}

//  Copy những image không có expire time vào gallery
- (IBAction)_iconCopyClicked:(id)sender {
    if ([[infosArr objectAtIndex:1] intValue] > 0) {
        [self showMessagePopupWithContent: [localization localizedStringForKey:TEXT_DENY_COPY_EXPIRE_IMAGE]];
    }else{
        NSString *valueStr = [localization localizedStringForKey:CN_ALERT_POPUP_SAVE_PICTURE_CONTENT];
        UIFont *font = [AppUtils fontRegularWithSize: 16.0];
        CGSize size = [(valueStr ? valueStr : @"") sizeWithFont:font
                                              constrainedToSize:CGSizeMake(220, 9999)
                                                  lineBreakMode:NSLineBreakByWordWrapping];
        float tmpHeight = 5 + 40 + 5 + size.height + 10 + 35 + 10;
        CGRect popupFrame = CGRectMake((self.view.frame.size.width-260)/2, (self.view.frame.size.height-tmpHeight)/2, 260, tmpHeight);
        
        popupSaveImage = [[SavePicturePopupView alloc] initWithFrame:popupFrame];
        [popupSaveImage._btnYes addTarget:self
                                   action:@selector(saveThisImageToGallery)
                         forControlEvents:UIControlEventTouchUpInside];
        [popupSaveImage showInView:[LinphoneAppDelegate sharedInstance].window animated:YES];
    }
}

//  Hàm copy image vào gallery
- (void)saveThisImageToGallery{
    [popupSaveImage fadeOut];
    if (currentImage == nil) {
        [self showMessagePopupWithContent:[localization localizedStringForKey:text_can_not_save_picture]];
    }else{
        UIImageWriteToSavedPhotosAlbum(currentImage, nil, nil, nil);
        [self showMessagePopupWithContent:[localization localizedStringForKey:text_successfully]];
    }
}

//  Touch và thả vào picture có expire time
-  (void)handleLongPress:(UILongPressGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        [_picture setImage:[UIImage imageNamed:@"unloaded.png"]];
        [lbClickToView setHidden: NO];
    }else if (sender.state == UIGestureRecognizerStateBegan){
        // Check delivered cua message, neu nhan xong thi moi expire
        int delivered = [NSDatabase getDeliveredOfMessage: _curIdPicture];
        if (delivered == 2) {
            // Cập nhật last_time_expire của image message
            [NSDatabase updateLastTimeExpireOfImageMessage: _curIdPicture];
            [[NSNotificationCenter defaultCenter] postNotificationName:k11ReStartDeleteExpireTimerOfMe object:nil];
        }
        currentImage = [AppUtils getImageOfDirectoryWithName: [infosArr firstObject]];
        [_picture setImage:currentImage];
        [lbClickToView setHidden: YES];
    }
}

//  Tạo 2 button next và previous để xem hình
- (void)createNextAndPreviousButtonToViewPicture{
    prevButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.origin.x+10, (SCREEN_HEIGHT-50)/2, 50, 50)];
    [prevButton setBackgroundImage:[UIImage imageNamed:@"previous-pic.png"]
                          forState:UIControlStateNormal];
    [prevButton addTarget:self
                   action:@selector(clickToViewPreviouPicture)
         forControlEvents:UIControlEventTouchUpInside];
    [prevButton setHidden: YES];
    [self.view addSubview: prevButton];
    
    nextButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-10-50, (SCREEN_HEIGHT-50)/2, 50, 50)];
    [nextButton setBackgroundImage:[UIImage imageNamed:@"next-pic.png"]
                          forState:UIControlStateNormal];
    [nextButton addTarget:self
                   action:@selector(clickToViewNextPicture)
         forControlEvents:UIControlEventTouchUpInside];
    [nextButton setHidden: YES];
    [self.view addSubview: nextButton];
}

//  Click vào image để xem 2 button
- (void)clickToChangePicture {
    if (!isClicked) {
        [_viewHeader setHidden: NO];
        
        CGRect oldRect = CGRectMake([UIScreen mainScreen].bounds.origin.x, -100, SCREEN_WIDTH, [LinphoneAppDelegate sharedInstance]._hHeader);
        CGRect newRect = CGRectMake([UIScreen mainScreen].bounds.origin.x, 0, SCREEN_WIDTH, [LinphoneAppDelegate sharedInstance]._hHeader);
        _viewHeader.frame = oldRect;
        [UIView animateWithDuration:0.25f animations:^{
            _viewHeader.frame = newRect;
        }];
        
        // Nếu có 2 ảnh trở lên thì mới hiển thị button chuyển ảnh
        if (_listPicture.count > 1) {
            [prevButton setHidden: NO];
            [nextButton setHidden: NO];
        }
        isClicked = YES;
    }else{
        CGRect oldRect = CGRectMake([UIScreen mainScreen].bounds.origin.x, -100, SCREEN_WIDTH, [LinphoneAppDelegate sharedInstance]._hHeader);
        CGRect newRect = CGRectMake([UIScreen mainScreen].bounds.origin.x, 0, SCREEN_WIDTH, [LinphoneAppDelegate sharedInstance]._hHeader);
        _viewHeader.frame = newRect;
        [UIView animateWithDuration:0.25f animations:^{
            _viewHeader.frame = oldRect;
        }];
        [_viewHeader setHidden: YES];
        [prevButton setHidden: YES];
        [nextButton setHidden: YES];
        isClicked = NO;
    }
}

//  Click để xem ảnh trước đó
- (void)clickToViewPreviouPicture {
    if (curIndex > 0) {
        curIndex = curIndex-1;
    }else{
        curIndex = (int)_listPicture.count - 1;
    }
    _curIdPicture = [_listPicture objectAtIndex: curIndex];
    [self showImage];
}

//  Click để xem ảnh tiếp theo
- (void)clickToViewNextPicture {
    if (_listPicture.count >= 2) {
        if (curIndex <= _listPicture.count - 2) {
            curIndex = curIndex + 1;
        }else{
            curIndex = 0;
        }
        _curIdPicture = [_listPicture objectAtIndex: curIndex];
        [self showImage];
    }
}

//  Hiển thị thông báo
- (void)showMessagePopupWithContent: (NSString *)messageContent {
    showMessageView = [[UIView alloc] initWithFrame: CGRectMake((SCREEN_WIDTH-280)/2, (SCREEN_HEIGHT-120), 280, 40)];
    [showMessageView setBackgroundColor: [UIColor blackColor]];
    [self.view addSubview: showMessageView];
    
    UILabel *lbText = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, showMessageView.frame.size.width-20, showMessageView.frame.size.height)];
    [lbText setText: messageContent];
    [lbText setTextColor: [UIColor whiteColor]];
    [lbText setFont: [AppUtils fontRegularWithSize: 13.0]];
    [lbText setTextAlignment: NSTextAlignmentCenter];
    [showMessageView addSubview: lbText];
    
    [showMessageView setTransform: CGAffineTransformMakeScale(1.0, 1.0)];
    [showMessageView setAlpha: 0.0f];
    [UIView animateWithDuration:1.0f animations:^{
        [showMessageView setAlpha: 1.0f];
    }completion:^(BOOL finish){
        [self hideMessagePopup];
    }];
}

//  Ẩn message popup
- (void)hideMessagePopup {
    [UIView animateWithDuration:4.5f animations:^{
        [showMessageView setTransform: CGAffineTransformMakeScale(1.0, 1.0)];
        [showMessageView setAlpha: 0.0f];
    } completion:^(BOOL finished) {
    }];
}

@end
