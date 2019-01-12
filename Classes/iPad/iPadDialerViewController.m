//
//  iPadDialerViewController.m
//  linphone
//
//  Created by lam quang quan on 1/11/19.
//

#import "iPadDialerViewController.h"

@interface iPadDialerViewController (){
    eTypeHistory typeHistory;
    NSMutableArray *listCalls;
}

@end

@implementation iPadDialerViewController
@synthesize viewHeader, btnAll, btnMissed, imgHeader;
@synthesize tbCalls, lbNoCalls, imgNoCalls;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [WriteLogsUtils writeForGoToScreen:@"iPadDialerViewController"];
    
    typeHistory = eAllCalls;
    
    [self showContentWithCurrentLanguage];
    [self getHistoryCallForUser];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    [AppUtils addCornerRadiusTopLeftAndBottomLeftForButton:btnAll radius:HEIGHT_IPAD_HEADER_BUTTON/2 withColor:[UIColor colorWithRed:0.169 green:0.53 blue:0.949 alpha:1.0] border:2.0];
    [AppUtils addCornerRadiusTopRightAndBottomRightForButton:btnMissed radius:HEIGHT_IPAD_HEADER_BUTTON/2 withColor:[UIColor colorWithRed:0.169 green:0.53 blue:0.949 alpha:1.0] border:2.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnAllPress:(UIButton *)sender {
}

- (IBAction)btnMissedPress:(UIButton *)sender {
}

- (void)showContentWithCurrentLanguage {
    lbNoCalls.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"No call in your history"];
    [btnAll setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"All"] forState:UIControlStateNormal];
    [btnMissed setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Missed"] forState:UIControlStateNormal];
}

- (void)setupUIForView {
    self.view.backgroundColor = IPAD_BG_COLOR;
    
    //  header view
    [viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(HEIGHT_IPAD_NAV);
    }];
    
    [imgHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(viewHeader);
    }];
    
    float top = STATUS_BAR_HEIGHT + (HEIGHT_IPAD_NAV - STATUS_BAR_HEIGHT - HEIGHT_IPAD_HEADER_BUTTON)/2;
    btnAll.backgroundColor = [UIColor colorWithRed:0.169 green:0.53 blue:0.949 alpha:1.0];
    [btnAll setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [btnAll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader).offset(top);
        make.right.equalTo(viewHeader.mas_centerX);
        make.height.mas_equalTo(HEIGHT_IPAD_HEADER_BUTTON);
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
    
    //  table calls
    tbCalls.backgroundColor = UIColor.clearColor;
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
    lbNoCalls.textColor = [UIColor colorWithRed:(180/255.0) green:(180/255.0)
                                           blue:(180/255.0) alpha:1.0];
    [lbNoCalls mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgNoCalls.mas_bottom).offset(10.0);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(50.0);
    }];
    if (SCREEN_WIDTH > 320) {
        lbNoCalls.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:20.0];
    }else{
        lbNoCalls.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:17.0];
    }
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
        
        NSArray *tmpArr = [NSDatabase getHistoryCallListOfUser:USERNAME isMissed: false];
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

@end
