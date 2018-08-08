//
//  ShowPictureViewController.m
//  linphone
//
//  Created by user on 7/11/14.
//
//

#import "ShowPictureViewController.h"
#import "PhoneMainView.h"
#import "MainChatViewController.h"
#import "GroupMainChatViewController.h"
#import "PopupEnterCaption.h"
#import "StatusBarView.h"

@interface ShowPictureViewController (){
    PopupEnterCaption *popupEnterCaption;
    UIFont *textFont;
    UIFont *textFontDesc;
    float hCaption;
}

@end

@implementation ShowPictureViewController
@synthesize _viewHeader, _titleLabel, _iconBack, _iconDone, _lbDesc, _pictureView;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    //  my code here
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Tắt màn hình cảm biến
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled: NO];
    
    [LinphoneAppDelegate sharedInstance].titleCaption = @"";
    _lbDesc.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_show_picture_desc];
    _titleLabel.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_show_picture];
    
    _pictureView.image = [self rotateImageAppropriately: [LinphoneAppDelegate sharedInstance].imageChoose];
    _pictureView.clipsToBounds = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self set_titleLabel:nil];
    [self set_iconBack:nil];
    [self set_iconDone:nil];
    [self set_pictureView:nil];
    [self set_lbDesc:nil];
    [super viewDidUnload];
}

- (IBAction)_iconBackClicked:(id)sender {
    [LinphoneAppDelegate sharedInstance].titleCaption = @"";
    [LinphoneAppDelegate sharedInstance].imageChoose = nil;
    [[PhoneMainView instance] popCurrentView];
}

- (IBAction)_iconDoneClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sendImageForUser"
                                                        object:[LinphoneAppDelegate sharedInstance].imageChoose];
    if ([LinphoneAppDelegate sharedInstance].idRoomChat == 0) {
        [LinphoneAppDelegate sharedInstance].imageCapture = NO;
        [[PhoneMainView instance] popCurrentView];
    }else{
        [[PhoneMainView instance] popCurrentView];
    }
}

#pragma mark - my functions

- (void)setupUIForView
{
    if (SCREEN_WIDTH > 320) {
        _titleLabel.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:20.0];
        textFontDesc = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
        hCaption = 50.0;
    }else{
        _titleLabel.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
        textFontDesc = [UIFont fontWithName:MYRIADPRO_REGULAR size:14.0];
        hCaption = 40.0;
    }
    self.view.backgroundColor = [UIColor colorWithRed:(90/255.0) green:(90/255.0)
                                                 blue:(90/255.0) alpha:1.0];
    //  header
    _viewHeader.frame = CGRectMake(0, 0, SCREEN_WIDTH, [LinphoneAppDelegate sharedInstance]._hHeader);
    _iconBack.frame = CGRectMake(0, 0, [LinphoneAppDelegate sharedInstance]._hHeader, [LinphoneAppDelegate sharedInstance]._hHeader);
    [_iconBack setBackgroundImage:[UIImage imageNamed:@"ic_back_act.png"]
                         forState:UIControlStateHighlighted];
    
    _iconDone.frame = CGRectMake(_viewHeader.frame.size.width-[LinphoneAppDelegate sharedInstance]._hHeader, 0, [LinphoneAppDelegate sharedInstance]._hHeader, [LinphoneAppDelegate sharedInstance]._hHeader);
    [_iconDone setBackgroundImage:[UIImage imageNamed:@"ic_done_act.png"]
                         forState:UIControlStateHighlighted];
    
    _titleLabel.frame = CGRectMake(_iconBack.frame.origin.x+_iconBack.frame.size.width+5, 0, (_viewHeader.frame.size.width-2*_iconBack.frame.size.width-10), [LinphoneAppDelegate sharedInstance]._hHeader);
    
    //  tap vao label description
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPopupCaption)];
    [_lbDesc addGestureRecognizer:tapGesture];
    _lbDesc.userInteractionEnabled = YES;
    _lbDesc.font = textFont;
    _lbDesc.frame = CGRectMake(0, SCREEN_HEIGHT-([LinphoneAppDelegate sharedInstance]._hStatus+hCaption), SCREEN_WIDTH, hCaption);
    
    _pictureView.frame = CGRectMake(0, _viewHeader.frame.origin.y+_viewHeader.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT-([LinphoneAppDelegate sharedInstance]._hStatus+_lbDesc.frame.size.height+[LinphoneAppDelegate sharedInstance]._hHeader));
}

//  SHOW POPUP NHẬP CHÚ THÍCH CHO HÌNH ẢNH
- (void)showPopupCaption {
    popupEnterCaption = [[PopupEnterCaption alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-250)/2, (SCREEN_HEIGHT - 122)/2, 250, 122)];
    if (![[LinphoneAppDelegate sharedInstance].titleCaption isEqualToString: @""]) {
        [popupEnterCaption._tfDesc setText: [LinphoneAppDelegate sharedInstance].titleCaption];
    }
    [popupEnterCaption._btnYes addTarget:self
                                  action:@selector(saveDescriptionForImage:)
                        forControlEvents:UIControlEventTouchUpInside];
    [popupEnterCaption showInView:[LinphoneAppDelegate sharedInstance].window animated:YES];
    [popupEnterCaption._tfDesc becomeFirstResponder];
}

- (void)saveDescriptionForImage: (UIButton *)sender{
    [LinphoneAppDelegate sharedInstance].titleCaption = popupEnterCaption._tfDesc.text;
    [popupEnterCaption._tfDesc resignFirstResponder];
    [popupEnterCaption fadeOut];
    [[LinphoneAppDelegate sharedInstance] setTitleCaption: popupEnterCaption._tfDesc.text];
    if (![[LinphoneAppDelegate sharedInstance].titleCaption isEqualToString: @""]) {
        _lbDesc.text = [LinphoneAppDelegate sharedInstance].titleCaption;
    }else{
        _lbDesc.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_show_picture_desc];
    }
}

- (UIImage*)rotateImageAppropriately:(UIImage*) imageToRotate {
    CGImageRef imageRef = [imageToRotate CGImage];
    UIImage* properlyRotatedImage;
    
    if (imageToRotate.imageOrientation == 0) {
        properlyRotatedImage = imageToRotate;
    }else if (imageToRotate.imageOrientation == 3){
        properlyRotatedImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:3];
    }else if (imageToRotate.imageOrientation == 1){
        properlyRotatedImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:1];
    }else{
        properlyRotatedImage = imageToRotate;
    }
    return properlyRotatedImage;
}

@end
