//
//  EditContactViewController.m
//  linphone
//
//  Created by Ei Captain on 4/4/17.
//
//

#import "EditContactViewController.h"
#import "TypePhoneObject.h"
#import "NewPhoneCell.h"
#import "InfoForNewContactTableCell.h"
#import "MenuCell.h"
#import "SettingItem.h"
#import "ChooseAvatarPopupView.h"
#import "NSDatabase.h"
#import "NSData+Base64.h"
#import "PhoneObject.h"
#import "ContactDetailObj.h"
#import "PECropViewController.h"

#define ROW_CONTACT_NAME    0
#define ROW_CONTACT_EMAIL   1
#define ROW_CONTACT_COMPANY 2
#define NUMBER_ROW_BEFORE   3

@interface EditContactViewController ()<PECropViewControllerDelegate>
{
    LinphoneAppDelegate *appDelegate;
    
    ChooseAvatarPopupView *popupChooseAvatar;
    NSMutableArray *listOptions;
    
    YBHud *waitingHud;
    
    ContactObject *newContact;
    
    PECropViewController *PECropController;
    UIActionSheet *optionsPopup;
    
    NSArray *listNumber;
    
    UIView *viewFooter;
    UIButton *btnCancel;
    UIButton *btnSave;
}

@end

@implementation EditContactViewController
@synthesize _viewHeader, bgHeader, _iconBack, _lbHeader, _iconDone, tbContents, _imgAvatar, _imgChangePicture, _btnAvatar;
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
    
    [tbContents reloadData];
    if ([detailsContact._fullName isEqualToString:@""] || detailsContact._fullName == nil) {
        [self enableForSaveButton: NO];
    }else{
        [self enableForSaveButton: YES];
    }
    
    //  notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification object:nil];
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
    
    [waitingHud dismissAnimated:YES];
    [[PhoneMainView instance] popCurrentView];
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
    
    popupChooseAvatar = [[ChooseAvatarPopupView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-236)/2, (SCREEN_HEIGHT-listOptions.count*50.0+6)/2, 236, listOptions.count*50.0+6)];
    popupChooseAvatar._listOptions = listOptions;
    popupChooseAvatar._optionsTableView.delegate = self;
    popupChooseAvatar._optionsTableView.dataSource = self;
    [popupChooseAvatar._optionsTableView reloadData];
    [popupChooseAvatar showInView:appDelegate.window animated:YES];
}

#pragma mark - my functions

- (void)whenTextfieldFullnameChanged: (UITextField *)textfield {
    //  Save fullname into first name
    detailsContact._fullName = textfield.text;
    
    if (![textfield.text isEqualToString:@""]) {
        [self enableForSaveButton: YES];
    }else{
        [self enableForSaveButton: NO];
    }
}

- (void)whenTextfieldChanged: (UITextField *)textfield {
    if (textfield.tag == 100) {
        detailsContact._email = textfield.text;
    }else if (textfield.tag == 101){
        detailsContact._company = textfield.text;
    }
}

- (void)enableForSaveButton: (BOOL)enable {
    btnSave.enabled = enable;
    if (enable) {
        btnSave.backgroundColor = [UIColor colorWithRed:(20/255.0) green:(129/255.0)
                                                   blue:(211/255.0) alpha:1.0];
    }else{
        btnSave.backgroundColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                   blue:(200/255.0) alpha:1.0];
    }
}

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
}

- (void)showContentWithCurrentLanguage {
    _lbHeader.text = [appDelegate.localization localizedStringForKey:@"Edit contact"];
    [btnCancel setTitle:[appDelegate.localization localizedStringForKey:@"Cancel"]
               forState:UIControlStateNormal];
    [btnSave setTitle:[appDelegate.localization localizedStringForKey:@"Save"]
             forState:UIControlStateNormal];
}

- (void)showPopupFinish {
    [[PhoneMainView instance] popCurrentView];
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
}

//  Chọn loại phone cho điện thoại
- (void)btnTypePhonePressed: (UIButton *)sender {
    [self.view endEditing: true];
    
}

//  Thêm hoặc xoá số phone
- (void)btnAddPhonePressed: (UIButton *)sender {
    int tag = (int)[sender tag];
    if (tag - NUMBER_ROW_BEFORE >= 0) {
        if ([sender.currentTitle isEqualToString:@"Add"])
        {
            NewPhoneCell *cell = [tbContents cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tag inSection:0]];
            if (cell != nil && ![cell._tfPhone.text isEqualToString:@""]) {
                ContactDetailObj *aPhone = [[ContactDetailObj alloc] init];
                aPhone._iconStr = @"btn_contacts_mobile.png";
                aPhone._titleStr = [appDelegate.localization localizedStringForKey:type_phone_mobile];
                aPhone._valueStr = cell._tfPhone.text;
                aPhone._buttonStr = @"contact_detail_icon_call.png";
                aPhone._typePhone = type_phone_mobile;
                [detailsContact._listPhone addObject: aPhone];
            }else{
                [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Please input phone number"]
                            duration:2.0 position:CSToastPositionCenter];
            }
        }else if ([sender.currentTitle isEqualToString:@"Remove"]){
            if (tag-NUMBER_ROW_BEFORE < appDelegate._newContact._listPhone.count) {
                [appDelegate._newContact._listPhone removeObjectAtIndex: tag-NUMBER_ROW_BEFORE];
            }
        }
    }
    
    //  Khi thêm mới hoặc xoá thì chỉ có dòng cuối cùng là new
    [tbContents reloadData];
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

