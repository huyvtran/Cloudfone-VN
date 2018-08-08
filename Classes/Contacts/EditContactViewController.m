//
//  EditContactViewController.m
//  linphone
//
//  Created by Ei Captain on 4/4/17.
//
//

#import "EditContactViewController.h"
#import "PhoneMainView.h"
#import "TypePhoneObject.h"
#import "NewPhoneCell.h"
#import "MenuCell.h"
#import "SettingItem.h"
#import "ChooseAvatarPopupView.h"
#import "TypePhonePopupView.h"
#import "NSDatabase.h"
#import "NSData+Base64.h"
#import "PhoneObject.h"
#import "ContactDetailObj.h"
#import "PECropViewController.h"

@interface EditContactViewController ()<PECropViewControllerDelegate>
{
    LinphoneAppDelegate *appDelegate;
    float marginX;
    float hTextfield;
    float hCell;
    
    ChooseAvatarPopupView *popupChooseAvatar;
    NSMutableArray *listOptions;
    
    TypePhonePopupView *popupTypePhone;
    YBHud *waitingHud;
    
    UIFont *textFont;
    ContactObject *newContact;
    
    PECropViewController *PECropController;
    UIActionSheet *optionsPopup;
    
    NSArray *listNumber;
}

@end

@implementation EditContactViewController
@synthesize _viewHeader, _iconBack, _lbHeader, _iconDone;
@synthesize _scrollViewContent, _viewInfo, _imgAvatar, _imgChangePicture, _btnAvatar, _tfFullName, _tfCloudFoneID, _tfCompany;
@synthesize _iconType, _tfType, _btnType, _iconEmail, _tfEmail, _tbPhones;
@synthesize detailsContact;

#pragma mark - UICompositeViewDelegate Functions
static UICompositeViewDescription *compositeDescription = nil;
+ (UICompositeViewDescription *)compositeViewDescription {
    if (compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:nil
                                                                 tabBar:nil
                                                               sideMenu:nil
                                                             fullscreen:false
                                                         isLeftFragment:YES
                                                           fragmentWith:nil];
        compositeDescription.darkBackground = true;
    }
    return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
    return self.class.compositeViewDescription;
}

#pragma mark - my controller

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
    
    //  add waiting view
    waitingHud = [[YBHud alloc] initWithHudType:DGActivityIndicatorAnimationTypeLineScale andText:@""];
    waitingHud.tintColor = [UIColor whiteColor];
    waitingHud.dimAmount = 0.5;
    
    appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    if (listNumber == nil) {
        listNumber = [[NSArray alloc] initWithObjects: @"+", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil];
    }
    
    [self showContentWithCurrentLanguage];
    
    [self showContactInformation];
    [_tbPhones reloadData];
    [self updateAllUIForView];
    
    //  notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification object:nil];
    //  Chọn loại điện thoại
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenSelectTypeForPhone:)
                                                 name:selectTypeForPhoneNumber object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)_iconBackClicked:(UIButton *)sender {
    [[PhoneMainView instance] popCurrentView];
}

- (IBAction)_iconDoneClicked:(UIButton *)sender {
    [self.view endEditing: true];
    
    [waitingHud showInView:self.view animated:YES];
    
    [self addNewContactToAddressPhoneBook];
    
    if (![detailsContact._sipPhone isEqualToString:@""]) {
        [self checkIsCloudFoneNumber: detailsContact._sipPhone];
    }else{
        [waitingHud dismissAnimated:YES];
        [[PhoneMainView instance] popCurrentView];
    }
}

- (IBAction)_btnAvatarPressed:(UIButton *)sender {
    [self.view endEditing: YES];
    
    if (appDelegate._dataCrop != nil) {
        [self createDataForPopupAvatarWithExistsAvatar: YES];
    }else{
        if ([self checkExistsValue: detailsContact._avatar]) {
            [self createDataForPopupAvatarWithExistsAvatar: YES];
        }else{
            [self createDataForPopupAvatarWithExistsAvatar: NO];
        }
    }
    
    popupChooseAvatar = [[ChooseAvatarPopupView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-236)/2, (SCREEN_HEIGHT-listOptions.count*hCell+6)/2, 236, listOptions.count*hCell+6)];
    popupChooseAvatar._listOptions = listOptions;
    popupChooseAvatar._optionsTableView.delegate = self;
    popupChooseAvatar._optionsTableView.dataSource = self;
    [popupChooseAvatar._optionsTableView reloadData];
    [popupChooseAvatar showInView:appDelegate.window animated:YES];
}

