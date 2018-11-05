//
//  AllContactsViewController.m
//  linphone
//
//  Created by Ei Captain on 6/30/16.
//
//

#import "AllContactsViewController.h"
#import "ContactsViewController.h"
#import "KContactDetailViewController.h"
#import "NewContactViewController.h"
#import "UIImage+GKContact.h"
//  #import "NSDBCallnex.h"

#import "NSData+Base64.h"
#import "ContactCell.h"
#import "ContactObject.h"
#import "ContactDetailObj.h"

@interface AllContactsViewController (){
    BOOL isSearching;
    NSString *stringForCall;
    BOOL isFound;
    BOOL found;
    float hSection;
    
    NSTimer *searchTimer;
    
    BOOL transfer_popup;
    
    UIRefreshControl *refreshControl;
    NSArray *listCharacter;
    
    NSMutableArray *filterContactList;
    UIFont *textFont;
    
    YBHud *waitingHud;
    int pbxContactID;
}

@end

@implementation AllContactsViewController
@synthesize _tbContacts, _lbNoContacts;
@synthesize _searchResults, _contactSections;

- (void)viewDidLoad {
    [super viewDidLoad];
    //  MY CODE HERE
    hSection = 35.0;
    
    listCharacter = [[NSArray alloc] initWithObjects: @"A", @"B", @"C", @"D", @"E", @"F",
                  @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
    
    _contactSections = [[NSMutableDictionary alloc] init];
    
    [self autoLayoutForView];
    
    //  Pull to refresh contact list
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl setTintColor:[UIColor magentaColor]];
    [refreshControl setBackgroundColor:[UIColor whiteColor]];
    
    [refreshControl addTarget:self
                       action:@selector(refreshContactList)
             forControlEvents:UIControlEventValueChanged];
    [_tbContacts addSubview: refreshControl];
    
    //  add waiting view
    waitingHud = [[YBHud alloc] initWithHudType:DGActivityIndicatorAnimationTypeLineScale andText:@""];
    waitingHud.tintColor = [UIColor whiteColor];
    waitingHud.dimAmount = 0.5;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![LinphoneAppDelegate sharedInstance].contactLoaded) {
        [waitingHud showInView:[LinphoneAppDelegate sharedInstance].window animated:YES];
        
        _tbContacts.hidden = YES;
        _lbNoContacts.hidden = YES;
    }else{
        [waitingHud dismissAnimated:YES];
        _tbContacts.hidden = NO;
    }
    
    if ([LinphoneAppDelegate sharedInstance].needToReloadContactList) {
        [_tbContacts reloadData];
        [LinphoneAppDelegate sharedInstance].needToReloadContactList = NO;
    }
    
    //  notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenLoadContactFinish)
                                                 name:finishLoadContacts object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewContact)
                                                 name:addNewContactInContactView object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchContactWithValue:)
                                                 name:@"searchContactWithValue" object:nil];
    //  ---------
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - My Functions

- (void)whenLoadContactFinish {
    [waitingHud dismissAnimated:YES];
    _tbContacts.hidden = NO;
    [_tbContacts reloadData];
}

//  Kéo xuống để refresh lại danh sách
- (void)refreshContactList {
    [_tbContacts reloadData];
    
    // iOs 7 tro len thi set
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        NSMutableAttributedString *tmpStr = [[NSMutableAttributedString alloc] initWithString: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_pull_to_refresh]];
        [tmpStr addAttribute:NSFontAttributeName
                       value:textFont
                       range:NSMakeRange(0, tmpStr.length)];
        [refreshControl setAttributedTitle: tmpStr];
    }
    [refreshControl endRefreshing];
}

- (void)addNewContact {
    [[PhoneMainView instance] changeCurrentView:[NewContactViewController compositeViewDescription] push: true];
}

- (void)autoLayoutForView {
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }else{
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
    }
    
    [_tbContacts mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    _tbContacts.delegate = self;
    _tbContacts.dataSource = self;
    _tbContacts.separatorStyle = UITableViewCellSeparatorStyleNone;
    if ([_tbContacts respondsToSelector:@selector(setSectionIndexColor:)]) {
        _tbContacts.sectionIndexColor = UIColor.grayColor;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            _tbContacts.sectionIndexBackgroundColor = UIColor.whiteColor;
        }
    }
    //  khong co lien he
    _lbNoContacts.font = textFont;
    _lbNoContacts.textColor = UIColor.grayColor;
    _lbNoContacts.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_no_contact];
}

