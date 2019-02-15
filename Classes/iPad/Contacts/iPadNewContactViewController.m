//
//  iPadNewContactViewController.m
//  linphone
//
//  Created by lam quang quan on 1/16/19.
//

#import "iPadNewContactViewController.h"
#import "InfoForNewContactTableCell.h"
#import "NSData+Base64.h"
#import "ContactDetailObj.h"
#import "NewPhoneCell.h"
#import "TypePhoneObject.h"
#import "TypePhonePopupView.h"
#import "PECropViewController.h"

#define ROW_CONTACT_NAME    0
#define ROW_CONTACT_EMAIL   1
#define ROW_CONTACT_COMPANY 2
#define NUMBER_ROW_BEFORE   3

@interface iPadNewContactViewController ()<PECropViewControllerDelegate>{
    LinphoneAppDelegate *appDelegate;
    UITapGestureRecognizer *tapOnScreen;
    
    UIView *viewFooter;
    
    TypePhonePopupView *popupTypePhone;
    UIBarButtonItem *btnSave;
    UIBarButtonItem *btnCancel;
    
    PECropViewController *PECropController;
}

@end

@implementation iPadNewContactViewController
@synthesize imgAvatar, btnAvatar, tbContents, currentName, currentPhoneNumber;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate._newContact == nil) {
        appDelegate._newContact = [[ContactObject alloc] init];
        appDelegate._newContact._listPhone = [[NSMutableArray alloc] init];
    }
    
    [self setupUIForView];
    
    btnCancel = [[UIBarButtonItem alloc] initWithTitle:[appDelegate.localization localizedStringForKey:@"Cancel"] style:UIBarButtonItemStyleDone target:self action:@selector(resetDataAfterAddContact)];
    self.navigationItem.leftBarButtonItem = btnCancel;
    
    btnSave = [[UIBarButtonItem alloc] initWithTitle:[appDelegate.localization localizedStringForKey:@"Save"] style:UIBarButtonItemStyleDone target:self action:@selector(saveContactPressed)];
    self.navigationItem.rightBarButtonItem = btnSave;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [WriteLogsUtils writeForGoToScreen: @"iPadNewContactViewController"];
    
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
    if (currentPhoneNumber != nil && ![currentPhoneNumber isEqualToString:@""] && ![self checkCurrentPhone: currentPhoneNumber inList: appDelegate._newContact._listPhone])
    {
        ContactDetailObj *aPhone = [[ContactDetailObj alloc] init];
        aPhone._iconStr = @"btn_contacts_mobile.png";
        aPhone._titleStr = [appDelegate.localization localizedStringForKey:type_phone_mobile];
        aPhone._valueStr = currentPhoneNumber;
        aPhone._buttonStr = @"contact_detail_icon_call.png";
        aPhone._typePhone = type_phone_mobile;
        [appDelegate._newContact._listPhone addObject: aPhone];
    }
    
    if (appDelegate._dataCrop != nil) {
        imgAvatar.image = [UIImage imageWithData: appDelegate._dataCrop];
    }else{
        imgAvatar.image = [UIImage imageNamed:@"man_user.png"];
    }
    
    [tbContents reloadData];
    
    if ([appDelegate._newContact._fullName isEqualToString:@""] || appDelegate._newContact._fullName == nil) {
        btnSave.enabled = NO;
    }else{
        btnSave.enabled = YES;
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

- (IBAction)btnAvatarPressed:(UIButton *)sender {
    [self.view endEditing: YES];
    if (appDelegate._dataCrop != nil) {
        UIActionSheet *popupAddContact = [[UIActionSheet alloc] initWithTitle:[appDelegate.localization localizedStringForKey:@"Options"] delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:@"Cancel"] destructiveButtonTitle:nil otherButtonTitles:
                                          [appDelegate.localization localizedStringForKey:@"Gallery"],
                                          [appDelegate.localization localizedStringForKey:@"Camera"],
                                          [appDelegate.localization localizedStringForKey:@"Remove Avatar"],
                                          nil];
        popupAddContact.tag = 100;
        [popupAddContact showFromRect:imgAvatar.bounds inView:imgAvatar animated:YES];
        
    }else{
        UIActionSheet *popupAddContact = [[UIActionSheet alloc] initWithTitle:[appDelegate.localization localizedStringForKey:@"Options"] delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:@"Cancel"] destructiveButtonTitle:nil otherButtonTitles:
                                          [appDelegate.localization localizedStringForKey:@"Gallery"],
                                          [appDelegate.localization localizedStringForKey:@"Camera"],
                                          nil];
        popupAddContact.tag = 101;
        [popupAddContact showFromRect:imgAvatar.bounds inView:imgAvatar animated:YES];
    }
}

