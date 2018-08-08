//
//  HistoryCallCell.h
//  linphone
//
//  Created by Ei Captain on 3/1/17.
//
//

#import <UIKit/UIKit.h>
#import "BEMCheckBox.h"

@interface HistoryCallCell : UITableViewCell

@property (weak, nonatomic) IBOutlet BEMCheckBox *_cbDelete;
@property (weak, nonatomic) IBOutlet UIImageView *_imgAvatar;
@property (weak, nonatomic) IBOutlet UIImageView *_imgStatus;
@property (weak, nonatomic) IBOutlet UILabel *_lbName;
@property (weak, nonatomic) IBOutlet UILabel *_lbDateTime;
@property (weak, nonatomic) IBOutlet UIButton *_btnCall;
@property (weak, nonatomic) IBOutlet UILabel *_lbSepa;
@property (weak, nonatomic) IBOutlet UILabel *_lbPhone;

@property (nonatomic, strong) NSString *_phoneNumber;

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

- (void)setupUIForViewWithStatus: (BOOL)isDelete;

@end
