//
//  ChooseRouteOutputCell.m
//  linphone
//
//  Created by admin on 3/21/19.
//

#import "ChooseRouteOutputCell.h"

@implementation ChooseRouteOutputCell
@synthesize imgType, lbContent, imgSelected, lbSepa;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [imgType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10.0);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(25.0);
    }];
    
    [imgSelected mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-10.0);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(22.0);
    }];
    
    lbContent.textAlignment = NSTextAlignmentCenter;
    lbContent.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:22.0];
    lbContent.textColor = [UIColor colorWithRed:(29/255.0) green:(106/255.0)
                                           blue:(207/255.0) alpha:1.0];
    [lbContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgType.mas_right).offset(10.0);
        make.right.equalTo(imgSelected.mas_left).offset(-10.0);
        make.top.bottom.equalTo(self);
    }];
    
    lbSepa.text = @"";
    lbSepa.backgroundColor = [UIColor colorWithRed:(240/255.0) green:(240/255.0) blue:(240/255.0) alpha:1.0];
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
