//
//  ChooseAccountCell.m
//  linphone
//
//  Created by Ei Captain on 7/6/16.
//
//

#import "ChooseAccountCell.h"

@implementation ChooseAccountCell
@synthesize _lbTitle, _lbValue, _imgSelect, _lbSepa;

- (void)awakeFromNib {
    [super awakeFromNib];
    // MY CODE HERE
    self.backgroundColor = UIColor.clearColor;
    _lbTitle.textColor = [UIColor colorWithRed:(50/255.0) green:(50/255.0)
                                          blue:(50/255.0) alpha:1];
    _lbValue.textColor = [UIColor colorWithRed:(50/255.0) green:(50/255.0)
                                          blue:(50/255.0) alpha:1];
    _lbSepa.backgroundColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0)
                                               blue:(220/255.0) alpha:1.0];
    
    _lbTitle.font = [UIFont fontWithName:HelveticaNeue size:15.0];
    _lbValue.font = [UIFont fontWithName:HelveticaNeue size:15.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setFrameForCell {
    [_lbTitle sizeToFit];
    _lbTitle.frame = CGRectMake(_lbTitle.frame.origin.x, (self.frame.size.height-_lbTitle.frame.size.height)/2, _lbTitle.frame.size.width, _lbTitle.frame.size.height);
    _lbValue.frame = CGRectMake(_lbTitle.frame.origin.x+_lbTitle.frame.size.width+5, _lbTitle.frame.origin.y, self.frame.size.width-(_lbTitle.frame.origin.x+_lbTitle.frame.size.width+5+20+10), _lbTitle.frame.size.height);
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
