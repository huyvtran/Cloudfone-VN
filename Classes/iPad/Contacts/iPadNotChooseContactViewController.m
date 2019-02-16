//
//  iPadNotChooseContactViewController.m
//  linphone
//
//  Created by lam quang quan on 2/16/19.
//

#import "iPadNotChooseContactViewController.h"

@interface iPadNotChooseContactViewController ()

@end

@implementation iPadNotChooseContactViewController
@synthesize lbContent;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    lbContent.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Have not choosen contact"];
    self.title = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Contacts"];
}

- (void)setupUIForView {
    //  [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor redColor], NSFontAttributeName:[UIFont systemFontOfSize:22.0 weight:UIFontWeightThin]}];
    
    lbContent.textColor = UIColor.blackColor;
    lbContent.font = [UIFont systemFontOfSize:22.0 weight:UIFontWeightThin];
    [lbContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
}

@end
