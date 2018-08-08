//
//  AcceptContactViewController.m
//  linphone
//
//  Created by Apple on 5/20/17.
//
//

#import "AcceptContactViewController.h"
#import "PhoneObject.h"
#import "TypePhoneObject.h"
#import "TypePhonePopupView.h"
#import "ChooseAvatarPopupView.h"
#import "NewPhoneCell.h"
#import "PhoneMainView.h"
#import "SettingItem.h"
#import "NSDatabase.h"
#import "NSData+Base64.h"

@interface AcceptContactViewController (){
    LinphoneAppDelegate *appDelegate;
    float hHeader;
    float marginX;
    float hTextfield;
    
    float hCell;
    
    TypePhonePopupView *popupTypePhone;
    
    YBHud *waitingHud;
    
    ChooseAvatarPopupView *popupChooseAvatar;
    NSMutableArray *listOptions;
}

@end

@implementation AcceptContactViewController
@synthesize _viewHeader, _iconBack, _lbHeader, _iconDone;
@synthesize _scrollViewContent, _viewInfo, _imgAvatar, _imgChangePicture, _btnAvatar, _lbFirstName, _tfFirstName, _lbBotFirstName, _lbLastName, _tfLastName, _lbBotLastName, _lbCompany, _tfCompany, _lbBotCompany;
@synthesize _lbCloudFoneID, _tfCloudFoneID, _lbBotID, _lbEmail, _tfEmail, _lbBotEmail, _tbPhones, _lbDescription, _tvDescription;

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
    
    [self showAllInformationOfView];
    [self updateAllUIForView];
    
    if (appDelegate._dataCrop != nil) {
        _imgAvatar.image = [UIImage imageWithData: appDelegate._dataCrop];
    }else{
        _imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
    }
    
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)_btnAvatarPressed:(UIButton *)sender {
    [self.view endEditing: YES];
    appDelegate._chooseMyAvatar =  NO;
    if (appDelegate._dataCrop != nil) {
        [self createDataForPopupAvatarWithExistsAvatar: YES];
    }else{
        [self createDataForPopupAvatarWithExistsAvatar: NO];
    }
    popupChooseAvatar = [[ChooseAvatarPopupView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-236)/2, (SCREEN_HEIGHT-listOptions.count*40+6)/2, 236, listOptions.count*40+6)];
    popupChooseAvatar._listOptions = listOptions;
    popupChooseAvatar._optionsTableView.delegate = self;
    popupChooseAvatar._optionsTableView.dataSource = self;
    [popupChooseAvatar._optionsTableView reloadData];
    [popupChooseAvatar showInView:appDelegate.window animated:YES];
}

- (IBAction)_iconBackClicked:(UIButton *)sender {
    [[PhoneMainView instance] popCurrentView];
}

- (IBAction)_iconDoneClicked:(UIButton *)sender {
    if ([[LinphoneManager instance] connectivity] == none) {
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_error_connection] duration:2.0 position:CSToastPositionCenter];
    }else{
        [self.view endEditing: true];
        [waitingHud showInView:self.view animated:YES];
        
        [NSTimer scheduledTimerWithTimeInterval:30.0 target:self
                                       selector:@selector(saveContactTimeOut)
                                       userInfo:nil repeats:NO];
        
        for (int iCount=0; iCount<appDelegate._newContact._listPhone.count; iCount++) {
            PhoneObject *aPhone = [appDelegate._newContact._listPhone objectAtIndex: iCount];
            if ([aPhone._phoneNumber isEqualToString: @""]) {
                [appDelegate._newContact._listPhone removeObject: aPhone];
                iCount--;
            }
        }
        
        [self addContacts];
    }
}

#pragma mark - my functions

//  Time out
- (void)saveContactTimeOut {
    [waitingHud dismissAnimated:YES];
    [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_add_contact_failed] duration:2.0 position:CSToastPositionCenter];
}

