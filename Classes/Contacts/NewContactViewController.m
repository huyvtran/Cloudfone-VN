//
//  NewContactViewController.m
//  linphone
//
//  Created by Ei Captain on 3/17/17.
//
//

#import "NewContactViewController.h"
#import "TypePhonePopupView.h"
#import "NewPhoneCell.h"
#import "TypePhoneObject.h"
#import "NSDatabase.h"
#import "NSData+Base64.h"
#import "PhoneMainView.h"
#import "ContactDetailObj.h"
//  Leo Kelvin
//  #import "OTRProtocolManager.h"
#import "TypePhoneCell.h"
#import "PECropViewController.h"

@interface NewContactViewController ()<PECropViewControllerDelegate>{
    LinphoneAppDelegate *appDelegate;
    float marginX;
    float hTextfield;
    float hCell;
    
    TypePhonePopupView *popupTypePhone;
    
    YBHud *waitingHud;
    UIFont *textFont;
    
    UITableView *tbTypeContact;
    
    UITapGestureRecognizer *tapOnScreen;
    
    PECropViewController *PECropController;
}

@end

@implementation NewContactViewController
@synthesize _viewHeader, _iconBack, _lbHeader, _iconDone;
@synthesize _scrollViewContent, _viewInfo, _imgAvatar, _imgChangePicture, _btnAvatar, _tfFullName, _tfCloudFoneID, _tfCompany;
@synthesize _iconType, _tfType, _btnType, _iconEmail, _tfEmail, _tbPhones;
@synthesize currentSipPhone, currentPhoneNumber, currentName;

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
    if (compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:nil
                                                                 tabBar:nil
                                                               sideMenu:nil
                                                             fullscreen:false
                                                         isLeftFragment:false
                                                           fragmentWith:nil];
    }
    return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
    return self.class.compositeViewDescription;
}

#pragma mark - my controller
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

//  View không bị thay đổi sau khi vào pickerview controller
- (void) viewDidLayoutSubviews {
    if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        CGRect viewBounds = self.view.bounds;
        CGFloat topBarOffset = self.topLayoutGuide.length;
        viewBounds.origin.y = topBarOffset * -1;
        self.view.bounds = viewBounds;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //  my code here
    appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate._newContact == nil) {
        appDelegate._newContact = [[ContactObject alloc] init];
        appDelegate._newContact._listPhone = [[NSMutableArray alloc] init];
    }
    
    [self setupUIForView];
    
    //  add waiting view
    waitingHud = [[YBHud alloc] initWithHudType:DGActivityIndicatorAnimationTypeLineScale andText:@""];
    waitingHud.tintColor = [UIColor whiteColor];
    waitingHud.dimAmount = 0.5;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [self showContentWithCurrentLanguage];
    
    if (appDelegate._newContact == nil) {
        appDelegate._newContact = [[ContactObject alloc] init];
        appDelegate._newContact._listPhone = [[NSMutableArray alloc] init];
    }
    if (currentSipPhone != nil && ![currentSipPhone isEqualToString:@""]) {
        appDelegate._newContact._sipPhone = currentSipPhone;
    }
    
    if (currentName != nil && ![currentName isEqualToString:@""]) {
        appDelegate._newContact._fullName = currentName;
        appDelegate._newContact._firstName = currentName;
    }
    
    if (currentPhoneNumber != nil && ![currentPhoneNumber isEqualToString:@""]) {
        ContactDetailObj *aPhone = [[ContactDetailObj alloc] init];
        aPhone._iconStr = @"btn_contacts_mobile.png";
        aPhone._titleStr = [appDelegate.localization localizedStringForKey:type_phone_mobile];
        aPhone._valueStr = currentPhoneNumber;
        aPhone._buttonStr = @"contact_detail_icon_call.png";
        aPhone._typePhone = type_phone_mobile;
        [appDelegate._newContact._listPhone addObject: aPhone];
    }
    
    
    //  Nếu đang thêm contact từ request kết bạn
    if (appDelegate._newContact._accept) {
        _tfCloudFoneID.enabled = NO;
        _tfCloudFoneID.backgroundColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                          blue:(200/255.0) alpha:1.0];
    }else{
        _tfCloudFoneID.enabled = YES;
        _tfCloudFoneID.backgroundColor = [UIColor clearColor];
    }
    
    
    [self showAllInformationOfView];
    [self updateAllUIForView];
    
    if (appDelegate._dataCrop != nil) {
        _imgAvatar.image = [UIImage imageWithData: appDelegate._dataCrop];
        _imgChangePicture.hidden = YES;
    }else{
        _imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
        _imgChangePicture.hidden = NO;
    }
    
    //  notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification object:nil];
    //  Chọn loại điện thoại
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenSelectTypeForPhone:)
                                                 name:selectTypeForPhoneNumber object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(afterAddAndReloadContactDone)
                                                 name:finishLoadContacts object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)_iconBackClicked:(UIButton *)sender {
    currentSipPhone = @"";
    currentPhoneNumber = @"";
    appDelegate._dataCrop = nil;
    appDelegate._cropAvatar = nil;
    
    [[PhoneMainView instance] popCurrentView];
}

