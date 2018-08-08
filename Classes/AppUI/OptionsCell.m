//
//  OptionsCell.m
//  linphone
//
//  Created by Ei Captain on 4/14/17.
//
//

#import "OptionsCell.h"

@implementation OptionsCell
@synthesize _imgIcon, _lbTitle, _lbSepa;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    if (SCREEN_WIDTH > 320) {
        _lbTitle.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
    }else{
        _lbTitle.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:14.0];
    }
    _lbTitle.textColor = UIColor.darkGrayColor;
    _lbSepa.backgroundColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0)
                                               blue:(220/255.0) alpha:1.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupUIForCell {
    _imgIcon.frame = CGRectMake(5, 5, self.frame.size.height-10, self.frame.size.height-10);
    _lbTitle.frame = CGRectMake(_imgIcon.frame.origin.x+_imgIcon.frame.size.width+10, _imgIcon.frame.origin.y, self.frame.size.width-(15+_imgIcon.frame.size.width), _imgIcon.frame.size.height);
    _lbSepa.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
}

@end
