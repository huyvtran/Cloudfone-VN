//
//  ChangePasswordPopupView.m
//  linphone
//
//  Created by admin on 12/17/17.
//

#import "ChangePasswordPopupView.h"

@interface ChangePasswordPopupView (){
    UIFont *textFont;
}
@end

@implementation ChangePasswordPopupView
@synthesize _tfNewPass, _tfConfirmPass, _tfOldPass, _lbError, _btnCancel, _btnConfirm, _tapGesture, _viewFooter;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // My code here
        if (SCREEN_WIDTH > 320) {
            textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
        }else{
            textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
        }
        self.backgroundColor = UIColor.whiteColor;
        self.layer.borderWidth = 3.0;
        self.layer.borderColor = [UIColor colorWithRed:(24/255.0) green:(185/255.0)
                                                  blue:(153/255.0) alpha:1.0].CGColor;
        // Add logo image
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(4, 4, frame.size.width-8, 40)];
        headerView.backgroundColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                                      blue:(230/255.0) alpha:1.0];
        
        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.height, headerView.frame.size.height)];
        logoImageView.image = [UIImage imageNamed:@"ic_offline.png"];
        [headerView addSubview: logoImageView];
        
        // label header
        UILabel *lbTitle = [[UILabel alloc] initWithFrame: CGRectMake(50, 0, frame.size.width-90, 40)];
        lbTitle.backgroundColor = UIColor.clearColor;
        lbTitle.textColor = [UIColor colorWithRed:(138/255.0) green:(138/255.0)
                                             blue:(138/255.0) alpha:1];
        lbTitle.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_change_password];
        lbTitle.font = textFont;
        lbTitle.textAlignment = NSTextAlignmentLeft;
        [headerView addSubview: lbTitle];
        [self addSubview: headerView];
        
        _tfOldPass = [[UITextField alloc] initWithFrame:CGRectMake(6, headerView.frame.origin.y+headerView.frame.size.height+10, frame.size.width-12, 30)];
        _tfOldPass.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _tfOldPass.layer.borderWidth = 1.0;
        _tfOldPass.layer.cornerRadius = 5.0;
        _tfOldPass.font = textFont;
        [self addSubview: _tfOldPass];
        
        UIView *pOld = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 8, _tfOldPass.frame.size.height)];
        _tfOldPass.leftView = pOld;
        _tfOldPass.leftViewMode = UITextFieldViewModeAlways;
        
        _tfNewPass = [[UITextField alloc] initWithFrame:CGRectMake(_tfOldPass.frame.origin.x, _tfOldPass.frame.origin.y+_tfOldPass.frame.size.height+10, _tfOldPass.frame.size.width, _tfOldPass.frame.size.height)];
        _tfNewPass.layer.borderColor = UIColor.lightGrayColor.CGColor;
        _tfNewPass.layer.borderWidth = 1.0;
        _tfNewPass.layer.cornerRadius = 5.0;
        _tfNewPass.font = textFont;
        [self addSubview: _tfNewPass];
        
        UIView *pNew = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 8, _tfNewPass.frame.size.height)];
        _tfNewPass.leftView = pNew;
        _tfNewPass.leftViewMode = UITextFieldViewModeAlways;
        
        _tfConfirmPass = [[UITextField alloc] initWithFrame:CGRectMake(_tfNewPass.frame.origin.x, _tfNewPass.frame.origin.y+_tfNewPass.frame.size.height+10, _tfNewPass.frame.size.width, _tfNewPass.frame.size.height)];
        _tfConfirmPass.layer.borderColor = UIColor.lightGrayColor.CGColor;
        _tfConfirmPass.layer.borderWidth = 1.0;
        _tfConfirmPass.layer.cornerRadius = 5.0;
        _tfConfirmPass.font = textFont;
        [self addSubview: _tfConfirmPass];
        
        UIView *pConfirm = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 8, _tfConfirmPass.frame.size.height)];
        _tfConfirmPass.leftView = pConfirm;
        _tfConfirmPass.leftViewMode = UITextFieldViewModeAlways;
        
        _lbError = [[UILabel alloc] initWithFrame:CGRectMake(_tfConfirmPass.frame.origin.x, _tfConfirmPass.frame.origin.y+_tfConfirmPass.frame.size.height, _tfConfirmPass.frame.size.width, _tfConfirmPass.frame.size.height)];
        _lbError.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:14.0];
        _lbError.textColor = UIColor.redColor;
        _lbError.textAlignment = NSTextAlignmentCenter;
        [self addSubview: _lbError];
        
        _viewFooter = [[UIView alloc] initWithFrame:CGRectMake(0, _lbError.frame.origin.y+_lbError.frame.size.height, frame.size.width, 40)];
        _viewFooter.backgroundColor = [UIColor colorWithRed:(240/255.0) green:(240/255.0)
                                                       blue:(240/255.0) alpha:1.0];
        [self addSubview: _viewFooter];
        
        
        float originX = (frame.size.width-80*2)/3;
        _btnCancel = [[UIButton alloc] initWithFrame: CGRectMake(originX, 5, 80, _viewFooter.frame.size.height-10)];
        _btnCancel.backgroundColor = [UIColor colorWithRed:(237/255.0) green:(27/255.0)
                                                      blue:(45/255.0) alpha:1.0];
        _btnCancel.titleLabel.font = textFont;
        [_btnCancel setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_cancel]
                    forState:UIControlStateNormal];
        [_btnCancel addTarget:self
                       action:@selector(fadeOut)
             forControlEvents:UIControlEventTouchUpInside];
        [_viewFooter addSubview: _btnCancel];
        
        //  ADD CANCEL BUTTON
        _btnConfirm = [[UIButton alloc] initWithFrame:CGRectMake(_btnCancel.frame.origin.x+_btnCancel.frame.size.width+originX, _btnCancel.frame.origin.y, _btnCancel.frame.size.width, _btnCancel.frame.size.height)];
        _btnConfirm.backgroundColor = [UIColor colorWithRed:(153/255.0) green:(202/255.0)
                                                       blue:(87/255.0) alpha:1.0];
        _btnConfirm.titleLabel.font = textFont;
        [_btnConfirm setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_confirm]
                    forState:UIControlStateNormal];
        [_viewFooter addSubview: _btnConfirm];
    }
    return self;
}

- (void)showInView:(UIView *)aView animated:(BOOL)animated {
    //Add transparent
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopupViewWhenTagOut)];
    
    //Add transparent
    UIView *viewBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    viewBackground.backgroundColor = UIColor.blackColor;
    viewBackground.alpha = 0.5;
    viewBackground.tag = 20;
    [viewBackground addGestureRecognizer: _tapGesture];
    
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

- (void)fadeOut
{
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
            [self removeFromSuperview];
        }
    }];
}

- (void)showContentWithCurrentLanguage {
    _tfOldPass.placeholder = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_old_pass];
    _tfNewPass.placeholder = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_new_pass];
    _tfConfirmPass.placeholder = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_confirm_new_pass];
    _lbError.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_change_pass_len];
    [_btnCancel setTitle: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_cancel]
                forState:UIControlStateNormal];
    [_btnConfirm setTitle: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_confirm]
                 forState:UIControlStateNormal];
}

@end
