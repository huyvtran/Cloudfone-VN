//
//  ChooseContactsViewController.m
//  linphone
//
//  Created by admin on 1/8/18.
//

#import "ChooseContactsViewController.h"
#import "MainChatViewController.h"
#import "PhoneMainView.h"
#import "ChooseContactCell.h"
#import "MessageCellForListChat.h"

#import "OTRBuddy.h"
#import "OTRXMPPManager.h"
#import "OTRBuddyList.h"
#import "OTRBoolSetting.h"

//#import "KChatsViewController.h"
#import "NSDatabase.h"
#import "ContactObject.h"
#import <QuartzCore/QuartzCore.h>
#import "NSData+Base64.h"
#import "OTRProtocolManager.h"
#import "StatusBarView.h"
#import "GroupMainChatViewController.h"
#import "JSONKit.h"

@interface ChooseContactsViewController (){
    LinphoneAppDelegate *appDelegate;
    float hSearch;
    
    NSTimer *searchTimer;
    
    BOOL isFound;
    BOOL found;
    
    NSMutableArray *userInfo;
    NSMutableArray *arrLabelContact;
    
    NSString *callnexID;
    /*--String de send tracking--*/
    NSString *accountStr;
    
    NSMutableArray *listFiltered;
    BOOL isFiltered;
    
    float hCell;
    float hSection;
    
    NSArray *listCharacter;
    BOOL isSearching;
    
    NSMutableArray *listSelect;
    NSString *roomName;
    NSString *groupName;
    UIFont *textFont;
}

@end

@implementation ChooseContactsViewController
@synthesize _viewHeader, _iconBack, _lbHeader, _iconDone;
@synthesize _viewSearch, _bgSearch, _imgSearch, _tfSearch, _lbSearch, _iconClear;
@synthesize _tbContents, _lbNoContact;
@synthesize _contactSections, _searchResults, _isForwardMessage, _idForwardMessage;
@synthesize addFromRoomChat, listMembers;

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

#pragma mark - Controller delegate and Functions
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = BUDDY_LIST_STRING;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // MY CODE HERE
    appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    listCharacter = [[NSArray alloc] initWithObjects: @"A", @"B", @"C", @"D", @"E", @"F",
                     @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
    
    _contactSections = [[NSMutableDictionary alloc] init];
    
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated {
    // Tắt màn hình cảm biến
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled: NO];

    if (listSelect == nil) {
        listSelect = [[NSMutableArray alloc] init];
    }else{
        [listSelect removeAllObjects];
    }
    
    [_tfSearch setText: @""];
    [_iconClear setHidden: true];
    [_iconDone setHidden: true];
    [_lbSearch setHidden: false];
    
    [self startSearchCloudFoneContacts];
    
    // get data cho tableview
    isFiltered = NO;
    if (appDelegate.sipContacts.count > 0) {
        [_tbContents reloadData];
        [_tbContents setHidden: NO];
        [_lbNoContact setHidden: YES];
    }else{
        [_tbContents setHidden: YES];
        [_lbNoContact setHidden: NO];
    }
    
    //  notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buddyListUpdate)
                                                 name:kOTRBuddyListUpdate object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createGroupSuccessfully:)
                                                 name:k11CreateGroupChatSuccessfully object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)_iconBackClicked:(UIButton *)sender {
    [[PhoneMainView instance] popCurrentView];
}

