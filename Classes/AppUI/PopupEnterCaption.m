//
//  PopupEnterCaption.m
//  linphone
//
//  Created by user on 7/11/14.
//
//

#import "PopupEnterCaption.h"

@implementation PopupEnterCaption
@synthesize _btnNo, _btnYes, _tfDesc, _tapGesture;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = UIColor.whiteColor;
        self.layer.borderWidth = 3.0;
        self.layer.borderColor = [UIColor colorWithRed:(24/255.0) green:(185/255.0)
                                                  blue:(153/255.0) alpha:1.0].CGColor;
        
        //Add logo image
        UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectMake(3, 3, self.frame.size.width-6, 40)];
        viewHeader.backgroundColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                                      blue:(230/255.0) alpha:1.0];
        
        UIImageView *imgLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, viewHeader.frame.size.height, viewHeader.frame.size.height)];
        imgLogo.image = [UIImage imageNamed:@"ic_offline.png"];
        [viewHeader addSubview: imgLogo];
        
        //Add Label
        UILabel *lbTitle = [[UILabel alloc] initWithFrame: CGRectMake(45, 0, 200, 40)];
        lbTitle.textColor = [UIColor colorWithRed:(138/255.0) green:(138/255.0)
                                             blue:(138/255.0) alpha:1];
        lbTitle.font = [UIFont fontWithName:HelveticaNeue size:18.0];
        lbTitle.textAlignment = NSTextAlignmentLeft;
        lbTitle.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_enter_caption_header];
        [viewHeader addSubview: lbTitle];
        [self addSubview: viewHeader];
        
        _tfDesc = [[UITextField alloc] initWithFrame:CGRectMake(6+5, viewHeader.frame.origin.y+viewHeader.frame.size.height+5, self.frame.size.width-12-10, 30)];
        _tfDesc.borderStyle = UITextBorderStyleRoundedRect;
        _tfDesc.layer.borderColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                                     blue:(230/255.0) alpha:1.0].CGColor;
        _tfDesc.layer.borderWidth = 1.0;
        _tfDesc.layer.cornerRadius = 4.0;
        
        if ([LinphoneAppDelegate sharedInstance].titleCaption.length > 0) {
            _tfDesc.text = [LinphoneAppDelegate sharedInstance].titleCaption;
        }else{
            _tfDesc.placeholder = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_enter_caption_desc];
        }
        _tfDesc.font = [UIFont fontWithName:HelveticaNeue size:15.0];
        [self addSubview: _tfDesc];
        
        // button yes
        float buttonWidth = (frame.size.width-10)/2;
        _btnYes = [UIButton buttonWithType: UIButtonTypeCustom];
        _btnYes.frame = CGRectMake(4, _tfDesc.frame.origin.y+_tfDesc.frame.size.height+5, buttonWidth, 35);
        _btnYes.titleLabel.font = [UIFont fontWithName:HelveticaNeueBold size:16.0];
        _btnYes.backgroundColor = [UIColor colorWithRed:(180/255.0) green:(180/255.0)
                                                   blue:(180/255.0) alpha:1.0];
        [_btnYes setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_yes] forState:UIControlStateNormal];
        [_btnYes setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [_btnYes addTarget:self
                    action:@selector(changeBackgroundButton:)
          forControlEvents:UIControlEventTouchDown];
        [self addSubview: _btnYes];
        
        // button no
        _btnNo = [UIButton buttonWithType: UIButtonTypeCustom];
        _btnNo.frame = CGRectMake(_btnYes.frame.origin.x+_btnYes.frame.size.width+2, _btnYes.frame.origin.y, buttonWidth, _btnYes.frame.size.height);
        _btnNo.titleLabel.font = [UIFont fontWithName:HelveticaNeueBold size:16.0];
        _btnNo.backgroundColor = [UIColor colorWithRed:(180/255.0) green:(180/255.0)
                                                  blue:(180/255.0) alpha:1.0];
        [_btnNo setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_no] forState:UIControlStateNormal];
        [_btnNo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnNo addTarget:self
                   action:@selector(btnCancelClicked:)
         forControlEvents:UIControlEventTouchUpInside];
        [_btnNo addTarget:self
                      action:@selector(changeBackgroundButton:)
            forControlEvents:UIControlEventTouchDown];
        [self addSubview: _btnNo];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWhenShowKeyboard:)
                                                     name:UIKeyboardDidShowNotification object:nil];
    }
    return self;
}

- (void)showInView:(UIView *)aView animated:(BOOL)animated {
    UIView *viewBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    viewBackground.backgroundColor = UIColor.blackColor;
    viewBackground.alpha = 0.5;
    viewBackground.tag = 20;
    
    UITapGestureRecognizer *tapClose = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fadeOut)];
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

- (void)btnCancelClicked: (UIButton *)sender{
    [_tfDesc resignFirstResponder];
    [self fadeOut];
}

- (void)notificationWhenShowKeyboard:(NSNotification*)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    float heightKeyboard = keyboardFrameBeginRect.size.height;
    self.frame = CGRectMake(self.frame.origin.x, (SCREEN_HEIGHT-20-self.frame.size.height-heightKeyboard)/2, self.frame.size.width, self.frame.size.height);
}

- (void)changeBackgroundButton: (UIButton *)sender{
    sender.backgroundColor = [UIColor colorWithRed:(223/255.0) green:(255/255.0)
                                              blue:(133/255.0) alpha:1];
}



@end
