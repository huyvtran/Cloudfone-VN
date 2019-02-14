//
//  iPadDialerViewController.m
//  linphone
//
//  Created by lam quang quan on 1/11/19.
//

#import "iPadDialerViewController.h"
#import "iPadKeypadViewController.h"
#import "iPadCallHistoryViewController.h"
#import "iPadHistoryCallCell.h"
#import "KHistoryCallObject.h"

@interface iPadDialerViewController (){
    NSMutableArray *listCalls;
    BOOL isDeleted;
    float hSection;
    NSMutableArray *listDelete;
}

@end

@implementation iPadDialerViewController
@synthesize viewHeader, btnAll, btnMissed, iconDelete;
@synthesize tbCalls, lbNoCalls, imgNoCalls, btnKeypad;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [WriteLogsUtils writeForGoToScreen:@"iPadDialerViewController"];
    
    //  [Khai Le - 13/02/2019]  register observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getHistoryCallForUser)
                                                 name:reloadHistoryCallForIpad object:nil];
    
    if (listDelete == nil) {
        listDelete = [[NSMutableArray alloc] init];
    }
    [listDelete removeAllObjects];
    
    [self showContentWithCurrentLanguage];
    [self getHistoryCallForUser];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    [AppUtils addCornerRadiusTopLeftAndBottomLeftForButton:btnAll radius:HEIGHT_IPAD_HEADER_BUTTON/2 withColor:SELECT_TAB_BG_COLOR border:2.0];
    [AppUtils addCornerRadiusTopRightAndBottomRightForButton:btnMissed radius:HEIGHT_IPAD_HEADER_BUTTON/2 withColor:SELECT_TAB_BG_COLOR border:2.0];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnAllPress:(UIButton *)sender {
    if ([LinphoneAppDelegate sharedInstance].historyType == eAllCalls) {
        return;
    }
    
    isDeleted = NO;
    [listDelete removeAllObjects];
    
    [LinphoneAppDelegate sharedInstance].historyType = eAllCalls;
    [self updateStateIconWithView];
    [self getHistoryCallForUser];
    
    //  [Khai Le - 14/02/2019]: If showing detail of history call, after delete all, will not see detail again, so should show keypad
    [self btnKeypadPress: nil];
}

- (IBAction)btnMissedPress:(UIButton *)sender {
    if ([LinphoneAppDelegate sharedInstance].historyType == eMissedCalls) {
        return;
    }
    
    isDeleted = NO;
    [listDelete removeAllObjects];
    
    [LinphoneAppDelegate sharedInstance].historyType = eMissedCalls;
    [self updateStateIconWithView];
    [self getHistoryCallForUser];
    
    //  [Khai Le - 14/02/2019]: If showing detail of history call, after delete all, will not see detail again, so should show keypad
    [self btnKeypadPress: nil];
}

- (IBAction)btnKeypadPress:(UIButton *)sender {
    //  deselect all rows was selected
    NSArray *selectedRows = [tbCalls indexPathsForSelectedRows];
    for (int i=0; i<selectedRows.count; i++) {
        NSIndexPath *indexPath = [selectedRows objectAtIndex: i];
        [tbCalls deselectRowAtIndexPath: indexPath animated:NO];
    }
    //  -----
    
    iPadKeypadViewController *keypadVC = [[iPadKeypadViewController alloc] initWithNibName:@"iPadKeypadViewController" bundle:nil];
    [AppUtils showDetailViewWithController: keypadVC];
}

