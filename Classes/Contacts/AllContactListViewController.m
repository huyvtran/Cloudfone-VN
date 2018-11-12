//
//  AllContactListViewController.m
//  linphone
//
//  Created by admin on 1/29/18.
//

#import "AllContactListViewController.h"
#import "EditContactViewController.h"
#import "DGActivityIndicatorView.h"
#import "ContactCell.h"
#import "NSData+Base64.h"
#import "UIImage+GKContact.h"

@interface AllContactListViewController (){
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
@synthesize viewHeader, iconBack, lbHeader, bgHeader, tfSearch, iconClear, tbContacts, lbNoContact;
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
    
    [self autoLayoutForMainView];
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
            isSearching = NO;
            if ([LinphoneAppDelegate sharedInstance].listContacts.count > 0) {
                lbNoContact.hidden = YES;
            }else{
                lbNoContact.hidden = NO;
            }
            [tbContacts reloadData];
        }else{
            iconClear.hidden = NO;
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
    lbHeader.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Choose contact"];
}

//  Setup frame cho view
- (void)autoLayoutForMainView
{
    if (SCREEN_WIDTH > 320) {
        lbHeader.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:20.0];
    }else{
        lbHeader.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }
    
    viewHeader.backgroundColor = UIColor.clearColor;
    [viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo([LinphoneAppDelegate sharedInstance]._hRegistrationState + 50);
    }];
    
    [bgHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(viewHeader);
    }];
    
    [iconBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewHeader);
        make.top.equalTo(viewHeader).offset([LinphoneAppDelegate sharedInstance]._hStatus);
        make.width.height.mas_equalTo(HEADER_ICON_WIDTH);
    }];
    
    [lbHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewHeader.mas_centerX);
        make.width.mas_equalTo(200);
        make.top.bottom.equalTo(iconBack);
    }];
    
    [lbHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewHeader.mas_centerX);
        make.width.mas_equalTo(200);
        make.top.bottom.equalTo(iconBack);
    }];
    
    float hTextfield = 32.0;
    tfSearch.backgroundColor = [UIColor colorWithRed:(16/255.0) green:(59/255.0)
                                                 blue:(123/255.0) alpha:0.8];
    tfSearch.font = [UIFont systemFontOfSize: 16.0];
    tfSearch.borderStyle = UITextBorderStyleNone;
    tfSearch.layer.cornerRadius = hTextfield/2;
    tfSearch.clipsToBounds = YES;
    tfSearch.textColor = UIColor.whiteColor;
    if ([self.tfSearch respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        tfSearch.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Type name or phone number"] attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:(230/255.0) green:(230/255.0) blue:(230/255.0) alpha:1.0]}];
    } else {
        tfSearch.placeholder = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Type name or phone number"];
    }
    [tfSearch addTarget:self
                  action:@selector(whenTextFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    UIView *pLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 0, hTextfield, hTextfield)];
    tfSearch.leftView = pLeft;
    tfSearch.leftViewMode = UITextFieldViewModeAlways;
    
    [tfSearch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbHeader.mas_bottom).offset(5+(50-hTextfield)/2);
        make.left.equalTo(viewHeader).offset(30.0);
        make.right.equalTo(viewHeader).offset(-30.0);
        make.height.mas_equalTo(hTextfield);
    }];
    
    UIImageView *imgSearch = [[UIImageView alloc] init];
    imgSearch.image = [UIImage imageNamed:@"ic_search"];
    [tfSearch addSubview: imgSearch];
    [imgSearch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(tfSearch.mas_centerY);
        make.left.equalTo(tfSearch).offset(8.0);
        make.width.height.mas_equalTo(17.0);
    }];
    
    iconClear.backgroundColor = UIColor.clearColor;
    [iconClear mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(tfSearch);
        make.width.mas_equalTo(hTextfield);
    }];
    
    //  table contact
    [tbContacts mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader.mas_bottom);
        make.left.bottom.right.equalTo(self.view);
    }];
    
    tbContacts.delegate = self;
    tbContacts.dataSource = self;
    tbContacts.separatorStyle = UITableViewCellSeparatorStyleNone;
    if ([tbContacts respondsToSelector:@selector(setSectionIndexColor:)]) {
        [tbContacts setSectionIndexColor: [UIColor grayColor]];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            [tbContacts setSectionIndexBackgroundColor:[UIColor whiteColor]];
        }
    }
    
    lbNoContact.textColor = UIColor.darkGrayColor;
    lbNoContact.font = [UIFont fontWithName:HelveticaNeue size:15.0];
    lbNoContact.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"No contacts"];
    [lbNoContact mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader.mas_bottom);
        make.left.bottom.right.equalTo(self.view);
    }];
    
    hCell = 60.0;
    hSection = 35.0;
}

- (void)whenTextFieldDidChange: (UITextField *)textField {
    if (textField.text.length == 0) {
        isSearching = false;
        [iconClear setHidden: true];
        [tbContacts reloadData];
    }else{
        [iconClear setHidden: false];
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
    cell.icCall.hidden = YES;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactObject *contact = [[_contactSections objectForKey:[[[_contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    EditContactViewController *controller = VIEW(EditContactViewController);
    if (controller != nil) {
        controller.idContact = contact._id_contact;
        controller.curPhoneNumber = phoneNumber;
    }
    [[PhoneMainView instance] changeCurrentView:[EditContactViewController compositeViewDescription]];
    //  [[PhoneMainView instance] changeCurrentView:[EditContactViewController compositeViewDescription] push:true];
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

@end
