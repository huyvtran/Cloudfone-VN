//
//  ContactsViewController.m
//  linphone
//
//  Created by Ei Captain on 6/30/16.
//
//

#import "ContactsViewController.h"
#import "AllContactsViewController.h"
#import "PBXContactsViewController.h"
#import "JSONKit.h"
#import "StatusBarView.h"
#import "TabBarView.h"
#import "NSDatabase.h"
#import "PBXContact.h"

@interface ContactsViewController (){
    AllContactsViewController *allContactsVC;
    PBXContactsViewController *pbxContactsVC;
    int currentView;
    float hIcon;
    
    NSTimer *searchTimer;
    WebServices *webService;
    
    UIActivityIndicatorView *icWaiting;
    
}
@end

@implementation ContactsViewController
@synthesize _pageViewController, _viewHeader, _iconAddNew, _iconAll, _iconPBX, _iconSyncPBXContact, _tfSearch, imgBackground, _icClearSearch;
@synthesize _listSyncContact, _phoneForSync;

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
    if (compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:nil
                                                                 tabBar:TabBarView.class
                                                               sideMenu:nil
                                                             fullscreen:false
                                                         isLeftFragment:YES
                                                           fragmentWith:nil];
    }
    return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
    return self.class.compositeViewDescription;
}

#pragma mark - My controller

- (void)viewDidLoad {
    [super viewDidLoad];
    //  MY CODE HERE
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
    
    self.view.backgroundColor = UIColor.clearColor;
    
    webService = [[WebServices alloc] init];
    webService.delegate = self;
    
    [self autoLayoutForMainView];
    
    currentView = eContactPBX;
    [self updateStateIconWithView: currentView];
    
    _pageViewController.view.backgroundColor = UIColor.clearColor;
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    
    pbxContactsVC = [[PBXContactsViewController alloc] init];
    allContactsVC = [[AllContactsViewController alloc] init];
    
    NSArray *viewControllers = [NSArray arrayWithObject:pbxContactsVC];
    [_pageViewController setViewControllers:viewControllers
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:true completion:nil];
    _pageViewController.view.layer.shadowColor = UIColor.clearColor.CGColor;
    _pageViewController.view.layer.borderWidth = 0.0;
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    
    [_pageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    //  _pageViewController.view.frame = CGRectMake(0, [LinphoneAppDelegate sharedInstance]._hHeader, SCREEN_WIDTH, SCREEN_HEIGHT-[LinphoneAppDelegate sharedInstance]._hStatus-[LinphoneAppDelegate sharedInstance]._hHeader-[LinphoneAppDelegate sharedInstance]._hTabbar);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Tắt màn hình cảm biến
    UIDevice *device = [UIDevice currentDevice];
    device.proximityMonitoringEnabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeKeyboard)
                                                 name:@"closeKeyboard" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    [AppUtils addCornerRadiusTopLeftAndBottomLeftForButton:_iconPBX radius:(hIcon-10)/2 withColor:[UIColor colorWithRed:0.169 green:0.53 blue:0.949 alpha:1.0] border:2.0];
    [AppUtils addCornerRadiusTopRightAndBottomRightForButton:_iconAll radius:(hIcon-10)/2 withColor:[UIColor colorWithRed:0.169 green:0.53 blue:0.949 alpha:1.0] border:2.0];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark – UIPageViewControllerDelegate Method

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if (viewController == pbxContactsVC){
        currentView = eContactPBX;
        [self updateStateIconWithView: currentView];
        return nil;
    }else{
        currentView = eContactAll;
        [self updateStateIconWithView: currentView];
        return pbxContactsVC;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if (viewController == pbxContactsVC){
        currentView = eContactPBX;
        [self updateStateIconWithView: currentView];
        return allContactsVC;
    }else{
        currentView = eContactAll;
        [self updateStateIconWithView: currentView];
        return nil;
    }
}

- (IBAction)_iconAddNewClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:addNewContactInContactView
                                                        object:nil];
}

- (IBAction)_iconAllClicked:(id)sender {
    currentView = eContactAll;
    [self updateStateIconWithView:currentView];
    [_pageViewController setViewControllers: @[allContactsVC]
                                  direction: UIPageViewControllerNavigationDirectionReverse
                                   animated: false completion: nil];
}

