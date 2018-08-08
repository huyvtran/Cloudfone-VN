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
#import "MainChatViewController.h"
//  #import "NSDBCallnex.h"
//  #import "OTRProtocolManager.h"
#import "ContactDetailObj.h"

@interface KContactDetailViewController (){
    LinphoneAppDelegate *appDelegate;
    NSArray *listNumber;
    
    //  call
    BOOL transfer_popup;
    
    int i;
    float hCell;
    float hInfo;
    float hAction;
    
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
@synthesize _viewAction, _btnCall, _lbCall, _lbVideoCall, _btnVideoCall, _btnBlock, _lbBlock, _btnMessage, _lbMessage;
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
    
    [self showContentWithCurrentLanguage];
    
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
    [self set_btnCall:nil];
    [self set_btnMessage:nil];
    [self set_btnBlock:nil];
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

- (void)showContentWithCurrentLanguage {
    _lbTitle.text = [appDelegate.localization localizedStringForKey:text_contact_detail];
    _lbCall.text = [appDelegate.localization localizedStringForKey:text_detail_call];
    _lbMessage.text = [appDelegate.localization localizedStringForKey:text_detail_message];
    _lbVideoCall.text = [appDelegate.localization localizedStringForKey:text_detail_video_call];
    _lbBlock.text = [appDelegate.localization localizedStringForKey:text_detail_block];
}

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
    _viewHeader.frame = CGRectMake(0, 0, SCREEN_WIDTH, appDelegate._hHeader);
    
    _iconBack.frame = CGRectMake(0, (appDelegate._hHeader-40.0)/2, 40.0, 40.0);
    [_iconBack setBackgroundImage:[UIImage imageNamed:@"ic_back_act.png"]
                         forState:UIControlStateHighlighted];
    
    _iconEdit.frame = CGRectMake(_viewHeader.frame.size.width-appDelegate._hHeader, _iconBack.frame.origin.y, _iconBack.frame.size.width, _iconBack.frame.size.height);
    _iconDelete.frame = CGRectMake(_iconEdit.frame.origin.x-appDelegate._hHeader, _iconBack.frame.origin.y, _iconBack.frame.size.width, _iconBack.frame.size.height);
    _lbTitle.frame = CGRectMake(_iconBack.frame.origin.x+_iconBack.frame.size.width+5, 0, (_viewHeader.frame.size.width-3*_iconBack.frame.size.width-10), appDelegate._hHeader);
    
    //  content
    _scrollViewContent.frame = CGRectMake(0, _viewHeader.frame.origin.y+_viewHeader.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT-appDelegate._hStatus-appDelegate._hHeader);
    
    //  view info
    hInfo = 110.0;
    _viewInfo.frame = CGRectMake(0, 0, _scrollViewContent.frame.size.width, hInfo);
    _imgAvatar.frame = CGRectMake((_viewInfo.frame.size.width-65)/2, 5, 65, 65);
    _imgAvatar.layer.cornerRadius = 65.0/2;
    _imgAvatar.clipsToBounds = YES;
    
    _lbContactName.frame = CGRectMake(0, _imgAvatar.frame.origin.y+_imgAvatar.frame.size.height, _viewInfo.frame.size.width, 30);
    
    //  view action
    hAction = 75.0;
    float wIcon = 35.0;
    _viewAction.frame = CGRectMake(0, _viewInfo.frame.origin.y+_viewInfo.frame.size.height, SCREEN_WIDTH, hAction);
    
    float marginX = (_viewAction.frame.size.width - 4*wIcon)/5;
    _btnCall.frame = CGRectMake(marginX, (hAction-(wIcon+25))/2, wIcon, wIcon);
    _lbCall.frame = CGRectMake(_btnCall.frame.origin.x-marginX/2, _btnCall.frame.origin.y+wIcon, wIcon+marginX, 25);
    [_btnCall setBackgroundImage:[UIImage imageNamed:@"ic_call_act.png"]
                        forState:UIControlStateHighlighted];
    [_btnCall setBackgroundImage:[UIImage imageNamed:@"ic_call_dis.png"]
                        forState:UIControlStateDisabled];
    [_btnCall addTarget:self
                 action:@selector(btnCallPressed:)
       forControlEvents:UIControlEventTouchUpInside];
    
