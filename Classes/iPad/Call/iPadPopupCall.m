//
//  iPadPopupCall.m
//  linphone
//
//  Created by admin on 1/16/19.
//

#import "iPadPopupCall.h"
#import <AVFoundation/AVCaptureDevice.h>

#define kMaxRadius 200
#define kMaxDuration 10


@implementation iPadPopupCall
@synthesize imgBgCall, imgAvatar, bgTransparent, lbName, lbPhone, lbTime, lbQuality, scvButtons, btnMute, lbMute, btnKeypad, lbKeypad, btnSpeaker, lbSpeaker, btnAddCall, lbAddCall, btnHoldCall, lbHoldCall, btnTransfer, lbTransfer, btnHangupCall, icShink;
@synthesize wButton, hLabel, phoneNumber, callDirection, durationTimer, qualityTimer, needEnableSpeaker, viewKeypad, viewTransferCall;

- (void)customButton: (UIButton *)sender withImage: (UIImage *)normalImg selectedImage: (UIImage *)selectedImg disableImage: (UIImage *)disableImage cornerRadius: (float)radius
{
    [sender setImage:normalImg forState:UIControlStateNormal];
    [sender setImage:selectedImg forState:UIControlStateSelected];
    [sender setImage:disableImage forState:UIControlStateDisabled];
    sender.layer.cornerRadius = radius;
    sender.imageEdgeInsets = UIEdgeInsetsMake(22.0, 22.0, 22.0, 22.0);
}

- (void)setButton: (UIButton *)sender selected: (BOOL)selected {
    sender.selected = selected;
    if (selected) {
        sender.backgroundColor = UIColor.whiteColor;
    }else{
        sender.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    }
}

