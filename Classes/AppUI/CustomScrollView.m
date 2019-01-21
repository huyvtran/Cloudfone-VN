//
//  CustomScrollView.m
//  linphone
//
//  Created by lam quang quan on 1/21/19.
//

#import "CustomScrollView.h"

@implementation CustomScrollView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *result = nil;
    for (UIView *child in self.subviews)
        if ([child pointInside:point withEvent:event])
            if ((result = [child hitTest:point withEvent:event]) != nil)
                break;
    
    return result;
}

@end
