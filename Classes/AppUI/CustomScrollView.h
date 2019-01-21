//
//  CustomScrollView.h
//  linphone
//
//  Created by lam quang quan on 1/21/19.
//

#import <UIKit/UIKit.h>

@interface CustomScrollView : UIScrollView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event;

@end
