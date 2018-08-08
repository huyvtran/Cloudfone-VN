//
//  AllContactListViewController.m
//  linphone
//
//  Created by admin on 1/29/18.
//

#import "AllContactListViewController.h"
#import "EditContactViewController.h"
#import "DGActivityIndicatorView.h"
#import "PhoneMainView.h"
#import "ContactCell.h"
#import "ContactNormalCell.h"
#import "NSData+Base64.h"

@interface AllContactListViewController (){
    float hSearch;
    float hSection;
    float hCell;
    
    NSTimer *searchTimer;
    BOOL isSearching;
    
    NSArray *listCharacter;
    BOOL isFound;
    BOOL found;
    UIFont *textFont;
    
    DGActivityIndicatorView *activityIndicatorView;
}

@end

@implementation AllContactListViewController
@synthesize viewHeader, iconBack, lbHeader;
@synthesize viewSearch, bgSearch, imgSearch, tfSearch, lbSearch, iconClear, tbContacts, lbNoContact;
@synthesize _searchResults, _contactSections, phoneNumber;

#pragma mark - UICompositeViewDelegate Functions
static UICompositeViewDescription *compositeDescription = nil;
+ (UICompositeViewDescription *)compositeViewDescription {
    if (compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:nil
                                                                 tabBar:nil
                                                               sideMenu:nil
                                                             fullscreen:NO
                                                         isLeftFragment:YES
                                                           fragmentWith:nil];
        compositeDescription.darkBackground = true;
    }
    return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
    return self.class.compositeViewDescription;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //  my code here
    _contactSections = [[NSMutableDictionary alloc] init];
    
    listCharacter = [[NSArray alloc] initWithObjects: @"A", @"B", @"C", @"D", @"E", @"F",
                     @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
    
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self showContentWithCurrentLanguage];
    
    if (![LinphoneAppDelegate sharedInstance].contactLoaded) {
        if (activityIndicatorView == nil) {
            activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeNineDots tintColor:[UIColor grayColor]];
            [self.view addSubview:activityIndicatorView];
        }
        tbContacts.hidden = YES;
        lbNoContact.hidden = YES;
        
        activityIndicatorView.frame = tbContacts.frame;
        [activityIndicatorView startAnimating];
    }else{
        [activityIndicatorView stopAnimating];
        tbContacts.hidden = NO;
        
        if ([tfSearch.text isEqualToString:@""]) {
            iconClear.hidden = YES;
            lbSearch.hidden = NO;
            isSearching = NO;
            if ([LinphoneAppDelegate sharedInstance].listContacts.count > 0) {
                lbNoContact.hidden = YES;
            }else{
                lbNoContact.hidden = NO;
            }
            [tbContacts reloadData];
        }else{
            iconClear.hidden = NO;
            lbSearch.hidden = YES;
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
    //  ---------
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)iconBackClicked:(UIButton *)sender {
    [[PhoneMainView instance] popCurrentView];
}

- (IBAction)iconCloseClicked:(UIButton *)sender {
    
}

#pragma mark - my functions

- (void)whenLoadContactFinish {
    if (activityIndicatorView != nil) {
        [activityIndicatorView stopAnimating];
    }
    tbContacts.hidden = NO;
    [tbContacts reloadData];
}

- (void)showContentWithCurrentLanguage {
    [lbSearch setText:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_search_contact]];
}

