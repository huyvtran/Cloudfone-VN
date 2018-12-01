//
//  AllCallsViewController.m
//  linphone
//
//  Created by Ei Captain on 7/5/16.
//
//

#import "AllCallsViewController.h"
#import "DetailHistoryCNViewController.h"
#import "KHistoryCallObject.h"
#import "HistoryCallCell.h"
#import "NSData+Base64.h"
#import "UIView+Toast.h"

@interface AllCallsViewController ()
{
    NSMutableArray *listCalls;
    
    float hCell;
    float hSection;
    
    NSMutableArray *listDelete;
    BOOL isDeleted;
}

@end

@implementation AllCallsViewController
@synthesize _lbNoCalls, _tbListCalls;

- (void)viewDidLoad {
    [super viewDidLoad];
    // MY CODE HERE
    if (SCREEN_WIDTH > 320) {
        hCell = 70.0;
        hSection = 35.0;
        _lbNoCalls.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:20.0];
    }else{
        hCell = 60.0;
        hSection = 35.0;
        _lbNoCalls.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:17.0];
    }
    
    _lbNoCalls.textColor = UIColor.grayColor;
    _lbNoCalls.textAlignment = NSTextAlignmentCenter;
    [_lbNoCalls mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
    
    //  tableview
    _tbListCalls.delegate = self;
    _tbListCalls.dataSource = self;
    _tbListCalls.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tbListCalls mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [WriteLogsUtils writeForGoToScreen:@"AllCallsViewController"];
    
    [self showContentWithCurrentLanguage];
    [self getHistoryCallForUser];
    
    _tbListCalls.hidden = YES;
    isDeleted = false;
    
    //  Sự kiện click trên icon Edit
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginEditHistoryView)
                                                 name:editHistoryCallView object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteHistoryCallsPressed:)
                                                 name:deleteHistoryCallsChoosed object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getHistoryCallForUser)
                                                 name:reloadHistoryCall object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - My functions

- (void)getHistoryCallForUser
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__]
                         toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if (listCalls == nil) {
            listCalls = [[NSMutableArray alloc] init];
        }
        [listCalls removeAllObjects];
        
        NSArray *tmpArr = [NSDatabase getHistoryCallListOfUser:USERNAME isMissed: false];
        [listCalls addObjectsFromArray: tmpArr];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (listCalls.count == 0) {
                _tbListCalls.hidden = YES;
                _lbNoCalls.hidden = NO;
            }else {
                _tbListCalls.hidden = NO;
                _lbNoCalls.hidden = YES;
                [_tbListCalls reloadData];
            }
        });
    });
}

- (void)showContentWithCurrentLanguage {
    _lbNoCalls.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"No call in your history"];
}

//  Click trên button Edit
- (void)beginEditHistoryView {
    isDeleted = true;
    [_tbListCalls reloadData];
}

//  Get lại danh sách các cuộc gọi sau khi xoá
- (void)reGetListCallsForHistory {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__]
                         toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    [listCalls removeAllObjects];
    [listCalls addObjectsFromArray:[NSDatabase getHistoryCallListOfUser:USERNAME isMissed:false]];
}

