//
//  iPadContactDetailViewController.m
//  linphone
//
//  Created by admin on 1/12/19.
//

#import "iPadContactDetailViewController.h"
#import "iPadEditContactViewController.h"
#import "NSData+Base64.h"
#import "UIContactPhoneCell.h"
#import "ContactDetailObj.h"
#import "UIKContactCell.h"

@interface iPadContactDetailViewController () {
    BOOL isPBXContact;
    UIBarButtonItem *icEdit;
    
    UIView *viewFooter;
    UIButton *btnDeleteContact;
}

@end

@implementation iPadContactDetailViewController
@synthesize viewHeader, imgAvatar, lbName, btnCall, btnSendMessage, tbDetail, tbPBXDetail;
@synthesize detailsContact, detailsPBXContact;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupUIForView];
    [self createEditContactButtonForView];
    [self createFooterViewForTable];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    self.title = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Contact info"];
    [self registerNotifications];
    
    self.navigationItem.rightBarButtonItem = nil;
    
    if (detailsPBXContact != nil) {
        [self displayPBXContactInformation];
    }else if (detailsContact != nil) {
        [self displayContactInformation];
    }
    
    if ([LinphoneAppDelegate sharedInstance].idContact != 0) {
        self.navigationItem.rightBarButtonItem = icEdit;
        
        detailsContact = [ContactUtils getContactWithId: [LinphoneAppDelegate sharedInstance].idContact];
        [self displayContactInformation];
        btnCall.enabled = NO;
        tbDetail.hidden = NO;
        tbPBXDetail.hidden = YES;
        [tbDetail reloadData];
    }
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)iconEditContactClicked {
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = newBackButton;
    
    iPadEditContactViewController *editContactVC = [[iPadEditContactViewController alloc] initWithNibName:@"iPadEditContactViewController" bundle:nil];
    [self.navigationController pushViewController:editContactVC animated:YES];
}

- (IBAction)icCallPBXClicked:(UIButton *)sender {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Call from %@ to %@", __FUNCTION__, USERNAME, sender.currentTitle] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    sender.backgroundColor = UIColor.whiteColor;
    [sender setTitleColor:IPAD_HEADER_BG_COLOR forState:UIControlStateNormal];
    
    [self performSelector:@selector(startCallAfterChangeBackground) withObject:nil afterDelay:0.1];
}

- (void)startCallAfterChangeBackground
{
    btnCall.backgroundColor = IPAD_HEADER_BG_COLOR;
    [btnCall setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    
    if ([AppUtils isNullOrEmpty: detailsPBXContact._number]) {
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"The phone number can not empty"] duration:2.0 position:CSToastPositionCenter];
    }else{
        NSString *number = [AppUtils removeAllSpecialInString: detailsPBXContact._number];
        if (![AppUtils isNullOrEmpty: number]) {
            [SipUtils makeCallWithPhoneNumber: number];
        }
    }
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayContactInformation:)
                                                 name:showContactInformation object:nil];
}

- (void)displayContactInformation: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[ContactObject class]]) {
        detailsContact = [ContactUtils getContactWithId: [(ContactObject *)object _id_contact]];
        if (![AppUtils isNullOrEmpty:detailsContact._sipPhone]) {
            isPBXContact = YES;
        }else{
            isPBXContact = NO;
        }
        
        [self displayContactInformation];
        btnCall.enabled = NO;
        tbDetail.hidden = NO;
        tbPBXDetail.hidden = YES;
        [tbDetail reloadData];
        
    }else if ([object isKindOfClass:[PBXContact class]]) {
        detailsPBXContact = (PBXContact *)object;
        [self displayPBXContactInformation];
        
        btnCall.enabled = YES;
        tbDetail.hidden = YES;
        tbPBXDetail.hidden = NO;
        [tbPBXDetail reloadData];
    }
}