- (IBAction)_iconDoneClicked:(UIButton *)sender {
    [self.view endEditing: true];
    
    [waitingHud showInView:self.view animated:YES];
    
    for (int iCount=0; iCount<appDelegate._newContact._listPhone.count; iCount++) {
        ContactDetailObj *aPhone = [appDelegate._newContact._listPhone objectAtIndex: iCount];
        if ([aPhone._valueStr isEqualToString: @""]) {
            [appDelegate._newContact._listPhone removeObject: aPhone];
            iCount--;
        }
    }
    
    [self addContacts];
}

- (IBAction)_btnAvatarPressed:(UIButton *)sender {
    [self.view endEditing: YES];
    appDelegate._chooseMyAvatar =  NO;
    if (appDelegate._dataCrop != nil) {
        UIActionSheet *popupAddContact = [[UIActionSheet alloc] initWithTitle:[appDelegate.localization localizedStringForKey:text_options] delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:text_cancel] destructiveButtonTitle:nil otherButtonTitles:
                                          [appDelegate.localization localizedStringForKey:text_gallery],
                                          [appDelegate.localization localizedStringForKey:text_camera],
                                          [appDelegate.localization localizedStringForKey:text_remove],
                                          nil];
        popupAddContact.tag = 100;
        [popupAddContact showInView:self.view];
    }else{
        UIActionSheet *popupAddContact = [[UIActionSheet alloc] initWithTitle:[appDelegate.localization localizedStringForKey:text_options] delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:text_cancel] destructiveButtonTitle:nil otherButtonTitles:
                                          [appDelegate.localization localizedStringForKey:text_gallery],
                                          [appDelegate.localization localizedStringForKey:text_camera],
                                          nil];
        popupAddContact.tag = 101;
        [popupAddContact showInView:self.view];
    }
}

#pragma mark - my functions

- (void)showContentWithCurrentLanguage {
    _lbHeader.text = [appDelegate.localization localizedStringForKey: text_new_contact];
    _tfFullName.placeholder = [appDelegate.localization localizedStringForKey:text_contact_name];
    _tfEmail.placeholder = [appDelegate.localization localizedStringForKey:text_contact_email];
    _tfCloudFoneID.placeholder = [appDelegate.localization localizedStringForKey:text_contact_cloudfoneId];
    _tfCompany.placeholder = [appDelegate.localization localizedStringForKey:text_contact_company];
    _tfType.text = [appDelegate.localization localizedStringForKey:text_contact_type];
}