- (IBAction)_iconPBXClicked:(UIButton *)sender {
    currentView = eContactPBX;
    [self updateStateIconWithView:currentView];
    [_pageViewController setViewControllers: @[pbxContactsVC]
                                  direction: UIPageViewControllerNavigationDirectionForward
                                   animated: false completion: nil];
}

- (IBAction)_iconSyncPBXContactClicked:(UIButton *)sender {
    [self startSyncPBXContactsForAccount];
}

- (IBAction)_icClearSearchClicked:(UIButton *)sender {
}

//  setup trạng thái cho các button
- (void)autoLayoutForMainView {
    hIcon = [LinphoneAppDelegate sharedInstance]._hRegistrationState - [LinphoneAppDelegate sharedInstance]._hStatus;
    _viewHeader.backgroundColor = UIColor.greenColor;
    [_viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo([LinphoneAppDelegate sharedInstance]._hRegistrationState + 50);
    }];
    
    [imgBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(_viewHeader);
    }];
    
    _iconSyncPBXContact.backgroundColor = UIColor.clearColor;
    [_iconSyncPBXContact mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewHeader).offset(10);
        make.top.equalTo(_viewHeader).offset([LinphoneAppDelegate sharedInstance]._hStatus+5);
        make.width.height.mas_equalTo(hIcon-10);
    }];
    
    [_iconAddNew mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_viewHeader.mas_right).offset(-10);
        make.top.equalTo(_iconSyncPBXContact.mas_top);
        make.width.equalTo(_iconSyncPBXContact.mas_width);
        make.height.equalTo(_iconSyncPBXContact.mas_height);
    }];
    
    _iconPBX.backgroundColor = [UIColor colorWithRed:0.169 green:0.53 blue:0.949 alpha:1.0];
    [_iconPBX setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"PBX"] forState:UIControlStateNormal];
    [_iconPBX setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_iconPBX mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_viewHeader.mas_centerX);
        make.centerY.equalTo(_iconAddNew.mas_centerY);
        make.height.equalTo(_iconAddNew.mas_height);
        make.width.mas_equalTo(SCREEN_WIDTH/4);
    }];
    
    _iconAll.backgroundColor = UIColor.clearColor;
    [_iconAll setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Contacts"] forState:UIControlStateNormal];
    [_iconAll setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_iconAll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewHeader.mas_centerX);
        make.top.bottom.equalTo(_iconPBX);
        make.width.equalTo(_iconPBX.mas_width);
        make.height.equalTo(_iconPBX.mas_height);
    }];
    
    float hTextfield = 32.0;
    _tfSearch.backgroundColor = [UIColor colorWithRed:(16/255.0) green:(59/255.0)
                                                 blue:(123/255.0) alpha:0.8];
    _tfSearch.font = [UIFont systemFontOfSize: 16.0];
    _tfSearch.borderStyle = UITextBorderStyleNone;
    _tfSearch.layer.cornerRadius = hTextfield/2;
    _tfSearch.clipsToBounds = YES;
    _tfSearch.textColor = UIColor.whiteColor;
    if ([self._tfSearch respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        _tfSearch.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Type name or phone number"] attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:(230/255.0) green:(230/255.0) blue:(230/255.0) alpha:1.0]}];
    } else {
        _tfSearch.placeholder = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Type name or phone number"];
    }
    [_tfSearch addTarget:self
                  action:@selector(onSearchContactChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    UIView *pLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 0, hTextfield, hTextfield)];
    _tfSearch.leftView = pLeft;
    _tfSearch.leftViewMode = UITextFieldViewModeAlways;
    
    [_tfSearch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_iconAll.mas_bottom).offset(5+(50-hTextfield)/2);
        make.left.equalTo(_viewHeader).offset(30.0);
        make.right.equalTo(_viewHeader).offset(-30.0);
        make.height.mas_equalTo(hTextfield);
    }];
    
    UIImageView *imgSearch = [[UIImageView alloc] init];
    imgSearch.image = [UIImage imageNamed:@"ic_search"];
    [_tfSearch addSubview: imgSearch];
    [imgSearch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(_tfSearch);
        make.width.mas_equalTo(hTextfield);
    }];
    
    _icClearSearch.backgroundColor = UIColor.clearColor;
    [_icClearSearch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(_tfSearch);
        make.width.mas_equalTo(hTextfield);
    }];
    
    icWaiting = [[UIActivityIndicatorView alloc] init];
    icWaiting.backgroundColor = UIColor.whiteColor;
    icWaiting.alpha = 0.5;
    icWaiting.hidden = YES;
    [self.view addSubview: icWaiting];
    [icWaiting mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
}

