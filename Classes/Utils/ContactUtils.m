//
//  ContactUtils.m
//  linphone
//
//  Created by lam quang quan on 11/2/18.
//

#import "ContactUtils.h"

@implementation ContactUtils

+ (PhoneObject *)getContactPhoneObjectWithNumber: (NSString *)number {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"number = %@", number];
    NSArray *filter = [[LinphoneAppDelegate sharedInstance].listInfoPhoneNumber filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        for (int i=0; i<filter.count; i++) {
            PhoneObject *item = [filter objectAtIndex: i];
            if (![AppUtils isNullOrEmpty: item.avatar]) {
                return item;
            }
        }
        return [filter firstObject];
    }
    return nil;
}

+ (NSString *)getContactNameWithNumber: (NSString *)number {
    PhoneObject *contact = [self getContactPhoneObjectWithNumber: number];
    if (![AppUtils isNullOrEmpty: contact.name]) {
        return contact.name;
    }
    return number;
}

+ (NSAttributedString *)getSearchValueFromResultForNewSearchMethod: (NSArray *)searchs
{
    UIFont *font = [UIFont fontWithName:MYRIADPRO_BOLD size:16.0];
    NSMutableAttributedString *attrResult = [[NSMutableAttributedString alloc] init];
    
    if (searchs.count == 1) {
        PhoneObject *phone = [searchs firstObject];
        
        [attrResult appendAttributedString:[[NSAttributedString alloc] initWithString: phone.name]];
        [attrResult addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, phone.name.length)];
        [attrResult addAttribute: NSLinkAttributeName value:phone.number range: NSMakeRange(0, phone.name.length)];
    }else if (searchs.count == 2)
    {
        PhoneObject *phone = [searchs firstObject];
        
        [attrResult appendAttributedString:[[NSAttributedString alloc] initWithString: phone.name]];
        [attrResult addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, phone.name.length)];
        [attrResult addAttribute: NSLinkAttributeName value:phone.number range: NSMakeRange(0, phone.name.length)];
        
        phone = [searchs lastObject];
        
        NSString *strOR = [NSString stringWithFormat:@" %@ ", [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"or"]];
        [attrResult appendAttributedString:[[NSAttributedString alloc] initWithString: strOR]];
        
        NSMutableAttributedString *secondAttr = [[NSMutableAttributedString alloc] initWithString: phone.name];
        [secondAttr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, phone.name.length)];
        [secondAttr addAttribute: NSLinkAttributeName value:phone.number range: NSMakeRange(0, phone.name.length)];
        [attrResult appendAttributedString:secondAttr];
    }else{
        PhoneObject *phone = [searchs firstObject];
        
        NSMutableAttributedString * str1 = [[NSMutableAttributedString alloc] initWithString:phone.name];
        [str1 addAttribute: NSLinkAttributeName value:phone range: NSMakeRange(0, phone.name.length)];
        [str1 addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleNone) range:NSMakeRange(0, phone.name.length)];
        [str1 addAttribute: NSFontAttributeName value: font range: NSMakeRange(0, phone.name.length)];
        [attrResult appendAttributedString:str1];
        
        NSString *strAND = [NSString stringWithFormat:@" %@ ", [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"and"]];
        NSMutableAttributedString * attrAnd = [[NSMutableAttributedString alloc] initWithString:strAND];
        [attrAnd addAttribute: NSFontAttributeName value: [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0]
                        range: NSMakeRange(0, strAND.length)];
        [attrResult appendAttributedString:attrAnd];
        
        NSString *strOthers = [NSString stringWithFormat:@"%d %@", (int)searchs.count-1, [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"others"]];
        NSMutableAttributedString * str2 = [[NSMutableAttributedString alloc] initWithString:strOthers];
        [str2 addAttribute: NSLinkAttributeName value: @"others" range: NSMakeRange(0, strOthers.length)];
        [str2 addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleNone) range:NSMakeRange(0, strOthers.length)];
        [str2 addAttribute: NSFontAttributeName value: font range: NSMakeRange(0, strOthers.length)];
        [attrResult appendAttributedString:str2];
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [attrResult addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attrResult.string.length)];
    
    return attrResult;
}

