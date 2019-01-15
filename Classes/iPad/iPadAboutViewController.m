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
@synthesize imgLogo, lbVersion, btnCheckForUpdate, btnYoutube, btnFacebook, btnCallHotline;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    self.title = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"About"];
    [btnCheckForUpdate setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Check for update"] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnCallHotlinePressed:(UIButton *)sender {
}

- (IBAction)btnYoutubePressed:(UIButton *)sender
{
    NSURL *linkToApp = [NSURL URLWithString:[NSString stringWithFormat:@"youtube://watch?v=%@", youtube_channel]];
    NSURL *linkToWeb = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.youtube.com/channel/%@", youtube_channel]];
    if ([[UIApplication sharedApplication] canOpenURL:linkToApp]) {
        [[UIApplication sharedApplication] openURL:linkToApp];
    }
    else{
        [[UIApplication sharedApplication] openURL:linkToWeb];
    }
}

- (IBAction)btnFacebookPressed:(UIButton *)sender {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:facebook_link]];
        
    }else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:facebook_link]];
    }
}

- (void)setupUIForView {
    imgLogo.clipsToBounds = YES;
    imgLogo.layer.cornerRadius = 10.0;
    [imgLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(100);
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
    btnCheckForUpdate.layer.cornerRadius = 45.0/2;
    [btnCheckForUpdate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbVersion.mas_bottom).offset(40.0);
        make.left.equalTo(self.view).offset(30.0);
        make.right.equalTo(self.view).offset(-30.0);
        make.height.mas_equalTo(45.0);
    }];
    
    //  action buttons
    float padding = 20.0;
    float margin = 30.0;
    
    btnFacebook.imageEdgeInsets = UIEdgeInsetsMake(padding, padding, padding, padding);
    btnFacebook.layer.cornerRadius = 80.0/2;
    btnFacebook.layer.borderWidth = 1.0;
    btnFacebook.layer.borderColor = [UIColor colorWithRed:(77/255.0) green:(111/255.0)
                                                     blue:(169/255.0) alpha:1.0].CGColor;
    [btnFacebook mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(btnCheckForUpdate.mas_bottom).offset(50.0);
        make.width.height.mas_equalTo(80.0);
    }];
    
    btnYoutube.imageEdgeInsets = UIEdgeInsetsMake(padding, padding, padding, padding);
    btnYoutube.layer.cornerRadius = btnFacebook.layer.cornerRadius;
    btnYoutube.layer.borderWidth = btnFacebook.layer.borderWidth;
    btnYoutube.layer.borderColor = [UIColor colorWithRed:(244/255.0) green:(67/255.0)
                                                    blue:(54/255.0) alpha:1.0].CGColor;
    [btnYoutube mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(btnFacebook.mas_right).offset(margin);
        make.top.equalTo(btnFacebook);
        make.width.equalTo(btnFacebook.mas_width);
        make.height.equalTo(btnFacebook.mas_height);
    }];
    
    btnCallHotline.imageEdgeInsets = UIEdgeInsetsMake(padding, padding, padding, padding);
    btnCallHotline.layer.cornerRadius = btnFacebook.layer.cornerRadius;
    btnCallHotline.layer.borderWidth = btnFacebook.layer.borderWidth;
    btnCallHotline.layer.borderColor = [UIColor colorWithRed:(0/255.0) green:(109/255.0)
                                                        blue:(240/255.0) alpha:1.0].CGColor;
    [btnCallHotline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(btnFacebook.mas_left).offset(-margin);
        make.top.equalTo(btnFacebook);
        make.width.equalTo(btnFacebook.mas_width);
        make.height.equalTo(btnFacebook.mas_height);
    }];
}


@end
