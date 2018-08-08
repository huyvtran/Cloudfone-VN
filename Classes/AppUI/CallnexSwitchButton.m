//
//  CallnexSwitchButton.m
//  linphone
//
//  Created by mac book on 20/7/15.
//
//

#import "CallnexSwitchButton.h"
#import "NSDatabase.h"

@implementation CallnexSwitchButton
@synthesize _lbBackground, _btnEnable, _btnDisable, _btnThumb, _status, _typeSwitch;

- (id)initWithState: (BOOL)state frame: (CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self) {
        self.clipsToBounds = YES;
        self.layer.cornerRadius = self.frame.size.height/2;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(declineEnableWhiteList)
                                                     name:k11DeclineEnableWhiteList object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(declineEnableHideMsg)
                                                     name:k11DeclineEnableHideMsg object:nil];
        // Background
        _status = state;
        
        _lbBackground = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview: _lbBackground];
        
        // Button enable
        _btnEnable = [UIButton buttonWithType: UIButtonTypeCustom];
        _btnEnable.frame = CGRectMake(2, 2, frame.size.height-4, frame.size.height-4);
        _btnEnable.backgroundColor = UIColor.clearColor;
        
        UIView *bgEnable = [[UIView alloc] initWithFrame: CGRectMake(0, 0, _btnEnable.frame.size.width, _btnEnable.frame.size.height)];
        UILabel *lbEnable = [[UILabel alloc] initWithFrame: CGRectMake((bgEnable.frame.size.width-2)/2, (bgEnable.frame.size.height-14)/2, 2, 14)];
        lbEnable.backgroundColor = UIColor.whiteColor;
        [bgEnable addSubview: lbEnable];
        
        UIImage *imgEnable = [self imageFromView: bgEnable];
        [_btnEnable setBackgroundImage:imgEnable forState:UIControlStateNormal];
        [_btnEnable setBackgroundImage:imgEnable forState:UIControlStateHighlighted];
        [_btnEnable addTarget:self
                       action:@selector(onButtonEnableClicked:)
             forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview: _btnEnable];
        
        // Button disable
        _btnDisable = [UIButton buttonWithType: UIButtonTypeCustom];
        [_btnDisable setFrame: CGRectMake(frame.size.width-2-_btnEnable.frame.size.width, 2, _btnEnable.frame.size.width, _btnEnable.frame.size.height)];
        _btnDisable.backgroundColor = UIColor.clearColor;
        [_btnDisable setBackgroundImage:[UIImage imageNamed:@"ic_tick.png"] forState:UIControlStateNormal];
        [_btnDisable addTarget:self
                        action:@selector(onButtonDisableClicked:)
              forControlEvents:UIControlEventTouchUpInside];
        [self addSubview: _btnDisable];
        
        // Button thumb
        _btnThumb = [UIButton buttonWithType: UIButtonTypeCustom];
        _btnThumb.backgroundColor = UIColor.clearColor;
        
        if (state) {
            _btnThumb.frame = _btnDisable.frame;
            [_btnThumb setBackgroundImage:[UIImage imageNamed:@"ic_switch_round.png"]
                                 forState:UIControlStateNormal];
            [_lbBackground setBackgroundColor:[UIColor colorWithRed:(95/255.0) green:(182/255.0)
                                                               blue:(113/255.0) alpha:1.0]];
        }else{
            _btnThumb.frame = _btnEnable.frame;
            [_btnThumb setBackgroundImage:[UIImage imageNamed:@"ic_switch_round_dis.png"]
                                 forState:UIControlStateNormal];
            
            [_lbBackground setBackgroundColor:[UIColor colorWithRed:(146/255.0) green:(147/255.0)
                                                               blue:(151/255.0) alpha:1.0]];
        }
        [self addSubview: _btnThumb];
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
        _btnThumb.frame = _btnEnable.frame;
        [_lbBackground setBackgroundColor:[UIColor colorWithRed:(146/255.0) green:(147/255.0)
                                                           blue:(151/255.0) alpha:1.0]];
        [_btnThumb setBackgroundImage:[UIImage imageNamed:@"ic_switch_round_dis.png"]
                             forState:UIControlStateNormal];
    } completion:^(BOOL finished) {
        switch (_typeSwitch) {
            case eSwitchWhiteList:{
                [self disableWhiteList];
                break;
            }
            case eSwitchTrukingPBX:{
                [[NSNotificationCenter defaultCenter] postNotificationName:k11ClickOnViewTrunkingPBX
                                                                    object:[NSNumber numberWithInt:0]];
                break;
            }
        }
        _status = NO;
    }];
}

