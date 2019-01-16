//
//  iPadHistoryCallCell.h
//  linphone
//
//  Created by admin on 1/16/19.
//

#import <UIKit/UIKit.h>

@interface iPadHistoryCallCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UIImageView *imgDirection;
@property (weak, nonatomic) IBOutlet UILabel *lbNumber;
@property (weak, nonatomic) IBOutlet UILabel *lbTime;
@property (weak, nonatomic) IBOutlet UIButton *icCall;
@property (weak, nonatomic) IBOutlet UILabel *lbSepa;

@end
