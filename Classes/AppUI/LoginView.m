//
//  LoginView.m
//  linphone
//
//  Created by Hung Ho on 7/4/17.
//
//

#import "LoginView.h"
#import "JSONKit.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSDatabase.h"

@interface LoginView (){
    UIFont *textFont;
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

@implementation LoginView
@synthesize _viewContent, _imgLogo, _imgBackground, _lbWelcome, _btnSignIn, _lbSepa, _btnSignUp;
@synthesize _viewSignIn, _viewRegister, _viewConfirm, _viewResetPassword;
@synthesize webService, delegate;

- (void)setupUIForView
{
    //  Init for webservice
    webService = [[WebServices alloc] init];
    webService.delegate = self;
    
    _viewContent.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    float originX = SCREEN_WIDTH/4;
    _imgLogo.frame = CGRectMake(originX, originX/3, SCREEN_WIDTH/2, SCREEN_WIDTH/2);
    _lbWelcome.frame = CGRectMake(_imgLogo.frame.origin.x, _imgLogo.frame.origin.y+_imgLogo.frame.size.height, _imgLogo.frame.size.width, 50);
    _lbWelcome.font = [UIFont fontWithName:HelveticaNeueThin size:35.0];
    
    float bgHeight = SCREEN_WIDTH*417/1282;
    _imgBackground.frame = CGRectMake(0, SCREEN_HEIGHT-bgHeight, SCREEN_WIDTH, bgHeight);
    
    textFont = [UIFont fontWithName:HelveticaNeue size:18.0];
    
    CGSize signInSize = [AppUtils getSizeWithText:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_sign_in]
                                             withFont:textFont];
    CGSize signUpSize = [AppUtils getSizeWithText:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_sign_up] withFont:textFont];
    
    float marginX = (SCREEN_WIDTH - (signInSize.width+20 + signUpSize.width+20 + 1 + 40))/2;
    _btnSignIn.frame = CGRectMake(marginX, _imgBackground.frame.origin.y+20, signInSize.width+20, 35);
    [_btnSignIn setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_sign_in] forState:UIControlStateNormal];
    _btnSignIn.titleLabel.font = textFont;
    
    _lbSepa.frame = CGRectMake(_btnSignIn.frame.origin.x+_btnSignIn.frame.size.width+20, _btnSignIn.frame.origin.y, 1, _btnSignIn.frame.size.height);
    _btnSignUp.frame = CGRectMake(_lbSepa.frame.origin.x+_lbSepa.frame.size.width+20, _btnSignIn.frame.origin.y, signUpSize.width+20, _btnSignIn.frame.size.height);
    [_btnSignUp setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_sign_up] forState:UIControlStateNormal];
    _btnSignUp.titleLabel.font = textFont;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(funcCloseViewResetPassword)
                                                 name:closeViewResetPassword object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetPasswordSuccesfully:)
                                                 name:resetPasswordSucces object:nil];
}

- (IBAction)_btnSignInPressed:(UIButton *)sender {
    [self endEditing: YES];
    _viewContent.hidden = YES;
    
    [sender setTitleColor:[UIColor colorWithRed:(0/255.0) green:(173/255.0)
                                           blue:(142/255.0) alpha:1.0]
                 forState:UIControlStateNormal];
    if (_viewSignIn == nil) {
        [self addViewSignInForMainView];
        [_viewSignIn._btnSignIn addTarget:self
                                  action:@selector(btnSignPressed:)
                        forControlEvents:UIControlEventTouchUpInside];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        _viewSignIn.alpha = 1.0;
    }];
    
    //  Add new by Khai Le on 03/07/2018
    if (_viewSignIn._tfUsername.text.length == 0) {
        NSString *userId = [NSDatabase getUserAccountForLastLogin];
        _viewSignIn._tfUsername.text = userId;
        if ([userId isEqualToString:@""]) {
            _viewSignIn._lbUsername.hidden = NO;
        }else{
            _viewSignIn._lbUsername.hidden = YES;
        }
    }
}

