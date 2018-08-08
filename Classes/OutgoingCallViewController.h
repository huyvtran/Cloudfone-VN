//
//  OutgoingCallViewController.h
//  linphone
//
//  Created by admin on 12/17/17.
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"
#import "PulsingHaloLayer.h"

@interface OutgoingCallViewController : UIViewController<UICompositeViewDelegate, CAAnimationDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *_imgBackground;
@property (weak, nonatomic) IBOutlet UIImageView *_imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *_lbName;
@property (weak, nonatomic) IBOutlet UILabel *_lbCallState;
@property (weak, nonatomic) IBOutlet UIImageView *_imgCallState;
@property (weak, nonatomic) IBOutlet UIButton *_btnEndCall;
@property (weak, nonatomic) IBOutlet UISpeakerButton *_btnSpeaker;
@property (weak, nonatomic) IBOutlet UIMutedMicroButton *_btnMute;

- (IBAction)_btnEndCallPressed:(UIButton *)sender;

- (void)setPhoneNumberForView: (NSString *)phoneNumber;
@property (nonatomic, strong) NSString *_phoneNumber;

@property (nonatomic, weak) PulsingHaloLayer *halo;

@end
