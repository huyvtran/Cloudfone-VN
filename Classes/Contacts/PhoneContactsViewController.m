//
//  PhoneContactsViewController.m
//  linphone
//
//  Created by lam quang quan on 6/24/19.
//

#import "PhoneContactsViewController.h"
#import "PhoneBookDetailViewController.h"
#import "NewContactViewController.h"
#import "AddressBook/ABPerson.h"
#import "ContactCell.h"

@interface PhoneContactsViewController ()<UITableViewDelegate, UITableViewDataSource>{
    BOOL isSearching;
    NSMutableArray *searchs;
    NSMutableDictionary *contactsInfo;
    NSArray *listCharacter;
}

@end

@implementation PhoneContactsViewController
@synthesize tbContacts;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    listCharacter = [[NSArray alloc] initWithObjects: @"A", @"B", @"C", @"D", @"E", @"F",
                     @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
    
    [self setupUIForView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [WriteLogsUtils writeForGoToScreen: @"AllContactsViewController"];
    
    if (contactsInfo == nil) {
        contactsInfo = [[NSMutableDictionary alloc] init];
    }else{
        [contactsInfo removeAllObjects];
    }
    
    [tbContacts reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewContact)
                                                 name:addNewContactInContactView object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startSearchContactWithValue:)
                                                 name:searchContactWithValue object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)setupUIForView {
    [tbContacts mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    tbContacts.delegate = self;
    tbContacts.dataSource = self;
    tbContacts.separatorStyle = UITableViewCellSeparatorStyleNone;
    if ([tbContacts respondsToSelector:@selector(setSectionIndexColor:)]) {
        tbContacts.sectionIndexColor = UIColor.grayColor;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            tbContacts.sectionIndexBackgroundColor = UIColor.whiteColor;
        }
    }
}

- (void)addNewContact {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__]
                         toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    [[PhoneMainView instance] changeCurrentView:[NewContactViewController compositeViewDescription] push: true];
}

- (NSString *)getFirstPhoneFromContact: (ABRecordRef)aPerson
{
    ABMultiValueRef phones = ABRecordCopyValue(aPerson, kABPersonPhoneProperty);
    if (ABMultiValueGetCount(phones) > 0)
    {
        for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
        {
            CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, j);
            NSString *phoneNumber = (__bridge NSString *)phoneNumberRef;
            phoneNumber = [AppUtils removeAllSpecialInString: phoneNumber];
            return phoneNumber;
        }
    }
    return @"";
}

- (void)startSearchContactWithValue: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[NSString class]])
    {
        if ([object isEqualToString:@""]) {
            isSearching = NO;
            [tbContacts reloadData];
            
        }else{
            isSearching = YES;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [self searchPhoneBook: object];
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [tbContacts reloadData];
                });
            });
        }
    }
}