#pragma mark - my functions

- (void)setContactDetailsInformation: (ContactObject *)contactInfo {
    if (detailsContact == nil) {
        detailsContact = [[ContactObject alloc] init];
    }
    detailsContact = contactInfo;
    if (detailsContact._listPhone == nil) {
        detailsContact._listPhone = [[NSMutableArray alloc] init];
    }
}

- (void)processPhoneNumberForAddExist: (NSString *)phoneNumber {
    if (![detailsContact._sipPhone isEqualToString:@""]) {
        ContactDetailObj *aPhone = [[ContactDetailObj alloc] init];
        aPhone._iconStr = @"btn_contacts_mobile.png";
        aPhone._titleStr = [appDelegate.localization localizedStringForKey:type_phone_mobile];
        aPhone._valueStr = phoneNumber;
        aPhone._buttonStr = @"contact_detail_icon_call.png";
        aPhone._typePhone = type_phone_mobile;
        
        [detailsContact._listPhone addObject: aPhone];
    }else{
        if ([phoneNumber hasPrefix:@"778899"]) {
            detailsContact._sipPhone = phoneNumber;
        }else{
            ContactDetailObj *aPhone = [[ContactDetailObj alloc] init];
            aPhone._iconStr = @"btn_contacts_mobile.png";
            aPhone._titleStr = [appDelegate.localization localizedStringForKey:type_phone_mobile];
            aPhone._valueStr = phoneNumber;
            aPhone._buttonStr = @"contact_detail_icon_call.png";
            aPhone._typePhone = type_phone_mobile;
            
            [detailsContact._listPhone addObject: aPhone];
        }
    }
}

- (void)addNewContactToAddressPhoneBook
{
    ABAddressBookRef addressBook;
    CFErrorRef anError = NULL;
    addressBook = ABAddressBookCreateWithOptions(nil, &anError);
    
    ABRecordRef aRecord = ABAddressBookGetPersonWithRecordID(addressBook, detailsContact._id_contact);
    
    // Lưu thông tin
    ABRecordSetValue(aRecord, kABPersonFirstNameProperty, (__bridge CFTypeRef)(detailsContact._fullName), &anError);
    ABRecordSetValue(aRecord, kABPersonLastNameProperty, (__bridge CFTypeRef)(detailsContact._lastName), &anError);
    ABRecordSetValue(aRecord, kABPersonOrganizationProperty, (__bridge CFTypeRef)(detailsContact._company), &anError);
    ABRecordSetValue(aRecord, kABPersonFirstNamePhoneticProperty, (__bridge CFTypeRef)(detailsContact._sipPhone), &anError);
    
    if (detailsContact._email != nil) {
        ABMutableMultiValueRef email = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(email, (__bridge CFTypeRef)(detailsContact._email), CFSTR("email"), NULL);
        ABRecordSetValue(aRecord, kABPersonEmailProperty, email, &anError);
    }
    
    if (appDelegate._dataCrop != nil) {
        CFDataRef cfdata = CFDataCreate(NULL,[appDelegate._dataCrop bytes], [appDelegate._dataCrop length]);
        ABPersonSetImageData(aRecord, cfdata, &anError);
    }
    
    // Phone number
    NSMutableArray *listPhone = [[NSMutableArray alloc] init];
    ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    
    for (int iCount=0; iCount<detailsContact._listPhone.count; iCount++) {
        ContactDetailObj *aPhone = [detailsContact._listPhone objectAtIndex: iCount];
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
        }
    }
    ABRecordSetValue(aRecord, kABPersonPhoneProperty, multiPhone,nil);
    CFRelease(multiPhone);
    
    // Instant Message
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"SIP", (NSString*)kABPersonInstantMessageServiceKey,
                                detailsContact._sipPhone, (NSString*)kABPersonInstantMessageUsernameKey, nil];
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
    
    anError = nil;
    BOOL isAdded = ABAddressBookAddRecord (addressBook,aRecord,&anError);
    
    if(isAdded){
        NSLog(@"added..");
    }
    if (anError != NULL) {
        NSLog(@"ABAddressBookAddRecord %@", anError);
    }
    anError = NULL;
    
    BOOL isSaved = ABAddressBookSave (addressBook,&anError);
    if(isSaved){
        NSLog(@"saved..");
    }
    
    if (anError != NULL) {
        NSLog(@"ABAddressBookSave %@", anError);
    }
    
    [self addNewContactToList: aRecord];
}

