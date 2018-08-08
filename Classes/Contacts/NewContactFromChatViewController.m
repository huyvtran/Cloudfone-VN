//
//  NewContactFromChatViewController.m
//  linphone
//
//  Created by Ei Captain on 4/13/17.
//
//

#import "NewContactFromChatViewController.h"
#import "TypePhoneObject.h"
#import "PhoneObject.h"
#import "TypePhonePopupView.h"
#import "ChooseAvatarPopupView.h"
#import "NewPhoneCell.h"
#import "SettingItem.h"
#import "PhoneMainView.h"
#import "NSDatabase.h"
#import "NSData+Base64.h"
#import "MBProgressHUD.h"

@interface NewContactFromChatViewController ()
{
    LinphoneAppDelegate *appDelegate;
    float marginX;
    float hTextfield;
    
    TypePhonePopupView *popupTypePhone;
    
    float hCell;
    
    NSData *cropAvatarData;
    
    ChooseAvatarPopupView *popupChooseAvatar;
    NSMutableArray *listOptions;
    
    MBProgressHUD *waitingHUD;
    
    int lastContactId;
    
    UITapGestureRecognizer *tapOnScreen;
    UIFont *textFont;
    UITableView *tbTypeContact;
}

@end

@implementation NewContactFromChatViewController
@synthesize _viewHeader, _iconBack, _lbHeader, _iconDone;
@synthesize _scrollViewContent, _viewInfo, _imgAvatar, _imgChangePicture, _btnAvatar, _tfFullName, _tfCompany, _tfCloudFoneID, _tfEmail, _tbPhones, _btnType, _tfType, _iconType, _iconEmail;
@synthesize _sipPhoneID;

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
    if (compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:nil
                                                                 tabBar:nil
                                                               sideMenu:nil
                                                             fullscreen:NO
                                                         isLeftFragment:false
                                                           fragmentWith:nil];
    }
    return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
    return self.class.compositeViewDescription;
}
#pragma mark - my controller

- (void)viewDidLoad {
    [super viewDidLoad];
    //  my code here
    appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [self showContentWithCurrentLanguage];
    
    if (appDelegate._newContact == nil) {
        appDelegate._newContact = [[ContactObject alloc] init];
        appDelegate._newContact._listPhone = [[NSMutableArray alloc] init];
    }
    appDelegate._newContact._sipPhone = _sipPhoneID;
    
    if (appDelegate._dataCrop != nil) {
        _imgAvatar.image = [UIImage imageWithData: appDelegate._dataCrop];
        _imgChangePicture.hidden = YES;
    }else{
        _imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
        _imgChangePicture.hidden = NO;
    }
    [self showAllInformationOfView];
    [self updateAllUIForView];
    
    //  notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification object:nil];
    //  Chọn loại điện thoại
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenSelectTypeForPhone:)
                                                 name:selectTypeForPhoneNumber object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveCloudFoneIDForView:)
                                                 name:saveNewContactFromChatView object:nil];
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
    appDelegate._dataCrop = nil;
    appDelegate._cropAvatar = nil;
    [[PhoneMainView instance] popCurrentView];
}

- (IBAction)_iconDoneClicked:(UIButton *)sender {
    [self.view endEditing: true];
    
    if (waitingHUD == nil) {
        // ProgessHUD cho watting
        waitingHUD = [[MBProgressHUD alloc] initWithView: self.view];
        waitingHUD.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        waitingHUD.labelText = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_saving];
        waitingHUD.dimBackground = YES;
        [self.view addSubview: waitingHUD];
    }
    [waitingHUD show: true];
    
    [NSTimer scheduledTimerWithTimeInterval:30.0 target:self
                                   selector:@selector(saveContactTimeOut)
                                   userInfo:nil repeats:NO];
    
    [self addContacts];
}


- (IBAction)_btnAvatarPressed:(UIButton *)sender {
}

#pragma mark - my functions

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

