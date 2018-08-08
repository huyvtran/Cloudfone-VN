//
//  ViewTrunking.m
//  linphone
//
//  Created by mac book on 17/4/15.
//
//

#import "ViewTrunking.h"

@implementation ViewTrunking
@synthesize _lbPBX, _switchPBX;
@synthesize _viewPBX, _tfPBXID, _tfPBXUsername, _tfPBXPassword, _viewFooter, _btnReset, _btnSave, _iconSearchQRCode;

- (void)setupUIForView
{
    self.clipsToBounds = YES;
    
    UIFont *textFont;
    UIFont *textFontBold;
    if (self.frame.size.width > 320) {
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
        textFontBold = [UIFont fontWithName:MYRIADPRO_BOLD size:18.0];
    }else{
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
        textFontBold = [UIFont fontWithName:MYRIADPRO_BOLD size:16.0];
    }
    
    UITapGestureRecognizer *tapClose = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToCloseKeyboard)];
    [self addGestureRecognizer: tapClose];
    
    float hViewTrunking;
    float marginX = 10.0;
    
    NSNumber *pbxFlag = [[NSUserDefaults standardUserDefaults] objectForKey: callnexPBXFlag];
    if (pbxFlag == nil || [pbxFlag intValue] == 0) {
        hViewTrunking = 50.0;
    }else{
        hViewTrunking = 210;
    }
    self.backgroundColor = UIColor.whiteColor;
    
    UIColor *textColor = [UIColor colorWithRed:(50/255.0) green:(50/255.0)
                                          blue:(50/255.0) alpha:1.0];
    _lbPBX.frame = CGRectMake(marginX, 10, self.frame.size.width-(marginX+80), 30);
    _lbPBX.font = textFont;
    _lbPBX.textColor = [UIColor colorWithRed:(170/255.0) green:(170/255.0)
                                        blue:(170/255.0) alpha:1.0];
    //  view pbx
    _viewPBX.frame = CGRectMake(0, _lbPBX.frame.origin.y+_lbPBX.frame.size.height+10, self.frame.size.width, hViewTrunking-(_lbPBX.frame.origin.y+_lbPBX.frame.size.height+10));
    _viewPBX.userInteractionEnabled = YES;
    _viewPBX.backgroundColor = UIColor.clearColor;
    
    //  textfield ID
    _tfPBXID.frame = CGRectMake(15.0, _tfPBXID.frame.origin.y, self.frame.size.width-2*15.0, _tfPBXID.frame.size.height);
    _tfPBXID.textColor = textColor;
    _tfPBXID.font = textFont;
    _tfPBXID.borderStyle = UITextBorderStyleNone;
    _tfPBXID.layer.borderColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0)
                                                  blue:(220/255.0) alpha:1.0].CGColor;
    _tfPBXID.layer.borderWidth = 1.0;
    _tfPBXID.layer.cornerRadius = 4.0;
    
    UIView *idPadding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 7, 30)];
    _tfPBXID.leftView = idPadding;
    _tfPBXID.leftViewMode = UITextFieldViewModeAlways;
    
    //  textfield username
    _tfPBXUsername.frame = CGRectMake(_tfPBXID.frame.origin.x, _tfPBXID.frame.origin.y+_tfPBXID.frame.size.height+5, _tfPBXID.frame.size.width, _tfPBXID.frame.size.height);
    _tfPBXUsername.textColor = textColor;
    _tfPBXUsername.font = textFont;
    _tfPBXUsername.borderStyle = UITextBorderStyleNone;
    _tfPBXUsername.layer.borderColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0)
                                                        blue:(220/255.0) alpha:1.0].CGColor;
    _tfPBXUsername.layer.borderWidth = 1.0;
    _tfPBXUsername.layer.cornerRadius = 4.0;
    
    UIView *userPadding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 7, 30)];
    _tfPBXUsername.leftView = userPadding;
    _tfPBXUsername.leftViewMode = UITextFieldViewModeAlways;
    
    //  textfield password
    _tfPBXPassword.frame = CGRectMake(_tfPBXUsername.frame.origin.x, _tfPBXUsername.frame.origin.y+_tfPBXUsername.frame.size.height+5, _tfPBXUsername.frame.size.width, _tfPBXUsername.frame.size.height);
    _tfPBXPassword.textColor = textColor;
    _tfPBXPassword.secureTextEntry = YES;
    _tfPBXPassword.font = textFont;
    _tfPBXPassword.borderStyle = UITextBorderStyleNone;
    _tfPBXPassword.layer.borderColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0)
                                                        blue:(220/255.0) alpha:1.0].CGColor;
    _tfPBXPassword.layer.borderWidth = 1.0;
    _tfPBXPassword.layer.cornerRadius = 4.0;
    
    UIView *passPadding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 7, 30)];
    _tfPBXPassword.leftView = passPadding;
    _tfPBXPassword.leftViewMode = UITextFieldViewModeAlways;
    
    //  footer
    float hFooter = 40.0;
    _viewFooter.frame = CGRectMake(0, 160-hFooter, self.frame.size.width, hFooter);
    _viewFooter.backgroundColor = [UIColor greenColor];
    
    CGRect qrCodeRect = CGRectMake((_viewFooter.frame.size.width-35.0)/2, (_viewFooter.frame.size.height-35.0)/2, 35.0, 35.0);
    _iconSearchQRCode.frame = qrCodeRect;
    _iconSearchQRCode.backgroundColor = [UIColor redColor];
    
    float hButton = 30.0;
    float tmpWidth = (_viewPBX.frame.size.width-160)/4;
    _btnReset.frame = CGRectMake(tmpWidth, (hFooter-hButton)/2, 80, hButton);
    _btnReset.titleLabel.font = textFontBold;
    
    [_btnReset setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _btnReset.backgroundColor = [UIColor colorWithRed:(237/255.0) green:(32/255.0)
                                                 blue:(36/255.0) alpha:1.0];
    
    _btnReset.layer.cornerRadius = 4.0;
    _btnReset.layer.borderWidth = 1.0;
    _btnReset.layer.borderColor = [UIColor colorWithRed:(237/255.0) green:(32/255.0)
                                                   blue:(36/255.0) alpha:1.0].CGColor;
    [_btnReset addTarget:self
                  action:@selector(whenButtonResetTouchDown:)
        forControlEvents:UIControlEventTouchDown];
    
    //  button save
    _btnSave.frame = CGRectMake(_btnReset.frame.origin.x+_btnReset.frame.size.width+tmpWidth*2, _btnReset.frame.origin.y, _btnReset.frame.size.width, _btnReset.frame.size.height);
    _btnSave.titleLabel.font = textFontBold;
    
    [_btnSave setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _btnSave.backgroundColor = [UIColor colorWithRed:(154/255.0) green:(202/255.0)
                                                blue:(61/255.0) alpha:1.0];
    
    _btnSave.layer.cornerRadius = 4.0;
    _btnSave.layer.borderWidth = 1.0;
    _btnSave.layer.borderColor = [UIColor colorWithRed:(154/255.0) green:(202/255.0)
                                                  blue:(61/255.0) alpha:1.0].CGColor;
    
    //  other
    _viewPBX.hidden = YES;
    
    // switch pbx
    _switchPBX = [[CallnexSwitchButton alloc] initWithState:NO frame:CGRectMake(self.frame.size.width-54-10, _lbPBX.frame.origin.y, 54, 27)];
    _switchPBX._typeSwitch = eSwitchTrukingPBX;
    [self addSubview: _switchPBX];
}

- (void)showContentWithCurrentLanguage
{
    _lbPBX.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_trunking_pbx];
    _tfPBXID.placeholder = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_trunking_id];
    _tfPBXUsername.placeholder = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_trunking_user];
    _tfPBXPassword.placeholder = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_trunking_pass];
    [_btnReset setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_trunking_clear]
               forState:UIControlStateNormal];
    [_btnSave setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_trunking_save]
              forState:UIControlStateNormal];
}