//  Setup frame cho view
- (void)setupUIForView {
    hCell = 60.0;
    hSection = 20.0;
    
    hSearch = 60.0;
    
    // set font cho tiêu đề
    [viewHeader setFrame: CGRectMake(0, 0, SCREEN_WIDTH, [LinphoneAppDelegate sharedInstance]._hHeader)];
    [iconBack setFrame: CGRectMake(0, 0, [LinphoneAppDelegate sharedInstance]._hHeader, [LinphoneAppDelegate sharedInstance]._hHeader)];
    [iconBack setBackgroundImage:[UIImage imageNamed:@"ic_back_act.png"]
                         forState:UIControlStateHighlighted];
    
    [lbHeader setFrame: CGRectMake(iconBack.frame.origin.x+iconBack.frame.size.width+5, 0, viewHeader.frame.size.width-(2*iconBack.frame.origin.x+2*iconBack.frame.size.width+10), [LinphoneAppDelegate sharedInstance]._hHeader)];
    [lbHeader setFont:[UIFont fontWithName:HelveticaNeue size:18.0]];
    [lbHeader setText: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_select_contact]];
    
    //  view search
    [viewSearch setFrame: CGRectMake(0, viewHeader.frame.origin.y+viewHeader.frame.size.height, SCREEN_WIDTH, hSearch)];
    [bgSearch setFrame: CGRectMake(0, 0, viewHeader.frame.size.width, hSearch)];
    [imgSearch setFrame: CGRectMake(10, (hSearch-30)/2, 30, 30)];
    [tfSearch setFrame: CGRectMake(imgSearch.frame.origin.x+imgSearch.frame.size.width+5, imgSearch.frame.origin.y, viewSearch.frame.size.width-(2*imgSearch.frame.origin.x+2*imgSearch.frame.size.width+10), imgSearch.frame.size.height)];
    [tfSearch setFont:[UIFont fontWithName:HelveticaNeue size:15.0]];
    [tfSearch setBackgroundColor:[UIColor clearColor]];
    [tfSearch setBorderStyle: UITextBorderStyleNone];
    
    [tfSearch addTarget:self
                  action:@selector(whenTextFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    [iconClear setFrame: CGRectMake(tfSearch.frame.origin.x+tfSearch.frame.size.width+5, imgSearch.frame.origin.y, imgSearch.frame.size.width, imgSearch.frame.size.height)];
    
    [lbSearch setFrame: tfSearch.frame];
    [lbSearch setFont:[UIFont fontWithName:HelveticaNeue size:15.0]];
    [lbSearch setText: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_type_to_chat]];
    
    // setup cho tableview
    [tbContacts setFrame: CGRectMake(0, viewSearch.frame.origin.y+viewSearch.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT-([LinphoneAppDelegate sharedInstance]._hStatus+[LinphoneAppDelegate sharedInstance]._hHeader+hSearch))];
    [tbContacts setDelegate: self];
    [tbContacts setDataSource: self];
    if ([tbContacts respondsToSelector:@selector(setSectionIndexColor:)]) {
        [tbContacts setSectionIndexColor: [UIColor grayColor]];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            [tbContacts setSectionIndexBackgroundColor:[UIColor whiteColor]];
        }
    }
    [tbContacts setSeparatorStyle: UITableViewCellSeparatorStyleNone];
    
    [lbNoContact setFrame: tbContacts.frame];
    [lbNoContact setTextColor:[UIColor darkGrayColor]];
    [lbNoContact setFont:[UIFont fontWithName:HelveticaNeue size:15.0]];
    [lbNoContact setText: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_no_contact]];
}

- (void)whenTextFieldDidChange: (UITextField *)textField {
    if (textField.text.length == 0) {
        isSearching = false;
        [iconClear setHidden: true];
        [lbSearch setHidden: false];
        [tbContacts reloadData];
    }else{
        [iconClear setHidden: false];
        [lbSearch setHidden: true];
        isSearching = true;
        
        [searchTimer invalidate];
        searchTimer = nil;
        searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self
                                                     selector:@selector(startSearchPhoneBook)
                                                     userInfo:nil repeats:NO];
    }
}

