//
//  SettingSoundCell.h
//  linphone
//
//  Created by admin on 2/3/18.
//

#import <UIKit/UIKit.h>

@interface SettingSoundCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UISwitch *swAction;
@property (weak, nonatomic) IBOutlet UILabel *lbSepa;

- (void)setupUIForCell;

@end