- (void)addNewContactToList: (ABRecordRef)aPerson
{
    ContactObject *aContact = [[ContactObject alloc] init];
    aContact.person = aPerson;
    aContact._id_contact = detailsContact._id_contact;
    aContact._fullName = [AppUtils getNameOfContact: aPerson];
    
    if (![aContact._fullName isEqualToString:@""]) {
        NSString *convertName = [AppUtils convertUTF8CharacterToCharacter: aContact._fullName];
        aContact._nameForSearch = [AppUtils getNameForSearchOfConvertName: convertName];
    }
    
    aContact._sipPhone = detailsContact._sipPhone;
    aContact._avatar = detailsContact._avatar;
    aContact._listPhone = [self getListPhoneOfContactPerson: aPerson withName: aContact._fullName];
    
    //  Xoa contact ra khoi db neu co
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_id_contact = %d", detailsContact._id_contact];
    NSArray *filter = [appDelegate.listContacts filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        [appDelegate.listContacts removeObjectsInArray: filter];
    }
    [appDelegate.listContacts addObject: aContact];
    
    //  remove ra khoi contact sip
    if (![aContact._sipPhone isEqualToString: @""] && [aContact._sipPhone hasPrefix:@"778899"]) {
        filter = [appDelegate.sipContacts filteredArrayUsingPredicate: predicate];
        if (filter.count > 0) {
            [appDelegate.sipContacts removeObjectsInArray: filter];
        }
        [appDelegate.sipContacts addObject: aContact];
    }
}

- (void)showContentWithCurrentLanguage {
    _lbHeader.text = [appDelegate.localization localizedStringForKey:text_edit_contact];
    _tfFullName.placeholder = [appDelegate.localization localizedStringForKey:text_contact_name];
    _tfCloudFoneID.placeholder = [appDelegate.localization localizedStringForKey:text_contact_cloudfoneId];
    _tfCompany.placeholder = [appDelegate.localization localizedStringForKey:text_contact_company];
    _tfEmail.placeholder = [appDelegate.localization localizedStringForKey:text_contact_email];
}

- (void)showPopupFinish {
    [[PhoneMainView instance] popCurrentView];
}

//  Kiểm tra cloudfoneID đã kết bạn hay chưa?
- (BOOL)checkContactIsFriendOnList : (NSString *)cloudfoneID {
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
        PhoneObject *curPhone = [detailsContact._listPhone objectAtIndex: curIndex];
        curPhone._phoneType = [(TypePhoneObject *)object _strType];
        [_tbPhones reloadData];
    }
}

- (BOOL)checkExistsValue: (NSString *)string {
    if (![string isEqualToString:@""] && string != nil && ![string isEqualToString:@"null"] && ![string isEqualToString:@"(null)"] && ![string isEqualToString:@"<null>"]) {
        return true;
    }else{
        return false;
    }
}

//  Hiển thị thông tin của contact
- (void)showContactInformation
{
    if (detailsContact._listPhone == nil) {
        detailsContact._listPhone = [[NSMutableArray alloc] init];
    }
    
    if(detailsContact._fullName != nil){
        _tfFullName.text = detailsContact._fullName;
    }else{
        _tfFullName.text = @"";
    }
    
    if ([self checkExistsValue: detailsContact._company]) {
        _tfCompany.text = detailsContact._company;
    }else{
        _tfCompany.text = @"";
    }
    
    //  Avatar contact
    if (appDelegate._dataCrop != nil) {
        _imgAvatar.image = [UIImage imageWithData: appDelegate._dataCrop];
    }else{
        if ([self checkExistsValue: detailsContact._avatar]) {
            _imgAvatar.image = [UIImage imageWithData: [NSData dataFromBase64String: detailsContact._avatar]];
        }else{
            _imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
        }
    }
    
    if ([self checkExistsValue: detailsContact._sipPhone]) {
        _tfCloudFoneID.text = detailsContact._sipPhone;
    }else{
        _tfCloudFoneID.text = @"";
    }
    
    if (detailsContact._type == 0) {
        _tfType.text = [appDelegate.localization localizedStringForKey:TEXT_TYPE_INDIVIDUAL];
    }else if (detailsContact._type == 1){
        _tfType.text = [appDelegate.localization localizedStringForKey:TEXT_TYPE_COMPANY];
    }else{
        _tfType.text = [appDelegate.localization localizedStringForKey:text_contact_type];
    }
    
    if ([self checkExistsValue: detailsContact._email]) {
        _tfEmail.text = detailsContact._email;
    }else{
        _tfEmail.text = @"";
    }
}