//  Thêm mới contact
- (void)addContacts
{
    //  cloudfoneID
    NSString *sipPhone = _tfCloudFoneID.text;
    appDelegate._newContact._sipPhone = sipPhone;
    
    //  email
    NSString *strEmail = [_tfEmail text];
    [appDelegate._newContact set_email: strEmail];
    
    // Add thêm cloudfone id vào list phone
    if (![sipPhone isEqualToString: @""]) {
        ContactDetailObj *aPhone = [[ContactDetailObj alloc] init];
        aPhone._typePhone = type_cloudfone_id;
        aPhone._iconStr = @"btn_contacts_mobile.png";
        aPhone._titleStr = [appDelegate.localization localizedStringForKey:type_cloudfone_id];
        aPhone._valueStr = sipPhone;
        aPhone._buttonStr = @"contact_detail_icon_call.png";
        [appDelegate._newContact._listPhone addObject: aPhone];
    }
    appDelegate._newContact._firstName = _tfFullName.text;
    appDelegate._newContact._lastName = @"";
    appDelegate._newContact._fullName = _tfFullName.text;
    appDelegate._newContact._company = _tfCompany.text;
    
    NSString *convertName = [AppUtils convertUTF8CharacterToCharacter: _tfFullName.text];
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
        if (aPhone._valueStr == nil || [aPhone._valueStr isEqualToString:@""]) {
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
    
    // Instant Message
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"SIP", (NSString*)kABPersonInstantMessageServiceKey,
                                appDelegate._newContact._sipPhone, (NSString*)kABPersonInstantMessageUsernameKey, nil];
    CFStringRef label = NULL; // in this case 'IM' will be set. But you could use something like = CFSTR("Personal IM");
    CFErrorRef errorf = NULL;
    ABMutableMultiValueRef values =  ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
    BOOL didAdd = ABMultiValueAddValueAndLabel(values, (__bridge CFTypeRef)(dictionary), label, NULL);
    BOOL didSet = ABRecordSetValue(aRecord, kABPersonInstantMessageProperty, values, &errorf);
    if (!didAdd || !didSet) {
        CFStringRef errorDescription = CFErrorCopyDescription(errorf);
        NSLog(@"%s error %@ while inserting multi dictionary property %@ into ABRecordRef", __FUNCTION__, dictionary, errorDescription);
        CFRelease(errorDescription);
    }
    CFRelease(values);
    
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
    
    CFStringRef firstName, lastName, company;
    firstName = ABRecordCopyValue(aRecord, kABPersonFirstNameProperty);
    lastName  = ABRecordCopyValue(aRecord, kABPersonLastNameProperty);
    company  = ABRecordCopyValue(aRecord, kABPersonOrganizationProperty);
    
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
    CFRelease(firstName);
    CFRelease(lastName);
    CFRelease(company);
    CFRelease(email);
    CFRelease(addressBook);
    
    [self afterAddContactSuccessfully];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadContactAfterAdd" object:nil];
}

- (NSString *)getAvatarOfContact: (ABRecordRef)aPerson
{
    NSString *avatar = @"";
    if (aPerson != nil) {
        NSData  *imgData = (__bridge NSData *)ABPersonCopyImageData(aPerson);
        if (imgData != nil) {
            UIImage *imageAvatar = [UIImage imageWithData: imgData];
            CGRect rect = CGRectMake(0,0,120,120);
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

- (NSString *)getSipIdOfContact: (ABRecordRef)aPerson {
    if (aPerson != nil) {
        NSString *sipNumber = (__bridge NSString *)ABRecordCopyValue(aPerson, kABPersonFirstNamePhoneticProperty);
        if (sipNumber == nil) {
            sipNumber = @"";
        }
        [sipNumber stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        return sipNumber;
    }
    return @"";
}

//  Xử lý kết bạn khi thêm thành công
- (void)afterAddContactSuccessfully {
    if (![appDelegate._newContact._sipPhone isEqualToString: @""] && appDelegate._internetActive) {
        [self checkIsCloudFoneNumber: appDelegate._newContact._sipPhone];
    }
}

- (void)afterAddAndReloadContactDone {
    [waitingHud dismissAnimated:YES];
    appDelegate._newContact = nil;
    [self.view makeToast:[appDelegate.localization localizedStringForKey:text_successfully]
                duration:1.0 position:CSToastPositionCenter];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self
                                   selector:@selector(backToView)
                                   userInfo:nil repeats:NO];
}

- (void)backToView{
    appDelegate._dataCrop = nil;
    appDelegate._newContact = nil;
    [[PhoneMainView instance] popCurrentView];
}

//  Kiểm tra có phải số cloudfone hay không?
- (void)checkIsCloudFoneNumber: (NSString *)cloudfone
{
    //  Kiểm tra trong ds chờ kết bạn có hay ko? có thì accept, ko thì thêm mới.
    BOOL exists = [NSDatabase checkRequestFriendExistsOnList:cloudfone];
    if (exists) {
        NSString *user = [NSString stringWithFormat:@"%@@%@", cloudfone, xmpp_cloudfone];
        NSString *me = [NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone];
        [appDelegate.myBuddy.protocol acceptRequestFromUser:user toMe:me];
    }else{
        BOOL isFriend = [self checkContactIsFriendOnList: cloudfone];
        if (!isFriend) {
            //  Gửi request kết bạn
            NSString *toUser = [NSString stringWithFormat:@"%@@%@", cloudfone, xmpp_cloudfone];
            NSString *idRequest = [NSString stringWithFormat:@"requestsent_%@", [AppUtils randomStringWithLength: 10]];
            BOOL added = [NSDatabase addUserToRequestSent:cloudfone withIdRequest:idRequest];
            if (added) {
                //  Gửi lệnh remove để reset lại nếu trạng thái subscrition đang là from hoặc to
                appDelegate._cloudfoneRequestSent = toUser;
                [appDelegate.myBuddy.protocol removeUserFromRosterList:toUser withIdMessage:idRequest];
                
                NSString *profileName = [NSDatabase getProfielNameOfAccount:USERNAME];
                [appDelegate.myBuddy.protocol sendRequestUserInfoOf:appDelegate.myBuddy.accountName
                                                             toUser:toUser
                                                        withContent:[appDelegate.localization localizedStringForKey:text_hi]
                                                     andDisplayName:profileName];
            }
        }
    }
}

- (void)showResultPopupFinish {
    [waitingHud dismissAnimated:YES];
    appDelegate._newContact = nil;
    
    [[PhoneMainView instance] popCurrentView];
}

//  Kiểm tra cloudfoneID đã kết bạn hay chưa?
- (BOOL)checkContactIsFriendOnList : (NSString *)cloudfoneID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self CONTAINS[cd] %@", cloudfoneID];
    NSArray *filter = [appDelegate._listFriends filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        return YES;
    }else{
        return NO;
    }
}

//  Chọn loại phone
- (void)whenSelectTypeForPhone: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[TypePhoneObject class]]) {
        int curIndex = (int)[popupTypePhone tag];
        ContactDetailObj *curPhone = [appDelegate._newContact._listPhone objectAtIndex: curIndex];
        curPhone._typePhone = [(TypePhoneObject *)object _strType];
        [_tbPhones reloadData];
    }
}

