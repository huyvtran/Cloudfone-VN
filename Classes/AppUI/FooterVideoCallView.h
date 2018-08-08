//
//  FooterVideoCallView.h
//  linphone
//
//  Created by admin on 12/27/17.
//

#import <UIKit/UIKit.h>
#import "UICamSwitch.h"

@interface FooterVideoCallView : UIView

@property (weak, nonatomic) IBOutlet UISpeakerButton *footerSpeaker;
@property (weak, nonatomic) IBOutlet UIMutedMicroButton *footerMute;
@property (weak, nonatomic) IBOutlet UIButton *footerEndCall;
@property (weak, nonatomic) IBOutlet UIButton *footerCameraOff;
@property (weak, nonatomic) IBOutlet UICamSwitch *footerCameraSwitch;

- (void)setupUIForView;

@end
