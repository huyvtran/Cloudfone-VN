//
//  iPadSendLogsViewController.m
//  linphone
//
//  Created by lam quang quan on 1/14/19.
//

#import "iPadSendLogsViewController.h"
#import "SendLogFileCell.h"
#import "AESCrypt.h"

@interface iPadSendLogsViewController () {
    NSMutableArray *listFiles;
    NSMutableArray *listSelect;
    UIBarButtonItem *btnSend;
}

@end

@implementation iPadSendLogsViewController
@synthesize tbLogs;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUIForView];
    
    btnSend = [[UIBarButtonItem alloc] initWithTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Send"] style:UIBarButtonItemStyleDone target:self action:@selector(sendLogFilePressed)];
    self.navigationItem.rightBarButtonItem = btnSend;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    //  remove other files if it is not log file
    [DeviceUtils cleanLogFolder];
    [WriteLogsUtils clearLogFilesAfterExpireTime: DAY_FOR_LOGS*24*3600];
    
    self.title = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Send logs"];
    btnSend.title = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Send"];
    btnSend.enabled = NO;
    
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

- (void)sendLogFilePressed {
    if ([MFMailComposeViewController canSendMail]) {
        BOOL networkReady = [DeviceUtils checkNetworkAvailable];
        if (!networkReady) {
            [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Please check your internet connection!"] duration:2.0 position:CSToastPositionCenter];
            return;
        }
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        
        NSString *emailTitle =  @"Send logs files";
        NSString *messageBody = @"";
        NSArray *toRecipents = [NSArray arrayWithObject:@"lekhai0212@gmail.com"];
        
        for (int i=0; i<listSelect.count; i++)
        {
            NSIndexPath *curIndex = [listSelect objectAtIndex: i];
            NSString *fileName = [listFiles objectAtIndex: curIndex.row];
            NSString *path = [NgnFileUtils getPathOfFileWithSubDir:[NSString stringWithFormat:@"%@/%@", logsFolderName, fileName]];
            
            NSString* content = [NSString stringWithContentsOfFile:path
                                                          encoding:NSUTF8StringEncoding
                                                             error:NULL];
            NSString *encryptStr = [AESCrypt encrypt:content password:AES_KEY];
            NSData *logFileData = [encryptStr dataUsingEncoding:NSUTF8StringEncoding];
            
            NSString *nameForSend = [DeviceUtils convertLogFileName: fileName];
            [mc addAttachmentData:logFileData mimeType:@"text/plain" fileName:nameForSend];
        }
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        [mc setToRecipients:toRecipents];
        
        
        
        [self presentViewController:mc animated:YES completion:NULL];
    }else{
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Can not send email. Please check your email account again!"]
                    duration:3.0 position:CSToastPositionCenter];
    }
}

- (void)setupUIForView
{
    //  tableview
    tbLogs.backgroundColor = UIColor.clearColor;
    [tbLogs mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(self.view);
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
    fileName = [DeviceUtils convertLogFileName: fileName];
    cell.lbName.text = fileName;
    
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
        btnSend.enabled = YES;
    }else{
        btnSend.enabled = NO;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

#pragma mark - Email
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (error) {
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Failed to send email. Please check again!"] duration:4.0 position:CSToastPositionCenter];
    }else{
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Your email was sent. Thank you!"] duration:4.0 position:CSToastPositionCenter];
    }
    [self performSelector:@selector(goBack) withObject:nil afterDelay:2.0];
}

- (void)goBack {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
