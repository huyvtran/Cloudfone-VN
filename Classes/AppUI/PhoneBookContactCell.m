//
//  PhoneBookContactCell.m
//  linphone
//
//  Created by user on 11/8/14.
//
//

#import "PhoneBookContactCell.h"

@implementation PhoneBookContactCell
@synthesize imgAvatar, name, phone, _lbSepa, _iconChat;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setupUIForCell
{
    float marginX = 5.0;
    imgAvatar.frame = CGRectMake(marginX, 5, self.frame.size.height-10, self.frame.size.height-10);
    _iconChat.frame = CGRectMake(self.frame.size.width-5-45, (self.frame.size.height-45.0)/2, 45.0, 45.0);
    name.frame = CGRectMake(marginX+imgAvatar.frame.size.width+marginX, imgAvatar.frame.origin.y, _iconChat.frame.origin.x-(imgAvatar.frame.origin.x+imgAvatar.frame.size.width+marginX), imgAvatar.frame.size.height/2);
    phone.frame = CGRectMake(name.frame.origin.x, name.frame.origin.y+name.frame.size.height, name.frame.size.width, name.frame.size.height);
    _lbSepa.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
    _lbSepa.backgroundColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0)
                                               blue:(220/255.0) alpha:1.0];
    
    if (self.frame.size.width > 320) {
        name.font = [UIFont fontWithName:MYRIADPRO_BOLD size:17.0];
        phone.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:17.0];
    }else{
        name.font = [UIFont fontWithName:MYRIADPRO_BOLD size:15.0];
        phone.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:15.0];
    }
    name.textColor = [UIColor darkGrayColor];
    phone.textColor = [UIColor grayColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithRed:(223/255.0) green:(255/255.0) blue:(133/255.0) alpha:1];
    }else{
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void)dealloc {
}
@end
