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
@synthesize wvContent, icWaiting;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [WriteLogsUtils writeForGoToScreen:@"iPadPolicyViewController"];
    
    self.title = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Privacy Policy"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    NSURL *nsurl = [NSURL URLWithString: link_policy];
    NSURLRequest *nsrequest = [NSURLRequest requestWithURL: nsurl];
    [wvContent loadRequest:nsrequest];
    
    icWaiting.hidden = NO;
    [icWaiting startAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUIForView {
    float tmpMargin = 15.0;
    [wvContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.view).offset(tmpMargin);
        make.bottom.right.equalTo(self.view).offset(-tmpMargin);
    }];
    wvContent.layer.borderColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                   blue:(200/255.0) alpha:1.0].CGColor;
    wvContent.layer.borderWidth = 1.0;
    wvContent.layer.cornerRadius = 5.0;
    wvContent.backgroundColor = [UIColor whiteColor];
    wvContent.delegate = self;
    
    [icWaiting mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(wvContent);
    }];
}

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
            wvContent.hidden = NO;
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