- (void)startSearchPhoneBook {
    NSString *strSearch = tfSearch.text;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self searchPhoneBook: strSearch];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [tbContacts reloadData];
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
            c = @"*";
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
            c = @"*";
        }
        
        [[_contactSections objectForKey: c] addObject:contactItem];
    }
    // Sort each section array
    for (NSString *key in [_contactSections allKeys]){
        [[_contactSections objectForKey:key] sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"_fullName" ascending:YES]]];
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
    ContactObject *contact = [[_contactSections objectForKey:[[[_contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    if (contact._sipPhone != nil && ![contact._sipPhone isKindOfClass:[NSNull class]] && ![contact._sipPhone isEqualToString:@""])
    {
        static NSString *identifier = @"ContactCell";
        ContactCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ContactCell" owner:self options:nil];
            cell = topLevelObjects[0];
        }
        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
        [cell setFrame: CGRectMake(cell.frame.origin.x, cell.frame.origin.y, tbContacts.frame.size.width, hCell)];
        [cell setupUIForCell];
        
        // Tên contact
        if (contact._fullName != nil) {
            if ([contact._fullName isEqualToString: @""]) {
                [cell.name setText: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_unknown]];
            }else{
                [cell.name setText: contact._fullName];
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
            [cell.image setImage: [UIImage imageWithData: imageData]];
        }else {
            //  UIImage *avatar = [UIImage imageForName:[contact._fullName uppercaseString] size: CGSizeMake(60, 60)];
            [cell.image setImage: [UIImage imageNamed:@"no_avatar.png"]];
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
        [contactCell setFrame: CGRectMake(contactCell.frame.origin.x, contactCell.frame.origin.y, tbContacts.frame.size.width, hCell)];
        [contactCell setupUIForCell];
        
        // Tên contact
        [contactCell._contactName setText: contact._fullName];
        
        if (contact._avatar != nil && ![contact._avatar isEqualToString:@""] && ![contact._avatar isEqualToString:@"<null>"] && ![contact._avatar isEqualToString:@"(null)"] && ![contact._avatar isEqualToString:@"null"])
        {
            NSData *imageData = [NSData dataFromBase64String:contact._avatar];
            [contactCell._contactAvatar setImage: [UIImage imageWithData: imageData]];
        }else {
            //  UIImage *avatar = [UIImage imageForName:[contact._fullName uppercaseString] size: CGSizeMake(60, 60)];
            [contactCell._contactAvatar setImage: [UIImage imageNamed:@"no_avatar.png"]];
        }
        
        contactCell.tag = contact._id_contact;
        
        return contactCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactObject *contact = [[_contactSections objectForKey:[[[_contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    EditContactViewController *controller = VIEW(EditContactViewController);
    if (controller != nil) {
        [controller setContactDetailsInformation: contact];
        [controller processPhoneNumberForAddExist: phoneNumber];
    }
    [[PhoneMainView instance] changeCurrentView:[EditContactViewController compositeViewDescription] push:true];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return hCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return hSection;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *titleHeader = [[[_contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, hSection)];
    [headerView setBackgroundColor:[UIColor colorWithRed:(240/255.0) green:(240/255.0)
                                                    blue:(240/255.0) alpha:1.0]];
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, hSection)];
    [descLabel setTextColor: [UIColor colorWithRed:(50/255.0) green:(50/255.0)
                                              blue:(50/255.0) alpha:1.0]];
    if ([titleHeader isEqualToString:@"*"]) {
        [descLabel setFont: [UIFont fontWithName:HelveticaNeue size:20.0]];
    }else{
        [descLabel setFont: textFont];
    }
    [descLabel setText: titleHeader];
    [descLabel setBackgroundColor:[UIColor clearColor]];
    [headerView addSubview: descLabel];
    return headerView;
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *tmpArr = [[NSMutableArray alloc] initWithArray: [[_contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    
    int iCount = 0;
    while (iCount < tmpArr.count) {
        NSString *callnexIndex = [tmpArr objectAtIndex: iCount];
        if ([callnexIndex isEqualToString:@"Callnex"]) {
            [tmpArr replaceObjectAtIndex:iCount withObject:@"*"];
            break;
        }
        iCount++;
    }
    return tmpArr;
}

@end