- (void)displayPBXContactInformation
{
    lbName.text = detailsPBXContact._name;
    if ([AppUtils isNullOrEmpty: detailsPBXContact._avatar]) {
        imgAvatar.image = [UIImage imageNamed:@"avatar"];
    }else{
        imgAvatar.image = [UIImage imageWithData: [NSData dataFromBase64String: detailsPBXContact._avatar]];
    }
    
    //  [Khai Le - 14/02/2019]
    btnCall.enabled = YES;
    btnCall.backgroundColor = IPAD_HEADER_BG_COLOR;
    btnCall.layer.borderColor = IPAD_HEADER_BG_COLOR.CGColor;
    viewFooter.hidden = YES;
    self.navigationItem.rightBarButtonItem = nil;
    
    [LinphoneAppDelegate sharedInstance].idContact = 0;
}

- (void)displayContactInformation
{
    if ([detailsContact._fullName isEqualToString:@""] && ![detailsContact._sipPhone isEqualToString:@""]) {
        lbName.text = detailsContact._sipPhone;
    }else{
        lbName.text = detailsContact._fullName;
    }
    
    //  Avatar contact
    if ([AppUtils isNullOrEmpty: detailsContact._avatar]) {
        imgAvatar.image = [UIImage imageNamed:@"avatar"];
    }else{
        imgAvatar.image = [UIImage imageWithData: [NSData dataFromBase64String: detailsContact._avatar]];
    }
    
    //  [Khai Le - 14/02/2019]
    btnCall.enabled = NO;
    btnCall.backgroundColor = GRAY_COLOR;
    btnCall.layer.borderColor = GRAY_COLOR.CGColor;
    viewFooter.hidden = NO;
    self.navigationItem.rightBarButtonItem = icEdit;
    
    [LinphoneAppDelegate sharedInstance].idContact = detailsContact._id_contact;
}

- (void)setupUIForView {
    self.view.backgroundColor = viewHeader.backgroundColor = IPAD_BG_COLOR;
    [viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(140.0);
    }];
    
    float hAvatar = 100.0;
    float padding = 20.0;
    
    [ContactUtils addBorderForImageView:imgAvatar withRectSize:hAvatar strokeWidth:0 strokeColor:nil radius:4.0];
    
    [imgAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewHeader).offset(padding);
        make.centerY.equalTo(viewHeader.mas_centerY);
        make.width.height.mas_equalTo(hAvatar);
    }];
    
    lbName.font = [UIFont systemFontOfSize:24.0 weight:UIFontWeightThin];
    lbName.textColor = UIColor.blackColor;
    [lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgAvatar);
        make.left.equalTo(imgAvatar.mas_right).offset(padding);
        make.right.equalTo(viewHeader).offset(-padding);
        make.height.mas_equalTo(40.0);
    }];
    
    UIFont *btnFont = [UIFont systemFontOfSize:18.0 weight:UIFontWeightThin];
    CGSize textSize = [AppUtils getSizeWithText:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Call"] withFont:btnFont];
    if (textSize.width < 60) {
        textSize.width = 60.0;
    }
    
    btnCall.layer.cornerRadius = 40.0/2;
    btnCall.backgroundColor = IPAD_HEADER_BG_COLOR;
    [btnCall setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnCall.titleLabel.font = btnFont;
    btnCall.layer.borderColor = IPAD_HEADER_BG_COLOR.CGColor;
    btnCall.layer.borderWidth = 1.0;
    [btnCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbName.mas_bottom).offset(10.0);
        make.left.equalTo(lbName);
        make.width.mas_equalTo(textSize.width + 10.0);
        make.height.mas_equalTo(40.0);
    }];
    
    textSize = [AppUtils getSizeWithText:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Send message"] withFont:btnFont];
    if (textSize.width < 60) {
        textSize.width = 60.0;
    }
    
    btnSendMessage.layer.cornerRadius = btnCall.layer.cornerRadius;
    //  btnSendMessage.backgroundColor = IPAD_HEADER_BG_COLOR;
    btnSendMessage.backgroundColor = GRAY_COLOR;
    [btnSendMessage setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnSendMessage.titleLabel.font = btnFont;
    [btnSendMessage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(btnCall);
        make.left.equalTo(btnCall.mas_right).offset(10.0);
        make.width.mas_equalTo(textSize.width + 40.0);
    }];
    
    
    //  table contacts
    tbDetail.delegate = self;
    tbDetail.dataSource = self;
    tbDetail.separatorStyle = UITableViewCellSeparatorStyleNone;
    tbDetail.backgroundColor = UIColor.clearColor;
    [tbDetail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    //  table pbx detail
    tbPBXDetail.delegate = self;
    tbPBXDetail.dataSource = self;
    tbPBXDetail.separatorStyle = UITableViewCellSeparatorStyleNone;
    tbPBXDetail.backgroundColor = UIColor.clearColor;
    tbPBXDetail.scrollEnabled = NO;
    [tbPBXDetail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(tbDetail);
    }];
}