- (void)tapToCloseKeyboard {
    [self endEditing: true];
}

- (void)whenButtonResetTouchDown: (UIButton *)sender {
    sender.backgroundColor = UIColor.whiteColor;
    [sender setTitleColor:[UIColor colorWithRed:(237/255.0) green:(32/255.0)
                                           blue:(36/255.0) alpha:1.0]
                 forState:UIControlStateNormal];
}

//  hiển thị view pbx
- (void)showViewPBXForTrunkingView: (float)hTrunkingView {
    _viewPBX.hidden = NO;
    
    //  Điền thông tin cho view PBX
    NSString *pbxID         = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_ID];
    NSString *pbxUsername   = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_USERNAME];
    NSString *pbxPassword   = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_PASSWORD];
    if (pbxID == nil || [pbxID isEqualToString: @""]) {
        //  pbxID = @"CF-B-21164";
        pbxID = @"";
    }
    _tfPBXID.text = pbxID;
    
    if (pbxUsername == nil) {
        pbxUsername = @"";
    }
    _tfPBXUsername.text = pbxUsername;
    
    if (pbxPassword == nil) {
        pbxPassword = @"";
    }
    _tfPBXPassword.text = pbxPassword;
    
    _viewPBX.frame = CGRectMake(_viewPBX.frame.origin.x, _viewPBX.frame.origin.y, _viewPBX.frame.size.width, hTrunkingView-_viewPBX.frame.origin.y);
}

@end