    _lbCall.font = textFont;
    
    //  message
    _btnMessage.frame = CGRectMake(_btnCall.frame.origin.x+wIcon+marginX, _btnCall.frame.origin.y, wIcon, wIcon);
    _lbMessage.frame = CGRectMake(_btnMessage.frame.origin.x-marginX/2, _lbCall.frame.origin.y, _lbCall.frame.size.width, _lbCall.frame.size.height);
    _lbMessage.font = textFont;
    [_btnMessage setBackgroundImage:[UIImage imageNamed:@"ic_mess_act.png"]
                           forState:UIControlStateHighlighted];
    [_btnMessage setBackgroundImage:[UIImage imageNamed:@"ic_mess_dis.png"]
                           forState:UIControlStateDisabled];
    
    [_btnMessage addTarget:self
                    action:@selector(btnMessageTouchDown)
          forControlEvents:UIControlEventTouchDown];
    
    //  video call
    _btnVideoCall.frame = CGRectMake(_btnMessage.frame.origin.x+wIcon+marginX, _btnMessage.frame.origin.y, wIcon, wIcon);
    _lbVideoCall.frame = CGRectMake(_btnVideoCall.frame.origin.x-marginX/2, _lbMessage.frame.origin.y, _lbMessage.frame.size.width, _lbMessage.frame.size.height);
    _btnVideoCall.frame = CGRectMake(_btnMessage.frame.origin.x+wIcon+marginX, _btnMessage.frame.origin.y, wIcon, wIcon);
    [_btnVideoCall setBackgroundImage:[UIImage imageNamed:@"ic_video_call_act.png"]
                             forState:UIControlStateHighlighted];
    [_btnVideoCall setBackgroundImage:[UIImage imageNamed:@"ic_video_call_dis.png"]
                             forState:UIControlStateDisabled];
    
    [_btnVideoCall addTarget:self
                      action:@selector(btnVideoCallTouchDown)
            forControlEvents:UIControlEventTouchDown];
    _lbVideoCall.font = textFont;
    
    //  block
    _btnBlock.frame = CGRectMake(_btnVideoCall.frame.origin.x+wIcon+marginX, _btnVideoCall.frame.origin.y, wIcon, wIcon);
    _lbBlock.frame = CGRectMake(_btnBlock.frame.origin.x-marginX/2, _lbVideoCall.frame.origin.y, _lbVideoCall.frame.size.width, _lbVideoCall.frame.size.height);
    [_btnBlock setBackgroundImage:[UIImage imageNamed:@"ic_block_def.png"]
                         forState:UIControlStateHighlighted];
    _lbBlock.font = textFont;
    
    //  contact name
    _lbContactName.marqueeType = MLContinuous;
    _lbContactName.scrollDuration = 15.0;
    _lbContactName.animationCurve = UIViewAnimationOptionCurveEaseInOut;
    _lbContactName.fadeLength = 10.0;
    _lbContactName.continuousMarqueeExtraBuffer = 10.0f;
    _lbContactName.font = [UIFont fontWithName:HelveticaNeue size:16.0];
    _lbContactName.textColor = [UIColor colorWithRed:(50/255.0) green:(50/255.0)
                                                blue:(50/255.0) alpha:1.0];
    
    _tbContactInfo.frame = CGRectMake(0, _viewAction.frame.origin.y+_viewAction.frame.size.height+8, _scrollViewContent.frame.size.width, SCREEN_HEIGHT-(appDelegate._hStatus+appDelegate._hHeader+hInfo+hAction));
    _tbContactInfo.delegate = self;
    _tbContactInfo.dataSource = self;
    _tbContactInfo.separatorStyle = UITableViewCellSeparatorStyleNone;
}