- (IBAction)_btnSignUpPressed:(UIButton *)sender {
    [self endEditing: YES];
    _viewContent.hidden = YES;
    
    [sender setTitleColor:[UIColor colorWithRed:(0/255.0) green:(173/255.0)
                                           blue:(142/255.0) alpha:1.0]
                 forState:UIControlStateNormal];
    
    if (_viewRegister == nil) {
        [self addViewRegisterForMainView];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        _viewSignIn.alpha = 0.0;
        _viewRegister.alpha = 1.0;
    }];
}

- (void)updateBackgroundButton {
    [_viewSignIn._btnSignIn setTitleColor:[UIColor colorWithRed:(50/255.0) green:(50/255.0)
                                                           blue:(50/255.0) alpha:1.0]
                                 forState:UIControlStateNormal];
    [_viewSignIn._btnSignIn setBackgroundColor:[UIColor colorWithRed:(0/255.0) green:(188/255.0)
                                                                blue:(157/255.0) alpha:1.0]];
}

- (void)btnSignPressed: (UIButton *)sender {
    sender.backgroundColor = UIColor.clearColor;
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self
                                   selector:@selector(updateBackgroundButton)
                                   userInfo:nil repeats:false];
    [self endEditing: true];
    
    NSString *userName = _viewSignIn._tfUsername.text;
    NSString *passord = _viewSignIn._tfPassword.text;
    
    if ([userName isEqualToString: @""]) {
        [self makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_username_empty]
               duration:2.0 position:CSToastPositionCenter];
    }else if ([passord isEqualToString:@""]){
        [self makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_password_empty]
               duration:2.0 position:CSToastPositionCenter];
    }else{
        if (![LinphoneAppDelegate sharedInstance]._internetActive) {
            [self makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_no_internet]
                   duration:2.0 position:CSToastPositionCenter];
        }else{
            [_viewSignIn.waitingHud showInView:_viewSignIn animated:YES];
            
            [self getLoginInforWithUsername:_viewSignIn._tfUsername.text password:_viewSignIn._tfPassword.text];
        }
    }
}

//  Thêm view SignIn vào màn hình
- (void)addViewSignInForMainView {
    NSArray *toplevelObject = [[NSBundle mainBundle] loadNibNamed:@"SignInView" owner:nil options:nil];
    for(id currentObject in toplevelObject){
        if ([currentObject isKindOfClass:[SignInView class]]) {
            _viewSignIn = (SignInView *) currentObject;
            break;
        }
    }
    [_viewSignIn._btnSignUp addTarget:self
                              action:@selector(goToRegisterViewFromSignIn)
                    forControlEvents:UIControlEventTouchUpInside];
    
    [_viewSignIn._btnForgotPassword addTarget:self
                                      action:@selector(_btnForgotPassPressed:)
                            forControlEvents:UIControlEventTouchUpInside];
    _viewSignIn.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [_viewSignIn setupUIForView];
    _viewSignIn.alpha = 0.0;
    [self addSubview: _viewSignIn];
}

//  Thêm view đăng ký vào màn hình
- (void)addViewRegisterForMainView {
    NSArray *toplevelObject = [[NSBundle mainBundle] loadNibNamed:@"RegisterView" owner:nil options:nil];
    for(id currentObject in toplevelObject){
        if ([currentObject isKindOfClass:[RegisterView class]]) {
            _viewRegister = (RegisterView *) currentObject;
            break;
        }
    }
    [_viewRegister._btnLogin addTarget:self
                               action:@selector(showViewSignIn)
                     forControlEvents:UIControlEventTouchUpInside];
    _viewRegister.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [_viewRegister setupUIForView];
    _viewRegister.alpha = 0.0;
    [self addSubview: _viewRegister];
    
    //  Thêm view confirm code
    if (_viewConfirm == nil) {
        NSArray *toplevelObject = [[NSBundle mainBundle] loadNibNamed:@"ConfirmView" owner:nil options:nil];
        for(id currentObject in toplevelObject){
            if ([currentObject isKindOfClass:[ConfirmView class]]) {
                _viewConfirm = (ConfirmView *) currentObject;
                break;
            }
        }
        _viewConfirm.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [_viewConfirm setupUIForView];
        _viewConfirm.alpha = 0.0;
        [self addSubview: _viewConfirm];
    }
}

