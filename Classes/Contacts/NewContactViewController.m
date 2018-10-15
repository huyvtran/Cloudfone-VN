//
//  NewContactViewController.m
//  linphone
//
//  Created by Ei Captain on 3/17/17.
//
//

#import "NewContactViewController.h"
#import "NewPhoneCell.h"
#import "TypePhoneObject.h"
#import "NSDatabase.h"
#import "NSData+Base64.h"
#import "ContactDetailObj.h"
#import "InfoForNewContactTableCell.h"
#import "PECropViewController.h"
#import "TypePhonePopupView.h"

#define ROW_CONTACT_NAME    0
#define ROW_CONTACT_EMAIL   1
#define ROW_CONTACT_COMPANY 2
#define NUMBER_ROW_BEFORE   3

@interface NewContactViewController ()<PECropViewControllerDelegate>{
    LinphoneAppDelegate *appDelegate;
    
    YBHud *waitingHud;
    
    UITapGestureRecognizer *tapOnScreen;
    
    PECropViewController *PECropController;
    
    UIView *viewFooter;
    UIButton *btnCancel;
    UIButton *btnSave;
    TypePhonePopupView *popupTypePhone;
}

@end

@implementation NewContactViewController
@synthesize _viewHeader, bgHeader, _iconBack, _lbHeader, _imgAvatar, _imgChangePicture, _btnAvatar;
@synthesize currentPhoneNumber, currentName;

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
    
    if (currentName != nil && ![currentName isEqualToString:@""]) {
        appDelegate._newContact._fullName = currentName;
        appDelegate._newContact._firstName = currentName;
    }
    //  For case add contact from keypad screen
    if (currentPhoneNumber != nil && ![currentPhoneNumber isEqualToString:@""]) {
        ContactDetailObj *aPhone = [[ContactDetailObj alloc] init];
        aPhone._iconStr = @"btn_contacts_mobile.png";
        aPhone._titleStr = [appDelegate.localization localizedStringForKey:type_phone_mobile];
        aPhone._valueStr = currentPhoneNumber;
        aPhone._buttonStr = @"contact_detail_icon_call.png";
        aPhone._typePhone = type_phone_mobile;
        [appDelegate._newContact._listPhone addObject: aPhone];
    }
    
    if (appDelegate._dataCrop != nil) {
        _imgAvatar.image = [UIImage imageWithData: appDelegate._dataCrop];
    }else{
        _imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
    }
    
    [_tbContents reloadData];
    
    if ([appDelegate._newContact._fullName isEqualToString:@""] || appDelegate._newContact._fullName == nil) {
        [self enableForSaveButton: NO];
    }else{
        [self enableForSaveButton: YES];
    }
    //  notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(afterAddAndReloadContactDone)
                                                 name:finishLoadContacts object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenSelectTypeForPhone:)
                                                 name:selectTypeForPhoneNumber object:nil];
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
    currentPhoneNumber = @"";
    appDelegate._dataCrop = nil;
    appDelegate._cropAvatar = nil;
    
    [[PhoneMainView instance] popCurrentView];
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
    _lbHeader.text = [appDelegate.localization localizedStringForKey: @"Add contact"];
    [btnCancel setTitle:[appDelegate.localization localizedStringForKey:@"Cancel"]
               forState:UIControlStateNormal];
    [btnSave setTitle:[appDelegate.localization localizedStringForKey:@"Save"]
             forState:UIControlStateNormal];
}

//  Thêm mới contact
- (void)addContacts
{
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
    
    [LinphoneAppDelegate sharedInstance].needToReloadContactList = YES;
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

- (void)setupUIForView {
    //  Tap vào màn hình để đóng bàn phím
    float wAvatar = 110.0;
    
    if (SCREEN_WIDTH > 320) {
        _lbHeader.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:20.0];
    }else{
        _lbHeader.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }
    
    //  Tap vào màn hình để đóng bàn phím
    tapOnScreen = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                          action:@selector(whenTapOnMainScreen)];
    tapOnScreen.delegate = self;
    self.view.userInteractionEnabled = YES;
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
        make.width.height.mas_equalTo(HEADER_ICON_WIDTH);
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
    
    [_tbContents mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    _tbContents.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tbContents.delegate = self;
    _tbContents.dataSource = self;
    
    UIView *viewHeader = [[UIView alloc] init];
    viewHeader.frame = CGRectMake(0, 0, SCREEN_WIDTH, wAvatar/2);
    viewHeader.backgroundColor = UIColor.clearColor;
    _tbContents.tableHeaderView = viewHeader;
    
    
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
    
    _tbContents.tableFooterView = viewFooter;
}