//  Tao du lieu cho popup change avatar
- (void)createDataForPopupAvatarWithExistsAvatar: (BOOL)isExists {
    if (listOptions == nil) {
        listOptions = [[NSMutableArray alloc] init];
    }
    [listOptions removeAllObjects];
    
    SettingItem *itemGallery = [[SettingItem alloc] init];
    itemGallery._imageStr = @"gallery.png";
    itemGallery._valueStr = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_gallery];
    [listOptions addObject: itemGallery];
    
    SettingItem *itemCamera = [[SettingItem alloc] init];
    itemCamera._imageStr = @"camera.png";
    itemCamera._valueStr = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_camera];
    [listOptions addObject: itemCamera];
    
    if (isExists) {
        SettingItem *itemRemove = [[SettingItem alloc] init];
        itemRemove._imageStr = @"delete_conversation.png";
        itemRemove._valueStr = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_remove];
        [listOptions addObject: itemRemove];
    }
}

//  Cập nhật vị trí các ui trong view
- (void)updateAllUIForView {
    _tbPhones.frame = CGRectMake(0, _lbBotEmail.frame.origin.y+_lbBotEmail.frame.size.height+20, _scrollViewContent.frame.size.width, appDelegate._newContact._listPhone.count*hCell);
    
    _tvDescription.frame = CGRectMake(_lbBotEmail.frame.origin.x, _tbPhones.frame.origin.y+_tbPhones.frame.size.height+20, _lbBotEmail.frame.size.width, 2.5*hTextfield);
    
    _lbDescription.frame = CGRectMake(_tvDescription.frame.origin.x+5, _tvDescription.frame.origin.y, _scrollViewContent.frame.size.width-10, hTextfield);
    
    _scrollViewContent.contentSize = CGSizeMake(SCREEN_WIDTH, _tvDescription.frame.origin.y+_tvDescription.frame.size.height+15);
}

//  Chọn loại phone
- (void)whenSelectTypeForPhone: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[TypePhoneObject class]]) {
        int curIndex = (int)[popupTypePhone tag];
        PhoneObject *curPhone = [appDelegate._newContact._listPhone objectAtIndex: curIndex];
        [curPhone set_phoneType:[(TypePhoneObject *)object _strType]];
        [_tbPhones reloadData];
    }
}

