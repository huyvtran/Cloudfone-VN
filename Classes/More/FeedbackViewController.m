//
//  FeedbackViewController.m
//  linphone
//
//  Created by Apple on 4/28/17.
//
//

#import "FeedbackViewController.h"
#import "PhoneMainView.h"

@interface FeedbackViewController (){
    UIFont *textFont;
}

@end

@implementation FeedbackViewController
@synthesize _viewHeader, _lbHeader, _iconBack;

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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    _lbHeader.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_feedback];
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
    //  header view
    if (SCREEN_WIDTH > 320) {
        _lbHeader.font = [UIFont fontWithName:HelveticaNeue size:20.0];
    }else{
        _lbHeader.font = [UIFont fontWithName:HelveticaNeue size:18.0];
    }
    _viewHeader.frame = CGRectMake(0, 0, SCREEN_WIDTH, [LinphoneAppDelegate sharedInstance]._hHeader);
    _iconBack.frame = CGRectMake(0, 0, [LinphoneAppDelegate sharedInstance]._hHeader, [LinphoneAppDelegate sharedInstance]._hHeader);
    [_iconBack setBackgroundImage:[UIImage imageNamed:@"ic_back_act.png"]
                         forState:UIControlStateHighlighted];
    
    _lbHeader.frame = CGRectMake(_iconBack.frame.origin.x+_iconBack.frame.size.width+5, 0, _viewHeader.frame.size.width-2*(_iconBack.frame.origin.x+_iconBack.frame.size.width+5), [LinphoneAppDelegate sharedInstance]._hHeader);
}

@end
