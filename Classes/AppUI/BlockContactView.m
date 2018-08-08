//
//  BlockContactView.m
//  linphone
//
//  Created by Ei Captain on 7/7/16.
//
//

#import "BlockContactView.h"

@implementation BlockContactView
@synthesize _btnCancel, _btnYes, _tapGesture, _typePopup, _lbContent;

- (id)initWithFrame: (CGRect)frame {
    self = [super initWithFrame: frame];
    if (self)
    {
        UIFont *textFont;
        if (SCREEN_WIDTH > 320) {
            textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
        }else{
            textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
        }
        
        //  my code here
        self.backgroundColor = UIColor.whiteColor;
        self.layer.borderWidth = 3.0;
        self.layer.borderColor = [UIColor colorWithRed:(23/255.0) green:(184/255.0)
                                                  blue:(151/255.0) alpha:1.0].CGColor;
        
        //  Add logo image
        UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectMake(4, 4, frame.size.width-8, 40)];
        viewHeader.backgroundColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                                      blue:(230/255.0) alpha:1.0];
        
        UIImageView *imgLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, viewHeader.frame.size.height, viewHeader.frame.size.height)];
        imgLogo.image = [UIImage imageNamed:@"ic_offline.png"];
        [viewHeader addSubview: imgLogo];
        
        // Add Label title
        UILabel *lbTitle = [[UILabel alloc] initWithFrame: CGRectMake(45, 0, 200, 40)];
        lbTitle.textColor = UIColor.darkGrayColor;
        lbTitle.font = textFont;
        lbTitle.backgroundColor = UIColor.clearColor;
        lbTitle.textAlignment = NSTextAlignmentLeft;
        lbTitle.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:TEXT_CONFIRM];
        
        //Adds
        _lbContent = [[UILabel alloc] initWithFrame:CGRectMake(9, viewHeader.frame.origin.y+viewHeader.frame.size.height + 10, frame.size.width-18, frame.size.height-8-40-35 - 20)];
        _lbContent.font = textFont;
        _lbContent.backgroundColor = UIColor.clearColor;
        _lbContent.textAlignment = NSTextAlignmentCenter;
        _lbContent.numberOfLines = 5;
        _lbContent.textColor = UIColor.blackColor;
        
        //Add button
        float buttonWidth = (frame.size.width-8-2)/2;
        _btnYes = [[UIButton alloc] initWithFrame: CGRectMake(4, frame.size.height-35-4, buttonWidth, 35)];
        _btnYes.backgroundColor = [UIColor colorWithRed:(188/255.0) green:(188/255.0)
                                                   blue:(188/255.0) alpha:1.0];
        _btnYes.titleLabel.font = textFont;
        _btnYes.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [_btnYes setTitle: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_yes]
                 forState:UIControlStateNormal];
        
        [_btnYes addTarget:self
                       action:@selector(whenButtonTouchDown:)
             forControlEvents:UIControlEventTouchDown];
        
        //Add button
        _btnCancel = [[UIButton alloc] initWithFrame: CGRectMake(_btnYes.frame.origin.x+buttonWidth+2, _btnYes.frame.origin.y, buttonWidth, 35)];
        _btnCancel.backgroundColor = _btnYes.backgroundColor;
        _btnCancel.titleLabel.font = textFont;
        _btnCancel.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [_btnCancel setTitle: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_no]
                 forState:UIControlStateNormal];
        [_btnCancel addTarget:self
                      action:@selector(whenButtonTouchDown:)
            forControlEvents:UIControlEventTouchDown];
        
        [_btnCancel addTarget:self
                      action:@selector(buttonCancelPressed)
            forControlEvents:UIControlEventTouchUpInside];
        
        [viewHeader addSubview: lbTitle];
        [self addSubview: viewHeader];
        [self addSubview: _lbContent];
        [self addSubview: _btnCancel];
        [self addSubview: _btnYes];
    }
    return self;
}

- (void)whenButtonTouchDown: (UIButton *)sender{
    sender.backgroundColor = [UIColor colorWithRed:(223/255.0) green:(255/255.0)
                                              blue:(133/255.0) alpha:1];
}

//  Click trên button cancel
- (void)buttonCancelPressed {
    _btnCancel.backgroundColor = [UIColor colorWithRed:(188/255.0) green:(188/255.0)
                                                  blue:(188/255.0) alpha:1];
    [self fadeOut];
}

- (void)showInView:(UIView *)aView animated:(BOOL)animated {
    //Add transparent
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopupViewWhenTagOut)];
    
    UIView *viewBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    viewBackground.backgroundColor = UIColor.blackColor;
    viewBackground.alpha = 0.5;
    viewBackground.tag = 20.0;
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


@end
