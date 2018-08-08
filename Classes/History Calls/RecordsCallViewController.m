//
//  RecordsCallViewController.m
//  linphone
//
//  Created by Ei Captain on 7/5/16.
//
//

#import "RecordsCallViewController.h"
#import "HistoryCallCell.h"
#import "KHistoryCallObject.h"
#import "NSDatabase.h"
#import "NSData+Base64.h"
#import "RecordCallPopupView.h"
#import "PhoneMainView.h"

@interface RecordsCallViewController ()
{
    HMLocalization *localization;
    NSMutableArray *listCall;
    float hCell;
    float hSection;
    
    NSMutableArray *listDelete;
    BOOL isDeleted;
    
    UIView *messageView;
    UILabel *lbMessage;
    
    RecordCallPopupView *popupRecord;
    UIFont *textFont;
}

@end

@implementation RecordsCallViewController
@synthesize _lbNoCalls, _tbRecordCall;

- (void)viewDidLoad {
    [super viewDidLoad];
    // MY CODE HERE
    localization = [HMLocalization sharedInstance];
    
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    isDeleted = false;
    if (listCall == nil) {
        listCall = [[NSMutableArray alloc] init];
    }
    [listCall removeAllObjects];
    
    [listCall addObjectsFromArray:[NSDatabase getHistoryRecordCallListOfUser:USERNAME]];
    
    if (listCall.count == 0) {
        _tbRecordCall.hidden = YES;
        _lbNoCalls.hidden = NO;
    }else {
        [_tbRecordCall reloadData];
        _tbRecordCall.hidden = NO;
        _lbNoCalls.hidden = YES;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(btnDoneRemoveHistoryCallPressed)
                                                 name:finishRemoveHistoryCall object:nil];
    
    //  Sự kiện click trên icon Edit
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginEditHistoryView)
                                                 name:editHistoryCallView object:nil];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - my functions

//  Click trên button Edit
- (void)beginEditHistoryView {
    isDeleted = true;
    [_tbRecordCall reloadData];
}

//  Nhấn nút xoá lịch sử cuộc gọi
- (void)btnDoneRemoveHistoryCallPressed {
    isDeleted = false;
    if (listDelete != nil && listDelete.count > 0) {
        for (int iCount=0; iCount<listDelete.count; iCount++) {
            int idHisCall = [[listDelete objectAtIndex: iCount] intValue];
            NSString *recordFile = [NSDatabase getRecordFileNameOfCall: idHisCall];
            [NSDatabase deleteRecordCallHistory:idHisCall withRecordFile: recordFile];
        }
    }
    [self reGetListCallsForHistory];
    [_tbRecordCall reloadData];
}

//  Get lại danh sách các cuộc gọi sau khi xoá
- (void)reGetListCallsForHistory {
    [listCall removeAllObjects];
    [listCall addObjectsFromArray:[NSDatabase getHistoryRecordCallListOfUser: USERNAME]];
}

- (void)setupUIForView {
    if (SCREEN_WIDTH > 320) {
        hCell = 70.0;
        hSection = 35.0;
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }else{
        hCell = 60.0;
        hSection = 35.0;
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
    }
    
    [_lbNoCalls setFrame: CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-[LinphoneAppDelegate sharedInstance]._hStatus-[LinphoneAppDelegate sharedInstance]._hHeader-[LinphoneAppDelegate sharedInstance]._hTabbar)];
    [_lbNoCalls setFont: textFont];
    [_lbNoCalls setTextColor:[UIColor grayColor]];
    [_lbNoCalls setText:[localization localizedStringForKey:text_no_recorded_call]];
    [_lbNoCalls setTextAlignment:NSTextAlignmentCenter];
    
    [_tbRecordCall setFrame: _lbNoCalls.frame];
    [_tbRecordCall setDelegate: self];
    [_tbRecordCall setDataSource: self];
    [_tbRecordCall setSeparatorStyle: UITableViewCellSeparatorStyleNone];
}

//  Click trên button xoá tất cả
- (void)clickOnDeleAllButton: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[NSNumber class]]) {
        int value = [object intValue];
        if (value == 2) {
            [[NSNotificationCenter defaultCenter] postNotificationName:k11ReloadAfterDeleteAllCall
                                                                object:nil];
        }
    }
}

- (void)btnCallOnCellPressed: (UIButton *)sender {
    NSString *phoneNumber = [sender.titleLabel text];
    if (![phoneNumber isEqualToString: @""]) {
        LinphoneAddress *addr = linphone_core_interpret_url([LinphoneManager getLc], phoneNumber.UTF8String);
        [LinphoneManager.instance call:addr];
        if (addr)
            linphone_address_destroy(addr);
        
        OutgoingCallViewController *controller = VIEW(OutgoingCallViewController);
        if (controller != nil) {
            [controller setPhoneNumberForView: phoneNumber];
        }
        [[PhoneMainView instance] changeCurrentView:[OutgoingCallViewController compositeViewDescription] push:TRUE];
    }else{
        [self showPopupWithContent:[localization localizedStringForKey:text_phone_not_exists]
                      withTimeShow:1.0 andTimeHide:3.5];
    }
}