- (IBAction)iconDeleteClick:(UIButton *)sender {
    if (sender.tag == 0) {
        [listDelete removeAllObjects];
        
        isDeleted = YES;
        sender.tag = 1;
        [sender setImage:[UIImage imageNamed:@"ic_tick_ipad"] forState:UIControlStateNormal];
    }else{
        isDeleted = NO;
        sender.tag = 0;
        [sender setImage:[UIImage imageNamed:@"ic_trash_ipad"] forState:UIControlStateNormal];
        
        
        [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__]
                             toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
        
        if (listDelete != nil && listDelete.count > 0) {
            for (int iCount=0; iCount<listDelete.count; iCount++) {
                int idHisCall = [[listDelete objectAtIndex: iCount] intValue];
                NSDictionary *callInfo = [NSDatabase getCallInfoWithHistoryCallId: idHisCall];
                if (callInfo != nil) {
                    NSString *phoneNumber = [callInfo objectForKey:@"phone_number"];
                    if (![AppUtils isNullOrEmpty: phoneNumber]) {
                        NSString *date = [callInfo objectForKey:@"date"];
                        
                        BOOL onlyMissed = ([LinphoneAppDelegate sharedInstance].historyType == eMissedCalls) ? YES : NO;
                        [NSDatabase removeHistoryCallsOfUser:phoneNumber onDate:date ofAccount:USERNAME onlyMissed: onlyMissed];
                    }
                }
            }
        }
        
        [listDelete removeAllObjects];
        [self reGetListCallsForHistory];
        
        //  [Khai Le - 14/02/2019]: If showing detail of history call, after delete all, will not see detail again, so should show keypad
        [self btnKeypadPress: nil];
    }
    [tbCalls reloadData];
}

- (void)reGetListCallsForHistory {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__]
                         toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    BOOL isMissedCall = ([LinphoneAppDelegate sharedInstance].historyType == eMissedCalls) ? YES : NO;
    
    NSArray *tmpArr = [NSDatabase getHistoryCallListOfUser:USERNAME isMissed: isMissedCall];
    [listCalls removeAllObjects];
    [listCalls addObjectsFromArray: tmpArr];
}

- (void)showContentWithCurrentLanguage {
    lbNoCalls.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"No call in your history"];
    [btnAll setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"All"] forState:UIControlStateNormal];
    [btnMissed setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Missed"] forState:UIControlStateNormal];
}

//  Cập nhật trạng thái của các icon trên header
- (void)updateStateIconWithView
{
    if ([LinphoneAppDelegate sharedInstance].historyType == eAllCalls){
        [AppUtils setSelected:YES forButton:btnAll];
        [AppUtils setSelected:NO forButton:btnMissed];
    }else{
        [AppUtils setSelected:NO forButton:btnAll];
        [AppUtils setSelected:YES forButton:btnMissed];
    }
}

- (void)setupUIForView {
    self.view.backgroundColor = IPAD_BG_COLOR;
    hSection = 40.0;
    
    //  header view
    float hNav = [LinphoneAppDelegate sharedInstance].hNavigation;
    float hHeader = STATUS_BAR_HEIGHT + hNav;
    viewHeader.backgroundColor = IPAD_HEADER_BG_COLOR;
    [viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(hHeader);
    }];
    
    float top = STATUS_BAR_HEIGHT + (hNav - HEIGHT_HEADER_BTN)/2;
    btnAll.backgroundColor = SELECT_TAB_BG_COLOR;
    [btnAll setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [btnAll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader).offset(top);
        make.right.equalTo(viewHeader.mas_centerX);
        make.height.mas_equalTo(HEIGHT_HEADER_BTN);
        make.width.mas_equalTo(100);
    }];
    
    btnMissed.backgroundColor = UIColor.clearColor;
    [btnMissed setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [btnMissed mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewHeader.mas_centerX);
        make.top.bottom.equalTo(btnAll);
        make.width.equalTo(btnAll.mas_width);
        make.height.equalTo(btnAll.mas_height);
    }];
    
    iconDelete.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [iconDelete mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(viewHeader);
        make.centerY.equalTo(btnMissed.mas_centerY);
        make.width.height.mas_equalTo(HEIGHT_HEADER_BTN);
    }];
    
    //  btnKeypad
    float rightPadding = 15.0;
    btnKeypad.backgroundColor = UIColor.whiteColor;
    btnKeypad.layer.cornerRadius = 60.0/2;
    btnKeypad.layer.borderColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0)
                                                   blue:(220/255.0) alpha:1.0].CGColor;
    btnKeypad.layer.borderWidth = 1.0;
    btnKeypad.imageEdgeInsets = UIEdgeInsetsMake(14, 14, 14, 14);
    [btnKeypad mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-rightPadding);
        make.bottom.equalTo(self.view).offset(-self.tabBarController.tabBar.frame.size.height - rightPadding);
        make.width.height.mas_equalTo(60.0);
    }];
    
    //  table calls
    tbCalls.separatorStyle = UITableViewCellSelectionStyleNone;
    tbCalls.backgroundColor = UIColor.clearColor;
    tbCalls.delegate = self;
    tbCalls.dataSource = self;
    [tbCalls mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-self.tabBarController.tabBar.frame.size.height);
    }];
    
    //  no calls yet
    [imgNoCalls mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(tbCalls.mas_centerX);
        make.centerY.equalTo(tbCalls.mas_centerY).offset(-70.0);
        make.width.height.mas_equalTo(100.0);
    }];
    
    lbNoCalls.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"No call in your history"];
    lbNoCalls.textColor = GRAY_COLOR;
    lbNoCalls.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightThin];
    [lbNoCalls mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgNoCalls.mas_bottom).offset(10.0);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(50.0);
    }];
}

