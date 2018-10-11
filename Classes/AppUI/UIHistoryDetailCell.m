//
//  UIHistoryDetailCell.m
//  linphone
//
//  Created by user on 19/3/14.
//
//

#import "UIHistoryDetailCell.h"

@implementation UIHistoryDetailCell
@synthesize lbTitle, viewContent, imgStatus, lbStateCall, lbTime, lbDuration;

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    lbTitle.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightSemibold];
    lbTitle.textColor = [UIColor colorWithRed:(61/255.0) green:(75/255.0)
                                         blue:(100/255.0) alpha:1.0];
    [lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
    }];
    
    [viewContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self);
    }];
    
    [imgStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewContent).offset(20);
        make.centerY.equalTo(viewContent.mas_centerY);
        make.width.height.mas_equalTo(20.0);
    }];
    
    [lbTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewContent.mas_centerX);
        make.top.equalTo(viewContent).offset(5);
        make.bottom.equalTo(viewContent).offset(-5);
        make.width.mas_equalTo(70.0);
    }];
    
    [lbStateCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgStatus.mas_right).offset(5);
        make.right.equalTo(lbTime.mas_left).offset(-5);
        make.top.bottom.equalTo(lbTime);
    }];
    
    [lbDuration mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lbTime.mas_right).offset(5);
        make.right.equalTo(viewContent).offset(-20);
        make.top.bottom.equalTo(lbTime);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void) dealloc{
}

@end
