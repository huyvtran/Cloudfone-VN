//
//  HotlineViewController.h
//  linphone
//
//  Created by admin on 3/10/18.
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"

@interface HotlineViewController : UIViewController<UICompositeViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lbStatus;
@property (weak, nonatomic) IBOutlet UILabel *lbTime;
@property (weak, nonatomic) IBOutlet UIImageView *imgClock;
@property (weak, nonatomic) IBOutlet UIImageView *imgHotline;
@property (weak, nonatomic) IBOutlet UIButton *btnEndCall;

@property (weak, nonatomic) IBOutlet UIMutedMicroButton *btnMute;
@property (weak, nonatomic) IBOutlet UISpeakerButton *btnSpeaker;

@end