//  Chọn loại phone cho điện thoại
- (void)btnTypePhonePressed: (UIButton *)sender {
    [self.view endEditing: true];
    
    popupTypePhone = [[TypePhonePopupView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-236)/2, (SCREEN_HEIGHT-4*40+6)/2, 236, 4*40+6)];
    popupTypePhone.tag = sender.tag;
    [popupTypePhone showInView:appDelegate.window animated:YES];
}

//  Thêm hoặc xoá số phone
- (void)btnAddPhonePressed: (UIButton *)sender {
    int tag = (int)[sender tag];
    if (tag < detailsContact._listPhone.count) {
        [detailsContact._listPhone removeObjectAtIndex: tag];
    }else{
        NewPhoneCell *cell = [_tbPhones cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tag inSection:0]];
        if (![cell._tfPhone.text isEqualToString:@""]) {
            ContactDetailObj *aPhone = [[ContactDetailObj alloc] init];
            aPhone._iconStr = @"btn_contacts_mobile.png";
            aPhone._titleStr = [appDelegate.localization localizedStringForKey:type_phone_mobile];
            aPhone._valueStr = cell._tfPhone.text;
            aPhone._buttonStr = @"contact_detail_icon_call.png";
            aPhone._typePhone = type_phone_mobile;
            [detailsContact._listPhone addObject: aPhone];
        }else{
            [self.view makeToast:[appDelegate.localization localizedStringForKey:please_input_phone_number]
                        duration:2.0 position:CSToastPositionCenter];
        }
    }
    
    //  Khi thêm mới hoặc xoá thì chỉ có dòng cuối cùng là new
    //  [self updateStateNewForPhoneList];
    
    [_tbPhones reloadData];
    
    [self updateAllUIForView];
}

//  Cập nhật vị trí các ui trong view
- (void)updateAllUIForView {
    _tbPhones.frame = CGRectMake(0, _tfEmail.frame.origin.y+_tfEmail.frame.size.height+10, _scrollViewContent.frame.size.width, (detailsContact._listPhone.count+1)*hCell);
    _scrollViewContent.contentSize = CGSizeMake(SCREEN_WIDTH, _tbPhones.frame.origin.y+_tbPhones.frame.size.height+15);
}

- (void)updateStateNewForPhoneList {
    for (int iCount=0; iCount<detailsContact._listPhone.count; iCount++) {
        PhoneObject *aPhone = [detailsContact._listPhone objectAtIndex: iCount];
        if (iCount == detailsContact._listPhone.count-1) {
            [aPhone set_isNew: true];
        }else{
            [aPhone set_isNew: false];
        }
    }
}

- (void)whenTextfieldPhoneDidChanged: (UITextField *)textfield {
    int row = (int)[textfield tag];
    if (row < detailsContact._listPhone.count) {
        ContactDetailObj *curPhone = [detailsContact._listPhone objectAtIndex: row];
        [curPhone set_valueStr: textfield.text];
    }
}

//  Get icon tương ứng với loại phone
- (NSString *)getTypeOfPhone: (NSString *)typePhone {
    if ([typePhone isEqualToString: [appDelegate.localization localizedStringForKey:type_phone_mobile]]) {
        return @"btn_contacts_mobile.png";
    }else if ([typePhone isEqualToString: [appDelegate.localization localizedStringForKey:type_phone_work]]){
        return @"btn_contacts_work.png";
    }else if ([typePhone isEqualToString: [appDelegate.localization localizedStringForKey:type_phone_fax]]){
        return @"btn_contacts_fax.png";
    }else if ([typePhone isEqualToString: [appDelegate.localization localizedStringForKey:type_phone_home]]){
        return @"btn_contacts_home.png";
    }else{
        return @"btn_contacts_mobile.png";
    }
}


