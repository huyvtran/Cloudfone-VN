//
//  iPadPopupCall.m
//  linphone
//
//  Created by admin on 1/16/19.
//

#import "iPadPopupCall.h"

@implementation iPadPopupCall
@synthesize lbName, lbTime, lbNetwork, lbNetworkState, scvButtons, btnMute, lbMute, btnKeypad, lbKeypad, btnSpeaker, lbSpeaker, btnAddCall, lbAddCall, btnHoldCall, lbHoldCall, btnTransfer, lbTransfer;

- (void)setupUIForView {
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 10.0;
    
    //  float padding = 15.0;
    btnMute.layer.rasterizationScale = 1.0;
    btnMute.layer.cornerRadius = 32.0;
    btnMute.imageEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
    btnMute.backgroundColor = UIColor.whiteColor;
    [btnMute setImage:[UIImage imageNamed:@"ic_muted_black"] forState:UIControlStateSelected];
    [btnMute setImage:[UIImage imageNamed:@"ic_muted_white"] forState:UIControlStateNormal];
    btnMute.selected = YES;
}

- (void)showInView:(UIView *)aView animated:(BOOL)animated {
    //Add transparent
    //  _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopupViewWhenTagOut)];
    UIView *viewBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    viewBackground.backgroundColor = UIColor.blackColor;
    viewBackground.alpha = 0.7;
    viewBackground.tag = 20;
    [aView addSubview:viewBackground];
    
    //  [viewBackground addGestureRecognizer:_tapGesture];
    
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
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self removeFromSuperview];
        }
    }];
}

@end