+ (ContactObject *)getContactWithId: (int)idContact {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_id_contact = %d", idContact];
    NSArray *filter = [[LinphoneAppDelegate sharedInstance].listContacts filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        return [filter objectAtIndex: 0];
    }
    return nil;
}

+ (PBXContact *)getPBXContactWithId: (int)idContact {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_id_contact = %d", idContact];
    NSArray *filter = [[LinphoneAppDelegate sharedInstance].listContacts filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        return [filter objectAtIndex: 0];
    }
    return nil;
}


+ (void)addBorderForImageView: (UIImageView *)imageView withRectSize: (float)rectSize strokeWidth: (int)stroke strokeColor: (UIColor *)strokeColor radius: (float)radius
{
    CGRect rectangle = CGRectMake(0, 0, rectSize-2*stroke, rectSize-2*stroke);
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(rectSize, rectSize), false, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, CGRectMake(0, 0, rectSize, rectSize));
    CGContextSaveGState(context);
    
    // offset the draw to allow the line thickness to not get clipped
    if (stroke > 0) {
        CGContextTranslateCTM(context, stroke, stroke);
    }
    
    //Rounded rectangle
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetFillColorWithColor(context, UIColor.greenColor.CGColor);
    
    //Rectangle from Fours Bezier Curves
    UIBezierPath *bezierCurvePath = [UIBezierPath bezierPath];
    if (stroke > 0) {
        bezierCurvePath.lineWidth = stroke;
    }
    
    //set coner points
    CGPoint topLPoint = CGPointMake(CGRectGetMinX(rectangle), CGRectGetMinY(rectangle));
    topLPoint.x += radius;
    topLPoint.y += radius;
    
    CGPoint topRPoint = CGPointMake(CGRectGetMaxX(rectangle), CGRectGetMinY(rectangle));
    topRPoint.x -= radius;
    topRPoint.y += radius;
    
    CGPoint botLPoint = CGPointMake(CGRectGetMinX(rectangle), CGRectGetMaxY(rectangle));
    botLPoint.x += radius;
    botLPoint.y -= radius;
    
    CGPoint botRPoint = CGPointMake(CGRectGetMaxX(rectangle), CGRectGetMaxY(rectangle));
    botRPoint.x -= radius;
    botRPoint.y -= radius;
    
    //    //set start-end points
    CGPoint midRPoint = CGPointMake(CGRectGetMaxX(rectangle), CGRectGetMidY(rectangle));
    CGPoint botMPoint = CGPointMake(CGRectGetMidX(rectangle), CGRectGetMaxY(rectangle));
    CGPoint topMPoint = CGPointMake(CGRectGetMidX(rectangle), CGRectGetMinY(rectangle));
    CGPoint midLPoint = CGPointMake(CGRectGetMinX(rectangle), CGRectGetMidY(rectangle));
    
    //  Four Bezier Curve
    [bezierCurvePath moveToPoint:midLPoint];
    [bezierCurvePath addCurveToPoint:topMPoint controlPoint1:topLPoint controlPoint2:topLPoint];
    [bezierCurvePath moveToPoint:topMPoint];
    [bezierCurvePath addCurveToPoint:midRPoint controlPoint1:topRPoint controlPoint2:topRPoint];
    [bezierCurvePath moveToPoint:midRPoint];
    [bezierCurvePath addCurveToPoint:botMPoint controlPoint1:botRPoint controlPoint2:botRPoint];
    [bezierCurvePath moveToPoint:botMPoint];
    [bezierCurvePath addCurveToPoint:midLPoint controlPoint1:botLPoint controlPoint2:botLPoint];
    
    [bezierCurvePath stroke];
    [bezierCurvePath fill];
    
    CGContextSetFillColorWithColor(context, UIColor.yellowColor.CGColor);
    UIBezierPath *subPath = [UIBezierPath bezierPath];
    [subPath moveToPoint: midLPoint];
    [subPath addLineToPoint: topMPoint];
    [subPath addLineToPoint: midRPoint];
    [subPath addLineToPoint: botMPoint];
    [subPath closePath];
    [subPath fill];
    [bezierCurvePath appendPath: subPath];
    
    //  UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    CGContextRestoreGState(context);
    
    UIGraphicsEndImageContext();
    
    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    borderLayer.path = bezierCurvePath.CGPath;
    
    imageView.layer.mask = borderLayer;
}

@end
