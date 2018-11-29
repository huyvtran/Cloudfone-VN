//
//  PBXContactsViewController.m
//  linphone
//
//  Created by Apple on 5/11/17.
//
//

#import "PBXContactsViewController.h"
#import "NewContactViewController.h"
#import "JSONKit.h"
#import "PBXContact.h"
#import "PBXContactTableCell.h"
#import "UIImage+GKContact.h"

@interface PBXContactsViewController (){
    BOOL isSearching;
    
    float hCell;
    
    YBHud *waitingHud;
    UIFont *textFont;
    
    NSMutableArray *listSearch;
    NSMutableDictionary *contactSections;
    NSArray *listCharacter;
    BOOL isFound;
    BOOL found;
    
    float hSection;
}

@end

@implementation PBXContactsViewController
@synthesize _lbContacts, _tbContacts;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //  my code here
    hSection = 35.0;
    
    [self autoLayoutForView];
    
    contactSections = [[NSMutableDictionary alloc] init];
    listCharacter = [[NSArray alloc] initWithObjects: @"A", @"B", @"C", @"D", @"E", @"F",
                     @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"\n\n---------->GO TO PBXContactsViewController"] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    [self showContentWithCurrentLanguage];
    isSearching = NO;
    
    if (listSearch == nil) {
        listSearch = [[NSMutableArray alloc] init];
    }
    [listSearch removeAllObjects];
    
    if (![LinphoneAppDelegate sharedInstance].contactLoaded) {
        [WriteLogsUtils writeLogContent:@"Contact have not loaded yet" toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchContactWithValue:)
                                                 name:@"searchContactWithValue" object:nil];
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

- (void)showContentWithCurrentLanguage {
    [_lbContacts setText:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"No contacts"]];
}

//  setup thông tin cho tableview
- (void)autoLayoutForView {
    float wIconSync;
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
        wIconSync = 30.0;
    }else{
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
        wIconSync = 26.0;
    }
    
    hCell = 65.0;
    
    //  table contacts
    _tbContacts.delegate = self;
    _tbContacts.dataSource = self;
    _tbContacts.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tbContacts mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
    
    //  no contact label
    _lbContacts.font = textFont;
    _lbContacts.textColor = UIColor.darkGrayColor;
    [_lbContacts mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
}

#pragma mark - UITableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (isSearching) {
        [self getSectionsForContactsList: listSearch];
    }else{
        [self getSectionsForContactsList: [LinphoneAppDelegate sharedInstance].pbxContacts];
    }
    return [[contactSections allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (![LinphoneAppDelegate sharedInstance].contactLoaded) {
        return 0;
    }
    
    NSString *str = [[[contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
    return [[contactSections objectForKey:str] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    return hCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return hSection;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeKeyboard" object:nil];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeKeyboard" object:nil];
}

//  Added by Khai Le on 04/10/2018
- (void)searchContactWithValue: (NSNotification *)notif {
    
    id object = [notif object];
    if ([object isKindOfClass:[NSString class]])
    {
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"%s search value = %@", __FUNCTION__, object] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        
        if ([object isEqualToString:@""]) {
            if ([LinphoneAppDelegate sharedInstance].pbxContacts.count > 0) {
                _lbContacts.hidden = YES;
                _tbContacts.hidden = NO;
            }else{
                _lbContacts.hidden = NO;
                _tbContacts.hidden = YES;
            }
            isSearching = NO;
            [_tbContacts reloadData];
            
        }else{
            isSearching = YES;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [self startSearchPBXContactsWithContent: object];
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"%s Finished search contact with value = %@", __FUNCTION__, object] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
                    
                    if (listSearch.count > 0) {
                        _lbContacts.hidden = YES;
                        _tbContacts.hidden = NO;
                        [_tbContacts reloadData];
                    }else{
                        _lbContacts.hidden = NO;
                        _tbContacts.hidden = YES;
                    }
                });
            });
        }
    }
}

- (void)startSearchPBXContactsWithContent: (NSString *)content {
    [listSearch removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_name CONTAINS[cd] %@ OR _number CONTAINS[cd] %@", content, content];
    NSArray *filter = [[LinphoneAppDelegate sharedInstance].pbxContacts filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        [listSearch addObjectsFromArray: filter];
    }
}

- (void)getSectionsForContactsList: (NSMutableArray *)contactList {
    [contactSections removeAllObjects];
    
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
        
        [[contactSections objectForKey: c] addObject:contactItem];
    }
    // Sort each section array
    for (NSString *key in [contactSections allKeys]){
        [[contactSections objectForKey:key] sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"_name" ascending:YES]]];
    }
}

- (void)onIconCallClicked: (UIButton *)sender {
    if (![AppUtils isNullOrEmpty: sender.currentTitle]) {
        NSString *number = [AppUtils removeAllSpecialInString: sender.currentTitle];
        if (![AppUtils isNullOrEmpty: number]) {
            [SipUtils makeCallWithPhoneNumber: number];
            
            [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"%s: %@ make call to %@", __FUNCTION__, USERNAME, number] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        }
    }
}

@end
