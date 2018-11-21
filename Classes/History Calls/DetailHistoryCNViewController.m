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
#import "UIHistoryDetailCell.h"
#import "NewHistoryDetailCell.h"
#import "CallHistoryObject.h"
#import "NSDatabase.h"
#import "NSData+Base64.h"
#import "contactBlackListCell.h"

@interface DetailHistoryCNViewController () {
    LinphoneAppDelegate *appDelegate;
    NSMutableArray *listHistoryCalls;
    UIFont *textFont;
    BOOL newLayout;
}
@end

@implementation DetailHistoryCNViewController

@synthesize _viewHeader, bgHeader, _iconBack, _lbHeader, _iconAddNew, _imgAvatar, _lbName, icDelete;
@synthesize btnCall, _tbHistory;
@synthesize phoneNumber, onDate;

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

- (void)setPhoneNumberForView:(NSString *)phone andDate: (NSString *)date {
    phoneNumber = [[NSString alloc] initWithString:[phone copy]];
    onDate = [[NSString alloc] initWithString:[date copy]];
    
    [self updateView];
    
    //  reset missed call
    [NSDatabase resetMissedCallOfRemote:phoneNumber onDate:onDate ofAccount:USERNAME];
    [[NSNotificationCenter defaultCenter] postNotificationName:k11UpdateBarNotifications object:nil];
}

- (IBAction)btnCallPressed:(UIButton *)sender {
    if (phoneNumber != nil && ![phoneNumber isEqualToString:@""]) {
        [SipUtils makeCallWithPhoneNumber: phoneNumber];
    }else{
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"The phone number can not empty"] duration:2.0 position:CSToastPositionCenter];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    newLayout = YES;
    
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
    if (!newLayout) {
        _lbHeader.text = [appDelegate.localization localizedStringForKey:@"Calls detail"];
    }else{
        if (![AppUtils isNullOrEmpty: phoneNumber]) {
            PhoneObject *contact = [ContactUtils getContactPhoneObjectWithNumber: phoneNumber];
            if (![AppUtils isNullOrEmpty:contact.name]) {
                _lbHeader.text = contact.name;
            }else{
                _lbHeader.text = [appDelegate.localization localizedStringForKey:@"Calls detail"];
            }
        }
    }
}

//  Cập nhật view sau khi get xong phone number
- (void)updateView
{
    //  check if is call with hotline
    if (!newLayout) {
        if ([phoneNumber isEqualToString: hotline]) {
            NSMutableAttributedString *contentAttr = [[NSMutableAttributedString alloc] initWithString:[appDelegate.localization localizedStringForKey:@"Hotline"]];
            [contentAttr addAttribute:NSFontAttributeName value:[UIFont fontWithName:MYRIADPRO_BOLD size:18.0] range:NSMakeRange(0, contentAttr.length)];
            [contentAttr addAttribute:NSForegroundColorAttributeName value:UIColor.orangeColor range:NSMakeRange(0, contentAttr.length)];
            _lbName.attributedText = contentAttr;
            
            _imgAvatar.image = [UIImage imageNamed:@"hotline_avatar.png"];
        }else{
            PhoneObject *contact = [ContactUtils getContactPhoneObjectWithNumber: phoneNumber];
            if (contact != nil)
            {
                _iconAddNew.hidden = YES;
                
                NSString *content = [NSString stringWithFormat:@"%@ - %@", contact.name, phoneNumber];
                
                NSRange phoneRange = NSMakeRange(content.length-phoneNumber.length, phoneNumber.length);
                
                NSMutableAttributedString *contentAttr = [[NSMutableAttributedString alloc] initWithString:content];
                [contentAttr addAttribute:NSFontAttributeName value:[UIFont fontWithName:MYRIADPRO_BOLD size:18.0] range:phoneRange];
                [contentAttr addAttribute:NSForegroundColorAttributeName value:UIColor.orangeColor range:phoneRange];
                _lbName.attributedText = contentAttr;
            }else{
                _iconAddNew.hidden = NO;
                
                _lbName.text = phoneNumber;
                
                NSRange phoneRange = NSMakeRange(0, phoneNumber.length);
                NSMutableAttributedString *contentAttr = [[NSMutableAttributedString alloc] initWithString:phoneNumber];
                [contentAttr addAttribute:NSFontAttributeName value:[UIFont fontWithName:MYRIADPRO_BOLD size:18.0] range:phoneRange];
                [contentAttr addAttribute:NSForegroundColorAttributeName value:UIColor.orangeColor range:phoneRange];
                _lbName.attributedText = contentAttr;
            }
            
            if (![AppUtils isNullOrEmpty: contact.avatar]) {
                _imgAvatar.image = [UIImage imageWithData: [NSData dataFromBase64String: contact.avatar]];
            }else{
                _imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
            }
        }
    }else{
        if ([phoneNumber isEqualToString: hotline]) {
            _lbName.text = [appDelegate.localization localizedStringForKey:@"Hotline"];
            _imgAvatar.image = [UIImage imageNamed:@"hotline_avatar.png"];
        }else{
            PhoneObject *contact = [ContactUtils getContactPhoneObjectWithNumber: phoneNumber];
            if (![AppUtils isNullOrEmpty:contact.name]) {
                _lbHeader.text = contact.name;
            }else{
                _lbHeader.text = [appDelegate.localization localizedStringForKey:@"Calls detail"];
            }
            
            if (![AppUtils isNullOrEmpty: contact.avatar]) {
                _imgAvatar.image = [UIImage imageWithData: [NSData dataFromBase64String: contact.avatar]];
            }else{
                _imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
            }
            _lbName.text = contact.number;
        }
    }
    
    // Check section
    [listHistoryCalls removeAllObjects];
    if ([AppUtils isNullOrEmpty: onDate]) {
        [listHistoryCalls addObjectsFromArray: [NSDatabase getAllListCallOfMe:USERNAME withPhoneNumber:phoneNumber]];
    }else{
        [listHistoryCalls addObjectsFromArray: [NSDatabase getAllCallOfMe:USERNAME withPhone:phoneNumber onDate:onDate]];
    }
    [_tbHistory reloadData];
}

