//
//  IntroduceViewController.m
//  linphone
//
//  Created by Apple on 4/28/17.
//
//

#import "IntroduceViewController.h"
#import "PhoneMainView.h"

@interface IntroduceViewController (){
    UIFont *textFont;
}

@end

@implementation IntroduceViewController
@synthesize _viewHeader, _iconBack, _wvIntroduce, _lbIntroduce;

#pragma mark - UICompositeViewDelegate Functions
static UICompositeViewDescription *compositeDescription = nil;
+ (UICompositeViewDescription *)compositeViewDescription {
    if (compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:nil
                                                                 tabBar:nil
                                                               sideMenu:nil
                                                             fullscreen:NO
                                                         isLeftFragment:YES
                                                           fragmentWith:nil];
        compositeDescription.darkBackground = true;
    }
    return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
    return self.class.compositeViewDescription;
}

#pragma mark - My Controller Delegate
- (void)viewDidLoad {
    [super viewDidLoad];
    //  my code here
    [self setupUIForView];
    
    float tmpMargin = 15.0;
    _wvIntroduce.frame = CGRectMake(tmpMargin, _viewHeader.frame.origin.y+_viewHeader.frame.size.height+tmpMargin, SCREEN_WIDTH-2*tmpMargin, SCREEN_HEIGHT-([LinphoneAppDelegate sharedInstance]._hStatus+[LinphoneAppDelegate sharedInstance]._hHeader+2*tmpMargin));
    _wvIntroduce.layer.borderColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                      blue:(200/255.0) alpha:1.0].CGColor;
    _wvIntroduce.layer.borderWidth = 1.0;
    _wvIntroduce.layer.cornerRadius = 5.0;
    _wvIntroduce.backgroundColor = [UIColor whiteColor];
    _wvIntroduce.clipsToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    _lbIntroduce.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_introduce];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    NSString *url = @"https://cloudfone.vn/gioi-thieu-dich-vu-cloudfone/";
    NSURL *nsurl=[NSURL URLWithString:url];
    NSURLRequest *nsrequest = [NSURLRequest requestWithURL: nsurl];
    [_wvIntroduce loadRequest:nsrequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)_iconBackClicked:(UIButton *)sender {
    [[PhoneMainView instance] popCurrentView];
}

#pragma mark - my functions

//  setup ui trong view
- (void)setupUIForView
{
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:20.0];
        _lbIntroduce.font = [UIFont fontWithName:MYRIADPRO_BOLD size:20.0];
    }else{
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
        _lbIntroduce.font = [UIFont fontWithName:MYRIADPRO_BOLD size:18.0];
    }
    //  header view
    _viewHeader.frame = CGRectMake(0, 0, SCREEN_WIDTH, [LinphoneAppDelegate sharedInstance]._hHeader);
    _iconBack.frame = CGRectMake(0, 0, [LinphoneAppDelegate sharedInstance]._hHeader, [LinphoneAppDelegate sharedInstance]._hHeader);
    [_iconBack setBackgroundImage:[UIImage imageNamed:@"ic_back_act.png"]
                         forState:UIControlStateHighlighted];
    
    _lbIntroduce.frame = CGRectMake(_iconBack.frame.origin.x+_iconBack.frame.size.width+5, 0, _viewHeader.frame.size.width-2*(_iconBack.frame.origin.x+_iconBack.frame.size.width+5), [LinphoneAppDelegate sharedInstance]._hHeader);
    _lbIntroduce.font = textFont;
}

@end
