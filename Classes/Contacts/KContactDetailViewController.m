//
//  KContactDetailViewController.m
//  linphone
//
//  Created by mac book on 11/5/15.
//
//

#import "KContactDetailViewController.h"
#import "UIKContactCell.h"
#import "UIContactPhoneCell.h"
#import "JSONKit.h"
#import "NSData+Base64.h"
#import <CommonCrypto/CommonDigest.h>
#import "TypePhoneContact.h"
#import "ContactDetailObj.h"
#import "EditContactViewController.h"

@interface KContactDetailViewController (){
    LinphoneAppDelegate *appDelegate;
    float hCell;
    
    YBHud *waitingHud;
    BOOL isPBXContact;
    
    UIButton *btnDelete;
}
@end

@implementation NSString (MD5)

- (NSString *)MD5String {
    const char *cstr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, (int)strlen(cstr), result);
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end

@implementation KContactDetailViewController
@synthesize _viewHeader, _iconBack, _lbTitle, _iconEdit, _imgAvatar, _lbContactName;
@synthesize _tbContactInfo, buttonCallPBX;
@synthesize detailsContact;

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
    
    //  MY CODE HERE
    appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self autoLayoutForView];
    
    //  add waiting view
    waitingHud = [[YBHud alloc] initWithHudType:DGActivityIndicatorAnimationTypeLineScale andText:@""];
    waitingHud.tintColor = [UIColor whiteColor];
    waitingHud.dimAmount = 0.5;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [WriteLogsUtils writeForGoToScreen: @"KContactDetailViewController"];
    
    _lbTitle.text = [appDelegate.localization localizedStringForKey:@"Contact info"];
    
    // Tắt màn hình cảm biến
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled: NO];
    
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"Get contact info with id: %d", appDelegate.idContact]
                         toFilePath:appDelegate.logFilePath];
    
    detailsContact = [AppUtils getContactWithId: appDelegate.idContact];
    if (![AppUtils isNullOrEmpty:detailsContact._sipPhone]) {
        isPBXContact = YES;
    }else{
        isPBXContact = NO;
    }
    
    [self displayContactInformation];
    [_tbContactInfo reloadData];
    
    [btnDelete setTitle:[appDelegate.localization localizedStringForKey:@"Delete contact"]
               forState:UIControlStateNormal];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self setupFooterForTableView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    
    _tbContactInfo.tableFooterView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
}

- (void)viewDidUnload {
    [self set_iconBack:nil];
    [self set_lbTitle:nil];
    [self set_iconEdit:nil];
    [self set_imgAvatar:nil];
    [self set_lbContactName:nil];
    [self set_tbContactInfo:nil];
    [super viewDidUnload];
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
        controller.idContact = detailsContact._id_contact;
        controller.curPhoneNumber = @"";
    }
    [[PhoneMainView instance] changeCurrentView:[EditContactViewController compositeViewDescription] push:true];
}

- (IBAction)buttonCallPBXPressed:(UIButton *)sender {
}

#pragma mark - my functions

- (void)autoLayoutForView
{
    self.view.backgroundColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                                 blue:(230/255.0) alpha:1.0];
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
    
    //  button call
    [buttonCallPBX setBackgroundImage:[UIImage imageNamed:@"call_disable.png"]
                             forState:UIControlStateDisabled];
    buttonCallPBX.hidden = YES;
    buttonCallPBX.enabled = NO;
    buttonCallPBX.layer.cornerRadius = 70.0/2;
    buttonCallPBX.clipsToBounds = YES;
    buttonCallPBX.layer.borderWidth = 2.0;
    buttonCallPBX.layer.borderColor = UIColor.whiteColor.CGColor;
    [buttonCallPBX mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(_viewHeader.mas_bottom);
        make.width.height.mas_equalTo(70.0);
    }];
    
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

//  Hiển thị thông tin của contact
- (void)displayContactInformation
{
    if ([detailsContact._fullName isEqualToString:@""] && ![detailsContact._sipPhone isEqualToString:@""]) {
        _lbContactName.text = detailsContact._sipPhone;
    }else{
        _lbContactName.text = detailsContact._fullName;
    }
    
    //  Avatar contact
    if (detailsContact._avatar == nil || [detailsContact._avatar isEqualToString:@""] || [detailsContact._avatar isEqualToString:@"<null>"] || [detailsContact._avatar isEqualToString:@"(null)"] || [detailsContact._avatar isEqualToString:@"(null)"]) {
        _imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
    }else{
        _imgAvatar.image = [UIImage imageWithData: [NSData dataFromBase64String: detailsContact._avatar]];
    }
}