#pragma mark - my functions

- (void)setupUIForView
{
    self.view.backgroundColor = UIColor.whiteColor;
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
        
        _lbHeader.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:20.0];
    }else{
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
        
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
        make.left.equalTo(_viewHeader);
        make.width.height.mas_equalTo(HEADER_ICON_WIDTH);
    }];
    
    _iconAddNew.hidden = YES;
    [_iconAddNew mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_iconBack);
        make.right.equalTo(_viewHeader).offset(-5);
        make.width.equalTo(_iconBack.mas_width);
        make.height.equalTo(_iconBack.mas_height);
    }];
    
    [icDelete mas_makeConstraints:^(MASConstraintMaker *make) {
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
        make.top.equalTo(_viewHeader.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    _tbHistory.delegate = self;
    _tbHistory.dataSource = self;
    _tbHistory.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView *headerView = [[UIView alloc] init];
    headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 70.0/2);
    headerView.backgroundColor = UIColor.clearColor;
    _tbHistory.tableHeaderView = headerView;
    
    listHistoryCalls = [[NSMutableArray alloc] init];
}

#pragma mark - tableview delegate

- (NSString *)convertIntToTime : (int) time{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *startData = [NSDate dateWithTimeIntervalSince1970:time];
    dateFormatter.dateFormat = @"HH:mm";
    NSString *str_time = [dateFormatter stringFromDate:startData];
    return str_time;
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
        return [appDelegate.localization localizedStringForKey:@"Yesterday"];
    }
    
    if ([strTime isEqualToString:[dateFormatter stringFromDate:today]]) {
        return [appDelegate.localization localizedStringForKey:@"Today"];
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
    if (!newLayout) {
        return 35.0;
    }
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!newLayout) {
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
                    dateStr = [appDelegate.localization localizedStringForKey:@"Yesterday"];
                }
            }else{
                dateStr = [appDelegate.localization localizedStringForKey:@"Today"];
            }
            cell.viewContent.hidden = YES;
            cell.lbTitle.hidden = NO;
            cell.lbTitle.text = dateStr;
        }else{
            cell.viewContent.hidden = NO;
            cell.lbTitle.hidden = YES;
            //  cell.lbTime.text = [AppUtils getTimeStringFromTimeInterval: aCall._timeInt];
            cell.lbTime.text = aCall._time;
            
            if ([aCall._status isEqualToString: success_call])
            {
                if (aCall._duration < 60) {
                    cell.lbDuration.text = [NSString stringWithFormat:@"%d %@", aCall._duration, [appDelegate.localization localizedStringForKey:@"sec"]];
                }else{
                    int hour = aCall._duration/3600;
                    int minutes = (aCall._duration - hour*3600)/60;
                    int seconds = aCall._duration - hour*3600 - minutes*60;
                    
                    NSString *str = @"";
                    if (hour > 0) {
                        if (hour == 1) {
                            str = [NSString stringWithFormat:@"%ld %@", (long)hour, [appDelegate.localization localizedStringForKey:@"hour"]];
                        }else{
                            str = [NSString stringWithFormat:@"%ld %@", (long)hour, [appDelegate.localization localizedStringForKey:@"hours"]];
                        }
                    }
                    
                    if (minutes > 0) {
                        if (![str isEqualToString:@""]) {
                            if (minutes == 1) {
                                str = [NSString stringWithFormat:@"%@ %d %@", str, minutes, [appDelegate.localization localizedStringForKey:@"minute"]];
                            }else{
                                str = [NSString stringWithFormat:@"%@ %d %@", str, minutes, [appDelegate.localization localizedStringForKey:@"minutes"]];
                            }
                        }else{
                            if (minutes == 1) {
                                str = [NSString stringWithFormat:@"%d %@", minutes, [appDelegate.localization localizedStringForKey:@"minute"]];
                            }else{
                                str = [NSString stringWithFormat:@"%d %@", minutes, [appDelegate.localization localizedStringForKey:@"minutes"]];
                            }
                        }
                    }
                    
                    if (seconds > 0) {
                        if (![str isEqualToString:@""]) {
                            str = [NSString stringWithFormat:@"%@ %d %@", str, seconds, [appDelegate.localization localizedStringForKey:@"sec"]];
                        }else{
                            str = [NSString stringWithFormat:@"%d %@", seconds, [appDelegate.localization localizedStringForKey:@"sec"]];
                        }
                    }
                    cell.lbDuration.text = str;
                }
                
                if ([aCall._callDirection isEqualToString:@"Incomming"]) {
                    cell.imgStatus.image = [UIImage imageNamed:@"ic_call_incoming.png"];
                    cell.lbStateCall.text = [appDelegate.localization localizedStringForKey:@"Incoming call"];
                }else{
                    cell.imgStatus.image = [UIImage imageNamed:@"ic_call_outgoing.png"];
                    cell.lbStateCall.text = [appDelegate.localization localizedStringForKey:@"Outgoing call"];
                }
            }else{
                if ([aCall._status isEqualToString: aborted_call] || [aCall._status isEqualToString: declined_call]) {
                    cell.lbStateCall.text = [appDelegate.localization localizedStringForKey:@"Aborted call"];
                    cell.lbDuration.text = @"";
                }else{
                    cell.lbStateCall.text = [appDelegate.localization localizedStringForKey:@"Missed call"];
                }
                cell.imgStatus.image = [UIImage imageNamed:@"ic_call_missed.png"];
                cell.lbDuration.text = [NSString stringWithFormat:@"%d %@", aCall._duration, [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"sec"]];
            }
        }
        return cell;
    }else{
        static NSString *identifier = @"NewHistoryDetailCell";
        NewHistoryDetailCell *cell = (NewHistoryDetailCell *)[tableView dequeueReusableCellWithIdentifier: identifier];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"NewHistoryDetailCell" owner:self options:nil];
            cell = topLevelObjects[0];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CallHistoryObject *aCall = [listHistoryCalls objectAtIndex: indexPath.row];
        
        //  cell.lbTime.text = [AppUtils getTimeStringFromTimeInterval: aCall._timeInt];
        cell.lbTime.text = aCall._time;
        
        if (aCall._duration == 0) {
            cell.lbDuration.text = @"";
        }else{
            if (aCall._duration < 60) {
                cell.lbDuration.text = [NSString stringWithFormat:@"%d %@", aCall._duration, [appDelegate.localization localizedStringForKey:@"sec"]];
            }else{
                int hour = aCall._duration/3600;
                int minutes = (aCall._duration - hour*3600)/60;
                int seconds = aCall._duration - hour*3600 - minutes*60;
                
                NSString *str = @"";
                if (hour > 0) {
                    if (hour == 1) {
                        str = [NSString stringWithFormat:@"%ld %@", (long)hour, [appDelegate.localization localizedStringForKey:@"hour"]];
                    }else{
                        str = [NSString stringWithFormat:@"%ld %@", (long)hour, [appDelegate.localization localizedStringForKey:@"hours"]];
                    }
                }
                
                if (minutes > 0) {
                    if (![str isEqualToString:@""]) {
                        if (minutes == 1) {
                            str = [NSString stringWithFormat:@"%@ %d %@", str, minutes, [appDelegate.localization localizedStringForKey:@"minute"]];
                        }else{
                            str = [NSString stringWithFormat:@"%@ %d %@", str, minutes, [appDelegate.localization localizedStringForKey:@"minutes"]];
                        }
                    }else{
                        if (minutes == 1) {
                            str = [NSString stringWithFormat:@"%d %@", minutes, [appDelegate.localization localizedStringForKey:@"minute"]];
                        }else{
                            str = [NSString stringWithFormat:@"%d %@", minutes, [appDelegate.localization localizedStringForKey:@"minutes"]];
                        }
                    }
                }
                
                if (seconds > 0) {
                    if (![str isEqualToString:@""]) {
                        str = [NSString stringWithFormat:@"%@ %d %@", str, seconds, [appDelegate.localization localizedStringForKey:@"sec"]];
                    }else{
                        str = [NSString stringWithFormat:@"%d %@", seconds, [appDelegate.localization localizedStringForKey:@"sec"]];
                    }
                }
                cell.lbDuration.text = str;
            }
        }
        
        if ([aCall._status isEqualToString: aborted_call] || [aCall._status isEqualToString: declined_call]) {
            cell.lbState.text = [appDelegate.localization localizedStringForKey:@"Aborted call"];
        }else if ([aCall._status isEqualToString: missed_call]){
            cell.lbState.text = [appDelegate.localization localizedStringForKey:@"Missed call"];
        }else{
            cell.lbState.text = @"";
        }
        
        if ([aCall._callDirection isEqualToString: incomming_call]) {
            if ([aCall._status isEqualToString: missed_call]) {
                cell.imgStatus.image = [UIImage imageNamed:@"ic_call_missed.png"];
            }else{
                cell.imgStatus.image = [UIImage imageNamed:@"ic_call_incoming.png"];
            }
        }else{
            cell.imgStatus.image = [UIImage imageNamed:@"ic_call_outgoing.png"];
        }
        
        return cell;
    }
}