//  Hiển thị bàn phím
- (void)keyboardDidShow: (NSNotification *) notif{
    CGSize keyboardSize = [[[notif userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [tbContents mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-keyboardSize.height);
    }];
}

//  Ẩn bàn phím
- (void)keyboardDidHide: (NSNotification *) notif{
    [tbContents mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
    }];
}

- (void)setupUIForView {
    //  Tap vào màn hình để đóng bàn phím
    float wAvatar = 110.0;
    
    if (SCREEN_WIDTH > 320) {
        _lbHeader.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:20.0];
    }else{
        _lbHeader.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }
    
    UITapGestureRecognizer *tapOnScreen = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTapOnMainScreen)];
    [self.view setUserInteractionEnabled: true];
    [self.view addGestureRecognizer: tapOnScreen];
    
    //  view header
    [_viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(appDelegate._hRegistrationState + 60.0);
    }];
    
    [bgHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(_viewHeader);
    }];
    
    [_lbHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader).offset(appDelegate._hStatus);
        make.centerX.equalTo(_viewHeader.mas_centerX);
        make.width.mas_equalTo(200.0);
        make.height.mas_equalTo(44.0);
    }];
    
    [_iconBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewHeader);
        make.centerY.equalTo(_lbHeader.mas_centerY);
        make.width.height.mas_equalTo(35.0);
    }];
    
    [_iconDone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_viewHeader);
        make.centerY.equalTo(_lbHeader.mas_centerY);
        make.width.height.mas_equalTo(35.0);
    }];
    
    _imgAvatar.layer.borderColor = UIColor.whiteColor.CGColor;
    _imgAvatar.layer.borderWidth = 2.0;
    _imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
    _imgAvatar.layer.cornerRadius = wAvatar/2;
    _imgAvatar.clipsToBounds = YES;
    [_imgAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(_viewHeader.mas_bottom);
        make.width.height.mas_equalTo(wAvatar);
    }];
    
    [_btnAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(_imgAvatar);
    }];
    
    [_imgChangePicture mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_imgAvatar.mas_centerX);
        make.bottom.equalTo(_imgAvatar.mas_bottom).offset(-10.0);
        make.width.height.mas_equalTo(20.0);
    }];
    
    [tbContents mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    tbContents.separatorStyle = UITableViewCellSeparatorStyleNone;
    tbContents.delegate = self;
    tbContents.dataSource = self;
    
    UIView *viewHeader = [[UIView alloc] init];
    viewHeader.frame = CGRectMake(0, 0, SCREEN_WIDTH, wAvatar/2);
    viewHeader.backgroundColor = UIColor.clearColor;
    tbContents.tableHeaderView = viewHeader;
    
    //  Footer view
    viewFooter = [[UIView alloc] init];
    viewFooter.frame = CGRectMake(0, 0, SCREEN_WIDTH, 100);
    
    btnCancel = [[UIButton alloc] init];
    [btnCancel setTitle:[appDelegate.localization localizedStringForKey:@"Cancel"]
               forState:UIControlStateNormal];
    
    btnCancel.backgroundColor = [UIColor colorWithRed:(210/255.0) green:(51/255.0)
                                                 blue:(92/255.0) alpha:1.0];
    [btnCancel setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnCancel.clipsToBounds = YES;
    btnCancel.layer.cornerRadius = 40.0/2;
    [viewFooter addSubview: btnCancel];
    [btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(viewFooter.mas_centerX).offset(-10);
        make.centerY.equalTo(viewFooter.mas_centerY);
        make.width.mas_equalTo(140.0);
        make.height.mas_equalTo(40.0);
    }];
    
    btnSave = [[UIButton alloc] init];
    [btnSave setTitle:[appDelegate.localization localizedStringForKey:@"Save"]
             forState:UIControlStateNormal];
    btnSave.backgroundColor = [UIColor colorWithRed:(20/255.0) green:(129/255.0)
                                               blue:(211/255.0) alpha:1.0];
    [btnSave setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnSave.clipsToBounds = YES;
    btnSave.layer.cornerRadius = 40.0/2;
    [viewFooter addSubview: btnSave];
    [btnSave mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewFooter.mas_centerX).offset(10);
        make.centerY.equalTo(viewFooter.mas_centerY);
        make.width.equalTo(btnCancel.mas_width);
        make.height.equalTo(btnCancel.mas_height);
    }];
    [btnSave addTarget:self
                action:@selector(saveContactPressed:)
      forControlEvents:UIControlEventTouchUpInside];
    
    tbContents.tableFooterView = viewFooter;
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

