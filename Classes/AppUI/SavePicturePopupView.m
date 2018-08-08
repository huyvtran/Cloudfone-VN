//
//  SavePicturePopupView.m
//  linphone
//
//  Created by Hung Ho on 9/7/17.
//
//

#import "SavePicturePopupView.h"

@implementation SavePicturePopupView

@synthesize _btnNo, _btnYes, _lbContent, _tapGesture;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor whiteColor]];
        [self.layer setBorderWidth: 3.0];
        [self.layer setBorderColor: [UIColor colorWithRed:(24/255.0) green:(185/255.0)
                                                     blue:(153/255.0) alpha:1.0].CGColor];
        
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
        lbTitle.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:CN_ALERT_POPUP_SAVE_PICTURE_TITLE];
        [viewHeader addSubview: lbTitle];
        [self addSubview: viewHeader];

        //  Adds
        _lbContent = [[UILabel alloc] initWithFrame:CGRectMake(10, viewHeader.frame.origin.y+viewHeader.frame.size.height+10, frame.size.width-20-10, frame.size.height-8-40-20-35)];
        _lbContent.font = [UIFont fontWithName:@"MYRIADPRO-REGULAR" size:16.0];
        _lbContent.backgroundColor = UIColor.clearColor;
        _lbContent.textAlignment = NSTextAlignmentCenter;
        _lbContent.numberOfLines = 5;
        _lbContent.textColor = [UIColor colorWithRed:(12/255.0) green:(39/255.0)
                                                blue:(50/255.0) alpha:1];
        _lbContent.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:CN_ALERT_POPUP_SAVE_PICTURE_CONTENT];
        [self addSubview: _lbContent];
        
        //  Add button yes
        float buttonWidth = (frame.size.width-8-2)/2;
        _btnYes = [[UIButton alloc] initWithFrame: CGRectMake(4, frame.size.height-35-4, buttonWidth, 35)];
        [_btnYes setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_yes] forState:UIControlStateNormal];
        _btnYes.backgroundColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                   blue:(200/255.0) alpha:1.0];
        _btnYes.titleLabel.font = [UIFont fontWithName:HelveticaNeueBold size:16.0];
        _btnYes.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [_btnYes addTarget:self
                    action:@selector(whenButtonTouchDown:)
          forControlEvents:UIControlEventTouchDown];
        [self addSubview: _btnYes];
        
        //  Add button no
        _btnNo = [[UIButton alloc] initWithFrame: CGRectMake(_btnYes.frame.origin.x+buttonWidth+2, _btnYes.frame.origin.y, buttonWidth, 35)];
        [_btnNo setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_no] forState:UIControlStateNormal];
        _btnNo.backgroundColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                  blue:(200/255.0) alpha:1];
        _btnNo.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _btnNo.titleLabel.font = [UIFont fontWithName:HelveticaNeueBold size:16.0];
        [_btnNo addTarget:self
                   action:@selector(whenButtonTouchDown:)
         forControlEvents:UIControlEventTouchDown];
        [_btnNo addTarget:self
                   action:@selector(fadeOut)
         forControlEvents:UIControlEventTouchUpInside];
        [self addSubview: _btnNo];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWhenShowKeyboard:)
                                                     name:UIKeyboardDidShowNotification object:nil];
    }
    return self;
}

- (void)whenButtonTouchDown: (UIButton *)sender{
    sender.backgroundColor = [UIColor colorWithRed:(223/255.0) green:(255/255.0)
                                              blue:(133/255.0) alpha:1];
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

- (void)fadeOut
{
    _btnNo.backgroundColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                              blue:(200/255.0) alpha:1];
    _btnYes.backgroundColor = _btnNo.backgroundColor;
    
    for (UIView *subView in self.window.subviews) {
        if (subView.tag == 20) {
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
