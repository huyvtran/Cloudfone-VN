//
//  iPadEditContactViewController.m
//  linphone
//
//  Created by lam quang quan on 1/25/19.
//

#import "iPadEditContactViewController.h"
#import "ContactDetailObj.h"
#import "NewPhoneCell.h"
#import "TypePhoneObject.h"
#import "TypePhonePopupView.h"
#import "PECropViewController.h"

@interface iPadEditContactViewController ()<PECropViewControllerDelegate>{
    TypePhonePopupView *popupTypePhone;
    UIBarButtonItem *btnSave;
    PECropViewController *PECropController;
}
@end

@implementation iPadEditContactViewController
@synthesize viewHeader, btnAvatar, imgAvatar, imgChange, tfName, tfEmail, tfCompany, tbPhone;
@synthesize detailsContact, idContact, curPhoneNumber;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupUIForView];
    [self createSaveContactButtonForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [WriteLogsUtils writeForGoToScreen: @"iPadEditContactViewController"];
    
    [self showContentWithCurrentLanguage];
    
    idContact = [LinphoneAppDelegate sharedInstance].idContact;
    
    //  Get contact information
    if (detailsContact == nil) {
        detailsContact = [[LinphoneAppDelegate sharedInstance] getContactInPhoneBookWithIdRecord: idContact];
        
        if (curPhoneNumber != nil && ![curPhoneNumber isEqualToString:@""] && ![self checkCurrentPhone: curPhoneNumber inList: detailsContact._listPhone])
        {
            ContactDetailObj *aPhone = [[ContactDetailObj alloc] init];
            aPhone._iconStr = @"btn_contacts_mobile.png";
            aPhone._titleStr = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:type_phone_mobile];
            aPhone._valueStr = curPhoneNumber;
            aPhone._buttonStr = @"contact_detail_icon_call.png";
            aPhone._typePhone = type_phone_mobile;
            if (detailsContact._listPhone == nil){
                detailsContact._listPhone = [[NSMutableArray alloc] init];
            }
            [detailsContact._listPhone addObject: aPhone];
        }
    }
    [self displayContactInformation];
    
    [tbPhone reloadData];
    if ([AppUtils isNullOrEmpty: detailsContact._fullName]) {
        [self enableForSaveButton: NO];
    }else{
        [self enableForSaveButton: YES];
    }
    
    //  notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenSelectTypeForPhone:)
                                                 name:selectTypeForPhoneNumber object:nil];
}

-(void) viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound)
    {
        // Navigation button was pressed. Do some stuff
        [LinphoneAppDelegate sharedInstance]._dataCrop = nil;
        
        [self.navigationController popViewControllerAnimated:NO];
    }
    [super viewWillDisappear:animated];
}

- (void)createSaveContactButtonForView {
    UIButton *save = [UIButton buttonWithType:UIButtonTypeCustom];
    save.backgroundColor = UIColor.clearColor;
    [save setImage:[UIImage imageNamed:@"ic_save"] forState:UIControlStateNormal];
    save.imageEdgeInsets = UIEdgeInsetsMake(15.0, 15.0, 15.0, 15.0);
    save.frame = CGRectMake(17, 0, 50.0, 50.0 );
    [save addTarget:self
             action:@selector(iconSaveContactClicked)
   forControlEvents:UIControlEventTouchUpInside];
    
    UIView *saveView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50.0, 50.0)];
    [saveView addSubview: save];
    
    btnSave = [[UIBarButtonItem alloc] initWithCustomView: saveView];
    btnSave.customView.backgroundColor = UIColor.clearColor;
    self.navigationItem.rightBarButtonItem = btnSave;
}

- (void)keyboardWillShow: (NSNotification *) notif{
    CGSize keyboardSize = [[[notif userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [tbPhone mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-keyboardSize.height);
    }];
}

- (void)keyboardDidHide: (NSNotification *) notif{
    [tbPhone mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
    }];
}

