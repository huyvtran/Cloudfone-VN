//
//  AllCallsViewController.m
//  linphone
//
//  Created by Ei Captain on 7/5/16.
//
//

#import "AllCallsViewController.h"
#import "DetailHistoryCNViewController.h"
#import "PhoneMainView.h"
#import "NSDatabase.h"
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
    
    UIFont *textFont;
    
    YBHud *waitingHud;
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
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }else{
        hCell = 60.0;
        hSection = 35.0;
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
    }
    _lbNoCalls.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-([LinphoneAppDelegate sharedInstance]._hStatus+[LinphoneAppDelegate sharedInstance]._hHeader+[LinphoneAppDelegate sharedInstance]._hTabbar));
    _lbNoCalls.font = textFont;
    _lbNoCalls.textColor = UIColor.grayColor;
    _lbNoCalls.textAlignment = NSTextAlignmentCenter;
    
    _tbListCalls.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-([LinphoneAppDelegate sharedInstance]._hStatus+[LinphoneAppDelegate sharedInstance]._hHeader+[LinphoneAppDelegate sharedInstance]._hTabbar));
    _tbListCalls.delegate = self;
    _tbListCalls.dataSource = self;
    _tbListCalls.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self showContentWithCurrentLanguage];
    
    if (waitingHud == nil) {
        //  add waiting view
        waitingHud = [[YBHud alloc] initWithHudType:DGActivityIndicatorAnimationTypeLineScale andText:@""];
        waitingHud.tintColor = [UIColor whiteColor];
        waitingHud.dimAmount = 0.5;
    }
    [waitingHud showInView:[LinphoneAppDelegate sharedInstance].window animated:YES];
    _tbListCalls.hidden = YES;
    isDeleted = false;
    
    //  Sự kiện click trên icon Edit
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginEditHistoryView)
                                                 name:editHistoryCallView object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(btnDoneRemoveHistoryCallPressed)
                                                 name:finishRemoveHistoryCall object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getHistoryCallForUser)
                                                 name:reloadHistoryCall object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    [self getHistoryCallForUser];
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

- (void)getHistoryCallForUser {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (listCalls == nil) {
            listCalls = [[NSMutableArray alloc] init];
        }
        [listCalls removeAllObjects];
        
        NSArray *tmpArr = [NSDatabase getHistoryCallListOfUser:USERNAME isMissed: false];
        [listCalls addObjectsFromArray: tmpArr];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [waitingHud dismissAnimated:YES];
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
    _lbNoCalls.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_no_recent_call];
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
    [_tbListCalls reloadData];
}

//  Click trên button Edit
- (void)beginEditHistoryView {
    isDeleted = true;
    [_tbListCalls reloadData];
}

//  Click trên button xoá tất cả
- (void)clickOnDeleAllButton: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[NSNumber class]]) {
        int value = [object intValue];
        if (value == 0) {
            BOOL result = [NSDatabase deleteAllHistoryCallOfUser: USERNAME];
            if (!result) {
                [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_failed] duration:2.0 position:CSToastPositionCenter];
            }else{
                _lbNoCalls.hidden = NO;
                _tbListCalls.hidden = NO;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:k11ReloadAfterDeleteAllCall
                                                                    object:nil];
            }
        }
    }
}

//  Chuyển số phone trong history thành số phone hiển thị lên tableview
- (NSString *)changePhoneNumberOfUser: (NSString *)phoneNumber {
    NSString *result = @"";
    if (phoneNumber != nil) {
        if ([phoneNumber isEqualToString: hotline]) {
            result = @"hotline";
        }else{
            NSArray *tmpArr = [phoneNumber componentsSeparatedByString:@"_"];
            if (tmpArr.count > 1) {
                //  Trường hợp gọi trunking
                result = [tmpArr objectAtIndex: 1];
            }else if ([phoneNumber hasPrefix:@"sv-"]){
                //  Trường hợp gọi saving
                result = [phoneNumber substringFromIndex: 3];
            }else{
                // Trường hợp gọi premium
                NSRange range = [phoneNumber rangeOfString:@",,"];
                if (range.location != NSNotFound) {
                    NSString *tmpStr = [phoneNumber substringFromIndex: range.location+range.length];
                    result = [tmpStr substringToIndex: tmpStr.length-1];
                }else{
                    result = phoneNumber;
                }
            }
        }
    }
    return result;
}

//  Get lại danh sách các cuộc gọi sau khi xoá
- (void)reGetListCallsForHistory {
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
    NSString *phoneNumber = [self changePhoneNumberOfUser: aCall._phoneNumber];
    cell._lbPhone.text = phoneNumber;
    cell._phoneNumber = phoneNumber;
    
    if ([aCall._phoneName isEqualToString:@""]) {
        cell._lbName.text = phoneNumber;
    }else{
        cell._lbName.text = aCall._phoneName;
    }
    
    if (aCall._phoneAvatar == nil || [aCall._phoneAvatar isEqualToString:@""] || [aCall._phoneAvatar isEqualToString:@"(null)"] || [aCall._phoneAvatar isEqualToString:@"null"] || [aCall._phoneAvatar isEqualToString:@"<null>"])
    {
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
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, _tbListCalls.frame.size.width, hCell);
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
    }else{
        HistoryCallCell *curCell = (HistoryCallCell *)[tableView cellForRowAtIndexPath: indexPath];
        if (![curCell._phoneNumber isEqualToString: @""]) {
            DetailHistoryCNViewController *controller = VIEW(DetailHistoryCNViewController);
            if (controller != nil) {
                [controller setPhoneNumberForView: curCell._phoneNumber];
            }
            [[PhoneMainView instance] changeCurrentView:[DetailHistoryCNViewController compositeViewDescription] push:true];
        }else{
            [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_phone_not_exists] duration:2.0 position:CSToastPositionCenter];
        }
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
        titleHeader =  [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_today];
    }else{
        NSString *yesterday = [AppUtils checkYesterdayForHistoryCall:currentDate];
        if ([yesterday isEqualToString:@"Yesterday"]) {
            titleHeader =  [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_yesterday];
        }else{
            titleHeader = currentDate;
        }
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, hSection)];
    headerView.backgroundColor = [UIColor colorWithRed:(240/255.0) green:(240/255.0)
                                                  blue:(240/255.0) alpha:1.0];
    
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, hSection)];
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

- (void)btnCallOnCellPressed: (UIButton *)sender {
    NSString *phoneNumber = [sender.titleLabel text];
    if (![phoneNumber isEqualToString: @""]) {
        LinphoneAddress *addr = linphone_core_interpret_url(LC, phoneNumber.UTF8String);
        [LinphoneManager.instance call:addr];
        if (addr)
            linphone_address_destroy(addr);
        
        OutgoingCallViewController *controller = VIEW(OutgoingCallViewController);
        if (controller != nil) {
            [controller setPhoneNumberForView: phoneNumber];
        }
        [[PhoneMainView instance] changeCurrentView:[OutgoingCallViewController compositeViewDescription] push:TRUE];
    }else{
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_phone_not_exists] duration:2.0 position:CSToastPositionCenter];
    }
}

@end
