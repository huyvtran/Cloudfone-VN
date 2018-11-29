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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)icBackClicked:(UIButton *)sender {
    [[PhoneMainView instance] popCurrentView];
}

- (IBAction)icSendClicked:(UIButton *)sender {
    /*
    NSString *totalEmail = [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@", @"lekhai0212@gmail.com", @"Send logs file", messageSend];
    NSString *url = [totalEmail stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication]  openURL: [NSURL URLWithString: url]];
    */
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    
    NSString *emailTitle =  @"Send logs files";
    NSString *messageBody = @"";
    NSArray *toRecipents = [NSArray arrayWithObject:@"lekhai0212@gmail.com"];
    
    for (int i=0; i<listSelect.count; i++)
    {
        NSIndexPath *curIndex = [listSelect objectAtIndex: i];
        NSString *fileName = [listFiles objectAtIndex: curIndex.row];
        NSString *path = [NgnFileUtils getPathOfFileWithSubDir:[NSString stringWithFormat:@"%@/%@", logsFolderName, fileName]];
        NSData *logFileData = [NSData dataWithContentsOfFile: path];
        [mc addAttachmentData:logFileData mimeType:@"text/plain" fileName:fileName];
    }
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    [self presentViewController:mc animated:YES completion:NULL];
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
    
    tbLogs.backgroundColor = UIColor.clearColor;
    [tbLogs mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader.mas_bottom);
        make.bottom.left.right.equalTo(self.view);
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
    NSString *fileName = [listFiles objectAtIndex: indexPath.row];
    cell.lbName.text = [NSString stringWithFormat:@"log_file_%@", fileName];
    
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

#pragma mark - Email
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (error) {
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Failed to send email. Please check again!"] duration:2.0 position:CSToastPositionCenter];
    }else{
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Your email was sent. Thank you!"] duration:2.0 position:CSToastPositionCenter];
    }
    [self performSelector:@selector(goBack) withObject:nil afterDelay:2.0];
}

- (void)goBack {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