- (void)showAllInformationOfView
{
    [_tbPhones reloadData];
    
    //  fullname
    NSString *fullname = @"";
    if (appDelegate._newContact._firstName != nil && appDelegate._newContact._lastName != nil) {
        fullname = [NSString stringWithFormat:@"%@ %@", appDelegate._newContact._firstName, appDelegate._newContact._lastName];
    }else if (appDelegate._newContact._firstName != nil && appDelegate._newContact._lastName == nil){
        fullname = appDelegate._newContact._firstName;
    }else if (appDelegate._newContact._firstName == nil && appDelegate._newContact._lastName != nil){
        fullname = appDelegate._newContact._lastName;
    }
    _tfFullName.text = fullname;
    
    //  cloudfone ID
    if (![appDelegate._newContact._sipPhone isEqualToString: @""] && appDelegate._newContact._sipPhone != nil) {
        _tfCloudFoneID.text = appDelegate._newContact._sipPhone;
    }else{
        _tfCloudFoneID.text = @"";
    }
    
    //  company
    if (![appDelegate._newContact._company isEqualToString: @""] && appDelegate._newContact._company != nil) {
        _tfCompany.text = appDelegate._newContact._company;
    }else{
        _tfCompany.text = @"";
    }
    
    //  email
    if (![appDelegate._newContact._email isEqualToString: @""] && appDelegate._newContact._email != nil) {
        _tfEmail.text = appDelegate._newContact._email;
    }else{
        _tfEmail.text = @"";
    }
    [self checkFirstNameAndLastNameForDoneIcon];
}

