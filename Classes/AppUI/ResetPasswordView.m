//
//  ResetPasswordView.m
//  linphone
//
//  Created by Apple on 5/8/17.
//
//

#import "ResetPasswordView.h"
#import "JSONKit.h"
#import <CommonCrypto/CommonDigest.h>

@interface ResetPasswordView (){
    NSString *randomString;
    NSString *hashString;
    
    UIFont *textFont;
    WebServices *webService;
    YBHud *waitingHud;
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

@implementation ResetPasswordView
@synthesize _imgBackground, _scrollViewContent, _iconClose, _imgLogo, _tfAccount, _lbAccount, _iconAccont, _lbBotAccount, _btnResetPassword, viewConfirmResetPass;

- (void)setupUIForView
{
    //  add waiting view
    waitingHud = [[YBHud alloc] initWithHudType:DGActivityIndicatorAnimationTypeLineScale andText:@""];
    waitingHud.tintColor = [UIColor whiteColor];
    waitingHud.dimAmount = 0.5;
    
    [self setClipsToBounds: true];
    
    webService = [[WebServices alloc] init];
    webService.delegate = self;
    
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:HelveticaNeue size:18.0];
    }else{
        textFont = [UIFont fontWithName:HelveticaNeue size:15.0];
    }
    
    float bgHeight = SCREEN_WIDTH*417/1282;
    _imgBackground.frame = CGRectMake(0, SCREEN_HEIGHT-bgHeight, SCREEN_WIDTH, bgHeight);
    
    //  scrollview content
    _scrollViewContent.frame = CGRectMake(0, 0, self.frame.size.width, SCREEN_HEIGHT);
    float wButton = 42.0;
    _iconClose.frame = CGRectMake(self.frame.size.width-5-wButton, 0, wButton, wButton);
    [_iconClose setBackgroundImage:[UIImage imageNamed:@"ic_remove_act.png"]
                          forState:UIControlStateHighlighted];
    
    float logoWidth = self.frame.size.width/2;
    _imgLogo.frame = CGRectMake((self.frame.size.width-logoWidth)/2, 0, logoWidth, logoWidth);
    
    float tmpWidth = 15.0;
    float hTextfield = 35.0;
    
    //  Account
    _tfAccount.frame = CGRectMake(tmpWidth, _imgLogo.frame.origin.y+_imgLogo.frame.size.height+20, self.frame.size.width-2*tmpWidth, hTextfield);
    _tfAccount.borderStyle = UITextBorderStyleNone;
    _tfAccount.font = textFont;
    [_tfAccount addTarget:self
                   action:@selector(onTextFieldDidChanged:)
         forControlEvents:UIControlEventEditingChanged];
    
    UIView *pAccount = [[UIView alloc] initWithFrame: CGRectMake(0, 0, hTextfield/2, hTextfield)];
    pAccount.backgroundColor = UIColor.clearColor;
    _tfAccount.leftView = pAccount;
    _tfAccount.leftViewMode = UITextFieldViewModeAlways;
    
    _lbBotAccount.frame = CGRectMake(_tfAccount.frame.origin.x, _tfAccount.frame.origin.y+hTextfield, _tfAccount.frame.size.width, 1);
    _lbBotAccount.backgroundColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                     blue:(200/255.0) alpha:1.0];
    
    _iconAccont.frame = CGRectMake(_tfAccount.frame.origin.x+5, _tfAccount.frame.origin.y+hTextfield/4, hTextfield/2, hTextfield/2);
    
    _lbAccount.frame = _tfAccount.frame;
    _lbAccount.font = textFont;
    _lbAccount.backgroundColor = UIColor.clearColor;
    _lbAccount.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_input_username];
    
    //  reset button
    _btnResetPassword.frame = CGRectMake(_tfAccount.frame.origin.x, _tfAccount.frame.origin.y+hTextfield+40, _tfAccount.frame.size.width, hTextfield+10);
    [_btnResetPassword setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _btnResetPassword.layer.cornerRadius = (hTextfield+10)/2;
    _btnResetPassword.titleLabel.font = textFont;
    [_btnResetPassword setBackgroundColor:[UIColor colorWithRed:(0/255.0) green:(188/255.0)
                                                      blue:(157/255.0) alpha:1.0]];
    _btnResetPassword.layer.borderWidth = 1.0;
    _btnResetPassword.layer.borderColor = [UIColor colorWithRed:(0/255.0) green:(188/255.0)
                                                           blue:(157/255.0) alpha:1.0].CGColor;
    [_btnResetPassword setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_reset_password]
                       forState:UIControlStateNormal];
    [_btnResetPassword addTarget:self
                          action:@selector(btnResetPasswordTouchDown:)
                forControlEvents:UIControlEventTouchDown];
    
    _scrollViewContent.contentSize = CGSizeMake(_scrollViewContent.frame.size.width, _btnResetPassword.frame.origin.y+_btnResetPassword.frame.size.height+20);
    
    UITapGestureRecognizer *tapClose = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTapToCloseKeyboard)];
    [_scrollViewContent addGestureRecognizer: tapClose];
    
    //
    [self addViewConfirmResetPassForMainView];
}

- (void)whenTapToCloseKeyboard {
    [self endEditing: true];
}

- (void)btnResetPasswordTouchDown: (UIButton *)sender {
    sender.backgroundColor = UIColor.clearColor;
    [sender setTitleColor:[UIColor colorWithRed:(0/255.0) green:(188/255.0)
                                           blue:(157/255.0) alpha:1.0]
                 forState:UIControlStateNormal];
}

