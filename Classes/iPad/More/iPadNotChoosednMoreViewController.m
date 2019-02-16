//
//  iPadNotChoosednMoreViewController.m
//  linphone
//
//  Created by admin on 2/16/19.
//

#import "iPadNotChoosednMoreViewController.h"

@interface iPadNotChoosednMoreViewController ()

@end

@implementation iPadNotChoosednMoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    self.title = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"More"];
}

@end