- (void)setupUIForView {
    self.backgroundColor = [UIColor colorWithRed:(20/255.0) green:(20/255.0)
                                            blue:(20/255.0) alpha:1.0];
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 10.0;
    
    float padding = 20.0;
    wButton = 75.0;
    hLabel = 30.0;
    float hButtonsView = wButton + hLabel + 20 + wButton + hLabel;
    
    [imgBgCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self);
    }];
    
    [imgAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self);
    }];
    
    bgTransparent.backgroundColor = [UIColor colorWithRed:(20/255.0) green:(20/255.0)
                                                     blue:(20/255.0) alpha:0.7];
    [bgTransparent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self);
    }];
    
    //  scrollview buttons
    float buttonRadius = (wButton-15.0)/2;
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
    [btnKeypad mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(scvButtons.mas_centerX);
        make.top.equalTo(scvButtons);
        make.width.height.mas_equalTo(wButton);
    }];
    [self customButton: btnKeypad withImage: [UIImage imageNamed:@"ic_keyboard_white"] selectedImage: [UIImage imageNamed:@"ic_keyboard_black"] disableImage: [UIImage imageNamed:@"ic_keyboard_gray"] cornerRadius: buttonRadius];
    [self setButton:btnKeypad selected:NO];
    btnKeypad.enabled = NO;
    [btnKeypad addTarget:self
                  action:@selector(onNumpadClick)
        forControlEvents:UIControlEventTouchUpInside];
    
    lbKeypad.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Keypad"];
    lbKeypad.backgroundColor = UIColor.clearColor;
    lbKeypad.font = [UIFont fontWithName:HelveticaNeue size:15.0];
    [lbKeypad mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnKeypad.mas_bottom);
        make.centerX.equalTo(btnKeypad.mas_centerX);
        make.height.mas_equalTo(hLabel);
        make.width.mas_equalTo(wButton + marginButton);
    }];
    
    
    //  mute button
    [btnMute mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnKeypad);
        make.right.equalTo(btnKeypad.mas_left).offset(-marginButton);
        make.width.height.mas_equalTo(wButton);
    }];
    [self customButton:btnMute withImage:[UIImage imageNamed:@"ic_muted_white"] selectedImage:[UIImage imageNamed:@"ic_muted_black"] disableImage:[UIImage imageNamed:@"ic_muted_gray"] cornerRadius:buttonRadius];
    [self setButton:btnMute selected:NO];
    btnMute.enabled = NO;
    btnMute.delegate = self;
    
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
    [btnSpeaker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnKeypad);
        make.left.equalTo(btnKeypad.mas_right).offset(marginButton);
        make.width.height.mas_equalTo(wButton);
    }];
    [self customButton:btnSpeaker withImage:[UIImage imageNamed:@"ic_speaker_white"] selectedImage:[UIImage imageNamed:@"ic_speaker_black"] disableImage:[UIImage imageNamed:@"ic_speaker_gray"] cornerRadius:buttonRadius];
    [self setButton:btnSpeaker selected:NO];
    btnSpeaker.enabled = NO;
    btnSpeaker.delegate = self;
    
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
    [btnHoldCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbKeypad.mas_bottom).offset(20.0);
        make.centerX.equalTo(scvButtons.mas_centerX);
        make.width.height.mas_equalTo(wButton);
    }];
    [self customButton:btnHoldCall withImage:[UIImage imageNamed:@"ic_pause_call_white"] selectedImage:[UIImage imageNamed:@"ic_pause_call_black"] disableImage:[UIImage imageNamed:@"ic_pause_call_gray"] cornerRadius:buttonRadius];
    [self setButton:btnHoldCall selected:NO];
    btnHoldCall.enabled = NO;
    btnHoldCall.delegate = self;
    
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
    [btnAddCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnHoldCall);
        make.right.equalTo(btnHoldCall.mas_left).offset(-marginButton);
        make.width.height.mas_equalTo(wButton);
    }];
    [self customButton:btnAddCall withImage:[UIImage imageNamed:@"ic_add_call_white"] selectedImage:[UIImage imageNamed:@"ic_add_call_black"] disableImage:[UIImage imageNamed:@"ic_add_call_gray"] cornerRadius:buttonRadius];
    [self setButton:btnAddCall selected:NO];
    btnAddCall.enabled = NO;
    [btnAddCall addTarget:self
                  action:@selector(onAddCallClick:)
        forControlEvents:UIControlEventTouchUpInside];
    
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
    [btnTransfer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnHoldCall);
        make.left.equalTo(btnHoldCall.mas_right).offset(marginButton);
        make.width.height.mas_equalTo(wButton);
    }];
    [self customButton:btnTransfer withImage:[UIImage imageNamed:@"ic_transfer_call_white"] selectedImage:[UIImage imageNamed:@"ic_transfer_call_black"] disableImage:[UIImage imageNamed:@"ic_transfer_call_gray"] cornerRadius:buttonRadius];
    [self setButton:btnTransfer selected:NO];
    btnTransfer.enabled = NO;
    
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
    [self customButton:btnHangupCall withImage:nil selectedImage:nil disableImage:nil cornerRadius:buttonRadius];
    btnHangupCall.imageEdgeInsets = UIEdgeInsetsMake(19.0, 19.0, 19.0, 19.0);
    float hBottom = (self.frame.size.height - hButtonsView)/2;
    
    [btnHangupCall setImage:[UIImage imageNamed:@"ic_end_call_white"] forState:UIControlStateNormal];
    btnHangupCall.backgroundColor = [UIColor colorWithRed:(216/255.0) green:(0/255.0)
                                                     blue:(39.0/255.0) alpha:1.0];
    [btnHangupCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.bottom.equalTo(self).offset(-hBottom/2 + wButton/2);
        make.width.height.mas_equalTo(wButton);
    }];
    
    
    //  quality
    lbQuality.text = @"";
    lbQuality.backgroundColor = UIColor.clearColor;
    lbQuality.font = [UIFont systemFontOfSize:24.0 weight:UIFontWeightThin];
    lbQuality.textColor = UIColor.whiteColor;
    lbQuality.textAlignment = NSTextAlignmentCenter;
    [lbQuality mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(scvButtons.mas_top).offset(-20.0);
        make.left.right.equalTo(scvButtons);
        make.height.mas_equalTo(40.0);
    }];
    
    //  header
    lbName.text = @"";
    lbName.font = [UIFont systemFontOfSize:32.0 weight:UIFontWeightThin];
    [lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(50.0);
        make.left.equalTo(self).offset(padding);
        make.right.equalTo(self).offset(-padding);
        make.height.mas_equalTo(40.0);
    }];
    
    lbPhone.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightThin];
    [lbPhone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbName.mas_bottom).offset(10.0);
        make.left.equalTo(self).offset(padding);
        make.right.equalTo(self).offset(-padding);
        make.height.mas_equalTo(40.0);
    }];
    
    lbTime.font = [UIFont systemFontOfSize:32.0 weight:UIFontWeightThin];
    [lbTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbPhone.mas_bottom).offset(5.0);
        make.left.right.equalTo(lbPhone);
        make.height.mas_equalTo(30.0);
    }];
    
    icShink.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    [icShink mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(padding);
        make.right.equalTo(self).offset(-padding);
        make.width.height.mas_equalTo(40.0);
    }];
    
    //  set text is calling for first
    lbTime.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Calling"];
    lbTime.textColor = UIColor.whiteColor;
    
    [self finishLoaded];
}

