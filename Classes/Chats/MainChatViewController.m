//
//  MainChatViewController.m
//  linphone
//
//  Created by Ei Captain on 4/11/16.
//
//

#import "MainChatViewController.h"
#import "ChatViewController.h"
#import "NewChatViewController.h"
#import "RightChatViewController.h"

@interface MainChatViewController (){
    
}

@end

@implementation MainChatViewController

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
    self.rearViewRevealWidth = SCREEN_WIDTH - [LinphoneAppDelegate sharedInstance]._wSubMenu;
    self.rightViewRevealWidth = SCREEN_WIDTH - [LinphoneAppDelegate sharedInstance]._wSubMenu;
    
    NewChatViewController *mainVC         = [[NewChatViewController alloc] init];
    //  LeftChatViewController *leftVC      = [[LeftChatViewController alloc] init];
    RightChatViewController *RightVC    = [[RightChatViewController alloc] init];
    
    //  self.rearViewController     = leftVC;
    self.rightViewController    = RightVC;
    self.frontViewController    = mainVC;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
