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
#import "PhoneMainView.h"
//  Leo Kelvin
//  #import "PopupFriendRequest.h"
//  #import "NSDBCallnex.h"

#import "NSData+Base64.h"

#import "ContactCell.h"
#import "ContactNormalCell.h"
#import "ContactObject.h"
#import "ContactDetailObj.h"

@interface AllContactsViewController (){
    BOOL isSearching;
    NSString *stringForCall;
    BOOL isFound;
    BOOL found;
    float hCell;
    float hSection;
    
    NSTimer *searchTimer;
    
    BOOL transfer_popup;
    
    UIRefreshControl *refreshControl;
    //  Leo Kelvin
    //  PopupFriendRequest *requestPopupView;
    NSArray *listCharacter;
    
    NSMutableArray *filterContactList;
    UIFont *textFont;
    
    YBHud *waitingHud;
    int pbxContactID;
}

@end

@implementation AllContactsViewController
@synthesize _iconClear, _tfSearch, _tbContacts, _viewSearch, _lbSearch, _imgBgSearch, _iconSearch, _lbNoContacts;
@synthesize _searchResults, _contactSections;

- (void)viewDidLoad {
    [super viewDidLoad];
    //  MY CODE HERE
    hCell = 60.0;
    hSection = 25.0;
    
    listCharacter = [[NSArray alloc] initWithObjects: @"A", @"B", @"C", @"D", @"E", @"F",
                  @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
    
    _contactSections = [[NSMutableDictionary alloc] init];
    
    [self setupUIForView];
    
    //  Kéo xuống để refresh lại list
    
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
    
    [self showContentWithCurrentLanguage];
    
    if (![LinphoneAppDelegate sharedInstance].contactLoaded) {
        [waitingHud showInView:[LinphoneAppDelegate sharedInstance].window animated:YES];
        
        _tbContacts.hidden = YES;
        _lbNoContacts.hidden = YES;
    }else{
        [waitingHud dismissAnimated:YES];
        _tbContacts.hidden = NO;
        
        if ([_tfSearch.text isEqualToString:@""]) {
            _iconClear.hidden = YES;
            isSearching = NO;
            
            if ([LinphoneAppDelegate sharedInstance].listContacts.count > 0) {
                _lbSearch.hidden = YES;
            }else{
                _lbSearch.hidden = NO;
            }
            [_tbContacts reloadData];
        }else{
            _iconClear.hidden = NO;
            _lbSearch.hidden = YES;
            isSearching = YES;
            
            [self startSearchPhoneBook];
        }
    }
    
    //  notifications
    /*  Leo Kelvin
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableScrolledForTableView:)
                                                 name:k11EnableScrolledForTableView object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenAcceptSendRequestToUser)
                                                 name:k11AcceptSendRequestToUser object:nil];
    */
    //  Add notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenLoadContactFinish)
                                                 name:finishLoadContacts object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewContact)
                                                 name:addNewContactInContactView object:nil];
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

- (IBAction)_iconClearClicked:(id)sender {
    isSearching = false;
    _tfSearch.text = @"";
    [_tfSearch endEditing: true];
    _iconClear.hidden = YES;
    _lbSearch.hidden = NO;
    [_tbContacts reloadData];
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

- (void)showContentWithCurrentLanguage {
    _lbSearch.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_search_contact];
}

- (void)addNewContact {
    [[PhoneMainView instance] changeCurrentView:[NewContactViewController compositeViewDescription] push: true];
}

