//
//  FriendForAcceptCell.m
//  linphone
//
//  Created by user on 10/14/15.
//
//

#import "FriendForAcceptCell.h"

@implementation FriendForAcceptCell
@synthesize _imgAvatar, _lbName, _lbNumber, _btnAccept, _btnDecline, _lbSepa;

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    _lbName.textColor = UIColor.blackColor;
    _lbName.font = [UIFont fontWithName:HelveticaNeueBold size:18.0];
    _lbName.backgroundColor = UIColor.clearColor;
    
    _lbNumber.font = [UIFont fontWithName:HelveticaNeue size:14.0];
    _btnAccept.backgroundColor = UIColor.clearColor;
    [_btnAccept setTitleColor:[UIColor colorWithRed:(125/255.0) green:(81/255.0)
                                               blue:(163/255.0) alpha:1.0]
                     forState:UIControlStateNormal];
    [_btnAccept setTitleColor:[UIColor colorWithRed:(125/255.0) green:(81/255.0)
                                               blue:(163/255.0) alpha:1.0]
                     forState:UIControlStateNormal];
    _btnAccept.titleLabel.font = [UIFont fontWithName:HelveticaNeue size:14.0];

    _btnDecline.backgroundColor = UIColor.clearColor;
    [_btnDecline setTitleColor:[UIColor colorWithRed:(125/255.0) green:(81/255.0)
                                                blue:(163/255.0) alpha:1.0]
                      forState:UIControlStateNormal];
    [_btnDecline setTitleColor:[UIColor colorWithRed:(125/255.0) green:(81/255.0)
                                                blue:(163/255.0) alpha:1.0]
                      forState:UIControlStateNormal];
    _btnDecline.titleLabel.font = [UIFont fontWithName:HelveticaNeue size:14.0];
    _imgAvatar.layer.masksToBounds = YES;
    
    _lbSepa.backgroundColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                               blue:(200/255.0) alpha:1.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setupUIForCell {
    _imgAvatar.frame = CGRectMake(8, 8, self.frame.size.height-16, self.frame.size.height-16);
    _imgAvatar.layer.cornerRadius = (self.frame.size.height-16)/2;
    
    _btnDecline.frame = CGRectMake(self.frame.size.width-37.0, (self.frame.size.height-37.0)/2, 37.0, 37.0);
    _btnAccept.frame = CGRectMake(_btnDecline.frame.origin.x-_btnDecline.frame.size.width, _btnDecline.frame.origin.y, _btnDecline.frame.size.width, _btnDecline.frame.size.height);
    
    _lbName.frame = CGRectMake(_imgAvatar.frame.origin.x+_imgAvatar.frame.size.width+5, _imgAvatar.frame.origin.y, _btnAccept.frame.origin.x-(_imgAvatar.frame.origin.x+_imgAvatar.frame.size.width+5+5), _imgAvatar.frame.size.height/2);
    _lbNumber.frame = CGRectMake(_lbName.frame.origin.x, _lbName.frame.origin.y+_lbName.frame.size.height, _lbName.frame.size.width, _lbName.frame.size.height);
    
    _lbSepa.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
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