- (IBAction)_iconDoneClicked:(UIButton *)sender
{
    if (_isForwardMessage) {
        [self sendMessageForward: _idForwardMessage];
        [self.view makeToast:[appDelegate.localization localizedStringForKey:text_successfully]
                    duration:1.5 position:CSToastPositionCenter title:nil image:nil style:nil completion:^(BOOL didTap) {
                        [[PhoneMainView instance] popCurrentView];
                    }];
    }else{
        if (appDelegate.supportGroupChat) {
            if (addFromRoomChat) {
                XMPPRoom *room = [AppUtils searchRoomFromId:[NSString stringWithFormat:@"%@@%@", appDelegate.roomChatName, xmpp_cloudfone_group]];
                if (room != nil) {
                    for(int iCount=0; iCount<listSelect.count; iCount++)
                    {
                        NSString *newjid = [NSString stringWithFormat:@"%@@%@", [listSelect objectAtIndex:iCount], xmpp_cloudfone];
                        [room editRoomPrivileges:@[[XMPPRoom itemWithAffiliation:@"owner" jid:[XMPPJID jidWithString:newjid]]]];
                        [room inviteUser:[XMPPJID jidWithString:newjid] withMessage:@"join this room"];
                    }
                    [[PhoneMainView instance] popCurrentView];
                }
            }else{
                appDelegate.reloadMessageList = TRUE;
                
                if (listSelect.count == 0) {
                    if (_tfSearch.text.length >= 10 && [_tfSearch.text hasPrefix:@"778899"]) {
                        appDelegate.reloadMessageList = YES;
                        appDelegate.friendBuddy = [AppUtils getBuddyOfUserOnList: _tfSearch.text];
                        [[PhoneMainView instance] changeCurrentView:[MainChatViewController compositeViewDescription]
                                                               push:true];
                    }
                }else if (listSelect.count == 1){
                    NSString *user = [listSelect objectAtIndex: 0];
                    if (user != nil && ![user isEqualToString:@""]) {
                        appDelegate.reloadMessageList = YES;
                        appDelegate.friendBuddy = [AppUtils getBuddyOfUserOnList: user];
                        [[PhoneMainView instance] changeCurrentView:[MainChatViewController compositeViewDescription]
                                                               push:true];
                    }
                }
                else{
                    groupName = @"";
                    for (int iCount=0; iCount<listSelect.count; iCount++) {
                        NSString *sipPhone = [listSelect objectAtIndex: iCount];
                        NSString *contactName = [NSDatabase getNameOfContactWithPhoneNumber: sipPhone];
                        if ([groupName isEqualToString:@""]) {
                            groupName = contactName;
                        }else{
                            groupName = [NSString stringWithFormat:@"%@, %@", groupName, contactName];
                        }
                    }
                    
                    roomName = [NSString stringWithFormat:@"%@_%@", USERNAME , [AppUtils randomStringWithLength: 10]];
                    roomName = [roomName lowercaseString];
                    
                    //  Tạo group chat và lưu xuống database
                    [appDelegate.myBuddy.protocol createGroupOfMe:USERNAME andGroupName:roomName];
                    appDelegate.reloadMessageList = TRUE;
                }
            }
        }else{
            [self.view makeToast:[appDelegate.localization localizedStringForKey:TEXT_OTR_NOT_SUPPORTED]
                        duration:2.0 position:CSToastPositionCenter];
        }
    }
}

- (IBAction)_iconClearClicked:(UIButton *)sender {
    [self.view endEditing: true];
    [_tfSearch setText: @""];
    [_iconClear setHidden: true];
    
    [_lbSearch setHidden: false];
    [_iconDone setHidden: true];
    [_tbContents setHidden: true];
    [_tbContents reloadData];
}

#pragma mark - my functions

