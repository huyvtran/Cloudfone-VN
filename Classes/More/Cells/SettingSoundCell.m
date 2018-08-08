//
//  SettingSoundCell.m
//  linphone
//
//  Created by admin on 2/3/18.
//

#import "SettingSoundCell.h"

@implementation SettingSoundCell
@synthesize lbTitle, swAction;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    swAction.onTintColor = [UIColor colorWithRed:(24/255.0) green:(185/255.0)
                                            blue:(153/255.0) alpha:1.0];
    swAction.tintColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0)
                                          blue:(220/255.0) alpha:1.0];
    if (SCREEN_WIDTH > 320) {
        lbTitle.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }else{
        lbTitle.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupUIForCell {
    float marginX = 10;
    swAction.frame = CGRectMake(self.frame.size.width-marginX-49.0, (self.frame.size.height-31.0)/2, 49.0, 31.0);
    lbTitle.frame = CGRectMake(marginX, 0, self.frame.size.width-(3*marginX+swAction.frame.size.width), self.frame.size.height);
    _lbSepa.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
}

@end
