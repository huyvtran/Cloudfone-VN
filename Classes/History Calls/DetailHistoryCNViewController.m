//
//  DetailHistoryCNViewController.m
//  linphone
//
//  Created by user on 18/3/14.
//
//

#import "DetailHistoryCNViewController.h"
#import "NewContactViewController.h"
#import "AllContactListViewController.h"
#import "MainChatViewController.h"
//  Leo Kelvin
//  #import "HotlineViewController.h"
//  #import "OTRProtocolManager.h"
#import "PhoneMainView.h"
#import "JSONKit.h"
#import "UIHistoryDetailCell.h"
#import "CallHistoryObject.h"
#import "NSDatabase.h"
#import "NSData+Base64.h"
#import "contactBlackListCell.h"

#import <CommonCrypto/CommonDigest.h>

@interface DetailHistoryCNViewController ()
{
    LinphoneAppDelegate *appDelegate;
    float hInfo;
    
    BOOL transfer_popup;
    
    // list history call
    NSArray *arrOugoingcalls;
    NSArray *arrIncommingcalls;
    int historySection;
    
    NSMutableArray *listOutgoing;
    NSMutableArray *listIncomming;
    
    BOOL checkSection;
    
    int totalDuration;
    
    int originXTotalMinites;
    
    float hCell;
    float hSection;
    
    UIFont *textFont;
    UIFont *textFontDes;
    UIFont *textFontBold;
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

@implementation DetailHistoryCNViewController
@synthesize _viewHeader, _iconBack, _lbHeader, _iconAddNew;
@synthesize _viewInfo, _imgAvatar, _lbName, _lbPhone;
@synthesize _viewButton, _iconCall, _lbCall, _iconMessage, _lbMessage, _iconVideo, _lbVideo, _iconBlockUnblock, _lbBlockUnblock;
@synthesize _tbHistory, _refreshControl;
@synthesize phoneNumber, _phoneNumberDetail;

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;
+ (UICompositeViewDescription *)compositeViewDescription {
    if (compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:nil
                                                                 tabBar:nil
                                                               sideMenu:nil
                                                             fullscreen:NO
                                                         isLeftFragment:YES
                                                           fragmentWith:nil];
        compositeDescription.darkBackground = true;
    }
    return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
    return self.class.compositeViewDescription;
}

#pragma mark - View controllers

//  View không bị thay đổi sau khi vào pickerview controller
- (void) viewDidLayoutSubviews {
    if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        CGRect viewBounds = self.view.bounds;
        CGFloat topBarOffset = self.topLayoutGuide.length;
        viewBounds.origin.y = topBarOffset * -1;
        self.view.bounds = viewBounds;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Property Functions

- (void)setPhoneNumberForView:(NSString *)phoneNumberStr {
    _phoneNumberDetail = [[NSString alloc] initWithString:[phoneNumberStr copy]];
    [self updateView];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // MY CODE HERE
    appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self setupUIForView];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self showContentWithCurrentLanguage];
    
    // Tắt màn hình cảm biến
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled: NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView)
                                                 name:reloadHistoryCall object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showContentWithCurrentLanguage {
    _lbHeader.text = [appDelegate.localization localizedStringForKey:text_call_detail_header];
    _lbCall.text = [appDelegate.localization localizedStringForKey:text_detail_call];
    _lbMessage.text = [appDelegate.localization localizedStringForKey:text_detail_message];
    _lbVideo.text = [appDelegate.localization localizedStringForKey:text_detail_video_call];
}