- (void)sendMessageForward: (NSString *)idMessage {
    MessageEvent *message = [NSDatabase getMessageEventWithId: idMessage];
    
    int delivered = 0;
    if (appDelegate.xmppStream.isConnected) {
        delivered = 1;
    }
    
    for (int iCount=0; iCount<listSelect.count; iCount++) {
        NSString *receivePhone = [listSelect objectAtIndex: iCount];
        NSString *idMsgImage = [NSString stringWithFormat:@"userimage_%@", [AppUtils randomStringWithLength: 20]];
        
        [NSDatabase saveMessage:USERNAME toPhone:receivePhone withContent:message.content andStatus:YES withDelivered:delivered andIdMsg:idMsgImage detailsUrl:message.detailsUrl andThumbUrl:message.thumbUrl withTypeMessage:message.typeMessage andExpireTime:0 andRoomID:@"" andExtra:nil andDesc:message.description];
        
        int burn = [AppUtils getBurnMessageValueOfRemoteParty: receivePhone];
        
        // send message
        if ([message.typeMessage isEqualToString:videoMessage]) {
            [appDelegate.myBuddy.protocol sendMessageMediaForUser:receivePhone withLinkImage:message.detailsUrl andDescription:message.description andIdMessage:idMsgImage andType:@"uservideo" withBurn:burn forGroup:NO];
            
            NSString *displayName = [NSDatabase getProfielNameOfAccount:USERNAME];
            NSString *strPush = strPush = [NSString stringWithFormat:@"%@ %@", displayName, [appDelegate.localization localizedStringForKey:sent_video_to_you]];
            [AppUtils sendMessageForOfflineForUser:receivePhone fromSender:USERNAME withContent:message.content andTypeMessage:@"uservideo" withGroupID:@""];
        }else if ([message.typeMessage isEqualToString: imageMessage])
        {
            [appDelegate.myBuddy.protocol sendMessageMediaForUser:receivePhone withLinkImage:message.detailsUrl andDescription:message.description andIdMessage:idMsgImage andType:userimage withBurn:burn forGroup:NO];
            //  push message content
            NSString *displayName = [NSDatabase getProfielNameOfAccount:USERNAME];
            NSString *strPush = [NSString stringWithFormat:@"%@ %@", displayName, [appDelegate.localization localizedStringForKey:sent_photo_to_you]];
            [AppUtils sendMessageForOfflineForUser:receivePhone fromSender:USERNAME withContent:strPush andTypeMessage:userimage withGroupID:@""];
        }else{
            [appDelegate.friendBuddy sendMessage: message.content secure:NO withIdMessage:idMsgImage];
            
            NSString *displayName = [NSDatabase getProfielNameOfAccount:USERNAME];
            NSString *strPush = [NSString stringWithFormat:@"%@: %@", displayName, message.content];
            [AppUtils sendMessageForOfflineForUser:receivePhone fromSender:USERNAME withContent:strPush andTypeMessage:@"text" withGroupID:@""];
        }
    }
}

//  SỰ KIỆN NHẬP SỐ VÀO TEXTFIELD NUMBER
- (void)whenTextFieldDidChange: (UITextField *)textField {
    if (textField.text.length == 0) {
        isSearching = NO;
        _iconDone.hidden = YES;
        _iconClear.hidden = YES;
        _lbSearch.hidden = NO;
        
        [_tbContents reloadData];
    }else{
        isSearching = YES;
        _iconDone.hidden = NO;
        _iconClear.hidden = NO;
        _lbSearch.hidden = YES;
        
        [searchTimer invalidate];
        searchTimer = nil;
        searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self
                                                     selector:@selector(startSearchCloudFoneContacts)
                                                     userInfo:nil repeats:NO];
    }
}

//  Tìm liên hệ cloudfone
- (void)startSearchCloudFoneContacts {
    NSString *strSearch = _tfSearch.text;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self searchPhoneBookWithText: strSearch];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (_searchResults.count == 0) {
                [_tbContents setHidden: true];
                [_lbNoContact setHidden: false];
            }else{
                [_tbContents setHidden: false];
                [_lbNoContact setHidden: true];
                [_tbContents reloadData];
            }
        });
    });
}

- (void)searchPhoneBookWithText: (NSString *)searchContent {
    if (_searchResults == nil) {
        _searchResults = [[NSMutableArray alloc] init];
    }
    if (![searchContent isEqualToString:@""]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_fullName contains[cd] %@ OR _sipPhone contains[cd] %@",_tfSearch.text, _tfSearch.text];
        [_searchResults removeAllObjects];
        [_searchResults addObjectsFromArray:[appDelegate.sipContacts filteredArrayUsingPredicate:predicate]];
    }else{
        [_searchResults addObjectsFromArray: appDelegate.sipContacts];
    }
}