//  Hiển thị bàn phím
- (void)keyboardWillShow:(NSNotification *)notif {
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

- (void)afterAddAndReloadContactDone {
    [appDelegate showWaiting: NO];
    
    appDelegate._newContact = nil;
    
    [appDelegate.window makeToast:[appDelegate.localization localizedStringForKey:@"Successful"] duration:1.0 position:CSToastPositionCenter];
    [self performSelector:@selector(resetDataAfterAddContact) withObject:nil afterDelay:1.0];
}

- (void)resetDataAfterAddContact{
    appDelegate._dataCrop = nil;
    appDelegate._newContact = [[ContactObject alloc] init];
    appDelegate._newContact._listPhone = [[NSMutableArray alloc] init];
    
    imgAvatar.image = [UIImage imageNamed:@"man_user.png"];
    [tbContents reloadData];
    btnSave.enabled = NO;
}

- (void)showContentWithCurrentLanguage {
    self.title = [appDelegate.localization localizedStringForKey: @"Add contact"];
}

- (BOOL)checkCurrentPhone: (NSString *)phone inList: (NSArray *)listPhone {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_valueStr = %@", phone];
    NSArray *filter = [listPhone filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        return YES;
    }
    return NO;
}

- (void)whenTapOnMainScreen {
    [self.view endEditing: true];
}

- (void)setupUIForView
{
    //  Tap vào màn hình để đóng bàn phím
    tapOnScreen = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTapOnMainScreen)];
    tapOnScreen.delegate = self;
    self.view.userInteractionEnabled = YES;
    [self.view addGestureRecognizer: tapOnScreen];
    
    imgAvatar.layer.borderColor = UIColor.whiteColor.CGColor;
    imgAvatar.layer.borderWidth = 2.0;
    imgAvatar.image = [UIImage imageNamed:@"man_user.png"];
    [imgAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(SCREEN_WIDTH - SPLIT_MASTER_WIDTH);
    }];
    
    [btnAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(imgAvatar);
    }];
    
    [tbContents mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgAvatar.mas_centerY).offset(50.0);
        make.left.right.bottom.equalTo(self.view);
    }];
    tbContents.separatorStyle = UITableViewCellSeparatorStyleNone;
    tbContents.delegate = self;
    tbContents.dataSource = self;
    tbContents.backgroundColor = UIColor.clearColor;
    [self.view bringSubviewToFront: tbContents];
    
    
    //  Footer view
//    viewFooter = [[UIView alloc] init];
//    viewFooter.frame = CGRectMake(0, 0, SCREEN_WIDTH, 100);
//
//    btnCancel = [[UIButton alloc] init];
//    [btnCancel setTitle:[appDelegate.localization localizedStringForKey:@"Cancel"]
//               forState:UIControlStateNormal];
//
//    btnCancel.backgroundColor = [UIColor colorWithRed:(210/255.0) green:(51/255.0)
//                                                 blue:(92/255.0) alpha:1.0];
//    [btnCancel setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
//    btnCancel.clipsToBounds = YES;
//    btnCancel.layer.cornerRadius = 40.0/2;
//    [viewFooter addSubview: btnCancel];
//    [btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(viewFooter.mas_centerX).offset(-10);
//        make.centerY.equalTo(viewFooter.mas_centerY);
//        make.width.mas_equalTo(140.0);
//        make.height.mas_equalTo(40.0);
//    }];
//
//    btnSave = [[UIButton alloc] init];
//    [btnSave setTitle:[appDelegate.localization localizedStringForKey:@"Save"]
//             forState:UIControlStateNormal];
//    btnSave.backgroundColor = [UIColor colorWithRed:(20/255.0) green:(129/255.0)
//                                               blue:(211/255.0) alpha:1.0];
//    [btnSave setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
//    btnSave.clipsToBounds = YES;
//    btnSave.layer.cornerRadius = 40.0/2;
//    [viewFooter addSubview: btnSave];
//    [btnSave mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(viewFooter.mas_centerX).offset(10);
//        make.centerY.equalTo(viewFooter.mas_centerY);
//        make.width.equalTo(btnCancel.mas_width);
//        make.height.equalTo(btnCancel.mas_height);
//    }];
//    [btnSave addTarget:self
//                action:@selector(saveContactPressed:)
//      forControlEvents:UIControlEventTouchUpInside];
//
//    tbContents.tableFooterView = viewFooter;
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