//  Cập nhật view sau khi get xong phone number
- (void)updateView {
    // Lấy tổng tiền và số phút gọi
    totalDuration = 0;
    
    NSArray *infosCall = [NSDatabase getTotalDurationAndRateOfCallWithPhone: _phoneNumberDetail];
    totalDuration = [[infosCall firstObject] intValue];
  
    NSArray *infos = [NSDatabase getNameAndAvatarOfContactWithPhoneNumber: _phoneNumberDetail];
    if ([[infos objectAtIndex: 0] isEqualToString: @""]) {
        _lbName.text = [appDelegate.localization localizedStringForKey: text_unknown];
        _lbPhone.text = [NSString stringWithFormat:@"(%@)", _phoneNumberDetail];
        
        _iconAddNew.hidden = NO;
    }else{
        _lbName.text = [infos objectAtIndex: 0];
        _lbPhone.text = [NSString stringWithFormat:@"(%@)", _phoneNumberDetail];
        
        _iconAddNew.hidden = YES;
    }
    
    NSString *avatar = [infos objectAtIndex:1];
    if ([avatar isEqualToString: @""] || [avatar isEqualToString: @"(null)"] || [avatar isEqualToString: @"null"] || [avatar isEqualToString: @"<null>"]) {
        _imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
    }else{
        NSData *imgData = [NSData dataFromBase64String: [infos objectAtIndex: 1]];
        _imgAvatar.image = [UIImage imageWithData: imgData];
    }
    
    //  Kiểm tra cloudFoneID có đang bị block hay ko?
    BOOL block = [NSDatabase checkCloudFoneIDInBlackList: _phoneNumberDetail ofAccount: USERNAME];
    if (block) {
        [_iconBlockUnblock setBackgroundImage:[UIImage imageNamed:@"ic_unblock_def.png"]
                                     forState:UIControlStateNormal];
        [_iconBlockUnblock setBackgroundImage:[UIImage imageNamed:@"ic_unblock_act.png"]
                                     forState:UIControlStateHighlighted];
        _lbBlockUnblock.text = [appDelegate.localization localizedStringForKey:text_unblock_user];
    }else{
        [_iconBlockUnblock setBackgroundImage:[UIImage imageNamed:@"ic_block_def.png"]
                                     forState:UIControlStateNormal];
        [_iconBlockUnblock setBackgroundImage:[UIImage imageNamed:@"ic_block_act.png"]
                                     forState:UIControlStateHighlighted];
        _lbBlockUnblock.text = [appDelegate.localization localizedStringForKey:text_block_user];
    }
    
    if ([_phoneNumberDetail hasPrefix:@"778899"]) {
        _iconMessage.enabled = YES;
    }else{
        _iconMessage.enabled = NO;
    }
    
    // Check section
    [listOutgoing removeAllObjects];
    [listOutgoing addObjectsFromArray: [NSDatabase getAllListCallOfMe:USERNAME withPhoneNumber:_phoneNumberDetail andCallDirection:outgoing_call]];
    
    [listIncomming removeAllObjects];
    [listIncomming addObjectsFromArray: [NSDatabase getAllListCallOfMe:USERNAME withPhoneNumber:_phoneNumberDetail andCallDirection: incomming_call]];
    
    if (listOutgoing.count > 0 && listIncomming.count > 0) {
        checkSection = YES;
    }else{
        checkSection = NO;
    }
    [_tbHistory reloadData];
}

#pragma mark - my functions

