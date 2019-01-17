//
//  iPadPopupCall.m
//  linphone
//
//  Created by admin on 1/16/19.
//

#import "iPadPopupCall.h"

@implementation iPadPopupCall
@synthesize lbName, lbTime, lbQuality, scvButtons, btnMute, lbMute, btnKeypad, lbKeypad, btnSpeaker, lbSpeaker, btnAddCall, lbAddCall, btnHoldCall, lbHoldCall, btnTransfer, lbTransfer, btnHangupCall, icShink;
@synthesize wButton, hLabel;

- (void)setupUIForView {
    self.backgroundColor = [UIColor colorWithRed:(20/255.0) green:(20/255.0)
                                            blue:(20/255.0) alpha:1.0];
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 10.0;
    
    float padding = 30.0;
    wButton = 80.0;
    hLabel = 25.0;
    float hButtonsView = wButton + hLabel + 20 + wButton + hLabel;
    
    //  scrollview buttons
    float marginButton = (self.frame.size.width - 2*padding - 3*wButton)/4;
    scvButtons.scrollEnabled = NO;
    scvButtons.backgroundColor = UIColor.clearColor;
    [scvButtons mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.left.equalTo(self).offset(padding);
        make.right.equalTo(self).offset(-padding);
        make.height.mas_equalTo(hButtonsView);
    }];
    
    //  keypad button
    [self customForButton:btnKeypad selectedImage:[UIImage imageNamed:@"ic_keyboad_white"] normalImage:[UIImage imageNamed:@"ic_keyboad_black"]];
    [self setSelected:NO forButton:btnKeypad];
    
    [btnKeypad mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(scvButtons.mas_centerX);
        make.top.equalTo(scvButtons);
        make.width.height.mas_equalTo(wButton);
    }];
    
    lbKeypad.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Keypad"];
    lbKeypad.backgroundColor = UIColor.clearColor;
    lbKeypad.font = [UIFont fontWithName:HelveticaNeue size:16.0];
    [lbKeypad mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnKeypad.mas_bottom);
        make.centerX.equalTo(btnKeypad.mas_centerX);
        make.height.mas_equalTo(hLabel);
        make.width.mas_equalTo(wButton + marginButton);
    }];
    
    
    //  mute button
    [self customForButton:btnMute selectedImage:[UIImage imageNamed:@"ic_muted_white"] normalImage:[UIImage imageNamed:@"ic_muted_black"]];
    [self setSelected:NO forButton:btnMute];
    
    [btnMute mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnKeypad);
        make.right.equalTo(btnKeypad.mas_left).offset(-marginButton);
        make.width.height.mas_equalTo(wButton);
    }];
    
    lbMute.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Mute"];
    lbMute.backgroundColor = UIColor.clearColor;
    lbMute.font = lbKeypad.font;
    [lbMute mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnMute.mas_bottom);
        make.centerX.equalTo(btnMute.mas_centerX);
        make.height.mas_equalTo(hLabel);
        make.width.equalTo(lbKeypad.mas_width);
    }];
    
    //  speaker button
    [self customForButton:btnSpeaker selectedImage:[UIImage imageNamed:@"ic_speaker_white"] normalImage:[UIImage imageNamed:@"ic_speaker_black"]];
    [self setSelected:NO forButton:btnSpeaker];
    
    [btnSpeaker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnKeypad);
        make.left.equalTo(btnKeypad.mas_right).offset(marginButton);
        make.width.height.mas_equalTo(wButton);
    }];
    
    lbSpeaker.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Speaker"];
    lbSpeaker.backgroundColor = UIColor.clearColor;
    lbSpeaker.font = lbKeypad.font;
    [lbSpeaker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnSpeaker.mas_bottom);
        make.centerX.equalTo(btnSpeaker.mas_centerX);
        make.height.mas_equalTo(hLabel);
        make.width.equalTo(lbKeypad.mas_width);
    }];
    
    //  hold call button
    [self customForButton:btnHoldCall selectedImage:[UIImage imageNamed:@"ic_pause_call_white"] normalImage:[UIImage imageNamed:@"ic_pause_call_black"]];
    [self setSelected:NO forButton:btnHoldCall];
    
    [btnHoldCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbKeypad.mas_bottom).offset(20.0);
        make.centerX.equalTo(scvButtons.mas_centerX);
        make.width.height.mas_equalTo(wButton);
    }];
    
    lbHoldCall.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Hold"];
    lbHoldCall.backgroundColor = UIColor.clearColor;
    lbHoldCall.font = lbKeypad.font;
    [lbHoldCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnHoldCall.mas_bottom);
        make.centerX.equalTo(btnHoldCall.mas_centerX);
        make.height.mas_equalTo(hLabel);
        make.width.equalTo(lbKeypad.mas_width);
    }];
    
    //  add call button
    [self customForButton:btnAddCall selectedImage:[UIImage imageNamed:@"ic_add_call_white"] normalImage:[UIImage imageNamed:@"ic_add_call_black"]];
    [self setSelected:NO forButton:btnAddCall];
    
    [btnAddCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnHoldCall);
        make.right.equalTo(btnHoldCall.mas_left).offset(-marginButton);
        make.width.height.mas_equalTo(wButton);
    }];
    
    lbAddCall.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Add call"];
    lbAddCall.backgroundColor = UIColor.clearColor;
    lbAddCall.font = lbKeypad.font;
    [lbAddCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnAddCall.mas_bottom);
        make.centerX.equalTo(btnAddCall.mas_centerX);
        make.height.mas_equalTo(hLabel);
        make.width.equalTo(lbKeypad.mas_width);
    }];
    
    //  transfer call button
    [self customForButton:btnTransfer selectedImage:[UIImage imageNamed:@"ic_transfer_call_white"] normalImage:[UIImage imageNamed:@"ic_transfer_call_black"]];
    [self setSelected:NO forButton:btnTransfer];
    
    [btnTransfer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnHoldCall);
        make.left.equalTo(btnHoldCall.mas_right).offset(marginButton);
        make.width.height.mas_equalTo(wButton);
    }];
    
    lbTransfer.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Transfer"];
    lbTransfer.backgroundColor = UIColor.clearColor;
    lbTransfer.font = lbKeypad.font;
    [lbTransfer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnTransfer.mas_bottom);
        make.centerX.equalTo(btnTransfer.mas_centerX);
        make.height.mas_equalTo(hLabel);
        make.width.equalTo(lbKeypad.mas_width);
    }];
    
    //  hangup call button
    float hBottom = (self.frame.size.height - hButtonsView)/2;
    btnHangupCall.backgroundColor = [UIColor colorWithRed:(254/255.0) green:(59/255.0)
                                                     blue:(47/255.0) alpha:1.0];
    [self customForButton:btnHangupCall selectedImage:[UIImage imageNamed:@"ic_end_call_red"] normalImage:[UIImage imageNamed:@"ic_end_call_white"]];
    [btnHangupCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.bottom.equalTo(self).offset(-hBottom/2 + wButton/2);
        make.width.height.mas_equalTo(wButton);
    }];
    
    //  quality
    [lbQuality mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(scvButtons.mas_top);
        make.left.right.equalTo(scvButtons);
        make.height.mas_equalTo(40.0);
    }];
    
    //  name label
    lbName.font = [UIFont fontWithName:HelveticaNeue size:24.0];
    [lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(50.0);
        make.left.equalTo(self).offset(padding);
        make.right.equalTo(self).offset(-padding);
        make.height.mas_equalTo(45.0);
    }];
    
    lbTime.font = [UIFont fontWithName:HelveticaNeue size:18.0];
    [lbTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbName.mas_bottom).offset(5.0);
        make.left.right.equalTo(lbName);
        make.height.mas_equalTo(30.0);
    }];
    
    icShink.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    [icShink mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(padding);
        make.right.equalTo(self).offset(-padding);
        make.width.height.mas_equalTo(40.0);
    }];
}