- (void)showPopupWithContent: (NSString *)strContent withTimeShow: (float)showValue andTimeHide: (float)hideValue {
    if (messageView == nil) {
        messageView = [[UIView alloc] init];
        [messageView setBackgroundColor:[UIColor blackColor]];
        [messageView.layer setCornerRadius: 5.0];
        
        lbMessage = [[UILabel alloc] init];
        [lbMessage setNumberOfLines: 10];
        [lbMessage setTextColor:[UIColor whiteColor]];
        [lbMessage setTextAlignment: NSTextAlignmentCenter];
        [messageView addSubview: lbMessage];
        [self.view addSubview: messageView];
    }
    [lbMessage setText: strContent];
    
    CGSize size = [AppUtils getSizeWithText:strContent
                                      withFont:textFont
                                   andMaxWidth:(SCREEN_WIDTH-40)];
    
    [lbMessage setFont: textFont];
    [messageView setFrame: CGRectMake((self.view.frame.size.width-size.width-20)/2, (self.view.frame.size.height-size.height-20)/2, size.width+20, size.height+20)];
    [lbMessage setFrame: CGRectMake(10, 10, size.width, size.height)];
    
    [messageView setHidden: NO];
    [UIView animateWithDuration:showValue animations:^{
        [messageView setAlpha: 1.0];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:hideValue animations:^{
            [messageView setAlpha: 0];
        }];
    }];
}

#pragma mark - UITableview Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [listCall count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[[listCall objectAtIndex:section] valueForKey:@"rows"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"HistoryCallCell";
    HistoryCallCell *cell = (HistoryCallCell *)[tableView dequeueReusableCellWithIdentifier: identifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HistoryCallCell" owner:self options:nil];
        cell = topLevelObjects[0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    KHistoryCallObject *aCall = [[[listCall objectAtIndex:indexPath.section] valueForKey:@"rows"] objectAtIndex: indexPath.row];
    
    cell._phoneNumber = aCall._phoneNumber;
    cell._lbPhone.text = aCall._phoneNumber;
    if ([aCall._phoneName isEqualToString:@""]) {
        cell._lbName.text = aCall._phoneNumber;
    }else{
        cell._lbName.text = aCall._phoneName;
    }
    
    if ([aCall._phoneAvatar isEqualToString:@""] || [aCall._phoneAvatar isEqualToString:@"(null)"] || [aCall._phoneAvatar isEqualToString:@"null"] || [aCall._phoneAvatar isEqualToString:@"<null>"]) {
        cell._imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
    }else{
        NSData *imgData = [[NSData alloc] initWithData:[NSData dataFromBase64String: aCall._phoneAvatar]];
        cell._imgAvatar.image = [UIImage imageWithData: imgData];
    }
    cell._lbDateTime.text = aCall._callTime;
    
    if (isDeleted) {
        cell._cbDelete.hidden = NO;
    }else{
        cell._cbDelete.hidden = YES;
        if ([aCall._callDirection isEqualToString: incomming_call]) {
            if ([aCall._status isEqualToString: missed_call]) {
                cell._imgStatus.image = [UIImage imageNamed:@"ic_call_missed.png"];
            }else{
                cell._imgStatus.image = [UIImage imageNamed:@"ic_call.png"];
            }
        }else{
            cell._imgStatus.image = [UIImage imageNamed:@"ic_call_to.png"];
        }
    }
    cell._cbDelete._indexPath = indexPath;
    cell._cbDelete._idHisCall = aCall._callId;
    cell._cbDelete.delegate = self;
    
    [cell._btnCall setTitle:aCall._phoneNumber forState:UIControlStateNormal];
    [cell._btnCall setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [cell._btnCall addTarget:self
                      action:@selector(btnCallOnCellPressed:)
            forControlEvents:UIControlEventTouchUpInside];
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, _tbRecordCall.frame.size.width, hCell);
    [cell setupUIForViewWithStatus: isDeleted];
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
    }else {
        KHistoryCallObject *aCall = [[[listCall objectAtIndex:indexPath.section] valueForKey:@"rows"] objectAtIndex: indexPath.row];
        
        popupRecord = [[RecordCallPopupView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 268)/2, (SCREEN_HEIGHT-50)/2 , 268, 50)];
        [popupRecord set_recordFile: aCall._recordFile];
        [popupRecord showTotalLengthOfRecordFile];
        [popupRecord showInView:[LinphoneAppDelegate sharedInstance].window animated:true];
        
        NSLog(@"Play record files");
    }
}

- (void)didTapCheckBox:(BEMCheckBox *)checkBox {
    NSIndexPath *indexPath = [checkBox _indexPath];
    if (listDelete == nil) {
        listDelete = [[NSMutableArray alloc] init];
    }
    
    HistoryCallCell *curCell = [_tbRecordCall cellForRowAtIndexPath: indexPath];
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
    NSString *currentDate = [[listCall objectAtIndex: section] valueForKey:@"title"];
    NSString *today = [AppUtils checkTodayForHistoryCall: currentDate];
    if ([today isEqualToString: @"Today"]) {
        titleHeader =  [localization localizedStringForKey:text_today];
    }else{
        NSString *yesterday = [AppUtils checkYesterdayForHistoryCall:currentDate];
        if ([yesterday isEqualToString:@"Yesterday"]) {
            titleHeader =  [localization localizedStringForKey:text_yesterday];
        }else{
            titleHeader = currentDate;
        }
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, hSection)];
    headerView.backgroundColor = [UIColor colorWithRed:(240/255.0) green:(240/255.0)
                                                  blue:(240/255.0) alpha:1.0];
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, hSection)];
    descLabel.backgroundColor = UIColor.clearColor;
    descLabel.textColor = UIColor.darkGrayColor;
    descLabel.font = textFont;
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

@end
