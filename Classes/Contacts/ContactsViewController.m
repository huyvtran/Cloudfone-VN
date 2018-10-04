//
//  ContactsViewController.m
//  linphone
//
//  Created by Ei Captain on 6/30/16.
//
//

#import "ContactsViewController.h"
#import "AllContactsViewController.h"
#import "PBXContactsViewController.h"
#import "PhoneMainView.h"
#import "JSONKit.h"
#import "StatusBarView.h"
#import "TabBarView.h"

@interface ContactsViewController (){
    AllContactsViewController *allContactsVC;
    PBXContactsViewController *pbxContactsVC;
    int currentView;
    float hIcon;
    
    NSTimer *searchTimer;
}
@end

@implementation ContactsViewController
@synthesize _pageViewController, _viewHeader, _iconAddNew, _iconAll, _iconPBX, _iconSyncPBXContact, _tfSearch, imgBackground, _icClearSearch;
@synthesize _listSyncContact, _phoneForSync;

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
    if (compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:nil
                                                                 tabBar:TabBarView.class
                                                               sideMenu:nil
                                                             fullscreen:false
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
    //  MY CODE HERE
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
    
    self.view.backgroundColor = UIColor.clearColor;
    
    [self autoLayoutForMainView];
    
    currentView = eContactPBX;
    [self updateStateIconWithView: currentView];
    
    _pageViewController.view.backgroundColor = UIColor.clearColor;
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    
    pbxContactsVC = [[PBXContactsViewController alloc] init];
    allContactsVC = [[AllContactsViewController alloc] init];
    
    NSArray *viewControllers = [NSArray arrayWithObject:pbxContactsVC];
    [_pageViewController setViewControllers:viewControllers
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:true completion:nil];
    _pageViewController.view.layer.shadowColor = UIColor.clearColor.CGColor;
    _pageViewController.view.layer.borderWidth = 0.0;
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    
    [_pageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    //  _pageViewController.view.frame = CGRectMake(0, [LinphoneAppDelegate sharedInstance]._hHeader, SCREEN_WIDTH, SCREEN_HEIGHT-[LinphoneAppDelegate sharedInstance]._hStatus-[LinphoneAppDelegate sharedInstance]._hHeader-[LinphoneAppDelegate sharedInstance]._hTabbar);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Tắt màn hình cảm biến
    UIDevice *device = [UIDevice currentDevice];
    device.proximityMonitoringEnabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    [AppUtils addCornerRadiusTopLeftAndBottomLeftForButton:_iconPBX radius:(hIcon-10)/2 withColor:[UIColor colorWithRed:0.169 green:0.53 blue:0.949 alpha:1.0] border:2.0];
    [AppUtils addCornerRadiusTopRightAndBottomRightForButton:_iconAll radius:(hIcon-10)/2 withColor:[UIColor colorWithRed:0.169 green:0.53 blue:0.949 alpha:1.0] border:2.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark – UIPageViewControllerDelegate Method

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if (viewController == pbxContactsVC){
        currentView = eContactPBX;
        [self updateStateIconWithView: currentView];
        return nil;
    }else{
        currentView = eContactAll;
        [self updateStateIconWithView: currentView];
        return pbxContactsVC;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if (viewController == pbxContactsVC){
        currentView = eContactPBX;
        [self updateStateIconWithView: currentView];
        return allContactsVC;
    }else{
        currentView = eContactAll;
        [self updateStateIconWithView: currentView];
        return nil;
    }
}

- (IBAction)_iconAddNewClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:addNewContactInContactView
                                                        object:nil];
}

- (IBAction)_iconAllClicked:(id)sender {
    currentView = eContactAll;
    [self updateStateIconWithView:currentView];
    [_pageViewController setViewControllers: @[allContactsVC]
                                  direction: UIPageViewControllerNavigationDirectionReverse
                                   animated: false completion: nil];
}

- (IBAction)_iconPBXClicked:(UIButton *)sender {
    currentView = eContactPBX;
    [self updateStateIconWithView:currentView];
    [_pageViewController setViewControllers: @[pbxContactsVC]
                                  direction: UIPageViewControllerNavigationDirectionForward
                                   animated: false completion: nil];
}

- (IBAction)_iconSyncPBXContactClicked:(UIButton *)sender {
}

- (IBAction)_icClearSearchClicked:(UIButton *)sender {
}

//  setup trạng thái cho các button
- (void)autoLayoutForMainView {
    hIcon = [LinphoneAppDelegate sharedInstance]._hRegistrationState - [LinphoneAppDelegate sharedInstance]._hStatus;
    _viewHeader.backgroundColor = UIColor.greenColor;
    [_viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo([LinphoneAppDelegate sharedInstance]._hRegistrationState + 50);
    }];
    
    [imgBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(_viewHeader);
    }];
    
    _iconSyncPBXContact.backgroundColor = UIColor.clearColor;
    [_iconSyncPBXContact mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewHeader).offset(10);
        make.top.equalTo(_viewHeader).offset([LinphoneAppDelegate sharedInstance]._hStatus+5);
        make.width.height.mas_equalTo(hIcon-10);
    }];
    
    [_iconAddNew mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_viewHeader.mas_right).offset(-10);
        make.top.equalTo(_iconSyncPBXContact.mas_top);
        make.width.equalTo(_iconSyncPBXContact.mas_width);
        make.height.equalTo(_iconSyncPBXContact.mas_height);
    }];
    
    _iconPBX.backgroundColor = [UIColor colorWithRed:0.169 green:0.53 blue:0.949 alpha:1.0];
    [_iconPBX setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"PBX"] forState:UIControlStateNormal];
    [_iconPBX setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_iconPBX mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_viewHeader.mas_centerX);
        make.centerY.equalTo(_iconAddNew.mas_centerY);
        make.height.equalTo(_iconAddNew.mas_height);
        make.width.mas_equalTo(SCREEN_WIDTH/4);
    }];
    
    _iconAll.backgroundColor = UIColor.clearColor;
    [_iconAll setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Contacts"] forState:UIControlStateNormal];
    [_iconAll setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_iconAll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewHeader.mas_centerX);
        make.top.bottom.equalTo(_iconPBX);
        make.width.equalTo(_iconPBX.mas_width);
        make.height.equalTo(_iconPBX.mas_height);
    }];
    
    float hTextfield = 34.0;
    _tfSearch.backgroundColor = [UIColor colorWithRed:(150/255.0) green:(150/255.0)
                                                 blue:(150/255.0) alpha:0.5];
    _tfSearch.font = [UIFont systemFontOfSize: 16.0];
    _tfSearch.borderStyle = UITextBorderStyleNone;
    _tfSearch.layer.cornerRadius = hTextfield/2;
    _tfSearch.clipsToBounds = YES;
    if ([self._tfSearch respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        _tfSearch.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Type name or phone number"] attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:(230/255.0) green:(230/255.0) blue:(230/255.0) alpha:1.0]}];
    } else {
        _tfSearch.placeholder = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Type name or phone number"];
    }
    [_tfSearch addTarget:self
                  action:@selector(onSearchContactChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    UIView *pLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 0, hTextfield, hTextfield)];
    _tfSearch.leftView = pLeft;
    _tfSearch.leftViewMode = UITextFieldViewModeAlways;
    
    [_tfSearch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_iconAll.mas_bottom).offset(5+(50-hTextfield)/2);
        make.left.equalTo(_viewHeader).offset(50.0);
        make.right.equalTo(_viewHeader).offset(-50.0);
        make.height.mas_equalTo(hTextfield);
    }];
    
    UIImageView *imgSearch = [[UIImageView alloc] init];
    imgSearch.image = [UIImage imageNamed:@"ic_search"];
    [_tfSearch addSubview: imgSearch];
    [imgSearch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(_tfSearch);
        make.width.mas_equalTo(hTextfield);
    }];
    
    _icClearSearch.backgroundColor = UIColor.clearColor;
    [_icClearSearch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(_tfSearch);
        make.width.mas_equalTo(hTextfield);
    }];
}

//  Cập nhật trạng thái của các icon trên header
- (void)updateStateIconWithView: (int)view
{
    if (view == eContactAll){
        _iconSyncPBXContact.hidden = YES;
        _iconAddNew.hidden = NO;
        [self setSelected: YES forButton: _iconAll];
        [self setSelected: NO forButton: _iconPBX];
    }else{
        _iconSyncPBXContact.hidden = NO;
        _iconAddNew.hidden = YES;
        [self setSelected: NO forButton: _iconAll];
        [self setSelected: YES forButton: _iconPBX];
    }
}

- (void)setSelected: (BOOL)selected forButton: (UIButton *)button {
    if (selected) {
        button.backgroundColor = [UIColor colorWithRed:0.169 green:0.53 blue:0.949 alpha:1.0];
    }else{
        button.backgroundColor = UIColor.clearColor;
    }
}

//  Added by Khai Le on 04/10/2018
- (void)onSearchContactChange: (UITextField *)textField {
    [searchTimer invalidate];
    searchTimer = nil;
    searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self
                                                 selector:@selector(startSearchPhoneBook)
                                                 userInfo:nil repeats:NO];
}

- (void)startSearchPhoneBook {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"searchContactWithValue" object:_tfSearch.text];
}

@end