- (void)showInView:(UIView *)aView animated:(BOOL)animated {
    //Add transparent
    //  _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopupViewWhenTagOut)];
    UIView *viewBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    viewBackground.backgroundColor = UIColor.blackColor;
    viewBackground.alpha = 0.5;
    viewBackground.tag = 20;
    [aView addSubview:viewBackground];
    
    //  [viewBackground addGestureRecognizer:_tapGesture];
    
    [aView addSubview:self];
    if (animated) {
        [self fadeIn];
    }
    
    [self showCallInformation];
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


- (void)onAddCallClick: (UIButton *)sender
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__]
                         toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    if (![LinphoneAppDelegate sharedInstance].enableForTest) {
        [self makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"This feature have not supported yet. Please try later!"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    DialerView *view = VIEW(DialerView);
    [view setAddress:@""];
    LinphoneManager.instance.nextCallIsTransfer = NO;
    [PhoneMainView.instance changeCurrentView:view.compositeViewDescription];
}

- (void)showCallInformation {
    int count = linphone_core_get_calls_nb([LinphoneManager getLc]);
    if (count > 0) {
        phoneNumber = [self getPhoneNumberOfCall];
    }
    
    //  [Khai le - 03/11/2018]
    PhoneObject *contact = [ContactUtils getContactPhoneObjectWithNumber: phoneNumber];
    if (![AppUtils isNullOrEmpty: contact.avatar]) {
        imgAvatar.image = [UIImage imageWithData: [NSData dataFromBase64String:contact.avatar]];
    }else{
        imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
    }
    
    if (contact.phoneType == ePBXPhone) {
        //  Download avatar of user if exists
        [self checkToDownloadAvatarOfUser: phoneNumber];
    }
    
    LinphoneManager.instance.nextCallIsTransfer = NO;
    lbName.text = @"";
    
    // Update on show
    [self callDurationUpdate];
    [self onCurrentCallChange];
    
    // Enable tap
    //  [Khai Le - 18/01/2019]
    //  singleFingerTap.enabled = YES;
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(bluetoothAvailabilityUpdateEvent:)
                                               name:kLinphoneBluetoothAvailabilityUpdate object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(callUpdateEvent:)
                                               name:kLinphoneCallUpdate object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(headsetPluginChanged:)
                                               name:@"headsetPluginChanged" object:nil];
    //  Update address
    [self updateAddress];
    
    //  [Khai Le]
    //  [self btnHideKeypadPressed];
    
    if (count == 0) {
        lbTime.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Calling"];
        lbTime.textColor = UIColor.whiteColor;
    }else{
        LinphoneCall *curCall = linphone_core_get_current_call([LinphoneManager getLc]);
        if (curCall == NULL) {
            [self closeTimer];
            [self hideCallView];
        }else{
            LinphoneCallState callState = (curCall != NULL) ? linphone_call_get_state(curCall) : 0;
            if (callState == LinphoneCallOutgoingProgress) {
                lbTime.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Calling"];
                lbTime.textColor = UIColor.whiteColor;
            }
            callDirection = linphone_call_get_dir(curCall);
            if (callDirection == LinphoneCallIncoming) {
                [self countUpTimeForCall];
                [self updateQualityForCall];
            }
        }
    }
}

- (void)updateQualityForCall {
    if (qualityTimer != nil) {
        [qualityTimer invalidate];
        qualityTimer = nil;
    }
    [self callQualityUpdate];
    qualityTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(callQualityUpdate) userInfo:nil repeats:YES];
}