- (void)showAllInformationOfView {
    if (appDelegate._newContact._listPhone.count == 0) {
        PhoneObject *aPhone = [[PhoneObject alloc] init];
        aPhone._isNew = YES;
        aPhone._phoneType = type_phone_mobile;
        aPhone._phoneNumber = @"";
        [appDelegate._newContact._listPhone addObject: aPhone];
    }
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

//  Hiển thị icon done nếu có firstname hoặc lastname
- (void)checkFirstNameAndLastNameForDoneIcon {
    if ([_tfFullName.text isEqualToString: @""]) {
        _iconDone.hidden = YES;
    }else{
        _iconDone.hidden = NO;
    }
}

- (void)showContentWithCurrentLanguage {
    _lbHeader.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey: text_new_contact];
    _tfFullName.placeholder = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_contact_name];
    _tfEmail.placeholder = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_contact_email];
    _tfCloudFoneID.placeholder = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_contact_sipPhone];
    _tfCompany.placeholder = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_contact_company];
    _tfType.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_contact_type];
}

- (void)updateCloudFoneIDForView: (NSString *)sipPhoneID
{
    _sipPhoneID = sipPhoneID;
    if (![_sipPhoneID isEqualToString: @""] && _sipPhoneID != nil) {
        _tfCloudFoneID.text = _sipPhoneID;
    }else{
        _tfCloudFoneID.text = @"";
    }
    appDelegate._newContact._sipPhone = _sipPhoneID;
}

