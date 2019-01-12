//
//  iPadPolicyViewController.m
//  linphone
//
//  Created by admin on 1/12/19.
//

#import "iPadPolicyViewController.h"

@interface iPadPolicyViewController ()

@end

@implementation iPadPolicyViewController
@synthesize viewHeader, lbHeader, wvContent;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [WriteLogsUtils writeForGoToScreen:@"iPadPolicyViewController"];
    
    lbHeader.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Privacy Policy"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    NSString *url = @"http://dieukhoan.cloudfone.vn";
    NSURL *nsurl = [NSURL URLWithString:url];
    NSURLRequest *nsrequest = [NSURLRequest requestWithURL: nsurl];
    [wvContent loadRequest:nsrequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUIForView {
    //  header
    [viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(HEIGHT_IPAD_NAV);
    }];
    
    lbHeader.font = [UIFont fontWithName:HelveticaNeue size:24.0];
    [lbHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader).offset(STATUS_BAR_HEIGHT);
        make.left.right.bottom.equalTo(viewHeader);
    }];
    
    [lbHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader).offset(STATUS_BAR_HEIGHT);
        make.left.right.bottom.equalTo(viewHeader);
    }];
    
    float tmpMargin = 15.0;
    [wvContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader.mas_bottom).offset(tmpMargin);
        make.left.equalTo(self.view).offset(tmpMargin);
        make.bottom.right.equalTo(self.view).offset(-tmpMargin);
    }];
    wvContent.layer.borderColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                   blue:(200/255.0) alpha:1.0].CGColor;
    wvContent.layer.borderWidth = 1.0;
    wvContent.layer.cornerRadius = 5.0;
    wvContent.backgroundColor = [UIColor whiteColor];
}

@end