- (void)setupUIForView
{
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
        textFontDes = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
        textFontBold = [UIFont fontWithName:MYRIADPRO_BOLD size:16.0];
        
        _lbHeader.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:20.0];
    }else{
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
        textFontDes = [UIFont fontWithName:MYRIADPRO_REGULAR size:14.0];
        textFontBold = [UIFont fontWithName:MYRIADPRO_BOLD size:14.0];
        
        _lbHeader.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }
    //  header
    _viewHeader.frame = CGRectMake(0, 0, SCREEN_WIDTH, appDelegate._hHeader);
    _iconBack.frame = CGRectMake(0, 0, appDelegate._hHeader, appDelegate._hHeader);
    [_iconBack setBackgroundImage:[UIImage imageNamed:@"ic_back_act.png"]
                         forState:UIControlStateHighlighted];
    _iconAddNew.frame = CGRectMake(_viewHeader.frame.size.width-appDelegate._hHeader, 0, appDelegate._hHeader, appDelegate._hHeader);
    _lbHeader.frame = CGRectMake(_iconBack.frame.origin.x+_iconBack.frame.size.width+5, 0, _viewHeader.frame.size.width-(2*appDelegate._hHeader+10), appDelegate._hHeader);
    
    //  view info
    hInfo = 140.0;
    _viewInfo.frame = CGRectMake(0, _viewHeader.frame.origin.y+_viewHeader.frame.size.height, SCREEN_WIDTH, hInfo);
    _imgAvatar.frame = CGRectMake((_viewInfo.frame.size.width-65)/2, 5, 65, 65);
    _imgAvatar.layer.cornerRadius = _imgAvatar.frame.size.width/2;
    _imgAvatar.clipsToBounds = YES;
    
    _lbName.frame = CGRectMake(0, _imgAvatar.frame.origin.y+_imgAvatar.frame.size.height, _viewInfo.frame.size.width, 30);
    _lbName.font = textFont;
    
    _lbPhone.frame = CGRectMake(_lbName.frame.origin.x, _lbName.frame.origin.y+_lbName.frame.size.height, _lbName.frame.size.width, _lbName.frame.size.height);
    _lbPhone.textColor = [UIColor grayColor];
    if (SCREEN_WIDTH > 320) {
        _lbPhone.font = [UIFont fontWithName:HelveticaNeueItalic size:16.0];
    }else{
        _lbPhone.font = [UIFont fontWithName:HelveticaNeueItalic size:14.0];
    }    
    
    //  view action
    float hAction = 70.0;
    float wIcon = 35.0;
    _viewButton.frame = CGRectMake(0, _viewInfo.frame.origin.y+_viewInfo.frame.size.height, SCREEN_WIDTH, hAction);
    
    float marginX = (_viewButton.frame.size.width - 4*wIcon)/5;
    _iconCall.frame = CGRectMake(marginX, (hAction-(wIcon+25))/2, wIcon, wIcon);
    [_iconCall addTarget:self
                  action:@selector(btnCallTouchDown)
        forControlEvents:UIControlEventTouchDown];
    
    _lbCall.frame = CGRectMake(_iconCall.frame.origin.x-marginX/2, _iconCall.frame.origin.y+wIcon, wIcon+marginX, 25);
    [_iconCall setBackgroundImage:[UIImage imageNamed:@"ic_call_act.png"]
                         forState:UIControlStateHighlighted];
    _lbCall.font = textFont;
    
    //  message
    _iconMessage.frame = CGRectMake(_iconCall.frame.origin.x+wIcon+marginX, _iconCall.frame.origin.y, wIcon, wIcon);
    [_iconMessage addTarget:self
                     action:@selector(btnMessageTouchDown)
           forControlEvents:UIControlEventTouchDown];
    
    _lbMessage.frame = CGRectMake(_iconMessage.frame.origin.x-marginX/2, _lbCall.frame.origin.y, _lbCall.frame.size.width, _lbCall.frame.size.height);
    _lbMessage.font = textFont;
    [_iconMessage setBackgroundImage:[UIImage imageNamed:@"ic_mess_act.png"]
                            forState:UIControlStateHighlighted];
    [_iconMessage setBackgroundImage:[UIImage imageNamed:@"ic_mess_dis.png"]
                            forState:UIControlStateDisabled];
    
    //  video call
    _iconVideo.frame = CGRectMake(_iconMessage.frame.origin.x+wIcon+marginX, _iconMessage.frame.origin.y, wIcon, wIcon);
    [_iconVideo addTarget:self
                   action:@selector(btnVideoCallTouchDown)
         forControlEvents:UIControlEventTouchDown];
    _lbVideo.frame = CGRectMake(_iconVideo.frame.origin.x-marginX/2, _lbMessage.frame.origin.y, _lbMessage.frame.size.width, _lbMessage.frame.size.height);
    
    [_iconVideo setBackgroundImage:[UIImage imageNamed:@"ic_call_video_act.png"]
                          forState:UIControlStateHighlighted];
    _lbVideo.font = textFont;
    
    //  invite
    _iconBlockUnblock.frame = CGRectMake(_iconVideo.frame.origin.x+wIcon+marginX, _iconVideo.frame.origin.y, wIcon, wIcon);
    _lbBlockUnblock.frame = CGRectMake(_iconBlockUnblock.frame.origin.x-marginX/2, _lbVideo.frame.origin.y, _lbVideo.frame.size.width, _lbVideo.frame.size.height);
    [_iconBack setBackgroundImage:[UIImage imageNamed:@"ic_back_act.png"]
                         forState:UIControlStateHighlighted];
    [_iconAddNew setBackgroundImage:[UIImage imageNamed:@"ic_add_act.png"]
                           forState:UIControlStateHighlighted];

    _tbHistory.frame = CGRectMake(0, _viewButton.frame.origin.y+_viewButton.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT-(appDelegate._hStatus+appDelegate._hHeader+hInfo+hAction));
    _tbHistory.delegate = self;
    _tbHistory.dataSource = self;
    _tbHistory.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    listOutgoing = [[NSMutableArray alloc] init];
    listIncomming = [[NSMutableArray alloc] init];
    
    // Refreshing.....
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.tintColor = UIColor.magentaColor;
    [_refreshControl endRefreshing];
    _refreshControl.backgroundColor = UIColor.whiteColor;
    [_refreshControl addTarget:self
                        action:@selector(updateHistoryWithPhoneNumber)
              forControlEvents:UIControlEventValueChanged];
    [_refreshControl endRefreshing];
    [_tbHistory addSubview: _refreshControl];
    
    originXTotalMinites = 0;
    
    hCell = 30.0;
    hSection = 30.0;
}