//  Hiển thị bàn phím
- (void)keyboardDidShow: (NSNotification *) notif{
    CGSize keyboardSize = [[[notif userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.05 animations:^{
        [_scrollViewContent setFrame: CGRectMake(0, _viewHeader.frame.origin.y+_viewHeader.frame.size.height, _scrollViewContent.frame.size.width, SCREEN_HEIGHT-(appDelegate._hStatus+appDelegate._hHeader+keyboardSize.height))];
    }];
}

//  Ẩn bàn phím
- (void)keyboardDidHide: (NSNotification *) notif{
    [UIView animateWithDuration:0.05 animations:^{
        [_scrollViewContent setFrame: CGRectMake(0, _viewHeader.frame.origin.y+_viewHeader.frame.size.height, _scrollViewContent.frame.size.width, SCREEN_HEIGHT-(appDelegate._hStatus+appDelegate._hHeader))];
    }];
}

- (void)setupUIForView {
    //  Tap vào màn hình để đóng bàn phím
    float wAvatar;
    
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:HelveticaNeue size:18.0];
        hTextfield = 35.0;
        wAvatar = 80.0;
    }else{
        textFont = [UIFont fontWithName:HelveticaNeue size:16.0];
        hTextfield = 30.0;
        wAvatar = 75.0;
    }
    
    UITapGestureRecognizer *tapOnScreen = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTapOnMainScreen)];
    [self.view setUserInteractionEnabled: true];
    [self.view addGestureRecognizer: tapOnScreen];
    
    marginX = 10.0;
    
    hCell = hTextfield + 10;
    
    //  view header
    [_viewHeader setFrame: CGRectMake(0, 0, SCREEN_WIDTH, appDelegate._hHeader)];
    [_iconBack setFrame: CGRectMake(0, (appDelegate._hHeader-40.0)/2, 40.0, 40.0)];
    [_iconBack setBackgroundImage:[UIImage imageNamed:@"ic_back_act.png"]
                         forState:UIControlStateHighlighted];
    
    [_iconDone setFrame: CGRectMake(_viewHeader.frame.size.width-appDelegate._hHeader, _iconBack.frame.origin.y, _iconBack.frame.size.width, _iconBack.frame.size.height)];
    [_iconDone setBackgroundImage:[UIImage imageNamed:@"ic_done_act.png"]
                         forState:UIControlStateHighlighted];
    
    [_lbHeader setFrame: CGRectMake(_iconBack.frame.origin.x+_iconBack.frame.size.width+5, 0, (_viewHeader.frame.size.width-2*_iconBack.frame.size.width-10), appDelegate._hHeader)];
    
    //  scroll view content
    [_scrollViewContent setFrame: CGRectMake(0, _viewHeader.frame.origin.y+_viewHeader.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT-appDelegate._hHeader-appDelegate._hStatus)];
    
    //  view info
    float hInfo = 7 + hTextfield + 7 + hTextfield + 7 + hTextfield + 7;
    
    [_viewInfo setFrame: CGRectMake(0, 0, _scrollViewContent.frame.size.width, hInfo)];
    
    [_imgAvatar setFrame: CGRectMake((hInfo-wAvatar)/2, (hInfo-wAvatar)/2, wAvatar, wAvatar)];
    [_imgAvatar setImage:[UIImage imageNamed:@"no_avatar.png"]];
    [_imgAvatar.layer setCornerRadius: wAvatar/2];
    [_imgAvatar setClipsToBounds: true];
    
    [_imgChangePicture setFrame: CGRectMake(_imgAvatar.frame.origin.x+(_imgAvatar.frame.size.width-25)/2, _imgAvatar.frame.origin.y+_imgAvatar.frame.size.height-25-5, 25, 25)];
    
    [_btnAvatar setFrame: _imgAvatar.frame];
    
    [_tfFullName setFrame: CGRectMake(_imgAvatar.frame.origin.x+_imgAvatar.frame.size.width+7, 7, _scrollViewContent.frame.size.width-(2*_imgAvatar.frame.origin.x+_imgAvatar.frame.size.width+7), hTextfield)];
    [_tfFullName setBackgroundColor:[UIColor clearColor]];
    [_tfFullName setFont: textFont];
    [_tfFullName addTarget:self
                     action:@selector(whenTextfieldDidChanged:)
           forControlEvents:UIControlEventEditingChanged];
    
    //  CloudfoneID
    [_tfCloudFoneID setFrame: CGRectMake(_tfFullName.frame.origin.x, _tfFullName.frame.origin.y+_tfFullName.frame.size.height+7, _tfFullName.frame.size.width, _tfFullName.frame.size.height)];
    [_tfCloudFoneID setBackgroundColor:[UIColor clearColor]];
    
    [_tfCloudFoneID setFont: textFont];
    [_tfCloudFoneID setKeyboardType: UIKeyboardTypeNumberPad];
    
    //  company
    [_tfCompany setFrame: CGRectMake(_tfCloudFoneID.frame.origin.x, _tfCloudFoneID.frame.origin.y+_tfCloudFoneID.frame.size.height+7, _tfCloudFoneID.frame.size.width, _tfCloudFoneID.frame.size.height)];
    [_tfCompany setBackgroundColor:[UIColor clearColor]];
    
    [_tfCompany setFont: textFont];
    [_tfCompany addTarget:self
                   action:@selector(whenTextfieldDidChanged:)
         forControlEvents:UIControlEventEditingChanged];
    
    //  type contact
    [_iconType setFrame: CGRectMake(marginX, _viewInfo.frame.origin.y+_viewInfo.frame.size.height+10, hTextfield, hTextfield)];
    [_tfType setFrame: CGRectMake(_iconType.frame.origin.x+_iconType.frame.size.width+marginX, _iconType.frame.origin.y, _scrollViewContent.frame.size.width-(_iconType.frame.origin.x+_iconType.frame.size.width+marginX+marginX), hTextfield)];
    [_tfType setEnabled: false];
    [_tfType setFont: textFont];
    
    [_btnType setFrame: _tfType.frame];
    
    //  email
    [_iconEmail setFrame: CGRectMake(_iconType.frame.origin.x, _iconType.frame.origin.y+_iconType.frame.size.height+10, _iconType.frame.size.width, _iconType.frame.size.height)];
    [_tfEmail setFrame: CGRectMake(_tfType.frame.origin.x, _iconEmail.frame.origin.y, _tfType.frame.size.width, hTextfield)];
    [_tfEmail setBackgroundColor:[UIColor clearColor]];
    [_tfEmail setKeyboardType:UIKeyboardTypeEmailAddress];
    
    [_tfEmail setFont: textFont];
    [_tfEmail addTarget:self
                 action:@selector(whenTextfieldDidChanged:)
       forControlEvents:UIControlEventEditingChanged];
    
    //  phone
    [_tbPhones setFrame: CGRectMake(0, _tfEmail.frame.origin.y+_tfEmail.frame.size.height+10, _scrollViewContent.frame.size.width, hCell)];
    [_tbPhones setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tbPhones setDelegate: self];
    [_tbPhones setDataSource: self];
    [_tbPhones setScrollEnabled: false];
    
    
    [_tfCompany setFont: textFont];
    [_tfCloudFoneID setFont: textFont];
    [_tfEmail setFont: textFont];
    
    [_scrollViewContent setContentSize: CGSizeMake(SCREEN_WIDTH, _tbPhones.frame.origin.y+_tbPhones.frame.size.height+15)];
}

