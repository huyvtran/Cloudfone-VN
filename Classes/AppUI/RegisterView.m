//
//  RegisterView.m
//  linphone
//
//  Created by Ei Captain on 3/14/17.
//
//

#import "RegisterView.h"
#import "JSONKit.h"

@interface RegisterView (){
    float marginY;
    float hTextfield;
    float cbWidth;
    
    float hView;
    
    UIFont *textFont;
}

@end

@implementation RegisterView
@synthesize _scrollViewContent, _iconEmail, _tfEmail, _lbEmail, _lbBotEmail, _iconPhone, _tfPhone, _lbPhone, _lbBotPhone, _imgLogo, _icCheckBox, _lbAgree1, _lbAgree2, _lbAgree3, _btnLogin, _btnRegister, _lbHaveAccount, _iconFlag, _lbCode;
@synthesize waitingHud, _imgBackground;
@synthesize webService;

- (void)setupUIForView
{
    //  Init for webservice
    webService = [[WebServices alloc] init];
    webService.delegate = self;
    
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:HelveticaNeue size:18.0];
    }else{
        textFont = [UIFont fontWithName:HelveticaNeue size:18.0];
    }
    
    hView = self.frame.size.height;
    
    UITapGestureRecognizer *tapOnScreen = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTapOnScreen)];
    [self setUserInteractionEnabled: true];
    [self addGestureRecognizer: tapOnScreen];
    
    //  Add waiting view
    waitingHud = [[YBHud alloc] initWithHudType:DGActivityIndicatorAnimationTypeLineScale andText:@""];
    //  hud.tintColor = [UIColor colorWithRed:(24/255.0) green:(185/255.0) blue:(153/255.0) alpha:1.0];
    waitingHud.tintColor = [UIColor whiteColor];
    waitingHud.dimAmount = 0.5;
    
    marginY = 10.0;
    hTextfield = 35.0;
    cbWidth = 18.0;
    
    float bgHeight = _scrollViewContent.frame.size.width*417/1282;
    _imgBackground.frame = CGRectMake(0, SCREEN_HEIGHT-bgHeight, SCREEN_WIDTH, bgHeight);
    
    _scrollViewContent.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _scrollViewContent.showsVerticalScrollIndicator = NO;
    _scrollViewContent.showsHorizontalScrollIndicator = NO;
    
    //  Chia màn hình làm 3 phần bằng nhau
    float tmpHeight = (SCREEN_HEIGHT-20)/3;
    
    float logoWidth = SCREEN_WIDTH/3+30;
    _imgLogo.frame = CGRectMake((_scrollViewContent.frame.size.width-logoWidth)/2, 0, logoWidth, logoWidth);
    
    float tmpWidth = (_scrollViewContent.frame.size.width/10);
    
    //  Chiều cao view chính giữa
    float tmpY = (tmpHeight - 3*hTextfield)/4;
    
    //  Email
    _iconEmail.frame = CGRectMake(tmpWidth+5, tmpHeight+tmpY+hTextfield/4, hTextfield/2, hTextfield/2);
    _tfEmail.frame = CGRectMake(_iconEmail.frame.origin.x+_iconEmail.frame.size.width+5, tmpHeight+tmpY, SCREEN_WIDTH-2*tmpWidth-(_iconEmail.frame.size.width+5), hTextfield);
    _tfEmail.keyboardType = UIKeyboardTypeEmailAddress;
    _tfEmail.borderStyle = UITextBorderStyleNone;
    _tfEmail.font = textFont;
    [_tfEmail addTarget:self
                    action:@selector(onTextFieldDidChanged:)
          forControlEvents:UIControlEventEditingChanged];
    
    _lbBotEmail.frame = CGRectMake(tmpWidth, _tfEmail.frame.origin.y+hTextfield, SCREEN_WIDTH-2*tmpWidth, 1);
    _lbBotEmail.backgroundColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                   blue:(200/255.0) alpha:1.0];
    _lbEmail.frame = _tfEmail.frame;
    _lbEmail.font = textFont;
    _lbEmail.backgroundColor = UIColor.clearColor;
    _lbEmail.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_email];
    
    //  Phone
    _iconPhone.frame = CGRectMake(_iconEmail.frame.origin.x, _tfEmail.frame.origin.y+hTextfield+tmpY+hTextfield/4, hTextfield/2, hTextfield/2);
    _iconFlag.frame = CGRectMake(_iconPhone.frame.origin.x+_iconPhone.frame.size.width+5, _tfEmail.frame.origin.y+hTextfield+tmpY+hTextfield/4, hTextfield/2, hTextfield/2);
    _lbCode.frame = CGRectMake(_iconFlag.frame.origin.x+_iconFlag.frame.size.width+5, _iconFlag.frame.origin.y, 40, _iconFlag.frame.size.height);
    _lbCode.text = @"+84";
    _lbCode.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:13.0];
    
    _tfPhone.frame = CGRectMake(_lbCode.frame.origin.x+_lbCode.frame.size.width+5, _tfEmail.frame.origin.y+hTextfield+tmpY, SCREEN_WIDTH-(tmpWidth+_lbCode.frame.origin.x+_lbCode.frame.size.width+5), hTextfield);
    _tfPhone.keyboardType = UIKeyboardTypePhonePad;
    _tfPhone.borderStyle = UITextBorderStyleNone;
    _tfPhone.font = textFont;
    [_tfPhone addTarget:self
                 action:@selector(onTextFieldDidChanged:)
       forControlEvents:UIControlEventEditingChanged];
    
    _lbBotPhone.frame = CGRectMake(_lbBotEmail.frame.origin.x, _tfPhone.frame.origin.y+hTextfield, _lbBotEmail.frame.size.width, 1);
    _lbBotPhone.backgroundColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                   blue:(200/255.0) alpha:1.0];
    _lbPhone.frame = _tfPhone.frame;
    _lbPhone.backgroundColor = UIColor.clearColor;
    _lbPhone.font = textFont;
    _lbPhone.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_phone];
    
    //  agree
    _icCheckBox.frame = CGRectMake(_lbBotPhone.frame.origin.x, _lbBotPhone.frame.origin.y+_lbBotPhone.frame.size.height+tmpY+(hTextfield-cbWidth)/2, cbWidth, cbWidth);
    _icCheckBox.lineWidth = 1.0;
    _icCheckBox.boxType = BEMBoxTypeSquare;
    _icCheckBox.onAnimationType = BEMAnimationTypeStroke;
    _icCheckBox.offAnimationType = BEMAnimationTypeStroke;
    _icCheckBox.tintColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0)
                                             blue:(220/255.0) alpha:1.0];
    _icCheckBox.onTintColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0)
                                               blue:(220/255.0) alpha:1.0];
    _icCheckBox.onFillColor = [UIColor colorWithRed:(119/255.0) green:(212/255.0)
                                               blue:(194/255.0) alpha:1.0];
    _icCheckBox.onCheckColor = UIColor.whiteColor;
    [_icCheckBox setOn:false animated: true];
    
    //  agree 1
    _lbAgree1.font = [UIFont fontWithName:HelveticaNeue size:14.0];
    _lbAgree1.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_agree_1];
    [_lbAgree1 sizeToFit];
    
    UITapGestureRecognizer *tapOnAgree1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTapOnAgree1)];
    _lbAgree1.userInteractionEnabled = YES;
    [_lbAgree1 addGestureRecognizer: tapOnAgree1];
    _lbAgree1.frame = CGRectMake(_icCheckBox.frame.origin.x+cbWidth+5, _lbBotPhone.frame.origin.y+_lbBotPhone.frame.size.height+tmpY, _lbAgree1.frame.size.width, hTextfield);
    
    //  agree 2
    _lbAgree2.font = [UIFont fontWithName:HelveticaNeue size:14.0];
    _lbAgree2.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_agree_2];
    [_lbAgree2 sizeToFit];
    _lbAgree2.frame = CGRectMake(_lbAgree1.frame.origin.x+_lbAgree1.frame.size.width+5, _lbAgree1.frame.origin.y, _lbAgree2.frame.size.width, _lbAgree1.frame.size.height);
    
    UITapGestureRecognizer *tapOnAgree2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTapOnAgree2)];
    _lbAgree2.userInteractionEnabled = YES;
    [_lbAgree2 addGestureRecognizer: tapOnAgree2];
    
    //  agree 3
    _lbAgree3.font = [UIFont fontWithName:HelveticaNeue size:14.0];
    _lbAgree3.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_agree_3];
    [_lbAgree3 sizeToFit];
    _lbAgree3.frame = CGRectMake(_lbAgree2.frame.origin.x+_lbAgree2.frame.size.width+5, _lbAgree2.frame.origin.y, _lbAgree3.frame.size.width, _lbAgree2.frame.size.height);
    
    UITapGestureRecognizer *tapOnAgree3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTapOnAgree3)];
    _lbAgree3.userInteractionEnabled = YES;
    [_lbAgree3 addGestureRecognizer: tapOnAgree3];
    
    //  button sign in
    float tmpY2 = (tmpHeight - (hTextfield+10) - hTextfield)/3;
    
    _btnRegister.frame = CGRectMake(tmpWidth, 2*tmpHeight+tmpY2, SCREEN_WIDTH-2*tmpWidth, hTextfield+10);
    [_btnRegister setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _btnRegister.layer.cornerRadius = (hTextfield+10)/2;
    
    if (SCREEN_WIDTH > 320) {
        _btnRegister.titleLabel.font = [UIFont fontWithName:HelveticaNeue size:20.0];
    }else{
        _btnRegister.titleLabel.font = [UIFont fontWithName:HelveticaNeue size:18.0];
    }
    _btnRegister.backgroundColor = [UIColor colorWithRed:(0/255.0) green:(188/255.0)
                                                    blue:(157/255.0) alpha:1.0];
    _btnRegister.layer.borderWidth = 1.0;
    _btnRegister.layer.borderColor = [UIColor colorWithRed:(0/255.0) green:(188/255.0)
                                                      blue:(157/255.0) alpha:1.0].CGColor;
    [_btnRegister setTitle:[[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_sign_up] capitalizedString]
                  forState:UIControlStateNormal];
    [_btnRegister addTarget:self
                     action:@selector(btnRegisterTouchDown:)
           forControlEvents:UIControlEventTouchDown];
    
    //  have account
    CGSize sizeHaveAcc = [AppUtils getSizeWithText:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_have_account]
                                              withFont:textFont];
    CGSize sizeSignIn = [AppUtils getSizeWithText:[[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_sign_in]
                                                       uppercaseString] withFont:textFont];
    _lbHaveAccount.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_have_account];
    _lbHaveAccount.font = textFont;
    _lbHaveAccount.frame = CGRectMake((SCREEN_WIDTH-(sizeHaveAcc.width+5+sizeSignIn.width))/2, _btnRegister.frame.origin.y+_btnRegister.frame.size.height+tmpY2, sizeHaveAcc.width, hTextfield);
    
    _btnLogin.frame = CGRectMake(_lbHaveAccount.frame.origin.x+sizeHaveAcc.width+5, _lbHaveAccount.frame.origin.y, sizeSignIn.width, hTextfield);
    [_btnLogin setTitle:[[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_sign_in] uppercaseString]
               forState:UIControlStateNormal];
    _btnLogin.titleLabel.font = textFont;
    
    _scrollViewContent.contentSize = CGSizeMake(0, hView);
}

