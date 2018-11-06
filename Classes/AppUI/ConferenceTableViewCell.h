//
//  ConferenceTableViewCell.h
//  linphone
//
//  Created by admin on 11/6/18.
//

#import <UIKit/UIKit.h>

@interface ConferenceTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UILabel *lbPhone;
@property (weak, nonatomic) IBOutlet UIButton *icPause;
@property (weak, nonatomic) IBOutlet UIButton *icEndCall;
@end
