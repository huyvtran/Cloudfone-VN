//
//  PBXContactsViewController.m
//  linphone
//
//  Created by Apple on 5/11/17.
//
//

#import "PBXContactsViewController.h"
#import "NewContactViewController.h"
#import "PBXContactPopupView.h"
#import "JSONKit.h"
#import "NSDatabase.h"
#import "PBXContact.h"
#import "PBXContactTableCell.h"
#import "DeleteContactPBXPopupView.h"
#import "PhoneMainView.h"
#import "UIImage+GKContact.h"

@interface PBXContactsViewController (){
    float hHeader;
    float hAppStatus;
    float hSync;
    BOOL isSearching;
    
    float hCell;
    NSTimer *searchTimer;
    
    YBHud *waitingHud;
    UIFont *textFont;
    float hView;
    
    NSMutableArray *listSearch;
    
    WebServices *webService;
}

@end

@implementation PBXContactsViewController
@synthesize _viewSearch, _imgBgSearch, _iconSearch, _tfSearch, _lbSearch, _iconClear, _lbContacts, _tbContacts, _viewSync, _lbSync, _imgSync, _lbSepa;

- (void)viewDidLoad {
    [super viewDidLoad];
    //  my code here
    
    webService = [[WebServices alloc] init];
    webService.delegate = self;
    
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    [self showContentWithCurrentLanguage];
    _tfSearch.text = @"";
    _iconClear.hidden = YES;
    _lbSearch.hidden = NO;
    isSearching = NO;
    
    if (listSearch == nil) {
        listSearch = [[NSMutableArray alloc] init];
    }
    [listSearch removeAllObjects];
    
    if (![LinphoneAppDelegate sharedInstance].contactLoaded) {
        if (waitingHud == nil) {
            //  add waiting view
            waitingHud = [[YBHud alloc] initWithHudType:DGActivityIndicatorAnimationTypeLineScale andText:@""];
            waitingHud.tintColor = [UIColor whiteColor];
            waitingHud.dimAmount = 0.5;
        }
        [waitingHud showInView:self.view animated:YES];
        
        _tbContacts.hidden = YES;
        _lbContacts.hidden = YES;
    }else{
        [waitingHud dismissAnimated:YES];
        
        if ([LinphoneAppDelegate sharedInstance].pbxContacts.count > 0) {
            _tbContacts.hidden = NO;
            _lbContacts.hidden = YES;
            [_tbContacts reloadData];
        }else{
            _tbContacts.hidden = YES;
            _lbContacts.hidden = NO;
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)_iconClearClicked:(UIButton *)sender {
    [self.view endEditing: true];
    [_tfSearch setText: @""];
    [_lbSearch setHidden: false];
    [_iconClear setHidden: true];
    isSearching = NO;
    
    if ([LinphoneAppDelegate sharedInstance].pbxContacts.count > 0) {
        [_lbContacts setHidden: true];
        [_tbContacts setHidden: false];
        [_tbContacts reloadData];
    }else{
        [_lbContacts setHidden: false];
        [_tbContacts setHidden: true];
    }
}

#pragma mark - my functions

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

- (void)showContentWithCurrentLanguage {
    [_lbSearch setText:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_search_contact]];
    [_lbContacts setText:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_no_contact]];
}

