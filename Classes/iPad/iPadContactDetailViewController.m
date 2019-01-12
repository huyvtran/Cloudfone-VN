//
//  iPadContactDetailViewController.m
//  linphone
//
//  Created by admin on 1/12/19.
//

#import "iPadContactDetailViewController.h"
#import "NSData+Base64.h"
#import "UIContactPhoneCell.h"
#import "ContactDetailObj.h"
#import "UIKContactCell.h"

@interface iPadContactDetailViewController () {
    BOOL isPBXContact;
}

@end

@implementation iPadContactDetailViewController
@synthesize viewHeader, bgHeader, lbHeader, icEdit, imgAvatar, lbName, icCallPBX, tbDetail, viewNoContacts, imgNoContacts, lbNoContacts;
@synthesize detailsContact;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    lbHeader.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Contact info"];
    [self registerNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)icEditClicked:(UIButton *)sender {
}

- (IBAction)icCallPBXClicked:(UIButton *)sender {
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
    id object = [notif object];
    if ([object isKindOfClass:[ContactObject class]]) {
        detailsContact = [AppUtils getContactWithId: [(ContactObject *)object _id_contact]];
        if (![AppUtils isNullOrEmpty:detailsContact._sipPhone]) {
            isPBXContact = YES;
        }else{
            isPBXContact = NO;
        }
        
        [self displayContactInformation];
        [tbDetail reloadData];
    }
}

- (void)displayContactInformation
{
    viewNoContacts.hidden = YES;
    
    icEdit.hidden = isPBXContact;
    
    if ([detailsContact._fullName isEqualToString:@""] && ![detailsContact._sipPhone isEqualToString:@""]) {
        lbName.text = detailsContact._sipPhone;
    }else{
        lbName.text = detailsContact._fullName;
    }
    
    //  Avatar contact
    if (detailsContact._avatar == nil || [detailsContact._avatar isEqualToString:@""] || [detailsContact._avatar isEqualToString:@"<null>"] || [detailsContact._avatar isEqualToString:@"(null)"] || [detailsContact._avatar isEqualToString:@"(null)"]) {
        imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
    }else{
        imgAvatar.image = [UIImage imageWithData: [NSData dataFromBase64String: detailsContact._avatar]];
    }
}

- (void)setupUIForView {
    [viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(HEIGHT_IPAD_NAV + 190.0);
    }];
    
    [bgHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(viewHeader);
    }];
    
    float top = STATUS_BAR_HEIGHT + (HEIGHT_IPAD_NAV - STATUS_BAR_HEIGHT - HEIGHT_IPAD_HEADER_BUTTON)/2;
    [icEdit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader).offset(top);
        make.right.equalTo(viewHeader).offset(-PADDING_HEADER_ICON);
        make.width.height.mas_equalTo(HEIGHT_IPAD_HEADER_BUTTON);
    }];
    
    [lbHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(icEdit);
        make.centerX.equalTo(viewHeader.mas_centerX);
        make.width.mas_equalTo(200);
    }];
    
    [imgAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader).offset(HEIGHT_IPAD_NAV + 10);
        make.centerX.equalTo(viewHeader.mas_centerX);
        make.width.height.mas_equalTo(100.0);
    }];
    
    lbName.textColor = UIColor.whiteColor;
    [lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgAvatar.mas_bottom);
        make.left.right.equalTo(viewHeader);
        make.height.mas_equalTo(40.0);
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
    
    //  button call
    [icCallPBX setBackgroundImage:[UIImage imageNamed:@"call_disable.png"]
                             forState:UIControlStateDisabled];
    //  icCallPBX.hidden = YES;
    icCallPBX.enabled = NO;
    icCallPBX.layer.cornerRadius = 70.0/2;
    icCallPBX.clipsToBounds = YES;
    icCallPBX.layer.borderWidth = 2.0;
    icCallPBX.layer.borderColor = UIColor.whiteColor.CGColor;
    [icCallPBX mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(viewHeader.mas_bottom);
        make.width.height.mas_equalTo(70.0);
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
    
    if (SCREEN_WIDTH > 320) {
        lbNoContacts.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:20.0];
    }else{
        lbNoContacts.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:17.0];
    }
    lbNoContacts.textAlignment = NSTextAlignmentCenter;
    lbNoContacts.textColor = [UIColor colorWithRed:(180/255.0) green:(180/255.0)
                                              blue:(180/255.0) alpha:1.0];
    [lbNoContacts mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgNoContacts.mas_bottom);
        make.left.right.equalTo(viewNoContacts);
        make.height.mas_equalTo(50.0);
    }];
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
    int numRow = [self getRowForSection];
    return numRow;
    
    if (detailsContact._sipPhone != nil && ![detailsContact._sipPhone isEqualToString:@""]) {
        return detailsContact._listPhone.count + 1;
    }else{
        return detailsContact._listPhone.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"The phone number can not empty"]
                    duration:2.0 position:CSToastPositionCenter];
    }
}

@end
