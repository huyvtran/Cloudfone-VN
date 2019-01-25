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
}

@end

@implementation iPadContactDetailViewController
@synthesize viewHeader, imgAvatar, lbName, btnCall, btnSendMessage, tbDetail, tbPBXDetail, viewNoContacts, imgNoContacts, lbNoContacts;
@synthesize detailsContact, detailsPBXContact;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupUIForView];
    [self createEditContactButtonForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    self.title = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Contact info"];
    [self registerNotifications];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showViewNoContactsDetailForIpad)
                                                 name:@"showViewNoContactsDetailForIpad" object:nil];
}

- (void)showViewNoContactsDetailForIpad {
    viewNoContacts.hidden = NO;
}

- (void)displayContactInformation: (NSNotification *)notif {
    viewNoContacts.hidden = YES;
    id object = [notif object];
    if ([object isKindOfClass:[ContactObject class]]) {
        self.navigationItem.rightBarButtonItem = icEdit;
        
        [LinphoneAppDelegate sharedInstance].idContact = [(ContactObject *)object _id_contact];
        
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
        [LinphoneAppDelegate sharedInstance].idContact = 0;
        
        self.navigationItem.rightBarButtonItem = nil;
        
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
    viewNoContacts.hidden = YES;
    lbName.text = detailsPBXContact._name;
    if ([AppUtils isNullOrEmpty: detailsPBXContact._avatar]) {
        imgAvatar.image = [UIImage imageNamed:@"avatar"];
    }else{
        imgAvatar.image = [UIImage imageWithData: [NSData dataFromBase64String: detailsPBXContact._avatar]];
    }
}

- (void)displayContactInformation
{
    viewNoContacts.hidden = YES;
    
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
    lbName.textColor = [UIColor colorWithRed:(120/255.0) green:(120/255.0)
                                        blue:(120/255.0) alpha:1.0];
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
    
    btnCall.layer.cornerRadius = 12.0;
    btnCall.backgroundColor = IPAD_HEADER_BG_COLOR;
    [btnCall setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnCall.titleLabel.font = btnFont;
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
    [tbPBXDetail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(tbDetail);
    }];
    
    //  view no contacts
    [viewNoContacts mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
    
    [imgNoContacts mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(viewNoContacts.mas_centerX);
        make.centerY.equalTo(viewNoContacts.mas_centerY).offset(-70.0);
        make.width.height.mas_equalTo(120.0);
    }];
    
    lbNoContacts.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightThin];
    lbNoContacts.textAlignment = NSTextAlignmentCenter;
    lbNoContacts.textColor = GRAY_COLOR;
    [lbNoContacts mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgNoContacts.mas_bottom);
        make.left.right.equalTo(viewNoContacts);
        make.height.mas_equalTo(50.0);
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
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Call from %@ to %@", __FUNCTION__, USERNAME, sender.currentTitle] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    if (![AppUtils isNullOrEmpty: sender.currentTitle]) {
        NSString *number = [AppUtils removeAllSpecialInString: sender.currentTitle];
        if (![AppUtils isNullOrEmpty: number]) {
            [SipUtils makeCallWithPhoneNumber: number];
        }
    }else{
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"The phone number can not empty"] duration:2.0 position:CSToastPositionCenter];
    }
}

- (IBAction)btnCallPressed:(UIButton *)sender {
}

- (IBAction)btnSendMessagePressed:(UIButton *)sender {
}
@end