- (void)getSectionsForContactsList: (NSMutableArray *)contactList {
    [_contactSections removeAllObjects];
    
    // Loop through the books and create our keys
    for (ContactObject *contactItem in contactList){
        NSString *c = @"";
        if (contactItem._fullName.length > 1) {
            c = [[contactItem._fullName substringToIndex: 1] uppercaseString];
            c = [AppUtils convertUTF8StringToString: c];
        }
        
        if (![listCharacter containsObject:c]) {
            c = @"z#";
        }
        
        found = NO;
        for (NSString *str in [_contactSections allKeys]){
            if ([str isEqualToString:c]){
                found = YES;
            }
        }
        if (!found){
            [_contactSections setObject:[[NSMutableArray alloc] init] forKey:c];
        }
    }
    
    // Loop again and sort the books into their respective keys
    for (ContactObject *contactItem in contactList){
        NSString *c = @"";
        if (contactItem._fullName.length > 1) {
            c = [[contactItem._fullName substringToIndex: 1] uppercaseString];
            c = [AppUtils convertUTF8StringToString: c];
        }
        if (![listCharacter containsObject:c]) {
            c = @"z#";
        }
        
        [[_contactSections objectForKey: c] addObject:contactItem];
    }
    // Sort each section array
    for (NSString *key in [_contactSections allKeys]){
        [[_contactSections objectForKey:key] sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"_fullName" ascending:YES]]];
    }
}

