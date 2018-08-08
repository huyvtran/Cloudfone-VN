//
//  ContactsViewController.m
//  linphone
//
//  Created by Ei Captain on 6/30/16.
//
//

#import "ContactsViewController.h"
#import "SipContactsViewController.h"
#import "AllContactsViewController.h"
#import "PBXContactsViewController.h"
#import "PhoneMainView.h"
#import "JSONKit.h"
#import "StatusBarView.h"
#import "TabBarView.h"
#import <CommonCrypto/CommonDigest.h>

@interface ContactsViewController (){
    SipContactsViewController *sipContactsVC;
    AllContactsViewController *allContactsVC;
    PBXContactsViewController *pbxContactsVC;
    
    int currentView;
}
@end

@implementation NSString (MD5)
- (NSString *)MD5String {
    const char *cstr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, (int)strlen(cstr), result);
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end

@implementation ContactsViewController
@synthesize _pageViewController, _viewHeader, _iconAddNew, _iconODS, _iconAll, _iconPBX;
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
    
    //  [self.view setFrame: CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-hAppStatus)];
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    [self setupUIForView];
    
    currentView = eContactSip;
    [self updateStateIconWithView: currentView];
    
    
    _pageViewController.view.frame = CGRectMake(0, [LinphoneAppDelegate sharedInstance]._hHeader, SCREEN_WIDTH, SCREEN_HEIGHT-[LinphoneAppDelegate sharedInstance]._hStatus-[LinphoneAppDelegate sharedInstance]._hHeader-[LinphoneAppDelegate sharedInstance]._hTabbar);
    _pageViewController.view.backgroundColor = UIColor.clearColor;
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    
    sipContactsVC = [[SipContactsViewController alloc] init];
    allContactsVC = [[AllContactsViewController alloc] init];
    pbxContactsVC = [[PBXContactsViewController alloc] init];
    
    
    NSArray *viewControllers = [NSArray arrayWithObject:sipContactsVC];
    [_pageViewController setViewControllers:viewControllers
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:true completion:nil];
    _pageViewController.view.layer.shadowColor = UIColor.clearColor.CGColor;
    _pageViewController.view.layer.borderWidth = 0.0;
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Tắt màn hình cảm biến
    UIDevice *device = [UIDevice currentDevice];
    device.proximityMonitoringEnabled = NO;
    
    // Neu chua login thi login lai
    if (![LinphoneAppDelegate sharedInstance].xmppStream.isConnected) {
        [AppUtils reconnectToXMPPServer];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark – UIPageViewControllerDelegate Method

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if (viewController == sipContactsVC) {
        currentView = eContactSip;
        [self updateStateIconWithView: currentView];
        return nil;
    }else if (viewController == pbxContactsVC){
        currentView = eContactPBX;
        [self updateStateIconWithView: currentView];
        return sipContactsVC;
    }else{
        currentView = eContactAll;
        [self updateStateIconWithView: currentView];
        return pbxContactsVC;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if (viewController == sipContactsVC) {
        currentView = eContactSip;
        [self updateStateIconWithView: currentView];
        return pbxContactsVC;
    }else if (viewController == pbxContactsVC){
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

- (IBAction)_iconODSClicked:(id)sender {
    currentView = eContactSip;
    [self updateStateIconWithView:currentView];
    [_pageViewController setViewControllers:@[sipContactsVC]
                                  direction:UIPageViewControllerNavigationDirectionReverse
                                   animated:false completion:nil];
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

//  setup trạng thái cho các button
- (void)setupUIForView {
    _viewHeader.frame = CGRectMake(0, 0, SCREEN_WIDTH, [LinphoneAppDelegate sharedInstance]._hHeader);
    _iconAddNew.frame = CGRectMake(0, ([LinphoneAppDelegate sharedInstance]._hHeader-45.0)/2, 45.0, 45.0);
    
    _iconAll.frame = CGRectMake(_viewHeader.frame.size.width-_iconAddNew.frame.size.width, _iconAddNew.frame.origin.y, _iconAddNew.frame.size.width, _iconAddNew.frame.size.height);
    [_iconAll setBackgroundImage:[UIImage imageNamed:@"ic_contact_act"]
                        forState:UIControlStateSelected];
    [_iconAll setBackgroundImage:[UIImage imageNamed:@"ic_contact_def"]
                        forState:UIControlStateNormal];
    
    _iconPBX.frame = CGRectMake(_iconAll.frame.origin.x-_iconAll.frame.size.width, _iconAll.frame.origin.y, _iconAll.frame.size.width, _iconAll.frame.size.height);
    [_iconPBX setBackgroundImage:[UIImage imageNamed:@"ic_PBX_act"]
                        forState:UIControlStateSelected];
    [_iconPBX setBackgroundImage:[UIImage imageNamed:@"ic_PBX_def"]
                        forState:UIControlStateNormal];
    
    _iconODS.frame = CGRectMake(_iconPBX.frame.origin.x-_iconPBX.frame.size.width, _iconPBX.frame.origin.y, _iconPBX.frame.size.width, _iconPBX.frame.size.height);
    [_iconODS setBackgroundImage:[UIImage imageNamed:@"ic_ods_act"]
                        forState:UIControlStateSelected];
    [_iconODS setBackgroundImage:[UIImage imageNamed:@"ic_ods_def"]
                        forState:UIControlStateNormal];
}

//  Cập nhật trạng thái của các icon trên header
- (void)updateStateIconWithView: (int)view
{
    if (view == eContactSip) {
        _iconODS.selected = YES;
        _iconAll.selected = NO;
        _iconPBX.selected = NO;
        _iconAddNew.hidden = NO;
    }else if (view == eContactAll){
        _iconODS.selected = NO;
        _iconAll.selected = YES;
        _iconPBX.selected = NO;
        _iconAddNew.hidden = NO;
    }else{
        _iconODS.selected = NO;
        _iconAll.selected = NO;
        _iconPBX.selected = YES;
        _iconAddNew.hidden = NO;
    }
}

@end
