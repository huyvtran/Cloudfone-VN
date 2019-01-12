//
//  AccountInfoCell.h
//  linphone
//
//  Created by admin on 1/12/19.
//

#import <UIKit/UIKit.h>

@interface AccountInfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbAccName;
@property (weak, nonatomic) IBOutlet UILabel *lbAccPhone;
@property (weak, nonatomic) IBOutlet UIButton *icEdit;

@end
