//
//  PhoneCell.m
//  linphone
//
//  Created by user on 31/8/14.
//
//

#import "PhoneCell.h"

@implementation PhoneCell
@synthesize _iconImage, _stringValue, _lbSepa;

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    _lbSepa.backgroundColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0)
                                               blue:(220/255.0) alpha:1.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
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

- (void)setupUIForCell {
    _iconImage.frame = CGRectMake(5, self.frame.size.height/4, self.frame.size.height/2, self.frame.size.height/2);
    _stringValue.frame = CGRectMake(2*_iconImage.frame.origin.x+_iconImage.frame.size.width, 0, self.frame.size.width-(3*_iconImage.frame.origin.x+_iconImage.frame.size.width), self.frame.size.height);
    _lbSepa.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
}

- (void)hideIconForCell {
    _iconImage.hidden = YES;
    _stringValue.frame = CGRectMake(15, 0, self.frame.size.width-30, self.frame.size.height);
    _lbSepa.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
}

@end
