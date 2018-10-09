//
//  NewSettingCell.m
//  linphone
//
//  Created by admin on 9/30/18.
//

#import "NewSettingCell.h"

@implementation NewSettingCell
@synthesize lbTitle, lbDescription, imgArrow;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [imgArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-10);
        make.centerY.equalTo(self.mas_centerY);
        make.width.mas_equalTo(25.0);
        make.height.mas_equalTo(25.0);
    }];
    
    lbTitle.font = [UIFont systemFontOfSize: 17.0];
    lbTitle.textColor = [UIColor colorWithRed:(50/255.0) green:(50/255.0)
                                         blue:(50/255.0) alpha:1.0];
    [lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.right.equalTo(imgArrow).offset(-10);
        make.bottom.equalTo(self.mas_centerY);
        make.height.mas_equalTo(25);
    }];
    
    lbDescription.font = [UIFont systemFontOfSize: 14.0];
    lbDescription.textColor = [UIColor colorWithRed:(180/255.0) green:(180/255.0)
                                               blue:(180/255.0) alpha:1.0];
    [lbDescription mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lbTitle);
        make.right.equalTo(lbTitle);
        make.top.equalTo(self.mas_centerY);
        make.height.mas_equalTo(lbTitle.mas_height);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        self.backgroundColor = [UIColor colorWithRed:(240/255.0) green:(240/255.0)
                                                blue:(240/255.0) alpha:1.0];
    }else{
        self.backgroundColor = UIColor.clearColor;
    }
}

@end