//  Call quality
- (void)callQualityUpdate {
    LinphoneCall *call = linphone_core_get_current_call([LinphoneManager getLc]);
    if (call == NULL) {
        if (qualityTimer != nil) {
            [qualityTimer invalidate];
            qualityTimer = nil;
        }
        return;
    }
    //FIXME double check call state before computing, may cause core dump
    float quality = linphone_call_get_average_quality(call);
    if (quality < 0) {
        //  Hide call quality value if have not connected yet
        //  [Khai Le]
        //  viewKeypad.lbQualityValue.hidden = YES;
    }else if(quality < 1) {
        NSString *qualityValue = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Worse"];
        NSString *quality = [NSString stringWithFormat:@"%@: %@", [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Quality"], qualityValue];
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString: quality];
        [attr addAttribute:NSForegroundColorAttributeName value:UIColor.whiteColor range:NSMakeRange(0, quality.length)];
        [attr addAttribute:NSForegroundColorAttributeName value:UIColor.redColor range:NSMakeRange(quality.length-qualityValue.length, qualityValue.length)];
        
        lbQuality.attributedText = attr;
        //  [Khai Le]
        //  viewKeypad.lbQualityValue.attributedText = attr;
        //  viewKeypad.lbQualityValue.hidden = NO;
        
    } else if (quality < 2) {
        NSString *qualityValue = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Very low"];
        NSString *quality = [NSString stringWithFormat:@"%@: %@", [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Quality"], qualityValue];
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString: quality];
        [attr addAttribute:NSForegroundColorAttributeName value:UIColor.whiteColor range:NSMakeRange(0, quality.length)];
        [attr addAttribute:NSForegroundColorAttributeName value:UIColor.orangeColor range:NSMakeRange(quality.length-qualityValue.length, qualityValue.length)];
        
        lbQuality.attributedText = attr;
        //  [Khai Le]
        //  viewKeypad.lbQualityValue.attributedText = attr;
        //  viewKeypad.lbQualityValue.hidden = NO;
        
    } else if (quality < 3) {
        NSString *qualityValue = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Low"];
        NSString *quality = [NSString stringWithFormat:@"%@: %@", [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Quality"], qualityValue];
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString: quality];
        [attr addAttribute:NSForegroundColorAttributeName value:UIColor.whiteColor range:NSMakeRange(0, quality.length)];
        [attr addAttribute:NSForegroundColorAttributeName value:UIColor.whiteColor range:NSMakeRange(quality.length-qualityValue.length, qualityValue.length)];
        
        lbQuality.attributedText = attr;
        //  [Khai Le]
        //  viewKeypad.lbQualityValue.attributedText = attr;
        //  viewKeypad.lbQualityValue.hidden = NO;
        
    } else if(quality < 4){
        NSString *qualityValue = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Average"];
        NSString *quality = [NSString stringWithFormat:@"%@: %@", [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Quality"], qualityValue];
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString: quality];
        [attr addAttribute:NSForegroundColorAttributeName value:UIColor.whiteColor range:NSMakeRange(0, quality.length)];
        [attr addAttribute:NSForegroundColorAttributeName value:UIColor.greenColor range:NSMakeRange(quality.length-qualityValue.length, qualityValue.length)];
        
        lbQuality.attributedText = attr;
        //  [Khai Le]
        //  viewKeypad.lbQualityValue.attributedText = attr;
        //  viewKeypad.lbQualityValue.hidden = NO;
        
    } else{
        NSString *qualityValue = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Good"];
        NSString *quality = [NSString stringWithFormat:@"%@: %@", [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Quality"], qualityValue];
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString: quality];
        [attr addAttribute:NSForegroundColorAttributeName value:UIColor.whiteColor range:NSMakeRange(0, quality.length)];
        [attr addAttribute:NSForegroundColorAttributeName value:UIColor.greenColor range:NSMakeRange(quality.length-qualityValue.length, qualityValue.length)];
        
        lbQuality.attributedText = attr;
        //  [Khai Le]
        //  viewKeypad.lbQualityValue.attributedText = attr;
        //  viewKeypad.lbQualityValue.hidden = NO;
    }
}

- (void)updateAddress {
    //  [Khai Le]
    //  [self view]; //Force view load
    PhoneObject *contact = [ContactUtils getContactPhoneObjectWithNumber: phoneNumber];
    
    if ([phoneNumber isEqualToString:hotline]) {
        imgAvatar.image = [UIImage imageNamed:@"hotline_avatar.png"];
    }else{
        if ([AppUtils isNullOrEmpty: contact.avatar]) {
            imgAvatar.image = nil;
            bgTransparent.backgroundColor = [UIColor colorWithRed:(20/255.0) green:(20/255.0)
                                                             blue:(20/255.0) alpha:1.0];
        }else{
            imgAvatar.image = [UIImage imageWithData:[NSData dataFromBase64String: contact.avatar]];
            bgTransparent.backgroundColor = [UIColor colorWithRed:(20/255.0) green:(20/255.0)
                                                             blue:(20/255.0) alpha:0.7];
        }
    }
    lbName.text = contact.name;
    lbPhone.text = phoneNumber;
}

- (void)countUpTimeForCall {
    if (durationTimer != nil) {
        [durationTimer invalidate];
        durationTimer = nil;
    }
    durationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self
                                                   selector:@selector(callDurationUpdate)
                                                   userInfo:nil repeats:YES];
}

- (void)checkToDownloadAvatarOfUser: (NSString *)phone
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] phone number = %@", __FUNCTION__, phone] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    if (phone.length > 9 || [phone isEqualToString:hotline]) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *pbxServer = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_SERVER];
        NSString *avatarName = [NSString stringWithFormat:@"%@_%@.png", pbxServer, phone];
        NSString *linkAvatar = [NSString stringWithFormat:@"%@/%@", link_picture_chat_group, avatarName];
        NSData *data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: linkAvatar]];
        
        if (data != nil) {
            NSString *folder = [NSString stringWithFormat:@"/avatars/%@", avatarName];
            [AppUtils saveFileToFolder:data withName: folder];
            
            //  set avatar value for pbx contact list if exists
            PBXContact *contact = [AppUtils getPBXContactFromListWithPhoneNumber: phoneNumber];
            if (contact != nil) {
                if ([data respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
                    contact._avatar = [data base64EncodedStringWithOptions: 0];
                } else {
                    contact._avatar = [data base64Encoding];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^(void){
                imgAvatar.image = [UIImage imageWithData: data];
            });
        }
    });
}