#pragma mark - tableview delegate

- (void)reloadData {
    arrOugoingcalls = [[NSArray alloc] initWithArray:[NSDatabase getAllRowsByCallDirection:outgoing_call phone:phoneNumber]];
    arrIncommingcalls = [[NSArray alloc] initWithArray:[NSDatabase getAllRowsByCallDirection:incomming_call phone:phoneNumber]];
    
    [_tbHistory reloadData];
}

- (NSString *)convertIntToTime : (int) time{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *startData = [NSDate dateWithTimeIntervalSince1970:time];
    dateFormatter.dateFormat = @"HH:mm";
    NSString *str_time = [dateFormatter stringFromDate:startData];
    return str_time;
}

- (void) dealloc{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)checkDateCurrentAndYesterday: (NSString *)strTime {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:[[NSDate alloc] init]];
    
    [components setHour:-[components hour]];
    [components setMinute:-[components minute]];
    [components setSecond:-[components second]];
    NSDate *today = [cal dateByAddingComponents:components toDate:[[NSDate alloc] init] options:0];
    
    [components setHour:-24];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *yesterday = [cal dateByAddingComponents:components toDate: today options:0];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd-MM-yyyy";
    
    if ([strTime isEqualToString:[dateFormatter stringFromDate:yesterday] ]) {
        return [appDelegate.localization localizedStringForKey:text_yesterday];
    }
    
    if ([strTime isEqualToString:[dateFormatter stringFromDate:today]]) {
        return [appDelegate.localization localizedStringForKey:text_today];
    }
    
    return strTime;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (checkSection) {
        return 2;
    }else if (listOutgoing.count > 0 || listIncomming.count > 0){
        return 1;
    }else{
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (checkSection) {
        if (section == 0) {
            return listOutgoing.count;
        }else{
            return listIncomming.count;
        }
    }else if (listOutgoing.count > 0 && listIncomming.count == 0){
        return listOutgoing.count;
    }else if(listOutgoing.count == 0 && listIncomming.count > 0){
        return listIncomming.count;
    }else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return hCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return hSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"UIHistoryDetailCell";
    
    UIHistoryDetailCell *cell = (UIHistoryDetailCell *)[tableView dequeueReusableCellWithIdentifier: simpleTableIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"UIHistoryDetailCell" owner:self options:nil];
        cell = topLevelObjects[0];
    }
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, _tbHistory.frame.size.width, hCell);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.lbTime.font = textFontDes;
    cell.lbDuration.font = textFontDes;
    cell.lbTitle.font = textFontDes;
    [cell setupUIForCell];
    
    CallHistoryObject *aCall = [[CallHistoryObject alloc] init];
    if (checkSection) {
        if (indexPath.section == 0) {
            aCall = [listOutgoing objectAtIndex: indexPath.row];
        }else{
            aCall = [listIncomming objectAtIndex: indexPath.row];
        }
    }else if (listOutgoing.count > 0 && listIncomming.count == 0){
        aCall = [listOutgoing objectAtIndex: indexPath.row];
    }else if(listOutgoing.count == 0 && listIncomming.count > 0){
        aCall = [listIncomming objectAtIndex: indexPath.row];
    }else{
        return nil;
    }
    
    if (![aCall._date isEqualToString:@"date"]) {
        NSString *dateStr = [AppUtils checkTodayForHistoryCall: aCall._date];
        
        if (![dateStr isEqualToString:@"Today"]) {
            dateStr = [AppUtils checkYesterdayForHistoryCall: aCall._date];
            if ([dateStr isEqualToString:@"Yesterday"]) {
                dateStr = [appDelegate.localization localizedStringForKey:text_yesterday];
            }
        }else{
            dateStr = [appDelegate.localization localizedStringForKey:text_today];
        }
        cell._imageClock.hidden = YES;
        cell.lbTime.hidden = YES;
        cell.lbDuration.hidden = YES;
        cell.lbRate.hidden = YES;
        
        UILabel *lbDate = [[UILabel alloc] initWithFrame:cell.frame];
        lbDate.text = dateStr;
        lbDate.textAlignment = NSTextAlignmentCenter;
        lbDate.font = textFontBold;
        lbDate.textColor = [UIColor colorWithRed:(50/255.0) green:(50/255.0)
                                            blue:(50/255.0) alpha:1];
        [cell addSubview: lbDate];
    }else{
        if (originXTotalMinites == 0) {
            originXTotalMinites = cell.lbDuration.frame.origin.x + cell.lbDuration.frame.size.width;
        }
        
        if ([aCall._status isEqualToString: success_call])
        {
            int timeValue = 0;
            float time = (float)aCall._duration/60;
            if (time > (int)time) {
                timeValue = (int)time + 1;
            }
            if (timeValue == 0) {
                timeValue = 1;
            }
            
            if (time == 1) {
                cell.lbDuration.text = [NSString stringWithFormat:@"%d %@", timeValue, [appDelegate.localization localizedStringForKey:text_minute]];
            }else{
                cell.lbDuration.text = [NSString stringWithFormat:@"%d %@", timeValue, [appDelegate.localization localizedStringForKey:text_minutes]];
            }
            cell.lbDuration.font = textFontDes;
            cell.lbDuration.textColor = [UIColor colorWithRed:(142/255.0) green:(193/255.0) blue:(5/255.0) alpha:1];
            cell.lbTime.text = aCall._time;
            if (aCall._rate == -1) {
                cell.lbRate.text = @"N/A";
            }else if (aCall._rate == 0) {
                cell.lbRate.text = [appDelegate.localization localizedStringForKey:text_call_free];
            }else{
                cell.lbRate.text = [NSString stringWithFormat:@"%f", aCall._rate];
            }
            cell.lbRate.font = textFontDes;
            cell.lbRate.hidden = NO;
        }else{
            if ([aCall._status isEqualToString: aborted_call]) {
                cell.lbDuration.text = [appDelegate.localization localizedStringForKey:text_call_aborted];
                cell.lbDuration.textColor = UIColor.redColor;
            }else if ([aCall._status isEqualToString: declined_call]){
                cell.lbDuration.text = [appDelegate.localization localizedStringForKey:text_call_aborted];
                cell.lbDuration.textColor = UIColor.redColor;
            }else{
                cell.lbDuration.text = [appDelegate.localization localizedStringForKey:text_call_missed];
                cell.lbDuration.textColor = UIColor.redColor;
            }
            cell.lbTime.text = aCall._time;
            cell.lbRate.text = @"N/A";
        }
    }
    if (indexPath.section == 1) {
        cell.lbRate.text = @"N/A";
    }
    return cell;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *titleHeader = @"";
    if (checkSection) {
        if (section == 0) {
            titleHeader = [appDelegate.localization localizedStringForKey:text_outging_call];
        }else{
            titleHeader = [appDelegate.localization localizedStringForKey:text_incomming_call];
        }
    }else if (listOutgoing.count > 0 && listIncomming.count == 0){
        titleHeader = [appDelegate.localization localizedStringForKey:text_outging_call];
    }else if(listOutgoing.count == 0 && listIncomming.count > 0){
        titleHeader = [appDelegate.localization localizedStringForKey:text_incomming_call];
    }else{
        titleHeader = @"";
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, hSection)];
    [headerView setBackgroundColor:[UIColor colorWithRed:(240/255.0) green:(240/255.0)
                                                    blue:(240/255.0) alpha:1.0]];
    
    //  Add label incoming outgoing
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.width, hSection)];
    [descLabel setBackgroundColor:[UIColor clearColor]];
    [descLabel setTextColor: [UIColor colorWithRed:(50/255.0) green:(50/255.0)
                                              blue:(50/255.0) alpha:1.0]];
    [descLabel setFont:textFontBold];
    [descLabel setText: titleHeader];
    [headerView addSubview: descLabel];
    
    //  Add label tong so phut goi
    if (section == 0) {
        UILabel *lbMinute = [[UILabel alloc] initWithFrame:CGRectMake(originXTotalMinites-90, 0, 90, hSection)];
        [lbMinute setTextAlignment: NSTextAlignmentRight];
        if (totalDuration > 0) {
            if ((int)totalDuration/60 == 1) {
                [lbMinute setText:[NSString stringWithFormat:@"%d %@", (int)totalDuration/60, [appDelegate.localization localizedStringForKey:text_minute]]];
            }else{
                [lbMinute setText:[NSString stringWithFormat:@"%d %@", (int)totalDuration/60, [appDelegate.localization localizedStringForKey:text_minutes]]];
            }
        }
        [lbMinute setFont: textFontDes];
        [lbMinute setTextAlignment:NSTextAlignmentRight];
        [lbMinute setTextColor:[UIColor colorWithRed:(142/255.0) green:(193/255.0) blue:(5/255.0) alpha:1]];
        [lbMinute setBackgroundColor:[UIColor clearColor]];
        [headerView addSubview: lbMinute];
    }
    
    return headerView;
}