- (void)setupUIForView {
    //  Tap vào màn hình để đóng bàn phím
    float wAvatar;
    
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
        hTextfield = 35.0;
        wAvatar = 80.0;
    }else{
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
        hTextfield = 30.0;
        wAvatar = 75.0;
    }
    
    //  Tap vào màn hình để đóng bàn phím
    tapOnScreen = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                          action:@selector(whenTapOnMainScreen)];
    tapOnScreen.delegate = self;
    self.view.userInteractionEnabled = YES;
    [self.view addGestureRecognizer: tapOnScreen];
    
    marginX = 10.0;
    hCell = hTextfield + 10;
    
    //  view header
    _viewHeader.frame = CGRectMake(0, -appDelegate._hStatus, SCREEN_WIDTH, appDelegate._hStatus+appDelegate._hHeader);
    
    _iconBack.frame = CGRectMake(0, appDelegate._hStatus, appDelegate._hHeader, appDelegate._hHeader);
    [_iconBack setBackgroundImage:[UIImage imageNamed:@"ic_back_act.png"]
                         forState:UIControlStateHighlighted];
    
    _iconDone.frame = CGRectMake(_viewHeader.frame.size.width-appDelegate._hHeader, _iconBack.frame.origin.y, _iconBack.frame.size.width, _iconBack.frame.size.height);
    [_iconDone setBackgroundImage:[UIImage imageNamed:@"ic_done_act.png"]
                         forState:UIControlStateHighlighted];
    
    _lbHeader.frame = CGRectMake(_iconBack.frame.origin.x+_iconBack.frame.size.width+5, appDelegate._hStatus, (_viewHeader.frame.size.width-2*_iconBack.frame.size.width-10), appDelegate._hHeader);
    if (SCREEN_WIDTH > 320) {
        _lbHeader.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:20.0];
    }else{
        _lbHeader.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }
    
    //  scroll view content
    _scrollViewContent.frame = CGRectMake(0, _viewHeader.frame.origin.y+_viewHeader.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT-appDelegate._hHeader-appDelegate._hStatus);
    
    //  view info
    float hInfo = 7 + hTextfield + 7 + hTextfield + 7 + hTextfield + 7;
    _viewInfo.frame = CGRectMake(0, 0, _scrollViewContent.frame.size.width, hInfo);
    
    _imgAvatar.frame = CGRectMake((hInfo-wAvatar)/2, (hInfo-wAvatar)/2, wAvatar, wAvatar);
    _imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
    _imgAvatar.layer.cornerRadius = wAvatar/2;
    _imgAvatar.clipsToBounds = YES;
    
    _imgChangePicture.frame = CGRectMake(_imgAvatar.frame.origin.x+(wAvatar-25)/2, _imgAvatar.frame.origin.y+wAvatar-25-5, 25, 25);
    
    _btnAvatar.frame = _imgAvatar.frame;
    
    _tfFullName.font = textFont;
    _tfFullName.frame = CGRectMake(_imgAvatar.frame.origin.x+_imgAvatar.frame.size.width+7, 7, _scrollViewContent.frame.size.width-(2*_imgAvatar.frame.origin.x+_imgAvatar.frame.size.width+7), hTextfield);
    _tfFullName.backgroundColor = UIColor.clearColor;
    
    [_tfFullName addTarget:self
                    action:@selector(whenTextfieldDidChanged:)
          forControlEvents:UIControlEventEditingChanged];
    
    //  cloudfoneID
    _tfCloudFoneID.font = textFont;
    _tfCloudFoneID.frame = CGRectMake(_tfFullName.frame.origin.x, _tfFullName.frame.origin.y+_tfFullName.frame.size.height+7, _tfFullName.frame.size.width, _tfFullName.frame.size.height);
    _tfCloudFoneID.backgroundColor = UIColor.clearColor;
    _tfCloudFoneID.keyboardType = UIKeyboardTypeNumberPad;
    [_tfCloudFoneID addTarget:self
                    action:@selector(whenTextfieldDidChanged:)
          forControlEvents:UIControlEventEditingChanged];
    
    //  company
    _tfCompany.font = textFont;
    _tfCompany.frame = CGRectMake(_tfCloudFoneID.frame.origin.x, _tfCloudFoneID.frame.origin.y+_tfCloudFoneID.frame.size.height+7, _tfCloudFoneID.frame.size.width, _tfCloudFoneID.frame.size.height);
    _tfCompany.backgroundColor = UIColor.clearColor;
    [_tfCompany addTarget:self
                   action:@selector(whenTextfieldDidChanged:)
         forControlEvents:UIControlEventEditingChanged];
    
    //  type contact
    _iconType.frame = CGRectMake(marginX, _viewInfo.frame.origin.y+_viewInfo.frame.size.height+10, hTextfield, hTextfield);
    
    _tfType.font = textFont;
    _tfType.frame = CGRectMake(_iconType.frame.origin.x+_iconType.frame.size.width+marginX, _iconType.frame.origin.y, _scrollViewContent.frame.size.width-(_iconType.frame.origin.x+_iconType.frame.size.width+marginX+marginX), hTextfield);
    _tfType.enabled = NO;
    
    _btnType.frame = _tfType.frame;
    [_btnType addTarget:self
                 action:@selector(btnTypeContactPressed)
       forControlEvents:UIControlEventTouchUpInside];
    
    //  email
    _iconEmail.frame = CGRectMake(_iconType.frame.origin.x, _iconType.frame.origin.y+_iconType.frame.size.height+10, _iconType.frame.size.width, _iconType.frame.size.height);
    
    _tfEmail.font = textFont;
    _tfEmail.frame = CGRectMake(_tfType.frame.origin.x, _iconEmail.frame.origin.y, _tfType.frame.size.width, hTextfield);
    _tfEmail.backgroundColor = UIColor.clearColor;
    _tfEmail.keyboardType = UIKeyboardTypeEmailAddress;
    [_tfEmail addTarget:self
                 action:@selector(whenTextfieldDidChanged:)
       forControlEvents:UIControlEventEditingChanged];
    
    
    //  email
    _tbPhones.frame = CGRectMake(0, _tfEmail.frame.origin.y+_tfEmail.frame.size.height+10, _scrollViewContent.frame.size.width, hCell);
    _tbPhones.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tbPhones.delegate = self;
    _tbPhones.dataSource = self;
    _tbPhones.scrollEnabled = NO;
    
    _scrollViewContent.contentSize = CGSizeMake(SCREEN_WIDTH, _tbPhones.frame.origin.y+_tbPhones.frame.size.height+15);
}

