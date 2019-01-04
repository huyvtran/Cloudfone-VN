//
//  MyScrollView.m
//  linphone
//
//  Created by lam quang quan on 1/4/19.
//

#import "MyScrollView.h"

@implementation MyScrollView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *result = nil;
    for (UIView *child in self.subviews)
        if ([child pointInside:point withEvent:event])
            if ((result = [child hitTest:point withEvent:event]) != nil)
                break;
    
    return result;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