- (void)setupUIForView {
    float hSearch = 60.0;
    
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }else{
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
    }
    
    //  view search
    _viewSearch.frame = CGRectMake(0, 0, SCREEN_WIDTH, hSearch);
    _imgBgSearch.frame = CGRectMake(0, 0, _viewSearch.frame.size.width, _viewSearch.frame.size.height);
    _iconSearch.frame = CGRectMake(10, (hSearch-30)/2, 30, 30);
    _tfSearch.frame = CGRectMake(_iconSearch.frame.origin.x+_iconSearch.frame.size.width+5, _iconSearch.frame.origin.y, _viewSearch.frame.size.width-(3*_iconSearch.frame.origin.x+_iconSearch.frame.size.width), _iconSearch.frame.size.height);
    
    _tfSearch.font = textFont;
    _tfSearch.borderStyle = UITextBorderStyleNone;
    [_tfSearch addTarget:self
                  action:@selector(onSearchContactChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    _lbSearch.frame = _tfSearch.frame;
    _lbSearch.font = textFont;
    
    _iconClear.frame = CGRectMake(_tfSearch.frame.origin.x+_tfSearch.frame.size.width-_tfSearch.frame.size.height, _tfSearch.frame.origin.y, _tfSearch.frame.size.height, _tfSearch.frame.size.height);
    _iconClear.hidden = YES;
    
    float hView = SCREEN_HEIGHT - ([LinphoneAppDelegate sharedInstance]._hStatus + [LinphoneAppDelegate sharedInstance]._hHeader + [LinphoneAppDelegate sharedInstance]._hTabbar);
    _tbContacts.frame = CGRectMake(0, _viewSearch.frame.origin.y+_viewSearch.frame.size.height, SCREEN_WIDTH, hView-hSearch);
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

- (void)enableScrolledForTableView: (NSNotification *)notif{
    id object = [notif object];
    if ([object isKindOfClass:[NSNumber class]]) {
        int value = [object intValue];
        if (value == 1) {
            _tbContacts.scrollEnabled = YES;
        }else{
            _tbContacts.scrollEnabled = NO;
        }
    }
}

//  Sự kiện call
- (void)onCallInCallnex {
    if (stringForCall.length > 0) {
        
    }
}

//  search contact
- (void)onSearchContactChange: (UITextField *)textField {
    if (textField.text.length == 0) {
        isSearching = false;
        _iconClear.hidden = YES;
        _lbSearch.hidden = NO;
        [_tbContacts reloadData];
    }else{
        _iconClear.hidden = NO;
        _lbSearch.hidden = YES;
        
        isSearching = true;
        
        [searchTimer invalidate];
        searchTimer = nil;
        searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self
                                                     selector:@selector(startSearchPhoneBook)
                                                     userInfo:nil repeats:NO];
    }
}

- (void)startSearchPhoneBook {
    NSString *strSearch = _tfSearch.text;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self searchPhoneBook: strSearch];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [_tbContacts reloadData];
        });
    });
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

//  Show popup nhập lời mời kết bạn
- (void)onclickSendRequestToUser: (UIButton *)sender {
    
}

- (void)btnSendRequestPressed: (UIButton *)sender {
    
}

