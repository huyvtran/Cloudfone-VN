//
//  EmotionCell.m
//  linphone
//
//  Created by user on 25/7/14.
//
//

#import "EmotionCell.h"

@implementation EmotionCell
@synthesize btnEmotion;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = UIColor.clearColor;
        btnEmotion.backgroundColor = UIColor.clearColor;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
}

@end