- (IBAction)_iconBackClicked:(UIButton *)sender {
    appDelegate._newContact = nil;
    [[PhoneMainView instance] popCurrentView];
}

- (IBAction)_iconAddNewClicked:(UIButton *)sender {
    UIActionSheet *popupAddContact = [[UIActionSheet alloc] initWithTitle:_phoneNumberDetail delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:text_cancel] destructiveButtonTitle:nil otherButtonTitles:
                                      [appDelegate.localization localizedStringForKey:text_add_new_contact],
                                      [appDelegate.localization localizedStringForKey:text_add_exists_contact],
                                      nil];
    popupAddContact.tag = 100;
    [popupAddContact showInView:self.view];
}

- (IBAction)_iconCallClicked:(UIButton *)sender {
    
}

- (void)btnCallTouchDown {
    [_iconCall setBackgroundImage:[UIImage imageNamed:@"ic_call_act.png"]
                         forState:UIControlStateNormal];
    [NSTimer scheduledTimerWithTimeInterval:0.05 target:self
                                   selector:@selector(startCall)
                                   userInfo:nil repeats:false];
}

- (void)startCall {
    [_iconCall setBackgroundImage:[UIImage imageNamed:@"ic_call_def.png"]
                         forState:UIControlStateNormal];
    
    LinphoneAddress *addr = linphone_core_interpret_url(LC, _phoneNumberDetail.UTF8String);
    [LinphoneManager.instance call:addr];
    if (addr)
        linphone_address_destroy(addr);
    
    OutgoingCallViewController *controller = VIEW(OutgoingCallViewController);
    if (controller != nil) {
        [controller setPhoneNumberForView: _phoneNumberDetail];
    }
    [[PhoneMainView instance] changeCurrentView:[OutgoingCallViewController compositeViewDescription] push:TRUE];
}

