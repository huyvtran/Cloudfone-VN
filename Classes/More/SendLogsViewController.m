//
//  SendLogsViewController.m
//  linphone
//
//  Created by lam quang quan on 11/27/18.
//

#import "SendLogsViewController.h"
#import "SendLogFileCell.h"

@interface SendLogsViewController (){
    NSMutableArray *listFiles;
    NSMutableArray *listSelect;
}

@end

@implementation SendLogsViewController
@synthesize viewHeader, bgHeader, icBack, lbHeader, icSend, tbLogs;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //  my code here
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    icSend.enabled = NO;
    
    if (listSelect == nil) {
        listSelect = [[NSMutableArray alloc] init];
    }
    [listSelect removeAllObjects];
    
    if (listFiles == nil) {
        listFiles = [[NSMutableArray alloc] init];
    }
    [listFiles removeAllObjects];
    [listFiles addObjectsFromArray:[WriteLogsUtils getAllFilesInDirectory:logsFolderName]];
    [tbLogs reloadData];
    
    icSend.hidden = YES;
    
    
    NSLog(@"%lu files", (unsigned long)listFiles.count);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)icBackClicked:(UIButton *)sender {
    [[PhoneMainView instance] popCurrentView];
}

- (IBAction)icSendClicked:(UIButton *)sender {
}

//  setup ui trong view
- (void)setupUIForView
{
    if (SCREEN_WIDTH > 320) {
        lbHeader.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:20.0];
    }else{
        lbHeader.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }
    
    //  header view
    [viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo([LinphoneAppDelegate sharedInstance]._hRegistrationState);
    }];
    
    [icBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewHeader);
        make.centerY.equalTo(lbHeader.mas_centerY);
        make.width.height.mas_equalTo(HEADER_ICON_WIDTH);
    }];
    
    [bgHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(viewHeader);
    }];
    
    [lbHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader).offset([LinphoneAppDelegate sharedInstance]._hStatus);
        make.bottom.equalTo(viewHeader);
        make.centerX.equalTo(viewHeader.mas_centerX);
        make.width.mas_equalTo(200);
    }];
    
    [icSend setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [icSend setTitleColor:UIColor.grayColor forState:UIControlStateDisabled];
    [icSend mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(viewHeader).offset(-5.0);
        make.centerY.equalTo(lbHeader.mas_centerY);
        make.width.mas_equalTo(80.0);
        make.height.mas_equalTo(HEADER_ICON_WIDTH);
    }];
    
    [tbLogs mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader.mas_bottom);
        make.bottom.left.right.equalTo(viewHeader);
    }];
    tbLogs.delegate = self;
    tbLogs.dataSource = self;
    tbLogs.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - uitableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return listFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"SendLogFileCell";
    SendLogFileCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SendLogFileCell" owner:self options:nil];
        cell = topLevelObjects[0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (![listSelect containsObject: indexPath]) {
        cell.imgSelect.image = [UIImage imageNamed:@"ic_not_check.png"];
    }else{
        cell.imgSelect.image = [UIImage imageNamed:@"ic_checked.png"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![listSelect containsObject: indexPath]) {
        [listSelect addObject: indexPath];
    }else{
        [listSelect removeObject: indexPath];
    }
    [tbLogs reloadData];
    if (listSelect.count > 0) {
        icSend.enabled = YES;
    }else{
        icSend.enabled = NO;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

@end
