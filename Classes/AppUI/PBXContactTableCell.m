//
//  PBXContactTableCell.m
//  linphone
//
//  Created by admin on 12/14/17.
//

#import "PBXContactTableCell.h"

@implementation PBXContactTableCell
@synthesize _imgAvatar, _lbName, _lbPhone, _lbSepa, icCall;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    float marginLeft;
    float marginRight;
    if (IS_IPHONE || IS_IPOD) {
        marginLeft = 20.0;
        marginRight = 25.0;
    }else{
        marginLeft = 0.0;
        marginRight = 5.0;
    }
    
    _imgAvatar.clipsToBounds = YES;
    _imgAvatar.layer.cornerRadius = 45.0/2;
    [_imgAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.left.equalTo(self).offset(20.0);
        make.width.height.mas_equalTo(45.0);
    }];
    
    [icCall setTitleColor:UIColor.clearColor forState:UIControlStateNormal];
    [icCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.right.equalTo(self).offset(-marginRight);
        make.width.height.mas_equalTo(40.0);
    }];
    
    [_lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_imgAvatar);
        make.left.equalTo(_imgAvatar.mas_right).offset(10);
        make.right.equalTo(icCall.mas_left).offset(-10);
        make.bottom.equalTo(_imgAvatar.mas_centerY);
    }];
    
    [_lbPhone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lbName.mas_bottom);
        make.left.right.equalTo(_lbName);
        make.bottom.equalTo(_imgAvatar);
    }];
    
    _lbSepa.backgroundColor = [UIColor colorWithRed:(240/255.0) green:(240/255.0)
                                               blue:(240/255.0) alpha:1.0];
    [_lbSepa mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(marginLeft);
        make.right.bottom.equalTo(self);
        make.height.mas_equalTo(1.0);
    }];
    
    if (IS_IPHONE || IS_IPOD) {
        _lbName.font = [UIFont fontWithName:HelveticaNeue size:17.0];
        _lbPhone.font = [UIFont fontWithName:HelveticaNeue size:14.0];
        
        icCall.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    }else{
        _lbName.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightRegular];
        _lbPhone.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightThin];
        
        icCall.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (!IS_IPHONE && !IS_IPOD) {
        if (selected) {
            self.backgroundColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                                    blue:(230/255.0) alpha:1.0];
        }else{
            self.backgroundColor = UIColor.whiteColor;
        }
    }
    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                                blue:(230/255.0) alpha:1.0];
    }else{
        if (IS_IPHONE || IS_IPOD) {
            self.backgroundColor = UIColor.clearColor;
        }else{
            self.backgroundColor = UIColor.whiteColor;
        }
    }
}

@end
