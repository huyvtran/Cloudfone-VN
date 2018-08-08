//
//  ChatProfileCell.m
//  linphone
//
//  Created by Ei Captain on 7/6/16.
//
//

#import "ChatProfileCell.h"

@implementation ChatProfileCell
@synthesize _imgAvatar, _imgClock, _lbName, _lbStatus, _lbSepa;
@synthesize _callnexID, _idContact;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _imgAvatar.layer.cornerRadius = 25.0;
    
    _lbName.marqueeType = MLContinuous;
    _lbName.scrollDuration = 15.0;
    _lbName.animationCurve = UIViewAnimationOptionCurveEaseInOut;
    _lbName.fadeLength = 10.0;
    _lbName.continuousMarqueeExtraBuffer = 10.0;
    _lbName.textColor = UIColor.blackColor;
    _lbName.font = [UIFont fontWithName:MYRIADPRO_BOLD size:18.0];
    _lbName.backgroundColor = UIColor.clearColor;
    
    //  status
    _lbStatus.marqueeType = MLContinuous;
    _lbStatus.scrollDuration = 15.0;
    _lbStatus.animationCurve = UIViewAnimationOptionCurveEaseInOut;
    _lbStatus.fadeLength = 10.0;
    _lbStatus.continuousMarqueeExtraBuffer = 10.0;
    _lbStatus.textColor = UIColor.darkGrayColor;
    _lbStatus.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:12.0];
    _lbStatus.backgroundColor = UIColor.clearColor;
    _lbStatus.hidden = NO;
    
    _imgAvatar.layer.masksToBounds = YES;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithRed:(223/255.0) green:(255/255.0)
                                                blue:(133/255.0) alpha:1];
    }else{
        self.backgroundColor = UIColor.clearColor;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setupUIForCell {
    _imgAvatar.frame = CGRectMake(5, 5, self.frame.size.height-10, self.frame.size.height-10);
    _imgAvatar.layer.cornerRadius = (self.frame.size.height-10)/2;
    _imgClock.frame = CGRectMake(_imgAvatar.frame.origin.x+_imgAvatar.frame.size.width-10, _imgAvatar.frame.origin.y+(_imgAvatar.frame.size.height-20)/2, 20.0, 20.0);
    _lbName.frame = CGRectMake(_imgClock.frame.origin.x+_imgClock.frame.size.width+5, _imgAvatar.frame.origin.y, self.frame.size.width-(_imgClock.frame.origin.x+_imgClock.frame.size.width+10), _imgAvatar.frame.size.height/2);
    _lbStatus.frame = CGRectMake(_lbName.frame.origin.x, _lbName.frame.origin.y+_lbName.frame.size.height, _lbName.frame.size.width, _lbName.frame.size.height);
    _lbSepa.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
}

@end
