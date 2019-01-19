//
//  iPadPopupCall.h
//  linphone
//
//  Created by admin on 1/16/19.
//

#import <UIKit/UIKit.h>
#import "UIMutedMicroButton.h"
#import "UISpeakerButton.h"
#import "UIPauseButton.h"
#import "PulsingHaloLayer.h"
#import "UIMiniKeypad.h"

@interface iPadPopupCall : UIView

@property (weak, nonatomic) IBOutlet UIImageView *imgBgCall;
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lbPhone;

@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UILabel *lbTime;
@property (weak, nonatomic) IBOutlet UIButton *icShink;
@property (weak, nonatomic) IBOutlet UILabel *lbQuality;

@property (weak, nonatomic) IBOutlet UIScrollView *scvButtons;

@property (weak, nonatomic) IBOutlet UILabel *lbMute;
@property (weak, nonatomic) IBOutlet UIMutedMicroButton *btnMute;

@property (weak, nonatomic) IBOutlet UILabel *lbKeypad;
@property (weak, nonatomic) IBOutlet UIButton *btnKeypad;

@property (weak, nonatomic) IBOutlet UILabel *lbSpeaker;
@property (weak, nonatomic) IBOutlet UISpeakerButton *btnSpeaker;

@property (weak, nonatomic) IBOutlet UILabel *lbAddCall;
@property (weak, nonatomic) IBOutlet UIButton *btnAddCall;

@property (weak, nonatomic) IBOutlet UILabel *lbHoldCall;
@property (weak, nonatomic) IBOutlet UIPauseButton *btnHoldCall;

@property (weak, nonatomic) IBOutlet UILabel *lbTransfer;
@property (weak, nonatomic) IBOutlet UIButton *btnTransfer;

@property (weak, nonatomic) IBOutlet UIButton *btnHangupCall;

- (void)setupUIForView;
- (void)showInView:(UIView *)aView animated:(BOOL)animated;
- (void)fadeOut;

@property (nonatomic, assign) float wButton;
@property (nonatomic, assign) float hLabel;

- (void)showCallInformation;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, assign) LinphoneCallDir callDirection;
@property (nonatomic, strong) NSTimer *durationTimer;
@property (nonatomic, strong) NSTimer *qualityTimer;
@property (nonatomic, assign) BOOL needEnableSpeaker;

@property (nonatomic, weak) PulsingHaloLayer *halo;
@property (nonatomic, strong) UIMiniKeypad *viewKeypad;

@end
