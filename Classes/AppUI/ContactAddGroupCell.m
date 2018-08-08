//
//  ContactAddGroupCell.m
//  linphone
//
//  Created by user on 18/9/14.
//
//

#import "ContactAddGroupCell.h"

@implementation ContactAddGroupCell
@synthesize _imgAvatar, _lbContactName, _lbContactPhone, _iconCheckBox, _cloudfoneID, _lbSepa;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // MY CODE HERE
    _lbContactName.textColor = UIColor.blackColor;
    _lbContactName.font = [UIFont fontWithName:HelveticaNeue size:17.0];
    
    _lbContactPhone.textColor = UIColor.grayColor;
    _lbContactPhone.font = [UIFont fontWithName:HelveticaNeue size:14.0];
    
    UIColor *cbColor = [UIColor colorWithRed:(24/255.0) green:(185/255.0)
                                        blue:(153/255.0) alpha:1.0];
    _iconCheckBox.lineWidth = 2.0;
    _iconCheckBox.boxType = BEMBoxTypeSquare;
    _iconCheckBox.onAnimationType = BEMAnimationTypeStroke;
    _iconCheckBox.offAnimationType = BEMAnimationTypeStroke;
    _iconCheckBox.tintColor = cbColor;
    _iconCheckBox.onTintColor = cbColor;
    _iconCheckBox.onFillColor = cbColor;
    _iconCheckBox.onCheckColor = UIColor.whiteColor;
    _iconCheckBox.on = NO;
    _imgAvatar.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)dealloc {
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithRed:(223/255.0) green:(255/255.0)
                                                blue:(133/255.0) alpha:1];
    }else{
        self.backgroundColor = UIColor.clearColor;
    }
}

- (void)setupUIForCell {
    _imgAvatar.frame = CGRectMake(5, 5, self.frame.size.height-10, self.frame.size.height-10);
    _imgAvatar.layer.cornerRadius = (self.frame.size.height-10)/2;
    _iconCheckBox.frame = CGRectMake(self.frame.size.width-22-20, (self.frame.size.height-22)/2, 22, 22);
    _lbContactName.frame = CGRectMake(_imgAvatar.frame.origin.x+_imgAvatar.frame.size.width+5, _imgAvatar.frame.origin.y, _iconCheckBox.frame.origin.x-5-(_imgAvatar.frame.origin.x+_imgAvatar.frame.size.width+5), _imgAvatar.frame.size.height/2);
    _lbContactPhone.frame = CGRectMake(_lbContactName.frame.origin.x, _lbContactName.frame.origin.y+_lbContactName.frame.size.height, _lbContactName.frame.size.width, _lbContactName.frame.size.height);
    _lbSepa.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
}

@end
