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

+ (NSString *)onlyGetContactNameForCallWithNumber: (NSString *)number {
    PhoneObject *contact = [self getContactPhoneObjectWithNumber: number];
    if (![AppUtils isNullOrEmpty: contact.name]) {
        return contact.name;
    }
    return @"";
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

+ (ABRecordRef)addNewContacts
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
    return aRecord;
}

+ (BOOL)deleteContactFromPhoneWithId: (int)recordId {
    CFErrorRef error = NULL;
    ABAddressBookRef listAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    ABRecordRef aPerson = ABAddressBookGetPersonWithRecordID(listAddressBook, recordId);
    ABAddressBookRemoveRecord(listAddressBook, aPerson, nil);
    return ABAddressBookSave (listAddressBook,&error);
}

+ (NSString *)getFullnameOfContactIfExists {
    NSString *fullname = @"";
    
    if ([LinphoneAppDelegate sharedInstance]._newContact._firstName != nil && [LinphoneAppDelegate sharedInstance]._newContact._lastName != nil) {
        fullname = [NSString stringWithFormat:@"%@ %@", [LinphoneAppDelegate sharedInstance]._newContact._lastName, [LinphoneAppDelegate sharedInstance]._newContact._firstName];
        
    }else if ([LinphoneAppDelegate sharedInstance]._newContact._firstName != nil && [LinphoneAppDelegate sharedInstance]._newContact._lastName == nil){
        fullname = [LinphoneAppDelegate sharedInstance]._newContact._firstName;
        
    }else if ([LinphoneAppDelegate sharedInstance]._newContact._firstName == nil && [LinphoneAppDelegate sharedInstance]._newContact._lastName != nil){
        fullname = [LinphoneAppDelegate sharedInstance]._newContact._lastName;
    }
    return fullname;
}