- (void)createEditContactButtonForView {
    UIButton *edit = [UIButton buttonWithType:UIButtonTypeCustom];
    edit.backgroundColor = UIColor.clearColor;
    [edit setImage:[UIImage imageNamed:@"ic_edit"] forState:UIControlStateNormal];
    edit.imageEdgeInsets = UIEdgeInsetsMake(15.0, 15.0, 15.0, 15.0);
    edit.frame = CGRectMake(17, 0, 50.0, 50.0 );
    [edit addTarget:self
             action:@selector(iconEditContactClicked)
   forControlEvents:UIControlEventTouchUpInside];
    
    UIView *editView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50.0, 50.0)];
    [editView addSubview: edit];
    
    icEdit = [[UIBarButtonItem alloc] initWithCustomView: editView];
    icEdit.customView.backgroundColor = UIColor.clearColor;
    self.navigationItem.rightBarButtonItem = icEdit;
}

#pragma mark - Tableview Delegate
//  Added by Khai Le on 05/10/2018
- (int)getRowForSection {
    int result = (int)detailsContact._listPhone.count;
    if (detailsContact._company != nil && ![detailsContact._company isEqualToString:@""]) {
        result = result + 1;
    }
    if (detailsContact._email != nil && ![detailsContact._email isEqualToString:@""]) {
        result = result + 1;
    }
    return result;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == tbDetail) {
        int numRow = [self getRowForSection];
        return numRow;
        
        if (detailsContact._sipPhone != nil && ![detailsContact._sipPhone isEqualToString:@""]) {
            return detailsContact._listPhone.count + 1;
        }else{
            return detailsContact._listPhone.count;
        }
    }else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tbDetail)
    {
        if (indexPath.row < detailsContact._listPhone.count)
        {
            static NSString *CellIdentifier = @"UIContactPhoneCell";
            UIContactPhoneCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
            if (cell == nil) {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"UIContactPhoneCell" owner:self options:nil];
                cell = topLevelObjects[0];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            ContactDetailObj *anItem = [detailsContact._listPhone objectAtIndex: indexPath.row];
            cell.lbTitle.text = anItem._titleStr;
            cell.lbPhone.text = anItem._valueStr;
            
            [cell.icCall setTitle:anItem._valueStr forState:UIControlStateNormal];
            [cell.icCall addTarget:self
                            action:@selector(onIconCallClicked:)
                  forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
        }else{
            static NSString *CellIdentifier = @"UIKContactCell";
            UIKContactCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
            if (cell == nil) {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"UIKContactCell" owner:self options:nil];
                cell = topLevelObjects[0];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if (indexPath.row == detailsContact._listPhone.count) {
                if (detailsContact._company != nil && ![detailsContact._company isEqualToString:@""]) {
                    cell.lbTitle.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Company"];
                    cell.lbValue.text = detailsContact._company;
                }else if (detailsContact._email != nil && ![detailsContact._email isEqualToString:@""]){
                    cell.lbTitle.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Email"];
                    cell.lbValue.text = detailsContact._email;
                }
            }else if (indexPath.row == detailsContact._listPhone.count + 1){
                if (detailsContact._email != nil && ![detailsContact._email isEqualToString:@""]){
                    cell.lbTitle.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Email"];
                    cell.lbValue.text = detailsContact._email;
                }
            }
            return cell;
        }
        
    }else{
        static NSString *CellIdentifier = @"UIContactPhoneCell";
        UIContactPhoneCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"UIContactPhoneCell" owner:self options:nil];
            cell = topLevelObjects[0];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.lbTitle.text = @"PBX ID";
        cell.lbPhone.text = detailsPBXContact._number;
        [cell.icCall setTitle:detailsPBXContact._number forState:UIControlStateNormal];
        [cell.icCall addTarget:self
                        action:@selector(onIconCallClicked:)
              forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0;
}

- (void)onIconCallClicked: (UIButton *)sender
{
    if (![AppUtils isNullOrEmpty: sender.currentTitle]) {
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Call from %@ to %@", __FUNCTION__, USERNAME, sender.currentTitle] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        
        NSString *number = [AppUtils removeAllSpecialInString: sender.currentTitle];
        if (![AppUtils isNullOrEmpty: number]) {
            [SipUtils makeCallWithPhoneNumber: number];
        }
    }else{
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"The phone number can not empty"] duration:2.0 position:CSToastPositionCenter];
    }
}

