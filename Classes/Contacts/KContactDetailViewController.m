//
//  KContactDetailViewController.m
//  linphone
//
//  Created by mac book on 11/5/15.
//
//

#import "KContactDetailViewController.h"
#import "PhoneMainView.h"
#import "UIKContactCell.h"
#import "JSONKit.h"
#import "NSData+Base64.h"
#import <CommonCrypto/CommonDigest.h>
#import "TypePhoneContact.h"
#import "ContactDetailObj.h"
//  Leo Kelvin
#import "EditContactViewController.h"
#import "ContactDetailObj.h"

@interface KContactDetailViewController (){
    LinphoneAppDelegate *appDelegate;
    NSArray *listNumber;
    
    //  call
    BOOL transfer_popup;
    
    int i;
    float hCell;
    float hInfo;
    
    YBHud *waitingHud;
    UIFont *textFont;
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
@synthesize _viewHeader, _iconBack, _lbTitle, _iconEdit, _iconDelete;
@synthesize _scrollViewContent;
@synthesize _viewInfo, _imgAvatar, _lbContactName;
@synthesize _tbContactInfo;
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
    listNumber = [[NSArray alloc] initWithObjects:@"0", @"1", @"2", @"3", @"4", @"5",
                  @"6", @"7", @"8", @"9",nil];
    [self setupUIForView];
    
    //  add waiting view
    waitingHud = [[YBHud alloc] initWithHudType:DGActivityIndicatorAnimationTypeLineScale andText:@""];
    waitingHud.tintColor = [UIColor whiteColor];
    waitingHud.dimAmount = 0.5;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _lbTitle.text = [appDelegate.localization localizedStringForKey:@"Contact info"];
    
    // Tắt màn hình cảm biến
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled: NO];
    
    detailsContact = [AppUtils getContactWithId: appDelegate.idContact];
    [self showContactInformation];
    [_tbContactInfo reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
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
    [self set_iconDelete:nil];
    [self set_iconEdit:nil];
    [self set_imgAvatar:nil];
    [self set_lbContactName:nil];
    [self set_tbContactInfo:nil];
    [super viewDidUnload];
}

- (IBAction)_iconBackClicked:(id)sender {
    [[PhoneMainView instance] popCurrentView];
}

- (IBAction)_iconDeleteClicked:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[appDelegate.localization localizedStringForKey:text_popup_delete_contact_title] message:[appDelegate.localization localizedStringForKey:text_popup_delete_contact_content] delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:text_no] otherButtonTitles:[appDelegate.localization localizedStringForKey:text_yes], nil];
    alertView.delegate = self;
    [alertView show];
}

- (IBAction)_iconEditClicked:(id)sender
{
    EditContactViewController *controller = VIEW(EditContactViewController);
    if (controller != nil) {
        [controller setContactDetailsInformation: detailsContact];
    }
    [[PhoneMainView instance] changeCurrentView:[EditContactViewController compositeViewDescription] push:true];
}

//  Gọi trên icon call trong từng cell
- (void)callOnPhoneDetail: (UIButton *)sender {
    NSString *phoneNumber = sender.titleLabel.text;
    [self makeCallWithPhoneNumber: phoneNumber];
}

- (IBAction)_btnMessagePressed:(id)sender {
    
}

- (IBAction)_btnInvitePressed:(id)sender
{
    
}

- (IBAction)_btnBlockPressed:(id)sender {
    
}

- (IBAction)_btnVideoCallPressed:(UIButton *)sender {
    
}

#pragma mark - my functions

- (void)setupUIForView {
    if (SCREEN_WIDTH > 320) {
        hCell = 55.0;
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
        _lbTitle.font = [UIFont fontWithName:HelveticaNeue size:20.0];
    }else{
        hCell = 45.0;
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
        _lbTitle.font = [UIFont fontWithName:HelveticaNeue size:18.0];
    }
    
    //  header
    [_viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(appDelegate._hHeader);
    }];
    
    [_iconBack setBackgroundImage:[UIImage imageNamed:@"ic_back_act.png"]
                         forState:UIControlStateHighlighted];
    [_iconBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewHeader);
        make.centerY.equalTo(_viewHeader.mas_centerY);
        make.width.height.mas_equalTo(40.0);
    }];
    
    [_iconEdit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_viewHeader);
        make.centerY.equalTo(_viewHeader.mas_centerY);
        make.width.equalTo(_iconBack.mas_width);
        make.height.equalTo(_iconBack.mas_height);
    }];
    
    [_iconDelete mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_iconEdit.mas_left);
        make.centerY.equalTo(_viewHeader.mas_centerY);
        make.width.equalTo(_iconBack.mas_width);
        make.height.equalTo(_iconBack.mas_height);
    }];
    
    [_lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(_viewHeader);
        make.centerX.equalTo(_viewHeader.mas_centerX);
        make.width.mas_equalTo(100);
    }];
    
    //  content
    [_scrollViewContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
        make.width.mas_equalTo(100);
    }];
    
    //  view info
    hInfo = 110.0;
    [_viewInfo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(_scrollViewContent);
        make.height.mas_equalTo(hInfo);
    }];
    
    [_imgAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewInfo).offset(5);
        make.centerX.equalTo(_viewInfo.mas_centerX);
        make.width.height.mas_equalTo(65.0);
    }];
    _imgAvatar.layer.cornerRadius = 65.0/2;
    _imgAvatar.clipsToBounds = YES;
    
    [_lbContactName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_viewInfo);
        make.top.equalTo(_imgAvatar.mas_bottom);
        make.width.height.mas_equalTo(30.0);
    }];
    _lbContactName.marqueeType = MLContinuous;
    _lbContactName.scrollDuration = 15.0;
    _lbContactName.animationCurve = UIViewAnimationOptionCurveEaseInOut;
    _lbContactName.fadeLength = 10.0;
    _lbContactName.continuousMarqueeExtraBuffer = 10.0f;
    _lbContactName.font = [UIFont fontWithName:HelveticaNeue size:16.0];
    _lbContactName.textColor = [UIColor colorWithRed:(50/255.0) green:(50/255.0)
                                                blue:(50/255.0) alpha:1.0];
    
    //  table info
    [_tbContactInfo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.top.equalTo(_viewInfo.mas_bottom);
    }];
    _tbContactInfo.delegate = self;
    _tbContactInfo.dataSource = self;
    _tbContactInfo.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)btnCallPressed: (UIButton *)sender {
    NSString *phoneNumber = sender.titleLabel.text;
    transfer_popup = NO;
    [self makeCallWithPhoneNumber: phoneNumber];
}

