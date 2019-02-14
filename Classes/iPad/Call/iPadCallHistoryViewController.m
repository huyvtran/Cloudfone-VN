//
//  iPadCallHistoryViewController.m
//  linphone
//
//  Created by lam quang quan on 1/16/19.
//

#import "iPadCallHistoryViewController.h"
#import "iPadDetailHistoryCallCell.h"
#import "CallHistoryObject.h"

@interface iPadCallHistoryViewController () {
    float tbHeight;
    float hInfo;
    NSMutableArray *listHistoryCalls;
    float hCell;
}

@end

@implementation iPadCallHistoryViewController
@synthesize scvContent, viewInfo, imgAvatar, lbName, lbPhone, btnCall, btnSendMessage, lbSepa, tbHistory;
@synthesize phoneNumber, onDate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [WriteLogsUtils writeForGoToScreen:@"iPadCallHistoryViewController"];
    [self showContentWithCurrentLanguage];
    
    [self showInformationForView];
    
    //  reset missed call
    [NSDatabase resetMissedCallOfRemote:phoneNumber onDate:onDate ofAccount:USERNAME];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:k11UpdateBarNotifications object:nil];
    
    //  [Khai Le - 13/02/2019]  register observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadHistoryCallData)
                                                 name:reloadHistoryCallForIpad object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showContentWithCurrentLanguage {
    self.title = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Calls detail"];
    [btnCall setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Call"] forState:UIControlStateNormal];
    [btnSendMessage setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Send message"] forState:UIControlStateNormal];
}

- (void)setupUIForView
{
    self.view.backgroundColor = IPAD_BG_COLOR;

    tbHeight = SCREEN_WIDTH;
    hInfo = 150;
    hCell = 38.0;
    
    scvContent.delegate = self;
    scvContent.backgroundColor = UIColor.clearColor;
    [scvContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(self.view);
        make.width.mas_equalTo(SCREEN_WIDTH - SPLIT_MASTER_WIDTH);
    }];
    
    //  view info
    [viewInfo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(scvContent);
        make.width.mas_equalTo(SCREEN_WIDTH - SPLIT_MASTER_WIDTH);
        make.height.mas_equalTo(hInfo);
    }];
    
    lbSepa.backgroundColor = IPAD_BG_COLOR;
    [lbSepa mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(viewInfo);
        make.height.mas_equalTo(1.0);
    }];
    
    float padding = 20.0;
    float hAvatar = hInfo - 2*padding;
    
    [ContactUtils addBorderForImageView:imgAvatar withRectSize:hAvatar strokeWidth:0 strokeColor:nil radius:4.0];
    [imgAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(viewInfo).offset(padding);
        make.bottom.equalTo(viewInfo).offset(-padding);
        make.width.mas_equalTo(hAvatar);
    }];
    
    lbName.font = [UIFont systemFontOfSize:24.0 weight:UIFontWeightRegular];
    [lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgAvatar);
        make.left.equalTo(imgAvatar.mas_right).offset(10.0);
        make.right.equalTo(viewInfo).offset(-padding);
        make.height.mas_equalTo(2*hAvatar/8);
    }];
    
    lbPhone.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightRegular];
    [lbPhone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbName.mas_bottom).offset(hAvatar/16);
        make.left.right.equalTo(lbName);
        make.height.mas_equalTo(hAvatar/8);
    }];
    
    UIFont *btnFont = [UIFont systemFontOfSize:18.0 weight:UIFontWeightRegular];
    
    CGSize textSize = [AppUtils getSizeWithText:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Call"] withFont:btnFont];
    if (textSize.width < 60) {
        textSize.width = 60.0;
    }
    
    btnCall.layer.cornerRadius = 20.0;
    btnCall.backgroundColor = IPAD_HEADER_BG_COLOR;
    [btnCall setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnCall.titleLabel.font = btnFont;
    btnCall.layer.borderWidth = 1.0;
    btnCall.layer.borderColor = IPAD_HEADER_BG_COLOR.CGColor;
    [btnCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbPhone.mas_bottom).offset(hAvatar/8);
        make.left.equalTo(lbPhone);
        make.width.mas_equalTo(textSize.width + 10.0);
        make.height.mas_equalTo(3*hAvatar/8);
    }];
    
    textSize = [AppUtils getSizeWithText:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Send message"] withFont:btnFont];
    if (textSize.width < 60) {
        textSize.width = 60.0;
    }
    
    btnSendMessage.layer.cornerRadius = btnCall.layer.cornerRadius;
    btnSendMessage.backgroundColor = GRAY_COLOR;
    [btnSendMessage setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnSendMessage.titleLabel.font = btnFont;
    [btnSendMessage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(btnCall);
        make.left.equalTo(btnCall.mas_right).offset(10.0);
        make.width.mas_equalTo(textSize.width + 40.0);
    }];
    
    tbHistory.delegate = self;
    tbHistory.dataSource = self;
    tbHistory.backgroundColor = UIColor.clearColor;
    tbHistory.separatorStyle = UITableViewCellSeparatorStyleNone;
    tbHistory.scrollEnabled = NO;
    [tbHistory mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewInfo.mas_bottom);
        make.left.equalTo(scvContent);
        make.height.mas_equalTo(SCREEN_HEIGHT - (STATUS_BAR_HEIGHT + HEIGHT_IPAD_NAV + hInfo));
        make.width.mas_equalTo(SCREEN_WIDTH - SPLIT_MASTER_WIDTH);
    }];
}

