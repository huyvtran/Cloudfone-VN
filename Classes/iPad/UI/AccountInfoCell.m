//
//  AccountInfoCell.m
//  linphone
//
//  Created by admin on 1/12/19.
//

#import "AccountInfoCell.h"

@implementation AccountInfoCell
@synthesize lbAccName, lbAccPhone, icEdit;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
