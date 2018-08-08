//
//  AddParticientsViewController.m
//  linphone
//
//  Created by user on 27/12/14.
//
//

#import "AddParticientsViewController.h"
#import "GroupMainChatViewController.h"
#import "PhoneMainView.h"
#import "NSDatabase.h"
#import "NSData+Base64.h"
#import "OTRProtocolManager.h"

@interface AddParticientsViewController (){
    float hSearch;
    
    NSMutableArray *listMemberAdd;
    BOOL isFound;
    BOOL found;
    NSString *roomName;
    
    float hCell;
    float hSection;
    
    BOOL isSearching;
    NSTimer *searchTimer;
    
    //  View hiển thị thông báo
    UIView *showMessageView;
    UILabel *lbTextMsg;
    
    UIFont *textFont;
    HMLocalization *localization;
    
    NSArray *listCharacter;
}

@end

@implementation AddParticientsViewController
@synthesize _viewHeader, _iconBack, _iconDone, _lbTitle;
@synthesize _viewSearch, _bgSearch, _iconSearch, _tfSearch, _lbSearch, _iconClear;
@synthesize _listTableView, _lbNoContacts;
@synthesize _contactSections, _listSearch, _addFromGroupChat;

#pragma mark - UICompositeViewDelegate Functions
static UICompositeViewDescription *compositeDescription = nil;
+ (UICompositeViewDescription *)compositeViewDescription {
    if (compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:nil
                                                                 tabBar:nil
                                                               sideMenu:nil
                                                             fullscreen:false
                                                         isLeftFragment:YES
                                                           fragmentWith:nil];
        compositeDescription.darkBackground = true;
    }
    return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
    return self.class.compositeViewDescription;
}

#pragma mark - My controller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // MY CODE HERE
    localization = [HMLocalization sharedInstance];
    
    listCharacter = [[NSArray alloc] initWithObjects: @"A", @"B", @"C", @"D", @"E", @"F",
                     @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
    
    _contactSections = [[NSMutableDictionary alloc] init];
    listMemberAdd = [[NSMutableArray alloc] init];
    
    hCell = 60.0;
    hSection = 25.0;
    
    [self setupUIForView];
    
    //  NOTIFICATIONS
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createGroupSuccessfully)
                                                 name:k11CreateGroupChatSuccessfully object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    
    [self showContentWithCurrentLanguage];
    
    // Tắt màn hình cảm biến
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled: NO];
    
    [_iconDone setHidden: true];
    
    isSearching = false;
    [_tfSearch setText: @""];
    [_iconClear setHidden: true];
    
    if ([LinphoneAppDelegate sharedInstance].sipContacts.count > 0) {
        [_listTableView setHidden: false];
        [_lbNoContacts setHidden: true];
    }else{
        [_listTableView setHidden: true];
        [_lbNoContacts setHidden: false];
    }
    [listMemberAdd removeAllObjects];
    [_listTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self set_iconBack:nil];
    [self set_iconDone:nil];
    [self set_lbTitle:nil];
    [self set_listTableView:nil];
    [self set_tfSearch:nil];
    [self set_iconClear:nil];
    [super viewDidUnload];
}

- (IBAction)_iconClearClicked:(UIButton *)sender {
    isSearching = false;
    [_tfSearch setText: @""];
    [_iconClear setHidden: true];
    
    if ([LinphoneAppDelegate sharedInstance].sipContacts.count > 0) {
        [_lbNoContacts setHidden: true];
        [_listTableView setHidden: false];
        [_listTableView reloadData];
    }else{
        [_lbNoContacts setHidden: false];
        [_listTableView setHidden: true];
    }
}

- (IBAction)_iconBackClicked:(id)sender {
    [[PhoneMainView instance] popCurrentView];
}