//  Tao du lieu cho popup change avatar
- (void)createDataForPopupAvatarWithExistsAvatar: (BOOL)isExists {
    if (listOptions == nil) {
        listOptions = [[NSMutableArray alloc] init];
    }
    [listOptions removeAllObjects];
    
    SettingItem *itemGallery = [[SettingItem alloc] init];
    itemGallery._imageStr = @"gallery.png";
    itemGallery._valueStr = [appDelegate.localization localizedStringForKey:text_gallery];
    [listOptions addObject: itemGallery];
    
    SettingItem *itemCamera = [[SettingItem alloc] init];
    itemCamera._imageStr = @"camera.png";
    itemCamera._valueStr = [appDelegate.localization localizedStringForKey:text_camera];
    [listOptions addObject: itemCamera];
    
    if (isExists) {
        SettingItem *itemRemove = [[SettingItem alloc] init];
        itemRemove._imageStr = @"delete_conversation.png";
        itemRemove._valueStr = [appDelegate.localization localizedStringForKey:text_remove];
        [listOptions addObject: itemRemove];
    }
}

- (void)whenTextfieldDidChanged: (UITextField *)textfield {
    if (textfield == _tfFullName) {
        if ([_tfFullName.text isEqualToString: @""]) {
            [_iconDone setHidden: true];
        }else{
            [_iconDone setHidden: false];
        }
        //  Lưu giá trị first name
        [detailsContact set_fullName: _tfFullName.text];
    }if (textfield == _tfCompany) {
        //  Lưu giá trị company
        [detailsContact set_company: _tfCompany.text];
    }else if (textfield == _tfEmail){
        //  Lưu giá trị email
        [detailsContact set_email: _tfEmail.text];
    }
}