- (void)btnTypeContactPressed {
    if (tbTypeContact == nil) {
        tbTypeContact = [[UITableView alloc] initWithFrame: CGRectMake(_tfType.frame.origin.x, _tfType.frame.origin.y+_tfType.frame.size.height+2, _tfType.frame.size.width/2, 0)];
        tbTypeContact.delegate = self;
        tbTypeContact.dataSource = self;
        tbTypeContact.layer.borderColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0)
                                                           blue:(220/255.0) alpha:1.0].CGColor;
        tbTypeContact.layer.borderWidth = 1.0;
        tbTypeContact.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_scrollViewContent addSubview: tbTypeContact];
    }
    
    if (tbTypeContact.frame.size.height == 0) {
        [UIView animateWithDuration:0.2 animations:^{
            tbTypeContact.frame = CGRectMake(tbTypeContact.frame.origin.x, tbTypeContact.frame.origin.y, tbTypeContact.frame.size.width, 2*hCell);
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            tbTypeContact.frame = CGRectMake(tbTypeContact.frame.origin.x, tbTypeContact.frame.origin.y, tbTypeContact.frame.size.width, 0);
        }];
    }
}

//  Hiển thị bàn phím
- (void)keyboardDidShow: (NSNotification *) notif{
    CGSize keyboardSize = [[[notif userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.05 animations:^{
        _scrollViewContent.frame = CGRectMake(0, _viewHeader.frame.origin.y+_viewHeader.frame.size.height, _scrollViewContent.frame.size.width, SCREEN_HEIGHT-(appDelegate._hStatus+appDelegate._hHeader+keyboardSize.height));
    }];
}

//  Ẩn bàn phím
- (void)keyboardDidHide: (NSNotification *) notif{
    [UIView animateWithDuration:0.05 animations:^{
        _scrollViewContent.frame = CGRectMake(0, _viewHeader.frame.origin.y+_viewHeader.frame.size.height, _scrollViewContent.frame.size.width, SCREEN_HEIGHT-(appDelegate._hStatus+appDelegate._hHeader));
    }];
}

//  Tap vào màn hình chính để đóng bàn phím
- (void)whenTapOnMainScreen {
    [self.view endEditing: true];
    
    [UIView animateWithDuration:0.2 animations:^{
        tbTypeContact.frame = CGRectMake(tbTypeContact.frame.origin.x, tbTypeContact.frame.origin.y, tbTypeContact.frame.size.width, 0);
    }];
}

- (void)whenTextfieldDidChanged: (UITextField *)textfield {
    if (textfield == _tfFullName) {
        if ([_tfFullName.text isEqualToString: @""]) {
            _iconDone.hidden = YES;
        }else{
            _iconDone.hidden = NO;
        }
        //  Lưu giá trị first name
        appDelegate._newContact._firstName = _tfFullName.text;
    }if (textfield == _tfCompany) {
        //  Lưu giá trị company
        appDelegate._newContact._company = _tfCompany.text;
    }else if (textfield == _tfCloudFoneID){
        //  Lưu giá trị cloudfoneID
        appDelegate._newContact._sipPhone = _tfCloudFoneID.text;
    }else if (textfield == _tfEmail){
        //  Lưu giá trị email
        appDelegate._newContact._email = _tfEmail.text;
    }
}

//  Hiển thị icon done nếu có firstname hoặc lastname
- (void)checkFirstNameAndLastNameForDoneIcon {
    if ([_tfFullName.text isEqualToString: @""]) {
        _iconDone.hidden = YES;
    }else{
        _iconDone.hidden = NO;
    }
}

//  Thêm hoặc xoá số phone
- (void)btnAddPhonePressed: (UIButton *)sender {
    int tag = (int)[sender tag];
    if (tag < appDelegate._newContact._listPhone.count) {
        [appDelegate._newContact._listPhone removeObjectAtIndex: tag];
    }else{
        NewPhoneCell *cell = [_tbPhones cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tag inSection:0]];
        if (![cell._tfPhone.text isEqualToString:@""]) {
            ContactDetailObj *aPhone = [[ContactDetailObj alloc] init];
            aPhone._iconStr = @"btn_contacts_mobile.png";
            aPhone._titleStr = [appDelegate.localization localizedStringForKey:type_phone_mobile];
            aPhone._valueStr = cell._tfPhone.text;
            aPhone._buttonStr = @"contact_detail_icon_call.png";
            aPhone._typePhone = type_phone_mobile;
            [appDelegate._newContact._listPhone addObject: aPhone];
        }else{
            [self.view makeToast:[appDelegate.localization localizedStringForKey:please_input_phone_number]
                        duration:2.0 position:CSToastPositionCenter];
        }
    }
    //  Khi thêm mới hoặc xoá thì chỉ có dòng cuối cùng là new
    [_tbPhones reloadData];
    [self updateAllUIForView];
}

//  Chọn loại phone cho điện thoại
- (void)btnTypePhonePressed: (UIButton *)sender {
    [self.view endEditing: true];
    
    float hPopup;
    if (SCREEN_WIDTH > 320) {
        hPopup = 4*50 + 6;
    }else{
        hPopup = 4*40 + 6;
    }
    
    popupTypePhone = [[TypePhonePopupView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-236)/2, (SCREEN_HEIGHT-hPopup)/2, 236, hPopup)];
    [popupTypePhone setTag: sender.tag];
    [popupTypePhone showInView:appDelegate.window animated:YES];
}