//  Click vào nút add participents
- (IBAction)_iconDoneClicked:(id)sender {
    [self.view endEditing: true];
    //  Kiểm tra là mời thành viên khi tạo group hay là add thêm thành viên vào group có sẵn
    if (!_addFromGroupChat)
    {
        if (![LinphoneAppDelegate sharedInstance]._internetActive) {
            [self showMessagePopupUp: [localization localizedStringForKey:text_please_check_your_connection]];
        }else{
            NSString *curFriend = [AppUtils getSipFoneIDFromString: [LinphoneAppDelegate sharedInstance].friendBuddy.accountName];
            NSString *shortCurFriend = [curFriend substringFromIndex:6];
            NSString *shortMe = [USERNAME substringFromIndex:6];
            
            roomName = [NSString stringWithFormat:@"%@_%@_%@", shortMe , shortCurFriend, [AppUtils randomStringWithLength: 8]];
            roomName = [roomName lowercaseString];
            
            //  Tạo group chat và lưu xuống database
            [[LinphoneAppDelegate sharedInstance].myBuddy.protocol createGroupOfMe:USERNAME andGroupName:roomName];
        }
    }else{
        if (listMemberAdd.count == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cloudfone" message:[localization localizedStringForKey:choose_contact_for_add_group] delegate:nil cancelButtonTitle:[localization localizedStringForKey:text_cancel] otherButtonTitles:nil];
            [alertView show];
        }else{
            NSString *strRoomName = [NSDatabase getRoomNameOfRoomWithRoomId: [LinphoneAppDelegate sharedInstance].idRoomChat];
            [[LinphoneAppDelegate sharedInstance].myBuddy.protocol inviteUserToGroupChat:strRoomName andListUser:listMemberAdd];
            [[LinphoneAppDelegate sharedInstance].myBuddy.protocol setRoleForUserInGroupChat:strRoomName andListUser:listMemberAdd];
            
            [[PhoneMainView instance] popCurrentView];
        }
    }
}

