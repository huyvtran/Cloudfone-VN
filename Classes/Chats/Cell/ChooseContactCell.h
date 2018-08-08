//
//  ChooseContactCell.h
//  linphone
//
//  Created by admin on 1/8/18.
//

#import <UIKit/UIKit.h>

@interface ChooseContactCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *_imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *_lbName;
@property (weak, nonatomic) IBOutlet UILabel *_lbPhone;
@property (weak, nonatomic) IBOutlet UIImageView *_imgSelect;
@property (weak, nonatomic) IBOutlet UILabel *_lbSepa;
@property (weak, nonatomic) IBOutlet UILabel *_lbMember;

- (void)setupUIForCell;

@end
