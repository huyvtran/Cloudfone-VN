//
//  DeleteConversationPopupView.m
//  linphone
//
//  Created by Ei Captain on 4/8/17.
//
//

#import "DeleteConversationPopupView.h"

@implementation DeleteConversationPopupView
@synthesize _btnDelete, _btnCancel, _tapGesture;

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
        self.layer.borderColor = [UIColor colorWithRed:(23/255.0) green:(184/255.0)
                                                  blue:(151/255.0) alpha:1.0].CGColor;
        
        //  Add logo image
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(4, 4, frame.size.width-8, 40)];
        headerView.backgroundColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                                      blue:(230/255.0) alpha:1.0];
        
        UIImageView *logoHeader = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.height, headerView.frame.size.height)];
        logoHeader.image = [UIImage imageNamed:@"ic_offline.png"];
        [headerView addSubview: logoHeader];
        
        // Thêm label title header
        UILabel *lbTitle = [[UILabel alloc] initWithFrame: CGRectMake(45, 0, 200, 40)];
        lbTitle.textColor = [UIColor colorWithRed:(138/255.0) green:(138/255.0)
                                             blue:(138/255.0) alpha:1];
        lbTitle.font = textFont;
        lbTitle.backgroundColor = UIColor.clearColor;
        lbTitle.textAlignment = NSTextAlignmentLeft;
        lbTitle.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_delete_conv_title];
        [headerView addSubview: lbTitle];
        
        [self addSubview: headerView];
        
        //Adds
        UILabel *lbContent = [[UILabel alloc] initWithFrame:CGRectMake(10, headerView.frame.origin.y+headerView.frame.size.height+10, frame.size.width-20-10, frame.size.height-8-40-20-35)];
        lbContent.font = textFont;
        lbContent.backgroundColor = UIColor.clearColor;
        lbContent.textAlignment = NSTextAlignmentCenter;
        lbContent.numberOfLines = 5;
        lbContent.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_delete_conv_content];
        lbContent.textColor = UIColor.darkGrayColor;
        [self addSubview: lbContent];
        
        //  Add button
        float buttonWidth = (frame.size.width-8-2)/2;
        _btnDelete = [[UIButton alloc] initWithFrame: CGRectMake(4, frame.size.height-35-4, buttonWidth, 35)];
        _btnDelete.backgroundColor = [UIColor colorWithRed:(150/255.0) green:(150/255.0)
                                                      blue:(150/255.0) alpha:1];
        _btnDelete.titleLabel.font = textFont;
        _btnDelete.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [_btnDelete setTitle: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_delete]
                    forState:UIControlStateNormal];
        [_btnDelete addTarget:self
                       action:@selector(whenButtonTouchDown:)
             forControlEvents:UIControlEventTouchDown];
        
        [self addSubview: _btnDelete];
        
        //Add button
        _btnCancel = [[UIButton alloc] initWithFrame: CGRectMake(_btnDelete.frame.origin.x+buttonWidth+2, _btnDelete.frame.origin.y, buttonWidth, 35)];
        _btnCancel.backgroundColor = _btnDelete.backgroundColor;
        _btnCancel.titleLabel.font = textFont;
        _btnCancel.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [_btnCancel setTitle: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_cancel]
                    forState:UIControlStateNormal];
        [_btnCancel addTarget:self
                       action:@selector(whenButtonTouchDown:)
             forControlEvents:UIControlEventTouchDown];
        [_btnCancel addTarget:self
                       action:@selector(buttonCancelClicked:)
             forControlEvents:UIControlEventTouchUpInside];
        [self addSubview: _btnCancel];
    }
    return self;
}

- (void)whenButtonTouchDown: (UIButton *)sender{
    sender.backgroundColor = [UIColor colorWithRed:(223/255.0) green:(255/255.0)
                                              blue:(133/255.0) alpha:1];
}

- (void)buttonCancelClicked: (UIButton *)sender {
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