+ (NSString *)getFullNameFromContact: (ABRecordRef)aPerson
{
    if (aPerson != nil) {
        NSString *firstName = (__bridge NSString *)ABRecordCopyValue(aPerson, kABPersonFirstNameProperty);
        firstName = [firstName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        firstName = [firstName stringByReplacingOccurrencesOfString:@"\n" withString: @""];
        
        NSString *middleName = (__bridge NSString *)ABRecordCopyValue(aPerson, kABPersonMiddleNameProperty);
        middleName = [middleName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        middleName = [middleName stringByReplacingOccurrencesOfString:@"\n" withString: @""];
        
        NSString *lastName = (__bridge NSString *)ABRecordCopyValue(aPerson, kABPersonLastNameProperty);
        lastName = [lastName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        lastName = [lastName stringByReplacingOccurrencesOfString:@"\n" withString: @""];
        
        // Lưu tên contact cho search phonebook
        NSString *fullname = @"";
        if (![AppUtils isNullOrEmpty: lastName]) {
            fullname = lastName;
        }
        
        if (![AppUtils isNullOrEmpty: middleName]) {
            if ([fullname isEqualToString:@""]) {
                fullname = middleName;
            }else{
                fullname = [NSString stringWithFormat:@"%@ %@", fullname, middleName];
            }
        }
        
        if (![AppUtils isNullOrEmpty: firstName]) {
            if ([fullname isEqualToString:@""]) {
                fullname = firstName;
            }else{
                fullname = [NSString stringWithFormat:@"%@ %@", fullname, firstName];
            }
        }
        if ([fullname isEqualToString:@""]) {
            return [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Unknown"];
        }
        return fullname;
    }
    return [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Unknown"];
}

+ (NSString *)getBase64AvatarFromContact: (ABRecordRef)aPerson
{
    NSString *avatar = @"";
    if (aPerson != nil) {
        NSData  *imgData = (__bridge NSData *)ABPersonCopyImageData(aPerson);
        if (imgData != nil) {
            UIImage *imageAvatar = [UIImage imageWithData: imgData];
            CGRect rect = CGRectMake(0, 0, 120, 120);
            UIGraphicsBeginImageContext(rect.size );
            [imageAvatar drawInRect:rect];
            UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            NSData *tmpImgData = UIImagePNGRepresentation(picture1);
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
                avatar = [tmpImgData base64EncodedStringWithOptions: 0];
            }
        }
    }
    return avatar;
}

+ (UIImage *)getAvatarFromContact: (ABRecordRef)aPerson
{
    if (aPerson != nil) {
        NSData  *imgData = (__bridge NSData *)ABPersonCopyImageData(aPerson);
        if (imgData != nil) {
            UIImage *imageAvatar = [UIImage imageWithData: imgData];
            CGRect rect = CGRectMake(0,0,120,120);
            UIGraphicsBeginImageContext(rect.size );
            [imageAvatar drawInRect:rect];
            UIImage *rsAvatar = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return rsAvatar;
        }
    }
    return [UIImage imageNamed:@"no_avatar.png"];
}

+ (NSString *)getEmailFromContact: (ABRecordRef)aPerson {
    NSString *email = @"";
    ABMultiValueRef map = ABRecordCopyValue(aPerson, kABPersonEmailProperty);
    if (map) {
        for (int i = 0; i < ABMultiValueGetCount(map); ++i) {
            ABMultiValueIdentifier identifier = ABMultiValueGetIdentifierAtIndex(map, i);
            NSInteger index = ABMultiValueGetIndexForIdentifier(map, identifier);
            if (index != -1) {
                NSString *valueRef = CFBridgingRelease(ABMultiValueCopyValueAtIndex(map, index));
                if (valueRef != NULL && ![valueRef isEqualToString:@""]) {
                    //  just get one email for contact
                    email = valueRef;
                    break;
                }
            }
        }
        CFRelease(map);
    }
    return email;
}

+ (NSString *)getCompanyFromContact: (ABRecordRef)aPerson {
    NSString *result = @"";
    CFStringRef companyRef  = ABRecordCopyValue(aPerson, kABPersonOrganizationProperty);
    if (companyRef != NULL && companyRef != nil){
        NSString *company = (__bridge NSString *)companyRef;
        if (company != nil && ![company isEqualToString:@""]){
            result = company;
        }
    }
    return result;
}

+ (NSMutableArray *)getListPhoneOfContactPerson: (ABRecordRef)aPerson
{
    NSMutableArray *result = nil;
    ABMultiValueRef phones = ABRecordCopyValue(aPerson, kABPersonPhoneProperty);
    NSString *strPhone = [[NSMutableString alloc] init];
    if (ABMultiValueGetCount(phones) > 0)
    {
        result = [[NSMutableArray alloc] init];
        
        for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
        {
            CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, j);
            CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(phones, j);
            
            NSString *phoneNumber = (__bridge NSString *)phoneNumberRef;
            phoneNumber = [AppUtils removeAllSpecialInString: phoneNumber];
            
            strPhone = @"";
            if (locLabel == nil) {
                ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                anItem._iconStr = @"btn_contacts_home.png";
                anItem._titleStr = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Home"];
                anItem._valueStr = [AppUtils removeAllSpecialInString: phoneNumber];
                anItem._buttonStr = @"contact_detail_icon_call.png";
                anItem._typePhone = type_phone_home;
                [result addObject: anItem];
            }else{
                if (CFStringCompare(locLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_home.png";
                    anItem._titleStr = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Home"];
                    anItem._valueStr = [AppUtils removeAllSpecialInString: phoneNumber];
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_home;
                    [result addObject: anItem];
                }else if (CFStringCompare(locLabel, kABWorkLabel, 0) == kCFCompareEqualTo)
                {
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_work.png";
                    anItem._titleStr = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Work"];
                    anItem._valueStr = [AppUtils removeAllSpecialInString: phoneNumber];
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_work;
                    [result addObject: anItem];
                }else if (CFStringCompare(locLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo)
                {
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_mobile.png";
                    anItem._titleStr = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Mobile"];
                    anItem._valueStr = [AppUtils removeAllSpecialInString: phoneNumber];
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_mobile;
                    [result addObject: anItem];
                }else if (CFStringCompare(locLabel, kABPersonPhoneHomeFAXLabel, 0) == kCFCompareEqualTo)
                {
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_fax.png";
                    anItem._titleStr = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Fax"];
                    anItem._valueStr = [AppUtils removeAllSpecialInString: phoneNumber];
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_fax;
                    [result addObject: anItem];
                }else if (CFStringCompare(locLabel, kABOtherLabel, 0) == kCFCompareEqualTo)
                {
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_fax.png";
                    anItem._titleStr = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Other"];
                    anItem._valueStr = [AppUtils removeAllSpecialInString: phoneNumber];
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_other;
                    [result addObject: anItem];
                }else{
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_mobile.png";
                    anItem._titleStr = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Mobile"];
                    anItem._valueStr = [AppUtils removeAllSpecialInString: phoneNumber];
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_mobile;
                    [result addObject: anItem];
                }
            }
        }
    }
    return result;
}

//  Get first name and last name of contact
+ (NSArray *)getFirstNameAndLastNameOfContact: (ABRecordRef)aPerson
{
    if (aPerson != nil) {
        NSString *firstName = (__bridge NSString *)ABRecordCopyValue(aPerson, kABPersonFirstNameProperty);
        if (firstName == nil) {
            firstName = @"";
        }
        firstName = [firstName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        firstName = [firstName stringByReplacingOccurrencesOfString:@"\n" withString: @""];
        
        NSString *middleName = (__bridge NSString *)ABRecordCopyValue(aPerson, kABPersonMiddleNameProperty);
        if (middleName == nil) {
            middleName = @"";
        }
        middleName = [middleName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        middleName = [middleName stringByReplacingOccurrencesOfString:@"\n" withString: @""];
        
        NSString *lastName = (__bridge NSString *)ABRecordCopyValue(aPerson, kABPersonLastNameProperty);
        if (lastName == nil) {
            lastName = @"";
        }
        lastName = [lastName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        lastName = [lastName stringByReplacingOccurrencesOfString:@"\n" withString: @""];
        
        // Lưu tên contact cho search phonebook
        NSString *fullname = @"";
        if (![lastName isEqualToString:@""]) {
            fullname = lastName;
        }
        
        if (![middleName isEqualToString:@""]) {
            if ([fullname isEqualToString:@""]) {
                fullname = middleName;
            }else{
                fullname = [NSString stringWithFormat:@"%@ %@", fullname, middleName];
            }
        }
        return @[firstName, fullname];
    }
    return @[@"", @""];
}

+ (NSString *)getFirstPhoneFromContact: (ABRecordRef)aPerson
{
    ABMultiValueRef phones = ABRecordCopyValue(aPerson, kABPersonPhoneProperty);
    if (ABMultiValueGetCount(phones) > 0)
    {
        for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
        {
            CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, j);
            NSString *phoneNumber = (__bridge NSString *)phoneNumberRef;
            phoneNumber = [AppUtils removeAllSpecialInString: phoneNumber];
            return phoneNumber;
        }
    }
    return @"";
}

@end