//  Nhập lời mời kết bạn và nhấn request
- (void)whenAcceptSendRequestToUser {
    if ([[[PhoneMainView instance] currentView] isEqual:[ContactsViewController compositeViewDescription]]) {
        
    }
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
        return [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_unknown];
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
    
    if (contact._sipPhone != nil && ![contact._sipPhone isKindOfClass:[NSNull class]] && ![contact._sipPhone isEqualToString:@""])
    {
        static NSString *identifier = @"ContactCell";
        ContactCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ContactCell" owner:self options:nil];
            cell = topLevelObjects[0];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, _tbContacts.frame.size.width, hCell);
        [cell setupUIForCell];
        
        // Tên contact
        if (contact._fullName != nil) {
            if ([contact._fullName isEqualToString: @""]) {
                cell.name.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_unknown];
            }else{
                cell.name.text = contact._fullName;
            }
        }
        [cell.btnCallnex setBackgroundImage:[UIImage imageNamed:@"ic_offline.png"]
                                   forState:UIControlStateNormal];
        
        /*  Leo Kelvin
        if (![LinphoneAppDelegate sharedInstance].xmppStream.isConnected) {
            [cell.btnCallnex setHidden: true];
            [cell.phone setText: contact._cloudFoneID];
        }else{
            [cell.btnCallnex setHidden: false];
            
            // Trạng thái online offline của user
            NSArray *statusArr = [AppFunctions getStatusOfUser: contact._cloudFoneID];
            int status = [[statusArr objectAtIndex: 1] intValue];
            NSString *statusStr = [statusArr objectAtIndex: 0];
            
            switch (status) {
                case -1:{
                    [cell.btnCallnex setEnabled: true];
                    [cell.btnCallnex addTarget:self
                                        action:@selector(onclickSendRequestToUser:)
                              forControlEvents:UIControlEventTouchUpInside];
                    [cell.btnCallnex setBackgroundImage:[UIImage imageNamed:@"add_new_callnex_contact.png"]
                                               forState:UIControlStateNormal];
                    break;
                }
                case kOTRBuddyStatusOffline:{
                    [cell.btnCallnex setEnabled: false];
                    [cell.btnCallnex setBackgroundImage:[UIImage imageNamed:@"ic_offline.png"]
                                               forState:UIControlStateNormal];
                    break;
                }
                default:{
                    [cell.btnCallnex setEnabled: false];
                    [cell.btnCallnex setBackgroundImage:[UIImage imageNamed:@"ic_online.png"]
                                               forState:UIControlStateNormal];
                    break;
                }
            }
            [cell.phone setText: statusStr];
        }   */
        
        if (contact._avatar != nil && ![contact._avatar isEqualToString:@""] && ![contact._avatar isEqualToString:@"<null>"] && ![contact._avatar isEqualToString:@"(null)"] && ![contact._avatar isEqualToString:@"null"])
        {
            NSData *imageData = [NSData dataFromBase64String:contact._avatar];
            cell.image.image = [UIImage imageWithData: imageData];
        }else {
            UIImage *avatar = [UIImage imageForName:[key uppercaseString] size: CGSizeMake(60, 60)];
            cell.image.image = avatar;
        }
        
        cell.tag = contact._id_contact;
        cell.phone.text = contact._sipPhone;
        
        return cell;
    }else{
        static NSString *cellIdentifier = @"ContactNormalCell";
        ContactNormalCell *contactCell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
        if (contactCell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ContactNormalCell" owner:self options:nil];
            contactCell = topLevelObjects[0];
        }
        [contactCell setSelectionStyle: UITableViewCellSelectionStyleNone];
        [contactCell setFrame: CGRectMake(contactCell.frame.origin.x, contactCell.frame.origin.y, _tbContacts.frame.size.width, hCell)];
        [contactCell setupUIForCell];
        
        // Tên contact
        if (![contact._fullName isEqualToString:@""]) {
            contactCell._contactName.text = contact._fullName;
        }else{
            if (contact._listPhone.count > 0) {
                ContactDetailObj *firstPhone = [contact._listPhone firstObject];
                if (firstPhone != nil && [firstPhone isKindOfClass:[ContactDetailObj class]]) {
                    contactCell._contactName.text = firstPhone._valueStr;
                }
            }
        }
        
        if (contact._avatar != nil && ![contact._avatar isEqualToString:@""] && ![contact._avatar isEqualToString:@"<null>"] && ![contact._avatar isEqualToString:@"(null)"] && ![contact._avatar isEqualToString:@"null"])
        {
            NSData *imageData = [NSData dataFromBase64String:contact._avatar];
            contactCell._contactAvatar.image = [UIImage imageWithData: imageData];
        }else {
            UIImage *avatar;
            if ([key isEqualToString:@"z#"]) {
                avatar = [UIImage imageForName:@"#" size: CGSizeMake(60, 60)];
            }else{
                /*
                avatar = [UIImage imageForName:[key uppercaseString] size:CGSizeMake(60, 60)
                               backgroundColor:[AppUtils randomColorWithAlpha:1.0]
                                     textColor:UIColor.whiteColor font:nil];
                */
                avatar = [UIImage imageForName:[key uppercaseString] size: CGSizeMake(60, 60)];
            }
            //  contactCell._contactAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
            contactCell._contactAvatar.image = avatar;
        }
        contactCell.tag = contact._id_contact;
        return contactCell;
    }
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
    return hCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return hSection;
}

#pragma mark -

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing: true];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self.view endEditing: true];
}

@end