#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (isSearching) {
        [self getSectionForContactList: _listSearch];
    }else {
        [self getSectionForContactList: [LinphoneAppDelegate sharedInstance].sipContacts];
    }
    return [_contactSections.allKeys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[_contactSections valueForKey:[[[_contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ContactAddGroupCell";
    ContactAddGroupCell *contactCell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    if (contactCell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ContactAddGroupCell" owner:self options:nil];
        contactCell = topLevelObjects[0];
        [contactCell._iconCheckBox setDelegate: self];
    }
    [contactCell setFrame: CGRectMake(contactCell.frame.origin.x, contactCell.frame.origin.y, _listTableView.frame.size.width, hCell)];
    [contactCell setupUIForCell];
    [contactCell._imgAvatar.layer setCornerRadius:(hCell-10)/2];
    [contactCell setSelectionStyle: UITableViewCellSelectionStyleNone];
    
    ContactObject *contact = [[_contactSections valueForKey:[[[_contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    //  get status cho user
    NSString *status = [self getStatusOfUser: contact._sipPhone];
    [contactCell._lbContactPhone setText: status];
    
    //  Tên contact
    if (![contact._fullName isEqualToString:@""]) {
        [contactCell._lbContactName setText: contact._fullName];
    }else{
        [contactCell._lbContactName setText: [localization localizedStringForKey:text_unknown]];
    }
    
    if (contact._avatar == nil || [contact._avatar isEqualToString:@""] || [contact._avatar isEqualToString:@"(null)"] || [contact._avatar isEqualToString:@"<null>"] || [contact._avatar isEqualToString:@"null"])
    {
        [contactCell._imgAvatar setImage:[UIImage imageNamed:@"no_avatar.png"]];
    }else{
        [contactCell._imgAvatar setImage:[UIImage imageWithData:[NSData dataFromBase64String:contact._avatar]]];
    }
    [contactCell setTag: indexPath.row];
    [contactCell set_cloudfoneID: contact._sipPhone];
    [contactCell._iconCheckBox setTag:contact._id_contact];
    [contactCell._iconCheckBox setValue:indexPath forKey:@"indexPath"];
    
    
    if ([listMemberAdd containsObject: contact._sipPhone]) {
        [contactCell._iconCheckBox setOn:true];
    }else{
        [contactCell._iconCheckBox setOn:false];
    }
    return contactCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactObject *contact = [[_contactSections valueForKey:[[[_contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    if (![listMemberAdd containsObject: contact._sipPhone]) {
        [listMemberAdd addObject: contact._sipPhone];
    }else{
        [listMemberAdd removeObject: contact._sipPhone];
    }
    [_listTableView reloadData];

    if (listMemberAdd.count == 0) {
        [_iconDone setHidden: true];
    }else{
        [_iconDone setHidden: false];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
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
    [descLabel setFont: textFont];
    [descLabel setText: titleHeader];
    [descLabel setBackgroundColor:[UIColor clearColor]];
    [headerView addSubview: descLabel];
    return headerView;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [[_contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

#pragma mark - MY FUNCTIONS

- (void)showContentWithCurrentLanguage {
    [_lbTitle setText: [localization localizedStringForKey:text_select_contact]];
    [_lbSearch setText: [localization localizedStringForKey:text_search_contact]];
    [_lbNoContacts setText: [localization localizedStringForKey:text_list_friend_no_contacts]];
}

//  tạo group trên server thành công -> Lưu group xuống database
- (void)createGroupSuccessfully {
    if ([[[PhoneMainView instance] currentView] isEqual:[self compositeViewDescription]])
    {
        BOOL success = [NSDatabase createRoomChatInDatabase:roomName andGroupName:roomName
                                                withSubject:@""];
        if (success) {
            int idRoomChat = [NSDatabase getIdRoomChatWithRoomName: roomName];
            [[LinphoneAppDelegate sharedInstance] setIdRoomChat: idRoomChat];
            
            //  Add mình vào bảng room_user
            [NSDatabase saveUser: USERNAME toRoomChat: roomName forAccount: USERNAME];
            
            //  Mời các user đã add vào group
            NSString *currentUser = [AppUtils getSipFoneIDFromString: [LinphoneAppDelegate sharedInstance].friendBuddy.accountName];
            if (![listMemberAdd containsObject: currentUser]) {
                [listMemberAdd addObject: currentUser];
            }
            [[LinphoneAppDelegate sharedInstance].myBuddy.protocol inviteUserToGroupChat:roomName andListUser: listMemberAdd];
            
            [[LinphoneAppDelegate sharedInstance].myBuddy.protocol changeNameOfTheRoom:roomName withNewName: roomName];
            [[LinphoneAppDelegate sharedInstance].myBuddy.protocol changeSubjectOfTheRoom:roomName withSubject: @""];
            
            //  Lưu message tham gia vào phòng chat
            /*
            NSString *idMessage = [AppFunctions randomStringWithLength: 10];
            NSString *time = [AppFunctions getCurrentTimeStamp];
            NSString *msgContent = [NSString stringWithFormat:@"%@ %@", [localization localizedStringForKey:text_joined_room_at], time];
            
            [NSDatabase saveMessage:@"" toPhone:USERNAME  withContent:msgContent andStatus:YES withDelivered:2 andIdMsg:idMessage detailsUrl:@"" andThumbUrl:@"" withTypeMessage:descriptionMessage andExpireTime:5 andRoomID:[NSString stringWithFormat:@"%d", [LinphoneAppDelegate sharedInstance].idRoomChat] andExtra:@"" andDesc: nil];
            */
            [[PhoneMainView instance] changeCurrentView:GroupMainChatViewController.compositeViewDescription];
        }
    }
}

//  Hàm cập nhật giá trị cho _addFromGroupChat
- (void)updateValueForController: (BOOL)value {
    _addFromGroupChat = value;
}

//  get section cho danh sách
- (void)getSectionForContactList: (NSMutableArray *)contactList {
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

//  custom các UI trong view
- (void)setupUIForView
{
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:HelveticaNeue size:18.0];
    }else{
        textFont = [UIFont fontWithName:HelveticaNeue size:16.0];
    }
    
    hSearch = 60.0;
    
    //  view header
    [_viewHeader setFrame: CGRectMake(0, 0, SCREEN_WIDTH, [LinphoneAppDelegate sharedInstance]._hHeader)];
    [_iconBack setFrame: CGRectMake(0, ([LinphoneAppDelegate sharedInstance]._hHeader-40.0)/2, 40.0, 40.0)];
    [_iconBack setBackgroundImage:[UIImage imageNamed:@"ic_back_act.png"]
                         forState:UIControlStateHighlighted];
    
    [_iconDone setFrame: CGRectMake(_viewHeader.frame.size.width-[LinphoneAppDelegate sharedInstance]._hHeader, _iconBack.frame.origin.y, _iconBack.frame.size.width, _iconBack.frame.size.height)];
    [_iconDone setBackgroundImage:[UIImage imageNamed:@"ic_done_act.png"]
                         forState:UIControlStateHighlighted];
    
    [_lbTitle setFrame: CGRectMake(_iconBack.frame.origin.x+_iconBack.frame.size.width+5, 0, _viewHeader.frame.size.width-(_iconBack.frame.origin.x+_iconBack.frame.size.width)*2 - 10, [LinphoneAppDelegate sharedInstance]._hHeader)];
    [_lbTitle setFont:[UIFont fontWithName:HelveticaNeue size:19.0]];
    
    //  view search
    [_viewSearch setFrame: CGRectMake(0, _viewHeader.frame.origin.y+_viewHeader.frame.size.height, SCREEN_WIDTH, hSearch)];
    [_bgSearch setFrame: CGRectMake(0, 0, _viewSearch.frame.size.width, _viewSearch.frame.size.height)];
    [_iconSearch setFrame: CGRectMake(10, (hSearch-30)/2, 30, 30)];
    [_tfSearch setFrame: CGRectMake(_iconSearch.frame.origin.x+_iconSearch.frame.size.width+5, _iconSearch.frame.origin.y, _viewSearch.frame.size.width-(3*_iconSearch.frame.origin.x+_iconSearch.frame.size.width), _iconSearch.frame.size.height)];
    [_tfSearch setFont: textFont];
    [_tfSearch setBorderStyle: UITextBorderStyleNone];
    
    [_tfSearch addTarget:self
                  action:@selector(whenSearchTextfieldChanged:)
        forControlEvents:UIControlEventEditingChanged];
    
    [_lbSearch setFrame: _tfSearch.frame];
    [_lbSearch setFont: textFont];
    
    
    [_iconClear setFrame: CGRectMake(_tfSearch.frame.origin.x+_tfSearch.frame.size.width-_tfSearch.frame.size.height, _tfSearch.frame.origin.y, _tfSearch.frame.size.height, _tfSearch.frame.size.height)];
    [_iconClear setHidden: true];
    
    [_lbNoContacts setFrame: CGRectMake(0, _viewSearch.frame.origin.y+_viewSearch.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT-([LinphoneAppDelegate sharedInstance]._hStatus+[LinphoneAppDelegate sharedInstance]._hHeader+hSearch))];
    [_lbNoContacts setFont: textFont];
    [_lbNoContacts setTextColor:[UIColor grayColor]];
    [_lbNoContacts setHidden: true];
    
    UITapGestureRecognizer *tapToClose = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToCloseKeyboard)];
    [_lbNoContacts setUserInteractionEnabled: true];
    [_lbNoContacts addGestureRecognizer: tapToClose];
    
    [_listTableView setFrame: _lbNoContacts.frame];
    [_listTableView setDelegate: self];
    [_listTableView setDataSource: self];
    [_listTableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
    if ([_listTableView respondsToSelector:@selector(setSectionIndexColor:)]) {
        [_listTableView setSectionIndexColor: [UIColor grayColor]];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            [_listTableView setSectionIndexBackgroundColor:[UIColor whiteColor]];
        }
    }
}

//  Search
- (void)whenSearchTextfieldChanged: (UITextField *)textField {
    if (textField.text.length == 0) {
        isSearching = false;
        [_iconClear setHidden: true];
        [_lbSearch setHidden: false];
        [_listTableView reloadData];
    }else{
        isSearching = true;
        [_iconClear setHidden: false];
        [_lbSearch setHidden: true];
        
        [searchTimer invalidate];
        searchTimer = nil;
        searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self
                                                     selector:@selector(startSearchCloudFoneUser)
                                                     userInfo:nil repeats:false];
    }
}

- (void)startSearchCloudFoneUser {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self searchPhoneBook];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (_listSearch.count > 0) {
                [_listTableView setHidden: false];
                [_lbNoContacts setHidden: true];
            }else{
                [_listTableView setHidden: true];
                [_lbNoContacts setHidden: false];
            }
        });
    });
}

- (void)searchPhoneBook {
    if (_listSearch == nil) {
        _listSearch = [[NSMutableArray alloc] init];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_fullName contains[cd] %@ OR _sipPhone contains[cd] %@",_tfSearch.text, _tfSearch.text];
    [_listSearch removeAllObjects];
    [_listSearch addObjectsFromArray:[[LinphoneAppDelegate sharedInstance].sipContacts filteredArrayUsingPredicate:predicate]];
}

- (void)afterInsertContactSucessfully {
    if (_listSearch.count == 0) {
        [_lbNoContacts setHidden: false];
        [_listTableView setHidden: true];
    }else{
        [_lbNoContacts setHidden: true];
        [_listTableView setHidden: false];
        [_listTableView reloadData];
    }
}

//  Get trạng thái của user
- (NSString *)getStatusOfUser: (NSString *)callnexID {
    if ([callnexID isEqualToString: @""] || callnexID == nil) {
        return welcomeToCloudFone;
    }else{
        NSString *statusStr = callnexID;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName CONTAINS[cd] %@", callnexID];
        NSMutableDictionary *listUserDict = [[[OTRProtocolManager sharedInstance] buddyList] allBuddies];
        NSArray *listUser = [OTRBuddyList sortBuddies: listUserDict];
        NSArray *resultArr = [listUser filteredArrayUsingPredicate: predicate];
        if (resultArr.count > 0) {
            OTRBuddy *curBuddy = [resultArr objectAtIndex: 0];
            if (curBuddy.status == kOTRBuddyStatusAvailable || curBuddy.status == kOTRBuddyStatusAvailable) {
                statusStr = [[LinphoneAppDelegate sharedInstance]._statusXMPPDict objectForKey: callnexID];
                if (statusStr == nil || [statusStr isEqualToString:@""]) {
                    statusStr = welcomeToCloudFone;
                }
            }
        }
        return statusStr;
    }
}

//  show thông báo lên màn hình
- (void)showMessagePopupUp: (NSString *)message {
    CGSize contentSize = [message sizeWithFont:textFont
                             constrainedToSize:CGSizeMake(260, 9999)
                                 lineBreakMode:NSLineBreakByWordWrapping];
    
    if (showMessageView == nil) {
        showMessageView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-(contentSize.width+20))/2, SCREEN_HEIGHT-20-100, contentSize.width+20, contentSize.height+20)];
        [showMessageView setBackgroundColor:[UIColor blackColor]];
        
        lbTextMsg = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, contentSize.width, contentSize.height+20)];
        [lbTextMsg setBackgroundColor:[UIColor clearColor]];
        [lbTextMsg setTextColor:[UIColor whiteColor]];
        [lbTextMsg setFont: textFont];
        [lbTextMsg setTextAlignment: NSTextAlignmentCenter];
        [lbTextMsg setNumberOfLines:5];
        
        [showMessageView addSubview: lbTextMsg];
        [self.view addSubview: showMessageView];
    }else{
        [showMessageView setFrame:CGRectMake((SCREEN_WIDTH-(contentSize.width+20))/2, SCREEN_HEIGHT-20-100, contentSize.width+20, contentSize.height+20)];
        [lbTextMsg setFrame:CGRectMake(10, 0, contentSize.width, contentSize.height+20)];
    }
    
    [showMessageView setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
    [showMessageView setAlpha: 0.0];
    [lbTextMsg setText: message];
    [UIView animateWithDuration:1.0f animations:^{
        [showMessageView setAlpha: 1.0];
    }completion:^(BOOL finish){
        [self hideMessagePopup];
    }];
}

//  Ẩn thông báo
- (void)hideMessagePopup {
    [UIView animateWithDuration:3.0f animations:^{
        [showMessageView setTransform:CGAffineTransformMakeScale(1, 1)];
        [showMessageView setAlpha: 0.0];
    }];
}


#pragma mark - BEMCheckBox Delegate
- (void)didTapCheckBox:(BEMCheckBox *)checkBox {
    NSIndexPath *indexPath = [checkBox valueForKey:@"indexPath"];
    
    ContactObject *contact = [[_contactSections valueForKey:[[[_contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    if (![listMemberAdd containsObject: contact._sipPhone]) {
        [listMemberAdd addObject: contact._sipPhone];
    }else{
        [listMemberAdd removeObject: contact._sipPhone];
    }
    [_listTableView reloadData];
    
    if (listMemberAdd.count == 0) {
        [_iconDone setHidden: true];
    }else{
        [_iconDone setHidden: false];
    }
}

- (void)tapToCloseKeyboard {
    [self.view endEditing: true];
}

@end
