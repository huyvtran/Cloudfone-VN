//
//  ManagerPasswordViewController.m
//  linphone
//
//  Created by admin on 9/30/18.
//

#import "ManagerPasswordViewController.h"
#import <CommonCrypto/CommonDigest.h>

@interface ManagerPasswordViewController (){
    LinphoneAppDelegate *appDelegate;
    WebServices *webService;
}

@end

@implementation NSString (MD5)
- (NSString *)MD5String {
    const char *cstr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, (int)strlen(cstr), result);
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}
@end

@implementation ManagerPasswordViewController
@synthesize _viewHeader, bgHeader, _icBack, _lbHeader;
@synthesize _viewContent, _lbPassword, _tfPassword, _lbNewPassword, _tfNewPassword, _lbConfirmPassword, _tfConfirmPassword, _lbPasswordDesc, _btnCancel, _btnSave, _icWaiting;

#pragma mark - UICompositeViewDelegate Functions
static UICompositeViewDescription *compositeDescription = nil;
+ (UICompositeViewDescription *)compositeViewDescription {
    if (compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:nil
                                                                 tabBar:nil
                                                               sideMenu:nil
                                                             fullscreen:FALSE
                                                         isLeftFragment:YES
                                                           fragmentWith:0];
        //        compositeDescription.darkBackground = true;
    }
    return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
    return self.class.compositeViewDescription;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    webService = [[WebServices alloc] init];
    webService.delegate = self;
    
    appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self autoLayoutForMainView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    _icWaiting.hidden = YES;
    [self showContentForView];
}

- (void)viewDidLayoutSubviews {
    float height = _btnCancel.frame.origin.y + _btnCancel.frame.size.height + 15.0;
    [_viewContent mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)_icBackClicked:(UIButton *)sender {
    [[PhoneMainView instance] popCurrentView];
}

- (IBAction)_btnCancelPressed:(UIButton *)sender {
    [self.view endEditing: YES];
    _tfPassword.text = @"";
    _tfNewPassword.text = @"";
    _tfConfirmPassword.text = @"";
}

- (IBAction)_btnSavePressed:(UIButton *)sender {
    [self.view endEditing: YES];
    if ([_tfPassword.text isEqualToString:@""]) {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Current password can not empty"] duration:2.0 position:CSToastPositionCenter];
    }else if ([_tfNewPassword.text isEqualToString:@""]){
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"New password can not empty"] duration:2.0 position:CSToastPositionCenter];
    }else if ([_tfConfirmPassword.text isEqualToString:@""]){
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Confirm password can not empty"] duration:2.0 position:CSToastPositionCenter];
    }else if (![_tfConfirmPassword.text isEqualToString:_tfNewPassword.text]){
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Confirm password not match"] duration:2.0 position:CSToastPositionCenter];
    }else if (![_tfPassword.text isEqualToString:PASSWORD]){
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Current password not correct"] duration:2.0 position:CSToastPositionCenter];
    }else{
        _icWaiting.hidden = NO;
        [_icWaiting startAnimating];
        
        [self startChangePasswordForUser: _tfNewPassword.text];
    }
}