- (void)getHistoryCallForUser
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s]", __FUNCTION__]
                         toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if (listCalls == nil) {
            listCalls = [[NSMutableArray alloc] init];
        }
        [listCalls removeAllObjects];
        
        BOOL isMissedCall = ([LinphoneAppDelegate sharedInstance].historyType == eMissedCalls) ? YES : NO;
        
        NSArray *tmpArr = [NSDatabase getHistoryCallListOfUser:USERNAME isMissed: isMissedCall];
        [listCalls addObjectsFromArray: tmpArr];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (listCalls.count == 0) {
                [self showViewNoCalls: YES];
            }else {
                [self showViewNoCalls: NO];
                [tbCalls reloadData];
            }
        });
    });
}

- (void)showViewNoCalls: (BOOL)show {
    tbCalls.hidden = show;
    lbNoCalls.hidden = !show;
    imgNoCalls.hidden = !show;
}

#pragma mark - UITableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return listCalls.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[[listCalls objectAtIndex:section] valueForKey:@"rows"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"iPadHistoryCallCell";
    iPadHistoryCallCell *cell = (iPadHistoryCallCell *)[tableView dequeueReusableCellWithIdentifier: identifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"iPadHistoryCallCell" owner:self options:nil];
        cell = topLevelObjects[0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    KHistoryCallObject *aCall = [[[listCalls objectAtIndex:indexPath.section] valueForKey:@"rows"] objectAtIndex: indexPath.row];
    
    // Set name for cell
    cell.lbNumber.text = aCall._phoneNumber;
    //  cell._phoneNumber = aCall._phoneNumber;
    
    if ([aCall._phoneNumber isEqualToString: hotline]) {
        cell.lbName.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Hotline"];
        cell.imgAvatar.image = [UIImage imageNamed:@"hotline_avatar.png"];
        
//        [cell updateFrameForHotline: YES];
//        cell._lbPhone.hidden = YES;
//        cell.lbMissed.hidden = YES;
    }else{
        //  [cell updateFrameForHotline: NO];
        cell.lbNumber.hidden = NO;
        
        if ([AppUtils isNullOrEmpty: aCall._phoneName]) {
            cell.lbName.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Unknown"];
        }else{
            cell.lbName.text = aCall._phoneName;
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
                            cell.imgAvatar.image = [UIImage imageWithData: avatarData];
                        }else{
                            cell.imgAvatar.image = [UIImage imageNamed:@"avatar"];
                        }
                    });
                });
            }else{
                cell.imgAvatar.image = [[UIImage imageNamed:@"avatar"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
            }
        }else{
            NSData *imgData = [[NSData alloc] initWithData:[NSData dataFromBase64String: aCall._phoneAvatar]];
            cell.imgAvatar.image = [UIImage imageWithData: imgData];
        }
        
        //  Show missed notification
//        if (aCall.newMissedCall > 0) {
//            cell.lbMissed.hidden = NO;
//        }else{
//            cell.lbMissed.hidden = YES;
//        }
    }
    
    NSString *strTime = [AppUtils getTimeStringFromTimeInterval: aCall.timeInt];
    cell.lbTime.text = strTime;
    cell.lbTime.text = aCall._callTime;
    
    //  cell.lbDuration.text = [AppUtils convertDurtationToString: aCall.duration];
    
    if (isDeleted) {
        cell.cbDelete.hidden = NO;
        cell.icCall.hidden = YES;
    }else{
        cell.cbDelete.hidden = YES;
        cell.icCall.hidden = NO;
    }
    
    if ([aCall._callDirection isEqualToString: incomming_call]) {
        if ([aCall._status isEqualToString: missed_call]) {
            cell.imgDirection.image = [UIImage imageNamed:@"ic_call_missed.png"];
        }else{
            cell.imgDirection.image = [UIImage imageNamed:@"ic_call_incoming.png"];
        }
    }else{
        cell.imgDirection.image = [UIImage imageNamed:@"ic_call_outgoing.png"];
    }
    
    cell.cbDelete._indexPath = indexPath;
    cell.cbDelete._idHisCall = aCall._callId;
    cell.cbDelete.delegate = self;

    [cell.icCall setTitle:aCall._phoneNumber forState:UIControlStateNormal];
    [cell.icCall setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [cell.icCall addTarget:self
                    action:@selector(btnCallOnCellPressed:)
          forControlEvents:UIControlEventTouchUpInside];
    
    //  get missed call
//    if (aCall.newMissedCall > 0) {
//        NSString *strMissed = [NSString stringWithFormat:@"%d", aCall.newMissedCall];
//        if (aCall.newMissedCall > 5) {
//            strMissed = @"+5";
//        }
//        cell.lbMissed.hidden = NO;
//        cell.lbMissed.text = strMissed;
//    }else{
//        cell.lbMissed.hidden = YES;
//    }
    
    return cell;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isDeleted)
    {
        iPadHistoryCallCell *cell = [tableView cellForRowAtIndexPath: indexPath];
        
        if ([listDelete containsObject: [NSNumber numberWithInt: cell.cbDelete._idHisCall]]) {
            [listDelete removeObject: [NSNumber numberWithInt: cell.cbDelete._idHisCall]];
            [cell.cbDelete setOn:false animated:true];
        }else{
            [listDelete addObject: [NSNumber numberWithInt: cell.cbDelete._idHisCall]];
            [cell.cbDelete setOn:true animated:true];
        }
        return;
    }
    
    iPadCallHistoryViewController *callHistoryVC = [[iPadCallHistoryViewController alloc] initWithNibName:@"iPadCallHistoryViewController" bundle:nil];
    
    KHistoryCallObject *aCall = [[[listCalls objectAtIndex:indexPath.section] valueForKey:@"rows"] objectAtIndex: indexPath.row];
    callHistoryVC.phoneNumber = aCall._phoneNumber;
    callHistoryVC.onDate = aCall._callDate;
    
    UINavigationController *navigationVC = [AppUtils createNavigationWithController: callHistoryVC];
    [AppUtils showDetailViewWithController: navigationVC];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return hSection;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

- (void)btnCallOnCellPressed: (UIButton *)sender {
    NSString *phoneNumber = [AppUtils removeAllSpecialInString: sender.currentTitle];
    [SipUtils makeCallWithPhoneNumber: phoneNumber];
}

- (void)didTapCheckBox:(BEMCheckBox *)checkBox {
    NSIndexPath *indexPath = [checkBox _indexPath];
    iPadHistoryCallCell *cell = [tbCalls cellForRowAtIndexPath: indexPath];
    if ([listDelete containsObject:[NSNumber numberWithInt:cell.cbDelete._idHisCall]]) {
        [listDelete removeObject: [NSNumber numberWithInt:cell.cbDelete._idHisCall]];
        [cell.cbDelete setOn:false animated:true];
    }else{
        [listDelete addObject: [NSNumber numberWithInt:cell.cbDelete._idHisCall]];
        [cell.cbDelete setOn:true animated:true];
    }
}

@end