- (void)btnMessageTouchDown {
    [_iconMessage setBackgroundImage:[UIImage imageNamed:@"ic_mess_act.png"]
                            forState:UIControlStateNormal];
    
    [NSTimer scheduledTimerWithTimeInterval:0.05 target:self
                                   selector:@selector(startSendMessage)
                                   userInfo:nil repeats:false];
}

- (void)startSendMessage {
    [_iconMessage setBackgroundImage:[UIImage imageNamed:@"ic_mess_def.png"]
                            forState:UIControlStateNormal];
    if (![_phoneNumberDetail hasPrefix:@"778899"]) {
        appDelegate.friendBuddy = [AppUtils getBuddyOfUserOnList: _phoneNumberDetail];
        [[PhoneMainView instance] changeCurrentView:[MainChatViewController compositeViewDescription] push:true];
    }else{
        [self.view makeToast:[appDelegate.localization localizedStringForKey:text_not_send_message] duration:3.0 position:CSToastPositionCenter];
    }
}

- (void)btnVideoCallTouchDown {
    [_iconVideo setBackgroundImage:[UIImage imageNamed:@"ic_call_video_act.png"]
                          forState:UIControlStateNormal];
    
    [NSTimer scheduledTimerWithTimeInterval:0.05 target:self
                                   selector:@selector(startVideoCall)
                                   userInfo:nil repeats:false];
}

- (void)startVideoCall {
    [_iconVideo setBackgroundImage:[UIImage imageNamed:@"ic_call_video_def.png"]
                          forState:UIControlStateNormal];
    
    LinphoneAddress *addr = linphone_core_interpret_url(LC, _phoneNumberDetail.UTF8String);
    [LinphoneManager.instance call:addr];
    if (addr)
        linphone_address_destroy(addr);
    
    OutgoingCallViewController *controller = VIEW(OutgoingCallViewController);
    if (controller != nil) {
        [controller setPhoneNumberForView: _phoneNumberDetail];
    }
    [[PhoneMainView instance] changeCurrentView:[OutgoingCallViewController compositeViewDescription] push:TRUE];
}