#pragma mark - UITableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return listCalls.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[[listCalls objectAtIndex:section] valueForKey:@"rows"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"HistoryCallCell";
    HistoryCallCell *cell = (HistoryCallCell *)[tableView dequeueReusableCellWithIdentifier: identifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HistoryCallCell" owner:self options:nil];
        cell = topLevelObjects[0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    KHistoryCallObject *aCall = [[[listCalls objectAtIndex:indexPath.section] valueForKey:@"rows"] objectAtIndex: indexPath.row];
    
    // Set name for cell
    cell._lbPhone.text = aCall._phoneNumber;
    cell._phoneNumber = aCall._phoneNumber;
    
    if ([aCall._phoneNumber isEqualToString: hotline]) {
        cell._lbName.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Hotline"];
        cell._imgAvatar.image = [UIImage imageNamed:@"hotline_avatar.png"];
        
        [cell updateFrameForHotline: YES];
        cell._lbPhone.hidden = YES;
        cell.lbMissed.hidden = YES;
    }else{
        [cell updateFrameForHotline: NO];
        cell._lbPhone.hidden = NO;
        
        if ([AppUtils isNullOrEmpty: aCall._phoneName]) {
            cell._lbName.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Unknown"];
        }else{
            cell._lbName.text = aCall._phoneName;
        }
        
        if ([AppUtils isNullOrEmpty: aCall._phoneAvatar])
        {
            if (aCall._phoneNumber.length < 10) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    NSString *pbxServer = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_SERVER];
                    NSString *avatarName = [NSString stringWithFormat:@"%@_%@.png", pbxServer, aCall._phoneNumber];
                    NSString *localFile = [NSString stringWithFormat:@"/avatars/%@", avatarName];
                    NSData *avatarData = [AppUtils getFileDataFromDirectoryWithFileName:localFile];
                    
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        if (avatarData != nil) {
                            cell._imgAvatar.image = [UIImage imageWithData: avatarData];
                        }else{
                            cell._imgAvatar.image = [UIImage imageNamed:@"no_avatar_blue.png"];
                        }
                    });
                });
            }else{
                cell._imgAvatar.image = [UIImage imageNamed:@"no_avatar_blue.png"];
            }
        }else{
            NSData *imgData = [[NSData alloc] initWithData:[NSData dataFromBase64String: aCall._phoneAvatar]];
            cell._imgAvatar.image = [UIImage imageWithData: imgData];
        }
        
        //  Show missed notification
        if (aCall.newMissedCall > 0) {
            cell.lbMissed.hidden = NO;
        }else{
            cell.lbMissed.hidden = YES;
        }
    }
    
    NSString *strTime = [AppUtils getTimeStringFromTimeInterval: aCall.timeInt];
    cell.lbTime.text = strTime;
    cell.lbTime.text = aCall._callTime;
    
    cell.lbDuration.text = [AppUtils convertDurtationToString: aCall.duration];
    
    if (isDeleted) {
        cell._cbDelete.hidden = NO;
        cell._btnCall.hidden = YES;
    }else{
        cell._cbDelete.hidden = YES;
        cell._btnCall.hidden = NO;
    }
    
    if ([aCall._callDirection isEqualToString: incomming_call]) {
        if ([aCall._status isEqualToString: missed_call]) {
            cell._imgStatus.image = [UIImage imageNamed:@"ic_call_missed.png"];
        }else{
            cell._imgStatus.image = [UIImage imageNamed:@"ic_call_incoming.png"];
        }
    }else{
        cell._imgStatus.image = [UIImage imageNamed:@"ic_call_outgoing.png"];
    }
    
    cell._cbDelete._indexPath = indexPath;
    cell._cbDelete._idHisCall = aCall._callId;
    cell._cbDelete.delegate = self;
    
    [cell._btnCall setTitle:aCall._phoneNumber forState:UIControlStateNormal];
    [cell._btnCall setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [cell._btnCall addTarget:self
                      action:@selector(btnCallOnCellPressed:)
            forControlEvents:UIControlEventTouchUpInside];
    
    //  get missed call
    if (aCall.newMissedCall > 0) {
        NSString *strMissed = [NSString stringWithFormat:@"%d", aCall.newMissedCall];
        if (aCall.newMissedCall > 5) {
            strMissed = @"+5";
        }
        cell.lbMissed.hidden = NO;
        cell.lbMissed.text = strMissed;
    }else{
        cell.lbMissed.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isDeleted) {
        if (listDelete == nil) {
            listDelete = [[NSMutableArray alloc] init];
        }
        
        HistoryCallCell *curCell = [tableView cellForRowAtIndexPath: indexPath];
        if ([listDelete containsObject: [NSNumber numberWithInt:curCell._cbDelete._idHisCall]]) {
            [listDelete removeObject: [NSNumber numberWithInt:curCell._cbDelete._idHisCall]];
            [curCell._cbDelete setOn:false animated:true];
        }else{
            [listDelete addObject: [NSNumber numberWithInt:curCell._cbDelete._idHisCall]];
            [curCell._cbDelete setOn:true animated:true];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:updateNumberHistoryCallRemove
                                                            object:[NSNumber numberWithInt:(int)listDelete.count]];
    }else{
        KHistoryCallObject *aCall = [[[listCalls objectAtIndex:indexPath.section] valueForKey:@"rows"] objectAtIndex: indexPath.row];
        DetailHistoryCNViewController *controller = VIEW(DetailHistoryCNViewController);
        if (controller != nil) {
            [controller setPhoneNumberForView:aCall._phoneNumber andDate:aCall._callDate];
        }
        [[PhoneMainView instance] changeCurrentView:[DetailHistoryCNViewController compositeViewDescription] push:true];
    }
}