#pragma mark - Scrollview Delegate
/*
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y <= 0) {
        [imgAvatar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
        }];
    }else{
        if (scrollView.contentOffset.y < tbHeight/2) {
            [imgAvatar mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view).offset(-scrollView.contentOffset.y);
            }];
        }else{
            
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
}
*/
- (void)showInformationForView
{
    //  check if is call with hotline
    if ([phoneNumber isEqualToString: hotline]) {
        lbName.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Hotline"];
        imgAvatar.image = [UIImage imageNamed:@"hotline_avatar.png"];
    }else{
        PhoneObject *contact = [ContactUtils getContactPhoneObjectWithNumber: phoneNumber];
        lbName.text = ![AppUtils isNullOrEmpty:contact.name] ? contact.name : [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Unknown"];
        lbPhone.text = phoneNumber;
        
        if (contact == nil) {
            if (phoneNumber.length < 10) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    NSString *pbxServer = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_SERVER];
                    NSString *avatarName = [NSString stringWithFormat:@"%@_%@.png", pbxServer, phoneNumber];
                    NSString *localFile = [NSString stringWithFormat:@"/avatars/%@", avatarName];
                    NSData *avatarData = [AppUtils getFileDataFromDirectoryWithFileName:localFile];
                    
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        if (avatarData != nil) {
                            imgAvatar.image = [UIImage imageWithData: avatarData];
                        }else{
                            imgAvatar.image = [UIImage imageNamed:@"avatar"];
                        }
                    });
                });
            }
        }else{
            if (![AppUtils isNullOrEmpty: contact.avatar]) {
                imgAvatar.image = [UIImage imageWithData: [NSData dataFromBase64String: contact.avatar]];
            }else{
                imgAvatar.image = [UIImage imageNamed:@"avatar"];
            }
        }
    }
    
    // Check section
    if (listHistoryCalls == nil) {
        listHistoryCalls = [[NSMutableArray alloc] init];
    }
    [listHistoryCalls removeAllObjects];
    if ([AppUtils isNullOrEmpty: onDate]) {
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Get all list call with phone number %@", __FUNCTION__, phoneNumber] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];

        [listHistoryCalls addObjectsFromArray: [NSDatabase getAllListCallOfMe:USERNAME withPhoneNumber:phoneNumber]];
    }else{
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Get all list call with phone number %@, on date %@", __FUNCTION__, phoneNumber, onDate] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];

        [listHistoryCalls addObjectsFromArray: [NSDatabase getAllCallOfMe:USERNAME withPhone:phoneNumber onDate:onDate]];
    }
    [tbHistory reloadData];
    
    float totalHeight = hInfo + hCell * listHistoryCalls.count;
    scvContent.contentSize = CGSizeMake(SCREEN_WIDTH - SPLIT_MASTER_WIDTH, totalHeight);
    tbHistory.frame = CGRectMake(tbHistory.frame.origin.x, tbHistory.frame.origin.y, tbHistory.frame.size.width, hCell * listHistoryCalls.count);
}


- (IBAction)btnCallPressed:(UIButton *)sender
{
    if ([phoneNumber isEqualToString: hotline]) {
        NSLog(@"Call to Hotline");
    }else{
        NSString *phone = [AppUtils removeAllSpecialInString: phoneNumber];
        if ([AppUtils isNullOrEmpty: phone]) {
            [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"The phone number can not empty"] duration:2.0 position:CSToastPositionCenter];
            return;
        }else{
            [SipUtils makeCallWithPhoneNumber: phone];
        }
    }
}

