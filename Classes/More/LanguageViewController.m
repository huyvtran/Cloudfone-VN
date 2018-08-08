//
//  LanguageViewController.m
//  linphone
//
//  Created by Apple on 5/10/17.
//
//

#import "LanguageViewController.h"
#import "LanguageCell.h"
#import "PhoneMainView.h"
#import "LanguageObject.h"

@interface LanguageViewController (){
    float hCell;
    
    NSMutableArray *listLanguage;
    NSString *curLanguage;
}

@end

@implementation LanguageViewController
@synthesize _viewHeader, _iconBack, _lbHeader, _tbLanguage;

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
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
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
    _lbHeader.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_change_language];
    [self createDataForLanguageView];
}

- (void)createDataForLanguageView {
    if (listLanguage == nil) {
        listLanguage = [[NSMutableArray alloc] init];
    }
    [listLanguage removeAllObjects];
    
    LanguageObject *viLang = [[LanguageObject alloc] init];
    viLang._code = @"vi";
    viLang._title = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_lang_vi];
    viLang._flag = @"flag_vietnam";
    [listLanguage addObject: viLang];
    
    LanguageObject *enLang = [[LanguageObject alloc] init];
    enLang._code = @"en";
    enLang._title = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_lang_en];
    enLang._flag = @"flag_usa";
    [listLanguage addObject: enLang];
    
    [_tbLanguage reloadData];
}

- (void)setupUIForView
{
    if (SCREEN_WIDTH > 320) {
        _lbHeader.font = [UIFont fontWithName:HelveticaNeue size:20.0];
        hCell = 55.0;
    }else{
        _lbHeader.font = [UIFont fontWithName:HelveticaNeue size:18.0];
        hCell = 45.0;
    }
    
    //  header view
    _viewHeader.frame = CGRectMake(0, 0, SCREEN_WIDTH, [LinphoneAppDelegate sharedInstance]._hHeader);
    _iconBack.frame = CGRectMake(0, 0, [LinphoneAppDelegate sharedInstance]._hHeader, [LinphoneAppDelegate sharedInstance]._hHeader);
    [_iconBack setBackgroundImage:[UIImage imageNamed:@"ic_back_act.png"]
                         forState:UIControlStateHighlighted];
    
    _lbHeader.frame = CGRectMake(_iconBack.frame.origin.x+_iconBack.frame.size.width+5, 0, _viewHeader.frame.size.width-2*(_iconBack.frame.origin.x+_iconBack.frame.size.width+5), [LinphoneAppDelegate sharedInstance]._hHeader);
    
    //  tableview
    _tbLanguage.frame = CGRectMake(0, _viewHeader.frame.origin.y+_viewHeader.frame.size.height, SCREEN_WIDTH, hCell*2);
    _tbLanguage.delegate = self;
    _tbLanguage.dataSource = self;
    _tbLanguage.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tbLanguage.backgroundColor = [UIColor colorWithRed:(240/255.0) green:(240/255.0)
                                                   blue:(240/255.0) alpha:1.0];
    self.view.backgroundColor = [UIColor colorWithRed:(240/255.0) green:(240/255.0)
                                                 blue:(240/255.0) alpha:1.0];
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
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, _tbLanguage.frame.size.width, hCell);
    [cell setupUIForCell];
    
    LanguageObject *langObj = [listLanguage objectAtIndex: indexPath.row];
    [cell._lbTitle setText: langObj._title];
    if ([langObj._code isEqualToString: curLanguage]) {
        cell._imgSelect.image = [UIImage imageNamed:@"menu_select_did_checked.png"];
    }else{
        cell._imgSelect.image = [UIImage imageNamed:@"menu_select_did_not_check.png"];
    }
    cell._imgFlag.image = [UIImage imageNamed: langObj._flag];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LanguageObject *lang = [listLanguage objectAtIndex: indexPath.row];
    [[NSUserDefaults standardUserDefaults] setObject:lang._code forKey:language_key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    curLanguage = lang._code;
    [[LinphoneAppDelegate sharedInstance].localization setLanguage: lang._code];
    
    [self showContentOfCurrentLanguage];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return hCell;
}

@end
