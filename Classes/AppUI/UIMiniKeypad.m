//
//  UIMiniKeypad.m
//  linphone
//
//  Created by user on 18/12/13.
//
//

#import "UIMiniKeypad.h"

@implementation UIMiniKeypad
@synthesize oneButton;
@synthesize twoButton;
@synthesize threeButton;
@synthesize fourButton;
@synthesize fiveButton;
@synthesize sevenButton;
@synthesize sixButton;
@synthesize eightButton;
@synthesize nineButton;
@synthesize zeroButton;
@synthesize sharpButton;
@synthesize starButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
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

@end