//  Hiển thị bàn phím
- (void)keyboardWillShow:(NSNotification *)notif {
    CGSize keyboardSize = [[[notif userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [_tbContents mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-keyboardSize.height);
    }];
}

//  Ẩn bàn phím
- (void)keyboardDidHide: (NSNotification *) notif{
    [_tbContents mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
    }];
}

//  Tap vào màn hình chính để đóng bàn phím
- (void)whenTapOnMainScreen {
    [self.view endEditing: true];
}

//  Thêm hoặc xoá số phone
- (void)btnAddPhonePressed: (UIButton *)sender {
    int tag = (int)[sender tag];
    if (tag - NUMBER_ROW_BEFORE >= 0) {
        if ([sender.currentTitle isEqualToString:@"Add"])
        {
            NewPhoneCell *cell = [_tbContents cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tag inSection:0]];
            if (cell != nil && ![cell._tfPhone.text isEqualToString:@""]) {
                ContactDetailObj *aPhone = [[ContactDetailObj alloc] init];
                aPhone._valueStr = cell._tfPhone.text;
                aPhone._buttonStr = @"contact_detail_icon_call.png";
                
                NSString *type = cell._iconTypePhone.currentTitle;
                if ([type isEqualToString:type_phone_work])
                {
                    aPhone._typePhone = type_phone_work;
                    aPhone._iconStr = @"btn_contacts_work.png";
                    aPhone._titleStr = [appDelegate.localization localizedStringForKey:type_phone_work];
                    
                }else if ([type isEqualToString:type_phone_fax]){
                    aPhone._typePhone = type_phone_fax;
                    aPhone._iconStr = @"btn_contacts_fax.png";
                    aPhone._titleStr = [appDelegate.localization localizedStringForKey:type_phone_fax];
                    
                }else if ([type isEqualToString:type_phone_home]){
                    aPhone._typePhone = type_phone_home;
                    aPhone._iconStr = @"btn_contacts_home.png";
                    aPhone._titleStr = [appDelegate.localization localizedStringForKey:type_phone_home];
                    
                }else{
                    aPhone._typePhone = type_phone_mobile;
                    aPhone._iconStr = @"btn_contacts_mobile.png";
                    aPhone._titleStr = [appDelegate.localization localizedStringForKey:type_phone_mobile];
                }
                [appDelegate._newContact._listPhone addObject: aPhone];
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
    [_tbContents reloadData];
}

- (void)whenTextfieldPhoneDidChanged: (UITextField *)textfield {
    int row = (int)[textfield tag];
    if (row-NUMBER_ROW_BEFORE >= 0 && row-NUMBER_ROW_BEFORE < appDelegate._newContact._listPhone.count)
    {
        ContactDetailObj *curPhone = [appDelegate._newContact._listPhone objectAtIndex: row];
        curPhone._valueStr = textfield.text;
    }
}

#pragma mark - UITableview Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return NUMBER_ROW_BEFORE + [appDelegate._newContact._listPhone count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
                cell.tfContent.text = [self getFullnameOfContactIfExists];
                [cell.tfContent addTarget:self
                                   action:@selector(whenTextfieldFullnameChanged:)
                         forControlEvents:UIControlEventEditingChanged];
                break;
            }
            case ROW_CONTACT_EMAIL:{
                cell.lbTitle.text = [appDelegate.localization localizedStringForKey:@"Email"];
                cell.tfContent.tag = 100;
                cell.tfContent.keyboardType = UIKeyboardTypeEmailAddress;
                [cell.tfContent addTarget:self
                                   action:@selector(whenTextfieldChanged:)
                         forControlEvents:UIControlEventEditingChanged];
                
                if (![appDelegate._newContact._email isEqualToString: @""] && appDelegate._newContact._email != nil) {
                    cell.tfContent.text = appDelegate._newContact._email;
                }else{
                    cell.tfContent.text = @"";
                }
                
                break;
            }
            case ROW_CONTACT_COMPANY:{
                cell.lbTitle.text = [appDelegate.localization localizedStringForKey:@"Company"];
                cell.tfContent.tag = 101;
                [cell.tfContent addTarget:self
                                   action:@selector(whenTextfieldChanged:)
                         forControlEvents:UIControlEventEditingChanged];
                
                if (![appDelegate._newContact._company isEqualToString: @""] && appDelegate._newContact._company != nil) {
                    cell.tfContent.text = appDelegate._newContact._company;
                }else{
                    cell.tfContent.text = @"";
                }
                break;
            }
        }
        return cell;
    }else{
        static NSString *identifier = @"NewPhoneCell";
        NewPhoneCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"NewPhoneCell" owner:self options:nil];
            cell = topLevelObjects[0];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (indexPath.row == appDelegate._newContact._listPhone.count + NUMBER_ROW_BEFORE) {
            cell._tfPhone.text = @"";
            
            [cell._iconNewPhone setTitle:@"Add" forState:UIControlStateNormal];
            [cell._iconNewPhone setBackgroundImage:[UIImage imageNamed:@"ic_add_phone.png"]
                                          forState:UIControlStateNormal];
            
            [cell._iconTypePhone setTitle:text_phone_mobile forState:UIControlStateNormal];
            [cell._iconTypePhone setBackgroundImage:[UIImage imageNamed:@"btn_contacts_mobile"]
                                           forState:UIControlStateNormal];
        }else{
            if ((indexPath.row - NUMBER_ROW_BEFORE) >= 0 && (indexPath.row - NUMBER_ROW_BEFORE) < appDelegate._newContact._listPhone.count) {
                ContactDetailObj *aPhone = [appDelegate._newContact._listPhone objectAtIndex: (indexPath.row - NUMBER_ROW_BEFORE)];
                cell._tfPhone.text = aPhone._valueStr;
                
                [cell._iconNewPhone setTitle:@"Remove" forState:UIControlStateNormal];
                [cell._iconNewPhone setBackgroundImage:[UIImage imageNamed:@"ic_delete_phone.png"]
                                              forState:UIControlStateNormal];
                [cell._iconTypePhone setTitle:aPhone._typePhone forState:UIControlStateNormal];
                [cell._iconTypePhone setBackgroundImage:[UIImage imageNamed:aPhone._iconStr]
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
        
        cell._iconTypePhone.tag = indexPath.row;
        [cell._iconTypePhone addTarget:self
                                action:@selector(btnTypePhonePressed:)
                      forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == ROW_CONTACT_NAME || indexPath.row == ROW_CONTACT_EMAIL || indexPath.row == ROW_CONTACT_COMPANY) {
        return 83.0;
    }
    return 50.0;
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
    appDelegate._dataCrop = nil;
}

- (void)saveContactPressed: (UIButton *)sender {
    [self.view endEditing: true];
    
    if ((appDelegate._newContact._firstName == nil || [appDelegate._newContact._firstName isEqualToString:@""]) && (appDelegate._newContact._lastName == nil || [appDelegate._newContact._lastName isEqualToString:@""]))
    {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Please input contact name"]
                    duration:2.0 position:CSToastPositionCenter];
        return;
    }
    [waitingHud showInView:self.view animated:YES];
    
    //  Check if user input phone number into textfield but have not added to list phone ---> still add
    /*
    if (appDelegate._newContact._listPhone.count == 0) {
        NewPhoneCell *cell = [_tbContents cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(NUMBER_ROW_BEFORE + appDelegate._newContact._listPhone.count) inSection:0]];
        if (cell != nil && [cell isKindOfClass:[NewPhoneCell class]] && [cell._iconNewPhone.currentTitle isEqualToString:@"Add"]) {
            if (![cell._tfPhone.text isEqualToString:@""]) {
                ContactDetailObj *aPhone = [[ContactDetailObj alloc] init];
                aPhone._iconStr = @"btn_contacts_mobile.png";
                aPhone._titleStr = [appDelegate.localization localizedStringForKey:type_phone_mobile];
                aPhone._valueStr = cell._tfPhone.text;
                aPhone._buttonStr = @"contact_detail_icon_call.png";
                aPhone._typePhone = type_phone_mobile;
                [appDelegate._newContact._listPhone addObject: aPhone];
                NSLog(@"-------%@", cell._tfPhone.text);
            }else{
                NSLog(@"-------EMPTY!!!!!!!");
            }
            
        }
    }   */
    
    //  Remove all phone number with value is empty
    for (int iCount=0; iCount<appDelegate._newContact._listPhone.count; iCount++) {
        ContactDetailObj *aPhone = [appDelegate._newContact._listPhone objectAtIndex: iCount];
        if ([aPhone._valueStr isEqualToString: @""]) {
            [appDelegate._newContact._listPhone removeObject: aPhone];
            iCount--;
        }
    }
    
    [self addContacts];
}

- (void)whenTextfieldFullnameChanged: (UITextField *)textfield {
    //  Save fullname into first name
    appDelegate._newContact._firstName = textfield.text;
    appDelegate._newContact._fullName = textfield.text;
    appDelegate._newContact._lastName = @"";
    
    if (![textfield.text isEqualToString:@""]) {
        [self enableForSaveButton: YES];
    }else{
        [self enableForSaveButton: NO];
    }
}

- (void)whenTextfieldChanged: (UITextField *)textfield {
    if (textfield.tag == 100) {
        appDelegate._newContact._email = textfield.text;
    }else if (textfield.tag == 101){
        appDelegate._newContact._company = textfield.text;
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

- (NSString *)getFullnameOfContactIfExists {
    NSString *fullname = @"";
    if (appDelegate._newContact._firstName != nil && appDelegate._newContact._lastName != nil) {
        fullname = [NSString stringWithFormat:@"%@ %@", appDelegate._newContact._lastName, appDelegate._newContact._firstName];
    }else if (appDelegate._newContact._firstName != nil && appDelegate._newContact._lastName == nil){
        fullname = appDelegate._newContact._firstName;
    }else if (appDelegate._newContact._firstName == nil && appDelegate._newContact._lastName != nil){
        fullname = appDelegate._newContact._lastName;
    }
    return fullname;
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

//  Chọn loại phone
- (void)whenSelectTypeForPhone: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[TypePhoneObject class]]) {
        int curIndex = (int)[popupTypePhone tag];
        
        //  Choose phone type for row: Add new phone
        NewPhoneCell *cell = [_tbContents cellForRowAtIndexPath:[NSIndexPath indexPathForRow:curIndex inSection:0]];
        if ([cell isKindOfClass:[NewPhoneCell class]]) {
            NSString *imgName = [self getTypeOfPhone: [(TypePhoneObject *)object _strType]];
            [cell._iconTypePhone setBackgroundImage:[UIImage imageNamed:imgName]
                                           forState:UIControlStateNormal];
            [cell._iconTypePhone setTitle:[(TypePhoneObject *)object _strType] forState:UIControlStateNormal];
        }
        if (curIndex - NUMBER_ROW_BEFORE >= 0 && (curIndex - NUMBER_ROW_BEFORE) < appDelegate._newContact._listPhone.count)
        {
            ContactDetailObj *curPhone = [appDelegate._newContact._listPhone objectAtIndex: (curIndex - NUMBER_ROW_BEFORE)];
            curPhone._typePhone = [(TypePhoneObject *)object _strType];
            curPhone._iconStr = [self getTypeOfPhone: curPhone._typePhone];
            [_tbContents reloadData];
        }
    }
}

@end