- (void)setSelected: (BOOL)selected forButton: (UIButton *)sender {
    sender.selected = selected;
    if (selected) {
        sender.backgroundColor = UIColor.whiteColor;
    }else{
        sender.backgroundColor = UIColor.grayColor;
    }
}

- (void)customForButton: (UIButton *)sender selectedImage: (UIImage *)selectedImg normalImage: (UIImage *)normalImg
{
    sender.layer.rasterizationScale = 1.0;
    sender.layer.cornerRadius = wButton/2-5;
    sender.imageEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
    [sender setImage:selectedImg forState:UIControlStateSelected];
    [sender setImage:normalImg forState:UIControlStateNormal];
}

- (void)showInView:(UIView *)aView animated:(BOOL)animated {
    //Add transparent
    //  _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopupViewWhenTagOut)];
    UIView *viewBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    viewBackground.backgroundColor = UIColor.blackColor;
    viewBackground.alpha = 0.7;
    viewBackground.tag = 20;
    [aView addSubview:viewBackground];
    
    //  [viewBackground addGestureRecognizer:_tapGesture];
    
    [aView addSubview:self];
    if (animated) {
        [self fadeIn];
    }
}


- (void)fadeIn {
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)fadeOut {
    for (UIView *subView in self.window.subviews)
    {
        if (subView.tag == 20)
        {
            [subView removeFromSuperview];
        }
    }
    
    [UIView animateWithDuration:.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self removeFromSuperview];
        }
    }];
}

@end
