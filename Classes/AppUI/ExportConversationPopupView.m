//
//  ExportConversationPopupView.m
//  linphone
//
//  Created by Ei Captain on 4/14/17.
//
//

#import "ExportConversationPopupView.h"

@implementation ExportConversationPopupView
@synthesize _buttonYes, _buttonNo, _tvFileName, _checkButton, _tapGesture;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self)
    {
        // My code here
        self.backgroundColor = UIColor.whiteColor;
        self.layer.borderWidth = 3.0;
        self.layer.borderColor = [UIColor colorWithRed:(23/255.0) green:(184/255.0)
                                                  blue:(151/255.0) alpha:1.0].CGColor;
        
        // Add logo image
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(3, 3, frame.size.width-6, 40)];
        headerView.backgroundColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                                      blue:(230/255.0) alpha:1.0];
        
        UIImageView *logoHeader = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.height, headerView.frame.size.height)];
        logoHeader.image = [UIImage imageNamed:@"ic_offline.png"];
        [headerView addSubview: logoHeader];
        
        // label header
        UILabel *lbTitle = [[UILabel alloc] initWithFrame: CGRectMake(50, 0, frame.size.width-90, 40)];
        lbTitle.backgroundColor = UIColor.clearColor;
        lbTitle.textColor = [UIColor colorWithRed:(138/255.0) green:(138/255.0)
                                             blue:(138/255.0) alpha:1];
        lbTitle.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_export_title];
        lbTitle.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:19.0];
        lbTitle.textAlignment = NSTextAlignmentLeft;
        [headerView addSubview: lbTitle];
        [self addSubview: headerView];
        
        _tvFileName = [[UITextView alloc] initWithFrame:CGRectMake(6, headerView.frame.origin.y+headerView.frame.size.height+10, frame.size.width-12, 50)];
        _tvFileName.layer.borderColor = UIColor.darkGrayColor.CGColor;
        _tvFileName.layer.borderWidth = 1.0;
        _tvFileName.layer.cornerRadius = 5.0;
        _tvFileName.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:15.0];
        _tvFileName.editable = NO;
        [self addSubview: _tvFileName];
        
        // checkbox
        
        _checkButton = [[BEMCheckBox alloc] initWithFrame:CGRectMake(20, _tvFileName.frame.origin.y+_tvFileName.frame.size.height+10, 18, 18)];
        _checkButton.lineWidth = 2.0;
        _checkButton.boxType = BEMBoxTypeSquare;
        _checkButton.onAnimationType = BEMAnimationTypeStroke;
        _checkButton.offAnimationType = BEMAnimationTypeStroke;
        _checkButton.tintColor = [UIColor colorWithRed:(110/255.0) green:(80/255.0)
                                                  blue:(148/255.0) alpha:1.0];
        _checkButton.onTintColor = [UIColor colorWithRed:(110/255.0) green:(80/255.0)
                                                    blue:(148/255.0) alpha:1.0];
        _checkButton.onFillColor = [UIColor colorWithRed:(110/255.0) green:(80/255.0)
                                                    blue:(148/255.0) alpha:1.0];
        _checkButton.onCheckColor = UIColor.whiteColor;
        _checkButton.on = NO;
        _checkButton.tag = 0;
        [self addSubview: _checkButton];
        
        UILabel *lbDesciption = [[UILabel alloc] initWithFrame:CGRectMake(_checkButton.frame.origin.x+_checkButton.frame.size.width+10, _checkButton.frame.origin.y, frame.size.width-_checkButton.frame.size.width-50, _checkButton.frame.size.height)];
        lbDesciption.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_export_content];
        lbDesciption.textColor = UIColor.blackColor;
        lbDesciption.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
        lbDesciption.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapOnDescription = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTapOnLabelDescription)];
        [lbDesciption addGestureRecognizer: tapOnDescription];
        
        [self addSubview: lbDesciption];
        
        //  ADD YES BUTTON
        float buttonWidth = (frame.size.width-8-2)/2;
        _buttonYes = [[UIButton alloc] initWithFrame: CGRectMake(4, frame.size.height-35-4, buttonWidth, 35)];
        _buttonYes.backgroundColor = [UIColor colorWithRed:(188/255.0) green:(188/255.0)
                                                      blue:(188/255.0) alpha:1];
        _buttonYes.titleLabel.font = [UIFont fontWithName:MYRIADPRO_BOLD size:16.0];
        [_buttonYes setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_yes]
                    forState:UIControlStateNormal];
        [_buttonYes addTarget:self
                       action:@selector(buttonHighlighted:)
             forControlEvents:UIControlEventTouchDown];
        
        [_buttonYes addTarget:self
                       action:@selector(saveCurrentConversation)
             forControlEvents:UIControlEventTouchUpInside];
        [self addSubview: _buttonYes];
        
        //  ADD CANCEL BUTTON
        _buttonNo = [[UIButton alloc] initWithFrame:CGRectMake(_buttonYes.frame.origin.x+_buttonYes.frame.size.width+2, _buttonYes.frame.origin.y, buttonWidth, 35)];
        _buttonNo.backgroundColor = [UIColor colorWithRed:(188/255.0) green:(188/255.0)
                                                     blue:(188/255.0) alpha:1];
        _buttonNo.titleLabel.font = [UIFont fontWithName:MYRIADPRO_BOLD size:15.0];
        [_buttonNo setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_no]
                   forState:UIControlStateNormal];
        [_buttonNo addTarget:self
                      action:@selector(buttonHighlighted:)
            forControlEvents:UIControlEventTouchDown];
        
        [_buttonNo addTarget:self
                      action:@selector(fadeOut)
            forControlEvents:UIControlEventTouchUpInside];
        [self addSubview: _buttonNo];
    }
    return self;
}

// tap trên label description
- (void)whenTapOnLabelDescription {
    if (_checkButton.on) {
        [_checkButton setOn:false animated:true];
    }else{
        [_checkButton setOn:true animated:true];
    }
}

- (void)showInView:(UIView *)aView animated:(BOOL)animated {
    //Add transparent
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopupViewWhenTagOut)];
    
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
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self removeFromSuperview];
        }
    }];
}

- (void)buttonHighlighted: (UIButton *)sender{
    sender.backgroundColor = [UIColor colorWithRed:(223/255.0) green:(255/255.0)
                                              blue:(133/255.0) alpha:1];
}

- (void)saveCurrentConversation {
    NSString *fileName = _tvFileName.text;
    if (![fileName isEqualToString: @""]) {
        NSRange range = [fileName rangeOfString:@".html" options:NSCaseInsensitiveSearch];
        if (range.location == NSNotFound) {
            fileName = [NSString stringWithFormat:@"%@.html", fileName];
        }
        [self fadeOut];
        
        NSNumber *tagNumber;
        if (_checkButton.on) {
            tagNumber = [NSNumber numberWithInt: 1];
        }else{
            tagNumber = [NSNumber numberWithInt: 0];
        }
        NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:fileName,@"fileName",tagNumber,@"tagNumber", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:k11SaveConversationChat
                                                            object: infoDict];
    }
}

@end
