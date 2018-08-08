//
//  UIHistoryDetailCell.m
//  linphone
//
//  Created by user on 19/3/14.
//
//

#import "UIHistoryDetailCell.h"

@implementation UIHistoryDetailCell
@synthesize lbTime,lbDuration,lbRate,viewContent,viewTitle,lbTitle, _imageClock;

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    lbDuration.textColor = [UIColor colorWithRed:(142/255.0) green:(193/255.0)
                                            blue:(5/255.0) alpha:1];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setupUIForCell
{
    _imageClock.frame = CGRectMake(5, (self.frame.size.height-15)/2, 15.0, 15.0);
    lbRate.frame = CGRectMake(self.frame.size.width-_imageClock.frame.origin.x-70, 0, 70, self.frame.size.height);
    lbTime.frame = CGRectMake(_imageClock.frame.origin.x+_imageClock.frame.size.width+5, 0, 100, self.frame.size.height);
    lbDuration.frame = CGRectMake(lbTime.frame.origin.x+lbTime.frame.size.width+5, 0, lbRate.frame.origin.x-5-(lbTime.frame.origin.x+lbTime.frame.size.width+5), self.frame.size.height);
}

-(void) dealloc{
}

@end