//  Chọn loại phone
- (void)whenSelectTypeForPhone: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[TypePhoneObject class]]) {
        int curIndex = (int)[popupTypePhone tag];
        
        //  Choose phone type for row: Add new phone
        NewPhoneCell *cell = [tbPhone cellForRowAtIndexPath:[NSIndexPath indexPathForRow:curIndex inSection:0]];
        if ([cell isKindOfClass:[NewPhoneCell class]]) {
            NSString *imgName = [self getTypeOfPhone: [(TypePhoneObject *)object _strType]];
            [cell._iconTypePhone setBackgroundImage:[UIImage imageNamed:imgName]
                                           forState:UIControlStateNormal];
            [cell._iconTypePhone setTitle:[(TypePhoneObject *)object _strType] forState:UIControlStateNormal];
        }
        if (curIndex < detailsContact._listPhone.count)
        {
            ContactDetailObj *curPhone = [detailsContact._listPhone objectAtIndex: curIndex];
            curPhone._typePhone = [(TypePhoneObject *)object _strType];
            curPhone._iconStr = [self getTypeOfPhone: curPhone._typePhone];
            [tbPhone reloadData];
        }
    }
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

- (void)enableForSaveButton: (BOOL)enable {
    if (enable) {
        self.navigationItem.rightBarButtonItem = btnSave;
    }else{
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)iconSaveContactClicked {
    [LinphoneAppDelegate sharedInstance].needToReloadContactList = YES;
    
    [self.view endEditing: true];
    
    [[LinphoneAppDelegate sharedInstance] showWaiting: YES];
    
    [self updateContactIntoAddressPhoneBook];
    [self performSelector:@selector(hideWaitingView) withObject:nil afterDelay:1.0];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)hideWaitingView {
    [[LinphoneAppDelegate sharedInstance] showWaiting: NO];
}

- (void)displayContactInformation
{
    if (detailsContact._listPhone == nil) {
        detailsContact._listPhone = [[NSMutableArray alloc] init];
    }
    
    tfCompany.text = @"";
    if (![AppUtils isNullOrEmpty: detailsContact._company]) {
        tfCompany.text = detailsContact._company;
    }
    
    tfEmail.text = @"";
    if (![AppUtils isNullOrEmpty: detailsContact._email]) {
        tfEmail.text = detailsContact._email;
    }
    
    tfName.text = @"";
    if (![AppUtils isNullOrEmpty: detailsContact._fullName]) {
        tfName.text = detailsContact._fullName;
    }
    
    //  Avatar contact
    if ([LinphoneAppDelegate sharedInstance]._dataCrop != nil) {
        imgAvatar.image = [UIImage imageWithData: [LinphoneAppDelegate sharedInstance]._dataCrop];
    }else{
        if (![AppUtils isNullOrEmpty: detailsContact._avatar]) {
            imgAvatar.image = [UIImage imageWithData: [NSData dataFromBase64String: detailsContact._avatar]];
        }else{
            imgAvatar.image = [UIImage imageNamed:@"avatar"];
        }
    }
}

- (void)showContentWithCurrentLanguage {
    self.title = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Edit contact"];
    tfName.placeholder = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Fullname"];
    tfEmail.placeholder = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Email"];
    tfCompany.placeholder = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Company"];
}

- (void)whenTapOnMainScreen {
    [self.view endEditing: true];
}

- (BOOL)checkCurrentPhone: (NSString *)phone inList: (NSArray *)listPhone {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_valueStr = %@", phone];
    NSArray *filter = [listPhone filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        return YES;
    }
    return NO;
}

- (void)setupUIForView {
    UITapGestureRecognizer *tapOnScreen = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTapOnMainScreen)];
    [self.view setUserInteractionEnabled: true];
    [self.view addGestureRecognizer: tapOnScreen];
    
    self.view.backgroundColor = viewHeader.backgroundColor = IPAD_BG_COLOR;
    
    //  view header
    float hTextfield = 35.0;
    float padding = 20.0;
    float hHeader = padding + hTextfield + 10 + hTextfield + 10.0 + hTextfield + padding;
    
    [viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(hHeader);
    }];
    
    float hAvatar = hHeader-2*padding;
    [ContactUtils addBorderForImageView:imgAvatar withRectSize:hAvatar strokeWidth:0 strokeColor:nil radius:4.0];
    [imgAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewHeader).offset(padding);
        make.centerY.equalTo(viewHeader.mas_centerY);
        make.width.height.mas_equalTo(hAvatar);
    }];
    imgAvatar.image = [UIImage imageNamed:@"avatar"];
    
    [imgChange mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(btnAvatar.mas_centerX);
        make.bottom.equalTo(btnAvatar.mas_bottom).offset(-10.0);
        make.width.height.mas_equalTo(20.0);
    }];
    
    [btnAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(imgAvatar);
    }];
    
    tfName.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightThin];
    tfName.textColor = UIColor.blackColor;
    [tfName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(btnAvatar.mas_right).offset(padding);
        make.right.equalTo(viewHeader).offset(-padding);
        make.top.equalTo(btnAvatar);
        make.height.mas_equalTo(hTextfield);
    }];
    [tfName addTarget:self
               action:@selector(whenTextfieldFullnameChanged:)
     forControlEvents:UIControlEventEditingChanged];
    
    //  email
    tfEmail.tag = 100;
    tfEmail.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightThin];
    tfEmail.textColor = tfName.textColor;
    [tfEmail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(tfName);
        make.top.equalTo(tfName.mas_bottom).offset(10.0);
        make.height.mas_equalTo(hTextfield);
    }];
    [tfEmail addTarget:self
                action:@selector(whenTextfieldChanged:)
      forControlEvents:UIControlEventEditingChanged];
    
    //  company
    tfCompany.tag = 101;
    tfCompany.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightThin];
    tfCompany.textColor = tfName.textColor;
    [tfCompany mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(tfEmail);
        make.top.equalTo(tfEmail.mas_bottom).offset(10.0);
        make.height.mas_equalTo(hTextfield);
    }];
    [tfCompany addTarget:self
                action:@selector(whenTextfieldChanged:)
      forControlEvents:UIControlEventEditingChanged];
    
    [tbPhone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    tbPhone.separatorStyle = UITableViewCellSeparatorStyleNone;
    tbPhone.backgroundColor = UIColor.clearColor;
    tbPhone.delegate = self;
    tbPhone.dataSource = self;
    
    /*  [Khai Le]
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
    */
}

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

