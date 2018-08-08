//
//  ContactNormalCell.m
//  linphone
//
//  Created by user on 9/29/15.
//
//

#import "ContactNormalCell.h"

@implementation ContactNormalCell
@synthesize _contactAvatar, _contactName, _lbSepa;

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    _contactName.backgroundColor = UIColor.clearColor;
    _lbSepa.backgroundColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0)
                                               blue:(235/255.0) alpha:1.0];
    _contactAvatar.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithRed:(223/255.0) green:(255/255.0)
                                                blue:(133/255.0) alpha:1];
    }else{
        self.backgroundColor = UIColor.clearColor;
    }
}

- (void)setupUIForCell{
    _contactAvatar.frame = CGRectMake(5, 5, self.frame.size.height-10, self.frame.size.height-10);
    _contactAvatar.layer.cornerRadius = (self.frame.size.height-10)/2;
    _contactName.frame = CGRectMake(_contactAvatar.frame.origin.x+_contactAvatar.frame.size.width+10, _contactAvatar.frame.origin.y, (self.frame.size.width-(2*_contactAvatar.frame.origin.x+_contactAvatar.frame.size.width+10+45+20)), _contactAvatar.frame.size.height);
    _lbSepa.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
}

@end
