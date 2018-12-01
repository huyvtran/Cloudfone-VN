//
//  CallsHistoryViewController.m
//  linphone
//
//  Created by Ei Captain on 7/5/16.
//
//

#import "CallsHistoryViewController.h"
#import "AllCallsViewController.h"
#import "MissedCallViewController.h"
#import "TabBarView.h"

@interface CallsHistoryViewController () {
    int currentView;
    AllCallsViewController *allCallsVC;
    MissedCallViewController *missedCallsVC;
    UIFont *textFont;
    float hIcon;
}

@end

@implementation CallsHistoryViewController
@synthesize _viewHeader, _btnEdit, _iconAll, _iconMissed, bgHeader;
@synthesize _pageViewController, _vcIndex;

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
    if (compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:nil
                                                                 tabBar:TabBarView.class
                                                               sideMenu:nil
                                                             fullscreen:FALSE
                                                         isLeftFragment:YES
                                                           fragmentWith:nil];
    }
    return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
    return self.class.compositeViewDescription;
}

#pragma mark - My controller
- (void)viewDidLoad {
    [super viewDidLoad];
    // MY CODE HERE
    
    //  notifications
    //  Sau khi xoá tất cả các cuộc gọi
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetUIForView)
                                                 name:k11ReloadAfterDeleteAllCall object:nil];
    
    //  Cập nhật nhãn delete khi xoá lịch sử cuộc gọi
    self.view.backgroundColor = UIColor.clearColor;
    
    [self autoLayoutForView];
    currentView = eAllCalls;
    [self updateStateIconWithView: currentView];
    
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
    
    _pageViewController.view.backgroundColor = UIColor.clearColor;
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    
    allCallsVC = [[AllCallsViewController alloc] init];
    missedCallsVC = [[MissedCallViewController alloc] init];
    
    NSArray *viewControllers = [NSArray arrayWithObject:allCallsVC];
    [_pageViewController setViewControllers:viewControllers
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:false
                                 completion:nil];
    _pageViewController.view.layer.shadowColor = UIColor.clearColor.CGColor;
    _pageViewController.view.layer.borderWidth = 0;
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    
    [_pageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self showContentWithCurrentLanguage];
    
    // Tắt màn hình cảm biến
    UIDevice *device = [UIDevice currentDevice];
    device.proximityMonitoringEnabled = NO;
    
    //  Reset lại các UI khi vào màn hình
    [self resetUIForView];
    
    // Reset missed call
    linphone_core_reset_missed_calls_count([LinphoneManager getLc]);
    
    // Fake event
    [[NSNotificationCenter defaultCenter] postNotificationName:kLinphoneCallUpdate object:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    [AppUtils addCornerRadiusTopLeftAndBottomLeftForButton:_iconAll radius:(hIcon-10)/2 withColor:[UIColor colorWithRed:0.169 green:0.53 blue:0.949 alpha:1.0] border:2.0];
    [AppUtils addCornerRadiusTopRightAndBottomRightForButton:_iconMissed radius:(hIcon-10)/2 withColor:[UIColor colorWithRed:0.169 green:0.53 blue:0.949 alpha:1.0] border:2.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)_iconAllClicked:(id)sender {
    if (currentView == eAllCalls) {
        return;
    }
    
    currentView = eAllCalls;
    [self updateStateIconWithView:currentView];
    [_pageViewController setViewControllers:@[allCallsVC]
                                  direction:UIPageViewControllerNavigationDirectionReverse
                                   animated:false completion:nil];
    [_btnEdit setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Delete"] forState:UIControlStateNormal];
}

- (IBAction)_iconMissedClicked:(id)sender {
    if (currentView == eMissedCalls) {
        return;
    }
    
    currentView = eMissedCalls;
    [self updateStateIconWithView:currentView];
    [_pageViewController setViewControllers: @[missedCallsVC]
                                  direction: UIPageViewControllerNavigationDirectionReverse
                                   animated: false completion: nil];
    
    [_btnEdit setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Delete"] forState:UIControlStateNormal];
}

- (IBAction)_btnEditPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:deleteHistoryCallsChoosed
                                                        object:[(UIButton *)sender currentTitle]];
}

#pragma mark – UIPageViewControllerDelegate Method

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if (viewController == allCallsVC) {
        currentView = eAllCalls;
        [self updateStateIconWithView: currentView];
        return nil;
    }else{
        currentView = eMissedCalls;
        [self updateStateIconWithView: currentView];
        return allCallsVC;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if (viewController == allCallsVC) {
        currentView = eAllCalls;
        [self updateStateIconWithView: currentView];
        return missedCallsVC;
    }else{
        currentView = eMissedCalls;
        [self updateStateIconWithView: currentView];
        return nil;
    }
}

#pragma mark - My functions

- (void)showContentWithCurrentLanguage {
    [_btnEdit setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Edit"] forState:UIControlStateNormal];
    [_iconAll setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"All"] forState:UIControlStateNormal];
    [_iconMissed setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Missed"] forState:UIControlStateNormal];
}

//  Reset lại các UI khi vào màn hình
- (void)resetUIForView {
    _btnEdit.hidden = NO;
    _iconAll.hidden = NO;
    _iconMissed.hidden = NO;
}

//  Cập nhật trạng thái của các icon trên header
- (void)updateStateIconWithView: (int)view
{
    if (view == eAllCalls){
        [self setSelected: YES forButton: _iconAll];
        [self setSelected: NO forButton: _iconMissed];
    }else{
        [self setSelected: NO forButton: _iconAll];
        [self setSelected: YES forButton: _iconMissed];
    }
}

- (void)setSelected: (BOOL)selected forButton: (UIButton *)button {
    if (selected) {
        button.backgroundColor = [UIColor colorWithRed:0.169 green:0.53 blue:0.949 alpha:1.0];
    }else{
        button.backgroundColor = UIColor.clearColor;
    }
}

//  setup trạng thái cho các button
- (void)autoLayoutForView {
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }else{
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
    }
    
    hIcon = [LinphoneAppDelegate sharedInstance]._hRegistrationState - [LinphoneAppDelegate sharedInstance]._hStatus;
    
    [_viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo([LinphoneAppDelegate sharedInstance]._hRegistrationState);
    }];
    
    [bgHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(_viewHeader);
    }];
    
    _iconAll.backgroundColor = [UIColor colorWithRed:0.169 green:0.53 blue:0.949 alpha:1.0];
    [_iconAll setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"All"] forState:UIControlStateNormal];
    [_iconAll setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_iconAll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader).offset([LinphoneAppDelegate sharedInstance]._hStatus+5);
        make.right.equalTo(_viewHeader.mas_centerX);
        make.height.mas_equalTo(hIcon-10);
        make.width.mas_equalTo(SCREEN_WIDTH/4);
    }];
    
    _iconMissed.backgroundColor = UIColor.clearColor;
    [_iconMissed setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Missed"] forState:UIControlStateNormal];
    [_iconMissed setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_iconMissed mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewHeader.mas_centerX);
        make.top.bottom.equalTo(_iconAll);
        make.width.equalTo(_iconAll.mas_width);
        make.height.equalTo(_iconAll.mas_height);
    }];
    
    [_btnEdit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_viewHeader.mas_right).offset(-10);
        make.centerY.equalTo(_iconAll.mas_centerY);
        make.height.equalTo(_iconAll.mas_height);
        make.width.mas_lessThanOrEqualTo(100);
    }];
    _btnEdit.titleLabel.font = textFont;
}

@end
