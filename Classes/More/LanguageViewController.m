//
//  LanguageViewController.m
//  linphone
//
//  Created by Apple on 5/10/17.
//
//

#import "LanguageViewController.h"
#import "LanguageCell.h"
#import "LanguageObject.h"

@interface LanguageViewController (){
    NSMutableArray *listLanguage;
    NSString *curLanguage;
}

@end

@implementation LanguageViewController
@synthesize _viewHeader, bgHeader, _iconBack, _lbHeader, _tbLanguage;

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

#pragma mark - My Controller Delegate

- (void)viewDidLoad {
    [super viewDidLoad];
    //  my code here
    [self autoLayoutForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [WriteLogsUtils writeForGoToScreen:@"LanguageViewController"];
    
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

- (IBAction)_iconBackClicked:(UIButton *)sender {
    [[PhoneMainView instance] popCurrentView];
}

#pragma mark - my functions

- (void)showContentOfCurrentLanguage {
    _lbHeader.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Change language"];
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
    
    [_tbLanguage reloadData];
}

- (void)autoLayoutForView
{
    if (SCREEN_WIDTH > 320) {
        _lbHeader.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:20.0];
    }else{
        _lbHeader.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }
    
    //  header view
    [_viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo([LinphoneAppDelegate sharedInstance]._hRegistrationState);
    }];
    
    [bgHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(_viewHeader);
    }];
    
    [_lbHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader).offset([LinphoneAppDelegate sharedInstance]._hStatus);
        make.bottom.equalTo(_viewHeader);
        make.width.mas_equalTo(200);
        make.centerX.equalTo(_viewHeader.mas_centerX);
    }];
    
    [_iconBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_viewHeader);
        make.centerY.equalTo(_lbHeader.mas_centerY);
        make.width.height.mas_equalTo(HEADER_ICON_WIDTH);
    }];
    
    //  tableview
    [_tbLanguage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_viewHeader.mas_bottom);
        make.left.bottom.right.equalTo(self.view);
    }];
    _tbLanguage.delegate = self;
    _tbLanguage.dataSource = self;
    _tbLanguage.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tbLanguage.backgroundColor = UIColor.clearColor;
    self.view.backgroundColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                                 blue:(230/255.0) alpha:1.0];
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
