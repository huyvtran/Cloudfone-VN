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
    
    [imgStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(margin);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(20.0);
    }];
    
    lbTime.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightThin];
    lbTime.backgroundColor = UIColor.blueColor;
    [lbTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgStatus.mas_right).offset(margin);
        make.top.bottom.equalTo(imgStatus);
        make.width.mas_equalTo(80.0);
    }];
    
    lbDuration.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightThin];
    lbDuration.backgroundColor = UIColor.greenColor;
    [lbDuration mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-margin);
        make.top.bottom.equalTo(imgStatus);
        make.width.mas_equalTo(120.0);
    }];
    
    lbCallType.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightThin];
    lbCallType.backgroundColor = UIColor.redColor;
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
