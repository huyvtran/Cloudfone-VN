//
//  PopupLeaveConference.m
//  linphone
//
//  Created by Ei Captain on 7/18/16.
//
//

#import "PopupLeaveConference.h"

@implementation PopupLeaveConference
@synthesize _btnNo, _btnYes, _tapGesture, _roomName;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self) {
        UIFont *textFont;
        if (SCREEN_WIDTH > 320) {
            textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
        }else{
            textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
        }
        
        self.backgroundColor = UIColor.whiteColor;
        self.layer.borderWidth = 3.0;
        self.layer.borderColor = [UIColor colorWithRed:(24/255.0) green:(185/255.0)
                                                  blue:(153/255.0) alpha:1.0].CGColor;
        //  Add logo image
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(4, 4, frame.size.width-8, 40)];
        headerView.backgroundColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                                      blue:(230/255.0) alpha:1.0];
        
        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.height, headerView.frame.size.height)];
        logoImageView.image = [UIImage imageNamed:@"ic_offline.png"];
        [headerView addSubview: logoImageView];
        
        // Thêm label title header
        UILabel *lbTitle = [[UILabel alloc] initWithFrame: CGRectMake(45, 0, 200, 40)];
        lbTitle.textColor = [UIColor colorWithRed:(138/255.0) green:(138/255.0)
                                             blue:(138/255.0) alpha:1];
        lbTitle.font = textFont;
        lbTitle.backgroundColor = UIColor.clearColor;
        lbTitle.textAlignment = NSTextAlignmentLeft;
        lbTitle.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:TEXT_LEAVE_CONF_TITLE];
        [headerView addSubview: lbTitle];
        
        //Adds
        UILabel *lbContent = [[UILabel alloc] initWithFrame:CGRectMake(10, headerView.frame.origin.y+headerView.frame.size.height, frame.size.width-18, frame.size.height-8-40-35)];
        lbContent.font = textFont;
        lbContent.backgroundColor = UIColor.clearColor;
        lbContent.textAlignment = NSTextAlignmentCenter;
        lbContent.numberOfLines = 5;
        lbContent.textColor = UIColor.blackColor;
        lbContent.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:TEXT_LEAVE_CONF_CONTENT];
        
        //  Add button
        float buttonWidth = (frame.size.width-8-2)/2;
        _btnYes = [[UIButton alloc] initWithFrame: CGRectMake(4, frame.size.height-35-4, buttonWidth, 35)];
        _btnYes.backgroundColor = [UIColor colorWithRed:(150/255.0) green:(150/255.0)
                                                   blue:(150/255.0) alpha:1.0];
        _btnYes.titleLabel.font = textFont;
        _btnYes.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [_btnYes setTitle: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_yes]
                 forState:UIControlStateNormal];
        [_btnYes addTarget:self
                    action:@selector(whenButtonTouchDown:)
          forControlEvents:UIControlEventTouchDown];
        
        [_btnYes addTarget:self
                    action:@selector(buttonYesClicked:)
          forControlEvents:UIControlEventTouchUpInside];
        
        //Add button
        _btnNo = [[UIButton alloc] initWithFrame: CGRectMake(_btnYes.frame.origin.x+buttonWidth+2, _btnYes.frame.origin.y, buttonWidth, 35)];
        _btnNo.backgroundColor = _btnYes.backgroundColor;
        _btnNo.titleLabel.font = textFont;
        _btnNo.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [_btnNo setTitle: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_no]
                forState:UIControlStateNormal];
        [_btnNo addTarget:self
                   action:@selector(whenButtonTouchDown:)
         forControlEvents:UIControlEventTouchDown];
        [_btnNo addTarget:self
                   action:@selector(buttonNoClicked:)
         forControlEvents:UIControlEventTouchUpInside];
        
        //Add subviews to view
        [self addSubview: headerView];
        [self addSubview: lbContent];
        [self addSubview: _btnNo];
        [self addSubview: _btnYes];
    }
    return self;
}

- (void)whenButtonTouchDown: (UIButton *)sender{
    sender.backgroundColor = [UIColor colorWithRed:(223/255.0) green:(255/255.0)
                                              blue:(133/255.0) alpha:1];
}

- (void)buttonYesClicked: (UIButton *)sender {
    sender.backgroundColor = [UIColor colorWithRed:(223/255.0) green:(255/255.0)
                                              blue:(133/255.0) alpha:1];
    [self fadeOut];
    
    [[LinphoneAppDelegate sharedInstance].myBuddy.protocol leaveConference: _roomName];
}

- (void)buttonNoClicked: (UIButton *)sender {
    sender.backgroundColor = [UIColor colorWithRed:(223/255.0) green:(255/255.0)
                                              blue:(133/255.0) alpha:1];
    [self fadeOut];
}

- (void)showInView:(UIView *)aView animated:(BOOL)animated {
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                          action:@selector(closePopupViewWhenTagOut)];
    
    UIView *viewBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    viewBackground.backgroundColor = UIColor.blackColor;
    viewBackground.alpha = 0.5;
    viewBackground.tag = 20;
    [viewBackground addGestureRecognizer:_tapGesture];
    
    [aView addSubview:viewBackground];
    
    [aView addSubview:self];
    if (animated) {
        [self fadeIn];
    }
}

- (void)closePopupViewWhenTagOut{
    [self fadeOut];
    [self.superview removeGestureRecognizer:_tapGesture];
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


@end
