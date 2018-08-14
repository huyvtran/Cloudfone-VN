//
//  SipContactsViewController.m
//  linphone
//
//  Created by admin on 11/7/17.
//
//

#import "SipContactsViewController.h"
#import "KContactDetailViewController.h"
#import "NewContactViewController.h"
#import "RequestHeaderView.h"
#import "ContactCell.h"
#import "FastAddressBook.h"
#import "ContactObject.h"
#import "NSData+Base64.h"
#import "PhoneMainView.h"
#import "UIImage+GKContact.h"
#import "NSDatabase.h"

@interface SipContactsViewController (){
    UIFont *textFont;
    float hSync;
    float hRequest;
    
    RequestHeaderView *viewRequest;
    
    float hCell;
    float hSection;
    
    BOOL isFound;
    BOOL found;
    NSArray *listCharacter;
    
    BOOL isSearching;
    
    NSTimer *searchTimer;
    YBHud *waitingHud;
    NSTimer *timeout;
    int numVCard;
    int curVCard;
    BOOL isSyncing;
}

@end

@implementation SipContactsViewController
@synthesize _viewSearch, _iconSearch, _imgBgSearch, _tfSearch, _lbSearch, _iconClear, _tbContacts, _lbNoContacts;
@synthesize _viewSync, _imgSync, _lbSync;
@synthesize _contactSections, _searchResults;

- (void)viewDidLoad {
    [super viewDidLoad];
    //  MY CODE HERE
    
    //  add waiting view
    waitingHud = [[YBHud alloc] initWithHudType:DGActivityIndicatorAnimationTypeLineScale andText:@""];
    waitingHud.tintColor = [UIColor whiteColor];
    waitingHud.dimAmount = 0.5;
    
    hCell = 60.0;
    hSection = 25.0;
    listCharacter = [[NSArray alloc] initWithObjects: @"A", @"B", @"C", @"D", @"E", @"F",
                     @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
    
    _contactSections = [[NSMutableDictionary alloc] init];
    
    //  tableview
    [self setupUIForView];
    [self createHeaderForTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [self showContentWithCurrentLanguage];
    
    numVCard = 0;
    curVCard = 0;
    _tfSearch.text = @"";
    _iconClear.hidden = YES;
    _lbSearch.hidden = YES;

    isSearching = false;
    
    if (![LinphoneAppDelegate sharedInstance].contactLoaded) {
        [waitingHud showInView:[LinphoneAppDelegate sharedInstance].window animated:YES];
        
        _tbContacts.hidden = YES;
        _lbNoContacts.hidden = YES;
    }else{
        [waitingHud dismissAnimated:YES];
        
        _tbContacts.hidden = NO;
        [_tbContacts reloadData];
    }
    
    //  Add Observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenLoadContactFinish)
                                                 name:finishLoadContacts object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewContact)
                                                 name:addNewContactInContactView object:nil];
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

#pragma mark - my functions

- (void)addNewContact {
    [[PhoneMainView instance] changeCurrentView:[NewContactViewController compositeViewDescription] push: true];
}

- (void)showContentWithCurrentLanguage {
    _lbSearch.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_search_contact];
    _lbSync.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_sync_xmpp];
    _lbNoContacts.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_no_contact];
}

- (void)whenLoadContactFinish {
    [waitingHud dismissAnimated:YES];
    
    if ([LinphoneAppDelegate sharedInstance].sipContacts.count == 0) {
        _tbContacts.hidden = YES;
        _lbNoContacts.hidden = NO;
    }else{
        _tbContacts.hidden = NO;
        _lbNoContacts.hidden = YES;
        [_tbContacts reloadData];
    }
}

//  Add view request kết bạn
- (void)createHeaderForTableView {
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"RequestHeaderView" owner:nil options:nil];
    for(id currentObject in subviewArray){
        if ([currentObject isKindOfClass:[RequestHeaderView class]]) {
            viewRequest = (RequestHeaderView *) currentObject;
            [viewRequest setupUIForCell];
            break;
        }
    }
    viewRequest._lbNotifications.hidden = YES;
    viewRequest._lbTitle.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_list_friend_accept];
    viewRequest.frame = CGRectMake(0, _viewSearch.frame.origin.y+_viewSearch.frame.size.height, _viewSearch.frame.size.width, hRequest);
    [viewRequest updateUIForView];
    viewRequest._lbTitle.font = textFont;
    viewRequest._lbNotifications.font = textFont;
    viewRequest.backgroundColor = [UIColor whiteColor];
    [self.view addSubview: viewRequest];
}

//  search contact
- (void)onSearchContactChange: (UITextField *)textField
{
    if (textField.text.length == 0) {
        isSearching = NO;
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self searchPhoneBook];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [_tbContacts reloadData];
        });
    });
}