//  Thêm mới contact
- (void)addContacts
{
    // Kiểm tra contact này có tồn tại username và callnexID trùng hay ko. Có thì xử lý
    NSString *strFullName = _tfFullName.text;
    
    NSString *strCompany = _tfCompany.text;
    NSString *fullName = [strFullName lowercaseString];
    
    //  cloudfoneID
    NSString *sipFoneID = _tfCloudFoneID.text;
    appDelegate._newContact._sipPhone = sipFoneID;
    
    //  email
    NSString *strEmail = _tfEmail.text;
    appDelegate._newContact._email = strEmail;
    
    ContactObject *contactExists = [NSDatabase checkContactExistsInDatabase:fullName andCloudFone: _sipPhoneID];
    if (contactExists != nil) {
        NSArray *tmpArr = [[NSArray alloc] initWithArray:appDelegate._newContact._listPhone];
        
        appDelegate._newContact = contactExists;
        for (int iCount=0; iCount<tmpArr.count; iCount++) {
            PhoneObject *phone = [tmpArr objectAtIndex: iCount];
            if (![self checkPhone:phone existsInList:appDelegate._newContact._listPhone]) {
                [appDelegate._newContact._listPhone addObject: phone];
            }
        }
        
        if (![_tfEmail.text isEqualToString: @""]) {
            appDelegate._newContact._email = _tfEmail.text;
        }
        
        if (appDelegate._dataCrop != nil) {
            if ([appDelegate._dataCrop respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
                appDelegate._newContact._avatar = [appDelegate._dataCrop base64EncodedStringWithOptions: 0]; // iOS 7+
            } else {
                appDelegate._newContact._avatar = [appDelegate._dataCrop base64Encoding]; // pre iOS7
            }
        }else{
            appDelegate._newContact._avatar = @"";
        }
        //  Leo Kelvin
        //  [NSDatabase updateContactInformation:[idContactExists intValue] andUpdateInfo:appDelegate._newContact];
        [self afterAddContactSuccessfully];
    }else{
        // Add thêm cloudfone id vào list phone
        if (![_sipPhoneID isEqualToString: @""]) {
            PhoneObject *cloudPhone = [[PhoneObject alloc] init];
            cloudPhone._phoneNumber = _sipPhoneID;
            cloudPhone._phoneType = type_cloudfone_id;
            [appDelegate._newContact._listPhone addObject: cloudPhone];
        }
        
        appDelegate._newContact._firstName = strFullName;
        appDelegate._newContact._lastName = @"";
        appDelegate._newContact._fullName = strFullName;
        appDelegate._newContact._company = strCompany;
        
        NSString *convertName = [AppUtils convertUTF8CharacterToCharacter: strFullName];
        appDelegate._newContact._nameForSearch = [AppUtils getNameForSearchOfConvertName: convertName];
        
        /*  Leo Kelvin
        [appDelegate._newContact set_street: @""];
        [appDelegate._newContact set_city: @""];
        [appDelegate._newContact set_state: @""];
        [appDelegate._newContact set_zip_postal: @""];
        [appDelegate._newContact set_country: @""];
        [appDelegate._newContact set_modify_time: @""];
        [appDelegate._newContact set_modify_int: 0];    */
        
        if (appDelegate._dataCrop != nil) {
            if ([appDelegate._dataCrop respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
                appDelegate._newContact._avatar = [appDelegate._dataCrop base64EncodedStringWithOptions: 0];// iOS 7+
            } else {
                appDelegate._newContact._avatar = [appDelegate._dataCrop base64Encoding];  // pre iOS7
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
        NSMutableArray *tmpListPhone = [[NSMutableArray alloc] init];
        ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        
        for (int iCount=0; iCount<appDelegate._newContact._listPhone.count; iCount++) {
            PhoneObject *aPhone = [appDelegate._newContact._listPhone objectAtIndex: iCount];
            if ([aPhone._phoneType isEqualToString: type_phone_mobile]) {
                ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(aPhone._phoneNumber), kABPersonPhoneMobileLabel, NULL);
                [tmpListPhone addObject: aPhone];
            }else if ([aPhone._phoneType isEqualToString: type_phone_work]){
                ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(aPhone._phoneNumber), kABWorkLabel, NULL);
                [tmpListPhone addObject: aPhone];
            }else if ([aPhone._phoneType isEqualToString: type_phone_fax]){
                ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(aPhone._phoneNumber), kABPersonPhoneHomeFAXLabel, NULL);
                [tmpListPhone addObject: aPhone];
            }else if ([aPhone._phoneType isEqualToString: type_phone_home]){
                ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(aPhone._phoneNumber), kABHomeLabel, NULL);
                [tmpListPhone addObject: aPhone];
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
        
        //  Get contactID của contact mới đc thêm vào
        NSArray *arrayOfAllPeople = (__bridge  NSArray *) ABAddressBookCopyArrayOfAllPeople(addressBook);
        int personCount = (int)[arrayOfAllPeople count];
        ABRecordRef lastPerson = (__bridge ABRecordRef)([arrayOfAllPeople objectAtIndex: personCount-1]);
        lastContactId = ABRecordGetRecordID(lastPerson);
        [appDelegate._newContact set_id_contact: lastContactId];
        
        
        CFRelease(aRecord);
        CFRelease(firstName);
        CFRelease(lastName);
        CFRelease(company);
        CFRelease(email);
        CFRelease(addressBook);
        
        [self afterAddContactSuccessfully];
    }
}

//  Kiem tra so phone hien tai co trong list hay chua
- (BOOL)checkPhone: (PhoneObject *)phone existsInList: (NSArray *)list {
    for (int iCount=0; iCount<list.count; iCount++) {
        PhoneObject *curPhone = [list objectAtIndex: iCount];
        if (phone._isNew == curPhone._isNew && [phone._phoneNumber isEqualToString: curPhone._phoneNumber] && [phone._phoneType isEqualToString: curPhone._phoneType]) {
            return true;
        }
    }
    return false;
}

- (void)afterAddContactSuccessfully
{
    if (![appDelegate._newContact._sipPhone isEqualToString:@""])
    {   // Nếu thêm mới thông thường thì gửi request kết bạn đến
        [self checkIsCloudFoneNumber: appDelegate._newContact._sipPhone];
    }
    
    // Ẩn HUD
    [waitingHUD hide: true];
    
    [[PhoneMainView instance] popCurrentView];
}

//  Kiểm tra có phải số cloudFoneID hay không?
- (void)checkIsCloudFoneNumber: (NSString *)string {
    /*  Leo Kelvin
    BOOL isFriend = [self checkContactIsFriendOnList: string];
    if (!isFriend) {
        NSString *toUser = [NSString stringWithFormat:@"%@@%@", string, xmpp_cloudfone];
        NSString *idRequest = [NSString stringWithFormat:@"requestsent_%@", [MyFunctions randomStringWithLength: 10]];
        BOOL added = [NSDBCallnex addUserToRequestSent:string withIdRequest:idRequest];
        if (added) {
            [appDelegate set_cloudfoneRequestSent: toUser];
            [appDelegate.myBuddy.protocol removeUserFromRosterList:toUser withIdMessage:idRequest];
            
            NSString *profileName = [NSDBCallnex getProfielNameOfAccount:USERNAME];
            [appDelegate.myBuddy.protocol sendRequestUserInfoOf:appDelegate.myBuddy.accountName
                                                         toUser:toUser
                                                    withContent:appDelegate._strRequestFriend
                                                 andDisplayName:profileName];
        }
        
        [self showMessagePopupUp:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_send_request_msg]
                    withTimeShow:1.0 andHide:2.0];
        
        
    }   */
}

//  Kiểm tra cloudfoneID đã kết bạn hay chưa?
- (BOOL)checkContactIsFriendOnList : (NSString *)callnexStr {
    /*  Leo Kelvin
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName contains[cd] %@", callnexStr];
    NSMutableDictionary *listUserDict = [[[OTRProtocolManager sharedInstance] buddyList] allBuddies];
    NSArray *listUser = [OTRBuddyList sortBuddies: listUserDict];
    NSArray *resultArr = [listUser filteredArrayUsingPredicate: predicate];
    if (resultArr.count > 0) {
        return true;
    }else{
        return false;
    }   */
    return FALSE;
}

//  Time out
- (void)saveContactTimeOut{
    [waitingHUD hide: true];
    
    [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_add_contact_failed] duration:2.0 position:CSToastPositionCenter];
}

- (void)saveCloudFoneIDForView: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[NSString class]]) {
        _tfCloudFoneID.text = object;
    }
}

