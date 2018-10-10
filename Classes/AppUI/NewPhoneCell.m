//
//  NewPhoneCell.m
//  linphone
//
//  Created by Ei Captain on 3/18/17.
//
//

#import "NewPhoneCell.h"

@implementation NewPhoneCell
@synthesize _tfPhone, _iconNewPhone, _iconTypePhone;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [_iconNewPhone setTitleColor:UIColor.clearColor forState:UIControlStateNormal];
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
    
    _tfPhone.placeholder = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Phone number"];
    _tfPhone.font = [UIFont fontWithName:HelveticaNeue size:17.0];
    _tfPhone.textColor = [UIColor colorWithRed:(50/255.0) green:(50/255.0)
                                          blue:(50/255.0) alpha:1.0];
    _tfPhone.keyboardType = UIKeyboardTypePhonePad;
    _tfPhone.borderStyle = UITextBorderStyleNone;
    _tfPhone.clipsToBounds = YES;
    _tfPhone.layer.cornerRadius = 3.0;
    _tfPhone.layer.borderWidth = 1.0;
    _tfPhone.layer.borderColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0)
                                                  blue:(235/255.0) alpha:1.0].CGColor;
    [_tfPhone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconNewPhone.mas_right).offset(10.0);
        make.right.equalTo(_iconTypePhone.mas_left).offset(-10.0);
        make.centerY.equalTo(self.mas_centerY);
        make.height.mas_equalTo(38.0);
    }];
    
    UIView *pView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 38.0)];
    _tfPhone.leftView = pView;
    _tfPhone.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *pRight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 38.0)];
    _tfPhone.rightView = pRight;
    _tfPhone.rightViewMode = UITextFieldViewModeAlways;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