- (void)setupUIForView {
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
        hCell = 60.0;
        hSection = 30.0;
    }else{
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
        hCell = 60.0;
        hSection = 20.0;
    }
    
    hSearch = 60.0;
    
    // set font cho tiêu đề
    [_viewHeader setFrame: CGRectMake(0, 0, SCREEN_WIDTH, appDelegate._hHeader)];
    [_iconBack setFrame: CGRectMake(0, (appDelegate._hHeader-40.0)/2, 40.0, 40.0)];
    [_iconBack setBackgroundImage:[UIImage imageNamed:@"ic_back_act.png"]
                         forState:UIControlStateHighlighted];
    
    [_iconDone setFrame: CGRectMake(_viewHeader.frame.size.width-appDelegate._hHeader, _iconBack.frame.origin.y, _iconBack.frame.size.width, _iconBack.frame.size.height)];
    [_iconDone setBackgroundImage:[UIImage imageNamed:@"ic_done_act.png"]
                         forState:UIControlStateHighlighted];
    
    [_lbHeader setFrame: CGRectMake(_iconBack.frame.origin.x+_iconBack.frame.size.width+5, 0, _viewHeader.frame.size.width-(2*_iconBack.frame.origin.x+2*_iconBack.frame.size.width+10), appDelegate._hHeader)];
    [_lbHeader setFont:[UIFont fontWithName:HelveticaNeue size:18.0]];
    _lbHeader.text = [appDelegate.localization localizedStringForKey:@"Choose contacts"];
    
    //  view search
    [_viewSearch setFrame: CGRectMake(0, _viewHeader.frame.origin.y+_viewHeader.frame.size.height, SCREEN_WIDTH, hSearch)];
    [_bgSearch setFrame: CGRectMake(0, 0, _viewHeader.frame.size.width, hSearch)];
    [_imgSearch setFrame: CGRectMake(10, (hSearch-30)/2, 30, 30)];
    [_tfSearch setFrame: CGRectMake(_imgSearch.frame.origin.x+_imgSearch.frame.size.width+5, _imgSearch.frame.origin.y, _viewSearch.frame.size.width-(2*_imgSearch.frame.origin.x+2*_imgSearch.frame.size.width+10), _imgSearch.frame.size.height)];
    [_tfSearch setFont: textFont];
    [_tfSearch setBackgroundColor:[UIColor clearColor]];
    [_tfSearch setBorderStyle: UITextBorderStyleNone];
    
    [_tfSearch addTarget:self
                  action:@selector(whenTextFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    [_iconClear setFrame: CGRectMake(_tfSearch.frame.origin.x+_tfSearch.frame.size.width+5, _imgSearch.frame.origin.y, _imgSearch.frame.size.width, _imgSearch.frame.size.height)];
    
    [_lbSearch setFrame: _tfSearch.frame];
    [_lbSearch setFont: textFont];
    [_lbSearch setText: [appDelegate.localization localizedStringForKey:text_search_contact]];
    
    // setup cho tableview
    [_tbContents setFrame: CGRectMake(0, _viewSearch.frame.origin.y+_viewSearch.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT-(appDelegate._hStatus+appDelegate._hHeader+hSearch))];
    [_tbContents setDelegate: self];
    [_tbContents setDataSource: self];
    if ([_tbContents respondsToSelector:@selector(setSectionIndexColor:)]) {
        [_tbContents setSectionIndexColor: [UIColor grayColor]];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            [_tbContents setSectionIndexBackgroundColor:[UIColor whiteColor]];
        }
    }
    [_tbContents setSeparatorStyle: UITableViewCellSeparatorStyleNone];
    [_lbNoContact setFrame: _tbContents.frame];
    [_lbNoContact setTextColor:[UIColor darkGrayColor]];
    [_lbNoContact setFont: textFont];
    [_lbNoContact setText: [appDelegate.localization localizedStringForKey:text_no_contact]];
}