- (void)autoLayoutForMainView {
    float marginX = 20.0;
    
    self.view.backgroundColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0)
                                                 blue:(235/255.0) alpha:1.0];
    
    _icWaiting.backgroundColor = UIColor.whiteColor;
    _icWaiting.alpha = 0.5;
    [_icWaiting mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    
    
    //  Header view
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
    
    [_icBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewHeader);
        make.centerY.equalTo(_lbHeader.mas_centerY);
        make.width.height.mas_equalTo(35.0);
    }];
    
    //  content view
    _viewContent.backgroundColor = UIColor.whiteColor;
    [_viewContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader.mas_bottom);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(0);
    }];
    
    _lbPassword.textColor = UIColor.darkGrayColor;
    [_lbPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewContent).offset(10);
        make.left.equalTo(_viewContent).offset(marginX);
        make.right.equalTo(_viewContent).offset(-marginX);
        make.height.mas_equalTo(35.0);
    }];
    
    [_tfPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lbPassword.mas_bottom);
        make.left.right.equalTo(_lbPassword);
        make.height.mas_equalTo(35.0);
    }];
    
    _lbNewPassword.textColor = UIColor.darkGrayColor;
    [_lbNewPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_tfPassword.mas_bottom).offset(15);
        make.left.right.equalTo(_lbPassword);
        make.height.equalTo(_lbPassword.mas_height);
    }];
    
    [_tfNewPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lbNewPassword.mas_bottom);
        make.left.right.equalTo(_lbNewPassword);
        make.height.equalTo(_tfPassword.mas_height);
    }];
    
    _lbConfirmPassword.textColor = UIColor.darkGrayColor;
    [_lbConfirmPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_tfNewPassword.mas_bottom).offset(15);
        make.left.right.equalTo(_tfNewPassword);
        make.height.equalTo(_lbPassword.mas_height);
    }];
    
    [_tfConfirmPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lbConfirmPassword.mas_bottom);
        make.left.right.equalTo(_lbConfirmPassword);
        make.height.equalTo(_tfNewPassword.mas_height);
    }];
    
    [_lbPasswordDesc mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_tfConfirmPassword.mas_bottom);
        make.left.right.equalTo(_tfConfirmPassword);
        make.height.equalTo(_lbConfirmPassword.mas_height);
    }];
    
    //  footer button
    [_btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lbPasswordDesc.mas_bottom).offset(35);
        make.left.equalTo(_lbPasswordDesc);
        make.right.equalTo(_viewContent.mas_centerX).offset(-20);
        make.height.mas_equalTo(45.0);
    }];
    
    _btnCancel.layer.cornerRadius = 45.0/2;
    [_btnCancel setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _btnCancel.titleLabel.font = [UIFont systemFontOfSize: 16.0];
    _btnCancel.backgroundColor = [UIColor colorWithRed:(248/255.0) green:(83/255.0)
                                                 blue:(86/255.0) alpha:1.0];
    
    [_btnSave mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_btnCancel);
        make.left.equalTo(_viewContent.mas_centerX).offset(20);
        make.right.equalTo(_tfConfirmPassword.mas_right);
        make.height.mas_equalTo(_btnCancel.mas_height);
    }];
    _btnSave.layer.cornerRadius = 45.0/2;
    [_btnSave setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _btnSave.titleLabel.font = [UIFont systemFontOfSize: 16.0];
    _btnSave.backgroundColor = [UIColor colorWithRed:(25/255.0) green:(86/255.0)
                                                blue:(108/255.0) alpha:1.0];
    
}

- (void)showContentForView {
    _lbHeader.text = [appDelegate.localization localizedStringForKey:@"Change password"];
    _lbPassword.text = [appDelegate.localization localizedStringForKey:@"Current password"];
    _lbNewPassword.text = [appDelegate.localization localizedStringForKey:@"New password"];
    _lbConfirmPassword.text = [appDelegate.localization localizedStringForKey:@"Confirm password"];
    _lbPasswordDesc.text = [appDelegate.localization localizedStringForKey:@"Password are at least 6 characters long"];
    
    [_btnCancel setTitle:[appDelegate.localization localizedStringForKey:@"Clear"]
               forState:UIControlStateNormal];
    [_btnSave setTitle:[appDelegate.localization localizedStringForKey:@"Save"]
              forState:UIControlStateNormal];
}

- (void)startChangePasswordForUser: (NSString *)password
{
    NSString *requestString = [AppUtils randomStringWithLength: 10];
    NSString *totalString = [NSString stringWithFormat:@"%@%@%@", PASSWORD, requestString, USERNAME];
    
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:AuthUser forKey:@"AuthUser"];
    [jsonDict setObject:AuthKey forKey:@"AuthKey"];
    [jsonDict setObject:requestString forKey:@"RequestString"];
    [jsonDict setObject:USERNAME forKey:@"LoginUser"];
    [jsonDict setObject:[[totalString MD5String] lowercaseString] forKey:@"MD5String"];
    [jsonDict setObject:password forKey:@"NewPassword"];
    
    [webService callWebServiceWithLink:changePasswordFunc withParams:jsonDict];
}

#pragma mark - Webservice Delegate

- (void)failedToCallWebService:(NSString *)link andError:(NSString *)error {
    [_icWaiting stopAnimating];
    _icWaiting.hidden = YES;
    [self.view makeToast:error duration:2.0 position:CSToastPositionCenter];
}

- (void)successfulToCallWebService:(NSString *)link withData:(NSDictionary *)data {
    if ([link isEqualToString:changePasswordFunc]) {
        if ([data isKindOfClass:[NSString class]]) {
            [[NSUserDefaults standardUserDefaults] setObject:_tfNewPassword.text forKey:key_password];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [_icWaiting stopAnimating];
            _icWaiting.hidden = YES;
            [self.view makeToast:(NSString *)data duration:2.0 position:CSToastPositionCenter];
        }
    }
}

- (void)receivedResponeCode:(NSString *)link withCode:(int)responeCode {
    NSLog(@"%d", responeCode);
}

@end