- (void)onButtonDisableClicked: (UIButton *)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        _btnThumb.frame = _btnDisable.frame;
        [_lbBackground setBackgroundColor:[UIColor colorWithRed:(95/255.0) green:(182/255.0)
                                                           blue:(113/255.0) alpha:1.0]];
        [_btnThumb setBackgroundImage:[UIImage imageNamed:@"ic_switch_round.png"]
                             forState:UIControlStateNormal];
    } completion:^(BOOL finished) {
        switch (_typeSwitch) {
            case eSwitchWhiteList:{
                [self enableWhiteList];
                break;
            }
            case eSwitchTrukingPBX:{
                [[NSNotificationCenter defaultCenter] postNotificationName:k11ClickOnViewTrunkingPBX
                                                                    object:[NSNumber numberWithInt: 1]];
                break;
            }
        }
        _status = YES;
    }];
}

- (void)declineEnableWhiteList {
    [UIView animateWithDuration:0.2 animations:^{
        _btnThumb.frame = _btnEnable.frame;
        _lbBackground.backgroundColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                         blue:(200/255.0) alpha:1.0];
    } completion:^(BOOL finished) {
        [self disableWhiteList];
        _status = NO;
    }];
}

- (void)declineEnableHideMsg{
    [UIView animateWithDuration:0.2 animations:^{
        _btnThumb.frame = _btnEnable.frame;
        _lbBackground.backgroundColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                         blue:(200/255.0) alpha:1.0];
    } completion:^(BOOL finished) {
        _status = NO;
    }];
}

- (void)disableWhiteList{
    /*  Leo Kelvin
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt: 0]
                                              forKey:@"accessWhiteList"];
    
    NSArray *blackList = [NSDBCallnex getAllUserInCallnexBlacklist];
    [[LinphoneAppDelegate sharedInstance].myBuddy.protocol createBlackListOfMe: blackList];
    [[LinphoneAppDelegate sharedInstance].myBuddy.protocol activeBlackListOfMe];
    */
}

- (void)enableWhiteList{
    [[NSNotificationCenter defaultCenter] postNotificationName:k11EnableWhiteList object:nil];
}

//  Set trạng thái của switch khi disable
- (void)setUIForDisableState{
    [UIView animateWithDuration:0.2 animations:^{
        _btnThumb.frame = _btnEnable.frame;
        _lbBackground.backgroundColor = [UIColor colorWithRed:(146/255.0) green:(147/255.0)
                                                         blue:(151/255.0) alpha:1.0];
        [_btnThumb setBackgroundImage:[UIImage imageNamed:@"ic_switch_round_dis.png"]
                             forState:UIControlStateNormal];
    } completion:^(BOOL finished) {
        _status = false;
    }];
}

//  Set trạng thái của switch khi đc enable
- (void)setUIForEnableState {
    [UIView animateWithDuration:0.2 animations:^{
        _btnThumb.frame = _btnDisable.frame;
        _lbBackground.backgroundColor = [UIColor colorWithRed:(95/255.0) green:(182/255.0)
                                                         blue:(113/255.0) alpha:1.0];
        [_btnThumb setBackgroundImage:[UIImage imageNamed:@"ic_switch_round_dis.png"]
                             forState:UIControlStateNormal];
    }completion:^(BOOL finished) {
        _status = true;
    }];
}

@end