#pragma mark - uiscrollview delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing: true];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self.view endEditing: true];
}

#pragma mark - tableview delegate and Functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (isSearching) {
        [self getSectionForContactList: _searchResults];
    }else{
        [self getSectionForContactList: appDelegate.sipContacts];
    }
    return [[_contactSections allKeys] count];
}

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[_contactSections valueForKey:[[[_contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section]] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ContactCellIdentifier = @"ChooseContactCell";
    ContactObject *contact = [[ContactObject alloc] init];
    
    ChooseContactCell *contactCell = [tableView dequeueReusableCellWithIdentifier: ContactCellIdentifier];
    if (contactCell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ChooseContactCell" owner:self options:nil];
        contactCell = topLevelObjects[0];
        [contactCell setupUIForCell];
    }
    [contactCell setSelectionStyle: UITableViewCellSelectionStyleNone];
    [contactCell setFrame: CGRectMake(contactCell.frame.origin.x, contactCell.frame.origin.y, _tbContents.frame.size.width, hCell)];
    [contactCell setupUIForCell];
    
    
    contact = [[_contactSections valueForKey:[[[self._contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    contactCell._lbName.text = [NSString stringWithFormat:@"%@",contact._fullName];
    contactCell._lbMember.text = [appDelegate.localization localizedStringForKey:text_is_member];
    // Get status cho user
    NSArray *stateArr = [self getStateOfUserOnList: contact._sipPhone];
    NSString *statusStr = [stateArr objectAtIndex: 0];
    contactCell._lbPhone.text = statusStr;
    
    [contactCell setTag: contact._id_contact];
    
    if (contact._avatar == nil || [contact._avatar isEqualToString:@""] || [contact._avatar isEqualToString:@"(null)"] || [contact._avatar isEqualToString:@"<null>"] || [contact._avatar isEqualToString:@"null"])
    {
        contactCell._imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
    }else{
        NSData *imageData = [NSData dataFromBase64String:contact._avatar];
        contactCell._imgAvatar.image = [UIImage imageWithData: imageData];
    }
    
    if (addFromRoomChat) {
        if ([listMembers containsObject:contact._sipPhone]) {
            contactCell._lbMember.hidden = NO;
            contactCell._imgSelect.hidden = YES;
        }else{
            contactCell._lbMember.hidden = YES;
            contactCell._imgSelect.hidden = NO;
        }
    }else{
        contactCell._lbMember.hidden = YES;
        contactCell._imgSelect.hidden = NO;
    }
    
    return contactCell;
}

- (NSString*)getNameFromDisplayName: (NSString*)displayName {
    NSRange rangeName = [displayName rangeOfString:[NSString stringWithFormat:@"@%@", xmpp_cloudfone]];
    if (rangeName.location == NSNotFound) {
        return displayName;
    }else{
        return [displayName substringToIndex:rangeName.location];
    }
}

//  Kiểm tra đang thao tác transfer money hay là chat
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactObject *contact = [[_contactSections valueForKey:[[[self._contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    if (_isForwardMessage) {
        appDelegate.reloadMessageList = YES;
        ChooseContactCell *contactCell = [tableView cellForRowAtIndexPath: indexPath];
        
        if ([listSelect containsObject: contact._sipPhone]) {
            contactCell._imgSelect.image = [UIImage imageNamed:@"ic_uncheck"];
            [listSelect removeObject: contact._sipPhone];
        }else{
            contactCell._imgSelect.image = [UIImage imageNamed:@"ic_checked"];
            [listSelect addObject: contact._sipPhone];
        }
        
        if (listSelect.count > 0) {
            _lbHeader.text = [NSString stringWithFormat:@"%@ %d %@", [appDelegate.localization localizedStringForKey:@"Selected"], (int)listSelect.count, [appDelegate.localization localizedStringForKey:@"contacts"]];
            _iconDone.hidden = NO;
        }else{
            _lbHeader.text = [appDelegate.localization localizedStringForKey:@"Choose contacts"];
            _iconDone.hidden = YES;
        }
    }else{
        if (appDelegate.supportGroupChat) {
            //  Trường hợp thêm contact từ chat group
            if (addFromRoomChat) {
                //  Neu da la member thi ko xu ly
                if ([listMembers containsObject: contact._sipPhone]) {
                    return;
                }
                
                ChooseContactCell *contactCell = [tableView cellForRowAtIndexPath: indexPath];
                if ([listSelect containsObject: contact._sipPhone]) {
                    contactCell._imgSelect.image = [UIImage imageNamed:@"ic_uncheck"];
                    [listSelect removeObject: contact._sipPhone];
                }else{
                    contactCell._imgSelect.image = [UIImage imageNamed:@"ic_checked"];
                    [listSelect addObject: contact._sipPhone];
                }
                
                if (listSelect.count > 0) {
                    _lbHeader.text = [NSString stringWithFormat:@"%@ %d %@", [appDelegate.localization localizedStringForKey:@"Selected"], (int)listSelect.count, [appDelegate.localization localizedStringForKey:@"contacts"]];
                    _iconDone.hidden = NO;
                }else{
                    _lbHeader.text = [appDelegate.localization localizedStringForKey:@"Choose contacts"];
                    _iconDone.hidden = YES;
                }
                
            }else{
                //  Chọn contact để chat group
                appDelegate.reloadMessageList = YES;
                ChooseContactCell *contactCell = [tableView cellForRowAtIndexPath: indexPath];
                
                if ([listSelect containsObject: contact._sipPhone]) {
                    contactCell._imgSelect.image = [UIImage imageNamed:@"ic_uncheck"];
                    [listSelect removeObject: contact._sipPhone];
                }else{
                    contactCell._imgSelect.image = [UIImage imageNamed:@"ic_checked"];
                    [listSelect addObject: contact._sipPhone];
                }
                
                if (listSelect.count > 0) {
                    _lbHeader.text = [NSString stringWithFormat:@"%@ %d %@", [appDelegate.localization localizedStringForKey:@"Selected"], (int)listSelect.count, [appDelegate.localization localizedStringForKey:@"contacts"]];
                    _iconDone.hidden = NO;
                }else{
                    _lbHeader.text = [appDelegate.localization localizedStringForKey:@"Choose contacts"];
                    _iconDone.hidden = YES;
                }
            }
        }else{
            appDelegate.reloadMessageList = YES;
            appDelegate.friendBuddy = [AppUtils getBuddyOfUserOnList: contact._sipPhone];
            [[PhoneMainView instance] changeCurrentView:[MainChatViewController compositeViewDescription]
                                                   push:true];
        }
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [[_contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *titleHeader = [[[_contactSections allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, hSection)];
    [headerView setBackgroundColor:[UIColor colorWithRed:(240/255.0) green:(240/255.0)
                                                    blue:(240/255.0) alpha:1.0]];
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, hSection)];
    [descLabel setTextColor: [UIColor colorWithRed:(50/255.0) green:(50/255.0)
                                              blue:(50/255.0) alpha:1.0]];
    [descLabel setFont: [UIFont fontWithName:HelveticaNeue size:16.0]];
    [descLabel setText: titleHeader];
    [descLabel setBackgroundColor:[UIColor clearColor]];
    [headerView addSubview: descLabel];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return hSection;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return hCell;
}

#pragma mark - chat method

//  Cập nhật roster list
- (void)buddyListUpdate {
    if(![[OTRProtocolManager sharedInstance] buddyList]) {
        return;
    }
    [_tbContents reloadData];
}

- (IBAction)onBackClicked:(id)sender {
    //  Huỷ message forward trước đó đã chọn forward conversation
    appDelegate._msgForward = nil;
    
    [[PhoneMainView instance] popCurrentView];
}

//  Click vào icon clear search
- (void)clearSearchTextField {
    isFiltered = NO;
    [_tfSearch setText: @""];
    [_tfSearch endEditing: YES];
    [_iconClear setHidden: YES];
    [_tbContents reloadData];
}

- (IBAction)_btnCloseKeypadClicked:(id)sender {
    [_tfSearch setText:@""];
    [_iconClear setHidden: YES];
    isFiltered = NO;
    [_tbContents reloadData];
    [_tbContents setHidden: NO];
}

//  Lấy status của user
- (NSArray *)getStateOfUserOnList: (NSString *)callnexUser {
    if (callnexUser == nil || [callnexUser isEqualToString:@""]) {
        return [NSArray arrayWithObjects:@"",[NSNumber numberWithInt:-1], nil];
    }else{
        int status = -1;
        NSString *statusStr = callnexUser;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName contains[cd] %@", callnexUser];
        NSMutableDictionary *listUserDict = [[[OTRProtocolManager sharedInstance] buddyList] allBuddies];
        NSArray *listUser = [OTRBuddyList sortBuddies: listUserDict];
        NSArray *resultArr = [listUser filteredArrayUsingPredicate: predicate];
        if (resultArr.count > 0) {
            OTRBuddy *curBuddy = [resultArr objectAtIndex: 0];
            if (curBuddy.status == kOTRBuddyStatusOffline) {
                statusStr = callnexUser;
            }else{
                statusStr = [appDelegate._statusXMPPDict objectForKey: callnexUser];
                if (statusStr == nil || [statusStr isEqualToString:@""]) {
                    statusStr = welcomeToCloudFone;
                }
            }
            status = curBuddy.status;
        }
        return [NSArray arrayWithObjects:statusStr,[NSNumber numberWithInt:status], nil];
    }
}

#pragma mark - Khai Le functions

//  tạo group trên server thành công -> Lưu group xuống database
- (void)createGroupSuccessfully: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[XMPPRoom class]]) {
        XMPPRoom *room = (XMPPRoom *)object;
        BOOL success = [NSDatabase createRoomChatInDatabase:roomName andGroupName:groupName
                                                withSubject:@""];
        if (success) {
            NSString *key = [NSString stringWithFormat:@"GROUPS_%@", USERNAME];
            NSString *groupIds = [[NSUserDefaults standardUserDefaults] objectForKey: key];
            if (groupIds == nil || [groupIds isEqualToString:@""]) {
                groupIds = [NSString stringWithFormat:@"%@@%@", roomName, xmpp_cloudfone_group];
            }else{
                groupIds = [NSString stringWithFormat:@"%@,%@@%@", groupIds, roomName, xmpp_cloudfone_group];
            }
            [[NSUserDefaults standardUserDefaults] setObject:groupIds forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [appDelegate.myBuddy.protocol storeGroupDataToServer: groupIds];
            
            [room fetchConfigurationForm];
            [room configureRoomAtributes];
            
            for(int iCount=0; iCount<listSelect.count; iCount++)
            {
                NSString *newjid = [NSString stringWithFormat:@"%@@%@", [listSelect objectAtIndex:iCount], xmpp_cloudfone];
                [room editRoomPrivileges:@[[XMPPRoom itemWithAffiliation:@"owner" jid:[XMPPJID jidWithString:newjid]]]];
                [room inviteUser:[XMPPJID jidWithString:newjid] withMessage:@"join this room"];
            }
            
            [appDelegate.myBuddy.protocol changeSubjectOfTheRoom:roomName withSubject: groupName];
            
            int idRoomChat = [NSDatabase getIdRoomChatWithRoomName: roomName];
            appDelegate.idRoomChat = idRoomChat;
            appDelegate.roomChatName = roomName;
            appDelegate.reloadMessageList = YES;
            
            [[PhoneMainView instance] changeCurrentView:GroupMainChatViewController.compositeViewDescription];
        }
    }
}

@end