//  Xử lý số phone
- (NSString *)changeAddressNumber: (NSString *)phoneString
{
    phoneString = [phoneString stringByReplacingOccurrencesOfString:@" " withString:@""];
    phoneString = [phoneString stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    if ([phoneString hasPrefix:@"84"]) {
        phoneString = [phoneString substringFromIndex: 2];
        phoneString = [NSString stringWithFormat:@"0%@", phoneString];
    }
    return phoneString;
}

#pragma mark - Tableview Delegate
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
                cell.lbTitle.text = [appDelegate.localization localizedStringForKey:@"Company"];
                cell.lbValue.text = detailsContact._company;
            }else if (detailsContact._email != nil && ![detailsContact._email isEqualToString:@""]){
                cell.lbTitle.text = [appDelegate.localization localizedStringForKey:@"Email"];
                cell.lbValue.text = detailsContact._email;
            }
        }else if (indexPath.row == detailsContact._listPhone.count + 1){
            if (detailsContact._email != nil && ![detailsContact._email isEqualToString:@""]){
                cell.lbTitle.text = [appDelegate.localization localizedStringForKey:@"Email"];
                cell.lbValue.text = detailsContact._email;
            }
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return hCell;
}

#pragma mark - Alertview Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Confirm delete this contact", __FUNCTION__] toFilePath:appDelegate.logFilePath];
        
        [waitingHud showInView:self.view animated:YES];
        
        // Remove khỏi addressbook
        CFErrorRef error = NULL;
        ABAddressBookRef listAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        ABRecordRef aPerson = ABAddressBookGetPersonWithRecordID(listAddressBook, detailsContact._id_contact);
        ABAddressBookRemoveRecord(listAddressBook, aPerson, nil);
        BOOL isSaved = ABAddressBookSave (listAddressBook,&error);
        if(isSaved){
            NSLog(@"Contact đã được xoá khỏi addressbook...");
        }
        
        [appDelegate.listContacts removeObject: detailsContact];
        
        [waitingHud dismissAnimated:YES];
        
        [[PhoneMainView instance] popCurrentView];
    }
}

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

- (void)setupFooterForTableView {
    UIView *footerView = [_tbContactInfo tableFooterView];
    if (footerView == nil) {
        float hFooterDefault = 100.0;
        footerView = [[UIView alloc] init];
        footerView.backgroundColor = UIColor.greenColor;
        if (_tbContactInfo.contentSize.height > _tbContactInfo.frame.size.height) {
            footerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, hFooterDefault);
            _tbContactInfo.scrollEnabled = YES;
        }else{
            float tmpHeight = _tbContactInfo.frame.size.height - _tbContactInfo.contentSize.height;
            if (tmpHeight <= hFooterDefault) {
                footerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, hFooterDefault);
                _tbContactInfo.scrollEnabled = YES;
            }else{
                footerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, tmpHeight);
                _tbContactInfo.scrollEnabled = NO;
            }
        }
        footerView.backgroundColor = UIColor.clearColor;
        _tbContactInfo.tableFooterView = footerView;
        
        btnDelete = [[UIButton alloc] init];
        btnDelete.backgroundColor = [UIColor colorWithRed:(202/255.0) green:(212/255.0)
                                                     blue:(223/255.0) alpha:1.0];
        [btnDelete setTitleColor:UIColor.redColor forState:UIControlStateNormal];
        [btnDelete setTitle:[appDelegate.localization localizedStringForKey:@"Delete contact"]
                   forState:UIControlStateNormal];
        btnDelete.titleLabel.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:20.0];
        [footerView addSubview: btnDelete];
        
        [btnDelete mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(footerView).offset(-25.0);
            make.left.equalTo(footerView).offset(50);
            make.right.equalTo(footerView).offset(-50);
            make.height.mas_equalTo(50.0);
        }];
        btnDelete.clipsToBounds = YES;
        btnDelete.layer.cornerRadius = 50.0/2;
        
        [btnDelete addTarget:self
                      action:@selector(btnDeleteContactPressed:)
            forControlEvents:UIControlEventTouchUpInside];
    }else{
        NSLog(@"You setted FooterView for UITableview");
    }
}

- (void)btnDeleteContactPressed: (UIButton *)sender
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__]
                         toFilePath:appDelegate.logFilePath];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[appDelegate.localization localizedStringForKey:@"Delete contact"] message:[appDelegate.localization localizedStringForKey:@"Are you sure, you want to delete this contact?"] delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:@"Cancel"] otherButtonTitles:[appDelegate.localization localizedStringForKey:@"Accept"], nil];
    alertView.delegate = self;
    [alertView show];
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

@end
