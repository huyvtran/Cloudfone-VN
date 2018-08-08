//
//  BackgroundViewController.m
//  linphone
//
//  Created by user on 25/9/14.
//
//

#import "BackgroundViewController.h"
#import "PhoneMainView.h"
#import "NSDatabase.h"
#import "JSONKit.h"
#import "UIImageView+WebCache.h"

@interface BackgroundViewController (){
    float sizeItem;
    NSMutableArray *listBackground;
    
    WebServices *webService;
}
@end

@implementation BackgroundViewController
@synthesize _viewHeader, _iconBack, _lbHeader, _bgCollectionView, _chatGroup;

#pragma mark - UICompositeViewDelegate Functions
static UICompositeViewDescription *compositeDescription = nil;
+ (UICompositeViewDescription *)compositeViewDescription {
    if (compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:nil
                                                                 tabBar:nil
                                                               sideMenu:nil
                                                             fullscreen:false
                                                         isLeftFragment:YES
                                                           fragmentWith:nil];
        compositeDescription.darkBackground = true;
    }
    return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
    return self.class.compositeViewDescription;
}

#pragma mark - My Controller
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //  My code here
    webService = [[WebServices alloc] init];
    webService.delegate = self;
    
    [_iconBack setBackgroundImage:[UIImage imageNamed:@"ic_back_act.png"]
                         forState:UIControlStateHighlighted];
    
    [_viewHeader setFrame: CGRectMake(0, 0, SCREEN_WIDTH, [LinphoneAppDelegate sharedInstance]._hHeader)];
    [_iconBack setFrame: CGRectMake(5, ([LinphoneAppDelegate sharedInstance]._hHeader-40.0)/2, 40.0, 40.0)];
    
    [_lbHeader setFrame: CGRectMake(_iconBack.frame.origin.x+_iconBack.frame.size.width+5, _iconBack.frame.origin.y, _viewHeader.frame.size.width-(_iconBack.frame.origin.x*2 + _iconBack.frame.size.width*2 + 5*2), _iconBack.frame.size.height)];
    [_lbHeader setFont:[UIFont fontWithName:MYRIADPRO_REGULAR size:19.0]];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // Collection view
    [_bgCollectionView setFrame: CGRectMake(0, _viewHeader.frame.origin.y+_viewHeader.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT-([LinphoneAppDelegate sharedInstance]._hStatus+[LinphoneAppDelegate sharedInstance]._hHeader))];
    
    [_bgCollectionView setDelegate: self];
    [_bgCollectionView setDataSource: self];
    [_bgCollectionView setBackgroundColor: [UIColor clearColor]];
    [_bgCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self
                       action:@selector(refershControlAction)
             forControlEvents:UIControlEventValueChanged];
    [_bgCollectionView addSubview:refreshControl];
    _bgCollectionView.alwaysBounceVertical = YES;
    
    // Web services
    sizeItem = (SCREEN_WIDTH-15)/3;
}

- (void)viewWillAppear:(BOOL)animated {
    // Tắt màn hình cảm biến
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled: NO];
    
    [self showContentWithCurrentLanguage];
    
    if (listBackground == nil) {
        listBackground = [[NSMutableArray alloc] init];
    }else{
        [listBackground removeAllObjects];
    }
    
    [self checkFileOnFolder:@"themes"];
    
    [self getImagesBackgroundFromServer];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
}

- (void)viewDidUnload {
    [self set_iconBack:nil];
    [self set_lbHeader:nil];
    [self set_bgCollectionView:nil];
    [super viewDidUnload];
}

- (IBAction)_iconBackClicked:(id)sender {
    [[PhoneMainView instance] popCurrentView];
}

#pragma mark - my functions

- (void)showContentWithCurrentLanguage {
    [_lbHeader setText: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_choose_background]];
}

//  Kiểm tra và lấy các ảnh trong folder
- (void)checkFileOnFolder: (NSString *)folderName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Kiểm tra folder có tồn tại hay không?
    NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", folderName]];
    BOOL isDir;
    BOOL exists = [fileManager fileExistsAtPath:folderPath isDirectory:&isDir];
    if (!exists) {
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error: nil];
    }
}

- (void)refershControlAction {
    NSLog(@"%@", @"refresh");
}

#pragma mark - collection view

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [listBackground count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell setTag: indexPath.row];
    
    NSDictionary *imageDict = [listBackground objectAtIndex: indexPath.row];
    NSString *link = [imageDict objectForKey:@"link"];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.frame];
    cell.backgroundView = imageView;
    
    if (![link isKindOfClass:[NSNull class]] && link != nil) {
        [imageView sd_setImageWithURL:[NSURL URLWithString: link]
                           placeholderImage:[UIImage imageNamed:@"unloaded.png"]];
    }else{
        [imageView setImage:[UIImage imageNamed:@"unloaded.png"]];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *curCell = [collectionView cellForItemAtIndexPath: indexPath];
    [curCell.layer setBorderColor: [UIColor colorWithRed:(63/255.0) green:(198/255.0)
                                                    blue:(255/255.0) alpha:1.0].CGColor];
    [curCell.layer setBorderWidth: 2.0];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *curCell = [collectionView cellForItemAtIndexPath: indexPath];
    [curCell.layer setBorderColor: [UIColor clearColor].CGColor];
    [curCell.layer setBorderWidth: 0.0];
    
    NSDictionary *bgInfo = [listBackground objectAtIndex: curCell.tag];
    if (_chatGroup) {
        NSString *link = [bgInfo objectForKey:@"link"];
        [NSDatabase saveBackgroundChatForRoom:[LinphoneAppDelegate sharedInstance].roomChatName withBackground:link];
    }else{
        NSString *link = [bgInfo objectForKey:@"link"];
        NSString *userStr = [AppUtils getSipFoneIDFromString: [LinphoneAppDelegate sharedInstance].friendBuddy.accountName];
        [NSDatabase saveBackgroundChatForUser:userStr withBackground:link];
    }
    [[PhoneMainView instance] popCurrentView];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(sizeItem, sizeItem);
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(2.5, 2.5, 2.5, 2.5); // top, left, bottom, right
}

#pragma mark - WebService Delegate
-(void)successfulToCallWebService:(NSString *)link withData:(NSDictionary *)data {
    if ([link isEqualToString: getImagesBackground]) {
        if ([data isKindOfClass:[NSArray class]] && [(NSArray *)data count] > 0) {
            [listBackground addObjectsFromArray: (NSArray *)data];
            [_bgCollectionView reloadData];
        }
    }
}

-(void)failedToCallWebService:(NSString *)link andError:(NSString *)error {
    if ([link isEqualToString: getImagesBackground]) {
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_failed]
                    duration:2.0 position:CSToastPositionCenter];
    }
}

-(void)receivedResponeCode:(NSString *)link withCode:(int)responeCode {
    
}

- (void)getImagesBackgroundFromServer
{
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:AuthUser forKey:@"AuthUser"];
    [jsonDict setObject:AuthKey forKey:@"AuthKey"];
    
    [webService callWebServiceWithLink:getImagesBackground withParams:jsonDict];
}

@end
