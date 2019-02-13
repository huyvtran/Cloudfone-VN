//
//  iPadDetailHistoryCallCell.m
//  linphone
//
//  Created by admin on 1/21/19.
//

#import "iPadDetailHistoryCallCell.h"

@implementation iPadDetailHistoryCallCell
@synthesize imgStatus, lbTime, lbCallType, lbDuration;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    float margin = 20.0;
    self.contentView.backgroundColor = UIColor.whiteColor;
    
    [imgStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(margin);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(17.0);
    }];
    
    lbTime.textColor = UIColor.darkGrayColor;
    lbTime.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightThin];
    [lbTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgStatus.mas_right).offset(margin);
        make.top.bottom.equalTo(imgStatus);
        make.width.mas_equalTo(80.0);
    }];
    
    lbDuration.textColor = lbTime.textColor;
    lbDuration.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightThin];
    [lbDuration mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-margin);
        make.top.bottom.equalTo(imgStatus);
        make.width.mas_equalTo(120.0);
    }];
    
    lbCallType.textColor = lbTime.textColor;
    lbCallType.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightThin];
    [lbCallType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lbTime.mas_right).offset(margin);
        make.right.equalTo(lbDuration.mas_left).offset(-margin);
        make.top.bottom.equalTo(imgStatus);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
