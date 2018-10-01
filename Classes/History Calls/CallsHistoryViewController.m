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
#import "RecordsCallViewController.h"
#import "TabBarView.h"

@interface CallsHistoryViewController ()
{
    int currentView;
    
    AllCallsViewController *allCallsVC;
    MissedCallViewController *missedCallsVC;
    RecordsCallViewController *recordCallsVC;
    
    UIFont *textFont;
}

@end

@implementation CallsHistoryViewController
@synthesize _viewHeader, _btnEdit, _lbDelete, _btnDone, _iconAll, _iconMissed, _iconRecord;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateValueNumberCallRemove:)
                                                 name:updateNumberHistoryCallRemove object:nil];
    self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-[LinphoneAppDelegate sharedInstance]._hStatus);
    self.view.backgroundColor = UIColor.clearColor;
    
    [self setupUIForView];
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
    recordCallsVC = [[RecordsCallViewController alloc] init];
    
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
        make.top.equalTo(self.view).offset([LinphoneAppDelegate sharedInstance]._hHeader);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self showContentWithCurrentLanguage];
    
    CGSize textSize = [AppUtils getSizeWithText:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Edit"] withFont:textFont];
    _btnEdit.frame = CGRectMake(10, 0, textSize.width, [LinphoneAppDelegate sharedInstance]._hHeader);
    
    textSize = [AppUtils getSizeWithText:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Done"] withFont:textFont];
    _btnDone.frame = CGRectMake(_viewHeader.frame.size.width-textSize.width-_lbDelete.frame.origin.x, _btnEdit.frame.origin.y, textSize.width, _btnEdit.frame.size.height);
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)_iconAllClicked:(id)sender {
    currentView = eAllCalls;
    [self updateStateIconWithView:currentView];
    [_pageViewController setViewControllers:@[allCallsVC]
                                  direction:UIPageViewControllerNavigationDirectionReverse
                                   animated:false completion:nil];
}

- (IBAction)_iconMissedClicked:(id)sender {
    currentView = eMissedCalls;
    [self updateStateIconWithView:currentView];
    [_pageViewController setViewControllers: @[missedCallsVC]
                                  direction: UIPageViewControllerNavigationDirectionReverse
                                   animated: false completion: nil];
}

- (IBAction)_iconRecordClicked:(id)sender {
    currentView = eRecordCalls;
    [self updateStateIconWithView:currentView];
    [_pageViewController setViewControllers: @[recordCallsVC]
                                  direction: UIPageViewControllerNavigationDirectionForward
                                   animated: false completion: nil];
}

- (IBAction)_btnEditPressed:(id)sender {
    _btnEdit.hidden = YES;
    _iconAll.hidden = YES;
    _iconMissed.hidden = YES;
    _iconRecord.hidden = YES;
    
    _btnDone.hidden = NO;
    _lbDelete.hidden = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:editHistoryCallView object:nil];
}

- (IBAction)_btnDonePressed:(id)sender {
    _btnEdit.hidden = NO;
    _iconAll.hidden = NO;
    _iconMissed.hidden = NO;
    _iconRecord.hidden = NO;
    
    _btnDone.hidden = YES;
    _lbDelete.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:finishRemoveHistoryCall object:nil];
}

#pragma mark – UIPageViewControllerDelegate Method

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if (viewController == allCallsVC) {
        currentView = eAllCalls;
        [self updateStateIconWithView: currentView];
        return nil;
    }else if (viewController == missedCallsVC){
        currentView = eMissedCalls;
        [self updateStateIconWithView: currentView];
        return allCallsVC;
    }else{
        currentView = eRecordCalls;
        [self updateStateIconWithView: currentView];
        return missedCallsVC;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if (viewController == allCallsVC) {
        currentView = eAllCalls;
        [self updateStateIconWithView: currentView];
        return missedCallsVC;
    }else if (viewController == missedCallsVC){
        currentView = eMissedCalls;
        [self updateStateIconWithView: currentView];
        return recordCallsVC;
    }else{
        currentView = eRecordCalls;
        [self updateStateIconWithView: currentView];
        return nil;
    }
}

#pragma mark - My functions

- (void)showContentWithCurrentLanguage {
    [_btnDone setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Done"] forState:UIControlStateNormal];
    [_btnEdit setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_edit] forState:UIControlStateNormal];
}

//  Reset lại các UI khi vào màn hình
- (void)resetUIForView {
    _btnEdit.hidden = NO;
    _iconAll.hidden = NO;
    _iconMissed.hidden = NO;
    _iconRecord.hidden = NO;
    
    _btnDone.hidden = YES;
    _lbDelete.hidden = YES;
}

//  Cập nhật trạng thái của các icon trên header
- (void)updateStateIconWithView: (int)view {
    //  Khi chuyển view thì huỷ trạng thái xoá
    [self resetUIForView];
    
    //  cập nhật background các icon
    if (view == eAllCalls) {
        _iconAll.selected = YES;
        _iconMissed.selected = NO;
        _iconRecord.selected = NO;
    }
    else if (view == eMissedCalls)
    {
        _iconAll.selected = NO;
        _iconMissed.selected = YES;
        _iconRecord.selected = NO;
    }else{
        _iconAll.selected = NO;
        _iconMissed.selected = NO;
        _iconRecord.selected = YES;
    }
}

//  setup trạng thái cho các button
- (void)setupUIForView {
    
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }else{
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
    }
    
    [_viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo([LinphoneAppDelegate sharedInstance]._hHeader);
    }];
    
    _lbDelete.font = textFont;
    _lbDelete.textAlignment = NSTextAlignmentLeft;
    _lbDelete.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_delete];
    [_lbDelete mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewHeader).offset(10);
        make.top.bottom.equalTo(_viewHeader);
        make.width.mas_equalTo(120.0);
    }];
    
    _btnEdit.titleLabel.font = textFont;
    _btnDone.titleLabel.font = textFont;
    
    [_iconRecord mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_viewHeader.mas_right);
        make.centerY.equalTo(_viewHeader.mas_centerY);
        make.width.height.mas_equalTo([LinphoneAppDelegate sharedInstance]._hHeader);
    }];
    
    [_iconMissed mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_iconRecord.mas_left);
        make.top.equalTo(_iconRecord);
        make.width.equalTo(_iconRecord.mas_width);
        make.height.equalTo(_iconRecord.mas_height);
    }];
    
    [_iconAll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_iconMissed.mas_left);
        make.top.equalTo(_iconMissed);
        make.width.equalTo(_iconMissed.mas_width);
        make.height.equalTo(_iconMissed.mas_height);
    }];
}

//  Cập nhật giá trị delete
- (void)updateValueNumberCallRemove: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[NSNumber class]]) {
        if ([object intValue] == 0) {
            _lbDelete.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_delete];
            
            CGSize textSize = [AppUtils getSizeWithText:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_delete] withFont:textFont];
            _btnEdit.frame = CGRectMake(_lbDelete.frame.origin.x, 0, textSize.width, [LinphoneAppDelegate sharedInstance]._hHeader);
        }else{
            NSString *str = [NSString stringWithFormat:@"%@(%d)", [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_delete], [object intValue]];
            _lbDelete.text = str;
            
            CGSize textSize = [AppUtils getSizeWithText:str withFont:textFont];
            _btnEdit.frame = CGRectMake(_lbDelete.frame.origin.x, 0, textSize.width, [LinphoneAppDelegate sharedInstance]._hHeader);
        }
    }
}

@end
