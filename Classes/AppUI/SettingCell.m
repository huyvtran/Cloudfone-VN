//
//  SettingCell.m
//  linphone
//
//  Created by Apple on 4/26/17.
//
//

#import "SettingCell.h"

@implementation SettingCell
@synthesize _iconArrow, _lbTitle, lbSepa;

- (void)awakeFromNib {
    [super awakeFromNib];
    //  my code here
    self.contentView.backgroundColor = UIColor.whiteColor;
    _lbTitle.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    _lbTitle.textColor = UIColor.darkGrayColor;
    
    lbSepa.backgroundColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                              blue:(230/255.0) alpha:1.0];
    
    [lbSepa mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(8.0);
    }];
    
    [_iconArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-10.0);
        make.centerY.equalTo(self.mas_centerY).offset(-4);
        make.width.height.mas_equalTo(25.0);
    }];
    
    [_lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20.0);
        make.top.equalTo(self);
        make.bottom.equalTo(lbSepa.mas_top);
        make.right.equalTo(_iconArrow.mas_left).offset(-10);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                                blue:(230/255.0) alpha:1.0];
    }else{
        self.backgroundColor = UIColor.clearColor;
    }
}

@end
