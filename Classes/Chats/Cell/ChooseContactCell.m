//
//  ChooseContactCell.m
//  linphone
//
//  Created by admin on 1/8/18.
//

#import "ChooseContactCell.h"

@implementation ChooseContactCell
@synthesize _imgAvatar, _lbName, _lbPhone, _imgSelect, _lbSepa, _lbMember;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _lbName.textColor = [UIColor blackColor];
    _lbName.font = [UIFont fontWithName:HelveticaNeue size:17.0];
    _lbName.backgroundColor = [UIColor clearColor];
    
    _lbPhone.hidden = NO;
    _lbPhone.textColor = [UIColor grayColor];
    _lbPhone.font = [UIFont fontWithName:HelveticaNeue size:14.0];
    _lbPhone.backgroundColor = [UIColor clearColor];
    
    _lbSepa.backgroundColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0)
                                               blue:(235/255.0) alpha:1.0];
    _imgAvatar.layer.masksToBounds = YES;
    
    _lbMember.textColor = [UIColor grayColor];
    _lbMember.font = [UIFont fontWithName:HelveticaNeue size:14.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupUIForCell{
    _imgAvatar.frame = CGRectMake(5, 5, self.frame.size.height-10, self.frame.size.height-10);
    _imgAvatar.layer.cornerRadius = (self.frame.size.height-10)/2;
    _lbName.frame = CGRectMake(_imgAvatar.frame.origin.x+_imgAvatar.frame.size.width+10, _imgAvatar.frame.origin.y, (self.frame.size.width-(2*_imgAvatar.frame.origin.x+_imgAvatar.frame.size.width+10+60+20)), _imgAvatar.frame.size.height/2);
    _lbPhone.frame = CGRectMake(_lbName.frame.origin.x, _lbName.frame.origin.y+_lbName.frame.size.height, _lbName.frame.size.width, _lbName.frame.size.height);
    _imgSelect.frame = CGRectMake(self.frame.size.width-45-20, (self.frame.size.height-45)/2, 45, 45);
    _lbMember.frame = CGRectMake(self.frame.size.width-60-20, 3, 60, self.frame.size.height-6);
    _lbSepa.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
}

@end