//  Nhập vào textfield
- (void)onTextFieldDidChanged: (UITextField *)textfield {
    if (textfield == _tfAccount) {
        if ([textfield.text isEqualToString: @""]) {
            _lbAccount.hidden = NO;
        }else{
            _lbAccount.hidden = YES;
        }
    }
}

- (IBAction)_btnResetPasswordPressed:(UIButton *)sender {
    sender.backgroundColor = [UIColor colorWithRed:(0/255.0) green:(188/255.0)
                                              blue:(157/255.0) alpha:1.0];
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self endEditing: true];
    
    if ([_tfAccount.text isEqualToString: @""]) {
        [self makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_username_or_email_not_empty]
               duration:2.0 position:CSToastPositionCenter];
    }else{
        [waitingHud showInView:self animated:YES];
        
        randomString = [AppUtils randomStringWithLength: 10];
        hashString = @"";
        [self CreateRequestResetPasswordForLoginUser: _tfAccount.text];
    }
}

- (void)CreateRequestResetPasswordForLoginUser: (NSString *)LoginUser
{
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:AuthUser forKey:@"AuthUser"];
    [jsonDict setObject:AuthKey forKey:@"AuthKey"];
    [jsonDict setObject:randomString forKey:@"RandomString"];
    [jsonDict setObject:LoginUser forKey:@"LoginUser"];
    
    [webService callWebServiceWithLink:CreateRequestResetPassword withParams:jsonDict];
}

- (void)addViewConfirmResetPassForMainView {
    NSArray *toplevelObject = [[NSBundle mainBundle] loadNibNamed:@"ConfirmResetPasswordView" owner:nil options:nil];
    for(id currentObject in toplevelObject){
        if ([currentObject isKindOfClass:[ConfirmResetPasswordView class]]) {
            viewConfirmResetPass = (ConfirmResetPasswordView *) currentObject;
            break;
        }
    }
    [viewConfirmResetPass._iconClose addTarget:self
                                        action:@selector(funcCloseViewResetPassword)
                              forControlEvents:UIControlEventTouchUpInside];
    [viewConfirmResetPass setFrame: CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [viewConfirmResetPass setupUIForView];
    [viewConfirmResetPass setAlpha: 0.0];
    [viewConfirmResetPass._btnConfirmReset addTarget:self
                                              action:@selector(confirmResetPasswordPressed:)
                                    forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview: viewConfirmResetPass];
}

- (void)showConfirmResetPasswordView {
    if (viewConfirmResetPass == nil) {
        [self addViewConfirmResetPassForMainView];
    }
    [viewConfirmResetPass._tfConfirm setText: @""];
    
    [UIView animateWithDuration:0.3 animations:^{
        [viewConfirmResetPass setAlpha: 1.0];
    }];
}

- (void)funcCloseViewResetPassword {
    [[NSNotificationCenter defaultCenter] postNotificationName:closeViewResetPassword
                                                        object:nil];
}

/*
    "AuthUser" : "ddb7c103eb98",
	"AuthKey" : "2b909f73069e47dba6feddb7c103eb98",
	"HashString" : "SAD223sasd"
	"MD5String" : md5(RandomString + OTP)
*/

- (void)confirmResetPasswordPressed: (UIButton *)sender
{
    if ([viewConfirmResetPass._tfConfirm.text isEqualToString: @""]) {
        [viewConfirmResetPass._lbBotConfirm setBackgroundColor:[UIColor redColor]];
    }else{
        [viewConfirmResetPass._lbBotConfirm setBackgroundColor:[UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                                                blue:(200/255.0) alpha:1.0]];
        [self endEditing: true];
        [waitingHud showInView:self animated:YES];
        
        [self startConfirmResetPassword];
    }
}

- (void)startConfirmResetPassword
{
    NSString *MD5String = [NSString stringWithFormat:@"%@%@", randomString, viewConfirmResetPass._tfConfirm.text];
    NSString *totalMD5String = [[MD5String MD5String] lowercaseString];
    
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:AuthUser forKey:@"AuthUser"];
    [jsonDict setObject:AuthKey forKey:@"AuthKey"];
    [jsonDict setObject:hashString forKey:@"HashString"];
    [jsonDict setObject:totalMD5String forKey:@"MD5String"];
    
    [webService callWebServiceWithLink:ConfirmRequestResetPassword withParams:jsonDict];
}

#pragma mark - WebServices delegate
- (void)failedToCallWebService:(NSString *)link andError:(NSString *)error {
    if ([link isEqualToString:CreateRequestResetPassword]) {
        [self makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:can_not_reset_password]
               duration:2.0 position:CSToastPositionCenter];
    }else if ([link isEqualToString:ConfirmRequestResetPassword]){
        [self makeToast:error duration:2.0 position:CSToastPositionCenter];
    }
}

- (void)successfulToCallWebService:(NSString *)link withData:(NSDictionary *)data {
    if ([link isEqualToString:CreateRequestResetPassword]) {
        [waitingHud dismissAnimated: YES];
        
        NSString *hashStr = [data objectForKey:@"hashString"];
        if (hashStr != nil && ![hashStr isEqualToString: @""]) {
            hashString = hashStr;
            
            [self showConfirmResetPasswordView];
        }
    }else if ([link isEqualToString:ConfirmRequestResetPassword]){
        [waitingHud dismissAnimated:YES];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:resetPasswordSucces
                                                            object:nil];
    }
}

- (void)receivedResponeCode:(NSString *)link withCode:(int)responeCode {
    
}

@end
