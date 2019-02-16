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
    
    icEdit.imageEdgeInsets = UIEdgeInsetsMake(11, 11, 11, 11);
    [icEdit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(45.0);
    }];
    
    lbAccName.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightRegular];
    [lbAccName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20.0);
        make.top.equalTo(self).offset(5.0);
        make.bottom.equalTo(self.mas_centerY);
        make.right.equalTo(icEdit).offset(-20.0);
    }];
    
    lbAccPhone.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightThin];
    [lbAccPhone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(lbAccName);
        make.top.equalTo(lbAccName.mas_bottom);
        make.bottom.equalTo(self).offset(-5.0);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
