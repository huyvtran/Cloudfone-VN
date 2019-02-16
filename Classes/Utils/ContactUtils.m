//
//  ContactUtils.m
//  linphone
//
//  Created by lam quang quan on 11/2/18.
//

#import "ContactUtils.h"
#import "ContactDetailObj.h"

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
        [str1 addAttribute: NSLinkAttributeName value:phone.number range: NSMakeRange(0, phone.name.length)];
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
    imageView.clipsToBounds = YES;
}

+ (void)addNewContacts
{
    LinphoneAppDelegate *appDelegate = [LinphoneAppDelegate sharedInstance];
    NSString *convertName = [AppUtils convertUTF8CharacterToCharacter: appDelegate._newContact._firstName];
    NSString *nameForSearch = [AppUtils getNameForSearchOfConvertName:convertName];
    appDelegate._newContact._nameForSearch = nameForSearch;
    
    
    if (appDelegate._dataCrop != nil) {
        if ([appDelegate._dataCrop respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
            // iOS 7+
            appDelegate._newContact._avatar = [appDelegate._dataCrop base64EncodedStringWithOptions: 0];
        } else {
            // pre iOS7
            appDelegate._newContact._avatar = [appDelegate._dataCrop base64Encoding];
        }
    }else{
        appDelegate._newContact._avatar = @"";
    }
    
    ABRecordRef aRecord = ABPersonCreate();
    CFErrorRef  anError = NULL;
    
    // Lưu thông tin
    ABRecordSetValue(aRecord, kABPersonFirstNameProperty, (__bridge CFTypeRef)(appDelegate._newContact._firstName), &anError);
    ABRecordSetValue(aRecord, kABPersonLastNameProperty, (__bridge CFTypeRef)(appDelegate._newContact._lastName), &anError);
    ABRecordSetValue(aRecord, kABPersonOrganizationProperty, (__bridge CFTypeRef)(appDelegate._newContact._company), &anError);
    ABRecordSetValue(aRecord, kABPersonFirstNamePhoneticProperty, (__bridge CFTypeRef)(appDelegate._newContact._sipPhone), &anError);
    
    if (appDelegate._newContact._email == nil) {
        appDelegate._newContact._email = @"";
    }
    
    ABMutableMultiValueRef email = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(email, (__bridge CFTypeRef)(appDelegate._newContact._email), CFSTR("email"), NULL);
    ABRecordSetValue(aRecord, kABPersonEmailProperty, email, &anError);
    
    if (appDelegate._dataCrop != nil) {
        CFDataRef cfdata = CFDataCreate(NULL,[appDelegate._dataCrop bytes], [appDelegate._dataCrop length]);
        ABPersonSetImageData(aRecord, cfdata, &anError);
    }
    
    // Phone number
    NSMutableArray *listPhone = [[NSMutableArray alloc] init];
    ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    
    for (int iCount=0; iCount<appDelegate._newContact._listPhone.count; iCount++) {
        ContactDetailObj *aPhone = [appDelegate._newContact._listPhone objectAtIndex: iCount];
        if ([AppUtils isNullOrEmpty: aPhone._valueStr]) {
            continue;
        }
        if ([aPhone._typePhone isEqualToString: type_phone_mobile]) {
            ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(aPhone._valueStr), kABPersonPhoneMobileLabel, NULL);
            [listPhone addObject: aPhone];
        }else if ([aPhone._typePhone isEqualToString: type_phone_work]){
            ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(aPhone._valueStr), kABWorkLabel, NULL);
            [listPhone addObject: aPhone];
        }else if ([aPhone._typePhone isEqualToString: type_phone_fax]){
            ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(aPhone._valueStr), kABPersonPhoneHomeFAXLabel, NULL);
            [listPhone addObject: aPhone];
        }else if ([aPhone._typePhone isEqualToString: type_phone_home]){
            ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(aPhone._valueStr), kABHomeLabel, NULL);
            [listPhone addObject: aPhone];
        }else if ([aPhone._typePhone isEqualToString: type_phone_other]){
            ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(aPhone._valueStr), kABOtherLabel, NULL);
            [listPhone addObject: aPhone];
        }
    }
    ABRecordSetValue(aRecord, kABPersonPhoneProperty, multiPhone,nil);
    CFRelease(multiPhone);
    
    //Address
    ABMutableMultiValueRef address = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
    NSMutableDictionary *addressDict = [[NSMutableDictionary alloc] init];
    [addressDict setObject:@"" forKey:(NSString *)kABPersonAddressStreetKey];
    [addressDict setObject:@"" forKey:(NSString *)kABPersonAddressZIPKey];
    [addressDict setObject:@"" forKey:(NSString *)kABPersonAddressStateKey];
    [addressDict setObject:@"" forKey:(NSString *)kABPersonAddressCityKey];
    [addressDict setObject:@"" forKey:(NSString *)kABPersonAddressCountryKey];
    ABMultiValueAddValueAndLabel(address, (__bridge CFTypeRef)(addressDict), kABWorkLabel, NULL);
    ABRecordSetValue(aRecord, kABPersonAddressProperty, address, &anError);
    
    if (anError != NULL) {
        NSLog(@"error while creating..");
    }
    
    ABAddressBookRef addressBook;
    CFErrorRef error = NULL;
    addressBook = ABAddressBookCreateWithOptions(nil, &error);
    
    BOOL isAdded = ABAddressBookAddRecord (addressBook,aRecord,&error);
    
    if(isAdded){
        NSLog(@"added..");
    }
    if (error != NULL) {
        NSLog(@"ABAddressBookAddRecord %@", error);
    }
    error = NULL;
    
    BOOL isSaved = ABAddressBookSave (addressBook,&error);
    if(isSaved){
        NSLog(@"saved..");
    }
    
    if (error != NULL) {
        NSLog(@"ABAddressBookSave %@", error);
    }
    
    CFRelease(aRecord);
    CFRelease(email);
    CFRelease(addressBook);
}

+ (BOOL)deleteContactFromPhoneWithId: (int)recordId {
    CFErrorRef error = NULL;
    ABAddressBookRef listAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    ABRecordRef aPerson = ABAddressBookGetPersonWithRecordID(listAddressBook, recordId);
    ABAddressBookRemoveRecord(listAddressBook, aPerson, nil);
    return ABAddressBookSave (listAddressBook,&error);
}

@end