- (IBAction)_iconMessageClicked:(UIButton *)sender {
    appDelegate.friendBuddy = [AppUtils getBuddyOfUserOnList: _phoneNumberDetail];
    [[PhoneMainView instance] changeCurrentView:[MainChatViewController compositeViewDescription] push:true];
}

- (IBAction)_iconVideoClicked:(UIButton *)sender {
    
}

- (IBAction)_iconBlockUnblockClicked:(UIButton *)sender {
    /*  Leo Kelvin
    if (appDelegate.xmppStream.isConnected)
    {
        BOOL isBlock = [NSDBCallnex checkCloudFoneIDInBlackList: _phoneNumberDetail ofAccount: USERNAME];
        
        NSMutableArray *blackList = [NSDBCallnex getAllUserInCallnexBlacklist];
        if (isBlock) {
            //  Xoá các cloudfoneID bị block ra khỏi danh sách
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_callnexContact = %@", _phoneNumberDetail];
            NSArray *filter = [blackList filteredArrayUsingPredicate: predicate];
            if (filter.count > 0) {
                [blackList removeObjectsInArray: filter];
                
                [NSDBCallnex removeCloudFoneFromBlackList: _phoneNumberDetail ofAccount: USERNAME];
                
                [appDelegate.myBuddy.protocol blockUserInCallnexBlacklist: blackList];
                
                //
                [_iconBlockUnblock setBackgroundImage:[UIImage imageNamed:@"ic_block_def.png"]
                                             forState:UIControlStateNormal];
                [_iconBlockUnblock setBackgroundImage:[UIImage imageNamed:@"ic_block_act.png"]
                                             forState:UIControlStateHighlighted];
                [_lbBlockUnblock setText: [appDelegate.localization localizedStringForKey:text_block_user]];
            }
        }else{
            int idContact = [NSDBCallnex getContactIDWithCloudFoneID: _phoneNumberDetail];
            
            contactBlackListCell *curContact = [[contactBlackListCell alloc] init];
            [curContact set_idContact: idContact];
            [curContact set_callnexContact: _phoneNumberDetail];
            [blackList addObject: curContact];
            
            [NSDBCallnex addCloudFoneIDToBlackList: _phoneNumberDetail andIdContact: idContact ofAccount: USERNAME];
            
            [appDelegate.myBuddy.protocol blockUserInCallnexBlacklist: blackList];
            
            [_iconBlockUnblock setBackgroundImage:[UIImage imageNamed:@"ic_unblock_def.png"]
                                         forState:UIControlStateNormal];
            [_iconBlockUnblock setBackgroundImage:[UIImage imageNamed:@"ic_unblock_act.png"]
                                         forState:UIControlStateHighlighted];
            
            [_lbBlockUnblock setText: [appDelegate.localization localizedStringForKey:text_unblock_user]];
        }
    }else{
        [self showMessagePopupWithContent: [appDelegate.localization localizedStringForKey:text_failed]];
    }   */
}

#pragma mark - My Functions


//  Cập nhật lịch sử cuộc gọi
- (void)updateHistoryWithPhoneNumber {
    [_refreshControl endRefreshing];
    
    // Lấy tổng tiền và số phút gọi
    totalDuration = 0;
    
    NSArray *infosCall = [NSDatabase getTotalDurationAndRateOfCallWithPhone: _phoneNumberDetail];
    totalDuration = [[infosCall firstObject] intValue];
    
    // Check section
    [listOutgoing removeAllObjects];
    [listOutgoing addObjectsFromArray: [NSDatabase getAllListCallOfMe:USERNAME withPhoneNumber:_phoneNumberDetail andCallDirection:outgoing_call]];
    
    [listIncomming removeAllObjects];
    [listIncomming addObjectsFromArray: [NSDatabase getAllListCallOfMe:USERNAME withPhoneNumber:_phoneNumberDetail andCallDirection:incomming_call]];
    
    if (listOutgoing.count > 0 && listIncomming.count > 0) {
        checkSection = YES;
    }else{
        checkSection = NO;
    }
    [_tbHistory reloadData];
}