- (void)finishLoaded {
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    UIDevice.currentDevice.proximityMonitoringEnabled = YES;
    
    [PhoneMainView.instance setVolumeHidden:TRUE];
    
    // we must wait didAppear to reset fullscreen mode because we cannot change it in viewwillappear
    LinphoneCall *call = linphone_core_get_current_call(LC);
    LinphoneCallState state = (call != NULL) ? linphone_call_get_state(call) : 0;
    [self callUpdate:call state:state animated:FALSE message:@""];
    
    [self requestAccessToMicroIfNot];
}

- (void)requestAccessToMicroIfNot
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__]
                         toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    //show warning Microphone
    if (IS_IOS7) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted){
            if (granted) {
                NSLog(@"granted");
            } else {
                NSLog(@"denied");
            }
        }];
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted){
            if (granted) {
                NSLog(@"granted");
            } else {
                NSLog(@"denied");
            }
        }];
    }
}

- (NSString *)getPhoneNumberOfCall {
    __block NSString *addressPhoneNumber = @"";
    LinphoneCall* call = linphone_core_get_current_call([LinphoneManager getLc]);
    if (call != NULL) {
        const LinphoneAddress* addr = linphone_call_get_remote_address(call);
        if (addr != NULL) {
            // contact name
            char* lAddress = linphone_address_as_string_uri_only(addr);
            if(lAddress) {
                NSString *normalizedSipAddress = [SipUtils normalizeSipURI:[NSString stringWithUTF8String:lAddress]];
                NSRange range = NSMakeRange(3, [normalizedSipAddress rangeOfString:@"@"].location - 3);
                NSString *tmp = [normalizedSipAddress substringWithRange:range];
                // tmp: -> :8889998007
                if (tmp.length > 2) {
                    NSString *phoneStr = [tmp substringFromIndex: 1];
                    addressPhoneNumber = [[NSString alloc] initWithString: phoneStr];
                    return addressPhoneNumber;
                }
                ms_free(lAddress);
            }
        }
    }
    return @"";
}

- (void)callDurationUpdate
{
    int duration;
    LinphoneCall* call = linphone_core_get_current_call([LinphoneManager getLc]);
    if (call != NULL) {
        duration = linphone_call_get_duration(call);
        lbTime.text = [LinphoneUtils durationToString:duration];
        lbTime.textColor = UIColor.greenColor;
        lbQuality.hidden = NO;
    }else{
        duration = 0;
        lbQuality.hidden = YES;
    }
}

- (void)onCurrentCallChange {
    LinphoneCall *call = linphone_core_get_current_call(LC);
    
    BOOL check = !call && !linphone_core_is_in_conference(LC);
    if (check) {
        btnHoldCall.selected = YES;
    }else{
        btnHoldCall.selected = NO;
    }
    [btnHoldCall setType:UIPauseButtonType_CurrentCall call:call];
}

