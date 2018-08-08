//
//  DeleteContactPBXPopupView.m
//  linphone
//
//  Created by Apple on 5/12/17.
//
//

#import "DeleteContactPBXPopupView.h"

@implementation DeleteContactPBXPopupView
@synthesize _lbTitle, _lbContent, _btnCancel, _btnYes;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        self.layer.borderWidth = 3.0;
        self.layer.borderColor = [UIColor colorWithRed:(23/255.0) green:(184/255.0)
                                                  blue:(151/255.0) alpha:1.0].CGColor;
        //  Add logo image
        UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectMake(3, 3, frame.size.width-6, 40)];
        viewHeader.backgroundColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                                      blue:(230/255.0) alpha:1.0];
        
        UIImageView *imgLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, viewHeader.frame.size.height, viewHeader.frame.size.height)];
        imgLogo.image = [UIImage imageNamed:@"ic_offline.png"];
        [viewHeader addSubview: imgLogo];
        
        //  Add Label
        _lbTitle = [[UILabel alloc] initWithFrame: CGRectMake(45, 0, 200, 40)];
        _lbTitle.textColor = [UIColor colorWithRed:(138/255.0) green:(138/255.0)
                                              blue:(138/255.0) alpha:1.0];
        _lbTitle.font = [UIFont fontWithName:HelveticaNeue size:18.0];
        _lbTitle.backgroundColor = [UIColor clearColor];
        _lbTitle.textAlignment = NSTextAlignmentLeft;
        _lbTitle.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_popup_delete_contact_title];
        [viewHeader addSubview: _lbTitle];
        
        [self addSubview: viewHeader];
        //Adds
        _lbContent = [[UILabel alloc] initWithFrame:CGRectMake(10, viewHeader.frame.origin.y+viewHeader.frame.size.height+10, frame.size.width-20-10, frame.size.height-8-40-20-35)];
        _lbContent.font = [UIFont fontWithName:HelveticaNeue size:16.0];
        _lbContent.backgroundColor = UIColor.clearColor;
        _lbContent.textAlignment = NSTextAlignmentCenter;
        _lbContent.numberOfLines = 5;
        _lbContent.textColor = UIColor.darkGrayColor;
        _lbContent.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_popup_delete_contact_content];
        [self addSubview: _lbContent];
        
        //  Add button
        float buttonWidth = (frame.size.width-8-2)/2;
        _btnYes = [[UIButton alloc] initWithFrame: CGRectMake(4, frame.size.height-35-4, buttonWidth, 35)];
        _btnYes.backgroundColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                   blue:(200/255.0) alpha:1.0];
        _btnYes.titleLabel.font = [UIFont fontWithName:HelveticaNeueBold size:16.0];
        _btnYes.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [_btnYes setTitle: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_yes] forState:UIControlStateNormal];
        
        [_btnYes addTarget:self
                    action:@selector(buttonHighlight:)
          forControlEvents:UIControlEventTouchDown];
        
        [self addSubview:_btnYes];
        
        //Add button
        _btnCancel = [[UIButton alloc] initWithFrame: CGRectMake(_btnYes.frame.origin.x+buttonWidth+2, _btnYes.frame.origin.y, buttonWidth, 35)];
        _btnCancel.backgroundColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                      blue:(200/255.0) alpha:1];
        _btnCancel.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _btnCancel.titleLabel.font = [UIFont fontWithName:HelveticaNeueBold size:16.0];
        [_btnCancel setTitle: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_no] forState:UIControlStateNormal];
        
        [_btnCancel addTarget:self
                       action:@selector(buttonHighlight:)
             forControlEvents:UIControlEventTouchDown];
        
        [_btnCancel addTarget:self
                       action:@selector(buttonCancePressed)
             forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_btnCancel];
    }
    return self;
}

- (void)buttonCancePressed {
    _btnCancel.backgroundColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                  blue:(200/255.0) alpha:1];
    [self fadeOut];
}

- (void)showInView:(UIView *)aView animated:(BOOL)animated {
    //  Add transparent
    UIView *viewBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    viewBackground.backgroundColor = UIColor.blackColor;
    viewBackground.alpha = 0.5;
    viewBackground.tag = 20;
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
    //xoa background black
    for (UIView *subView in self.window.subviews){
        if (subView.tag == 20){
            [subView removeFromSuperview];
        }
    }
    
    [UIView animateWithDuration:.35 animations:^{
        [self setAlpha: 0.0];
        [self setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.3, 1.3)];
    }completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

- (void)buttonHighlight: (UIButton *)sender{
    sender.backgroundColor = [UIColor colorWithRed:(223/255.0) green:(255/255.0)
                                              blue:(133/255.0) alpha:1];
}

@end
