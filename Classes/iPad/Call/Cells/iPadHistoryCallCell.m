//
//  iPadHistoryCallCell.m
//  linphone
//
//  Created by admin on 1/16/19.
//

#import "iPadHistoryCallCell.h"

@implementation iPadHistoryCallCell
@synthesize imgAvatar, lbName, lbTime, imgDirection, lbNumber, icCall, lbSepa, cbDelete;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    float padding = 10.0;
    lbName.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightRegular];
    lbNumber.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightThin];
    lbTime.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightThin];
    
    float hAvatar = 42.0;
    [ContactUtils addBorderForImageView:imgAvatar withRectSize:hAvatar strokeWidth:0 strokeColor:nil radius:1.0];
    [imgAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(padding);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(hAvatar);
    }];
    
    icCall.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [icCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-5.0);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(40.0);
    }];
    
    lbTime.textAlignment = NSTextAlignmentRight;
    lbTime.textColor = UIColor.darkGrayColor;
    [lbTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgAvatar);
        make.bottom.equalTo(imgAvatar);
        make.right.equalTo(icCall.mas_left).offset(-5.0);
        make.width.mas_equalTo(65.0);
    }];
    
    [lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(5);
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
    
    lbNumber.textColor = lbTime.textColor;
    [lbNumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbName.mas_bottom);
        make.left.equalTo(imgDirection.mas_right).offset(5.0);
        make.right.equalTo(lbName);
        make.bottom.equalTo(self).offset(-5.0);
    }];
    
    lbSepa.backgroundColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0)
                                               blue:(235/255.0) alpha:1.0];
    [lbSepa mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.height.mas_equalTo(1.0);
    }];
    
    UIColor *cbColor = UIColor.redColor;
    cbDelete.lineWidth = 1.0;
    cbDelete.boxType = BEMBoxTypeCircle;
    cbDelete.onAnimationType = BEMAnimationTypeStroke;
    cbDelete.offAnimationType = BEMAnimationTypeStroke;
    cbDelete.tintColor = cbColor;
    cbDelete.onTintColor = cbColor;
    cbDelete.onFillColor = cbColor;
    cbDelete.onCheckColor = UIColor.whiteColor;
    [cbDelete mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-10);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(24.0);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (selected) {
        self.backgroundColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0)
                                                blue:(220/255.0) alpha:1];
    }else{
        self.backgroundColor = UIColor.whiteColor;
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0)
                                                blue:(220/255.0) alpha:1];
    }else{
        self.backgroundColor = UIColor.whiteColor;
    }
}

@end
