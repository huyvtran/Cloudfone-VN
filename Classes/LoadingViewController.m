//
//  LoadingViewController.m
//  linphone
//
//  Created by admin on 2/4/18.
//

#import "LoadingViewController.h"
#import "YBHud.h"
#import "PhoneMainView.h"

@interface LoadingViewController (){
}
@end

@implementation LoadingViewController
@synthesize _lbCompany, _imgLogo, _lbStarting, _imgBottom;

#pragma mark - UICompositeViewDelegate Functions
static UICompositeViewDescription *compositeDescription = nil;
+ (UICompositeViewDescription *)compositeViewDescription {
    if (compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:nil
                                                                 tabBar:nil
                                                               sideMenu:nil
                                                             fullscreen:YES
                                                         isLeftFragment:YES
                                                           fragmentWith:nil];
        compositeDescription.darkBackground = true;
    }
    return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
    return self.class.compositeViewDescription;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //  My code here
    [self setupUIForView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenLoadContactFinish)
                                                 name:finishLoadContacts object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    _lbStarting.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey: text_wait_starting_app];
    if ([LinphoneAppDelegate sharedInstance].contactLoaded) {
        [[PhoneMainView instance] startUp];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)whenLoadContactFinish {
    [[PhoneMainView instance] startUp];
}

- (void)setupUIForView {
    if (SCREEN_WIDTH > 320) {
        _lbStarting.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:20.0];
        _lbCompany.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:20.0];
    }else{
        _lbStarting.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
        _lbCompany.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }
    
    float bgHeight = SCREEN_WIDTH*417/1282;
    _imgBottom.frame = CGRectMake(0, SCREEN_HEIGHT-bgHeight, SCREEN_WIDTH, bgHeight);
    
    float wLogo = 140;
    float hLogo = wLogo*281/512;
    float hLabel = 60.0;
    
    float originY = (SCREEN_HEIGHT-(hLogo+hLabel+bgHeight))/2;
    _imgLogo.frame = CGRectMake((SCREEN_WIDTH-wLogo)/2, originY, wLogo, hLogo);
    _lbStarting.frame = CGRectMake(0, _imgLogo.frame.origin.y+_imgLogo.frame.size.height, SCREEN_WIDTH, hLabel);
    _lbCompany.frame = CGRectMake(0, SCREEN_HEIGHT-40, SCREEN_WIDTH, 40);
    _lbCompany.textColor = [UIColor colorWithRed:(24/255.0) green:(185/255.0) blue:(153/255.0) alpha:1.0];
    
    YBHud *hud = [[YBHud alloc] initWithHudType:DGActivityIndicatorAnimationTypeLineScale andText:@""];
    
    //Optional Tint Color (Indicator Color)
    //  hud.tintColor = [UIColor colorWithRed:(24/255.0) green:(185/255.0) blue:(153/255.0) alpha:1.0];
    hud.tintColor = [UIColor whiteColor];
    hud.dimAmount = 0.5;
    [hud showInView:self.view animated:YES];
}

@end