- (void)btnRegisterTouchDown: (UIButton *)sender {
    sender.backgroundColor = UIColor.clearColor;
    [sender setTitleColor:[UIColor colorWithRed:(0/255.0) green:(188/255.0)
                                           blue:(157/255.0) alpha:1.0]
                 forState:UIControlStateNormal];
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self
                                   selector:@selector(btnRegisterPressed)
                                   userInfo:nil repeats:false];
}

- (void)btnRegisterPressed {
    _btnRegister.backgroundColor = [UIColor colorWithRed:(0/255.0) green:(188/255.0)
                                                    blue:(157/255.0) alpha:1.0];
    [_btnRegister setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self endEditing: true];
    
    if ([_tfEmail.text isEqualToString: @""]) {
        [self makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_email_empty]
               duration:2.0 position:CSToastPositionCenter];
    }else if ([_tfPhone.text isEqualToString: @""]){
        [self makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_phone_empty]
               duration:2.0 position:CSToastPositionCenter];
    }else{
        BOOL isEmail = [self checkEmailValid: _tfEmail.text];
        if (!isEmail) {
            [self makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_email_invalid]
                   duration:2.0 position:CSToastPositionCenter];
        }else{
            BOOL isPhone = [self checkPhoneNumberValid: _tfPhone.text];
            if (!isPhone) {
                [self makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_phone_invalid]
                       duration:2.0 position:CSToastPositionCenter];
            }else{
                if (!_icCheckBox.on) {
                    [self makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_accept_terms]
                           duration:2.0 position:CSToastPositionCenter];
                }else{
                    [waitingHud showInView:self animated:YES];
                    
                    NSString *randomKey = [AppUtils randomStringWithLength:10];
                    //  Lưu random key cho step 2
                    [[NSUserDefaults standardUserDefaults] setObject:randomKey forKey:random_key_register];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                     
                    [self registerWithEmail:_tfEmail.text andPhone:_tfPhone.text withRandomKey:randomKey];
                }
            }
        }
    }
}