//  Hiển thị bàn phím
- (void)keyboardDidShow: (NSNotification *) notif{
    CGSize keyboardSize = [[[notif userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.05 animations:^{
        _scrollViewContent.frame = CGRectMake(0, _viewHeader.frame.origin.y+_viewHeader.frame.size.height, _scrollViewContent.frame.size.width, SCREEN_HEIGHT-(appDelegate._hStatus+hHeader+keyboardSize.height));
    }];
}

//  Ẩn bàn phím
- (void)keyboardDidHide: (NSNotification *) notif{
    [UIView animateWithDuration:0.05 animations:^{
        _scrollViewContent.frame = CGRectMake(0, _viewHeader.frame.origin.y+_viewHeader.frame.size.height, _scrollViewContent.frame.size.width, SCREEN_HEIGHT-(appDelegate._hStatus+hHeader));
    }];
}

//  Tap vào màn hình chính để đóng bàn phím
- (void)whenTapOnMainScreen {
    [self.view endEditing: true];
}

- (void)setupUIForView {
    //  Tap vào màn hình để đóng bàn phím
    UITapGestureRecognizer *tapOnScreen = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTapOnMainScreen)];
    [self.view setUserInteractionEnabled: true];
    [self.view addGestureRecognizer: tapOnScreen];
    
    UIColor *textColor = [UIColor colorWithRed:(80/255.0) green:(80/255.0)
                                          blue:(80/255.0) alpha:1.0];
    float wAvatar = 75.0;
    marginX = 50.0;
    hHeader = 42.0;
    hTextfield = 30.0;
    hCell = 45.0;
    
    //  view header
    _viewHeader.frame = CGRectMake(0, 0, SCREEN_WIDTH, hHeader);
    _iconBack.frame = CGRectMake(0, 0, hHeader, hHeader);
    [_iconBack setBackgroundImage:[UIImage imageNamed:@"ic_back_act.png"]
                         forState:UIControlStateHighlighted];
    
    _iconDone.frame = CGRectMake(_viewHeader.frame.size.width-hHeader, 0, hHeader, hHeader);
    [_iconDone setBackgroundImage:[UIImage imageNamed:@"ic_done_act.png"]
                         forState:UIControlStateHighlighted];
    
    _lbHeader.frame = CGRectMake(_iconBack.frame.origin.x+_iconBack.frame.size.width+5, 0, (_viewHeader.frame.size.width-2*_iconBack.frame.size.width-10), hHeader);
    
    //  scroll view content
    _scrollViewContent.frame = CGRectMake(0, _viewHeader.frame.origin.y+_viewHeader.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT-hHeader-appDelegate._hStatus);
    
    //  view info
    float hInfo = 110.0;
    _viewInfo.frame = CGRectMake(0, 0, _scrollViewContent.frame.size.width, hInfo);
    
    _imgAvatar.frame = CGRectMake((hInfo-wAvatar)/2, (hInfo-wAvatar)/2, wAvatar, wAvatar);
    _imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
    _imgAvatar.layer.cornerRadius = wAvatar/2;
    _imgAvatar.clipsToBounds = YES;
    
    _imgChangePicture.frame = CGRectMake(_imgAvatar.frame.origin.x+(wAvatar-25)/2, _imgAvatar.frame.origin.y+wAvatar-25-5, 25, 25);
    _btnAvatar.frame = _imgAvatar.frame;
    
    _tfFirstName.frame = CGRectMake(_imgAvatar.frame.origin.x+_imgAvatar.frame.size.width+7, 5, _scrollViewContent.frame.size.width-(2*_imgAvatar.frame.origin.x+_imgAvatar.frame.size.width+7), hTextfield);
    _tfFirstName.borderStyle = UITextBorderStyleNone;
    [_tfFirstName addTarget:self
                     action:@selector(whenTextfieldDidChanged:)
           forControlEvents:UIControlEventEditingChanged];
    
    _lbFirstName.frame = _tfFirstName.frame;
    _lbFirstName.textColor = textColor;
    
    _lbBotFirstName.frame = CGRectMake(_lbFirstName.frame.origin.x, _lbFirstName.frame.origin.y+_lbFirstName.frame.size.height-1, _lbFirstName.frame.size.width, 1);
    _lbBotFirstName.backgroundColor = [UIColor colorWithRed:(190/255.0) green:(190/255.0)
                                                       blue:(190/255.0) alpha:1.0];
    
    //  lastname
    _tfLastName.frame = CGRectMake(_tfFirstName.frame.origin.x, _tfFirstName.frame.origin.y+_tfFirstName.frame.size.height+5, _tfFirstName.frame.size.width, _tfFirstName.frame.size.height);
    _tfLastName.borderStyle = UITextBorderStyleNone;
    [_tfLastName addTarget:self
                    action:@selector(whenTextfieldDidChanged:)
          forControlEvents:UIControlEventEditingChanged];
    
    _lbLastName.frame = _tfLastName.frame;
    _lbLastName.textColor = textColor;
    
    _lbBotLastName.frame = CGRectMake(_lbLastName.frame.origin.x, _lbLastName.frame.origin.y+_lbLastName.frame.size.height-1, _lbLastName.frame.size.width, 1);
    _lbBotLastName.backgroundColor = [UIColor colorWithRed:(190/255.0) green:(190/255.0)
                                                       blue:(190/255.0) alpha:1.0];
    
    //  company
    _tfCompany.frame = CGRectMake(_tfLastName.frame.origin.x, _tfLastName.frame.origin.y+_tfLastName.frame.size.height+5, _tfLastName.frame.size.width, _tfLastName.frame.size.height);
    _tfCompany.borderStyle = UITextBorderStyleNone;
    [_tfCompany addTarget:self
                   action:@selector(whenTextfieldDidChanged:)
         forControlEvents:UIControlEventEditingChanged];
    
    _lbCompany.frame = _tfCompany.frame;
    _lbCompany.textColor = textColor;
    
    _lbBotCompany.frame = CGRectMake(_lbCompany.frame.origin.x, _lbCompany.frame.origin.y+_lbCompany.frame.size.height-1, _lbCompany.frame.size.width, 1);
    _lbBotCompany.backgroundColor = [UIColor colorWithRed:(190/255.0) green:(190/255.0)
                                                      blue:(190/255.0) alpha:1.0];
    
    //  email
    _tfCloudFoneID.frame = CGRectMake(marginX, _viewInfo.frame.origin.y+_viewInfo.frame.size.height+20, _scrollViewContent.frame.size.width-2*marginX, hTextfield);
    _tfCloudFoneID.borderStyle = UITextBorderStyleNone;
    _tfCloudFoneID.keyboardType = UIKeyboardTypePhonePad;
    [_tfCloudFoneID addTarget:self
                       action:@selector(whenTextfieldDidChanged:)
             forControlEvents:UIControlEventEditingChanged];
    
    _lbCloudFoneID.frame = _tfCloudFoneID.frame;
    _lbCloudFoneID.textColor = textColor;
    
    _lbBotID.frame = CGRectMake(_lbCloudFoneID.frame.origin.x, _lbCloudFoneID.frame.origin.y+_lbCloudFoneID.frame.size.height-1, _lbCloudFoneID.frame.size.width, 1);
    _lbBotID.backgroundColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                                blue:(230/255.0) alpha:1.0];
    
    
    //  email
    _tfEmail.frame = CGRectMake(_tfCloudFoneID.frame.origin.x, _lbBotID.frame.origin.y+_lbBotID.frame.size.height+20, _tfCloudFoneID.frame.size.width, hTextfield);
    _tfEmail.borderStyle = UITextBorderStyleNone;
    _tfEmail.keyboardType = UIKeyboardTypeEmailAddress;
    [_tfEmail addTarget:self
                 action:@selector(whenTextfieldDidChanged:)
       forControlEvents:UIControlEventEditingChanged];
    
    _lbEmail.frame = _tfEmail.frame;
    _lbEmail.textColor = textColor;
    
    _lbBotEmail.frame = CGRectMake(_lbEmail.frame.origin.x, _lbEmail.frame.origin.y+_lbEmail.frame.size.height-1, _lbEmail.frame.size.width, 1);
    _lbBotEmail.backgroundColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                                   blue:(230/255.0) alpha:1.0];
    
    //  email
    _tbPhones.frame = CGRectMake(0, _lbBotEmail.frame.origin.y+_lbBotEmail.frame.size.height+20, _scrollViewContent.frame.size.width, hCell);
    _tbPhones.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tbPhones.delegate = self;
    _tbPhones.dataSource = self;
    _tbPhones.scrollEnabled = NO;
    
    //  description
    _tvDescription.frame = CGRectMake(_lbBotEmail.frame.origin.x, _tbPhones.frame.origin.y+_tbPhones.frame.size.height+20, _lbBotEmail.frame.size.width, 2.5*hTextfield);
    _tvDescription.layer.borderWidth = 1.0;
    _tvDescription.layer.borderColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                                        blue:(230/255.0) alpha:1.0].CGColor;
    _tvDescription.layer.cornerRadius = 0;
    _tvDescription.backgroundColor = UIColor.clearColor;
    _tvDescription.delegate = self;
    
    _lbDescription.frame = CGRectMake(_tvDescription.frame.origin.x+5, _tvDescription.frame.origin.y, _scrollViewContent.frame.size.width-10, hTextfield);
    _lbDescription.textColor = textColor;
    
    _lbFirstName.font = [UIFont fontWithName:HelveticaNeue size:15.0];
    _tfFirstName.font = [UIFont fontWithName:HelveticaNeue size:15.0];
    _lbLastName.font = [UIFont fontWithName:HelveticaNeue size:15.0];
    _tfLastName.font = [UIFont fontWithName:HelveticaNeue size:15.0];
    _lbCompany.font = [UIFont fontWithName:HelveticaNeue size:15.0];
    _tfCompany.font = [UIFont fontWithName:HelveticaNeue size:15.0];
    
    _lbCloudFoneID.font = [UIFont fontWithName:HelveticaNeue size:15.0];
    _tfCloudFoneID.font = [UIFont fontWithName:HelveticaNeue size:15.0];
    _lbEmail.font = [UIFont fontWithName:HelveticaNeue size:15.0];
    _tfEmail.font = [UIFont fontWithName:HelveticaNeue size:15.0];
    _lbDescription.font = [UIFont fontWithName:HelveticaNeue size:15.0];
    _tvDescription.font = [UIFont fontWithName:HelveticaNeue size:15.0];
    
    _scrollViewContent.contentSize = CGSizeMake(SCREEN_WIDTH, _tvDescription.frame.origin.y+_tvDescription.frame.size.height+15);
}

