//
//  PBXContactsViewController.m
//  linphone
//
//  Created by Apple on 5/11/17.
//
//

#import "PBXContactsViewController.h"
#import "NewContactViewController.h"
#import "PBXContactPopupView.h"
#import "JSONKit.h"
#import "PBXContact.h"
#import "PBXContactTableCell.h"
#import "DeleteContactPBXPopupView.h"
#import "PhoneMainView.h"
#import "UIImage+GKContact.h"

@interface PBXContactsViewController (){
    BOOL isSearching;
    
    float hCell;
    NSTimer *searchTimer;
    
    YBHud *waitingHud;
    UIFont *textFont;
    
    NSMutableArray *listSearch;
}

@end

@implementation PBXContactsViewController
@synthesize _lbContacts, _tbContacts;

- (void)viewDidLoad {
    [super viewDidLoad];
    //  my code here
    [self autoLayoutForView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    [self showContentWithCurrentLanguage];
    isSearching = NO;
    
    if (listSearch == nil) {
        listSearch = [[NSMutableArray alloc] init];
    }
    [listSearch removeAllObjects];
    
    if (![LinphoneAppDelegate sharedInstance].contactLoaded) {
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
    [_lbContacts setText:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_no_contact]];
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

//  Click sync pbx contact
- (void)clickSyncPBXContacts {

    
}

#pragma mark - UITableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (isSearching) {
        return [listSearch count];
    }else{
        NSSortDescriptor *sorter = [[NSSortDescriptor alloc]
                                     initWithKey:@"_name"
                                     ascending:YES
                                     selector:@selector(localizedCaseInsensitiveCompare:)];
        NSArray *sortDescriptors = [NSArray arrayWithObject: sorter];
        [[LinphoneAppDelegate sharedInstance].pbxContacts sortUsingDescriptors:sortDescriptors];
        
        return [[LinphoneAppDelegate sharedInstance].pbxContacts count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"PBXContactTableCell";
    PBXContactTableCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PBXContactTableCell" owner:self options:nil];
        cell = topLevelObjects[0];
    }
    
    PBXContact *contact;
    if (isSearching) {
        contact = [listSearch objectAtIndex:indexPath.row];
    }else{
        contact = [[LinphoneAppDelegate sharedInstance].pbxContacts objectAtIndex:indexPath.row];
    }
    
    // Tên contact
    if (contact._name != nil && ![contact._name isKindOfClass:[NSNull class]]) {
        cell._lbName.text = contact._name;
    }else{
        cell._lbName.text = @"";
    }
    
    if (contact._number != nil && ![contact._number isKindOfClass:[NSNull class]]) {
        cell._lbPhone.text = contact._number;
    }else{
        cell._lbPhone.text = @"";
    }
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, _tbContacts.frame.size.width, hCell);
    [cell updateUIForCell];
    
    if ([contact._name isEqualToString:@""]) {
        cell._imgAvatar.image = [UIImage imageForName:@"#" size: CGSizeMake(60, 60)];
    }else{
        NSString *firstChar = [contact._name substringToIndex:1];
        cell._imgAvatar.image = [UIImage imageForName:[firstChar uppercaseString] size: CGSizeMake(60, 60)];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PBXContact *contact;
    if (isSearching) {
        contact = [listSearch objectAtIndex:indexPath.row];
    }else{
        contact = [[LinphoneAppDelegate sharedInstance].pbxContacts objectAtIndex:indexPath.row];
    }
    [self callPBXWithNumber: contact._number];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return hCell;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeKeyboard" object:nil];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeKeyboard" object:nil];
}

- (void)callPBXWithNumber: (NSString *)pbxNumber {
    LinphoneAddress *addr = linphone_core_interpret_url(LC, pbxNumber.UTF8String);
    [LinphoneManager.instance call:addr];
    if (addr)
        linphone_address_destroy(addr);
    
    OutgoingCallViewController *controller = VIEW(OutgoingCallViewController);
    if (controller != nil) {
        [controller setPhoneNumberForView: pbxNumber];
    }
    [[PhoneMainView instance] changeCurrentView:[OutgoingCallViewController compositeViewDescription] push:TRUE];
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
            [self startSearchPBXContactsWithContent: object];
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [_tbContacts reloadData];
            });
        });
    }
}

- (void)startSearchPBXContactsWithContent: (NSString *)content {
    [listSearch removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_name CONTAINS[cd] %@ OR _number CONTAINS[cd] %@", content, content];
    NSArray *filter = [[LinphoneAppDelegate sharedInstance].pbxContacts filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        [listSearch addObjectsFromArray: filter];
    }
    
    if (listSearch.count > 0) {
        [_lbContacts setHidden: true];
        [_tbContacts setHidden: false];
        [_tbContacts reloadData];
    }else{
        [_lbContacts setHidden: false];
        [_tbContacts setHidden: true];
    }
}

@end
