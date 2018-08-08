//
//  PolicyViewController.m
//  linphone
//
//  Created by Apple on 4/28/17.
//
//

#import "PolicyViewController.h"
#import "PhoneMainView.h"

@implementation PolicyViewController
@synthesize _viewHeader, _iconBack, _lbHeader;
@synthesize _wvPolicy;

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
    self.view.backgroundColor = [UIColor colorWithRed:(240/255.0) green:(240/255.0)
                                                 blue:(240/255.0) alpha:(240/255.0)];
    
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    _lbHeader.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_policy];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    NSString *url = @"http://dieukhoan.cloudfone.vn";
    NSURL *nsurl = [NSURL URLWithString:url];
    NSURLRequest *nsrequest = [NSURLRequest requestWithURL: nsurl];
    [_wvPolicy loadRequest:nsrequest];
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
        _lbHeader.font = [UIFont fontWithName:HelveticaNeue size:20.0];
    }else{
        _lbHeader.font = [UIFont fontWithName:HelveticaNeue size:18.0];
    }
    
    //  header view
    _viewHeader.frame = CGRectMake(0, 0, SCREEN_WIDTH, [LinphoneAppDelegate sharedInstance]._hHeader);
    _iconBack.frame = CGRectMake(0, 0, [LinphoneAppDelegate sharedInstance]._hHeader, [LinphoneAppDelegate sharedInstance]._hHeader);
    [_iconBack setBackgroundImage:[UIImage imageNamed:@"ic_back_act.png"]
                         forState:UIControlStateHighlighted];
    _lbHeader.frame = CGRectMake(_iconBack.frame.origin.x+_iconBack.frame.size.width+5, 0, _viewHeader.frame.size.width-2*(_iconBack.frame.origin.x+_iconBack.frame.size.width+5), [LinphoneAppDelegate sharedInstance]._hHeader);
    
    float tmpMargin = 15.0;
    _wvPolicy.frame = CGRectMake(tmpMargin, _viewHeader.frame.origin.y+_viewHeader.frame.size.height+tmpMargin, SCREEN_WIDTH-2*tmpMargin, SCREEN_HEIGHT-([LinphoneAppDelegate sharedInstance]._hStatus+[LinphoneAppDelegate sharedInstance]._hHeader+2*tmpMargin));
    _wvPolicy.layer.borderColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                   blue:(200/255.0) alpha:1.0].CGColor;
    _wvPolicy.layer.borderWidth = 1.0;
    _wvPolicy.layer.cornerRadius = 5.0;
    _wvPolicy.backgroundColor = [UIColor whiteColor];
}

@end