//  setup frame các button theo từng loại contact
- (void)setupFrameForContactHasCloudfone: (BOOL)hasCloudFone
{
    float wIcon = 40.0;
    float marginX;
    float smallX = 30.0;
    if (hasCloudFone) {
        marginX = (_viewAction.frame.size.width - 4*wIcon - 3*smallX)/2;
        _btnCall.frame = CGRectMake(marginX, (hAction-(wIcon+25))/2, wIcon, wIcon);
        _lbCall.frame = CGRectMake(_btnCall.frame.origin.x-marginX/2, _btnCall.frame.origin.y+wIcon, wIcon+marginX, 25);
        _btnMessage.frame = CGRectMake(_btnCall.frame.origin.x+wIcon+smallX, _btnCall.frame.origin.y, wIcon, wIcon);
        _lbMessage.frame = CGRectMake(_btnMessage.frame.origin.x-marginX/2, _lbCall.frame.origin.y, _lbCall.frame.size.width, _lbCall.frame.size.height);
        _btnVideoCall.frame = CGRectMake(_btnMessage.frame.origin.x+wIcon+smallX, _btnMessage.frame.origin.y, wIcon, wIcon);
        _lbVideoCall.frame = CGRectMake(_btnVideoCall.frame.origin.x-marginX/2, _lbMessage.frame.origin.y, _lbMessage.frame.size.width, _lbMessage.frame.size.height);
        _btnBlock.frame = CGRectMake(_btnVideoCall.frame.origin.x+wIcon+smallX, _btnVideoCall.frame.origin.y, wIcon, wIcon);
        _lbBlock.frame = CGRectMake(_btnBlock.frame.origin.x-marginX/2, _lbVideoCall.frame.origin.y, _lbVideoCall.frame.size.width, _lbVideoCall.frame.size.height);
    }else{
        marginX = (_viewAction.frame.size.width - 3*wIcon - 2*smallX)/2;
        
        _btnCall.frame = CGRectMake(marginX, (hAction-(wIcon+25))/2, wIcon, wIcon);
        _lbCall.frame = CGRectMake(_btnCall.frame.origin.x-marginX/2, _btnCall.frame.origin.y+wIcon, wIcon+marginX, 25);
        
        _btnMessage.frame = CGRectMake(_btnCall.frame.origin.x+wIcon+smallX, _btnCall.frame.origin.y, wIcon, wIcon);
        _lbMessage.frame = CGRectMake(_btnMessage.frame.origin.x-marginX/2, _lbCall.frame.origin.y, _lbCall.frame.size.width, _lbCall.frame.size.height);
        
        _btnVideoCall.frame = CGRectMake(_btnMessage.frame.origin.x+wIcon+smallX, _btnMessage.frame.origin.y, wIcon, wIcon);
        _lbVideoCall.frame = CGRectMake(_btnVideoCall.frame.origin.x-marginX/2, _lbMessage.frame.origin.y, _lbMessage.frame.size.width, _lbMessage.frame.size.height);
    }
}

- (void)btnCallPressed: (UIButton *)sender {
    NSString *phoneNumber = sender.titleLabel.text;
    transfer_popup = NO;
    [self makeCallWithPhoneNumber: phoneNumber];
}

- (void)btnMessageTouchDown {
    [_btnMessage setBackgroundImage:[UIImage imageNamed:@"ic_mess_act.png"]
                        forState:UIControlStateNormal];
    
    [NSTimer scheduledTimerWithTimeInterval:0.05 target:self
                                   selector:@selector(startSendMessage)
                                   userInfo:nil repeats:false];
}

