//
//  IntroduceViewController.m
//  linphone
//
//  Created by Apple on 4/28/17.
//
//

#import "IntroduceViewController.h"

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
    [self autoLayoutForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    _lbIntroduce.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Introduce"];
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
- (void)autoLayoutForView
{
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:20.0];
        _lbIntroduce.font = [UIFont fontWithName:MYRIADPRO_BOLD size:20.0];
    }else{
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
        _lbIntroduce.font = [UIFont fontWithName:MYRIADPRO_BOLD size:18.0];
    }
    
    //  header view
    [_viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo([LinphoneAppDelegate sharedInstance]._hHeader);
    }];
    
    [_iconBack setBackgroundImage:[UIImage imageNamed:@"ic_back_act.png"]
                         forState:UIControlStateHighlighted];
    [_iconBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewHeader);
        make.centerY.equalTo(_viewHeader.mas_centerY);
        make.width.height.mas_equalTo([LinphoneAppDelegate sharedInstance]._hHeader);
    }];
    
    _lbIntroduce.font = textFont;
    [_lbIntroduce mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_viewHeader.mas_centerX);
        make.centerY.equalTo(_viewHeader.mas_centerY);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(40);
    }];
    
    float tmpMargin = 15.0;
    [_wvIntroduce mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader.mas_bottom).offset(tmpMargin);
        make.left.equalTo(self.view).offset(tmpMargin);
        make.bottom.right.equalTo(self.view).offset(-tmpMargin);
    }];
    _wvIntroduce.layer.borderColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                      blue:(200/255.0) alpha:1.0].CGColor;
    _wvIntroduce.layer.borderWidth = 1.0;
    _wvIntroduce.layer.cornerRadius = 5.0;
    _wvIntroduce.backgroundColor = [UIColor whiteColor];
    _wvIntroduce.clipsToBounds = YES;
}

@end
