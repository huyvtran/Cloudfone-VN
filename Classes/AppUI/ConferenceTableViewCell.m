//
//  ConferenceTableViewCell.m
//  linphone
//
//  Created by admin on 11/6/18.
//

#import "ConferenceTableViewCell.h"

@implementation ConferenceTableViewCell
@synthesize imgAvatar, lbName, lbPhone, icPause, icEndCall;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [imgAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15.0);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(45.0);
    }];
    
    [icEndCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-15.0);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(35.0);
    }];
    
    [icPause mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(icEndCall.mas_left).offset(-10.0);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(35.0);
    }];
    
    lbName.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:17.0];
    [lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgAvatar);
        make.left.equalTo(imgAvatar.mas_right).offset(5.0);
        make.bottom.equalTo(imgAvatar.mas_centerY);
        make.right.equalTo(icPause.mas_left).offset(-5.0);
    }];
    
    lbPhone.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:15.0];
    [lbPhone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgAvatar.mas_centerY);
        make.left.right.equalTo(lbName);
        make.bottom.equalTo(imgAvatar.mas_bottom);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