#pragma mark - UITableview Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [detailsContact._listPhone count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"NewPhoneCell";
    NewPhoneCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"NewPhoneCell" owner:self options:nil];
        cell = topLevelObjects[0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == detailsContact._listPhone.count) {
        cell._tfPhone.text = @"";
        
        [cell._iconNewPhone setTitle:@"Add" forState:UIControlStateNormal];
        [cell._iconNewPhone setBackgroundImage:[UIImage imageNamed:@"ic_add_phone.png"]
                                      forState:UIControlStateNormal];
    }else{
        ContactDetailObj *aPhone = [detailsContact._listPhone objectAtIndex: indexPath.row];
        cell._tfPhone.text = aPhone._valueStr;
        
        [cell._iconNewPhone setTitle:@"Remove" forState:UIControlStateNormal];
        [cell._iconNewPhone setBackgroundImage:[UIImage imageNamed:@"ic_delete_phone.png"]
                                      forState:UIControlStateNormal];
        
        [cell._iconTypePhone setTitle:aPhone._typePhone forState:UIControlStateNormal];
        [cell._iconTypePhone setBackgroundImage:[UIImage imageNamed:aPhone._iconStr]
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
    
    cell._iconTypePhone.tag = indexPath.row;
    [cell._iconTypePhone addTarget:self
                            action:@selector(btnTypePhonePressed:)
                  forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (void)whenTextfieldPhoneDidChanged: (UITextField *)textfield {
    int row = (int)[textfield tag];
    if (row < detailsContact._listPhone.count) {
        ContactDetailObj *curPhone = [detailsContact._listPhone objectAtIndex: row];
        [curPhone set_valueStr: textfield.text];
    }
}

//  Thêm hoặc xoá số phone
- (void)btnAddPhonePressed: (UIButton *)sender {
    int tag = (int)[sender tag];
    if ([sender.currentTitle isEqualToString:@"Add"])
    {
        NewPhoneCell *cell = [tbPhone cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tag inSection:0]];
        if (cell != nil && ![cell._tfPhone.text isEqualToString:@""]) {
            ContactDetailObj *aPhone = [[ContactDetailObj alloc] init];
            aPhone._valueStr = cell._tfPhone.text;
            aPhone._buttonStr = @"contact_detail_icon_call.png";
            
            NSString *type = cell._iconTypePhone.currentTitle;
            if ([type isEqualToString:type_phone_work])
            {
                aPhone._typePhone = type_phone_work;
                aPhone._iconStr = @"btn_contacts_work.png";
                aPhone._titleStr = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:type_phone_work];
                
            }else if ([type isEqualToString:type_phone_fax]){
                aPhone._typePhone = type_phone_fax;
                aPhone._iconStr = @"btn_contacts_fax.png";
                aPhone._titleStr = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:type_phone_fax];
                
            }else if ([type isEqualToString:type_phone_home]){
                aPhone._typePhone = type_phone_home;
                aPhone._iconStr = @"btn_contacts_home.png";
                aPhone._titleStr = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:type_phone_home];
                
            }else{
                aPhone._typePhone = type_phone_mobile;
                aPhone._iconStr = @"btn_contacts_mobile.png";
                aPhone._titleStr = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:type_phone_mobile];
            }
            [detailsContact._listPhone addObject: aPhone];
        }else{
            [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Please input phone number"]
                        duration:2.0 position:CSToastPositionCenter];
        }
    }else if ([sender.currentTitle isEqualToString:@"Remove"]){
        if (tag < detailsContact._listPhone.count) {
            [detailsContact._listPhone removeObjectAtIndex: tag];
        }
    }
    
    //  Khi thêm mới hoặc xoá thì chỉ có dòng cuối cùng là new
    [tbPhone reloadData];
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
    [popupTypePhone showInView:[LinphoneAppDelegate sharedInstance].window animated:YES];
}