- (void)startSendMessage {
    [_btnMessage setBackgroundImage:[UIImage imageNamed:@"ic_mess_def.png"]
                           forState:UIControlStateNormal];
    
    appDelegate.reloadMessageList = YES;
    appDelegate.friendBuddy = [AppUtils getBuddyOfUserOnList: detailsContact._sipPhone];
    [[PhoneMainView instance] changeCurrentView:MainChatViewController.compositeViewDescription];
}

- (void)btnVideoCallTouchDown {
    [_btnVideoCall setBackgroundImage:[UIImage imageNamed:@"ic_call_video_act.png"]
                           forState:UIControlStateNormal];
    
    [NSTimer scheduledTimerWithTimeInterval:0.05 target:self
                                   selector:@selector(startVideoCall)
                                   userInfo:nil repeats:false];
}

- (void)startVideoCall {
    [_btnVideoCall setBackgroundImage:[UIImage imageNamed:@"ic_call_video_def.png"]
                             forState:UIControlStateNormal];
}

#pragma mark - Block & Unblock contact

//  Block 1 contact
- (void)blockThisContact
{
    /*  Leo Kelvin
    BOOL isBlocked = [NSDBCallnex addContactToBlacklist:appDelegate.idContact
                                         andCloudFoneID:detailsContact._cloudFoneID];
    if (isBlocked) {
        // Thay đổi trạng thái của button block
        [_btnBlock setBackgroundImage:[UIImage imageNamed:@"ic_unblock_def.png"]
                             forState:UIControlStateNormal];
        
        [_btnBlock setBackgroundImage:[UIImage imageNamed:@"ic_unblock_act.png"]
                             forState:UIControlStateHighlighted];
        
        [_btnBlock removeTarget:self action:@selector(blockThisContact)
               forControlEvents:UIControlEventTouchUpInside];
        
        [_btnBlock addTarget:self action:@selector(unblockThisContact)
            forControlEvents:UIControlEventTouchUpInside];
        
        [_lbBlock setText:[appDelegate.localization localizedStringForKey:text_detail_unblock]];
        
        NSArray *blackList = [NSDBCallnex getAllUserInCallnexBlacklist];
        [appDelegate.myBuddy.protocol blockUserInCallnexBlacklist: blackList];
        [appDelegate.myBuddy.protocol activeBlackListOfMe];
    }else{
        [self showMessagePopupUp:[appDelegate.localization localizedStringForKey:text_failed_block_contact]
                    withTimeShow:1.0 andHide:3.0];
    }
    appDelegate.isUpdateGroup = YES;
    */
}

