//
//  ContactAddGroupCell.h
//  linphone
//
//  Created by user on 18/9/14.
//
//

#import <UIKit/UIKit.h>
#import "BEMCheckBox.h"

@interface ContactAddGroupCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *_imgAvatar;
@property (retain, nonatomic) IBOutlet UILabel *_lbContactName;
@property (retain, nonatomic) IBOutlet UILabel *_lbContactPhone;
@property (weak, nonatomic) IBOutlet BEMCheckBox *_iconCheckBox;
@property (weak, nonatomic) IBOutlet UILabel *_lbSepa;

@property (nonatomic, strong) NSString *_cloudfoneID;

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

- (void)setupUIForCell;

@end