//  Cập nhật trạng thái của các icon trên header
- (void)updateStateIconWithView: (int)view
{
    if (view == eContactAll){
        _iconSyncPBXContact.hidden = YES;
        _iconAddNew.hidden = NO;
        [self setSelected: YES forButton: _iconAll];
        [self setSelected: NO forButton: _iconPBX];
    }else{
        _iconSyncPBXContact.hidden = NO;
        _iconAddNew.hidden = YES;
        [self setSelected: NO forButton: _iconAll];
        [self setSelected: YES forButton: _iconPBX];
    }
}

- (void)setSelected: (BOOL)selected forButton: (UIButton *)button {
    if (selected) {
        button.backgroundColor = [UIColor colorWithRed:0.169 green:0.53 blue:0.949 alpha:1.0];
    }else{
        button.backgroundColor = UIColor.clearColor;
    }
}

//  Added by Khai Le on 04/10/2018
- (void)onSearchContactChange: (UITextField *)textField {
    [searchTimer invalidate];
    searchTimer = nil;
    searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self
                                                 selector:@selector(startSearchPhoneBook)
                                                 userInfo:nil repeats:NO];
}

- (void)startSearchPhoneBook {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"searchContactWithValue" object:_tfSearch.text];
}

- (void)closeKeyboard {
    [self.view endEditing: YES];
}

- (void)startSyncPBXContactsForAccount {
    NSString *service = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_ID];
    if ([service isKindOfClass:[NSNull class]] || service == nil || [service isEqualToString: @""]) {
        [[LinphoneAppDelegate sharedInstance].window makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_not_id_pbx]
                                                      duration:2.0 position:CSToastPositionCenter];
    }else{
        if (![LinphoneAppDelegate sharedInstance]._internetActive) {
            [[LinphoneAppDelegate sharedInstance].window makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_please_check_your_connection]
                                                          duration:2.0 position:CSToastPositionCenter];
        }else{
            if (![LinphoneAppDelegate sharedInstance]._threadDatabase.open) {
                [NSDatabase connectDatabaseForSyncContact];
            }
            
            if (![LinphoneAppDelegate sharedInstance]._isSyncing) {
                icWaiting.hidden = NO;
                [icWaiting startAnimating];
                
                [LinphoneAppDelegate sharedInstance]._isSyncing = YES;
                [self startAnimationForSyncButton: _iconSyncPBXContact];
                
                [self getPBXContactsWithServerName: service];
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//                    [self getPBXContactsWithServerName: service];
//                });
            }else{
                [[LinphoneAppDelegate sharedInstance].window makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"PBX contacts is being synchronized!"] duration:2.0 position:CSToastPositionCenter];
            }
        }
    }
}

#pragma mark - WebServices delegate
- (void)failedToCallWebService:(NSString *)link andError:(NSString *)error {
    [icWaiting stopAnimating];
    icWaiting.hidden = YES;
    
    if ([link isEqualToString:getServerContacts]) {
        [[LinphoneAppDelegate sharedInstance].window makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_error] duration:2.0 position:CSToastPositionCenter];
    }
}

- (void)successfulToCallWebService:(NSString *)link withData:(NSDictionary *)data {
    if ([link isEqualToString:getServerContacts]) {
        if (data != nil && [data isKindOfClass:[NSArray class]]) {
            [self whenStartSyncPBXContacts: (NSArray *)data];
        }
    }
}