//  Hiển thị thông tin của contact
- (void)showContactInformation
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

//  Hàm loại bỏ tất cả các ký tự ko là số ra khỏi chuỗi
- (NSString *)removeAllSpecialInString: (NSString *)phoneString {
    
    NSString *resultStr = @"";
    for (int strCount=0; strCount<phoneString.length; strCount++) {
        char characterChar = [phoneString characterAtIndex: strCount];
        NSString *characterStr = [NSString stringWithFormat:@"%c", characterChar];
        if ([listNumber containsObject: characterStr]) {
            resultStr = [NSString stringWithFormat:@"%@%@", resultStr, characterStr];
        }
    }
    return resultStr;
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

- (void)makeCallWithPhoneNumber: (NSString *)phoneNumber {
    if (phoneNumber != nil && phoneNumber.length > 0)
    {
        LinphoneAddress *addr = linphone_core_interpret_url(LC, phoneNumber.UTF8String);
        [LinphoneManager.instance call:addr];
        if (addr)
            linphone_address_destroy(addr);
        
        OutgoingCallViewController *controller = VIEW(OutgoingCallViewController);
        if (controller != nil) {
            [controller setPhoneNumberForView: phoneNumber];
        }
        [[PhoneMainView instance] changeCurrentView:[OutgoingCallViewController compositeViewDescription] push:TRUE];
    }
}

#pragma mark - Tableview Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (detailsContact._sipPhone != nil && ![detailsContact._sipPhone isEqualToString:@""]) {
        return detailsContact._listPhone.count + 1;
    }else{
        return detailsContact._listPhone.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"UIKContactCell";
    
    UIKContactCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"UIKContactCell" owner:self options:nil];
        cell = topLevelObjects[0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, _tbContactInfo.frame.size.width, hCell);
    [cell setupUIForCell];
    
    ContactDetailObj *anItem;
    if (detailsContact._sipPhone != nil && ![detailsContact._sipPhone isEqualToString:@""]) {
        if (indexPath.row == 0) {
            anItem = [[ContactDetailObj alloc] init];
            anItem._typePhone = type_cloudfone_id;
            anItem._titleStr = [appDelegate.localization localizedStringForKey:text_contact_cloudfoneId];
            anItem._valueStr = detailsContact._sipPhone;
            anItem._buttonStr = @"contact_detail_icon_call.png";
            anItem._iconStr = @"";
        }else{
            anItem = [detailsContact._listPhone objectAtIndex: (indexPath.row-1)];
        }
    }else{
        anItem = [detailsContact._listPhone objectAtIndex: indexPath.row];
    }
    
    //image for cell
    cell.typeImage.image = [UIImage imageNamed: anItem._iconStr];
    cell.typeImage.hidden = YES;
    
    cell.lbTitle.text = anItem._titleStr;
    cell.lbValue.text = anItem._valueStr;
    
    //set background button
    if ([anItem._buttonStr isEqualToString: @""]) {
        cell._imageDetails.hidden = YES;
        cell._btnCall.hidden = YES;
    }else{
        cell._imageDetails.hidden = YES;
        cell._btnCall.hidden = NO;
        [cell._btnCall addTarget:self
                          action:@selector(callOnPhoneDetail:)
                forControlEvents:UIControlEventTouchUpInside];
        
        cell._imageDetails.image = [UIImage imageNamed:anItem._buttonStr];
        cell._btnCall.tag = indexPath.row;
    }
    [cell._btnCall setTitle:anItem._valueStr forState:UIControlStateNormal];
    [cell._btnCall setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, _tbContactInfo.frame.size.width, hCell);
    [cell setupFrameForContactDetail];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return hCell;
}

#pragma mark - Alertview Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
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

@end