- (void)didTapCheckBox:(BEMCheckBox *)checkBox {
    NSIndexPath *indexPath = [checkBox _indexPath];
    if (listDelete == nil) {
        listDelete = [[NSMutableArray alloc] init];
    }
    
    HistoryCallCell *curCell = [_tbListCalls cellForRowAtIndexPath: indexPath];
    if ([listDelete containsObject:[NSNumber numberWithInt:curCell._cbDelete._idHisCall]]) {
        [listDelete removeObject: [NSNumber numberWithInt:curCell._cbDelete._idHisCall]];
        [curCell._cbDelete setOn:false animated:true];
    }else{
        [listDelete addObject: [NSNumber numberWithInt:curCell._cbDelete._idHisCall]];
        [curCell._cbDelete setOn:true animated:true];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:updateNumberHistoryCallRemove
                                                        object:[NSNumber numberWithInt:(int)listDelete.count]];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *titleHeader = @"";
    NSString *currentDate = [[listCalls objectAtIndex: section] valueForKey:@"title"];
    NSString *today = [AppUtils checkTodayForHistoryCall: currentDate];
    if ([today isEqualToString: @"Today"]) {
        titleHeader =  [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"TODAY"];
    }else{
        NSString *yesterday = [AppUtils checkYesterdayForHistoryCall:currentDate];
        if ([yesterday isEqualToString:@"Yesterday"]) {
            titleHeader =  [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"YESTERDAY"];
        }else{
            titleHeader = currentDate;
        }
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, hSection)];
    headerView.backgroundColor = [UIColor colorWithRed:(243/255.0) green:(244/255.0)
                                                  blue:(248/255.0) alpha:1.0];
    
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, hSection)];
    descLabel.textColor = UIColor.darkGrayColor;
    descLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightSemibold];
    descLabel.text = titleHeader;
    [headerView addSubview: descLabel];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return hSection;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return hCell;
}

- (void)btnCallOnCellPressed: (UIButton *)sender {
    if (sender.currentTitle != nil && ![sender.currentTitle isEqualToString:@""]) {
        NSString *phoneNumber = [AppUtils removeAllSpecialInString: sender.currentTitle];
        if (![phoneNumber isEqualToString:@""]) {
            [SipUtils makeCallWithPhoneNumber: phoneNumber];
        }
        return;
    }
    [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"The phone number can not empty"] duration:2.0 position:CSToastPositionCenter];
}

- (void)deleteHistoryCallsPressed: (NSNotification *)notif {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__]
                         toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    NSNumber *object = [notif object];
    if ([object isKindOfClass:[NSNumber class]]) {
        if ([object intValue] == 0) {
            isDeleted = NO;
            
            if (listDelete != nil && listDelete.count > 0) {
                for (int iCount=0; iCount<listDelete.count; iCount++) {
                    int idHisCall = [[listDelete objectAtIndex: iCount] intValue];
                    NSDictionary *callInfo = [NSDatabase getCallInfoWithHistoryCallId: idHisCall];
                    if (callInfo != nil) {
                        NSString *phoneNumber = [callInfo objectForKey:@"phone_number"];
                        if (phoneNumber != nil && ![phoneNumber isEqualToString:@""]) {
                            NSString *date = [callInfo objectForKey:@"date"];
                            [NSDatabase removeHistoryCallsOfUser:phoneNumber onDate:date ofAccount:USERNAME];
                        }
                    }
                }
            }
            [self reGetListCallsForHistory];
        }else{
            isDeleted = YES;
        }
    }
    [_tbListCalls reloadData];
}

@end
