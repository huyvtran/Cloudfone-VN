//
//  ChatSettingCell.m
//  linphone
//
//  Created by admin on 1/12/18.
//

#import "ChatSettingCell.h"

@implementation ChatSettingCell
@synthesize _lbTitle, _swAction, _lbSepa, _imgArrow;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    if (SCREEN_WIDTH > 320) {
        _lbTitle.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }else{
        _lbTitle.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
    }
    _lbTitle.textColor = [UIColor darkGrayColor];
    wContent = SCREEN_WIDTH - [LinphoneAppDelegate sharedInstance]._wSubMenu;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupUIForCell {
    _swAction.frame = CGRectMake(wContent-15-49, (self.frame.size.height-31)/2, 49, 31);
    _lbTitle.frame = CGRectMake(15, 0, _swAction.frame.origin.x-5-15, self.frame.size.height);
    _lbSepa.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
    _imgArrow.frame = CGRectMake(wContent-self.frame.size.height, 0, self.frame.size.height, self.frame.size.height);
}

@end
