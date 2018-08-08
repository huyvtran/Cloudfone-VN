//
//  PBXContactPopupView.m
//  linphone
//
//  Created by Apple on 5/12/17.
//
//

#import "PBXContactPopupView.h"

@implementation PBXContactPopupView
@synthesize _viewHeader, _lbHeader, _imgLogo, _tfName, _tfNumber, _btnCancel, _btnYes;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    if (self)
    {
        self.backgroundColor = UIColor.whiteColor;
        self.layer.borderWidth = 3.0;
        self.layer.borderColor = [UIColor colorWithRed:(23/255.0) green:(184/255.0)
                                                  blue:(151/255.0) alpha:1.0].CGColor;
        //  Add logo image
        _viewHeader = [[UIView alloc] initWithFrame:CGRectMake(3, 3, frame.size.width-6, 40)];
        [_viewHeader setBackgroundColor:[UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                                         blue:(230/255.0) alpha:1.0]];
        
        _imgLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _viewHeader.frame.size.height, _viewHeader.frame.size.height)];
        _imgLogo.image = [UIImage imageNamed:@"ic_offline.png"];
        [_viewHeader addSubview: _imgLogo];
        
        //  Add Label
        _lbHeader = [[UILabel alloc] initWithFrame: CGRectMake(45, 0, 200, 40)];
        _lbHeader.textColor = [UIColor colorWithRed:(138/255.0) green:(138/255.0)
                                               blue:(138/255.0) alpha:1.0];
        _lbHeader.font = [UIFont fontWithName:HelveticaNeue size:18.0];
        _lbHeader.backgroundColor = UIColor.clearColor;
        _lbHeader.textAlignment = NSTextAlignmentLeft;
        [_viewHeader addSubview: _lbHeader];
        [self addSubview: _viewHeader];
        
        //
        _tfName = [[UITextField alloc] initWithFrame: CGRectMake(10, _viewHeader.frame.origin.y+_viewHeader.frame.size.height+10, self.frame.size.width-20, 32)];
        _tfName.borderStyle = UITextBorderStyleNone;
        _tfName.layer.borderWidth = 1.0;
        _tfName.layer.borderColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0)
                                                     blue:(220/255.0) alpha:1.0].CGColor;
        _tfName.layer.cornerRadius = 5.0;
        _tfName.placeholder = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_pbx_name];
        _tfName.textColor = UIColor.darkGrayColor;
        
        UIView *pName = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 7, _tfName.frame.size.height)];
        _tfName.leftView = pName;
        _tfName.leftViewMode = UITextFieldViewModeAlways;
        [self addSubview: _tfName];
        
        _tfNumber = [[UITextField alloc] initWithFrame: CGRectMake(_tfName.frame.origin.x, _tfName.frame.origin.y+_tfName.frame.size.height+10, _tfName.frame.size.width, 32)];
        _tfNumber.borderStyle = UITextBorderStyleNone;
        _tfNumber.layer.borderWidth = 1.0;
        _tfNumber.layer.borderColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0)
                                                       blue:(220/255.0) alpha:1.0].CGColor;
        _tfNumber.layer.cornerRadius = 5.0;
        _tfNumber.placeholder = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_pbx_number];
        _tfNumber.textColor = UIColor.darkGrayColor;
        
        UIView *pNumber = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 7, _tfNumber.frame.size.height)];
        _tfNumber.leftView = pNumber;
        _tfNumber.leftViewMode = UITextFieldViewModeAlways;
        [self addSubview: _tfNumber];
        
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
        _btnCancel.backgroundColor = _btnYes.backgroundColor;
        _btnCancel.titleLabel.font = [UIFont fontWithName:HelveticaNeueBold size:16.0];
        _btnCancel.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
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
        self.alpha = 0;
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.3, 1.3);
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
