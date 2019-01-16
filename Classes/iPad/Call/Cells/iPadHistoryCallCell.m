//
//  iPadHistoryCallCell.m
//  linphone
//
//  Created by admin on 1/16/19.
//

#import "iPadHistoryCallCell.h"

@implementation iPadHistoryCallCell
@synthesize imgAvatar, lbName, lbTime, imgDirection, lbNumber, icCall, lbSepa;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    float padding = 10.0;
    lbName.font = [UIFont fontWithName:HelveticaNeue size:19.0];
    lbNumber.font = [UIFont fontWithName:HelveticaNeue size:16.0];
    lbTime.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
    
    imgAvatar.clipsToBounds = YES;
    imgAvatar.layer.borderColor = [UIColor colorWithRed:0.169 green:0.53 blue:0.949 alpha:1.0].CGColor;
    imgAvatar.layer.borderWidth = 1.0;
    imgAvatar.layer.cornerRadius = 45.0/2;
    [imgAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(padding);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(60.0);
    }];
    
    icCall.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [icCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-5.0);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(40.0);
    }];
    
    [lbTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgAvatar);
        make.bottom.equalTo(imgAvatar);
        make.right.equalTo(icCall.mas_left).offset(-5.0);
        make.width.mas_equalTo(80.0);
    }];
    
    [lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgAvatar).offset(4);
        make.left.equalTo(imgAvatar.mas_right).offset(5.0);
        make.bottom.equalTo(imgAvatar.mas_centerY);
        make.right.equalTo(lbTime.mas_left).offset(-5.0);
    }];
    
//    lbMissed.backgroundColor = UIColor.redColor;
//    lbMissed.clipsToBounds = YES;
//    lbMissed.layer.cornerRadius = 18.0/2;
//    [lbMissed mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(_imgAvatar.mas_right).offset(-18.0);
//        make.top.equalTo(_imgAvatar).offset(0);
//        make.width.height.mas_equalTo(18.0);
//    }];
//    lbMissed.font = [UIFont systemFontOfSize: 12.0];
//    lbMissed.textColor = UIColor.whiteColor;
//    lbMissed.textAlignment = NSTextAlignmentCenter;
    
    imgDirection.clipsToBounds = YES;
    imgDirection.layer.cornerRadius = 17.0/2;
    imgDirection.layer.borderColor = UIColor.whiteColor.CGColor;
    imgDirection.layer.borderWidth = 1.0;
    
    [imgDirection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lbName);
        make.bottom.equalTo(imgAvatar.mas_bottom);
        make.width.height.mas_equalTo(17.0);
    }];
    
    
    [lbNumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbName.mas_bottom);
        make.left.equalTo(imgDirection.mas_right).offset(5.0);
        make.right.equalTo(lbName);
        make.bottom.equalTo(imgAvatar.mas_bottom);
    }];
    
    lbSepa.backgroundColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0)
                                               blue:(235/255.0) alpha:1.0];
    [lbSepa mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.height.mas_equalTo(1.0);
    }];
    
    //    UIColor *cbColor = [UIColor colorWithRed:(17/255.0) green:(186/255.0)
    //                                        blue:(153/255.0) alpha:1.0];
//    UIColor *cbColor = UIColor.redColor;
//    _cbDelete.lineWidth = 1.0;
//    _cbDelete.boxType = BEMBoxTypeCircle;
//    _cbDelete.onAnimationType = BEMAnimationTypeStroke;
//    _cbDelete.offAnimationType = BEMAnimationTypeStroke;
//    _cbDelete.tintColor = cbColor;
//    _cbDelete.onTintColor = cbColor;
//    _cbDelete.onFillColor = cbColor;
//    _cbDelete.onCheckColor = UIColor.whiteColor;
//    [_cbDelete mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self).offset(-10);
//        make.centerY.equalTo(self.mas_centerY);
//        make.width.height.mas_equalTo(24.0);
//    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
