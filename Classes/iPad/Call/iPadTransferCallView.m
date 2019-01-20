//
//  iPadTransferCallView.m
//  linphone
//
//  Created by admin on 1/20/19.
//

#import "iPadTransferCallView.h"

@implementation iPadTransferCallView
@synthesize oneButton, twoButton, threeButton, fourButton, fiveButton, sixButton, sevenButton, eightButton, nineButton, zeroButton, starButton, sharpButton, transferCallButton, backspaceButton, backToCallButton, addressField, viewKeypad;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setupUIForView
{
    //  Number keypad
    self.backgroundColor = UIColor.whiteColor;
    float wIcon = 80.0;
    float spaceMarginY = 22.0;
    float spaceMarginX = 30.0;
    
    [transferCallButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.bottom.equalTo(self).offset(-40);
        make.width.height.mas_equalTo(wIcon);
    }];
    [transferCallButton addTarget:self
                           action:@selector(transferCallButtonPressed)
                 forControlEvents:UIControlEventTouchUpInside];
    
    [addressField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(50);
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.height.mas_equalTo(60.0);
    }];
    addressField.keyboardType = UIKeyboardTypePhonePad;
    addressField.enabled = NO;
    addressField.textAlignment = NSTextAlignmentCenter;
    addressField.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:45.0];
    addressField.adjustsFontSizeToFitWidth = YES;
    addressField.backgroundColor = UIColor.clearColor;
    addressField.textColor = [UIColor colorWithRed:(50/255.0) green:(50/255.0)
                                              blue:(50/255.0) alpha:1.0];
    [addressField setBorderStyle: UITextBorderStyleNone];
    
    [viewKeypad mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(addressField.mas_bottom).offset(10);
        make.bottom.equalTo(transferCallButton.mas_top).offset(-10);
    }];
    
    
    [fiveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewKeypad.mas_centerX);
        make.bottom.equalTo(viewKeypad.mas_centerY).offset(-spaceMarginY/2);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    [fourButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fiveButton);
        make.right.equalTo(fiveButton.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    [sixButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fiveButton);
        make.left.equalTo(fiveButton.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    [twoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(fiveButton.mas_top).offset(-spaceMarginY);
        make.centerX.equalTo(viewKeypad.mas_centerX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    [oneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(twoButton);
        make.right.equalTo(twoButton.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    [threeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(twoButton);
        make.left.equalTo(twoButton.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    [eightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fiveButton.mas_bottom).offset(spaceMarginY);
        make.centerX.equalTo(viewKeypad.mas_centerX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    [sevenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(eightButton);
        make.right.equalTo(eightButton.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    [nineButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(eightButton);
        make.left.equalTo(eightButton.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    [zeroButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(eightButton.mas_bottom).offset(spaceMarginY);
        make.centerX.equalTo(viewKeypad.mas_centerX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    [starButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(zeroButton);
        make.right.equalTo(zeroButton.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    [sharpButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(zeroButton);
        make.left.equalTo(zeroButton.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    backToCallButton.backgroundColor = UIColor.clearColor;
    [backToCallButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(starButton.mas_centerX);
        make.centerY.equalTo(transferCallButton.mas_centerY);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    [backspaceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(sharpButton.mas_centerX);
        make.centerY.equalTo(transferCallButton.mas_centerY);
        make.width.height.mas_equalTo(wIcon);
    }];
}

- (IBAction)onDigitPress:(UIDigitButton *)sender {
    NSString *value = [NSString stringWithFormat:@"%c", sender.digit];
    addressField.text = [NSString stringWithFormat:@"%@%@", addressField.text, value];
}

- (void)transferCallButtonPressed {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Transfer call to %@", __FUNCTION__, addressField.text] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    if (![addressField.text isEqualToString:@""]) {
        LinphoneManager.instance.nextCallIsTransfer = YES;
        LinphoneAddress *addr = linphone_core_interpret_url(LC, addressField.text.UTF8String);
        [LinphoneManager.instance call:addr];
        if (addr)
            linphone_address_destroy(addr);
    }else{
        [self makeToast:@"Please input phone number to transfer" duration:2.0 position:CSToastPositionCenter];
    }
}

@end
