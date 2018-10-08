//
//  CustomTextAttachment.m
//  linphone
//
//  Created by lam quang quan on 10/8/18.
//

#import "CustomTextAttachment.h"

@implementation CustomTextAttachment
@synthesize imgHeight;

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex {
    CGRect bounds;
    bounds.origin = CGPointMake(0, -5);
    bounds.size = CGSizeMake(imgHeight, imgHeight);
    return bounds;
}

- (void)setImageHeight: (CGFloat)height {
    imgHeight = height;
}

@end
