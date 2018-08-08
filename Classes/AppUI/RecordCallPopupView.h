//
//  RecordCallPopupView.h
//  linphone
//
//  Created by Apple on 5/17/17.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface RecordCallPopupView : UIView<AVAudioPlayerDelegate>

@property (nonatomic, strong) UISlider *_timeSlider;
@property (nonatomic, strong) UIButton *_btnPlay;
@property (nonatomic, strong) UILabel *_lbTotal;
@property (nonatomic, strong) UILabel *_lbTime;
@property (nonatomic, strong) UILabel *_lbBackground;
@property (nonatomic, retain) UITapGestureRecognizer *_tapGesture;


@property (nonatomic, strong) NSString *_recordFile;
@property (nonatomic, strong) AVAudioPlayer *player;

- (void)showInView:(UIView *)aView animated:(BOOL)animated;

- (void)fadeOut;
- (void)showTotalLengthOfRecordFile;

@end