//  Chọn loại phone cho điện thoại
- (void)btnTypePhonePressed: (UIButton *)sender {
    [self.view endEditing: true];
    
    popupTypePhone = [[TypePhonePopupView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-236)/2, (SCREEN_HEIGHT-4*40+6)/2, 236, 4*40+6)];
    popupTypePhone.tag = sender.tag;
    [popupTypePhone showInView:appDelegate.window animated:YES];
}

- (void)updateStateNewForPhoneList {
    for (int iCount=0; iCount<appDelegate._newContact._listPhone.count; iCount++) {
        PhoneObject *aPhone = [appDelegate._newContact._listPhone objectAtIndex: iCount];
        if (iCount == appDelegate._newContact._listPhone.count-1) {
            aPhone._isNew = YES;
        }else{
            aPhone._isNew = NO;
        }
    }
}

//  Thêm hoặc xoá số phone
- (void)btnAddPhonePressed: (UIButton *)sender {
    PhoneObject *aPhone = [appDelegate._newContact._listPhone objectAtIndex: (int)sender.tag];
    if (aPhone._isNew) {
        PhoneObject *aPhone = [[PhoneObject alloc] init];
        aPhone._isNew = YES;
        aPhone._phoneType = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:type_phone_mobile];
        aPhone._phoneNumber = @"";
        [appDelegate._newContact._listPhone addObject: aPhone];
    }else{
        [appDelegate._newContact._listPhone removeObjectAtIndex:(int)sender.tag];
    }
    //  Khi thêm mới hoặc xoá thì chỉ có dòng cuối cùng là new
    [self updateStateNewForPhoneList];
    
    [_tbPhones reloadData];
    
    [self updateAllUIForView];
}

//  Cập nhật vị trí các ui trong view
- (void)updateAllUIForView {
    _tbPhones.frame = CGRectMake(0, _tbPhones.frame.origin.y, _scrollViewContent.frame.size.width, appDelegate._newContact._listPhone.count*hCell);
    _scrollViewContent.contentSize = CGSizeMake(SCREEN_WIDTH, _tbPhones.frame.origin.y+_tbPhones.frame.size.height+15);
}

- (void)whenTextfieldPhoneDidChanged: (UITextField *)textfield {
    int row = (int)[textfield tag];
    
    PhoneObject *curPhone = [appDelegate._newContact._listPhone objectAtIndex: row];
    curPhone._phoneNumber = textfield.text;
}

//  Chọn loại phone
- (void)whenSelectTypeForPhone: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[TypePhoneObject class]]) {
        int curIndex = (int)[popupTypePhone tag];
        PhoneObject *curPhone = [appDelegate._newContact._listPhone objectAtIndex: curIndex];
        curPhone._phoneType = [(TypePhoneObject *)object _strType];
        [_tbPhones reloadData];
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
}

