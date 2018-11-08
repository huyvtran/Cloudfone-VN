//
//  CustomSwitchButton.m
//  linphone
//
//  Created by lam quang quan on 11/7/18.
//

#import "CustomSwitchButton.h"

@implementation CustomSwitchButton

@synthesize lbBackground, btnEnable, btnDisable, btnThumb, curState, lbState, border, wIcon, bgOn, bgOff, startPoint, isEnabled, endPoint, delegate;

- (id)initWithState: (BOOL)state frame: (CGRect)frame withEnable: (BOOL)enable
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
        
        //  button thumbnail
        btnThumb = [UIButton buttonWithType: UIButtonTypeCustom];
        btnThumb.clipsToBounds = YES;
        btnThumb.layer.cornerRadius = wIcon/2;
        btnThumb.backgroundColor = UIColor.whiteColor;
        [self addSubview: btnThumb];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(btnThumbMoved:)];
        [panGesture setMinimumNumberOfTouches:1];
        [panGesture setMaximumNumberOfTouches:1];
        [self addGestureRecognizer: panGesture];
        
        //  state label
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
        isEnabled = enable;
    }
    return self;
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

- (void)setUIForDisableState
{
    [UIView animateWithDuration:0.2 animations:^{
        btnThumb.frame = CGRectMake(border, border, wIcon, wIcon);
        lbState.frame = CGRectMake(btnThumb.frame.origin.x+btnThumb.frame.size.width, border, self.frame.size.width-(2*border+wIcon), self.frame.size.height-border);
        
        lbState.text = [[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"OFF"] uppercaseString];
        lbBackground.backgroundColor = bgOff;
    } completion:^(BOOL finished) {
        curState = NO;
        [delegate switchButtonDisabled];
    }];
}

- (void)setUIForEnableState
{
    [UIView animateWithDuration:0.2 animations:^{
        btnThumb.frame = CGRectMake(self.frame.size.width-border-wIcon, border, wIcon, wIcon);
        lbState.frame = CGRectMake(0, border, self.frame.size.width-(2*border+wIcon), self.frame.size.height-border);
        lbState.text = [[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"ON"] uppercaseString];
        lbBackground.backgroundColor = bgOn;
    }completion:^(BOOL finished) {
        curState = YES;
        [delegate switchButtonEnabled];
    }];
}

- (void)tapToChangeValue {
    if (!isEnabled) {
        NSLog(@"You can not change value when switch button in disable state");
        return;
    }
    
    if (curState) {
        [self setUIForDisableState];
    }else{
        [self setUIForEnableState];
    }
}

- (void)btnThumbMoved:(UIPanGestureRecognizer *)gesture {
    if ([gesture state] == UIGestureRecognizerStateBegan) {
        startPoint = [gesture locationInView: self];
    }else if ([gesture state] == UIGestureRecognizerStateEnded){
        endPoint = [gesture locationInView: self];
        [self checkToChangeUI];
    }
}

- (void)checkToChangeUI {
    if (!isEnabled) {
        NSLog(@"You can not change value when switch button in disable state");
        return;
    }
    
    if (curState) {
        if (startPoint.x - endPoint.x > 10) {
            [self setUIForDisableState];
        }
    }else{
        if (endPoint.x - startPoint.x > 10) {
            [self setUIForEnableState];
        }
    }
}

@end
