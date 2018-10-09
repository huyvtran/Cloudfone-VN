//
//  NewPhoneCell.m
//  linphone
//
//  Created by Ei Captain on 3/18/17.
//
//

#import "NewPhoneCell.h"

@implementation NewPhoneCell
@synthesize _iconTypePhone, _tfPhone, _iconNewPhone;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [_iconNewPhone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20.0);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(35.0);
    }];
    
    [_iconTypePhone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-20.0);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(35.0);
    }];
    
    _tfPhone.font = [UIFont fontWithName:HelveticaNeue size:16.0];
    _tfPhone.textColor = [UIColor colorWithRed:(50/255.0) green:(50/255.0)
                                          blue:(50/255.0) alpha:1.0];
    _tfPhone.keyboardType = UIKeyboardTypePhonePad;
    [_tfPhone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconNewPhone.mas_right).offset(10.0);
        make.right.equalTo(_iconTypePhone.mas_left).offset(-10.0);
        make.centerY.equalTo(self.mas_centerY);
        make.height.mas_equalTo(38.0);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
