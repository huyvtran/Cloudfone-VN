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
    NSMutableArray *listHistoryCalls;
    
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

@synthesize _viewHeader, bgHeader, _iconBack, _lbHeader, _iconAddNew, _imgAvatar, _lbName;
@synthesize btnCall, _tbHistory;
@synthesize _refreshControl;
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
}

//  Cập nhật view sau khi get xong phone number
- (void)updateView {
    // Lấy tổng tiền và số phút gọi
    NSArray *infos = [NSDatabase getNameAndAvatarOfContactWithPhoneNumber: _phoneNumberDetail];
    if ([[infos objectAtIndex: 0] isEqualToString: @""]) {
        _lbName.text = _phoneNumberDetail;
        _iconAddNew.hidden = NO;
    }else{
        _lbName.text = [NSString stringWithFormat:@"%@ - %@", [infos objectAtIndex: 0], _phoneNumberDetail];
        _iconAddNew.hidden = YES;
    }
    
    NSString *avatar = [infos objectAtIndex:1];
    if ([avatar isEqualToString: @""] || [avatar isEqualToString: @"(null)"] || [avatar isEqualToString: @"null"] || [avatar isEqualToString: @"<null>"]) {
        _imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
    }else{
        NSData *imgData = [NSData dataFromBase64String: [infos objectAtIndex: 1]];
        _imgAvatar.image = [UIImage imageWithData: imgData];
    }
    
    // Check section
    [listHistoryCalls removeAllObjects];
    [listHistoryCalls addObjectsFromArray: [NSDatabase getAllListCallOfMe:USERNAME withPhoneNumber:_phoneNumberDetail]];
    [_tbHistory reloadData];
}

#pragma mark - my functions

- (void)setupUIForView
{
    self.view.backgroundColor = UIColor.whiteColor;
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
    [_viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(230+[LinphoneAppDelegate sharedInstance]._hStatus);
    }];
    
    [bgHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(_viewHeader);
    }];
    
    [_iconBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader).offset([LinphoneAppDelegate sharedInstance]._hStatus+5.0);
        make.left.equalTo(_viewHeader).offset(5.0);
        make.width.height.mas_equalTo(35.0);
    }];
    
    [_iconAddNew mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_iconBack);
        make.right.equalTo(_viewHeader).offset(-5);
        make.width.equalTo(_iconBack.mas_width);
        make.height.equalTo(_iconBack.mas_height);
    }];
    
    [_lbHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(_iconBack);
        make.left.equalTo(_iconBack.mas_right).offset(5);
        make.right.equalTo(_iconAddNew.mas_left).offset(-5);
    }];
    
    _imgAvatar.layer.cornerRadius = 100.0/2;
    _imgAvatar.layer.borderWidth = 2.0;
    _imgAvatar.layer.borderColor = UIColor.whiteColor.CGColor;
    _imgAvatar.clipsToBounds = YES;
    [_imgAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lbHeader.mas_bottom).offset(10);
        make.centerX.equalTo(_viewHeader.mas_centerX);
        make.width.height.mas_equalTo(100.0);
    }];
    
    _lbName.font = textFont;
    _lbName.textColor = UIColor.whiteColor;
    [_lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_imgAvatar.mas_bottom);
        make.left.right.equalTo(_viewHeader);
        make.height.mas_equalTo(40.0);
    }];
    
    //  button call
    btnCall.layer.cornerRadius = 70.0/2;
    btnCall.clipsToBounds = YES;
    btnCall.layer.borderWidth = 2.0;
    btnCall.layer.borderColor = UIColor.whiteColor.CGColor;
    [btnCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(_viewHeader.mas_bottom);
        make.width.height.mas_equalTo(70.0);
    }];
    
    //  content
    [_tbHistory mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnCall.mas_bottom).offset(10);
        make.left.right.bottom.equalTo(self.view);
    }];
    _tbHistory.delegate = self;
    _tbHistory.dataSource = self;
    _tbHistory.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    listHistoryCalls = [[NSMutableArray alloc] init];
    
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
}

#pragma mark - tableview delegate

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
    dateFormatter.dateFormat = @"dd/MM/yyyy";
    
    if ([strTime isEqualToString:[dateFormatter stringFromDate:yesterday] ]) {
        return [appDelegate.localization localizedStringForKey:text_yesterday];
    }
    
    if ([strTime isEqualToString:[dateFormatter stringFromDate:today]]) {
        return [appDelegate.localization localizedStringForKey:text_today];
    }
    
    return strTime;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return listHistoryCalls.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 35.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"UIHistoryDetailCell";
    
    UIHistoryDetailCell *cell = (UIHistoryDetailCell *)[tableView dequeueReusableCellWithIdentifier: simpleTableIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"UIHistoryDetailCell" owner:self options:nil];
        cell = topLevelObjects[0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CallHistoryObject *aCall = [listHistoryCalls objectAtIndex: indexPath.row];
    
    if (![aCall._date isEqualToString:@"date"]) {
        NSString *dateStr = [AppUtils checkTodayForHistoryCall: aCall._date];
        
        if (![dateStr isEqualToString:@"Today"]) {
            dateStr = [AppUtils checkYesterdayForHistoryCall: aCall._date];
            if ([dateStr isEqualToString:@"Yesterday"]) {
                dateStr = [appDelegate.localization localizedStringForKey:@"YESTERDAY"];
            }
        }else{
            dateStr = [appDelegate.localization localizedStringForKey:text_today];
        }
        cell.viewContent.hidden = YES;
        cell.lbTitle.hidden = NO;
    }else{
        cell.viewContent.hidden = NO;
        cell.lbTitle.hidden = YES;
        
        
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
            cell.lbTime.text = aCall._time;
        }else{
            if ([aCall._status isEqualToString: aborted_call]) {
                cell.lbStateCall.text = [appDelegate.localization localizedStringForKey:text_call_aborted];
                cell.lbDuration.text = @"";
            }else if ([aCall._status isEqualToString: declined_call]){
                cell.lbStateCall.text = [appDelegate.localization localizedStringForKey:text_call_aborted];
            }else{
                cell.lbStateCall.text = [appDelegate.localization localizedStringForKey:text_call_missed];
            }
            cell.lbTime.text = aCall._time;
        }
    }
    return cell;
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

- (void)startCall {
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

#pragma mark - My Functions


//  Cập nhật lịch sử cuộc gọi
- (void)updateHistoryWithPhoneNumber {
    [_refreshControl endRefreshing];
    
    // Check section
    [listHistoryCalls removeAllObjects];
    [listHistoryCalls addObjectsFromArray: [NSDatabase getAllListCallOfMe:USERNAME withPhoneNumber:_phoneNumberDetail]];
    
    [_tbHistory reloadData];
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