#pragma mark - Headphone plugin changed
- (void)headsetPluginChanged: (NSNotification *)notif {
    if (notif.object != nil && [notif.object isKindOfClass:[NSNumber class]]) {
        int routeChangeReason = [notif.object intValue];
        if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
            if (needEnableSpeaker) {
                [btnSpeaker setOn];
                btnSpeaker.selected = YES;
            }else{
                [btnSpeaker setOff];
                btnSpeaker.selected = NO;
            }
            [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        }
        if (routeChangeReason == kAudioSessionRouteChangeReason_NewDeviceAvailable) {
            needEnableSpeaker = btnSpeaker.isEnabled;
            [btnSpeaker setOff];
            btnSpeaker.selected = NO;
            
            [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] routeChangeReason == kAudioSessionRouteChangeReason_NewDeviceAvailable", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        }
    }
}

#pragma mark - Event Functions

- (void)hideSpeaker:(BOOL)hidden {
    btnSpeaker.hidden = hidden;
    //  [Khai Le]
    //  _routesButton.hidden = !hidden;
}

- (void)bluetoothAvailabilityUpdateEvent:(NSNotification *)notif {
    dispatch_async(dispatch_get_main_queue(), ^{
        bool available = [[notif.userInfo objectForKey:@"available"] intValue];
        [self hideSpeaker:available];
    });
}

- (void)callUpdateEvent:(NSNotification *)notif {
    NSString *message = [notif.userInfo objectForKey:@"message"];
    LinphoneCall *call = [[notif.userInfo objectForKey:@"call"] pointerValue];
    LinphoneCallState state = [[notif.userInfo objectForKey:@"state"] intValue];
    [self callUpdate:call state:state animated:TRUE message: message];
}

- (void)callUpdate:(LinphoneCall *)call state:(LinphoneCallState)state animated:(BOOL)animated message: (NSString *)message
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] The current call state is %d, with message = %@", __FUNCTION__, state, message] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    // Add tất cả các cuộc gọi vào nhóm
    int numOfCalls = linphone_core_get_calls_nb(LC);
    if (numOfCalls >= 2) {
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Number call is %d. Add all call to conference", __FUNCTION__, numOfCalls] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        
        linphone_core_add_all_to_conference([LinphoneManager getLc]);
    }
    
    //  [Khai Le]
    //  [self updateBottomBar:call state:state];
    //  [self btnHideKeypadPressed];
    
    static LinphoneCall *currentCall = NULL;
    if (!currentCall || linphone_core_get_current_call(LC) != currentCall) {
        currentCall = linphone_core_get_current_call(LC);
        [self onCurrentCallChange];
    }
    
    // Fake call update
    if (call == NULL) {
        return;
    }
    
    if (state != LinphoneCallPausedByRemote) {
        //  [Khai Le]
        //  _pausedByRemoteView.hidden = YES;
    }
    
    switch (state) {
        case LinphoneCallOutgoingRinging:{
            lbTime.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Ringing"];
            lbTime.textColor = UIColor.whiteColor;
            
            [self getPhoneNumberOfCall];
            break;
        }
        case LinphoneCallIncomingReceived:{
            [self getPhoneNumberOfCall];
            NSLog(@"incomming");
            break;
        }
        case LinphoneCallOutgoingProgress:{
            lbTime.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Calling"];
            lbTime.textColor = UIColor.whiteColor;
            
            break;
        }
        case LinphoneCallOutgoingInit:{
            btnMute.enabled = YES;
            btnKeypad.enabled = YES;
            
            btnSpeaker.enabled = YES;
            [self setButton:btnSpeaker selected:YES];
            
            btnAddCall.enabled = NO;
            btnHoldCall.enabled = NO;
            btnTransfer.enabled = NO;
            
            break;
        }
        case LinphoneCallConnected:{
            //  Check if in call with hotline
            if ([phoneNumber isEqualToString:hotline]) {
                btnAddCall.enabled = NO;
                btnTransfer.enabled = NO;
            }else{
                btnAddCall.enabled = YES;
                btnTransfer.enabled = YES;
            }
            btnKeypad.enabled = YES;
            btnHoldCall.enabled = YES;
            btnMute.enabled = YES;
            
            lbQuality.hidden = NO;
            
            // Add tất cả các cuộc gọi vào nhóm
            if (linphone_core_get_calls_nb(LC) >= 2) {
                linphone_core_add_all_to_conference([LinphoneManager getLc]);
            }
            
            [self countUpTimeForCall];
            [self updateQualityForCall];
            
            break;
        }
        case LinphoneCallStreamsRunning: {
            // check video
            if (!linphone_call_params_video_enabled(linphone_call_get_current_params(call))) {
                const LinphoneCallParams *param = linphone_call_get_current_params(call);
                const LinphoneCallAppData *callAppData =
                (__bridge const LinphoneCallAppData *)(linphone_call_get_user_pointer(call));
                if (state == LinphoneCallStreamsRunning && callAppData->videoRequested &&
                    linphone_call_params_low_bandwidth_enabled(param)) {
                }
            }
            btnAddCall.enabled = YES;
            btnKeypad.enabled = YES;
            btnHoldCall.enabled = YES;
            btnMute.enabled = YES;
            btnTransfer.enabled = YES;
            
            // Add tất cả các cuộc gọi vào nhóm
            if (linphone_core_get_calls_nb(LC) >= 2) {
                linphone_core_add_all_to_conference([LinphoneManager getLc]);
            }
            
            break;
        }
        case LinphoneCallUpdatedByRemote: {
            const LinphoneCallParams *current = linphone_call_get_current_params(call);
            const LinphoneCallParams *remote = linphone_call_get_remote_params(call);
            
            /* remote wants to add video */
            if ((linphone_core_video_display_enabled(LC) && !linphone_call_params_video_enabled(current) &&
                 linphone_call_params_video_enabled(remote)) &&
                (!linphone_core_get_video_policy(LC)->automatically_accept ||
                 (([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) &&
                  floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max))) {
                     linphone_core_defer_call_update(LC, call);
                     
                 } else if (linphone_call_params_video_enabled(current) && !linphone_call_params_video_enabled(remote)) {
                     
                 }
            break;
        }
        case LinphoneCallPausing:
        case LinphoneCallPaused:{
            break;
        }
        case LinphoneCallPausedByRemote:
            if (call == linphone_core_get_current_call(LC)) {
                //  _pausedByRemoteView.hidden = NO;
            }
            break;
        case LinphoneCallEnd:{
            [self closeTimer];
            
            [self performSelector:@selector(hideCallView) withObject:nil afterDelay:2.0];
            
            break;
        }
        case LinphoneCallError:{
            [self closeTimer];
            
            [self displayCallError:call message:message];
            [self performSelector:@selector(hideCallView) withObject:nil afterDelay:2.0];
            break;
        }
        case LinphoneCallReleased:{
            [self closeTimer];
            
            [self performSelector:@selector(hideCallView) withObject:nil afterDelay:2.0];
            break;
        }
        default:
            break;
    }
}

