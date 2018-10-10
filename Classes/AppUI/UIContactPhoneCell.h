//
//  UIContactPhoneCell.h
//  linphone
//
//  Created by lam quang quan on 10/10/18.
//

#import <UIKit/UIKit.h>

@interface UIContactPhoneCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbPhone;
@property (weak, nonatomic) IBOutlet UIButton *icCall;
@property (weak, nonatomic) IBOutlet UILabel *lbSepa;

@end
