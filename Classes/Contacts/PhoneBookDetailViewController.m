//
//  PhoneBookDetailViewController.m
//  linphone
//
//  Created by lam quang quan on 6/24/19.
//

#import "PhoneBookDetailViewController.h"
#import "EditContactViewController.h"
#import "UIContactPhoneCell.h"
#import "UIKContactCell.h"
#import "ContactDetailObj.h"

@interface PhoneBookDetailViewController ()<UITableViewDelegate, UITableViewDataSource>{
    LinphoneAppDelegate *appDelegate;
    float hCell;
    NSMutableArray *listPhone;
    ABRecordRef contact;
}

@end

@implementation PhoneBookDetailViewController
@synthesize _viewHeader, _iconBack, _lbTitle, _iconEdit, _imgAvatar, _lbContactName;
@synthesize _tbContactInfo;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self autoLayoutForView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self displayContactInformation];
}

- (IBAction)_iconBackClicked:(id)sender {
    [[PhoneMainView instance] popCurrentView];
}

- (IBAction)_iconEditClicked:(id)sender
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__]
                         toFilePath:appDelegate.logFilePath];
    
    EditContactViewController *controller = VIEW(EditContactViewController);
    if (controller != nil) {
        controller.idContact = appDelegate.idContact;
        controller.curPhoneNumber = @"";
    }
    [[PhoneMainView instance] changeCurrentView:[EditContactViewController compositeViewDescription] push:true];
}

- (void)autoLayoutForView
{
    self.view.backgroundColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0) blue:(230/255.0) alpha:1.0];
    if (SCREEN_WIDTH > 320) {
        hCell = 55.0;
        _lbTitle.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:20.0];
    }else{
        hCell = 45.0;
        _lbTitle.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }
    
    //  header
    [_viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(230+[LinphoneAppDelegate sharedInstance]._hStatus);
    }];
    
    [_bgHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(_viewHeader);
    }];
    
    [_lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader).offset(appDelegate._hStatus);
        make.centerX.equalTo(_viewHeader.mas_centerX);
        make.width.mas_equalTo(200.0);
        make.height.mas_equalTo(44.0);
    }];
    
    [_iconBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewHeader);
        make.centerY.equalTo(_lbTitle.mas_centerY);
        make.width.height.mas_equalTo(HEADER_ICON_WIDTH);
    }];
    
    _iconEdit.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
    [_iconEdit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_iconBack);
        make.right.equalTo(_viewHeader);
        make.width.equalTo(_iconBack.mas_width);
        make.height.equalTo(_iconBack.mas_height);
    }];
    
    _imgAvatar.layer.cornerRadius = 120.0/2;
    _imgAvatar.layer.borderWidth = 2.0;
    _imgAvatar.layer.borderColor = UIColor.whiteColor.CGColor;
    _imgAvatar.clipsToBounds = YES;
    [_imgAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lbTitle.mas_bottom).offset(10);
        make.centerX.equalTo(_viewHeader.mas_centerX);
        make.width.height.mas_equalTo(120.0);
    }];
    
    [_lbContactName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_imgAvatar.mas_bottom);
        make.left.right.equalTo(_viewHeader);
        make.height.mas_equalTo(40.0);
    }];
    _lbContactName.marqueeType = MLContinuous;
    _lbContactName.scrollDuration = 15.0;
    _lbContactName.animationCurve = UIViewAnimationOptionCurveEaseInOut;
    _lbContactName.fadeLength = 10.0;
    _lbContactName.continuousMarqueeExtraBuffer = 10.0f;
    _lbContactName.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightSemibold];
    _lbContactName.textColor = UIColor.whiteColor;
    
    //  content
    [_tbContactInfo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    _tbContactInfo.delegate = self;
    _tbContactInfo.dataSource = self;
    _tbContactInfo.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tbContactInfo.backgroundColor = UIColor.clearColor;
    
    UIView *headerView = [[UIView alloc] init];
    headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 70.0/2);
    headerView.backgroundColor = UIColor.whiteColor;
    //  _tbContactInfo.tableHeaderView = headerView;
}

- (void)displayContactInformation {
    contact = ABAddressBookGetPersonWithRecordID(appDelegate.addressListBook, appDelegate.idContact);
    NSString *name = [ContactUtils getFullNameFromContact: contact];
    _lbContactName.text = name;
    
    UIImage *avatar = [ContactUtils getAvatarFromContact: contact];
    _imgAvatar.image = avatar;
    
    listPhone = [ContactUtils getListPhoneOfContactPerson: contact];
    [_tbContactInfo reloadData];
}

#pragma mark - Tableview Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int numRow = [self getRowForSection];
    return numRow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < listPhone.count)
    {
        static NSString *CellIdentifier = @"UIContactPhoneCell";
        UIContactPhoneCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"UIContactPhoneCell" owner:self options:nil];
            cell = topLevelObjects[0];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        ContactDetailObj *anItem = [listPhone objectAtIndex: indexPath.row];
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

        NSString *company = [ContactUtils getCompanyFromContact: contact];
        NSString *email =[ContactUtils getEmailFromContact: contact];
        
        if (indexPath.row == listPhone.count) {
            if (company != nil && ![company isEqualToString:@""]) {
                cell.lbTitle.text = [appDelegate.localization localizedStringForKey:@"Company"];
                cell.lbValue.text = company;
            }else if (email != nil && ![email isEqualToString:@""]){
                cell.lbTitle.text = [appDelegate.localization localizedStringForKey:@"Email"];
                cell.lbValue.text = email;
            }
        }else if (indexPath.row == listPhone.count + 1){
            if (email != nil && ![email isEqualToString:@""]){
                cell.lbTitle.text = [appDelegate.localization localizedStringForKey:@"Email"];
                cell.lbValue.text = email;
            }
        }
        return cell;
    }
}

- (void)onIconCallClicked: (UIButton *)sender
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Call from %@ to %@", __FUNCTION__, USERNAME, sender.currentTitle] toFilePath:appDelegate.logFilePath];
    
    if (![AppUtils isNullOrEmpty: sender.currentTitle]) {
        NSString *number = [AppUtils removeAllSpecialInString: sender.currentTitle];
        if (![AppUtils isNullOrEmpty: number]) {
            [SipUtils makeCallWithPhoneNumber: number];
        }
    }else{
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"The phone number can not empty"]
                    duration:2.0 position:CSToastPositionCenter];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return hCell;
}

- (int)getRowForSection {
    int result = (int)listPhone.count;
    
    NSString *company = [ContactUtils getCompanyFromContact: contact];
    if (company != nil && ![company isEqualToString:@""]) {
        result = result + 1;
    }
    
    NSString *email = [ContactUtils getEmailFromContact: contact];
    if (email != nil && ![email isEqualToString:@""]) {
        result = result + 1;
    }
    return result;
}

@end