- (IBAction)btnSendMessagePressed:(UIButton *)sender {
    [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"We have not supported this feature yet. Please try later!"] duration:2.0 position:CSToastPositionCenter];
}

//  [Khai Le - 13/02/2019]
- (void)reloadHistoryCallData
{
    if (listHistoryCalls == nil) {
        listHistoryCalls = [[NSMutableArray alloc] init];
    }
    [listHistoryCalls removeAllObjects];
    
    if ([AppUtils isNullOrEmpty: onDate]) {
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Get all list call with phone number %@", __FUNCTION__, phoneNumber] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        
        [listHistoryCalls addObjectsFromArray: [NSDatabase getAllListCallOfMe:USERNAME withPhoneNumber:phoneNumber]];
    }else{
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Get all list call with phone number %@, on date %@", __FUNCTION__, phoneNumber, onDate] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        
        [listHistoryCalls addObjectsFromArray: [NSDatabase getAllCallOfMe:USERNAME withPhone:phoneNumber onDate:onDate]];
    }
    [tbHistory reloadData];
    
    float totalHeight = hInfo + hCell * listHistoryCalls.count;
    scvContent.contentSize = CGSizeMake(SCREEN_WIDTH - SPLIT_MASTER_WIDTH, totalHeight);
    tbHistory.frame = CGRectMake(tbHistory.frame.origin.x, tbHistory.frame.origin.y, tbHistory.frame.size.width, hCell * listHistoryCalls.count);
}
    

#pragma mark - UITableviewCell delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return listHistoryCalls.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
     return hCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"iPadDetailHistoryCallCell";
    iPadDetailHistoryCallCell *cell = (iPadDetailHistoryCallCell *)[tableView dequeueReusableCellWithIdentifier: identifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"iPadDetailHistoryCallCell" owner:self options:nil];
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
            cell.lbDuration.text = [NSString stringWithFormat:@"%d %@", aCall._duration, [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"sec"]];
        }else{
            int hour = aCall._duration/3600;
            int minutes = (aCall._duration - hour*3600)/60;
            int seconds = aCall._duration - hour*3600 - minutes*60;
            
            NSString *str = @"";
            if (hour > 0) {
                if (hour == 1) {
                    str = [NSString stringWithFormat:@"%ld %@", (long)hour, [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"hour"]];
                }else{
                    str = [NSString stringWithFormat:@"%ld %@", (long)hour, [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"hours"]];
                }
            }
            
            if (minutes > 0) {
                if (![str isEqualToString:@""]) {
                    if (minutes == 1) {
                        str = [NSString stringWithFormat:@"%@ %d %@", str, minutes, [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"minute"]];
                    }else{
                        str = [NSString stringWithFormat:@"%@ %d %@", str, minutes, [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"minutes"]];
                    }
                }else{
                    if (minutes == 1) {
                        str = [NSString stringWithFormat:@"%d %@", minutes, [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"minute"]];
                    }else{
                        str = [NSString stringWithFormat:@"%d %@", minutes, [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"minutes"]];
                    }
                }
            }
            
            if (seconds > 0) {
                if (![str isEqualToString:@""]) {
                    str = [NSString stringWithFormat:@"%@ %d %@", str, seconds, [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"sec"]];
                }else{
                    str = [NSString stringWithFormat:@"%d %@", seconds, [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"sec"]];
                }
            }
            cell.lbDuration.text = str;
        }
    }
    
    if ([aCall._status isEqualToString: aborted_call] || [aCall._status isEqualToString: declined_call]) {
        cell.lbCallType.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Aborted call"];
    }else if ([aCall._status isEqualToString: missed_call]){
        cell.lbCallType.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Missed call"];
    }else{
        cell.lbCallType.text = @"";
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
    
    NSString *dateStr = [AppUtils checkTodayForHistoryCall: onDate];
    
    if (![dateStr isEqualToString:@"Today"]) {
        dateStr = [AppUtils checkYesterdayForHistoryCall: aCall._date];
        if ([dateStr isEqualToString:@"Yesterday"]) {
            dateStr = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Yesterday"];
        }
    }else{
        dateStr = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Today"];
    }
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
}

@end
