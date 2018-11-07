//
//  CustomSwitchButton.m
//  linphone
//
//  Created by lam quang quan on 11/7/18.
//

#import "CustomSwitchButton.h"

@implementation CustomSwitchButton

@synthesize lbBackground, btnEnable, btnDisable, btnThumb, curState, lbState, border, wIcon, bgOn, bgOff;

- (id)initWithState: (BOOL)state frame: (CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self) {
        bgOn = [UIColor colorWithRed:(27/255.0) green:(104/255.0)
                                blue:(213/255.0) alpha:1.0];
        
        bgOff = [UIColor colorWithRed:(118/255.0) green:(134/255.0)
                                 blue:(158/255.0) alpha:1.0];
        
        self.clipsToBounds = YES;
        self.layer.cornerRadius = self.frame.size.height/2;
        
        border = 3.0;
        wIcon = frame.size.height - 2*border;
        
        lbBackground = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview: lbBackground];
        
        btnThumb = [UIButton buttonWithType: UIButtonTypeCustom];
        btnThumb.clipsToBounds = YES;
        btnThumb.layer.cornerRadius = wIcon/2;
        btnThumb.backgroundColor = UIColor.whiteColor;
        [self addSubview: btnThumb];
        
        lbState = [[UILabel alloc] init];
        lbState.font = [UIFont fontWithName:MYRIADPRO_BOLD size:16.0];
        lbState.textColor = UIColor.whiteColor;
        lbState.textAlignment = NSTextAlignmentCenter;
        lbState.backgroundColor = UIColor.clearColor;
        [self addSubview: lbState];
        
        //  Add target action
        lbState.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapChangeValue = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToChangeValue)];
        [lbState addGestureRecognizer: tapChangeValue];
        
        if (state) {
            btnThumb.frame = CGRectMake(frame.size.width-border-wIcon, border, wIcon, wIcon);
            lbState.frame = CGRectMake(0, border, frame.size.width-(2*border+wIcon), frame.size.height-border);
            lbState.text = [[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"ON"] uppercaseString];
            lbBackground.backgroundColor = bgOn;
        }else{
            btnThumb.frame = CGRectMake(border, border, wIcon, wIcon);
            lbState.frame = CGRectMake(btnThumb.frame.origin.x+btnThumb.frame.size.width, border, frame.size.width-(2*border+wIcon), frame.size.height-border);
            lbState.text = [[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"OFF"] uppercaseString];
            lbBackground.backgroundColor = bgOff;
        }
    }
    return self;
}

//  Chuyển view gồm 2 ảnh thành ảnh
- (UIImage *)imageFromView:(UIView *) view {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(view.frame.size);
    }
    [view.layer renderInContext: UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)onButtonEnableClicked: (UIButton *)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        btnThumb.frame = btnEnable.frame;
        [lbBackground setBackgroundColor:[UIColor colorWithRed:(146/255.0) green:(147/255.0)
                                                           blue:(151/255.0) alpha:1.0]];
        [btnThumb setBackgroundImage:[UIImage imageNamed:@"ic_switch_round_dis.png"]
                             forState:UIControlStateNormal];
    } completion:^(BOOL finished) {
        
        curState = NO;
    }];
}

- (void)onButtonDisableClicked: (UIButton *)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        btnThumb.frame = btnDisable.frame;
        [lbBackground setBackgroundColor:[UIColor colorWithRed:(95/255.0) green:(182/255.0)
                                                           blue:(113/255.0) alpha:1.0]];
        [btnThumb setBackgroundImage:[UIImage imageNamed:@"ic_switch_round.png"]
                             forState:UIControlStateNormal];
    } completion:^(BOOL finished) {
        
        curState = YES;
    }];
}

//  Set trạng thái của switch khi disable
- (void)setUIForDisableState{
    [UIView animateWithDuration:0.2 animations:^{
        btnThumb.frame = CGRectMake(border, border, wIcon, wIcon);
        lbState.frame = CGRectMake(btnThumb.frame.origin.x+btnThumb.frame.size.width, border, self.frame.size.width-(2*border+wIcon), self.frame.size.height-border);
        
        lbState.text = [[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"OFF"] uppercaseString];
        lbBackground.backgroundColor = bgOff;
    } completion:^(BOOL finished) {
        curState = NO;
    }];
}

//  Set trạng thái của switch khi đc enable
- (void)setUIForEnableState {
    [UIView animateWithDuration:0.2 animations:^{
        btnThumb.frame = CGRectMake(self.frame.size.width-border-wIcon, border, wIcon, wIcon);
        lbState.frame = CGRectMake(0, border, self.frame.size.width-(2*border+wIcon), self.frame.size.height-border);
        lbState.text = [[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"ON"] uppercaseString];
        lbBackground.backgroundColor = bgOn;
    }completion:^(BOOL finished) {
        curState = YES;
    }];
}

- (void)tapToChangeValue {
    if (curState) {
        [self setUIForDisableState];
    }else{
        [self setUIForEnableState];
    }
}

@end
