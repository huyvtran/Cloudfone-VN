//
//  PolicyViewController.m
//  linphone
//
//  Created by Apple on 4/28/17.
//
//

#import "PolicyViewController.h"

@implementation PolicyViewController
@synthesize _viewHeader, bgHeader, _iconBack, _lbHeader;
@synthesize _wvPolicy, icWaiting;

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
        compositeDescription.darkBackground = true;
    }
    return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
    return self.class.compositeViewDescription;
}

#pragma mark - My Controller Delegate

- (void)viewDidLoad {
    [super viewDidLoad];
    //  my code here
    self.view.backgroundColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                                 blue:(230/255.0) alpha:1.0];
    
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [WriteLogsUtils writeForGoToScreen:@"PolicyViewController"];
    
    _lbHeader.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Privacy Policy"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    NSURL *nsurl = [NSURL URLWithString: link_policy];
    NSURLRequest *nsrequest = [NSURLRequest requestWithURL: nsurl];
    [_wvPolicy loadRequest:nsrequest];
    
    icWaiting.hidden = NO;
    [icWaiting startAnimating];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)_iconBackClicked:(UIButton *)sender {
    [[PhoneMainView instance] popCurrentView];
}

#pragma mark - my functions

//  setup ui trong view
- (void)setupUIForView
{
    if (SCREEN_WIDTH > 320) {
        _lbHeader.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:20.0];
    }else{
        _lbHeader.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }
    
    //  header view
    [_viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo([LinphoneAppDelegate sharedInstance]._hRegistrationState);
    }];
    
    [bgHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(_viewHeader);
    }];
    
    [_lbHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader).offset([LinphoneAppDelegate sharedInstance]._hStatus);
        make.bottom.equalTo(_viewHeader);
        make.centerX.equalTo(_viewHeader.mas_centerX);
        make.width.mas_equalTo(200);
    }];
    
    [_iconBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewHeader);
        make.centerY.equalTo(_lbHeader.mas_centerY);
        make.width.height.mas_equalTo(HEADER_ICON_WIDTH);
    }];
    
    float tmpMargin = 15.0;
    [_wvPolicy mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader.mas_bottom).offset(tmpMargin);
        make.left.equalTo(self.view).offset(tmpMargin);
        make.bottom.right.equalTo(self.view).offset(-tmpMargin);
    }];
    _wvPolicy.layer.borderColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                   blue:(200/255.0) alpha:1.0].CGColor;
    _wvPolicy.layer.borderWidth = 1.0;
    _wvPolicy.layer.cornerRadius = 5.0;
    _wvPolicy.backgroundColor = UIColor.whiteColor;
    _wvPolicy.delegate = self;
    
    //  waiting loading
    [icWaiting mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_wvPolicy.mas_centerX);
        make.centerY.equalTo(_wvPolicy.mas_centerY);
        make.width.height.mas_equalTo(40.0);
    }];
}

#pragma mark - Webview delegate

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (webView.loading) {
        return;
    }
    if ([[webView stringByEvaluatingJavaScriptFromString:@"document.readyState"] isEqualToString:@"complete"])
    {
        if ([[webView.request.URL absoluteString] isEqualToString: link_policy]) {
            _wvPolicy.hidden = NO;
            icWaiting.hidden = YES;
            [icWaiting stopAnimating];
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"KL didFail: %@; stillLoading: %@", [[webView request]URL],
          (webView.loading?@"YES":@"NO"));
}

@end