- (NSString *)getStatusOfUser: (NSString *)callnexUser
{
    return welcomeToCloudFone;
    /*  Leo Kelvin
    if (![callnexUser isEqualToString: @""]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"accountName CONTAINS[cd] %@", callnexUser];
        NSMutableDictionary *listUserDict = [[[OTRProtocolManager sharedInstance] buddyList] allBuddies];
        NSArray *listUser = [OTRBuddyList sortBuddies: listUserDict];
        NSArray *resultArr = [listUser filteredArrayUsingPredicate: predicate];
        if (resultArr.count > 0) {
            OTRBuddy *curBuddy = [resultArr objectAtIndex: 0];
            if (curBuddy.status == kOTRBuddyStatusOffline) {
                //  ssss
                // NSString *lastLogout = [appDelegate.timeLogoutUserDict objectForKey: callnexUser];
                NSString *lastLogout = @"";
                if (lastLogout == nil) {
                    return [appDelegate.localization localizedStringForKey:text_chat_offline];
                }else{
                    return [NSString stringWithFormat:@"%@: %@", [appDelegate.localization localizedStringForKey:CN_CALL_DETAIL_VC_LAST_SEEN_ON], lastLogout];
                }
            }else{
                NSString *status = [appDelegate._statusXMPPDict objectForKey: callnexUser];
                if (status == nil || [status isEqualToString: @""]) {
                    return welcomeToCloudFone;
                }else{
                    return status;
                }
            }
        }else{
            return welcomeToCloudFone;
        }
    }else{
        return welcomeToCloudFone;
    }
    */
}

//  Hàm chuyển chuỗi phone thành phone mặc định ban đầu
- (NSString *)convertPhoneStringToPhoneDefault: (NSString *)strPhone {
    NSString *result = strPhone;
    NSString *subStr = @"";
    if (strPhone.length > 3) {
        subStr = [strPhone substringToIndex: 3];
        if ([subStr isEqualToString:@"sv-"]) {
            result = [strPhone substringFromIndex: 3];
            if (result.length >= 2) {
                subStr = [result substringToIndex: 2];
                if ([subStr isEqualToString:@"84"]) {
                    result = [NSString stringWithFormat:@"0%@", [result substringFromIndex: 2]];
                }
            }
        }
    }
    return result;
}

- (void)blockThisContact {
    /*  Leo Kelvin
    int idContact = [NSDBCallnex getContactIDWithCloudFoneID: _phoneNumberDetail];
    BOOL isBlocked = [NSDBCallnex addContactToBlacklist:idContact andCloudFoneID:_phoneNumberDetail];
    
    //  kiem tra co block thanh cong hay ko roi moi them vao db
    
    if (isBlocked) {
//        // Thay đổi trạng thái của button block
//        [_btnBlock setBackgroundImage:[UIImage imageNamed:@"ic_unblock_def.png"]
//                             forState:UIControlStateNormal];
//        
//        [_btnBlock setBackgroundImage:[UIImage imageNamed:@"ic_unblock_act.png"]
//                             forState:UIControlStateHighlighted];
//        
//        [_btnBlock removeTarget:self action:@selector(blockThisContact)
//               forControlEvents:UIControlEventTouchUpInside];
//        
//        [_btnBlock addTarget:self action:@selector(unblockThisContact)
//            forControlEvents:UIControlEventTouchUpInside];
//        
//        [_lbBlock setText:NSLocalizedString(text_detail_unblock, nil)];
        
        NSArray *blackList = [NSDBCallnex getAllUserInCallnexBlacklist];
        [appDelegate.myBuddy.protocol blockUserInCallnexBlacklist: blackList];
        [appDelegate.myBuddy.protocol activeBlackListOfMe];
    }else{
        [self showMessagePopupWithContent: [appDelegate.localization localizedStringForKey:text_failed_block_contact]];
    }   */
}

#pragma mark - Actionsheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 100) {
        switch (buttonIndex) {
            case 0:{
                NewContactViewController *controller = VIEW(NewContactViewController);
                if (controller) {
                    if ([_phoneNumberDetail hasPrefix:@"778899"]) {
                        controller.currentSipPhone = _phoneNumberDetail;
                        controller.currentPhoneNumber = @"";
                        controller.currentName = @"";
                    }else{
                        controller.currentSipPhone = @"";
                        controller.currentPhoneNumber = _phoneNumberDetail;
                        controller.currentName = @"";
                    }
                }
                [[PhoneMainView instance] changeCurrentView:[NewContactViewController compositeViewDescription]
                                                       push:true];
                break;
            }
            case 1:{
                AllContactListViewController *controller = VIEW(AllContactListViewController);
                if (controller != nil) {
                    controller.phoneNumber = _phoneNumberDetail;
                }
                [[PhoneMainView instance] changeCurrentView:[AllContactListViewController compositeViewDescription]
                                                       push:true];
                break;
            }
            default:
                break;
        }
    }
}

@end