- (IBAction)_btnRegisterPressed:(UIButton *)sender
{

}

- (IBAction)_btnLoginPressed:(UIButton *)sender {
    
}

//  Kiểm tra số điện thoại có đúng định dạng không?
- (BOOL)checkPhoneNumberValid: (NSString *)phoneNumber {
    if (phoneNumber.length < 10) {
        return false;
    }else{
        return true;
    }
}

- (BOOL)checkEmailValid:(NSString *)email {
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

//  Nhập vào textfield
- (void)onTextFieldDidChanged: (UITextField *)textfield {
    if (textfield == _tfEmail) {
        if ([textfield.text isEqualToString: @""]) {
            _lbEmail.hidden = NO;
        }else{
            _lbEmail.hidden = YES;
        }
    }else if (textfield == _tfPhone){
        if ([textfield.text isEqualToString: @""]) {
            _lbPhone.hidden = YES;
        }else{
            _lbPhone.hidden = YES;
        }
    }
}

//  Tap trên màn hình để close keyboard
- (void)whenTapOnScreen {
    [self endEditing: true];
}

- (void)whenTapOnAgree1 {
    if (_icCheckBox.on) {
        [_icCheckBox setOn:false animated:true];
    }else{
        [_icCheckBox setOn:true animated:true];
    }
}

- (void)whenTapOnAgree2 {
    PrivacyPopupView *privacyPopupView = [[PrivacyPopupView alloc] initWithFrame:CGRectMake(20, 60, SCREEN_WIDTH-40, SCREEN_HEIGHT-120)];
    [privacyPopupView showInView:[LinphoneAppDelegate sharedInstance].window animated:true];
}

- (void)whenTapOnAgree3 {
    if (_icCheckBox.on) {
        [_icCheckBox setOn:false animated:true];
    }else{
        [_icCheckBox setOn:true animated:true];
    }
}

#pragma mark - API

- (void)registerWithEmail: (NSString *)email andPhone: (NSString *)phone withRandomKey: (NSString *)randomKey
{
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:AuthUser forKey:@"AuthUser"];
    [jsonDict setObject:AuthKey forKey:@"AuthKey"];
    [jsonDict setObject:randomKey forKey:@"RandomString"];
    [jsonDict setObject:email forKey:@"Email"];
    [jsonDict setObject:phone forKey:@"Phone"];
    
    [webService callWebServiceWithLink:createRequestFunc withParams:jsonDict];
}

#pragma mark - Web services delegate
- (void)failedToCallWebService:(NSString *)link andError:(NSString *)error {
    if ([link isEqualToString:createRequestFunc]) {
        [waitingHud dismissAnimated:YES];
        [self makeToast:error duration:3.0 position:CSToastPositionCenter];
    }
}

- (void)successfulToCallWebService:(NSString *)link withData:(NSDictionary *)data {
    if ([link isEqualToString:createRequestFunc]) {
        NSString *hashString = [data objectForKey:@"hashString"];
        if (![hashString isKindOfClass:[NSNull class]] && hashString != nil) {
            [[NSUserDefaults standardUserDefaults] setObject:hashString forKey:hash_register];
            
            NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:timeInSeconds]
                                                      forKey:time_register_expire];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:showConfirmCodeView object:nil];
        }else{
            [self makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_default_error]
                   duration:1.5 position:CSToastPositionCenter];
        }
    }
}

- (void)receivedResponeCode:(NSString *)link withCode:(int)responeCode {
    
}

@end
