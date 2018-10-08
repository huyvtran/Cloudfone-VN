//
//  KMessageViewController.m
//  linphone
//
//  Created by mac book on 30/4/15.
//
//

#import "KMessageViewController.h"
#import "SwipeableTableViewCell.h"
#import "NSDatabase.h"
#import "NSData+Base64.h"
#import "TabBarView.h"

@interface KMessageViewController (){
}
@end

@implementation KMessageViewController

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
        compositeDescription.darkBackground = true;
    }
    return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
    return self.class.compositeViewDescription;
}

#pragma mark - Web services

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