//  Cập nhật vị trí các ui trong view
- (void)updateAllUIForView {
    [_tbPhones setFrame: CGRectMake(0, _tfEmail.frame.origin.y+_tfEmail.frame.size.height+10, _scrollViewContent.frame.size.width, (appDelegate._newContact._listPhone.count+1)*hCell)];
    
    [_scrollViewContent setContentSize: CGSizeMake(SCREEN_WIDTH, _tbPhones.frame.origin.y+_tbPhones.frame.size.height+15)];
}

//  Get icon tương ứng với loại phone
- (NSString *)getTypeOfPhone: (NSString *)typePhone {
    if ([typePhone isEqualToString: type_phone_mobile]) {
        return @"btn_contacts_mobile.png";
    }else if ([typePhone isEqualToString: type_phone_work]){
        return @"btn_contacts_work.png";
    }else if ([typePhone isEqualToString: type_phone_fax]){
        return @"btn_contacts_fax.png";
    }else if ([typePhone isEqualToString: type_phone_home]){
        return @"btn_contacts_home.png";
    }else{
        return @"btn_contacts_mobile.png";
    }
}

- (void)whenTextfieldPhoneDidChanged: (UITextField *)textfield {
    int row = (int)[textfield tag];
    if (row < appDelegate._newContact._listPhone.count) {
        ContactDetailObj *curPhone = [appDelegate._newContact._listPhone objectAtIndex: row];
        [curPhone set_valueStr: textfield.text];
    }
}

