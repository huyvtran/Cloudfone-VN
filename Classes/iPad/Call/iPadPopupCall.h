//
//  iPadPopupCall.h
//  linphone
//
//  Created by admin on 1/16/19.
//

#import <UIKit/UIKit.h>

@interface iPadPopupCall : UIView

@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UILabel *lbTime;
@property (weak, nonatomic) IBOutlet UIButton *icShink;
@property (weak, nonatomic) IBOutlet UILabel *lbQuality;

@property (weak, nonatomic) IBOutlet UIScrollView *scvButtons;
@property (weak, nonatomic) IBOutlet UIButton *btnMute;
@property (weak, nonatomic) IBOutlet UILabel *lbMute;
@property (weak, nonatomic) IBOutlet UIButton *btnKeypad;
@property (weak, nonatomic) IBOutlet UILabel *lbKeypad;
@property (weak, nonatomic) IBOutlet UIButton *btnSpeaker;
@property (weak, nonatomic) IBOutlet UILabel *lbSpeaker;
@property (weak, nonatomic) IBOutlet UIButton *btnAddCall;
@property (weak, nonatomic) IBOutlet UILabel *lbAddCall;
@property (weak, nonatomic) IBOutlet UIButton *btnHoldCall;
@property (weak, nonatomic) IBOutlet UILabel *lbHoldCall;
@property (weak, nonatomic) IBOutlet UIButton *btnTransfer;
@property (weak, nonatomic) IBOutlet UILabel *lbTransfer;
@property (weak, nonatomic) IBOutlet UIButton *btnHangupCall;

- (void)setupUIForView;
- (void)showInView:(UIView *)aView animated:(BOOL)animated;
- (void)fadeOut;

@property (nonatomic, assign) float wButton;
@property (nonatomic, assign) float hLabel;

@end