//  Hàm xử lý unblock một contact
- (void)unblockThisContact
{
    /*  Leo Kelvin
    // Remove ra khoi bang group
    BOOL isRemoved = [NSDBCallnex removeContactFromBlacklist:appDelegate.idContact
                                                andCloudFoneID:detailsContact._cloudFoneID];
    if (isRemoved) {
        NSArray *blackList = [NSDBCallnex getAllUserInCallnexBlacklist];
        [appDelegate.myBuddy.protocol blockUserInCallnexBlacklist: blackList];
        [appDelegate.myBuddy.protocol activeBlackListOfMe];
        
        // Thay đổi trạng thái của button block
        [_btnBlock setBackgroundImage:[UIImage imageNamed:@"ic_block_def.png"]
                             forState:UIControlStateNormal];
        
        [_btnBlock setBackgroundImage:[UIImage imageNamed:@"ic_block_act.png"]
                             forState:UIControlStateHighlighted];
        
        [_btnBlock removeTarget:self action:@selector(unblockThisContact)
               forControlEvents:UIControlEventTouchUpInside];
        
        [_btnBlock addTarget:self action:@selector(blockThisContact)
            forControlEvents:UIControlEventTouchUpInside];
        
        [_lbBlock setText:[appDelegate.localization localizedStringForKey:text_detail_block]];
    }else{
        [self showMessagePopupUp:[appDelegate.localization localizedStringForKey:text_failed_block_contact]
                    withTimeShow:1.0 andHide:3.0];
    }
    appDelegate.isUpdateGroup = YES;
    */
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
    
    if (detailsContact._sipPhone == nil || [detailsContact._sipPhone isEqualToString:@""] || [detailsContact._sipPhone isEqualToString:@"(null)"] || [detailsContact._sipPhone isEqualToString:@"<null>"] || [detailsContact._sipPhone isEqualToString:@"null"])
    {
        [self setupFrameForContactHasCloudfone: false];
        
        _btnCall.enabled = FALSE;
        _btnCall.titleLabel.text = @"";
        
        _btnCall.enabled = NO;
        _btnVideoCall.enabled = NO;
        _btnMessage.enabled = NO;
        
        _btnBlock.hidden = YES;
        _lbBlock.hidden = YES;
    }else{
        [self setupFrameForContactHasCloudfone: true];
        
        _btnBlock.hidden = NO;
        _lbBlock.hidden = NO;
        
        _btnCall.enabled = TRUE;
        _btnCall.titleLabel.text = detailsContact._sipPhone;
        
        _btnVideoCall.enabled = YES;
        _btnMessage.enabled = YES;
        
        //  Kiểm tra contact này có bị block hay không?
        /*  Leo Kelvin
        NSArray *blackList = [NSDBCallnex getAllUserInCallnexBlacklist];
        NSPredicate *blockPredicate = [NSPredicate predicateWithFormat:@"_idContact = %d", appDelegate.idContact];
        NSArray *listFilter = [blackList filteredArrayUsingPredicate: blockPredicate];
        if (listFilter.count > 0) {
            [_btnBlock setBackgroundImage:[UIImage imageNamed:@"ic_unblock_def.png"]
                                       forState:UIControlStateNormal];
            [_btnBlock setBackgroundImage:[UIImage imageNamed:@"ic_unblock_act.png"]
                                       forState:UIControlStateHighlighted];
            [_btnBlock addTarget:self
                          action:@selector(unblockThisContact)
                forControlEvents:UIControlEventTouchUpInside];
            
            [_lbBlock setText: [appDelegate.localization localizedStringForKey:text_detail_unblock]];
        }else{
            //  Contact chưa bị Block
            [_btnBlock setBackgroundImage:[UIImage imageNamed:@"ic_block_def.png"]
                                       forState:UIControlStateNormal];
            [_btnBlock setBackgroundImage:[UIImage imageNamed:@"ic_block_act.png"]
                                       forState:UIControlStateHighlighted];
            [_btnBlock addTarget:self
                          action:@selector(blockThisContact)
                forControlEvents:UIControlEventTouchUpInside];
            [_lbBlock setText: [appDelegate.localization localizedStringForKey:text_detail_block]];
        }   */
    }
}

- (NSString *)getEmailFromContact: (ABRecordRef)aPerson
{
    NSString *email = @"";
    //get email
    ABMultiValueRef emailID = ABRecordCopyValue(aPerson, kABPersonEmailProperty);
    for(CFIndex j = 0; j < ABMultiValueGetCount(emailID); j++) {
        CFStringRef emailIDRef = ABMultiValueCopyValueAtIndex(emailID, j);
        email = (__bridge NSString *)emailIDRef;
        if (email != nil && ![email isEqualToString: @""]) {
            break;
        }
    }
    if (email == nil) {
        email = @"";
    }
    [email stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    return email;
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
        
        NSString *sipPhone = detailsContact._sipPhone;
        if (sipPhone != nil && ![sipPhone isEqualToString: @""]) {
            NSString *strUser = [NSString stringWithFormat:@"%@@%@", sipPhone, xmpp_cloudfone];
            [appDelegate.myBuddy.protocol removeUserFromRosterList:strUser
                                                     withIdMessage:[AppUtils randomStringWithLength: 10]];
        }
        
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
        [appDelegate.sipContacts removeObject: detailsContact];
        
        [waitingHud dismissAnimated:YES];
        
        [[PhoneMainView instance] popCurrentView];
    }
}

@end
