//
//  iPadContactsViewController.m
//  linphone
//
//  Created by lam quang quan on 1/11/19.
//

#import "iPadContactsViewController.h"
#import "PBXContactTableCell.h"
#import "UIImage+GKContact.h"
#import "NSData+Base64.h"
#import "ContactCell.h"
#import "ContactObject.h"
#import "ContactDetailObj.h"

@interface iPadContactsViewController (){
    UIButton *icClear;
    float hSection;
    
    NSMutableDictionary *contactSections;
    NSArray *listCharacter;
    
    NSMutableArray *contactList;
    NSMutableArray *listSearch;
    
    BOOL isSearching;
    
    BOOL isFound;
    BOOL found;
    UIFont *textFont;
    
    WebServices *webService;
    NSTimer *searchTimer;
}

@end

@implementation iPadContactsViewController
@synthesize viewHeader, bgHeader, btnAll, btnPBX, tfSearch, tbContacts, icSync, icAddNew, icWaiting;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    hSection = 35.0;
    
    contactSections = [[NSMutableDictionary alloc] init];
    listCharacter = [[NSArray alloc] initWithObjects: @"A", @"B", @"C", @"D", @"E", @"F",
                     @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
    
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [WriteLogsUtils writeForGoToScreen: @"PBXContactsViewController"];
    [self showContentWithCurrentLanguage];
    
    //  create web service
    if (webService == nil) {
        webService = [[WebServices alloc] init];
        webService.delegate = self;
    }
    
    //  create temp pbx contacts list
    if (contactList == nil) {
        contactList = [[NSMutableArray alloc] init];
    }
    [contactList removeAllObjects];
    
    if (listSearch == nil) {
        listSearch = [[NSMutableArray alloc] init];
    }
    [listSearch removeAllObjects];
    
    isSearching = NO;
    icClear.hidden = YES;
    icWaiting.hidden = YES;
    [icWaiting startAnimating];
    
    [self updateUIForView];
    
    //  check to show icon sync
    if ([SipUtils getStateOfDefaultProxyConfig] == eAccountNone) {
        icSync.hidden = YES;
    }else{
        icSync.hidden = NO;
    }
    
    if (![LinphoneAppDelegate sharedInstance].contactLoaded)
    {
        [WriteLogsUtils writeLogContent:@"Contact have not loaded yet" toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        /*
        NSNumber *pbxId = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_ID_CONTACT];
        if (pbxId != nil) {
            NSArray *contacts = [[LinphoneAppDelegate sharedInstance] getPBXContactPhone:[pbxId intValue]];
            [pbxList addObjectsFromArray: contacts];
            
            [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"Get PBX contacts with id = %d with list = %lu items", [pbxId intValue], (unsigned long)pbxList.count] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
            
            if (pbxList.count > 0) {
                tbContacts.hidden = NO;
                [tbContacts reloadData];
            }else{
                tbContacts.hidden = YES;
            }
        }else{
            tbContacts.hidden = YES;
        }   */
    }else{
        [self showAndReloadContactList];
        
        if (contactList.count > 0) {
            [tbContacts reloadData];
        }
    }
    
    if ([LinphoneAppDelegate sharedInstance].needToReloadContactList) {
        [tbContacts reloadData];
        [LinphoneAppDelegate sharedInstance].needToReloadContactList = NO;
    }
    
    /*  Le Khai
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startSearchContactWithValue:)
                                                 name:searchContactWithValue object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(afterFinishGetPBXContactsList:)
                                                 name:finishGetPBXContacts object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenSyncPBXContactsFinish)
                                                 name:syncPBXContactsFinish object:nil];
    */
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    [AppUtils addCornerRadiusTopLeftAndBottomLeftForButton:btnPBX radius:HEIGHT_IPAD_HEADER_BUTTON/2 withColor:[UIColor colorWithRed:0.169 green:0.53 blue:0.949 alpha:1.0] border:2.0];
    [AppUtils addCornerRadiusTopRightAndBottomRightForButton:btnAll radius:HEIGHT_IPAD_HEADER_BUTTON/2 withColor:[UIColor colorWithRed:0.169 green:0.53 blue:0.949 alpha:1.0] border:2.0];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnPBXPressed:(UIButton *)sender {
    [LinphoneAppDelegate sharedInstance].contactType = eContactPBX;
    [self updateUIForView];
    
    tfSearch.text = @"";
    icClear.hidden = YES;
    isSearching = NO;
    [self showAndReloadContactList];
    [tbContacts reloadData];
}

- (IBAction)btnAllPressed:(UIButton *)sender {
    [LinphoneAppDelegate sharedInstance].contactType = eContactAll;
    [self updateUIForView];
    
    tfSearch.text = @"";
    icClear.hidden = YES;
    isSearching = NO;
    [self showAndReloadContactList];
    [tbContacts reloadData];
}

- (IBAction)icSyncClicked:(UIButton *)sender {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Start sync contact with account %@", __FUNCTION__, [SipUtils getAccountIdOfDefaultProxyConfig]] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    [self startSyncPBXContactsForAccount];
}

- (IBAction)icAddNewClicked:(UIButton *)sender {
}

- (void)showContentWithCurrentLanguage {
    [btnPBX setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"PBX"] forState:UIControlStateNormal];
    [btnPBX setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Contacts"] forState:UIControlStateNormal];
}

- (void)setupUIForView {
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }else{
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
    }
    
    //  header view
    [viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(HEIGHT_IPAD_NAV + 60.0);
    }];
    
    [bgHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(viewHeader);
    }];
    
    [bgHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(viewHeader);
    }];
    
    float top = STATUS_BAR_HEIGHT + (HEIGHT_IPAD_NAV - STATUS_BAR_HEIGHT - HEIGHT_IPAD_HEADER_BUTTON)/2;
    icSync.backgroundColor = UIColor.clearColor;
    [icSync mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewHeader).offset(PADDING_HEADER_ICON);
        make.top.equalTo(viewHeader).offset(top);
        make.width.height.mas_equalTo(HEIGHT_IPAD_HEADER_BUTTON);
    }];
    
    icAddNew.backgroundColor = UIColor.clearColor;
    [icAddNew mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(viewHeader).offset(-PADDING_HEADER_ICON);
        make.top.equalTo(icSync);
        make.width.height.mas_equalTo(HEIGHT_IPAD_HEADER_BUTTON);
    }];
    
    btnPBX.backgroundColor = [UIColor colorWithRed:0.169 green:0.53 blue:0.949 alpha:1.0];
    [btnPBX setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"PBX"] forState:UIControlStateNormal];
    [btnPBX setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [btnPBX mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(viewHeader.mas_centerX);
        make.centerY.equalTo(icAddNew.mas_centerY);
        make.height.mas_equalTo(HEIGHT_HEADER_BTN);
        make.width.mas_equalTo(100.0);
    }];
    
    btnAll.backgroundColor = UIColor.clearColor;
    [btnAll setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Contacts"] forState:UIControlStateNormal];
    [btnAll setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [btnAll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewHeader.mas_centerX);
        make.top.bottom.equalTo(btnPBX);
        make.width.equalTo(btnPBX.mas_width);
        make.height.equalTo(btnPBX.mas_height);
    }];
    
    float hTextfield = 32.0;
    tfSearch.backgroundColor = [UIColor colorWithRed:(16/255.0) green:(59/255.0)
                                                blue:(123/255.0) alpha:0.8];
    tfSearch.font = [UIFont systemFontOfSize: 16.0];
    tfSearch.borderStyle = UITextBorderStyleNone;
    tfSearch.layer.cornerRadius = hTextfield/2;
    tfSearch.clipsToBounds = YES;
    tfSearch.textColor = UIColor.whiteColor;
    if ([tfSearch respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        tfSearch.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Type name or phone number"] attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:(230/255.0) green:(230/255.0) blue:(230/255.0) alpha:1.0]}];
    } else {
        tfSearch.placeholder = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Type name or phone number"];
    }
    [tfSearch addTarget:self
                 action:@selector(onSearchContactChange:)
       forControlEvents:UIControlEventEditingChanged];
    
    UIView *pLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 0, hTextfield, hTextfield)];
    tfSearch.leftView = pLeft;
    tfSearch.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *pRight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, hTextfield, hTextfield)];
    tfSearch.rightView = pRight;
    tfSearch.rightViewMode = UITextFieldViewModeAlways;
    
    [tfSearch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(viewHeader).offset(-(60-hTextfield)/2);
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
    
    icClear = [[UIButton alloc] init];
    [icClear setImage:[UIImage imageNamed:@"close_white"] forState:UIControlStateNormal];
    icClear.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    icClear.backgroundColor = UIColor.clearColor;
    [viewHeader addSubview: icClear];
    [icClear mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(tfSearch);
        make.width.mas_equalTo(hTextfield);
    }];
    [icClear addTarget:self
                action:@selector(clearSearch)
      forControlEvents:UIControlEventTouchUpInside];
    
    //  table contacts
    tbContacts.backgroundColor = UIColor.clearColor;
    tbContacts.delegate = self;
    tbContacts.dataSource = self;
    tbContacts.separatorStyle = UITableViewCellSeparatorStyleNone;
    if ([tbContacts respondsToSelector:@selector(setSectionIndexColor:)]) {
        tbContacts.sectionIndexColor = UIColor.grayColor;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            tbContacts.sectionIndexBackgroundColor = UIColor.whiteColor;
        }
    }
    [tbContacts mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-self.tabBarController.tabBar.frame.size.height);
    }];
    
    [icWaiting mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(tbContacts);
    }];
}