- (void)updateContactIntoAddressPhoneBook
{
    ABAddressBookRef addressBook;
    CFErrorRef anError = NULL;
    addressBook = ABAddressBookCreateWithOptions(nil, &anError);
    
    ABRecordRef aRecord = ABAddressBookGetPersonWithRecordID(addressBook, detailsContact._id_contact);
    
    // Lưu thông tin
    ABRecordSetValue(aRecord, kABPersonFirstNameProperty, (__bridge CFTypeRef)(detailsContact._fullName), &anError);
    ABRecordSetValue(aRecord, kABPersonLastNameProperty, (__bridge CFTypeRef)(detailsContact._lastName), &anError);
    ABRecordSetValue(aRecord, kABPersonOrganizationProperty, (__bridge CFTypeRef)(detailsContact._company), &anError);
    ABRecordSetValue(aRecord, kABPersonFirstNamePhoneticProperty, (__bridge CFTypeRef)(@""), &anError);
    
    if (detailsContact._email != nil) {
        ABMutableMultiValueRef email = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(email, (__bridge CFTypeRef)(detailsContact._email), CFSTR("email"), NULL);
        ABRecordSetValue(aRecord, kABPersonEmailProperty, email, &anError);
    }
    
    if ([LinphoneAppDelegate sharedInstance]._dataCrop != nil) {
        CFDataRef cfdata = CFDataCreate(NULL,[[LinphoneAppDelegate sharedInstance]._dataCrop bytes], [[LinphoneAppDelegate sharedInstance]._dataCrop length]);
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
        NSString *content = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Contact has been updated"];
        
        [[LinphoneAppDelegate sharedInstance].window makeToast:content duration:2.0 position:CSToastPositionCenter];
    }
    
    if (anError != NULL) {
        NSString *content = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Failed. Please try later!"];
        
        [[LinphoneAppDelegate sharedInstance].window makeToast:content duration:2.0 position:CSToastPositionCenter];
    }
    
    [self addNewContactToList: aRecord];
}

