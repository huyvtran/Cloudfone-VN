//
//  iPadAboutViewController.m
//  linphone
//
//  Created by admin on 1/13/19.
//

#import "iPadAboutViewController.h"

@interface iPadAboutViewController ()

@end

@implementation iPadAboutViewController
@synthesize viewHeader, lbHeader, imgLogo, lbVersion, btnCheckForUpdate, btnYoutube, btnFacebook, btnCallHotline;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupUIForView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnCallHotlinePressed:(UIButton *)sender {
}

- (IBAction)btnYoutubePressed:(UIButton *)sender {
    NSURL *linkToApp = [NSURL URLWithString:[NSString stringWithFormat:@"youtube://watch?v=%@", @"UCBoBK-efPAsF1NbvCJFCzJw"]]; // I dont know excatly this one
    
    NSURL *linkToWeb = [NSURL URLWithString:@"https://www.youtube.com/channel/UCBoBK-efPAsF1NbvCJFCzJw"]; // this is correct
    
    
    if ([[UIApplication sharedApplication] canOpenURL:linkToApp]) {
        // Can open the youtube app URL so launch the youTube app with this URL
        [[UIApplication sharedApplication] openURL:linkToApp];
    }
    else{
        // Can't open the youtube app URL so launch Safari instead
        [[UIApplication sharedApplication] openURL:linkToWeb];
    }
    return;
    NSString *string = [NSString stringWithFormat:@"https://www.youtube.com/channel/UCBoBK-efPAsF1NbvCJFCzJw"];
    NSURL *url = [NSURL URLWithString:string];
    UIApplication *app = [UIApplication sharedApplication];
    [app openURL:url];
}

- (IBAction)btnFacebookPressed:(UIButton *)sender {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/CloudFone.VN/"]];
        
    }else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/CloudFone.VN/"]];
    }
}

- (void)setupUIForView {
    //  view header
    [viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(HEIGHT_IPAD_NAV);
    }];
    
    [lbHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(STATUS_BAR_HEIGHT);
        make.left.right.bottom.equalTo(viewHeader);
    }];
    
    //
    imgLogo.clipsToBounds = YES;
    imgLogo.layer.cornerRadius = 10.0;
    [imgLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader.mas_bottom).offset(100);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.height.mas_equalTo(100.0);
    }];
    
    //  label version
    lbVersion.textAlignment = NSTextAlignmentCenter;
    lbVersion.font = [UIFont fontWithName:HelveticaNeue size:24.0];
    [lbVersion mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgLogo.mas_bottom).offset(40.0);
        make.left.equalTo(self.view).offset(20.0);
        make.right.equalTo(self.view).offset(-20.0);
        make.height.mas_lessThanOrEqualTo(100.0);
    }];
    
    btnCheckForUpdate.titleLabel.font = [UIFont fontWithName:HelveticaNeue size:24.0];
    [btnCheckForUpdate setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnCheckForUpdate.clipsToBounds = YES;
    btnCheckForUpdate.layer.cornerRadius = 60.0/2;
    [btnCheckForUpdate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbVersion.mas_bottom).offset(40.0);
        make.left.equalTo(lbVersion.mas_left);
        make.right.equalTo(lbVersion.mas_right);
        make.height.mas_equalTo(60.0);
    }];
    
    //  action buttons
    float padding = 20.0;
    float margin = 25.0;
    
    btnFacebook.imageEdgeInsets = UIEdgeInsetsMake(padding, padding, padding, padding);
    btnFacebook.layer.cornerRadius = 80.0/2;
    btnFacebook.layer.borderWidth = 2.0;
    btnFacebook.layer.borderColor = IPAD_HEADER_BG_COLOR.CGColor;
    [btnFacebook mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(btnCheckForUpdate.mas_bottom).offset(50.0);
        make.width.height.mas_equalTo(80.0);
    }];
    
    btnYoutube.imageEdgeInsets = UIEdgeInsetsMake(padding, padding, padding, padding);
    btnYoutube.layer.cornerRadius = btnFacebook.layer.cornerRadius;
    btnYoutube.layer.borderWidth = btnFacebook.layer.borderWidth;
    btnYoutube.layer.borderColor = btnFacebook.layer.borderColor;
    [btnYoutube mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(btnFacebook.mas_right).offset(margin);
        make.top.equalTo(btnFacebook);
        make.width.equalTo(btnFacebook.mas_width);
        make.height.equalTo(btnFacebook.mas_height);
    }];
    
    btnCallHotline.imageEdgeInsets = UIEdgeInsetsMake(padding, padding, padding, padding);
    btnCallHotline.layer.cornerRadius = btnFacebook.layer.cornerRadius;
    btnCallHotline.layer.borderWidth = btnFacebook.layer.borderWidth;
    btnCallHotline.layer.borderColor = btnFacebook.layer.borderColor;
    [btnCallHotline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(btnFacebook.mas_left).offset(-margin);
        make.top.equalTo(btnFacebook);
        make.width.equalTo(btnFacebook.mas_width);
        make.height.equalTo(btnFacebook.mas_height);
    }];
}


@end
