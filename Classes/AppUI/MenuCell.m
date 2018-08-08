//
//  MenuCell.m
//  linphone
//
//  Created by Apple on 4/26/17.
//
//

#import "MenuCell.h"

@implementation MenuCell
@synthesize _iconImage, _lbTitle, _lbSepa;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    if (SCREEN_WIDTH > 320) {
        _lbTitle.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }else{
        _lbTitle.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:17.0];
    }
    _lbTitle.textColor = UIColor.darkGrayColor;
    _lbSepa.backgroundColor = [UIColor colorWithRed:(240/255.0) green:(240/255.0)
                                               blue:(240/255.0) alpha:1.0];
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

- (void)setupUIForCell {
    _iconImage.frame = CGRectMake(15, (self.frame.size.height-2)/4, (self.frame.size.height-2)/2, (self.frame.size.height-2)/2);
    _lbTitle.frame = CGRectMake(_iconImage.frame.origin.x+_iconImage.frame.size.width+_iconImage.frame.origin.x, _iconImage.frame.origin.y, self.frame.size.width-(3*_iconImage.frame.origin.x+_iconImage.frame.size.width), _iconImage.frame.size.height);
    _lbSepa.frame = CGRectMake(0, self.frame.size.height-2, self.frame.size.width, 2);
}

- (void)setupCellForPopupView {
    _iconImage.frame = CGRectMake(15, (self.frame.size.height-1)/6, (self.frame.size.height-1)*4/6, (self.frame.size.height-1)*4/6);
    _lbTitle.frame = CGRectMake(_iconImage.frame.origin.x+_iconImage.frame.size.width+_iconImage.frame.origin.x, _iconImage.frame.origin.y, self.frame.size.width-(3*_iconImage.frame.origin.x+_iconImage.frame.size.width), _iconImage.frame.size.height);
    _lbSepa.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
}

@end
