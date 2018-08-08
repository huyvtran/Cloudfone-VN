//
//  ConfirmResetPasswordView.m
//  linphone
//
//  Created by Hung Ho on 8/1/17.
//
//

#import "ConfirmResetPasswordView.h"

@interface ConfirmResetPasswordView () {
    UIFont *textFont;
}
@end

@implementation ConfirmResetPasswordView

@synthesize _scrollViewContent, _imgLogo, _lbConfirm, _tfConfirm, _btnConfirmReset, _icPassword, _lbBotConfirm, _imgBackgroud, _iconClose;

- (void)setupUIForView {
    [self setClipsToBounds: true];
    
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:HelveticaNeue size:18.0];
    }else{
        textFont = [UIFont fontWithName:HelveticaNeue size:15.0];
    }
    
    float bgHeight = SCREEN_WIDTH*417/1282;
    _imgBackgroud.frame = CGRectMake(0, SCREEN_HEIGHT-bgHeight, SCREEN_WIDTH, bgHeight);
    
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
    _tfConfirm.frame = CGRectMake(tmpWidth, _imgLogo.frame.origin.y+_imgLogo.frame.size.height+20, self.frame.size.width-2*tmpWidth, hTextfield);
    _tfConfirm.borderStyle = UITextBorderStyleNone;
    _tfConfirm.font = textFont;
    [_tfConfirm addTarget:self
                   action:@selector(onTextFieldDidChanged:)
         forControlEvents:UIControlEventEditingChanged];
    _tfConfirm.keyboardType = UIKeyboardTypeNumberPad;
    
    UIView *pConfirm = [[UIView alloc] initWithFrame: CGRectMake(0, 0, hTextfield/2, hTextfield)];
    pConfirm.backgroundColor = UIColor.clearColor;
    _tfConfirm.leftView = pConfirm;
    _tfConfirm.leftViewMode = UITextFieldViewModeAlways;
    
    _lbBotConfirm.frame = CGRectMake(_tfConfirm.frame.origin.x, _tfConfirm.frame.origin.y+hTextfield, _tfConfirm.frame.size.width, 1);
    _lbBotConfirm.backgroundColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                     blue:(200/255.0) alpha:1.0];
    
    _icPassword.frame = CGRectMake(_tfConfirm.frame.origin.x+5, _tfConfirm.frame.origin.y+hTextfield/4, hTextfield/2, hTextfield/2);
    
    _lbConfirm.frame = _tfConfirm.frame;
    _lbConfirm.font = textFont;
    _lbConfirm.backgroundColor = UIColor.clearColor;
    _lbConfirm.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_confirm_code];
    
    //  reset button
    _btnConfirmReset.frame = CGRectMake(_tfConfirm.frame.origin.x, _tfConfirm.frame.origin.y+hTextfield+40, _tfConfirm.frame.size.width, hTextfield+10);
    [_btnConfirmReset setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _btnConfirmReset.layer.cornerRadius = (hTextfield+10)/2;
    _btnConfirmReset.titleLabel.font = textFont;
    _btnConfirmReset.backgroundColor = [UIColor colorWithRed:(0/255.0) green:(188/255.0)
                                                        blue:(157/255.0) alpha:1.0];
    _btnConfirmReset.layer.borderWidth = 1.0;
    _btnConfirmReset.layer.borderColor = [UIColor colorWithRed:(0/255.0) green:(188/255.0)
                                                          blue:(157/255.0) alpha:1.0].CGColor;
    [_btnConfirmReset setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_confirm_change_password]
                       forState:UIControlStateNormal];
    [_btnConfirmReset addTarget:self
                          action:@selector(btnConfirmRequestPressed:)
                forControlEvents:UIControlEventTouchUpInside];
    
    _scrollViewContent.contentSize = CGSizeMake(_scrollViewContent.frame.size.width, _btnConfirmReset.frame.origin.y+_btnConfirmReset.frame.size.height+20);
    
    UITapGestureRecognizer *tapClose = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTapToCloseKeyboard)];
    [_scrollViewContent addGestureRecognizer: tapClose];
}

//  Nhập vào textfield
- (void)onTextFieldDidChanged: (UITextField *)textfield {
    if (textfield == _tfConfirm) {
        if ([textfield.text isEqualToString: @""]) {
            _lbConfirm.hidden = NO;
        }else{
            _lbConfirm.hidden = YES;
        }
    }
}

- (void)btnConfirmRequestPressed: (UIButton *)sender {
    sender.backgroundColor = UIColor.clearColor;
    
    [sender setTitleColor:[UIColor colorWithRed:(0/255.0) green:(188/255.0)
                                           blue:(157/255.0) alpha:1.0]
                 forState:UIControlStateNormal];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self
                                   selector:@selector(udpateBackgroundButton)
                                   userInfo:nil repeats:false];
}

- (void)udpateBackgroundButton{
    _btnConfirmReset.backgroundColor = [UIColor colorWithRed:(0/255.0) green:(188/255.0)
                                                        blue:(157/255.0) alpha:1.0];
    [_btnConfirmReset setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)whenTapToCloseKeyboard {
    [self endEditing: true];
}

@end