- (void)whenTextfieldFullnameChanged: (UITextField *)textfield {
    //  Save fullname into first name
    appDelegate._newContact._firstName = textfield.text;
    appDelegate._newContact._fullName = textfield.text;
    appDelegate._newContact._lastName = @"";
    
    if (![textfield.text isEqualToString:@""]) {
        btnSave.enabled = YES;
    }else{
        btnSave.enabled = NO;
    }
}

- (void)whenTextfieldChanged: (UITextField *)textfield {
    if (textfield.tag == 100) {
        appDelegate._newContact._email = textfield.text;
    }else if (textfield.tag == 101){
        appDelegate._newContact._company = textfield.text;
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
            
            [cell._iconTypePhone setTitle:@"Mobile" forState:UIControlStateNormal];
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
        return 15.0 + 35.0 + 5.0 + IPAD_HEIGHT_TF + 15.0;
    }
    return 50.0;
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
    [tbContents reloadData];
}

- (void)whenTextfieldPhoneDidChanged: (UITextField *)textfield {
    int row = (int)[textfield tag];
    if (row-NUMBER_ROW_BEFORE >= 0 && row-NUMBER_ROW_BEFORE < appDelegate._newContact._listPhone.count)
    {
        ContactDetailObj *curPhone = [appDelegate._newContact._listPhone objectAtIndex: row];
        curPhone._valueStr = textfield.text;
    }
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

//  Chọn loại phone
- (void)whenSelectTypeForPhone: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[TypePhoneObject class]]) {
        int curIndex = (int)[popupTypePhone tag];
        
        //  Choose phone type for row: Add new phone
        NewPhoneCell *cell = [tbContents cellForRowAtIndexPath:[NSIndexPath indexPathForRow:curIndex inSection:0]];
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
            [tbContents reloadData];
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

- (void)saveContactPressed {
    [self.view endEditing: true];
    
    if ([AppUtils isNullOrEmpty:appDelegate._newContact._firstName] && [AppUtils isNullOrEmpty:appDelegate._newContact._lastName])
    {
        [appDelegate.window makeToast:[appDelegate.localization localizedStringForKey:@"Contact name can not empty!"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    [appDelegate showWaiting: YES];
    
    //  Remove all phone number with value is empty
    for (int iCount=0; iCount<appDelegate._newContact._listPhone.count; iCount++) {
        ContactDetailObj *aPhone = [appDelegate._newContact._listPhone objectAtIndex: iCount];
        if ([aPhone._valueStr isEqualToString: @""]) {
            [appDelegate._newContact._listPhone removeObject: aPhone];
            iCount--;
        }
    }
    [ContactUtils addNewContacts];
    
    appDelegate.needToReloadContactList = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:reloadContactAfterAdd object:nil];
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
        appDelegate.fromImagePicker = YES;
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
        appDelegate.fromImagePicker = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
            pickerController.delegate = self;
            [self presentViewController:pickerController animated:YES completion:nil];
        });
    });
}

- (void)removeAvatar {
    appDelegate._newContact._avatar = @"";
    imgAvatar.image = [UIImage imageNamed:@"man_user.png"];
    appDelegate._dataCrop = nil;
}

#pragma mark - ContactDetailsImagePickerDelegate Functions

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    appDelegate._cropAvatar = image;
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = newBackButton;
    
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
    PECropController.imageCropRect = CGRectMake((width - length) / 2, (height - length) / 2, length, length);
    PECropController.keepingCropAspectRatio = true;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController: PECropController];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [self.navigationController pushViewController:PECropController animated:YES];
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