- (void)receivedResponeCode:(NSString *)link withCode:(int)responeCode {
    
}

//  Xử lý pbx contacts trả về
- (void)whenStartSyncPBXContacts: (NSArray *)data
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self savePBXContactInPhoneBook: data];
        [self getListPhoneWithCurrentContactPBX];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self syncContactsSuccessfully];
        });
    });
}

- (void)startAnimationForSyncButton: (UIButton *)sender {
    CABasicAnimation *spin;
    spin = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    [spin setFromValue:@0.0f];
    [spin setToValue:@(2*M_PI)];
    [spin setDuration:2.5];
    [spin setRepeatCount: HUGE_VALF];   // HUGE_VALF means infinite repeatCount
    
    [sender.layer addAnimation:spin forKey:@"Spin"];
}

- (void)getPBXContactsWithServerName: (NSString *)serverName
{
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:AuthUser forKey:@"AuthUser"];
    [jsonDict setObject:AuthKey forKey:@"AuthKey"];
    [jsonDict setObject:serverName forKey:@"ServerName"];
    [webService callWebServiceWithLink:getServerContacts withParams:jsonDict];
}

- (void)savePBXContactInPhoneBook: (NSArray *)pbxData
{
    NSString *pbxContactName = @"";
    
    ABAddressBookRef addressListBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    NSArray *arrayOfAllPeople = (__bridge  NSArray *) ABAddressBookCopyArrayOfAllPeople(addressListBook);
    NSUInteger peopleCounter = 0;
    
    BOOL exists = NO;
    
    for (peopleCounter = 0; peopleCounter < [arrayOfAllPeople count]; peopleCounter++)
    {
        ABRecordRef aPerson = (__bridge ABRecordRef)[arrayOfAllPeople objectAtIndex:peopleCounter];
        NSString *sipNumber = (__bridge NSString *)ABRecordCopyValue(aPerson, kABPersonFirstNamePhoneticProperty);
        if (sipNumber != nil && [sipNumber isEqualToString: keySyncPBX]) {
            pbxContactName = [AppUtils getNameOfContact: aPerson];
            exists = YES;
            
            ABRecordSetValue(aPerson, kABPersonPhoneProperty, nil, nil);
            BOOL isSaved = ABAddressBookSave (addressListBook, nil);
            if (isSaved) {
                NSLog(@"Update thanh cong");
            }
            // Phone number
            ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
            for (int iCount=0; iCount<pbxData.count; iCount++) {
                NSDictionary *dict = [pbxData objectAtIndex: iCount];
                NSString *name = [dict objectForKey:@"name"];
                NSString *number = [dict objectForKey:@"number"];
                
                ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(number), (__bridge  CFStringRef)name, NULL);
            }
            
            ABRecordSetValue(aPerson, kABPersonPhoneProperty, multiPhone,nil);
            isSaved = ABAddressBookSave (addressListBook, nil);
            if (isSaved) {
                NSLog(@"Update thanh cong");
            }
        }
    }
    if (!exists) {
        [self addContactsWithData:pbxData withContactName:nameContactSyncPBX andCompany:nameSyncCompany];
    }
}