//  Hiển thị view đăng ký
- (void)goToRegisterViewFromSignIn {
    [self endEditing: TRUE];
    
    if (_viewRegister == nil) {
        [self addViewRegisterForMainView];
    }
    [UIView animateWithDuration:0.3 animations:^{
        _viewSignIn.alpha = 0.0;
        _viewRegister.alpha = 1.0;
    }];
}

//  Hiển thị view đăng nhập
- (void)showViewSignIn {
    [self endEditing: TRUE];
    
    if (_viewSignIn == nil) {
        [self addViewSignInForMainView];
        [_viewSignIn._btnSignIn addTarget:self
                                  action:@selector(btnSignPressed:)
                        forControlEvents:UIControlEventTouchUpInside];
    }
    [UIView animateWithDuration:0.3 animations:^{
        _viewSignIn.alpha = 1.0;
        _viewRegister.alpha = 0.0;
    }];
}

- (void)_btnForgotPassPressed: (UIButton *)sender {
    [self endEditing: true];
    
    if (_viewResetPassword == nil) {
        [self addViewForgotPasswordForMainView];
    }
    _viewResetPassword._tfAccount.text = @"";
    _viewResetPassword._lbAccount.hidden = NO;
    
    if (_viewResetPassword.frame.size.height == 0) {
        [UIView animateWithDuration:0.3 animations:^{
            _viewResetPassword.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            _viewResetPassword.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 0);
        }];
    }
}

//  Thêm view SignIn vào màn hình
- (void)addViewForgotPasswordForMainView {
    NSArray *toplevelObject = [[NSBundle mainBundle] loadNibNamed:@"ResetPasswordView" owner:nil options:nil];
    for(id currentObject in toplevelObject){
        if ([currentObject isKindOfClass:[ResetPasswordView class]]) {
            _viewResetPassword = (ResetPasswordView *) currentObject;
            break;
        }
    }
    [_viewResetPassword._iconClose addTarget:self
                                     action:@selector(funcCloseViewResetPassword)
                           forControlEvents:UIControlEventTouchUpInside];
    _viewResetPassword.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 0);
    [_viewResetPassword setupUIForView];
    [self addSubview: _viewResetPassword];
}

- (void)funcCloseViewResetPassword {
    [self endEditing: true];
    [UIView animateWithDuration:0.3 animations:^{
        _viewResetPassword.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 0);
        _viewResetPassword.viewConfirmResetPass.alpha = 0.0;
    }];
}

//  reset password thanh cong
- (void)resetPasswordSuccesfully: (NSNotification *)notif {
    [self funcCloseViewResetPassword];
    
    id object = [notif object];
    if ([object isKindOfClass:[NSString class]]) {
        [self makeToast:@"Đặt mật khẩu thành công! Vui lòng kiểm tra email của bạn."
               duration:3.0 position:CSToastPositionCenter];
    }
}

#pragma mark - API

- (void)getLoginInforWithUsername: (NSString *)username password: (NSString *)password {
    NSString *requestString = [AppUtils randomStringWithLength: 10];
    NSString *totalStr = [NSString stringWithFormat:@"%@%@%@", password, requestString, username];
    NSString *md5String = [[totalStr MD5String] lowercaseString];
    
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:AuthUser forKey:@"AuthUser"];
    [jsonDict setObject:AuthKey forKey:@"AuthKey"];
    [jsonDict setObject:requestString forKey:@"RequestString"];
    [jsonDict setObject:username forKey:@"LoginUser"];
    [jsonDict setObject:md5String forKey:@"MD5String"];
    
    [webService callWebServiceWithLink:getLoginInfoFunc withParams:jsonDict];
}

#pragma mark - Web services delegate
- (void)failedToCallWebService:(NSString *)link andError:(NSString *)error {
    [_viewSignIn.waitingHud dismissAnimated:YES];
    if ([link isEqualToString:getLoginInfoFunc]) {
        [self makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:not_connect_to_server]
               duration:3.0 position:CSToastPositionCenter];
    }
}

- (void)successfulToCallWebService:(NSString *)link withData:(NSDictionary *)data {
    [_viewSignIn.waitingHud dismissAnimated:YES];
    if ([link isEqualToString:getLoginInfoFunc]) {
        [delegate loginToSipWithInfo: data];
    }
}

- (void)receivedResponeCode:(NSString *)link withCode:(int)responeCode {
    NSLog(@"%d", responeCode);
}

@end
