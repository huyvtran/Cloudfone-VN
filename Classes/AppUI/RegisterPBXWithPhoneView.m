//
//  RegisterPBXWithPhoneView.m
//  linphone
//
//  Created by lam quang quan on 10/19/18.
//

#import "RegisterPBXWithPhoneView.h"

@implementation RegisterPBXWithPhoneView
@synthesize viewHeader, bgHeader, icClose, lbHeader, icQRCode, lbPhoneNumber, tfPhoneNumber, btnContinue, delegate;

- (void)setupUIForView {
    if (SCREEN_WIDTH > 320) {
        lbHeader.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:20.0];
    }else{
        lbHeader.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }
    
    float marginX = 20.0;
    
    //  Header view
    [viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.mas_equalTo([LinphoneAppDelegate sharedInstance]._hRegistrationState);
    }];
    
    [bgHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(viewHeader);
    }];
    
    lbHeader.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Register with phone number"];
    lbHeader.textColor = UIColor.whiteColor;
    [lbHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader).offset([LinphoneAppDelegate sharedInstance]._hStatus);
        make.bottom.equalTo(viewHeader);
        make.centerX.equalTo(viewHeader.mas_centerX);
        make.width.mas_equalTo(250);
    }];
    
    [icClose mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewHeader);
        make.centerY.equalTo(lbHeader.mas_centerY);
        make.width.height.mas_equalTo(HEADER_ICON_WIDTH);
    }];
    
    [icQRCode mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(icClose);
        make.right.equalTo(viewHeader.mas_right);
        make.width.equalTo(icClose.mas_width);
        make.height.equalTo(icClose.mas_height);
    }];
    
    //  Content
    lbPhoneNumber.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Input phone number"];
    lbPhoneNumber.textColor = [UIColor colorWithRed:(80/255.0) green:(80/255.0)
                                               blue:(80/255.0) alpha:1.0];
    lbPhoneNumber.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    [lbPhoneNumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(marginX);
        make.right.equalTo(self).offset(-marginX);
        make.top.equalTo(viewHeader.mas_bottom).offset(40.0);
        make.height.mas_equalTo(40.0);
    }];
    
    tfPhoneNumber.borderStyle = UITextBorderStyleNone;
    tfPhoneNumber.layer.cornerRadius = 3.0;
    tfPhoneNumber.layer.borderWidth = 1.0;
    tfPhoneNumber.layer.borderColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0)
                                                       blue:(235/255.0) alpha:1.0].CGColor;
    tfPhoneNumber.keyboardType = UIKeyboardTypePhonePad;
    tfPhoneNumber.font = [UIFont fontWithName:MYRIADPRO_BOLD size:16.0];
    [tfPhoneNumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbPhoneNumber.mas_bottom).offset(3.0);
        make.left.equalTo(self).offset(marginX);
        make.right.equalTo(self).offset(-marginX);
        make.height.mas_equalTo(40.0);
    }];
    [tfPhoneNumber addTarget:self
                      action:@selector(whenTextfieldDidChanged:)
            forControlEvents:UIControlEventEditingChanged];
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50.0, 40.0)];
    UILabel *lbSepa = [[UILabel alloc] init];
    lbSepa.backgroundColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0)
                                              blue:(235/255.0) alpha:1.0];
    [leftView addSubview: lbSepa];
    [lbSepa mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(leftView);
        make.width.mas_equalTo(1.0);
    }];
    
    UILabel *lbCountry = [[UILabel alloc] init];
    lbCountry.textAlignment = NSTextAlignmentCenter;
    lbCountry.text = @"+84";
    lbCountry.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
    lbCountry.textColor = [UIColor colorWithRed:(80/255.0) green:(80/255.0)
                                           blue:(80/255.0) alpha:1.0];
    [leftView addSubview: lbCountry];
    [lbCountry mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(leftView);
        make.left.equalTo(leftView).offset(5.0);
        make.right.equalTo(lbSepa.mas_left).offset(-5.0);
    }];
    
    tfPhoneNumber.leftView = leftView;
    tfPhoneNumber.leftViewMode = UITextFieldViewModeAlways;
    
    //  button login with phone number
    
    [btnContinue setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Continue"]
                 forState:UIControlStateNormal];
    UIImage *bgDisable = [AppUtils imageWithColor:[UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                                   blue:(200/255.0) alpha:1.0]
                                        andBounds:CGRectMake(0, 0, 300, 120)];
    [btnContinue setBackgroundImage:bgDisable forState:UIControlStateDisabled];
    [btnContinue setBackgroundImage:[UIImage imageNamed:@"bg_button.png"]
                           forState:UIControlStateNormal];
    btnContinue.enabled = NO;
    [btnContinue setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnContinue.clipsToBounds = YES;
    btnContinue.layer.cornerRadius = 45.0/2;
    btnContinue.titleLabel.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    [btnContinue mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tfPhoneNumber.mas_bottom).offset(30);
        make.left.equalTo(self).offset(marginX);
        make.right.equalTo(self).offset(-marginX);
        make.height.mas_equalTo(45.0);
    }];
}

- (IBAction)btnContinuePress:(UIButton *)sender {
    if ([delegate respondsToSelector:@selector(onButtonContinuePress)]) {
        [delegate onButtonContinuePress];
    }
}

- (IBAction)icCloseClick:(UIButton *)sender {
    if ([delegate respondsToSelector:@selector(onIconCloseClick)]) {
        [delegate onIconCloseClick];
    }
}

- (IBAction)icQRCodeClick:(UIButton *)sender {
    if ([delegate respondsToSelector:@selector(onIconQRCodeScanClick)]) {
        [delegate onIconQRCodeScanClick];
    }
}

- (void)whenTextfieldDidChanged: (UITextField *)textfield {
    if (textfield.text.length == 0) {
        btnContinue.enabled = NO;
    }else{
        btnContinue.enabled = YES;
    }
}

@end
