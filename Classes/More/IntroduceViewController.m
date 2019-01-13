//
//  IntroduceViewController.m
//  linphone
//
//  Created by Apple on 4/28/17.
//
//

#import "IntroduceViewController.h"

@interface IntroduceViewController ()
@end

@implementation IntroduceViewController
@synthesize _viewHeader, bgHeader, _iconBack, _wvIntroduce, _lbIntroduce, icWaiting;

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
    [self autoLayoutForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [WriteLogsUtils writeForGoToScreen:@"IntroduceViewController"];
    
    _lbIntroduce.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Introduction"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    NSURL *nsurl=[NSURL URLWithString: link_introduce];
    NSURLRequest *nsrequest = [NSURLRequest requestWithURL: nsurl];
    [_wvIntroduce loadRequest:nsrequest];
    
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
- (void)autoLayoutForView
{
    if (SCREEN_WIDTH > 320) {
        _lbIntroduce.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:20.0];
    }else{
        _lbIntroduce.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }
    
    //  header view
    [_viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo([LinphoneAppDelegate sharedInstance]._hRegistrationState);
    }];
    
    [bgHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(_viewHeader);
    }];
    
    [_lbIntroduce mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader).offset([LinphoneAppDelegate sharedInstance]._hStatus);
        make.bottom.equalTo(_viewHeader);
        make.centerX.equalTo(_viewHeader.mas_centerX);
        make.width.mas_equalTo(200);
    }];
    
    [_iconBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewHeader);
        make.centerY.equalTo(_lbIntroduce.mas_centerY);
        make.width.height.mas_equalTo(HEADER_ICON_WIDTH);
    }];
    
    float tmpMargin = 15.0;
    [_wvIntroduce mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader.mas_bottom).offset(tmpMargin);
        make.left.equalTo(self.view).offset(tmpMargin);
        make.bottom.right.equalTo(self.view).offset(-tmpMargin);
    }];
    _wvIntroduce.layer.borderColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                      blue:(200/255.0) alpha:1.0].CGColor;
    _wvIntroduce.layer.borderWidth = 1.0;
    _wvIntroduce.layer.cornerRadius = 5.0;
    _wvIntroduce.backgroundColor = [UIColor whiteColor];
    _wvIntroduce.clipsToBounds = YES;
    _wvIntroduce.delegate = self;
    
    //  waiting loading
    [icWaiting mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_wvIntroduce.mas_centerX);
        make.centerY.equalTo(_wvIntroduce.mas_centerY);
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
        if ([[webView.request.URL absoluteString] isEqualToString: link_introduce]) {
            _wvIntroduce.hidden = NO;
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