- (void)clearSearch {
    [self.view endEditing: true];
    tfSearch.text = @"";
    isSearching = NO;
    [tbContacts reloadData];
}

//  Added by Khai Le on 04/10/2018
- (void)onSearchContactChange: (UITextField *)textField {
    if (![textField.text isEqualToString:@""]) {
        icClear.hidden = NO;
    }else{
        icClear.hidden = YES;
    }
    
    [searchTimer invalidate];
    searchTimer = nil;
    searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self
                                                 selector:@selector(startSearchPhoneBook:)
                                                 userInfo:tfSearch.text repeats:NO];
}

//  Added by Khai Le on 04/10/2018
- (void)startSearchPhoneBook: (NSTimer *)timer {
    NSString *content = [timer userInfo];
    if ([content isKindOfClass:[NSString class]])
    {
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"%s search value = %@", __FUNCTION__, content] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        
        if (listSearch == nil) {
            listSearch = [[NSMutableArray alloc] init];
        }
        [listSearch removeAllObjects];
        
        if ([content isEqualToString:@""]) {
            isSearching = NO;
        }else{
            isSearching = YES;
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            if ([LinphoneAppDelegate sharedInstance].contactType == eContactPBX) {
                [self startSearchPBXContactsWithContent: content];
            }else{
                [self searchPhoneBook: content];
            }
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [tbContacts reloadData];
            });
        });
    }
}

