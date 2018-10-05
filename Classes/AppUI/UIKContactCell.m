//
//  UIKContactCell.m
//  linphone
//
//  Created by user on 29/5/14.
//
//

#import "UIKContactCell.h"

@implementation UIKContactCell
@synthesize lbTitle, lbValue, _lbSepa;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    if (SCREEN_WIDTH > 320) {
        lbTitle.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
        lbValue.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }else{
        lbTitle.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
        lbValue.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
    }
    
    [lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(5);
        make.top.equalTo(self);
        make.bottom.equalTo(self).offset(-1);
        make.width.mas_equalTo(100);
    }];
    lbTitle.textColor = [UIColor colorWithRed:(50/255.0) green:(50/255.0)
                                         blue:(50/255.0) alpha:1.0];
    
    [lbValue mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lbTitle.mas_right).offset(5);
        make.right.equalTo(self).offset(-5);
        make.top.equalTo(self);
        make.bottom.equalTo(self).offset(-1);
    }];
    lbValue.textColor = lbTitle.textColor;
    
    [_lbSepa mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lbTitle);
        make.right.bottom.equalTo(self);
        make.height.mas_equalTo(1.0);
    }];
    _lbSepa.backgroundColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0)
                                               blue:(235/255.0) alpha:1.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithRed:(223/255.0) green:(255/255.0)
                                                blue:(133/255.0) alpha:1];
    }else{
        self.backgroundColor = UIColor.clearColor;
    }
}

@end
