//
//  PBXContactTableCell.m
//  linphone
//
//  Created by admin on 12/14/17.
//

#import "PBXContactTableCell.h"

@implementation PBXContactTableCell
@synthesize _imgAvatar, _lbName, _lbPhone, _lbSepa;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateUIForCell {
    _imgAvatar.frame = CGRectMake(8, 8, self.frame.size.height-16, self.frame.size.height-16);
    _imgAvatar.clipsToBounds = YES;
    _imgAvatar.layer.cornerRadius = (self.frame.size.height-16)/2;
    
    _lbName.frame = CGRectMake(2*_imgAvatar.frame.origin.x+_imgAvatar.frame.size.width, _imgAvatar.frame.origin.y, self.frame.size.width-3*_imgAvatar.frame.origin.x, _imgAvatar.frame.size.height/2);
    _lbPhone.frame = CGRectMake(_lbName.frame.origin.x, _lbName.frame.origin.y+_lbName.frame.size.height, _lbName.frame.size.width, _lbName.frame.size.height);
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