- (void)closeTimer {
    if (durationTimer != nil) {
        [durationTimer invalidate];
        durationTimer = nil;
    }
    if (qualityTimer != nil) {
        [qualityTimer invalidate];
        qualityTimer = nil;
    }
}

- (void)hideCallView {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"%s", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    [self hideMiniKeypad];
    
    int count = linphone_core_get_calls_nb([LinphoneManager getLc]);
    if (count == 0) {
        if (durationTimer != nil) {
            [durationTimer invalidate];
            durationTimer = nil;
        }
        phoneNumber = @"";
        
        // Remove observer
        [NSNotificationCenter.defaultCenter removeObserver:self];
    }else{
        NSLog(@"Van con call ne");
    }
    
    [self fadeOut];
    if ([LinphoneAppDelegate sharedInstance].callTransfered) {
        [LinphoneAppDelegate sharedInstance].callTransfered = NO;
        
        [[LinphoneAppDelegate sharedInstance].window makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Your call has been transfered"] duration:3.0 position:CSToastPositionCenter];
    }
}

- (void)hideMiniKeypad
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__]
                         toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    for (UIView *subView in self.subviews) {
        if (subView.tag == MINI_KEYPAD_TAG) {
            [UIView animateWithDuration:.35 animations:^{
                subView.transform = CGAffineTransformMakeScale(1.3, 1.3);
                subView.alpha = 0.0;
            } completion:^(BOOL finished) {
                if (finished) {
                    [subView removeFromSuperview];
                }
            }];
        }
    }
    btnKeypad.selected = NO;
}

- (void)displayCallError:(LinphoneCall *)call message:(NSString *)message
{
    if (call != NULL) {
        const char *lUserNameChars = linphone_address_get_username(linphone_call_get_remote_address(call));
        NSString *lUserName =
        lUserNameChars ? [[NSString alloc] initWithUTF8String:lUserNameChars] : NSLocalizedString(@"Unknown", nil);
        NSString *lMessage;
        
        switch (linphone_call_get_reason(call)) {
            case LinphoneReasonNotFound:
                lMessage = [NSString stringWithFormat:NSLocalizedString(@"%@ is not registered.", nil), lUserName];
                break;
            case LinphoneReasonBusy:
                lbTime.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"The user is busy"];
                lbTime.textColor = UIColor.whiteColor;
                break;
            default:
                if (message != nil) {
                    lMessage = [NSString stringWithFormat:NSLocalizedString(@"%@\nReason was: %@", nil), lMessage, message];
                }
                break;
        }
    }
}

- (void)onNumpadClick
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Show mini keyboard", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    NSArray *toplevelObject = [[NSBundle mainBundle] loadNibNamed:@"UIMiniKeypad" owner:nil options:nil];
    
    for(id currentObject in toplevelObject){
        if ([currentObject isKindOfClass:[UIMiniKeypad class]]) {
            viewKeypad = (UIMiniKeypad *) currentObject;
            break;
        }
    }
    
    viewKeypad.tag = MINI_KEYPAD_TAG;
    [viewKeypad.zeroButton setDigit:'0'];
    [viewKeypad.zeroButton setDtmf:true] ;
    [viewKeypad.oneButton    setDigit:'1'];
    [viewKeypad.oneButton setDtmf:true];
    [viewKeypad.twoButton    setDigit:'2'];
    [viewKeypad.twoButton setDtmf:true];
    [viewKeypad.threeButton  setDigit:'3'];
    [viewKeypad.threeButton setDtmf:true];
    [viewKeypad.fourButton   setDigit:'4'];
    [viewKeypad.fourButton setDtmf:true];
    [viewKeypad.fiveButton   setDigit:'5'];
    [viewKeypad.fiveButton setDtmf:true];
    [viewKeypad.sixButton    setDigit:'6'];
    [viewKeypad.sixButton setDtmf:true];
    [viewKeypad.sevenButton  setDigit:'7'];
    [viewKeypad.sevenButton setDtmf:true];
    [viewKeypad.eightButton  setDigit:'8'];
    [viewKeypad.eightButton setDtmf:true];
    [viewKeypad.nineButton   setDigit:'9'];
    [viewKeypad.nineButton setDtmf:true];
    [viewKeypad.starButton   setDigit:'*'];
    [viewKeypad.starButton setDtmf:true];
    [viewKeypad.sharpButton  setDigit:'#'];
    [viewKeypad.sharpButton setDtmf:true];
    viewKeypad.backgroundColor = UIColor.clearColor;
    
    [self addSubview:viewKeypad];
    [self fadeIn:viewKeypad];
    
    
    [viewKeypad mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self);
    }];
    [viewKeypad setupUIForView];
    
    [viewKeypad.iconBack addTarget:self
                            action:@selector(hideMiniKeypad)
                  forControlEvents:UIControlEventTouchUpInside];
    
    [viewKeypad.iconMiniKeypadEndCall addTarget:self
                                         action:@selector(endCallInMiniKeypad)
                               forControlEvents:UIControlEventTouchUpInside];
    
    [self callQualityUpdate];
}

