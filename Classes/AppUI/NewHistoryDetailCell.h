//
//  NewHistoryDetailCell.h
//  linphone
//
//  Created by lam quang quan on 11/13/18.
//

#import <UIKit/UIKit.h>

@interface NewHistoryDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgStatus;
@property (weak, nonatomic) IBOutlet UILabel *lbDate;
@property (weak, nonatomic) IBOutlet UILabel *lbTime;
@property (weak, nonatomic) IBOutlet UILabel *lbDuration;
@property (weak, nonatomic) IBOutlet UILabel *lbSepa;
@property (weak, nonatomic) IBOutlet UILabel *lbState;

@end