- (void)searchPhoneBook: (NSString *)strSearch
{
    if (searchs == nil) {
        searchs = [[NSMutableArray alloc] init];
    }else{
        [searchs removeAllObjects];
    }
    
    NSArray *arrayOfAllPeople = (__bridge  NSArray *) ABAddressBookCopyArrayOfAllPeople([LinphoneAppDelegate sharedInstance].addressListBook);
    for (int i=0; i<[arrayOfAllPeople count]; i++ )
    {
        ABRecordRef person = (__bridge ABRecordRef)[arrayOfAllPeople objectAtIndex:i];
        
        NSString *fullname = [ContactUtils getFullNameFromContact: person];
        NSString *convertName = [AppUtils convertUTF8CharacterToCharacter: fullname];
        
        if ([convertName rangeOfString: strSearch options: NSCaseInsensitiveSearch].location != NSNotFound) {
            [searchs addObject: (__bridge id _Nonnull)(person)];
            continue;
        }
        
        ABMutableMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        CFIndex phoneNumberCount = ABMultiValueGetCount( phoneNumbers );
        
        for (int k=0; k<phoneNumberCount; k++ )
        {
            CFStringRef phoneNumberValue = ABMultiValueCopyValueAtIndex( phoneNumbers, k );
            NSString *phoneNumber = (__bridge NSString *)phoneNumberValue;
            phoneNumber = [AppUtils removeAllSpecialInString: phoneNumber];
            if ([phoneNumber containsString: strSearch]) {
                [searchs addObject: (__bridge id _Nonnull)(person)];
                break;
            }
        }
    }
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (isSearching) {
        [self getSectionsForContactsList: searchs];
    }else{
        [self getSectionsForContactsList: [LinphoneAppDelegate sharedInstance].contacts];
    }
    return [contactsInfo allKeys].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [[[contactsInfo allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
    return [[contactsInfo objectForKey:key] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [[[contactsInfo allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section];
    ABRecordRef person = (__bridge ABRecordRef)[[contactsInfo objectForKey: key] objectAtIndex:indexPath.row];
    
    static NSString *identifier = @"ContactCell";
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ContactCell" owner:self options:nil];
        cell = topLevelObjects[0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *fullname = [ContactUtils getFullNameFromContact: person];
    if (fullname != nil && ![fullname isEqualToString:@""] ) {
        cell.name.text = fullname;
    }else{
        
    }
    
    
    UIImage *avatar = [ContactUtils getAvatarFromContact: person];
    cell.image.image = avatar;
    
    NSString *firstPhone = [ContactUtils getFirstPhoneFromContact: person];
    cell.phone.text = firstPhone;
    if (firstPhone != nil && ![firstPhone isEqualToString:@""]) {
        cell.icCall.hidden = FALSE;
        [cell.icCall setTitle:firstPhone forState:UIControlStateNormal];
        [cell.icCall addTarget:self
                        action:@selector(onIconCallClicked:)
              forControlEvents:UIControlEventTouchUpInside];
    }else{
        cell.icCall.hidden = TRUE;
    }
    
    return cell;
}

- (void)onIconCallClicked: (UIButton *)sender
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] phone number = %@", __FUNCTION__, sender.currentTitle] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    if (![AppUtils isNullOrEmpty: sender.currentTitle]) {
        NSString *phoneNumber = [AppUtils removeAllSpecialInString: sender.currentTitle];
        if (phoneNumber != nil && ![phoneNumber isEqualToString:@""]) {
            [SipUtils makeCallWithPhoneNumber: phoneNumber];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [[[contactsInfo allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section];
    ABRecordRef person = (__bridge ABRecordRef)[[contactsInfo objectForKey: key] objectAtIndex:indexPath.row];
    int contactId = ABRecordGetRecordID(person);
    [LinphoneAppDelegate sharedInstance].idContact = contactId;
    [[PhoneMainView instance] changeCurrentView:[PhoneBookDetailViewController compositeViewDescription] push: true];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *key = [[[contactsInfo allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];;

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 35.0)];
    headerView.backgroundColor = [UIColor colorWithRed:(240/255.0) green:(240/255.0) blue:(240/255.0) alpha:1.0];

    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, headerView.frame.size.width-20, headerView.frame.size.height)];
    descLabel.textColor = [UIColor colorWithRed:(50/255.0) green:(50/255.0) blue:(50/255.0) alpha:1.0];
    if ([key isEqualToString:@"z#"]) {
        descLabel.text = @"#";
    }else{
        descLabel.text = key;
    }
    descLabel.backgroundColor = UIColor.clearColor;
    descLabel.font = [UIFont fontWithName:MYRIADPRO_BOLD size:20.0];
    [headerView addSubview: descLabel];
    return headerView;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *tmpArr = [[NSMutableArray alloc] initWithArray: [[contactsInfo allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];

    int iCount = 0;
    while (iCount < tmpArr.count) {
        NSString *title = [tmpArr objectAtIndex: iCount];
        if ([title isEqualToString:@"z#"]) {
            [tmpArr replaceObjectAtIndex:iCount withObject:@"#"];
            break;
        }
        iCount++;
    }
    return tmpArr;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 35.0;
}

- (void)getSectionsForContactsList: (NSMutableArray *)contactList {
    [contactsInfo removeAllObjects];
    
    // Loop through the books and create our keys
    for (int index=0; index<contactList.count; index++) {
        ABRecordRef person = (__bridge ABRecordRef)[contactList objectAtIndex: index];
        NSString *fullname = [ContactUtils getFullNameFromContact: person];
        
        NSString *c = @"";
        if (fullname.length > 1) {
            c = [[fullname substringToIndex: 1] uppercaseString];
            c = [AppUtils convertUTF8StringToString: c];
        }
        
        if (![listCharacter containsObject:c]) {
            c = @"z#";
        }
        
        if (![[contactsInfo allKeys] containsObject: c]) {
            NSMutableArray *list = [[NSMutableArray alloc] init];
            [list addObject: (__bridge id _Nonnull)(person)];
            [contactsInfo setObject:list forKey:c];
            
        }else{
            NSMutableArray *list = [contactsInfo objectForKey: c];
            [list addObject: (__bridge id _Nonnull)(person)];
            [contactsInfo setObject:list forKey:c];
        }
    }
}

@end