- (IBAction)_iconBackClicked:(UIButton *)sender {
    appDelegate._newContact = nil;
    [[PhoneMainView instance] popCurrentView];
}

- (IBAction)_iconAddNewClicked:(UIButton *)sender {
    UIActionSheet *popupAddContact = [[UIActionSheet alloc] initWithTitle:phoneNumber delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:@"Cancel"] destructiveButtonTitle:nil otherButtonTitles:
                                      [appDelegate.localization localizedStringForKey:@"Create new contact"],
                                      [appDelegate.localization localizedStringForKey:@"Add to existing contact"],
                                      nil];
    popupAddContact.tag = 100;
    [popupAddContact showInView:self.view];
}

- (IBAction)icDeleteClick:(UIButton *)sender {
    [NSDatabase deleteCallHistoryOfRemote:phoneNumber onDate:onDate ofAccount:USERNAME];
    
    appDelegate._newContact = nil;
    [[PhoneMainView instance] popCurrentView];
}

#pragma mark - Actionsheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 100) {
        switch (buttonIndex) {
            case 0:{
                NewContactViewController *controller = VIEW(NewContactViewController);
                if (controller) {
                    if ([phoneNumber hasPrefix:@"778899"]) {
                        controller.currentPhoneNumber = @"";
                        controller.currentName = @"";
                    }else{
                        controller.currentPhoneNumber = phoneNumber;
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
                    controller.phoneNumber = phoneNumber;
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

- (NSString *)getEventTimeFromDuration:(NSTimeInterval)duration
{
    NSDateComponentsFormatter *cFormatter = [[NSDateComponentsFormatter alloc] init];
    cFormatter.unitsStyle = NSDateComponentsFormatterUnitsStyleShort;
    cFormatter.includesApproximationPhrase = NO;
    cFormatter.includesTimeRemainingPhrase = NO;
    cFormatter.allowedUnits = NSCalendarUnitHour |NSCalendarUnitMinute | NSCalendarUnitSecond;
    cFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorDropAll;
    
    return [cFormatter stringFromTimeInterval:duration];
}

@end

