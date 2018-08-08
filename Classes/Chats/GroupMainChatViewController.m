//
//  GroupMainChatViewController.m
//  linphone
//
//  Created by Ei Captain on 7/12/16.
//
//

#import "GroupMainChatViewController.h"
#import "NewGroupChatViewController.h"
#import "GroupLeftChatViewController.h"
#import "GroupRightChatViewController.h"

@implementation GroupMainChatViewController

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
    if (compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:nil
                                                                 tabBar:nil
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
    
    // MY CODE HERE
    [self setRearViewRevealWidth: SCREEN_WIDTH - [LinphoneAppDelegate sharedInstance]._wSubMenu];
    [self setRightViewRevealWidth: SCREEN_WIDTH - [LinphoneAppDelegate sharedInstance]._wSubMenu];
    
    NewGroupChatViewController *groupChatVC    = [[NewGroupChatViewController alloc] init];
    //  GroupLeftChatViewController *leftVC     = [[GroupLeftChatViewController alloc] init];
    GroupRightChatViewController *rightVC   = [[GroupRightChatViewController alloc] init];
    
    //  [self setRearViewController: leftVC];
    [self setRightViewController: rightVC];
    [self setFrontViewController: groupChatVC];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
