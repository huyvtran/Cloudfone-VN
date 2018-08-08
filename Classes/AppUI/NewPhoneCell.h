//
//  NewPhoneCell.h
//  linphone
//
//  Created by Ei Captain on 3/18/17.
//
//

#import <UIKit/UIKit.h>

@interface NewPhoneCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *_iconTypePhone;
@property (weak, nonatomic) IBOutlet UITextField *_tfPhone;
@property (weak, nonatomic) IBOutlet UIButton *_iconNewPhone;

- (void)setupUIForCell;

@end
