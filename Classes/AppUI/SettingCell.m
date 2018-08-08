//
//  SettingCell.m
//  linphone
//
//  Created by Apple on 4/26/17.
//
//

#import "SettingCell.h"

@implementation SettingCell
@synthesize _iconArrow, _lbSepa, _lbTitle, _iconImage;

- (void)awakeFromNib {
    [super awakeFromNib];
    //  my code here
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

- (void)setupUIForView {
    _lbSepa.frame = CGRectMake(0, self.frame.size.height-2, self.frame.size.width, 2);
    _iconImage.frame = CGRectMake(15, (self.frame.size.height-_lbSepa.frame.size.height-26.0)/2, 26.0, 26.0);
    _iconArrow.frame = CGRectMake(self.frame.size.width-self.frame.size.height, 0, self.frame.size.height, self.frame.size.height);
    _lbTitle.frame = CGRectMake(_iconImage.frame.origin.x+_iconImage.frame.size.width+10, _iconImage.frame.origin.y, _iconArrow.frame.origin.x-(_iconImage.frame.origin.x+_iconImage.frame.size.width+10), _iconImage.frame.size.height);
}

- (void)hideImageIconForView {
    _lbSepa.frame = CGRectMake(0, self.frame.size.height-2, self.frame.size.width, 2);
    _iconImage.frame = CGRectMake(15, 10, 0, self.frame.size.height-20);
    _iconArrow.frame = CGRectMake(self.frame.size.width-self.frame.size.height, 0, self.frame.size.height, self.frame.size.height);
    _lbTitle.frame = CGRectMake(_iconImage.frame.origin.x+_iconImage.frame.size.width+10, _iconImage.frame.origin.y, _iconArrow.frame.origin.x-(_iconImage.frame.origin.x+_iconImage.frame.size.width+10), _iconImage.frame.size.height);
}

@end
