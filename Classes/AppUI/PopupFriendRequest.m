//
//  PopupFriendRequest.m
//  linphone
//
//  Created by Ei Captain on 7/7/16.
//
//

#import "PopupFriendRequest.h"

@interface PopupFriendRequest (){
    float hItem;
    UIFont *textFont;
}

@end

@implementation PopupFriendRequest
@synthesize delegate, _tfRequest, _btnSend, _btnCancel, _tapGesture, _cloudfoneID, _lbHeader;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //  MY CODE HERE
        if (SCREEN_WIDTH > 320) {
            hItem = 40.0;
            textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
        }else{
            hItem = 35.0;
            textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
        }
        self.backgroundColor = UIColor.whiteColor;
        self.layer.borderWidth = 3.0;
        self.layer.borderColor = [UIColor colorWithRed:(23/255.0) green:(184/255.0)
                                                  blue:(151/255.0) alpha:1.0].CGColor;
        
        //Add logo image
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(4, 4, frame.size.width-8, 40)];
        headerView.backgroundColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                                      blue:(230/255.0) alpha:1.0];
        
        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.height, headerView.frame.size.height)];
        logoImageView.image = [UIImage imageNamed:@"ic_offline.png"];
        [headerView addSubview: logoImageView];
        
        //Add Label
        CGRect nameLabelRect = CGRectMake(44, 0, 200, 40);
        _lbHeader = [[UILabel alloc] initWithFrame:nameLabelRect];
        _lbHeader.textColor = [UIColor colorWithRed:(138/255.0) green:(138/255.0)
                                               blue:(138/255.0) alpha:1];
        _lbHeader.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:19.0];
        _lbHeader.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:TEXT_ADD_FRIEND_TITLE];
        [headerView addSubview: _lbHeader];
        [self addSubview: headerView];
        
        //  Setup cho UITextField
        _tfRequest = [[UITextField alloc] initWithFrame:CGRectMake(15, headerView.frame.origin.y+headerView.frame.size.height+10, frame.size.width-30, hItem)];
        _tfRequest.font = textFont;
        _tfRequest.layer.borderWidth = 1.0;
        _tfRequest.layer.borderColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                        blue:(200/255.0) alpha:1.0].CGColor;
        _tfRequest.textColor = UIColor.blackColor;
        _tfRequest.placeholder = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:TEXT_PLACEHOLDER_REQUEST];
        _tfRequest.layer.cornerRadius = 4.0;
        [_tfRequest becomeFirstResponder];
        _tfRequest.delegate = self;
        [_tfRequest addTarget:self
                       action:@selector(whenTextFieldDidChanged:)
             forControlEvents:UIControlEventEditingChanged];
        
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, hItem)];
        _tfRequest.leftView = paddingView;
        _tfRequest.leftViewMode = UITextFieldViewModeAlways;
        [self addSubview:_tfRequest];
        
        [self addSubview: _tfRequest];
        
        float buttonWidth = (frame.size.width-10)/2;
        //  Button Cancel
        _btnCancel = [[UIButton alloc] initWithFrame: CGRectMake(4, _tfRequest.frame.origin.y+_tfRequest.frame.size.height+10, buttonWidth, hItem)];
        _btnCancel.backgroundColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0)
                                                      blue:(220/255.0) alpha:1.0];
        [_btnCancel setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:TEXT_CANCEL_REQUEST]
                    forState:UIControlStateNormal];
        [_btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnCancel.titleLabel.font = textFont;
        [_btnCancel addTarget:self
                       action:@selector(onClickCancelButton:)
             forControlEvents:UIControlEventTouchUpInside];
        [_btnCancel addTarget:self
                       action:@selector(buttonTouchDown:)
             forControlEvents:UIControlEventTouchDown];
        [self addSubview: _btnCancel];
        
        //  Button send
        _btnSend = [[UIButton alloc] initWithFrame: CGRectMake(_btnCancel.frame.origin.x+_btnCancel.frame.size.width+2, _btnCancel.frame.origin.y, buttonWidth, hItem)];
        _btnSend.backgroundColor = [UIColor colorWithRed:(188/255.0) green:(188/255.0)
                                                    blue:(188/255.0) alpha:1.0];
        [_btnSend setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:TEXT_SEND_REQUEST]
                    forState:UIControlStateNormal];
        [_btnSend setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnSend.titleLabel.font = textFont;
        
        [_btnSend addTarget:self
                       action:@selector(buttonTouchDown:)
             forControlEvents:UIControlEventTouchDown];
        _btnSend.enabled = NO;
        [self addSubview: _btnSend];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWhenShowKeyboard:)
                                                     name:UIKeyboardDidShowNotification object:nil];
    }
    return self;
}

- (void)showInView:(UIView *)aView animated:(BOOL)animated {
    //Add transparent
    UIView *viewBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    viewBackground.backgroundColor = UIColor.blackColor;
    viewBackground.alpha = 0.5;
    viewBackground.tag = 20;
    
    UITapGestureRecognizer *tapClose = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(fadeOut)];
    [viewBackground addGestureRecognizer: tapClose];
    
    [aView addSubview:viewBackground];
    
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
    for (UIView *subView in self.window.subviews){
        if (subView.tag == 20){
            [subView removeFromSuperview];
        }
    }
    
    [UIView animateWithDuration:.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

- (void)buttonTouchDown: (UIButton *)sender {
    sender.backgroundColor = [UIColor colorWithRed:(223/255.0) green:(255/255.0)
                                              blue:(133/255.0) alpha:1];
}

- (void)onClickCancelButton: (UIButton *)sender {
    sender.backgroundColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0)
                                              blue:(220/255.0) alpha:1.0];
    [self fadeOut];
}

- (void)notificationWhenShowKeyboard:(NSNotification*)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    float heightKeyboard = keyboardFrameBeginRect.size.height;
    self.frame = CGRectMake(self.frame.origin.x, (SCREEN_HEIGHT-20-self.frame.size.height-heightKeyboard)/2, self.frame.size.width, self.frame.size.height);
}

- (void)whenTextFieldDidChanged: (UITextField *)textfield {
    if (textfield.text.length > 0) {
        _btnSend.enabled = YES;
        _btnSend.backgroundColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0)
                                                    blue:(220/255.0) alpha:1.0];
    }else{
        _btnSend.enabled = NO;
        _btnSend.backgroundColor = [UIColor colorWithRed:(188/255.0) green:(188/255.0)
                                                    blue:(188/255.0) alpha:1.0];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 30;
}

@end