- (void)startSearchPBXContactsWithContent: (NSString *)content {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] search pbx contact = %@", __FUNCTION__, content] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    NSMutableArray *tmpList = [[NSMutableArray alloc] initWithArray: [[LinphoneAppDelegate sharedInstance].pbxContacts copy]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_name CONTAINS[cd] %@ OR _number CONTAINS[cd] %@", content, content];
    NSArray *filter = [tmpList filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        [listSearch addObjectsFromArray: filter];
    }
}

- (void)searchPhoneBook: (NSString *)content
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] search phonebook contact = %@", __FUNCTION__, content] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    NSMutableArray *tmpList = [[NSMutableArray alloc] initWithArray: [[LinphoneAppDelegate sharedInstance].listContacts copy]];
    
    //  search theo ten va sipPhone
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_fullName contains[cd] %@ OR _sipPhone contains[cd] %@", content, content];
    
    NSArray *filter = [tmpList filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        [listSearch addObjectsFromArray: filter];
        [tmpList removeObjectsInArray: filter];
    }
    
    predicate = [NSPredicate predicateWithFormat:@"_valueStr contains[cd] %@", content];
    for (int iCount=0; iCount<tmpList.count; iCount++) {
        ContactObject *contact = [tmpList objectAtIndex: iCount];
        NSArray *filter = [contact._listPhone filteredArrayUsingPredicate: predicate];
        if (filter.count > 0) {
            [listSearch addObject: contact];
        }
    }
}