- (void)whenTextfieldDidChanged: (UITextField *)textfield {
    if (textfield == _tfFirstName) {
        if ([textfield.text isEqualToString: @""]) {
            _lbFirstName.hidden = NO;
        }else{
            _lbFirstName.hidden = YES;
        }
        [self checkFirstNameAndLastNameForDoneIcon];
        //  Lưu giá trị first name
        appDelegate._newContact._firstName = _tfFirstName.text;
    }if (textfield == _tfLastName) {
        if ([textfield.text isEqualToString: @""]) {
            _lbLastName.hidden = NO;
        }else{
            _lbLastName.hidden = YES;
        }
        [self checkFirstNameAndLastNameForDoneIcon];
        //  Lưu giá trị last name
        [appDelegate._newContact set_lastName: _tfLastName.text];
    }if (textfield == _tfCompany) {
        if ([textfield.text isEqualToString: @""]) {
            _lbCompany.hidden = NO;
            _iconDone.hidden = YES;
        }else{
            _lbCompany.hidden = YES;
            _iconDone.hidden = NO;
        }
        //  Lưu giá trị company
        [appDelegate._newContact set_company: _tfCompany.text];
    }else if (textfield == _tfCloudFoneID){
        if ([textfield.text isEqualToString: @""]) {
            _lbCloudFoneID.hidden = NO;
        }else{
            _lbCloudFoneID.hidden = YES;
        }
        //  Lưu giá trị cloudfoneID
        appDelegate._newContact._sipPhone = _tfCloudFoneID.text;
    }else if (textfield == _tfEmail){
        if ([textfield.text isEqualToString: @""]) {
            _lbEmail.hidden = NO;
        }else{
            _lbEmail.hidden = YES;
        }
        //  Lưu giá trị email
        appDelegate._newContact._email = _tfEmail.text;
    }
}