- (NSString *)subTowString: (NSString *)str1 andString: (NSString *)str2{
    if ([str1 isEqualToString: @""] && [str2 isEqualToString: @""]) {
        return [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Unknown"];
    }else if ([str1 isEqualToString: @""] && ![str2 isEqualToString: @""]){
        return str2;
    }else if (![str1 isEqualToString: @""] && [str2 isEqualToString: @""]){
        return str1;
    }else{
        return [NSString stringWithFormat:@"%@ %@", str1, str2];
    }
}

#pragma mark - TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (![LinphoneAppDelegate sharedInstance].contactLoaded) {
        return 0;
    }
    
    if (isSearching) {
        [self getSectionsForContactsList: _searchResults];
    }else{
        [self getSectionsForContactsList: [LinphoneAppDelegate sharedInstance].listContacts];
    }
    return [[_contactSections allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (![LinphoneAppDelegate sharedInstance].contactLoaded) {
        return 0;
    }
    
    NSString *str = [[[_contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
    return [[_contactSections objectForKey:str] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactObject *contact = [[ContactObject alloc] init];
    NSString *key = [[[_contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section];
    contact = [[_contactSections objectForKey: key] objectAtIndex:indexPath.row];
    
    static NSString *identifier = @"ContactCell";
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ContactCell" owner:self options:nil];
        cell = topLevelObjects[0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Tên contact
    if (contact._fullName != nil) {
        if ([contact._fullName isEqualToString: @""]) {
            cell.name.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Unknown"];
        }else{
            cell.name.text = contact._fullName;
        }
    }
    
    if (contact._avatar != nil && ![contact._avatar isEqualToString:@""] && ![contact._avatar isEqualToString:@"<null>"] && ![contact._avatar isEqualToString:@"(null)"] && ![contact._avatar isEqualToString:@"null"])
    {
        NSData *imageData = [NSData dataFromBase64String:contact._avatar];
        cell.image.image = [UIImage imageWithData: imageData];
    }else {
        NSString *keyAvatar = @"";
        if (contact._lastName != nil && ![contact._lastName isEqualToString:@""]) {
            keyAvatar = [contact._lastName substringToIndex: 1];
        }
        
        if (contact._firstName != nil && ![contact._firstName isEqualToString:@""]) {
            if (![keyAvatar isEqualToString:@""]) {
                keyAvatar = [NSString stringWithFormat:@"%@ %@", keyAvatar, [contact._firstName substringToIndex: 1]];
            }else{
                keyAvatar = [contact._firstName substringToIndex: 1];
            }
        }
        
        UIImage *avatar = [UIImage imageForName:[keyAvatar uppercaseString] size:CGSizeMake(60.0, 60.0)
                                backgroundColor:[UIColor colorWithRed:0.169 green:0.53 blue:0.949 alpha:1.0]
                                      textColor:UIColor.whiteColor
                                           font:nil];
        cell.image.image = avatar;
    }
    
    cell.tag = contact._id_contact;
    cell.phone.text = contact._sipPhone;
    if (![contact._sipPhone isEqualToString:@""] && contact._sipPhone != nil) {
        cell.icCall.hidden = NO;
        [cell.icCall setTitle:contact._sipPhone forState:UIControlStateNormal];
        [cell.icCall addTarget:self
                        action:@selector(onIconCallClicked:)
              forControlEvents:UIControlEventTouchUpInside];
    }else{
        cell.icCall.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactCell *curCell = (ContactCell *)[tableView cellForRowAtIndexPath: indexPath];
    [LinphoneAppDelegate sharedInstance].idContact = (int)[curCell tag];
    
    [[PhoneMainView instance] changeCurrentView:[KContactDetailViewController compositeViewDescription] push: true];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *titleHeader = [[[_contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, hSection)];
    headerView.backgroundColor = [UIColor colorWithRed:(240/255.0) green:(240/255.0)
                                                  blue:(240/255.0) alpha:1.0];
    
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, hSection)];
    descLabel.textColor = [UIColor colorWithRed:(50/255.0) green:(50/255.0)
                                           blue:(50/255.0) alpha:1.0];
    if ([titleHeader isEqualToString:@"z#"]) {
        descLabel.font = [UIFont fontWithName:HelveticaNeue size:20.0];
        descLabel.text = @"#";
    }else{
        descLabel.font = textFont;
        descLabel.text = titleHeader;
    }
    descLabel.backgroundColor = UIColor.clearColor;
    [headerView addSubview: descLabel];
    return headerView;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *tmpArr = [[NSMutableArray alloc] initWithArray: [[_contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    
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
    return hSection;
}

#pragma mark -

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeKeyboard" object:nil];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeKeyboard" object:nil];
}

//  Added by Khai Le on 04/10/2018
- (void)searchContactWithValue: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[NSString class]])
    {
        if ([object isEqualToString:@""]) {
            isSearching = NO;
        }else{
            isSearching = YES;
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self searchPhoneBook: object];
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [_tbContacts reloadData];
            });
        });
    }
}

- (void)searchPhoneBook: (NSString *)strSearch
{
    if (_searchResults == nil) {
        _searchResults = [[NSMutableArray alloc] init];
    }
    
    NSMutableArray *tmpList = [[NSMutableArray alloc] initWithArray: [LinphoneAppDelegate sharedInstance].listContacts];
    
    //  search theo ten va sipPhone
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_fullName contains[cd] %@ OR _sipPhone contains[cd] %@", strSearch, strSearch];
    [_searchResults removeAllObjects];
    NSArray *filter = [tmpList filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        [_searchResults addObjectsFromArray: filter];
        [tmpList removeObjectsInArray: filter];
    }
    
    predicate = [NSPredicate predicateWithFormat:@"_valueStr contains[cd] %@", strSearch];
    for (int iCount=0; iCount<tmpList.count; iCount++) {
        ContactObject *contact = [tmpList objectAtIndex: iCount];
        NSArray *filter = [contact._listPhone filteredArrayUsingPredicate: predicate];
        if (filter.count > 0) {
            [_searchResults addObject: contact];
        }
    }
}

- (void)onIconCallClicked: (UIButton *)sender {
    if (sender.currentTitle != nil && ![sender.currentTitle isEqualToString:@""]) {
        NSString *phoneNumber = [AppUtils removeAllSpecialInString: sender.currentTitle];
        if (![phoneNumber isEqualToString:@""]) {
            [SipUtils makeCallWithPhoneNumber: phoneNumber];
        }
    }
}

@end