- (void)addNewContactToList: (ABRecordRef)aPerson
{
    ContactObject *aContact = [[LinphoneAppDelegate sharedInstance] getContactInPhoneBookWithIdRecord: idContact];
    
    //  Replace current contact with new contact after updated
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_id_contact = %d", idContact];
    NSArray *filter = [[LinphoneAppDelegate sharedInstance].listContacts filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        [[LinphoneAppDelegate sharedInstance].listContacts removeObjectsInArray: filter];
    }
    [[LinphoneAppDelegate sharedInstance].listContacts addObject: aContact];
    
    //  [Khai Le - 14/02/2019]  reload ipad contacts list after update
    [[NSNotificationCenter defaultCenter] postNotificationName:reloadContactsListForIpad object:nil];
    
    [LinphoneAppDelegate sharedInstance]._dataCrop = nil;
    [self.navigationController popViewControllerAnimated: YES];
}

- (IBAction)btnAvatarPressed:(UIButton *)sender {
    [self.view endEditing: YES];
    
    if ([LinphoneAppDelegate sharedInstance]._dataCrop != nil || (detailsContact._avatar != nil && ![detailsContact._avatar isEqualToString:@""])) {
        UIActionSheet *popupAddContact = [[UIActionSheet alloc] initWithTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Options"] delegate:self cancelButtonTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Cancel"] destructiveButtonTitle:nil otherButtonTitles:
                                          [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Gallery"],
                                          [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Camera"],
                                          [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Remove Avatar"],
                                          nil];
        popupAddContact.tag = 100;
        //  [popupAddContact showInView:self.view];
        [popupAddContact showFromRect:imgAvatar.bounds inView:imgAvatar animated:YES];
    }else{
        UIActionSheet *popupAddContact = [[UIActionSheet alloc] initWithTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Options"] delegate:self cancelButtonTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Cancel"] destructiveButtonTitle:nil otherButtonTitles: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Gallery"], [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Camera"],
                                          nil];
        popupAddContact.tag = 101;
        //  [popupAddContact showInView:self.view];
        [popupAddContact showFromRect:imgAvatar.bounds inView:imgAvatar animated:YES];
    }
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [LinphoneAppDelegate sharedInstance].fromImagePicker = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            [picker setDelegate: self];
            [picker setSourceType: UIImagePickerControllerSourceTypeCamera];
            [self presentViewController:picker animated:YES completion:NULL];
        });
    });
}

- (void)pressOnGallery {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [LinphoneAppDelegate sharedInstance].fromImagePicker = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
            pickerController.delegate = self;
            
            UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:pickerController];
            [popover presentPopoverFromRect:imgAvatar.bounds inView:imgAvatar permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            self.popOver = popover;
        });
    });
}

- (void)removeAvatar {
    if ([LinphoneAppDelegate sharedInstance]._dataCrop != nil) {
        [LinphoneAppDelegate sharedInstance]._dataCrop = nil;
        if (![AppUtils isNullOrEmpty: detailsContact._avatar]){
            imgAvatar.image = [UIImage imageWithData: [NSData dataFromBase64String: detailsContact._avatar]];
        }else{
            imgAvatar.image = [UIImage imageNamed:@"avatar"];
        }
    }else{
        detailsContact._avatar = @"";
        imgAvatar.image = [UIImage imageNamed:@"avatar"];
    }
}

#pragma mark - PECropViewControllerDelegate methods

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage transform:(CGAffineTransform)transform cropRect:(CGRect)cropRect
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    [LinphoneAppDelegate sharedInstance]._dataCrop = UIImagePNGRepresentation(croppedImage);
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Picker image

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    // Crop image trong edits contact
    [LinphoneAppDelegate sharedInstance]._cropAvatar = image;
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = newBackButton;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self openEditor];
    }];
}

- (void)openEditor {
    PECropController = [[PECropViewController alloc] init];
    PECropController.delegate = self;
    PECropController.image = [LinphoneAppDelegate sharedInstance]._cropAvatar;
    
    UIImage *image = [LinphoneAppDelegate sharedInstance]._cropAvatar;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat length = MIN(width, height);
    PECropController.imageCropRect = CGRectMake((width - length) / 2, (height - length) / 2, length, length);
    PECropController.keepingCropAspectRatio = true;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController: PECropController];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [self.navigationController pushViewController:PECropController animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    //  [lbStatusBg setBackgroundColor:[UIColor blackColor]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