//  Thêm mới contact
- (void)addContactsWithData: (NSArray *)pbxData withContactName: (NSString *)contactName andCompany: (NSString *)company
{
    NSString *strEmail = @"";
    
    NSString *strAvatar = @"";
    UIImage *logoImage = [UIImage imageNamed:@"logo"];
    NSData *avatarData = UIImagePNGRepresentation(logoImage);
    if (avatarData != nil) {
        if ([avatarData respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
            strAvatar = [avatarData base64EncodedStringWithOptions: 0];
        } else {
            strAvatar = [avatarData base64Encoding];
        }
    }
    
    ABRecordRef aRecord = ABPersonCreate();
    CFErrorRef  anError = NULL;
    
    // Lưu thông tin
    ABRecordSetValue(aRecord, kABPersonFirstNameProperty, (__bridge CFTypeRef)(contactName), &anError);
    ABRecordSetValue(aRecord, kABPersonLastNameProperty, (__bridge CFTypeRef)(@""), &anError);
    ABRecordSetValue(aRecord, kABPersonOrganizationProperty, (__bridge CFTypeRef)(company), &anError);
    ABRecordSetValue(aRecord, kABPersonFirstNamePhoneticProperty, (__bridge CFTypeRef)(keySyncPBX), &anError);
    
    ABMutableMultiValueRef email = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(email, (__bridge CFTypeRef)(strEmail), CFSTR("email"), NULL);
    ABRecordSetValue(aRecord, kABPersonEmailProperty, email, &anError);
    
    if (avatarData != nil) {
        CFDataRef cfdata = CFDataCreate(NULL,[avatarData bytes], [avatarData length]);
        ABPersonSetImageData(aRecord, cfdata, &anError);
    }
    
    // Phone number
    //  NSMutableArray *listPhone = [[NSMutableArray alloc] init];
    ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    
    for (int iCount=0; iCount<pbxData.count; iCount++) {
        NSDictionary *dict = [pbxData objectAtIndex: iCount];
        NSString *name = [dict objectForKey:@"name"];
        NSString *number = [dict objectForKey:@"number"];
        
        ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(number), (__bridge  CFStringRef)name, NULL);
    }
    
    ABRecordSetValue(aRecord, kABPersonPhoneProperty, multiPhone,nil);
    CFRelease(multiPhone);
    
    // Instant Message
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"SIP", (NSString*)kABPersonInstantMessageServiceKey,
                                @"", (NSString*)kABPersonInstantMessageUsernameKey, nil];
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
}

- (void)getListPhoneWithCurrentContactPBX {
    if ([LinphoneAppDelegate sharedInstance].pbxContacts == nil) {
        [LinphoneAppDelegate sharedInstance].pbxContacts = [[NSMutableArray alloc] init];
    }
    [[LinphoneAppDelegate sharedInstance].pbxContacts removeAllObjects];
    
    ABAddressBookRef addressListBook = ABAddressBookCreateWithOptions(NULL, NULL);
    NSArray *arrayOfAllPeople = (__bridge  NSArray *) ABAddressBookCopyArrayOfAllPeople(addressListBook);
    for (int peopleCounter = (int)arrayOfAllPeople.count-1; peopleCounter >= 0; peopleCounter--)
    {
        ABRecordRef aPerson = (__bridge ABRecordRef)[arrayOfAllPeople objectAtIndex:peopleCounter];
        
        ABRecordID idContact = ABRecordGetRecordID(aPerson);
        NSLog(@"-----id: %d", idContact);
        
        NSString *sipNumber = (__bridge NSString *)ABRecordCopyValue(aPerson, kABPersonFirstNamePhoneticProperty);
        if (sipNumber != nil && [sipNumber isEqualToString: keySyncPBX])
        {
            ABMultiValueRef phones = ABRecordCopyValue(aPerson, kABPersonPhoneProperty);
            if (ABMultiValueGetCount(phones) > 0)
            {
                for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
                {
                    CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, j);
                    CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(phones, j);
                    
                    NSString *curPhoneValue = (__bridge NSString *)phoneNumberRef;
                    curPhoneValue = [[curPhoneValue componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
                    
                    NSString *nameValue = (__bridge NSString *)locLabel;
                    
                    if (curPhoneValue != nil && nameValue != nil) {
                        PBXContact *aContact = [[PBXContact alloc] init];
                        aContact._name = nameValue;
                        aContact._number = curPhoneValue;
                        
                        [[LinphoneAppDelegate sharedInstance].pbxContacts addObject: aContact];
                    }
                }
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:idContact]
                                                          forKey:@"PBX_ID_CONTACT"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }
}

//  Thông báo kết thúc sync contacts
- (void)syncContactsSuccessfully
{
    [icWaiting stopAnimating];
    icWaiting.hidden = YES;
    
    [[LinphoneAppDelegate sharedInstance] set_isSyncing: false];
    [_iconSyncPBXContact.layer removeAllAnimations];
    
    [[LinphoneAppDelegate sharedInstance].window makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_successfully]
                                                  duration:2.0 position:CSToastPositionCenter];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"searchContactWithValue" object:_tfSearch.text];
}

@end
