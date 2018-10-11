//
//  HistoryCallCell.m
//  linphone
//
//  Created by Ei Captain on 3/1/17.
//
//

#import "HistoryCallCell.h"

@implementation HistoryCallCell
@synthesize _cbDelete, _imgAvatar, _imgStatus, _lbName, _lbDateTime, _btnCall, _lbSepa, _lbPhone, lbDuration;
@synthesize _phoneNumber;

- (void)awakeFromNib {
    [super awakeFromNib];
    if (self.frame.size.width > 320) {
        _lbName.font = [UIFont fontWithName:MYRIADPRO_BOLD size:18.0];
        _lbPhone.font = [UIFont fontWithName:HelveticaNeueItalic size:16.0];
        _lbDateTime.font = [UIFont fontWithName:HelveticaNeueItalic size:16.0];
    }else{
        _lbName.font = [UIFont fontWithName:MYRIADPRO_BOLD size:16.0];
        _lbPhone.font = [UIFont fontWithName:HelveticaNeueItalic size:14.0];
        _lbDateTime.font = [UIFont fontWithName:HelveticaNeueItalic size:14.0];
    }
    
    _imgAvatar.clipsToBounds = YES;
    _imgAvatar.layer.cornerRadius = 50.0/2;
    [_imgAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(50.0);
    }];
    
    [_imgStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_imgAvatar.mas_right).offset(-15);
        make.top.equalTo(_imgAvatar.mas_bottom).offset(-15);
        make.width.height.mas_equalTo(16.0);
    }];
    
    [_btnCall setBackgroundImage:[UIImage imageNamed:@"ic_call_history_over.png"]
                        forState:UIControlStateHighlighted];
    [_btnCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-20);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(35.0);
    }];
    
    _lbTime.textColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                         blue:(200/255.0) alpha:1.0];
    [_lbTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_imgAvatar);
        make.bottom.equalTo(_imgAvatar.mas_centerY);
        make.right.equalTo(_btnCall.mas_left).offset(-5);
        make.width.mas_equalTo(80.0);
    }];
    
    lbDuration.textColor = _lbTime.textColor;
    [lbDuration mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lbTime.mas_bottom);
        make.left.right.equalTo(_lbTime);
        make.bottom.equalTo(_imgAvatar.mas_bottom);
    }];
    
    _lbName.textColor = [UIColor colorWithRed:(50/255.0) green:(50/255.0)
                                         blue:(50/255.0) alpha:1.0];
    [_lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_imgAvatar).offset(4);
        make.left.equalTo(_imgAvatar.mas_right).offset(5);
        make.bottom.equalTo(_imgAvatar.mas_centerY);
        make.right.equalTo(_lbTime.mas_left).offset(-5);
    }];
    
    _lbPhone.textColor = _lbTime.textColor;
    [_lbPhone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lbName.mas_bottom);
        make.left.right.equalTo(_lbName);
        make.bottom.equalTo(lbDuration.mas_bottom);
    }];
    
    _lbSepa.backgroundColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0)
                                               blue:(235/255.0) alpha:1.0];
    [_lbSepa mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_imgAvatar);
        make.bottom.right.equalTo(self);
        make.height.mas_equalTo(1.0);
    }];
    
    UIColor *cbColor = [UIColor colorWithRed:(17/255.0) green:(186/255.0)
                                        blue:(153/255.0) alpha:1.0];
    _cbDelete.lineWidth = 1.0;
    _cbDelete.boxType = BEMBoxTypeCircle;
    _cbDelete.onAnimationType = BEMAnimationTypeStroke;
    _cbDelete.offAnimationType = BEMAnimationTypeStroke;
    _cbDelete.tintColor = cbColor;
    _cbDelete.onTintColor = cbColor;
    _cbDelete.onFillColor = cbColor;
    _cbDelete.onCheckColor = UIColor.whiteColor;
    [_cbDelete mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-10);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(30.0);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithRed:(240/255.0) green:(240/255.0)
                                                blue:(240/255.0) alpha:1];
    }else{
        self.backgroundColor = UIColor.clearColor;
    }
}

- (void)setupUIForViewWithStatus: (BOOL)isDelete {
    _lbSepa.frame = CGRectMake(5, self.frame.size.height-1, self.frame.size.width-10, 1);
    
    if (isDelete) {
        _cbDelete.frame = CGRectMake(10, (self.frame.size.height-22)/2, 22, 22);
        _imgAvatar.frame = CGRectMake(2*_cbDelete.frame.origin.x+_cbDelete.frame.size.width, 5, self.frame.size.height-10, self.frame.size.height-10);
        _imgStatus.frame = CGRectMake(_imgAvatar.frame.origin.x+_imgAvatar.frame.size.width-15, _imgAvatar.frame.origin.y, 16, 16);
        _btnCall.frame = CGRectMake(self.frame.size.width-40-_cbDelete.frame.origin.x, (self.frame.size.height-40)/2, 40, 40);
        _lbName.frame = CGRectMake(_imgAvatar.frame.origin.x+_imgAvatar.frame.size.width+5, _imgAvatar.frame.origin.y, self.frame.size.width-(_imgAvatar.frame.origin.x+_imgAvatar.frame.size.width+5 + _btnCall.frame.size.width + 2*_cbDelete.frame.origin.x), _imgAvatar.frame.size.height/2);
        _lbPhone.frame = CGRectMake(_lbName.frame.origin.x, _lbName.frame.origin.y+_lbName.frame.size.height, _lbName.frame.size.width/2, _lbName.frame.size.height);
        _lbDateTime.frame = CGRectMake(_lbPhone.frame.origin.x+_lbPhone.frame.size.width, _lbPhone.frame.origin.y, _lbPhone.frame.size.width, _lbPhone.frame.size.height);
    }else{
        _imgAvatar.frame = CGRectMake(_lbSepa.frame.origin.x, 5, self.frame.size.height-10, self.frame.size.height-10);
        _imgStatus.frame = CGRectMake(_imgAvatar.frame.origin.x+_imgAvatar.frame.size.width-15, _imgAvatar.frame.origin.y, 16, 16);
        _btnCall.frame = CGRectMake(self.frame.size.width-40-_cbDelete.frame.origin.x, (self.frame.size.height-40)/2, 40, 40);
        _lbName.frame = CGRectMake(_imgAvatar.frame.origin.x+_imgAvatar.frame.size.width+5, _imgAvatar.frame.origin.y, self.frame.size.width-(_imgAvatar.frame.origin.x+_imgAvatar.frame.size.width+5 + _btnCall.frame.size.width + 2*_cbDelete.frame.origin.x), _imgAvatar.frame.size.height/2);
        _lbPhone.frame = CGRectMake(_lbName.frame.origin.x, _lbName.frame.origin.y+_lbName.frame.size.height, _lbName.frame.size.width/2, _lbName.frame.size.height);
        _lbDateTime.frame = CGRectMake(_lbPhone.frame.origin.x+_lbPhone.frame.size.width, _lbPhone.frame.origin.y, _lbPhone.frame.size.width, _lbPhone.frame.size.height);
    }
    _imgAvatar.clipsToBounds = YES;
    _imgAvatar.layer.cornerRadius = _imgAvatar.frame.size.height/2;
    
    if ([_phoneNumber isEqualToString:@"hotline"]) {
        _lbName.frame = CGRectMake(_lbName.frame.origin.x, (self.frame.size.height-_lbName.frame.size.height)/2, _lbName.frame.size.width, _lbName.frame.size.height);
        _lbPhone.hidden = YES;
    }
}

@end
