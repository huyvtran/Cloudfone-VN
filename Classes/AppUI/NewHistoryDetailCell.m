//
//  NewHistoryDetailCell.m
//  linphone
//
//  Created by lam quang quan on 11/13/18.
//

#import "NewHistoryDetailCell.h"

@implementation NewHistoryDetailCell
@synthesize imgStatus, lbDate, lbTime, lbDuration, lbState, lbSepa;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [imgStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20.0);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(25.0);
    }];
    
    lbDate.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    lbDate.textColor = UIColor.blackColor;
    [lbDate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgStatus.mas_right).offset(15.0);
        make.top.equalTo(self).offset(10.0);
        make.right.equalTo(self.mas_centerX).offset(20.0);
        make.bottom.equalTo(self.mas_centerY);
    }];
    
    lbTime.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
    lbTime.textColor = [UIColor colorWithRed:(50/255.0) green:(50/255.0)
                                        blue:(50/255.0) alpha:1.0];
    [lbTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_centerY);
        make.left.right.equalTo(lbDate);
        make.bottom.equalTo(self).offset(-5.0);
    }];
    
    lbState.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
    lbState.textColor = lbTime.textColor;
    [lbState mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(lbDate);
        make.left.equalTo(lbDate.mas_right).offset(10.0);
        make.right.equalTo(self).offset(-10.0);
    }];
    
    lbDuration.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
    lbDuration.textColor = lbTime.textColor;
    [lbDuration mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(lbTime);
        make.left.right.equalTo(lbState);
    }];
    
    lbSepa.backgroundColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0)
                                              blue:(220/255.0) alpha:1.0];
    [lbSepa mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(1.0);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
