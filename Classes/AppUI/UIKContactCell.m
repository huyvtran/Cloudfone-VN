//
//  UIKContactCell.m
//  linphone
//
//  Created by user on 29/5/14.
//
//

#import "UIKContactCell.h"

@interface UIKContactCell (){
    float wIcon;
}

@end

@implementation UIKContactCell
@synthesize typeImage, lbTitle, lbValue, _imageDetails, _btnCall, _lbSepa;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    if (SCREEN_WIDTH > 320) {
        wIcon = 34.0;
        lbTitle.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
        lbValue.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }else{
        wIcon = 26.0;
        lbTitle.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
        lbValue.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
    }
    lbTitle.textColor = UIColor.grayColor;
    lbValue.textColor = [UIColor colorWithRed:(50/255.0) green:(50/255.0)
                                         blue:(50/255.0) alpha:1];
    _lbSepa.backgroundColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0)
                                               blue:(235/255.0) alpha:1.0];
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
    typeImage.frame = CGRectMake(10, (self.frame.size.height-wIcon)/2, wIcon, wIcon);
    _imageDetails.frame = CGRectMake(self.frame.size.width-10-typeImage.frame.size.width, typeImage.frame.origin.y, typeImage.frame.size.width, typeImage.frame.size.height);
    _btnCall.frame = _imageDetails.frame;
    
    [lbTitle sizeToFit];
    lbTitle.frame = CGRectMake(typeImage.frame.origin.x+typeImage.frame.size.width+5, 0, lbTitle.frame.size.width, self.frame.size.height);
    lbValue.frame = CGRectMake(lbTitle.frame.origin.x+lbTitle.frame.size.width+10, 0, _imageDetails.frame.origin.x-5-(lbTitle.frame.origin.x+lbTitle.frame.size.width+10), self.frame.size.height);
    _lbSepa.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
}

- (void)setupFrameForContactDetail {
    _imageDetails.frame = CGRectMake(self.frame.size.width-10-typeImage.frame.size.width, typeImage.frame.origin.y, typeImage.frame.size.width, typeImage.frame.size.height);
    _btnCall.frame = _imageDetails.frame;
    
    [lbTitle sizeToFit];
    lbTitle.frame = CGRectMake(10, 0, lbTitle.frame.size.width, self.frame.size.height);
    lbValue.frame = CGRectMake(lbTitle.frame.origin.x+lbTitle.frame.size.width+10, 0, _imageDetails.frame.origin.x-5-(lbTitle.frame.origin.x+lbTitle.frame.size.width+10), self.frame.size.height);
    lbTitle.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
}

@end