#pragma mark - UITableview Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _tbPhones) {
        return [appDelegate._newContact._listPhone count] + 1;
    }else{
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _tbPhones) {
        static NSString *identifier = @"NewPhoneCell";
        NewPhoneCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"NewPhoneCell" owner:self options:nil];
            cell = topLevelObjects[0];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, _tbPhones.frame.size.width, hCell);
        [cell setupUIForCell];
        cell._tfPhone.placeholder = [appDelegate.localization localizedStringForKey:text_phone];
        
        if (indexPath.row == appDelegate._newContact._listPhone.count) {
            cell._tfPhone.text = @"";
            
            [cell._iconNewPhone setBackgroundImage:[UIImage imageNamed:@"ic_add_phone.png"]
                                          forState:UIControlStateNormal];
            [cell._iconTypePhone setBackgroundImage:[UIImage imageNamed:@"btn_contacts_mobile"]
                                           forState:UIControlStateNormal];
        }else{
            ContactDetailObj *aPhone = [appDelegate._newContact._listPhone objectAtIndex: indexPath.row];
            cell._tfPhone.text = aPhone._valueStr;
            
            [cell._iconNewPhone setBackgroundImage:[UIImage imageNamed:@"ic_delete_phone.png"]
                                          forState:UIControlStateNormal];
            NSString *imgType = aPhone._iconStr;
            cell._iconTypePhone.tag = indexPath.row;
            [cell._iconTypePhone setBackgroundImage:[UIImage imageNamed:imgType]
                                           forState:UIControlStateNormal];
        }
        cell._tfPhone.tag = indexPath.row;
        [cell._tfPhone addTarget:self
                          action:@selector(whenTextfieldPhoneDidChanged:)
                forControlEvents:UIControlEventEditingChanged];
        
        cell._iconNewPhone.tag = indexPath.row;
        [cell._iconNewPhone addTarget:self
                               action:@selector(btnAddPhonePressed:)
                     forControlEvents:UIControlEventTouchUpInside];
        
        [cell._iconTypePhone addTarget:self
                                action:@selector(btnTypePhonePressed:)
                      forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }else{
        static NSString *cellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        if (indexPath.row == 0) {
            cell.textLabel.text = [appDelegate.localization localizedStringForKey:TEXT_TYPE_INDIVIDUAL];
        }else{
            cell.textLabel.text = [appDelegate.localization localizedStringForKey:TEXT_TYPE_COMPANY];
        }
        cell.textLabel.font = textFont;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == tbTypeContact){
        if (indexPath.row == 0) {
            _tfType.text = [appDelegate.localization localizedStringForKey:TEXT_TYPE_INDIVIDUAL];
        }else{
            _tfType.text = [appDelegate.localization localizedStringForKey:TEXT_TYPE_COMPANY];
        }
        appDelegate._newContact._type = (int)indexPath.row;
        
        [UIView animateWithDuration:0.2 animations:^{
            tbTypeContact.frame = CGRectMake(tbTypeContact.frame.origin.x, tbTypeContact.frame.origin.y, tbTypeContact.frame.size.width, 0);
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _tbPhones) {
        return hCell;
    }else{
        return hCell;
    }
}

#pragma mark - ContactDetailsImagePickerDelegate Functions

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    appDelegate._cropAvatar = image;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self openEditor];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView: tbTypeContact]) {
        return NO;
    }
    return YES;
}

- (void)openEditor {
    PECropController = [[PECropViewController alloc] init];
    PECropController.delegate = self;
    PECropController.image = appDelegate._cropAvatar;
    
    UIImage *image = appDelegate._cropAvatar;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat length = MIN(width, height);
    PECropController.imageCropRect = CGRectMake((width - length) / 2,
                                          (height - length) / 2,
                                          length,
                                          length);
    PECropController.keepingCropAspectRatio = true;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController: PECropController];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [[PhoneMainView instance] changeCurrentView:PECropViewController.compositeViewDescription
                                           push:true];
    
    //  [self presentViewController:navigationController animated:YES completion:NULL];
}

#pragma mark - PECropViewControllerDelegate methods

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage transform:(CGAffineTransform)transform cropRect:(CGRect)cropRect
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    appDelegate._dataCrop = UIImagePNGRepresentation(croppedImage);
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - ActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 100) {
        switch (buttonIndex) {
            case 0:{
                [self pressOnGallery];
                break;
            }
            case 1:{
                [self pressOnCamera];
                break;
            }
            case 2:{
                [self removeAvatar];
                break;
            }
            case 3:{
                NSLog(@"Cancel");
                break;
            }
        }
    }else if (actionSheet.tag == 101){
        switch (buttonIndex) {
            case 0:{
                [self pressOnGallery];
                break;
            }
            case 1:{
                [self pressOnCamera];
                break;
            }
        }
    }
}

- (void)pressOnCamera {
    appDelegate.fromImagePicker = YES;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    [picker setDelegate: self];
    [picker setSourceType: UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)pressOnGallery {
    appDelegate.fromImagePicker = YES;
    
    UILabel *testLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, -20, 320, 20)];
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    [pickerController.view addSubview: testLabel];
    
    pickerController.delegate = self;
    [self presentViewController:pickerController animated:YES completion:nil];
}

- (void)removeAvatar {
    appDelegate._newContact._avatar = @"";
    _imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
    _imgChangePicture.hidden = NO;
    appDelegate._dataCrop = nil;
    [_tbPhones reloadData];
}

@end