//  Hiển thị icon done nếu có firstname hoặc lastname
- (void)checkFirstNameAndLastNameForDoneIcon {
    if ([_tfFirstName.text isEqualToString: @""] && [_tfLastName.text isEqualToString: @""]) {
        _iconDone.hidden = YES;
    }else{
        _iconDone.hidden = NO;
    }
}

- (void)showAllInformationOfView {
    if (appDelegate._newContact._listPhone.count == 0) {
        PhoneObject *aPhone = [[PhoneObject alloc] init];
        [aPhone set_isNew: true];
        [aPhone set_phoneType: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:type_phone_mobile]];
        [aPhone set_phoneNumber: @""];
        [appDelegate._newContact._listPhone addObject: aPhone];
    }
    [_tbPhones reloadData];
    
    //  first name
    if ([appDelegate._newContact._firstName isEqualToString: @""] && [appDelegate._newContact._lastName isEqualToString: @""]) {
        _tfFirstName.text = appDelegate._newContact._sipPhone;
        _lbFirstName.hidden = YES;
    }else{
        _tfFirstName.text = @"";
        _lbFirstName.hidden = NO;
    }
    
    //  last name
    if (![appDelegate._newContact._lastName isEqualToString: @""] && appDelegate._newContact._lastName != nil) {
        _tfLastName.text = appDelegate._newContact._lastName;
        _lbLastName.hidden = YES;
    }else{
        _tfLastName.text = @"";
        _lbLastName.hidden = NO;
    }
    
    //  company
    if (![appDelegate._newContact._company isEqualToString: @""] && appDelegate._newContact._company != nil) {
        _tfCompany.text = appDelegate._newContact._company;
        _lbCompany.hidden = YES;
    }else{
        _tfCompany.text = @"";
        _lbCompany.hidden = NO;
    }
    
    //  cloudfone ID
    _lbCloudFoneID.hidden = YES;
    _tfCloudFoneID.text = appDelegate._newContact._sipPhone;
    _tfCloudFoneID.hidden = NO;
    _tfCloudFoneID.backgroundColor = [UIColor colorWithRed:(210/255.0) green:(210/255.0)
                                                      blue:(210/255.0) alpha:1.0];
    _tfCloudFoneID.leftView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 7, _tfCloudFoneID.frame.size.height)];
    _tfCloudFoneID.leftViewMode = UITextFieldViewModeAlways;
    
    //  email
    if (![appDelegate._newContact._email isEqualToString: @""] && appDelegate._newContact._email != nil) {
        _tfEmail.text = appDelegate._newContact._email;
        _lbEmail.hidden = YES;
    }else{
        _tfEmail.text = @"";
        _lbEmail.hidden = NO;
    }
    _tvDescription.text = @"";
    _lbDescription.hidden = NO;
    
    [self checkFirstNameAndLastNameForDoneIcon];
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
            appDelegate._dataCrop = nil;
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

