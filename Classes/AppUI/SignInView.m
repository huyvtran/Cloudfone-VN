//
//  SignInView.m
//  linphone
//
//  Created by Ei Captain on 2/28/17.
//
//

#import "SignInView.h"

@interface SignInView (){
    float marginY;
    float hTextfield;
    UIFont *textFont;
}
@end

@implementation SignInView

@synthesize _imgBackground, _scrollViewContent, _imgLogo, _tfUsername, _iconUsername, _lbUsername, _lbBotUsername, _tfPassword, _iconPassword, _lbPassword, _lbBotPassword, _btnShowHidePass, _btnSignIn, _btnForgotPassword, _lbNoAccount, _btnSignUp;
@synthesize waitingHud;

- (void)setupUIForView
{
    //  Add waiting view
    waitingHud = [[YBHud alloc] initWithHudType:DGActivityIndicatorAnimationTypeLineScale andText:@""];
    //  hud.tintColor = [UIColor colorWithRed:(24/255.0) green:(185/255.0) blue:(153/255.0) alpha:1.0];
    waitingHud.tintColor = [UIColor whiteColor];
    waitingHud.dimAmount = 0.5;
    
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:HelveticaNeue size:18.0];
    }else{
        textFont = [UIFont fontWithName:HelveticaNeue size:18.0];
    }
    
    UITapGestureRecognizer *tapOnScreen = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTapOnScreen)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer: tapOnScreen];
    
    marginY = 10.0;
    hTextfield = 35.0;
    
    float bgHeight = _scrollViewContent.frame.size.width*417/1282;
    _imgBackground.frame = CGRectMake(0, SCREEN_HEIGHT-bgHeight, SCREEN_WIDTH, bgHeight);
    
    _scrollViewContent.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _scrollViewContent.showsVerticalScrollIndicator = NO;
    _scrollViewContent.showsHorizontalScrollIndicator = NO;
    
    
    float logoWidth = SCREEN_WIDTH/3+30;
    _imgLogo.frame = CGRectMake((_scrollViewContent.frame.size.width-logoWidth)/2, 0, logoWidth, logoWidth);
    
    //  float tmpWidth = (_scrollViewContent.frame.size.width/8);
    float tmpWidth = 15.0;
    
    //  username
    _tfUsername.frame = CGRectMake(tmpWidth, _imgLogo.frame.origin.y+_imgLogo.frame.size.height+10, SCREEN_WIDTH-2*tmpWidth, hTextfield);
    _tfUsername.borderStyle = UITextBorderStyleNone;
    _tfUsername.font = textFont;
    [_tfUsername addTarget:self
                    action:@selector(onTextFieldDidChanged:)
          forControlEvents:UIControlEventEditingChanged];
    
    UIView *pUsername = [[UIView alloc] initWithFrame: CGRectMake(0, 0, hTextfield/2, hTextfield)];
    pUsername.backgroundColor = UIColor.clearColor;
    _tfUsername.leftView = pUsername;
    _tfUsername.leftViewMode = UITextFieldViewModeAlways;
    
    _lbBotUsername.frame = CGRectMake(_tfUsername.frame.origin.x, _tfUsername.frame.origin.y+hTextfield, _tfUsername.frame.size.width, 1);
    _lbBotUsername.backgroundColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                      blue:(200/255.0) alpha:1.0];
    
    _iconUsername.frame = CGRectMake(_tfUsername.frame.origin.x+5, _tfUsername.frame.origin.y+hTextfield/4, hTextfield/2, hTextfield/2);
    _lbUsername.frame = _tfUsername.frame;
    _lbUsername.font = textFont;
    _lbUsername.backgroundColor = UIColor.clearColor;
    _lbUsername.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_input_username];
    
    //  Password
    _tfPassword.frame = CGRectMake(_tfUsername.frame.origin.x, _tfUsername.frame.origin.y+hTextfield+2*marginY, _tfUsername.frame.size.width, hTextfield);
    _tfPassword.borderStyle = UITextBorderStyleNone;
    _tfPassword.font = textFont;
    _tfPassword.secureTextEntry = YES;
    [_tfPassword addTarget:self
                    action:@selector(onTextFieldDidChanged:)
          forControlEvents:UIControlEventEditingChanged];
    
    UIView *pPassword = [[UIView alloc] initWithFrame: CGRectMake(0, 0, hTextfield/2, hTextfield)];
    pPassword.backgroundColor = UIColor.clearColor;
    _tfPassword.leftView = pPassword;
    _tfPassword.leftViewMode = UITextFieldViewModeAlways;
    
    _lbBotPassword.frame = CGRectMake(_tfPassword.frame.origin.x, _tfPassword.frame.origin.y+hTextfield, _tfPassword.frame.size.width, 1);
    _lbBotPassword.backgroundColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                      blue:(200/255.0) alpha:1.0];
    _iconPassword.frame = CGRectMake(_iconUsername.frame.origin.x, _tfPassword.frame.origin.y+hTextfield/4, hTextfield/2, hTextfield/2);
    
    _lbPassword.frame = _tfPassword.frame;
    _lbPassword.font = textFont;
    _lbPassword.backgroundColor = UIColor.clearColor;
    _lbPassword.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_password];
    
    _btnShowHidePass.frame = CGRectMake(_tfPassword.frame.origin.x+_tfPassword.frame.size.width-50, _tfPassword.frame.origin.y, 50, _tfPassword.frame.size.height);
    _btnShowHidePass.titleLabel.font = [UIFont fontWithName:HelveticaNeue size:14.0];
    [_btnShowHidePass setTitleColor:_lbUsername.textColor forState:UIControlStateNormal];
    if (_tfPassword.isSecureTextEntry) {
        [_btnShowHidePass setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_show_pass] forState:UIControlStateNormal];
    }else{
        [_btnShowHidePass setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_hide_pass] forState:UIControlStateNormal];
    }
    
    //  button sign in
    _btnSignIn.frame = CGRectMake(_tfPassword.frame.origin.x, _tfPassword.frame.origin.y+hTextfield+2*marginY, _tfPassword.frame.size.width, hTextfield+10);
    _btnSignIn.layer.cornerRadius = _btnSignIn.frame.size.height/2;
    if (SCREEN_WIDTH > 320) {
        _btnSignIn.titleLabel.font = [UIFont fontWithName:HelveticaNeue size:20.0];
    }else{
        _btnSignIn.titleLabel.font = [UIFont fontWithName:HelveticaNeue size:18.0];
    }
    _btnSignIn.backgroundColor = [UIColor colorWithRed:(0/255.0) green:(188/255.0)
                                                  blue:(157/255.0) alpha:1.0];
    _btnSignIn.layer.borderWidth = 1.0;
    _btnSignIn.layer.borderColor = [UIColor colorWithRed:(0/255.0) green:(188/255.0)
                                                    blue:(157/255.0) alpha:1.0].CGColor;
    [_btnSignIn setTitle:[[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_sign_in] capitalizedString]
                forState:UIControlStateNormal];
    [_btnSignIn addTarget:self
                   action:@selector(btnSignInTouchDown:)
         forControlEvents:UIControlEventTouchDown];
    
    //  forgot password
    _btnForgotPassword.frame = CGRectMake(_btnSignIn.frame.origin.x, _btnSignIn.frame.origin.y+_btnSignIn.frame.size.height+marginY, _btnSignIn.frame.size.width, hTextfield);
    _btnForgotPassword.titleLabel.font = textFont;
    [_btnForgotPassword setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_forgot_password] forState:UIControlStateNormal];
    
    CGSize sizeNoAcc = [AppUtils getSizeWithText:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_no_account] withFont:textFont];
    CGSize sizeSignUp = [AppUtils getSizeWithText:[[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_sign_up] uppercaseString] withFont:textFont];
    
    _lbNoAccount.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_no_account];
    _lbNoAccount.font = textFont;
    _lbNoAccount.frame = CGRectMake((SCREEN_WIDTH-(sizeNoAcc.width+5+sizeSignUp.width))/2, _btnForgotPassword.frame.origin.y+_btnForgotPassword.frame.size.height+2*marginY, sizeNoAcc.width, hTextfield);
    
    _btnSignUp.frame = CGRectMake(_lbNoAccount.frame.origin.x+sizeNoAcc.width+5, _lbNoAccount.frame.origin.y, sizeSignUp.width, hTextfield);
    _btnSignUp.titleLabel.font = textFont;
    [_btnSignUp setTitle:[[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_sign_up] uppercaseString] forState:UIControlStateNormal];
    
    _scrollViewContent.contentSize = CGSizeMake(SCREEN_WIDTH, _btnSignUp.frame.origin.y+_btnSignUp.frame.size.height+2*marginY);
}

- (void)btnSignInTouchDown: (UIButton *)sender {
    sender.backgroundColor = UIColor.clearColor;
}

- (IBAction)_btnSignUpPressed:(id)sender {
}

- (IBAction)_btnShowHidePassPressed:(UIButton *)sender {
    if (_tfPassword.isSecureTextEntry) {
        _tfPassword.secureTextEntry = NO;
        [_btnShowHidePass setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_hide_pass] forState:UIControlStateNormal];
    }else{
        _tfPassword.secureTextEntry = YES;
        [_btnShowHidePass setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_show_pass] forState:UIControlStateNormal];
    }
}

- (void)onTextFieldDidChanged: (UITextField *)textfield {
    if (textfield == _tfUsername) {
        if ([textfield.text isEqualToString: @""]) {
            _lbUsername.hidden = NO;
        }else{
            _lbUsername.hidden = YES;
        }
    }else if (textfield == _tfPassword){
        if ([textfield.text isEqualToString: @""]) {
            _lbPassword.hidden = NO;
        }else{
            _lbPassword.hidden = YES;
        }
    }
}

//  Tap trên màn hình để close keyboard
- (void)whenTapOnScreen {
    [self endEditing: true];
}

@end