- (void)saveContactPressed: (UIButton *)sender {
    [self.view endEditing: true];
    
    [waitingHud showInView:self.view animated:YES];
    
    [self addNewContactToAddressPhoneBook];
    
    [waitingHud dismissAnimated:YES];
    [[PhoneMainView instance] popCurrentView];
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
    if (tableView == tbContents) {
        return NUMBER_ROW_BEFORE + [detailsContact._listPhone count] + 1;
    }else{
        return [listOptions count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == tbContents)
    {
        if (indexPath.row == ROW_CONTACT_NAME || indexPath.row == ROW_CONTACT_EMAIL || indexPath.row == ROW_CONTACT_COMPANY)
        {
            static NSString *identifier = @"InfoForNewContactTableCell";
            InfoForNewContactTableCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
            if (cell == nil) {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"InfoForNewContactTableCell" owner:self options:nil];
                cell = topLevelObjects[0];
            }
            switch (indexPath.row) {
                case ROW_CONTACT_NAME:{
                    cell.lbTitle.text = [appDelegate.localization localizedStringForKey:@"Fullname"];
                    cell.tfContent.text = detailsContact._fullName;
                    [cell.tfContent addTarget:self
                                       action:@selector(whenTextfieldFullnameChanged:)
                             forControlEvents:UIControlEventEditingChanged];
                    break;
                }
                case ROW_CONTACT_EMAIL:{
                    cell.lbTitle.text = [appDelegate.localization localizedStringForKey:@"Email"];
                    cell.tfContent.tag = 100;
                    cell.tfContent.text = detailsContact._email;
                    [cell.tfContent addTarget:self
                                       action:@selector(whenTextfieldChanged:)
                             forControlEvents:UIControlEventEditingChanged];
                    break;
                }
                case ROW_CONTACT_COMPANY:{
                    cell.lbTitle.text = [appDelegate.localization localizedStringForKey:@"Company"];
                    cell.tfContent.tag = 101;
                    cell.tfContent.text = detailsContact._company;
                    [cell.tfContent addTarget:self
                                       action:@selector(whenTextfieldChanged:)
                             forControlEvents:UIControlEventEditingChanged];
                    break;
                }
            }
            return cell;
        }else
        {
            static NSString *identifier = @"NewPhoneCell";
            NewPhoneCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
            if (cell == nil) {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"NewPhoneCell" owner:self options:nil];
                cell = topLevelObjects[0];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if (indexPath.row == detailsContact._listPhone.count + NUMBER_ROW_BEFORE) {
                cell._tfPhone.text = @"";
                
                [cell._iconNewPhone setTitle:@"Add" forState:UIControlStateNormal];
                [cell._iconNewPhone setBackgroundImage:[UIImage imageNamed:@"ic_add_phone.png"]
                                              forState:UIControlStateNormal];
            }else{
                if ((indexPath.row - NUMBER_ROW_BEFORE) >= 0 && (indexPath.row - NUMBER_ROW_BEFORE) < detailsContact._listPhone.count) {
                    ContactDetailObj *aPhone = [detailsContact._listPhone objectAtIndex: (indexPath.row - NUMBER_ROW_BEFORE)];
                    cell._tfPhone.text = aPhone._valueStr;
                    
                    [cell._iconNewPhone setTitle:@"Remove" forState:UIControlStateNormal];
                    [cell._iconNewPhone setBackgroundImage:[UIImage imageNamed:@"ic_delete_phone.png"]
                                                  forState:UIControlStateNormal];
                }
            }
            cell._tfPhone.tag = indexPath.row;
            [cell._tfPhone addTarget:self
                              action:@selector(whenTextfieldPhoneDidChanged:)
                    forControlEvents:UIControlEventEditingChanged];
            
            cell._iconNewPhone.tag = indexPath.row;
            [cell._iconNewPhone addTarget:self
                                   action:@selector(btnAddPhonePressed:)
                         forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
        }
    }else{
        static NSString *identifier = @"MenuCell";
        MenuCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MenuCell" owner:self options:nil];
            cell = topLevelObjects[0];
        }
        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
        [cell setFrame: CGRectMake(cell.frame.origin.x, cell.frame.origin.y, popupChooseAvatar._optionsTableView.frame.size.width, 50.0)];
        
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
        }
        [popupChooseAvatar fadeOut];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == tbContents) {
        if (indexPath.row == ROW_CONTACT_NAME || indexPath.row == ROW_CONTACT_EMAIL || indexPath.row == ROW_CONTACT_COMPANY) {
            return 83.0;
        }
    }
    return 50.0;
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