//  setup thông tin cho tableview
- (void)setupUIForView {
    float hSearch = 60.0;
    
    float wIconSync;
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
        hSync = 55.0;
        wIconSync = 30.0;
    }else{
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
        hSync = 45.0;
        wIconSync = 26.0;
    }
    
    hCell = 65.0;
    
    hView = SCREEN_HEIGHT - ([LinphoneAppDelegate sharedInstance]._hStatus + [LinphoneAppDelegate sharedInstance]._hHeader + [LinphoneAppDelegate sharedInstance]._hTabbar);
    
    //  view search
    [_viewSearch setFrame: CGRectMake(0, 0, SCREEN_WIDTH, hSearch)];
    [_imgBgSearch setFrame: CGRectMake(0, 0, _viewSearch.frame.size.width, _viewSearch.frame.size.height)];
    [_iconSearch setFrame: CGRectMake(10, (hSearch-30)/2, 30, 30)];
    [_tfSearch setFrame: CGRectMake(_iconSearch.frame.origin.x+_iconSearch.frame.size.width+5, _iconSearch.frame.origin.y, _viewSearch.frame.size.width-(3*_iconSearch.frame.origin.x+_iconSearch.frame.size.width), _iconSearch.frame.size.height)];
    [_tfSearch setFont: textFont];
    [_tfSearch setBorderStyle: UITextBorderStyleNone];
    
    [_tfSearch addTarget:self
                  action:@selector(onSearchContactChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    [_lbSearch setFrame: _tfSearch.frame];
    [_lbSearch setFont: textFont];
    
    [_iconClear setFrame: CGRectMake(_tfSearch.frame.origin.x+_tfSearch.frame.size.width-_tfSearch.frame.size.height, _tfSearch.frame.origin.y, _tfSearch.frame.size.height, _tfSearch.frame.size.height)];
    [_iconClear setHidden: true];
    
    //  view sync
    [_viewSync setFrame: CGRectMake(10, hView-hSync+5, SCREEN_WIDTH-20, hSync-10)];
    [_viewSync.layer setCornerRadius: 5.0];
    
    [_viewSync setUserInteractionEnabled: true];
    UITapGestureRecognizer *tapToSync = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickSyncPBXContacts)];
    [_viewSync addGestureRecognizer: tapToSync];
    
    [_lbSepa setFrame: CGRectMake(0, 0, _viewSync.frame.size.width, 1)];
    
    CGSize textSize = [AppUtils getSizeWithText:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_sync_pbx_contact]
                                          withFont:textFont];
    
    float marginX = (_viewSync.frame.size.width - (30+10+textSize.width))/2;
    [_imgSync setFrame: CGRectMake(marginX, (_viewSync.frame.size.height-30)/2, 30, 30)];
    [_imgSync setImage:[UIImage imageNamed:@"icon_phone_sync.png"]];
    
    [_lbSync setFrame: CGRectMake(_imgSync.frame.origin.x+_imgSync.frame.size.width+10, _imgSync.frame.origin.y, textSize.width, _imgSync.frame.size.height)];
    [_lbSync setText: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_sync_pbx_contact]];
    [_lbSync setFont: textFont];
    [_lbSync setTextColor:[UIColor whiteColor]];
    
    
    //  table contacts
    [_tbContacts setFrame: CGRectMake(0, _viewSearch.frame.origin.y+_viewSearch.frame.size.height, SCREEN_WIDTH, hView-hSearch-hSync)];
    [_tbContacts setDelegate:self];
    [_tbContacts setDataSource:self];
    [_tbContacts setSeparatorStyle: UITableViewCellSeparatorStyleNone];
    
    //  khong co lien he
    [_lbContacts setFrame: _tbContacts.frame];
    [_lbContacts setFont:textFont];
    [_lbContacts setTextColor:[UIColor grayColor]];
}

//  search contact
- (void)onSearchContactChange: (UITextField *)textField {
    if (textField.text.length == 0) {
        [_iconClear setHidden: true];
        [_lbSearch setHidden: false];
        [_tbContacts reloadData];
        isSearching = NO;
        
    }else{
        [_iconClear setHidden: false];
        [_lbSearch setHidden: true];
        isSearching = YES;
        
        [searchTimer invalidate];
        searchTimer = nil;
        searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self
                                                     selector:@selector(startSearchPBXContacts)
                                                     userInfo:nil repeats:NO];
    }
}

//  Search phonebook
- (void)startSearchPBXContacts {
    [listSearch removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_name CONTAINS[cd] %@ OR _number CONTAINS[cd] %@", _tfSearch.text, _tfSearch.text];
    NSArray *filter = [[LinphoneAppDelegate sharedInstance].pbxContacts filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        [listSearch addObjectsFromArray: filter];
    }
    
    if (listSearch.count > 0) {
        [_lbContacts setHidden: true];
        [_tbContacts setHidden: false];
        [_tbContacts reloadData];
    }else{
        [_lbContacts setHidden: false];
        [_tbContacts setHidden: true];
    }
}

//  Click sync pbx contact
- (void)clickSyncPBXContacts {
    [_viewSync setBackgroundColor:[UIColor colorWithRed:(24/255.0) green:(185/255.0)
                                                   blue:(153/255.0) alpha:1.0]];
    
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
                [[LinphoneAppDelegate sharedInstance] set_isSyncing: true];
                [self startSyncPBXContacts];
                [self getPBXContactsWithServerName: service];
            }else{
                [[LinphoneAppDelegate sharedInstance].window makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_contact_syncing]
                                     duration:2.0 position:CSToastPositionCenter];
            }
        }
    }
}