- (IBAction)btnSendMessagePressed:(UIButton *)sender {
}

- (void)createFooterViewForTable {
    viewFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-SPLIT_MASTER_WIDTH, 100.0)];
    viewFooter.backgroundColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0)
                                                  blue:(235/255.0) alpha:1.0];
    
    btnDeleteContact = [[UIButton alloc] init];
    btnDeleteContact.backgroundColor = UIColor.redColor;
    btnDeleteContact.layer.borderColor = btnDeleteContact.backgroundColor.CGColor;
    btnDeleteContact.layer.borderWidth = 1.0;
    [btnDeleteContact setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [btnDeleteContact setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Delete contact"] forState:UIControlStateNormal];
    btnDeleteContact.titleLabel.font = [UIFont systemFontOfSize:22.0 weight:UIFontWeightThin];
    [viewFooter addSubview: btnDeleteContact];
    
    [btnDeleteContact mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewFooter.mas_centerX);
        make.centerY.equalTo(viewFooter.mas_centerY);
        make.height.mas_equalTo(50.0);
        make.width.mas_equalTo(200.0);
    }];
    btnDeleteContact.clipsToBounds = YES;
    btnDeleteContact.layer.cornerRadius = 50.0/2;
    
    [btnDeleteContact addTarget:self
                         action:@selector(btnDeleteContactPress:)
               forControlEvents:UIControlEventTouchUpInside];
    
    tbDetail.tableFooterView = viewFooter;
}

- (void)btnDeleteContactPress: (UIButton *)sender
{
    sender.backgroundColor = UIColor.whiteColor;
    [sender setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    [self performSelector:@selector(showAlertForDeleteContact) withObject:nil afterDelay:0.1];
}

- (void)showAlertForDeleteContact
{
    btnDeleteContact.backgroundColor = UIColor.redColor;
    [btnDeleteContact setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Delete contact"] message:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Are you sure, you want to delete this contact?"] delegate:self cancelButtonTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Cancel"] otherButtonTitles:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Accept"], nil];
    alertView.delegate = self;
    [alertView show];
}

#pragma mark - AlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Confirm delete this contact", __FUNCTION__] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        
        [[LinphoneAppDelegate sharedInstance] showWaiting: YES];
        
        // Remove khỏi addressbook
        BOOL result = [ContactUtils deleteContactFromPhoneWithId: detailsContact._id_contact];
        if(result){
            NSString *msgContent = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Contact has been deleted"];
            [[LinphoneAppDelegate sharedInstance].window makeToast:msgContent duration:2.0 position:CSToastPositionCenter];
            
            [self updateContactListAfterDeleteContact: detailsContact];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:reloadContactsAfterDeleteForIpad
                                                                object:nil];
        }else{
            NSString *msgContent = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Failed"];
            [[LinphoneAppDelegate sharedInstance].window makeToast:msgContent duration:2.0 position:CSToastPositionCenter];
        }
        [[LinphoneAppDelegate sharedInstance] showWaiting: NO];
    }
}

- (void)updateContactListAfterDeleteContact: (ContactObject *)contact {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactId = %d", contact._id_contact];
    NSArray *filter = [[LinphoneAppDelegate sharedInstance].listInfoPhoneNumber filteredArrayUsingPredicate: predicate];
    if (filter.count > 0) {
        [[LinphoneAppDelegate sharedInstance].listInfoPhoneNumber removeObjectsInArray: filter];
    }
    [[LinphoneAppDelegate sharedInstance].listContacts removeObject: contact];
}


@end
