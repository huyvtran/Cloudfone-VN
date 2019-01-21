//
//  iPadHistoryCallCell.h
//  linphone
//
//  Created by admin on 1/21/19.
//

#import <UIKit/UIKit.h>

@interface iPadDetailHistoryCallCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgStatus;
@property (weak, nonatomic) IBOutlet UILabel *lbTime;
@property (weak, nonatomic) IBOutlet UILabel *lbCallType;
@property (weak, nonatomic) IBOutlet UILabel *lbDuration;

@end