//  Thêm hoặc xoá số phone
- (void)btnAddPhonePressed: (UIButton *)sender {
    PhoneObject *aPhone = [appDelegate._newContact._listPhone objectAtIndex: (int)sender.tag];
    if (aPhone._isNew) {
        PhoneObject *aPhone = [[PhoneObject alloc] init];
        [aPhone set_isNew: true];
        [aPhone set_phoneType: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:type_phone_mobile]];
        [aPhone set_phoneNumber: @""];
        [appDelegate._newContact._listPhone addObject: aPhone];
    }else{
        [appDelegate._newContact._listPhone removeObjectAtIndex:(int)sender.tag];
    }
    //  Khi thêm mới hoặc xoá thì chỉ có dòng cuối cùng là new
    [self updateStateNewForPhoneList];
    
    [_tbPhones reloadData];
    
    [self updateAllUIForView];
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

- (void)whenTextfieldPhoneDidChanged: (UITextField *)textfield {
    int row = (int)[textfield tag];
    
    PhoneObject *curPhone = [appDelegate._newContact._listPhone objectAtIndex: row];
    [curPhone set_phoneNumber: textfield.text];
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

#pragma mark - ContactDetailsImagePickerDelegate Functions

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    // Crop image trong edits contact
    appDelegate._cropAvatar = image;
    [self dismissViewControllerAnimated:YES completion:^{
        //  [[PhoneMainView instance] changeCurrentView:[CropImageViewController compositeViewDescription] push:TRUE];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//  Thêm mới contact
- (void)addContacts
{
    /*  Leo Kelvin
    // Kiểm tra contact này có tồn tại username và callnexID trùng hay ko. Có thì xử lý
    NSString *strFirstName = [_tfFirstName text];
    if (strFirstName == nil) {
        strFirstName = @"";
    }
    
    NSString *strLastName = [_tfLastName text];
    if (strLastName == nil) {
        strLastName = @"";
    }
    
    NSString *strCompany = [_tfCompany text];
    if (strCompany == nil) {
        strCompany = @"";
    }
    
    NSString *strFullName  = @"";
    if (![strFirstName isEqualToString:@""] && [strLastName isEqualToString:@""]) {
        strFullName = strFirstName;
    }else if ([strFirstName isEqualToString:@""] && ![strLastName isEqualToString:@""]){
        strFullName = strLastName;
    }else{
        strFullName = [NSString stringWithFormat:@"%@ %@", strFirstName, strLastName];
    }
    NSString *fullName = [strFullName lowercaseString];
    
    //  cloudfoneID
    NSString *cloudFoneID = [_tfCloudFoneID text];
    if (cloudFoneID == nil) {
        cloudFoneID = @"";
    }
    appDelegate._newContact._sipPhone = cloudFoneID;
    
    //  email
    NSString *strEmail = [_tfEmail text];
    if (strEmail == nil) {
        strEmail = @"";
    }
    [appDelegate._newContact set_email: strEmail];
    
    NSString *idContactExists = [NSDatabase checkContactExistsInDatabase:fullName andCloudFone:cloudFoneID];
    if (![idContactExists isEqualToString: @""]) {
        NSArray *tmpArr = [[NSArray alloc] initWithArray:appDelegate._newContact._listPhone];
        
        appDelegate._newContact = [NSDatabase getAContactOfDB: [idContactExists intValue]];
        for (int iCount=0; iCount<tmpArr.count; iCount++) {
            PhoneObject *phone = [tmpArr objectAtIndex: iCount];
            if (![self checkPhone:phone existsInList:appDelegate._newContact._listPhone]) {
                [appDelegate._newContact._listPhone addObject: phone];
            }
        }
        
        if (![_tfEmail.text isEqualToString: @""]) {
            [appDelegate._newContact set_email: _tfEmail.text];
        }
        
        
        if (appDelegate._dataCrop != nil) {
            if ([appDelegate._dataCrop respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
                [appDelegate._newContact set_avatar: [appDelegate._dataCrop base64EncodedStringWithOptions: 0]];   // iOS 7+
            } else {
                [appDelegate._newContact set_avatar: [appDelegate._dataCrop base64Encoding]];  // pre iOS7
            }
        }else{
            [appDelegate._newContact set_avatar: @""];
        }
        [NSDatabase updateContactInformation:[idContactExists intValue] andUpdateInfo:appDelegate._newContact];
        [self afterAddContactSuccessfully];
    }else{
        // Add thêm cloudfone id vào list phone
        if (![cloudFoneID isEqualToString: @""]) {
            PhoneObject *cloudPhone = [[PhoneObject alloc] init];
            [cloudPhone set_phoneNumber: cloudFoneID];
            [cloudPhone set_phoneType: type_cloudfone_id];
            
            [appDelegate._newContact._listPhone addObject: cloudPhone];
        }
        
        //  Get id cuối cùng thêm vào từ app
        int idContact = [NSDatabase getLastIDContactFromApp];
        idContact = idContact - 1;
        
        [appDelegate._newContact set_firstName: strFirstName];
        [appDelegate._newContact set_lastName: strLastName];
        [appDelegate._newContact set_fullName: strFullName];
        [appDelegate._newContact set_convertName: [MyFunctions convertUTF8CharacterToCharacter: strFullName]];
        
        [appDelegate._newContact set_nameForSearch: [MyFunctions getNameForSearchOfConvertName: appDelegate._newContact._convertName]];
        [appDelegate._newContact set_id_contact: idContact];
        [appDelegate._newContact set_street: @""];
        [appDelegate._newContact set_city: @""];
        [appDelegate._newContact set_state: @""];
        [appDelegate._newContact set_zip_postal: @""];
        [appDelegate._newContact set_country: @""];
        [appDelegate._newContact set_modify_time: @""];
        [appDelegate._newContact set_modify_int: 0];
        
        if (appDelegate._dataCrop != nil) {
            if ([appDelegate._dataCrop respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
                [appDelegate._newContact set_avatar: [appDelegate._dataCrop base64EncodedStringWithOptions: 0]];   // iOS 7+
            } else {
                [appDelegate._newContact set_avatar: [appDelegate._dataCrop base64Encoding]];  // pre iOS7
            }
        }else{
            [appDelegate._newContact set_avatar: @""];
        }
        
        //  Thêm contact vào database
        BOOL addSuccess = [NSDatabase addContactToCallnexDB: appDelegate._newContact];
        if (addSuccess) {
            // Thêm danh sách số phone cho contact
            [NSDatabase addPhoneOfContactToCallnexDB:appDelegate._newContact._listPhone
                                        withIdContact:idContact];
        }
        [self afterAddContactSuccessfully];
    }   */
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
    // Nếu add từ request gởi đến thì accept
    NSString *meStr = appDelegate.myBuddy.accountName;
    NSString *userStr = [NSString stringWithFormat:@"%@@%@", appDelegate._newContact._sipPhone, xmpp_cloudfone];
    [appDelegate.myBuddy.protocol sendAcceptRequestFromMe:meStr toUser:userStr];
    
    [NSDatabase removeAnUserFromRequestedList: appDelegate._newContact._sipPhone];
    
    [waitingHud dismissAnimated:YES];
    appDelegate._newContact = nil;
    
    [[PhoneMainView instance] popCurrentView];
}

@end
