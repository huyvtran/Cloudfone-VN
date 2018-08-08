//
//  UIConferenceCell.h
//  linphone
//
//  Created by Designer 01 on 3/6/15.
//
//

#import <UIKit/UIKit.h>
#include <linphone/linphonecore.h>
#include "UIPauseButton.h"

@interface UIConferenceCell : UICollectionViewCell

@property (retain, nonatomic) IBOutlet UIImageView *_userAvatar;
@property (retain, nonatomic) IBOutlet UILabel *_userName;
@property (retain, nonatomic) IBOutlet UILabel *_timeCall;
@property (retain, nonatomic) IBOutlet UIButton *_btnPause;
@property (retain, nonatomic) IBOutlet UIButton *_btnEndCall;

@property(nonatomic,assign) int duration;
@property (nonatomic, assign) LinphoneCall* call;

- (void) updateCell;
- (void)setupUIForCell;

@end