#pragma mark - UITableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (isSearching) {
        [self getSectionsForContactsList: listSearch];
    }else{
        [self getSectionsForContactsList: contactList];
    }
    return [[contactSections allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSString *str = [[[contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
    return [[contactSections objectForKey:str] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([LinphoneAppDelegate sharedInstance].contactType == eContactPBX) {
        static NSString *identifier = @"PBXContactTableCell";
        PBXContactTableCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PBXContactTableCell" owner:self options:nil];
            cell = topLevelObjects[0];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSString *key = [[[contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section];
        PBXContact *contact = [[contactSections objectForKey: key] objectAtIndex:indexPath.row];
        
        // Tên contact
        if (contact._name != nil && ![contact._name isKindOfClass:[NSNull class]]) {
            cell._lbName.text = contact._name;
        }else{
            cell._lbName.text = @"";
        }
        
        if (contact._number != nil && ![contact._number isKindOfClass:[NSNull class]]) {
            cell._lbPhone.text = contact._number;
            cell.icCall.hidden = NO;
            [cell.icCall setTitle:contact._number forState:UIControlStateNormal];
            [cell.icCall addTarget:self
                            action:@selector(onIconCallClicked:)
                  forControlEvents:UIControlEventTouchUpInside];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSString *pbxServer = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_SERVER];
                NSString *avatarName = [NSString stringWithFormat:@"%@_%@.png", pbxServer, contact._number];
                NSString *localFile = [NSString stringWithFormat:@"/avatars/%@", avatarName];
                NSData *avatarData = [AppUtils getFileDataFromDirectoryWithFileName:localFile];
                
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    if (avatarData != nil) {
                        cell._imgAvatar.image = [UIImage imageWithData: avatarData];
                    }else{
                        NSString *firstChar = [contact._name substringToIndex:1];
                        UIImage *avatar = [UIImage imageForName:[firstChar uppercaseString] size:CGSizeMake(60.0, 60.0)
                                                backgroundColor:[UIColor colorWithRed:0.169 green:0.53 blue:0.949 alpha:1.0]
                                                      textColor:UIColor.whiteColor
                                                           font:[UIFont fontWithName:HelveticaNeue size:30.0]];
                        cell._imgAvatar.image = avatar;
                    }
                });
            });
        }else{
            cell._lbPhone.text = @"";
            cell.icCall.hidden = YES;
        }
        
        if ([contact._name isEqualToString:@""]) {
            UIImage *avatar = [UIImage imageForName:@"#" size:CGSizeMake(60.0, 60.0)
                                    backgroundColor:[UIColor colorWithRed:0.169 green:0.53 blue:0.949 alpha:1.0]
                                          textColor:UIColor.whiteColor
                                               font:[UIFont fontWithName:HelveticaNeue size:30.0]];
            cell._imgAvatar.image = avatar;
        }
        
        int count = (int)[[contactSections objectForKey:key] count];
        if (indexPath.row == count-1) {
            cell._lbSepa.hidden = YES;
        }else{
            cell._lbSepa.hidden = NO;
        }
        
        return cell;
    }else{
        
        ContactObject *contact = [[ContactObject alloc] init];
        NSString *key = [[[contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section];
        contact = [[contactSections objectForKey: key] objectAtIndex:indexPath.row];
        
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
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([LinphoneAppDelegate sharedInstance].contactType == eContactPBX) {
        NSString *key = [[[contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section];
        PBXContact *contact = [[contactSections objectForKey: key] objectAtIndex:indexPath.row];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:showContactInformation
                                                            object:contact];
    }else{
        NSString *key = [[[contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section];
        ContactObject *contact = [[contactSections objectForKey: key] objectAtIndex:indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:showContactInformation
                                                            object:contact];
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *titleHeader = [[[contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];;
    
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
    NSMutableArray *tmpArr = [[NSMutableArray alloc] initWithArray: [[contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    
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

- (void)getSectionsForContactsList: (NSMutableArray *)contactList {
    [contactSections removeAllObjects];
    
    if ([LinphoneAppDelegate sharedInstance].contactType == eContactPBX) {
        // Loop through the books and create our keys
        for (PBXContact *contactItem in contactList){
            NSString *c = @"";
            if (contactItem._name.length > 1) {
                c = [[contactItem._name substringToIndex: 1] uppercaseString];
                c = [AppUtils convertUTF8StringToString: c];
            }
            
            if (![listCharacter containsObject:c]) {
                c = @"z#";
            }
            
            found = NO;
            for (NSString *str in [contactSections allKeys]){
                if ([str isEqualToString:c]){
                    found = YES;
                }
            }
            if (!found){
                [contactSections setObject:[[NSMutableArray alloc] init] forKey:c];
            }
        }
        
        // Loop again and sort the books into their respective keys
        for (PBXContact *contactItem in contactList){
            NSString *c = @"";
            if (contactItem._name.length > 1) {
                c = [[contactItem._name substringToIndex: 1] uppercaseString];
                c = [AppUtils convertUTF8StringToString: c];
            }
            if (![listCharacter containsObject:c]) {
                c = @"z#";
            }
            if (contactItem != nil) {
                [[contactSections objectForKey: c] addObject:contactItem];
            }
        }
        // Sort each section array
        for (NSString *key in [contactSections allKeys]){
            [[contactSections objectForKey:key] sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"_name" ascending:YES]]];
        }
        
    }else{
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
            for (NSString *str in [contactSections allKeys]){
                if ([str isEqualToString:c]){
                    found = YES;
                }
            }
            if (!found){
                [contactSections setObject:[[NSMutableArray alloc] init] forKey:c];
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
            
            [[contactSections objectForKey: c] addObject:contactItem];
        }
        // Sort each section array
        for (NSString *key in [contactSections allKeys]){
            [[contactSections objectForKey:key] sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"_fullName" ascending:YES]]];
        }
    }
    
}

- (void)onIconCallClicked: (UIButton *)sender
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] phone number = %@", __FUNCTION__, sender.currentTitle]
                         toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    if (![AppUtils isNullOrEmpty: sender.currentTitle]) {
        NSString *number = [AppUtils removeAllSpecialInString: sender.currentTitle];
        if (![AppUtils isNullOrEmpty: number]) {
            [SipUtils makeCallWithPhoneNumber: number];
            
            [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"%s: %@ make call to %@", __FUNCTION__, USERNAME, number] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        }
    }
}

- (void)updateUIForView {
    if ([LinphoneAppDelegate sharedInstance].contactType == eContactPBX) {
        icSync.hidden = NO;
        icAddNew.hidden = YES;
        
        [self setSelected: NO forButton: btnAll];
        [self setSelected: YES forButton: btnPBX];
    }else{
        icSync.hidden = YES;
        icAddNew.hidden = NO;
        
        [self setSelected: YES forButton: btnAll];
        [self setSelected: NO forButton: btnPBX];
    }
}

- (void)setSelected: (BOOL)selected forButton: (UIButton *)button {
    if (selected) {
        button.backgroundColor = [UIColor colorWithRed:0.169 green:0.53 blue:0.949 alpha:1.0];
    }else{
        button.backgroundColor = UIColor.clearColor;
    }
}

- (void)showAndReloadContactList {
    if ([LinphoneAppDelegate sharedInstance].contactType == eContactPBX) {
        [contactList removeAllObjects];
        [contactList addObjectsFromArray: [[LinphoneAppDelegate sharedInstance].pbxContacts copy]];
    }else{
        [contactList removeAllObjects];
        [contactList addObjectsFromArray:[[LinphoneAppDelegate sharedInstance].listContacts copy]];
    }
    
    if (contactList.count == 0) {
        tbContacts.hidden = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showViewNoContactsDetailForIpad" object:nil];
    }else{
        tbContacts.hidden = NO;
    }
}

- (void)startSyncPBXContactsForAccount
{
    BOOL networkReady = [DeviceUtils checkNetworkAvailable];
    
    if (!networkReady) {
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Error: Device can not access to network", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        
        [[LinphoneAppDelegate sharedInstance].window makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Please check your internet connection!"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    if ([LinphoneAppDelegate sharedInstance]._isSyncing) {
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] PBX contacts is being synchronized!", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        
        [[LinphoneAppDelegate sharedInstance].window makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"PBX contacts is being synchronized!"] duration:2.0 position:CSToastPositionCenter];
        return;
    }else{
        NSString *service = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_SERVER];
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] service = %@", __FUNCTION__, service] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        
        if ([service isKindOfClass:[NSNull class]] || service == nil || [service isEqualToString: @""]) {
            [[LinphoneAppDelegate sharedInstance].window makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"No account"] duration:2.0 position:CSToastPositionCenter];
            return;
        }
        
        icWaiting.hidden = NO;
        [icWaiting startAnimating];
        
        [LinphoneAppDelegate sharedInstance]._isSyncing = YES;
        [self startAnimationForSyncButton: icSync];
        
        [self getPBXContactsWithServerName: service];
    }
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

#pragma mark - Web service
- (void)getPBXContactsWithServerName: (NSString *)serverName
{
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:AuthUser forKey:@"AuthUser"];
    [jsonDict setObject:AuthKey forKey:@"AuthKey"];
    [jsonDict setObject:serverName forKey:@"ServerName"];
    [webService callWebServiceWithLink:getServerContacts withParams:jsonDict];
    
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] jsonDict = %@", __FUNCTION__, @[jsonDict]] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
}

- (void)failedToCallWebService:(NSString *)link andError:(NSString *)error {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] link: %@.\nResponse data: %@", __FUNCTION__, link, error] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    [icWaiting stopAnimating];
    icWaiting.hidden = YES;
    
    if ([link isEqualToString:getServerContacts]) {
        [[LinphoneAppDelegate sharedInstance].window makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Error"] duration:2.0 position:CSToastPositionCenter];
    }
}

- (void)successfulToCallWebService:(NSString *)link withData:(NSDictionary *)data
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] link: %@.\nResponse data: %@", __FUNCTION__, link, @[data]] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
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
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self savePBXContactInPhoneBook: data];
        [self getListPhoneWithCurrentContactPBX];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self syncContactsSuccessfully];
        });
    });
}

- (void)savePBXContactInPhoneBook: (NSArray *)pbxData
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__]
                         toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
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
                                                          forKey:PBX_ID_CONTACT];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }
}

//  Thông báo kết thúc sync contacts
- (void)syncContactsSuccessfully
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    [icWaiting stopAnimating];
    icWaiting.hidden = YES;
    
    [[LinphoneAppDelegate sharedInstance] set_isSyncing: false];
    [icSync.layer removeAllAnimations];
    
    [[LinphoneAppDelegate sharedInstance].window makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Successful"] duration:2.0 position:CSToastPositionCenter];
    
    [self showAndReloadContactList];
    [tbContacts reloadData];
    
    //  khai le
    //  [[NSNotificationCenter defaultCenter] postNotificationName:searchContactWithValue object:_tfSearch.text];
}

@end