//  Tap vào màn hình chính để đóng bàn phím
- (void)whenTapOnMainScreen {
    [self.view endEditing: true];
}

- (NSMutableArray *)getListPhoneOfContactPerson: (ABRecordRef)aPerson withName: (NSString *)contactName
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
            if (phoneNumber != nil) {
                int idOfContact = ABRecordGetRecordID(aPerson);
                phoneNumber = [self removeAllSpecialInString:phoneNumber];
                
                [appDelegate._allPhonesDict setObject:[NSString stringWithFormat:@"%@|%@|%@", contactName, [AppUtils getNameForSearchOfConvertName:contactName], phoneNumber] forKey:phoneNumber];
                [appDelegate._allIDDict setObject:[NSString stringWithFormat:@"%d", idOfContact] forKey:phoneNumber];
            }
            
            strPhone = @"";
            if (locLabel == nil) {
                ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                anItem._iconStr = @"btn_contacts_home.png";
                anItem._titleStr = [appDelegate.localization localizedStringForKey:text_phone_home];
                anItem._valueStr = phoneNumber;
                anItem._buttonStr = @"contact_detail_icon_call.png";
                anItem._typePhone = type_phone_home;
                [result addObject: anItem];
            }else{
                if (CFStringCompare(locLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_home.png";
                    anItem._titleStr = [appDelegate.localization localizedStringForKey:text_phone_home];
                    anItem._valueStr = phoneNumber;
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_home;
                    [result addObject: anItem];
                }else if (CFStringCompare(locLabel, kABWorkLabel, 0) == kCFCompareEqualTo)
                {
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_work.png";
                    anItem._titleStr = [appDelegate.localization localizedStringForKey:text_phone_work];
                    anItem._valueStr = phoneNumber;
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_work;
                    [result addObject: anItem];
                }else if (CFStringCompare(locLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo)
                {
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_mobile.png";
                    anItem._titleStr = [appDelegate.localization localizedStringForKey:text_phone_mobile];
                    anItem._valueStr = phoneNumber;
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_mobile;
                    [result addObject: anItem];
                }else if (CFStringCompare(locLabel, kABPersonPhoneHomeFAXLabel, 0) == kCFCompareEqualTo)
                {
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_fax.png";
                    anItem._titleStr = [appDelegate.localization localizedStringForKey:text_phone_fax];
                    anItem._valueStr = phoneNumber;
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_fax;
                    [result addObject: anItem];
                }else if (CFStringCompare(locLabel, kABOtherLabel, 0) == kCFCompareEqualTo)
                {
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_fax.png";
                    anItem._titleStr = [appDelegate.localization localizedStringForKey:text_phone_other];
                    anItem._valueStr = phoneNumber;
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_other;
                    [result addObject: anItem];
                }else{
                    ContactDetailObj *anItem = [[ContactDetailObj alloc] init];
                    anItem._iconStr = @"btn_contacts_mobile.png";
                    anItem._titleStr = [appDelegate.localization localizedStringForKey:text_phone_mobile];
                    anItem._valueStr = phoneNumber;
                    anItem._buttonStr = @"contact_detail_icon_call.png";
                    anItem._typePhone = type_phone_mobile;
                    [result addObject: anItem];
                }
            }
        }
    }
    return result;
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
        
        [self showResultPopupFinish];
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
            [self.view makeToast:[appDelegate.localization localizedStringForKey:text_send_request_msg]
                        duration:1.5 position:CSToastPositionCenter];
            
            [NSTimer scheduledTimerWithTimeInterval:1.5 target:self
                                           selector:@selector(showResultPopupFinish)
                                           userInfo:nil repeats:false];
        }else{
            [self showResultPopupFinish];
        }
    }
}