- (void)searchPhoneBook {
    if (_searchResults == nil) {
        _searchResults = [[NSMutableArray alloc] init];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_fullName contains[cd] %@ OR _sipPhone contains[cd] %@",_tfSearch.text, _tfSearch.text];
    [_searchResults removeAllObjects];
    [_searchResults addObjectsFromArray:[[LinphoneAppDelegate sharedInstance].sipContacts filteredArrayUsingPredicate:predicate]];
}

//  setup thông tin cho tableview
- (void)setupUIForView
{
    float wIconSync;
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
        hSync = 55.0;
        wIconSync = 30.0;
        hRequest = 60.0;
    }else{
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
        hSync = 45.0;
        wIconSync = 26.0;
        hRequest = 60.0;
    }
    
    float hSearch = 60.0;
    float hView = SCREEN_HEIGHT - ([LinphoneAppDelegate sharedInstance]._hStatus + [LinphoneAppDelegate sharedInstance]._hHeader + [LinphoneAppDelegate sharedInstance]._hTabbar);
    
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
    _lbSearch.text = @"";
    
    _iconClear.frame = CGRectMake(_tfSearch.frame.origin.x+_tfSearch.frame.size.width-_tfSearch.frame.size.height, _tfSearch.frame.origin.y, _tfSearch.frame.size.height, _tfSearch.frame.size.height);
    _iconClear.hidden = YES;
    
    //  view sync
    _viewSync.frame = CGRectMake(10, hView-hSync+5, SCREEN_WIDTH-20, hSync-10);
    _viewSync.layer.cornerRadius = 5.0;
    
    _lbSync.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_sync_xmpp];
    _lbSync.font = textFont;
    [_lbSync sizeToFit];
    
    float tmpX = (_viewSync.frame.size.width-(wIconSync+5.0+_lbSync.frame.size.width))/2;
    _imgSync.frame = CGRectMake(tmpX, (_viewSync.frame.size.height-wIconSync)/2, wIconSync, wIconSync);
    _lbSync.frame = CGRectMake(_imgSync.frame.origin.x+_imgSync.frame.size.width+5.0, 0, _lbSync.frame.size.width, _viewSync.frame.size.height);
    
    //  table contacts
    _tbContacts.frame = CGRectMake(0, _viewSearch.frame.origin.y+_viewSearch.frame.size.height+hRequest, SCREEN_WIDTH, hView-hSearch-hSync-hRequest);
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
    _lbNoContacts.frame = _tbContacts.frame;
    _lbNoContacts.font = textFont;
    _lbNoContacts.textColor = UIColor.grayColor;
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
        [self getSectionsForContactsList: [LinphoneAppDelegate sharedInstance].sipContacts];
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
    static NSString *identifier = @"ContactCell";
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ContactCell" owner:self options:nil];
        cell = topLevelObjects[0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, _tbContacts.frame.size.width, hCell);
    [cell setupUIForCell];
    
    NSString *key = [[[_contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section];
    ContactObject *contact = [[_contactSections objectForKey:key] objectAtIndex:indexPath.row];
    
    // Tên contact
    if ([contact._fullName isEqualToString:@""]) {
        cell.name.text = contact._sipPhone;
    }else{
        cell.name.text = contact._fullName;
    }
    
    if (![contact._sipPhone isEqualToString:@""]) {
        cell.btnCallnex.hidden = NO;
        [cell.btnCallnex setBackgroundImage:[UIImage imageNamed:@"ic_offline.png"]
                                   forState:UIControlStateNormal];
        
        cell.btnCallnex.enabled = YES;
        [cell.btnCallnex setBackgroundImage:[UIImage imageNamed:@"add_new_callnex_contact.png"]
                                   forState:UIControlStateNormal];
        cell.phone.text = contact._sipPhone;
    }
    
    [cell.btnCallnex setTag: contact._id_contact];
    if (contact._avatar != nil && ![contact._avatar isEqualToString:@""] && ![contact._avatar isEqualToString:@"<null>"] && ![contact._avatar isEqualToString:@"(null)"] && ![contact._avatar isEqualToString:@"null"])
    {
        NSData *imageData = [NSData dataFromBase64String:contact._avatar];
        cell.image.image = [UIImage imageWithData: imageData];
    }else {
        UIImage *avatar = [UIImage imageForName:[key uppercaseString] size: CGSizeMake(60, 60)];
        cell.image.image = avatar;
    }
    cell.tag = contact._id_contact;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactCell *curCell = (ContactCell *)[tableView cellForRowAtIndexPath: indexPath];
    [[LinphoneAppDelegate sharedInstance] setIdContact:(int)[curCell tag]];
    
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
    if ([titleHeader isEqualToString:@"*"]) {
        descLabel.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:20.0];
    }else{
        descLabel.font = textFont;
    }
    descLabel.text = titleHeader;
    descLabel.backgroundColor = UIColor.clearColor;
    [headerView addSubview: descLabel];
    return headerView;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *tmpArr = [[NSMutableArray alloc] initWithArray: [[_contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    return tmpArr;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return hCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return hSection;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing: true];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self.view endEditing: true];
}

//  Get sections contact cho callnex list
- (void)getSectionsForContactsList: (NSMutableArray *)listContacts {
    [_contactSections removeAllObjects];
    
    // Loop through the books and create our keys
    for (ContactObject *contactItem in listContacts){
        NSString *c = @"";
        if (contactItem._fullName.length > 1) {
            c = [[contactItem._fullName substringToIndex: 1] uppercaseString];
            c = [AppUtils convertUTF8StringToString: c];
        }
        
        if (![listCharacter containsObject:c]) {
            c = @"*";
        }
        
        found = false;
        for (NSString *str in [_contactSections allKeys]){
            if ([str isEqualToString:c]){
                found = true;
            }
        }
        if (!found){
            [_contactSections setObject:[[NSMutableArray alloc] init] forKey:c];
        }
    }
    
    // Loop again and sort the books into their respective keys
    for (ContactObject *contactItem in listContacts){
        NSString *c = @"";
        if (contactItem._fullName.length > 1) {
            c = [[contactItem._fullName substringToIndex: 1] uppercaseString];
            c = [AppUtils convertUTF8StringToString: c];
        }
        if (![listCharacter containsObject:c]) {
            c = @"*";
        }
        
        [[_contactSections objectForKey:c] addObject:contactItem];
    }
    // Sort each section array
    for (NSString *key in [_contactSections allKeys]){
        [[_contactSections objectForKey:key] sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"_fullName" ascending:YES]]];
    }
}

- (NSString *)subTowString: (NSString *)str1 andString: (NSString *)str2 {
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

@end