- (void)startSyncPBXContacts {
    CABasicAnimation *spin;
    spin = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    [spin setFromValue:@0.0f];
    [spin setToValue:@(2*M_PI)];
    [spin setDuration:2.5];
    [spin setRepeatCount: HUGE_VALF];   // HUGE_VALF means infinite repeatCount
    
    [_imgSync.layer addAnimation:spin forKey:@"Spin"];
    [_lbSync setText: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_syncing]];
}

- (void)getPBXContactsWithServerName: (NSString *)serverName
{
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:AuthUser forKey:@"AuthUser"];
    [jsonDict setObject:AuthKey forKey:@"AuthKey"];
    [jsonDict setObject:serverName forKey:@"ServerName"];
    [webService callWebServiceWithLink:getServerContacts withParams:jsonDict];
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

//  Thông báo kết thúc sync contacts
- (void)syncContactsSuccessfully
{
    [waitingHud dismissAnimated: YES];
    
    [[LinphoneAppDelegate sharedInstance] set_isSyncing: false];
    [_imgSync.layer removeAllAnimations];
    [_lbSync setText: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_sync_pbx_contact]];
    
    [[LinphoneAppDelegate sharedInstance].window makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_successfully]
                         duration:2.0 position:CSToastPositionCenter];
    
    if ([LinphoneAppDelegate sharedInstance].pbxContacts.count == 0) {
        [_tbContacts setHidden: true];
        [_lbContacts setHidden: false];
    }else{
        [_tbContacts setHidden: false];
        [_lbContacts setHidden: true];
    }
    [_tbContacts reloadData];
}

#pragma mark - UITableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (isSearching) {
        return [listSearch count];
    }else{
        NSSortDescriptor *sorter = [[NSSortDescriptor alloc]
                                     initWithKey:@"_name"
                                     ascending:YES
                                     selector:@selector(localizedCaseInsensitiveCompare:)];
        NSArray *sortDescriptors = [NSArray arrayWithObject: sorter];
        [[LinphoneAppDelegate sharedInstance].pbxContacts sortUsingDescriptors:sortDescriptors];
        
        return [[LinphoneAppDelegate sharedInstance].pbxContacts count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"PBXContactTableCell";
    PBXContactTableCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PBXContactTableCell" owner:self options:nil];
        cell = topLevelObjects[0];
    }
    
    PBXContact *contact;
    if (isSearching) {
        contact = [listSearch objectAtIndex:indexPath.row];
    }else{
        contact = [[LinphoneAppDelegate sharedInstance].pbxContacts objectAtIndex:indexPath.row];
    }
    
    // Tên contact
    if (contact._name != nil && ![contact._name isKindOfClass:[NSNull class]]) {
        cell._lbName.text = contact._name;
    }else{
        cell._lbName.text = @"";
    }
    
    if (contact._number != nil && ![contact._number isKindOfClass:[NSNull class]]) {
        cell._lbPhone.text = contact._number;
    }else{
        cell._lbPhone.text = @"";
    }
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, _tbContacts.frame.size.width, hCell);
    [cell updateUIForCell];
    
    if ([contact._name isEqualToString:@""]) {
        cell._imgAvatar.image = [UIImage imageForName:@"#" size: CGSizeMake(60, 60)];
    }else{
        NSString *firstChar = [contact._name substringToIndex:1];
        cell._imgAvatar.image = [UIImage imageForName:[firstChar uppercaseString] size: CGSizeMake(60, 60)];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PBXContact *contact;
    if (isSearching) {
        contact = [listSearch objectAtIndex:indexPath.row];
    }else{
        contact = [[LinphoneAppDelegate sharedInstance].pbxContacts objectAtIndex:indexPath.row];
    }
    [self callPBXWithNumber: contact._number];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return hCell;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self.view endEditing: true];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing: true];
}

- (void)callPBXWithNumber: (NSString *)pbxNumber {
    LinphoneAddress *addr = linphone_core_interpret_url(LC, pbxNumber.UTF8String);
    [LinphoneManager.instance call:addr];
    if (addr)
        linphone_address_destroy(addr);
    
    OutgoingCallViewController *controller = VIEW(OutgoingCallViewController);
    if (controller != nil) {
        [controller setPhoneNumberForView: pbxNumber];
    }
    [[PhoneMainView instance] changeCurrentView:[OutgoingCallViewController compositeViewDescription] push:TRUE];
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

#pragma mark - WebServices delegate
- (void)failedToCallWebService:(NSString *)link andError:(NSString *)error {
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

@end