- (void)showResultPopupFinish {
    [waitingHud dismissAnimated:YES];
    
    [[PhoneMainView instance] popCurrentView];
}

//  Hàm loại bỏ tất cả các ký tự ko là số ra khỏi chuỗi
- (NSString *)removeAllSpecialInString: (NSString *)phoneString {
    
    NSString *resultStr = @"";
    for (int strCount=0; strCount<phoneString.length; strCount++) {
        char characterChar = [phoneString characterAtIndex: strCount];
        NSString *characterStr = [NSString stringWithFormat:@"%c", characterChar];
        if ([listNumber containsObject: characterStr]) {
            resultStr = [NSString stringWithFormat:@"%@%@", resultStr, characterStr];
        }
    }
    return resultStr;
}

#pragma mark - Picker image

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    // Crop image trong edits contact
    appDelegate._chooseMyAvatar = NO;
    
    appDelegate._cropAvatar = image;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self openEditor];
    }];
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

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    //  [lbStatusBg setBackgroundColor:[UIColor blackColor]];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITableview Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _tbPhones) {
        return [detailsContact._listPhone count] + 1;
    }else{
        return [listOptions count];
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
        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
        [cell setFrame: CGRectMake(cell.frame.origin.x, cell.frame.origin.y, _tbPhones.frame.size.width, hCell)];
        [cell setupUIForCell];
        
        [cell._tfPhone setPlaceholder: [appDelegate.localization localizedStringForKey:text_phone]];
        
        if (indexPath.row == detailsContact._listPhone.count) {
            [cell._tfPhone setText:@""];
            
            [cell._iconNewPhone setBackgroundImage:[UIImage imageNamed:@"ic_add_phone.png"]
                                          forState:UIControlStateNormal];
            [cell._iconTypePhone setBackgroundImage:[UIImage imageNamed:@"btn_contacts_mobile"]
                                           forState:UIControlStateNormal];
        }else{
            ContactDetailObj *aPhone = [detailsContact._listPhone objectAtIndex: indexPath.row];
            [cell._tfPhone setText: aPhone._valueStr];
            
            [cell._iconNewPhone setBackgroundImage:[UIImage imageNamed:@"ic_delete_phone.png"]
                                          forState:UIControlStateNormal];
            NSString *imgType = aPhone._iconStr;
            [cell._iconTypePhone setTag: indexPath.row];
            [cell._iconTypePhone setBackgroundImage:[UIImage imageNamed:imgType]
                                           forState:UIControlStateNormal];
        }
        
        [cell._tfPhone setTag: indexPath.row];
        [cell._tfPhone addTarget:self
                          action:@selector(whenTextfieldPhoneDidChanged:)
                forControlEvents:UIControlEventEditingChanged];
        
        [cell._iconNewPhone setTag: indexPath.row];
        [cell._iconNewPhone addTarget:self
                               action:@selector(btnAddPhonePressed:)
                     forControlEvents:UIControlEventTouchUpInside];
        
        [cell._iconTypePhone addTarget:self
                                action:@selector(btnTypePhonePressed:)
                      forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }else{
        static NSString *identifier = @"MenuCell";
        MenuCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MenuCell" owner:self options:nil];
            cell = topLevelObjects[0];
        }
        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
        [cell setFrame: CGRectMake(cell.frame.origin.x, cell.frame.origin.y, popupChooseAvatar._optionsTableView.frame.size.width, hCell)];
        [cell setupCellForPopupView];
        
        [cell setTag: indexPath.row];
        
        SettingItem *curItem = [listOptions objectAtIndex: indexPath.row];
        cell._lbTitle.text = curItem._valueStr;
        [cell._iconImage setImage:[UIImage imageNamed: curItem._imageStr]];
        
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
            //  [newContact set_avatar: @""];
            [_imgAvatar setImage:[UIImage imageNamed:@"no_avatar.png"]];
            appDelegate._dataCrop = nil;
            [_tbPhones reloadData];
        }
        [popupChooseAvatar fadeOut];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return hCell;
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

@end
