//
//  IncomingCallViewController.h
//  linphone
//
//  Created by Hung Ho on 7/6/17.
//
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"

@protocol IncomingCallViewControllerDelegate <NSObject>

- (void)incomingCallAccepted:(LinphoneCall *)call evenWithVideo:(BOOL)video;
- (void)incomingCallDeclined:(LinphoneCall *)call;
- (void)incomingCallAborted:(LinphoneCall *)call;

@end

@interface IncomingCallViewController : UIViewController<UICompositeViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (weak, nonatomic) IBOutlet UIImageView *_bgHeader;
@property (weak, nonatomic) IBOutlet UILabel *_lbName;
@property (weak, nonatomic) IBOutlet UILabel *_lbPhone;

@property (weak, nonatomic) IBOutlet UIImageView *_imgBackground;
@property (weak, nonatomic) IBOutlet UIImageView *_imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *_lbIncoming;
@property (weak, nonatomic) IBOutlet UIButton *_btnDecline;
@property (weak, nonatomic) IBOutlet UIButton *_btnAccept;
@property (weak, nonatomic) IBOutlet UILabel *_lbSepa;

- (IBAction)_btnDeclinePressed:(UIButton *)sender;
- (IBAction)_btnAnswerPressed:(UIButton *)sender;

@property (nonatomic, assign) LinphoneCall* call;

@property (nonatomic, retain) id<IncomingCallViewControllerDelegate> delegate;

@end
