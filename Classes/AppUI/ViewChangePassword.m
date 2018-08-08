//
//  ViewChangePassword.m
//  linphone
//
//  Created by Ei Captain on 7/5/16.
//
//

#import "ViewChangePassword.h"

@implementation ViewChangePassword
@synthesize _tfOldPass, _tfNewPass, _tfConfirmPass, _lbNotification, _btnCancel, _btnConfirm, _viewFooter;

- (void)setupUIForView
{
    UIFont *textFont;
    UIFont *textFontBold;
    if (self.frame.size.width > 320) {
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
        textFontBold = [UIFont fontWithName:MYRIADPRO_BOLD size:18.0];
    }else{
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
        textFontBold = [UIFont fontWithName:MYRIADPRO_BOLD size:16.0];
    }
    
    float hView = 210.0;
    self.clipsToBounds = YES;
    self.backgroundColor = UIColor.whiteColor;
    
    float marginX = 15.0;
    
    //  Old password textfied
    _tfOldPass.frame = CGRectMake(marginX, 10, self.frame.size.width-2*marginX, 30);
    _tfOldPass.font = textFont;
    _tfOldPass.secureTextEntry = YES;
    
    UIView *pOldPass = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, _tfOldPass.frame.size.height)];
    _tfOldPass.leftView = pOldPass;
    _tfOldPass.leftViewMode = UITextFieldViewModeAlways;
    
    //  New password textfield
    _tfNewPass.frame = CGRectMake(_tfOldPass.frame.origin.x, _tfOldPass.frame.origin.y+_tfOldPass.frame.size.height+10, _tfOldPass.frame.size.width, _tfOldPass.frame.size.height);
    _tfNewPass.font = textFont;
    _tfNewPass.secureTextEntry = YES;
    
    UIView *pNewPass = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pOldPass.frame.size.width, _tfNewPass.frame.size.height)];
    _tfNewPass.leftView = pNewPass;
    _tfNewPass.leftViewMode = UITextFieldViewModeAlways;
    
    //  Confirm password textfield
    _tfConfirmPass.frame = CGRectMake(_tfNewPass.frame.origin.x, _tfNewPass.frame.origin.y+_tfNewPass.frame.size.height+10, _tfNewPass.frame.size.width, _tfNewPass.frame.size.height);
    _tfConfirmPass.font = textFont;
    _tfConfirmPass.secureTextEntry = YES;
    
    
    UIView *pConfirm = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pNewPass.frame.size.width, _tfConfirmPass.frame.size.height)];
    _tfConfirmPass.leftView = pConfirm;
    _tfConfirmPass.leftViewMode = UITextFieldViewModeAlways;
    
    //  Label note password
    _lbNotification.frame = CGRectMake(_tfConfirmPass.frame.origin.x, _tfConfirmPass.frame.origin.y+_tfConfirmPass.frame.size.height, _tfConfirmPass.frame.size.width, 40);
    _lbNotification.textColor = UIColor.redColor;
    _lbNotification.font = textFont;
    _lbNotification.textAlignment = NSTextAlignmentCenter;
    
    //  footer
    [_viewFooter setFrame: CGRectMake(0, _lbNotification.frame.origin.y+_lbNotification.frame.size.height, self.frame.size.width, hView-(_lbNotification.frame.origin.y+_lbNotification.frame.size.height))];
    
    UILabel *lbTest = [[UILabel alloc] init];
    lbTest.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_cancel];
    [lbTest sizeToFit];
    
    //  Cancel button
    _btnCancel.frame = CGRectMake(50, 10, lbTest.frame.size.width+20, _btnCancel.frame.size.height);
    _btnCancel.titleLabel.font = textFontBold;
    [_btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _btnCancel.layer.cornerRadius = 4.0;
    _btnCancel.layer.borderWidth = 1.0;
    _btnCancel.layer.borderColor = [UIColor colorWithRed:(237/255.0) green:(27/255.0)
                                                    blue:(45/255.0) alpha:1.0].CGColor;
    [_btnCancel addTarget:self
                   action:@selector(btnCancelTouchDown:)
         forControlEvents:UIControlEventTouchDown];
    
    //  Confirm button
    lbTest.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_confirm];
    [lbTest sizeToFit];
    
    _btnConfirm.frame = CGRectMake(self.frame.size.width-50 - (lbTest.frame.size.width+20), _btnConfirm.frame.origin.y, lbTest.frame.size.width+20, _btnConfirm.frame.size.height);
    _btnConfirm.titleLabel.font = textFontBold;
    [_btnConfirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _btnConfirm.layer.cornerRadius = 4.0;
    _btnConfirm.layer.borderWidth = 1.0;
    _btnConfirm.layer.borderColor = [UIColor colorWithRed:(153/255.0) green:(202/255.0)
                                                     blue:(87/255.0) alpha:1.0].CGColor;
    [_btnConfirm addTarget:self
                    action:@selector(btnChangePasswordTouchDown:)
          forControlEvents:UIControlEventTouchDown];
}

- (void)showContentWithCurrentLanguage {
    _tfOldPass.placeholder = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_old_pass];
    _tfNewPass.placeholder = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_new_pass];
    _tfConfirmPass.placeholder = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_confirm_new_pass];
    
    _lbNotification.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_change_pass_len];
    
    
    [_btnCancel setTitle: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_cancel]
                forState:UIControlStateNormal];
    [_btnConfirm setTitle: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_confirm]
                 forState:UIControlStateNormal];
}

- (void)btnChangePasswordTouchDown: (UIButton *)sender {
    sender.backgroundColor = UIColor.whiteColor;
    [sender setTitleColor:[UIColor colorWithRed:(153/255.0) green:(202/255.0)
                                           blue:(87/255.0) alpha:1.0]
                 forState:UIControlStateNormal];
}

- (void)btnCancelTouchDown: (UIButton *)sender {
    sender.backgroundColor = UIColor.whiteColor;
    [sender setTitleColor:[UIColor colorWithRed:(237/255.0) green:(27/255.0)
                                           blue:(45/255.0) alpha:1.0]
                 forState:UIControlStateNormal];
}

@end
