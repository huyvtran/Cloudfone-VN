//
//  iPadLanguageViewController.m
//  linphone
//
//  Created by lam quang quan on 1/14/19.
//

#import "iPadLanguageViewController.h"
#import "LanguageCell.h"
#import "LanguageObject.h"

@interface iPadLanguageViewController () {
    NSMutableArray *listLanguage;
    NSString *curLanguage;
}

@end

@implementation iPadLanguageViewController
@synthesize tbLanguage;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [WriteLogsUtils writeForGoToScreen:@"iPadLanguageViewController"];
    
    [self showContentOfCurrentLanguage];
    
    curLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:language_key];
    if (curLanguage == nil || [curLanguage isEqualToString: @""]) {
        curLanguage = key_en;
        [[NSUserDefaults standardUserDefaults] setObject:key_en forKey:language_key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [self createDataForLanguageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showContentOfCurrentLanguage {
    self.title = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Change language"];
    [self createDataForLanguageView];
}

- (void)createDataForLanguageView {
    if (listLanguage == nil) {
        listLanguage = [[NSMutableArray alloc] init];
    }
    [listLanguage removeAllObjects];
    
    LanguageObject *viLang = [[LanguageObject alloc] init];
    viLang._code = @"vi";
    viLang._title = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Vietnamese"];
    viLang._flag = @"flag_vietnam";
    [listLanguage addObject: viLang];
    
    LanguageObject *enLang = [[LanguageObject alloc] init];
    enLang._code = @"en";
    enLang._title = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"English"];
    enLang._flag = @"flag_usa";
    [listLanguage addObject: enLang];
    
    [tbLanguage reloadData];
}

- (void)setupForView
{
    self.view.backgroundColor = IPAD_BG_COLOR;
    
    [tbLanguage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
    tbLanguage.delegate = self;
    tbLanguage.dataSource = self;
    tbLanguage.separatorStyle = UITableViewCellSeparatorStyleNone;
    tbLanguage.backgroundColor = UIColor.clearColor;
    tbLanguage.scrollEnabled = NO;
}

#pragma mark - UITableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return listLanguage.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"LanguageCell";
    LanguageCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"LanguageCell" owner:self options:nil];
        cell = topLevelObjects[0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    LanguageObject *langObj = [listLanguage objectAtIndex: indexPath.row];
    [cell._lbTitle setText: langObj._title];
    if ([langObj._code isEqualToString: curLanguage]) {
        cell._imgSelect.image = [UIImage imageNamed:@"ic_checked.png"];
    }else{
        cell._imgSelect.image = [UIImage imageNamed:@"ic_not_check.png"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LanguageObject *lang = [listLanguage objectAtIndex: indexPath.row];
    [[NSUserDefaults standardUserDefaults] setObject:lang._code forKey:language_key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    curLanguage = lang._code;
    [[LinphoneAppDelegate sharedInstance].localization setLanguage: lang._code];
    
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"[%s] Choosed %@ to set language", __FUNCTION__, curLanguage] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    [self showContentOfCurrentLanguage];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

@end
