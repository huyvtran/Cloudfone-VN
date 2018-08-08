//
//  PlayVideoViewController.m
//  linphone
//
//  Created by user on 22/12/14.
//
//

#import "PlayVideoViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "NSDatabase.h"
#import "PhoneMainView.h"
#import "OTRConstants.h"

@interface PlayVideoViewController (){
    MPMoviePlayerController *moviePlayer;
    AlertPopupView *popupSaveImage;
    NSURL *videoUrl;
    
    //  View show thông tin save video thành công hay thất bại
    UIView *saveSuccessView;
}

@end

@implementation PlayVideoViewController
@synthesize _iconBack, _lbTitle, _saveVideoIcon;

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
    [_iconBack setBackgroundImage:[UIImage imageNamed:@"history_back_over.png"]
                         forState:UIControlStateHighlighted];
    [_saveVideoIcon setBackgroundImage:[UIImage imageNamed:@"savepic_press.png"]
                              forState:UIControlStateHighlighted];
    [_lbTitle setFont: [AppUtils fontRegularWithSize: 19.0]];
    
    popupSaveImage.delegate = self;
    
    /* Nhận thông báo save video vào gallery */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveThisVideoToGallery)
                                                 name:k11SaveVideoToGallery object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    // Tắt màn hình cảm biến
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled: NO];
    
    NSString *videoName = [NSDatabase getPictureNameOfMessage: [LinphoneAppDelegate sharedInstance].idVideoMessage];
    videoUrl = [self getUrlOfVideoFile: videoName];
    if (videoUrl != nil) {
        moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:videoUrl];
        [self.view addSubview:moviePlayer.view];
        moviePlayer.view.frame = CGRectMake([UIScreen mainScreen].bounds.origin.x, 42, SCREEN_WIDTH, SCREEN_HEIGHT-20-42);
        [moviePlayer setFullscreen: YES];
        [moviePlayer play];
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
    [self set_lbTitle:nil];
    [self set_saveVideoIcon:nil];
    [super viewDidUnload];
}

- (IBAction)_iconBackClicked:(id)sender {
    [[PhoneMainView instance] popCurrentView];
}

//  Hàm trả về đường dẫn đến file video
- (NSURL *)getUrlOfVideoFile: (NSString *)fileName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pathFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/videos/%@", fileName]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath: pathFile];
    
    if (!fileExists) {
        return nil;
    }else{
        return [[NSURL alloc] initFileURLWithPath: pathFile];
    }
}

//  Click vào icon save video
- (IBAction)_saveVideoIconClicked:(id)sender {
    
    UIView *currentView = [[UIApplication sharedApplication] keyWindow].rootViewController.view;
    popupSaveImage = [[AlertPopupView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-260)/2, (self.view.frame.size.height-150)/2, 260, 150)];
    [popupSaveImage showInView:currentView animated:YES];
}

//  Save video vao gallery
- (void)saveThisVideoToGallery {
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:videoUrl
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                        [self saveFinish:error];
                                }];
}

//  Sau khi save video kết thúc
- (void)saveFinish: (NSError *)error{
    if (error) {
        [self showMessagePopupWithContent: NSLocalizedString(TEXT_SAVE_VIDEO_SUCCESS, nil) withTimeShow:1.0 andHide:3.0];
    }else{
        [self showMessagePopupWithContent: NSLocalizedString(TEXT_SAVE_VIDEO_FAILED, nil) withTimeShow:1.0 andHide:3.0];
    }
}

//  Hiển thị popup khi send request
- (void)showMessagePopupWithContent: (NSString *)contentStr withTimeShow: (float)timeShow andHide: (float)timeHide
{
    
    CGSize mainSize = [[UIScreen mainScreen] bounds].size;
    saveSuccessView = [[UIView alloc] initWithFrame:CGRectMake((mainSize.width-280)/2, (mainSize.height-120), 280, 40)];
    [self.view.superview addSubview: saveSuccessView];
    UILabel *lbText = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, saveSuccessView.frame.size.width-20, saveSuccessView.frame.size.height)];
    lbText.text = contentStr;
    lbText.textColor = [UIColor whiteColor];
    lbText.font = [AppUtils fontRegularWithSize: 13.0];
    lbText.textAlignment = NSTextAlignmentCenter;
    saveSuccessView.backgroundColor = [UIColor blackColor];
    [saveSuccessView addSubview: lbText];

    saveSuccessView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    saveSuccessView.alpha = 0;
    [UIView animateWithDuration:timeShow animations:^{
        saveSuccessView.alpha = 1;
        // showMessageView.transform = CGAffineTransformMakeScale(1.3, 1.3);
    }completion:^(BOOL finish){
        [UIView animateWithDuration:timeHide animations:^{
            saveSuccessView.transform = CGAffineTransformMakeScale(1, 1);
            saveSuccessView.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (finished) {
            }
        }];
    }];
}


@end