- (void)setupUIForView
{
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
    
    _tfEmail.frame = CGRectMake(_tfType.frame.origin.x, _iconEmail.frame.origin.y, _tfType.frame.size.width, hTextfield);
    _tfEmail.backgroundColor = UIColor.clearColor;
    _tfEmail.keyboardType = UIKeyboardTypeEmailAddress;
    _tfEmail.font = textFont;
    [_tfEmail addTarget:self
                 action:@selector(whenTextfieldDidChanged:)
       forControlEvents:UIControlEventEditingChanged];
    
    //  email
    _tbPhones.frame = CGRectMake(0, _tfEmail.frame.origin.y+_tfEmail.frame.size.height+10, _scrollViewContent.frame.size.width,  hCell);
    _tbPhones.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tbPhones.delegate = self;
    _tbPhones.dataSource = self;
    _tbPhones.scrollEnabled = NO;
    
    _scrollViewContent.contentSize = CGSizeMake(SCREEN_WIDTH, _tbPhones.frame.origin.y+_tbPhones.frame.size.height+15);
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

#pragma mark - UITableview Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _tbPhones) {
        return appDelegate._newContact._listPhone.count;
    }else{
        return listOptions.count;
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
        cell._tfPhone.placeholder = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_phone];
        
        PhoneObject *aPhone = [appDelegate._newContact._listPhone objectAtIndex: indexPath.row];
        cell._tfPhone.text = aPhone._phoneNumber;
        
        if (aPhone._isNew) {
            [cell._iconNewPhone setBackgroundImage:[UIImage imageNamed:@"ic_add_phone.png"]
                                          forState:UIControlStateNormal];
        }else{
            [cell._iconNewPhone setBackgroundImage:[UIImage imageNamed:@"ic_delete_phone.png"]
                                          forState:UIControlStateNormal];
        }
        cell._tfPhone.tag = indexPath.row;
        [cell._tfPhone addTarget:self
                          action:@selector(whenTextfieldPhoneDidChanged:)
                forControlEvents:UIControlEventEditingChanged];
        
        NSString *imgType = [self getTypeOfPhone: aPhone._phoneType];
        
        cell._iconTypePhone.tag = indexPath.row;
        [cell._iconTypePhone setBackgroundImage:[UIImage imageNamed:imgType]
                                       forState:UIControlStateNormal];
        
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
        // set background khi click vào cell
        UIView *selected_bg = [[UIView alloc] init];
        selected_bg.backgroundColor = [UIColor colorWithRed:(223/255.0) green:(255/255.0)
                                                       blue:(133/255.0) alpha:1];
        cell.selectedBackgroundView = selected_bg;
        
        UIView *sepaView = [[UIView alloc] initWithFrame:CGRectMake(0, 39, popupChooseAvatar._optionsTableView.frame.size.width, 1)];
        sepaView.backgroundColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0) blue:(220/255.0) alpha:1.0];
        [cell addSubview: sepaView];
        
        cell.tag = indexPath.row;
        cell.textLabel.font = [AppUtils fontRegularWithSize: 14.0];
        cell.textLabel.textColor = UIColor.grayColor;
        
        SettingItem *curItem = [listOptions objectAtIndex: indexPath.row];
        cell.textLabel.text = curItem._valueStr;
        cell.imageView.image = [UIImage imageNamed: curItem._imageStr];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == popupChooseAvatar._optionsTableView) {
        UITableViewCell *curCell = [tableView cellForRowAtIndexPath: indexPath];
        curCell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        if (curCell.tag == 0) {
            appDelegate.fromImagePicker = YES;
            
            UILabel *testLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, -20, 320, 20)];
            UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
            [pickerController.view addSubview: testLabel];
            
            pickerController.delegate = self;
            [self presentViewController:pickerController animated:YES completion:nil];
        }else if (curCell.tag == 1) {
            // Go to camera
            appDelegate.fromImagePicker = YES;
            
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            [picker setDelegate: self];
            [picker setSourceType: UIImagePickerControllerSourceTypeCamera];
            [self presentViewController:picker animated:YES completion:NULL];
        }else{
            [appDelegate._newContact set_avatar: @""];
            [_imgAvatar setImage:[UIImage imageNamed:@"no_avatar.png"]];
            cropAvatarData = nil;
            [_tbPhones reloadData];
        }
        [popupChooseAvatar fadeOut];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _tbPhones) {
        return hCell;
    }else{
        return 40.0;
    }
}

//  Get icon tương ứng với loại phone
- (NSString *)getTypeOfPhone: (NSString *)typePhone {
    if ([typePhone isEqualToString: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:type_phone_mobile]]) {
        return @"btn_contacts_mobile.png";
    }else if ([typePhone isEqualToString: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:type_phone_work]]){
        return @"btn_contacts_work.png";
    }else if ([typePhone isEqualToString: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:type_phone_fax]]){
        return @"btn_contacts_fax.png";
    }else if ([typePhone isEqualToString: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:type_phone_home]]){
        return @"btn_contacts_home.png";
    }else{
        return @"btn_contacts_mobile.png";
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView: tbTypeContact]) {
        return NO;
    }
    return YES;
}

@end
