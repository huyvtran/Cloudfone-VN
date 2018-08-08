//
//  PopupChangeSubject.m
//  linphone
//
//  Created by Ei Captain on 7/18/16.
//
//

#import "PopupChangeSubject.h"

@implementation PopupChangeSubject
@synthesize _btnCancel, _btnSave, _tapGesture, _tfSubject;
@synthesize _roomName;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    if (self) {
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
        lbTitle.font = [AppUtils fontRegularWithSize: 18.0];
        lbTitle.backgroundColor = UIColor.clearColor;
        lbTitle.textAlignment = NSTextAlignmentLeft;
        lbTitle.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:TEXT_CHANGE_SUBJECT_TITLE];
        [headerView addSubview: lbTitle];
        
        [self addSubview: headerView];
        
        // Adds
        _tfSubject = [[UITextField alloc] initWithFrame: CGRectMake(25, headerView.frame.origin.y+headerView.frame.size.height+10, frame.size.width-50, 30)];
        _tfSubject.borderStyle = UITextBorderStyleNone;
        _tfSubject.layer.borderWidth = 1.0;
        _tfSubject.layer.borderColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                        blue:(200/255.0) alpha:1.0].CGColor;
        _tfSubject.layer.cornerRadius = 5.0;
        _tfSubject.placeholder = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:TEXT_CHANGE_SUBJECT_PLHD];
        _tfSubject.font = [AppUtils fontRegularWithSize:15.0];
        _tfSubject.textColor = UIColor.blackColor;
        [_tfSubject addTarget:self
                       action:@selector(whenTextfieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
        
        UIView *paddingView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 7, _tfSubject.frame.size.height)];
        paddingView.backgroundColor = UIColor.clearColor;
        _tfSubject.leftView = paddingView;
        _tfSubject.leftViewMode = UITextFieldViewModeAlways;
        [self addSubview: _tfSubject];
        
        //  Add button
        float buttonWidth = (frame.size.width-8-2)/2;
        _btnSave = [[UIButton alloc] initWithFrame: CGRectMake(4, frame.size.height-35-4, buttonWidth, 35)];
        _btnSave.backgroundColor = [UIColor colorWithRed:(180/255.0) green:(180/255.0)
                                                    blue:(180/255.0) alpha:1.0];
        _btnSave.enabled = NO;
        _btnSave.titleLabel.font = [AppUtils fontBoldWithSize: 16.0];
        _btnSave.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [_btnSave setTitle: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:TEXT_CHANGE_SUBJECT_SAVE]
                 forState:UIControlStateNormal];
        [_btnSave addTarget:self
                     action:@selector(whenButtonTouchDown:)
           forControlEvents:UIControlEventTouchDown];
        
        [_btnSave addTarget:self
                     action:@selector(buttonSaveClicked:)
           forControlEvents:UIControlEventTouchUpInside];
        [self addSubview: _btnSave];
        
        //Add button
        _btnCancel = [[UIButton alloc] initWithFrame: CGRectMake(_btnSave.frame.origin.x+buttonWidth+2, _btnSave.frame.origin.y, buttonWidth, 35)];
        _btnCancel.backgroundColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0)
                                                      blue:(220/255.0) alpha:1];
        _btnCancel.titleLabel.font = [AppUtils fontBoldWithSize: 16.0];
        _btnCancel.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [_btnCancel setTitle: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:TEXT_CHANGE_SUBJECT_CANCEL]
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

- (void)whenTextfieldDidChange: (UITextField *)textfield {
    if (textfield.text.length > 0) {
        _btnSave.enabled = YES;
        _btnSave.backgroundColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0)
                                                    blue:(220/255.0) alpha:1.0];
    }else{
        _btnSave.enabled = NO;
        _btnSave.backgroundColor = [UIColor colorWithRed:(180/255.0) green:(180/255.0)
                                                    blue:(180/255.0) alpha:1.0];
    }
}

- (void)whenButtonTouchDown: (UIButton *)sender{
    sender.backgroundColor = [UIColor colorWithRed:(223/255.0) green:(255/255.0)
                                              blue:(133/255.0) alpha:1];
}

- (void)buttonSaveClicked: (UIButton *)sender {
    sender.backgroundColor = [UIColor colorWithRed:(223/255.0) green:(255/255.0)
                                              blue:(133/255.0) alpha:1];
    [self fadeOut];
    // Kicking an Occupant
    [[LinphoneAppDelegate sharedInstance].myBuddy.protocol changeSubjectOfTheRoom:_roomName withSubject:_tfSubject.text];
}

- (void)buttonCancelClicked: (UIButton *)sender {
    sender.backgroundColor = [UIColor colorWithRed:(223/255.0) green:(255/255.0)
                                              blue:(133/255.0) alpha:1];
    [self fadeOut];
}

- (void)showInView:(UIView *)aView animated:(BOOL)animated {
    //Add transparent
    [_tfSubject becomeFirstResponder];
    
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