- (void)endCallInMiniKeypad {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__]
                         toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    linphone_core_terminate_all_calls(LC);
}

- (void)fadeIn :(UIView*)view{
    view.transform = CGAffineTransformMakeScale(1.3, 1.3);
    view.alpha = 0.0;
    [UIView animateWithDuration:.35 animations:^{
        view.transform = CGAffineTransformMakeScale(1.0, 1.0);
        view.alpha = 1.0;
    }];
}

- (IBAction)btnTransferPressed:(UIButton *)sender
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Show transfer call view", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    NSArray *toplevelObject = [[NSBundle mainBundle] loadNibNamed:@"iPadTransferCallView" owner:nil options:nil];
    for(id currentObject in toplevelObject){
        if ([currentObject isKindOfClass:[iPadTransferCallView class]]) {
            viewTransferCall = (iPadTransferCallView *) currentObject;
            break;
        }
    }
    
    viewTransferCall.tag = MINI_TRANSFER_CALL_VIEW_TAG;
    [viewTransferCall.zeroButton setDigit:'0'];
    [viewTransferCall.oneButton    setDigit:'1'];
    [viewTransferCall.twoButton    setDigit:'2'];
    [viewTransferCall.threeButton  setDigit:'3'];
    [viewTransferCall.fourButton   setDigit:'4'];
    [viewTransferCall.fiveButton   setDigit:'5'];
    [viewTransferCall.sixButton    setDigit:'6'];
    [viewTransferCall.sevenButton  setDigit:'7'];
    [viewTransferCall.eightButton  setDigit:'8'];
    [viewTransferCall.nineButton   setDigit:'9'];
    [viewTransferCall.starButton   setDigit:'*'];
    [viewTransferCall.sharpButton  setDigit:'#'];
    
    [self addSubview:viewTransferCall];
    [self fadeIn:viewTransferCall];
    
    
    [viewTransferCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self);
    }];
    [viewTransferCall setupUIForView];
    
    [viewTransferCall.backToCallButton addTarget:self
                                          action:@selector(hideTransferCallView)
                                forControlEvents:UIControlEventTouchUpInside];
}

- (void)hideTransferCallView
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__]
                         toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    for (UIView *subView in self.subviews) {
        if (subView.tag == MINI_TRANSFER_CALL_VIEW_TAG) {
            [UIView animateWithDuration:.35 animations:^{
                subView.transform = CGAffineTransformMakeScale(1.3, 1.3);
                subView.alpha = 0.0;
            } completion:^(BOOL finished) {
                if (finished) {
                    [subView removeFromSuperview];
                }
            }];
        }
    }
}

- (IBAction)btnHangupCallPressed:(UIButton *)sender {
    // Bien cho biết mình kết thúc cuộc gọi
    [LinphoneAppDelegate sharedInstance]._meEnded = YES;
    
    return;
    [btnHangupCall setImage:[UIImage imageNamed:@"ic_end_call_red"] forState:UIControlStateNormal];
    btnHangupCall.backgroundColor = UIColor.whiteColor;
    
    [self performSelector:@selector(resetStateOfHangupCallButton) withObject:nil afterDelay:0.05];
}

- (void)resetStateOfHangupCallButton {
    [btnHangupCall setImage:[UIImage imageNamed:@"ic_end_call_white"] forState:UIControlStateNormal];
    btnHangupCall.backgroundColor = [UIColor colorWithRed:(216/255.0) green:(0/255.0)
                                                     blue:(39.0/255.0) alpha:1.0];
    linphone_core_terminate_all_calls(LC);
}

#pragma mark - UISpeakerButton Delegate
- (void)onSpeakerStateChangedTo:(BOOL)speaker {
    [self setButton:btnSpeaker selected:speaker];
}

- (void)onMuteStateChangedTo:(BOOL)muted {
    [self setButton:btnMute selected:muted];
}

- (void)onPauseStateChangedTo:(BOOL)paused {
    [self setButton:btnHoldCall selected:paused];
}

@end
