//
//  PicturesViewController.m
//  linphone
//
//  Created by user on 7/11/14.
//
//

#import "PicturesViewController.h"
#import "PhoneMainView.h"
#import "ShowPictureViewController.h"

@interface PicturesViewController (){
    NSMutableArray *galleryImages;
    HMLocalization *localization;
    UIFont *textFont;
}
@end

@implementation PicturesViewController
@synthesize _viewHeader, _iconBack, _lbHeader, _clvImages;

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

#pragma mark - My Controller delegate
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
    // My code here
    localization = [HMLocalization sharedInstance];
    
    [self setupUIForView];
    
    galleryImages = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Tắt màn hình cảm biến
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled: NO];
    
    NSString *galleryName = [[LinphoneAppDelegate sharedInstance].photoGroup valueForProperty:ALAssetsGroupPropertyName];
    [_lbHeader setText: galleryName];
    
    [self fetchGalleryImages];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
}

- (void)viewDidUnload {
    [self set_lbHeader:nil];
    [self set_iconBack:nil];
    [self set_clvImages:nil];
    [super viewDidUnload];
}

- (IBAction)_iconBackClicked:(UIButton *)sender {
    [[PhoneMainView instance] popCurrentView];
}

#pragma mark - my functions
- (void)setupUIForView
{
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
        [_lbHeader setFont:[UIFont fontWithName:MYRIADPRO_REGULAR size:20.0]];
    }else{
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
        [_lbHeader setFont:[UIFont fontWithName:MYRIADPRO_REGULAR size:18.0]];
    }
    //  view header
    [_viewHeader setFrame: CGRectMake(0, 0, SCREEN_WIDTH, [LinphoneAppDelegate sharedInstance]._hHeader)];
    [_iconBack setFrame: CGRectMake(0, 0, [LinphoneAppDelegate sharedInstance]._hHeader, [LinphoneAppDelegate sharedInstance]._hHeader)];
    [_iconBack setBackgroundImage:[UIImage imageNamed:@"ic_back_act.png"]
                         forState:UIControlStateHighlighted];
    
    [_lbHeader setFrame: CGRectMake(_iconBack.frame.origin.x+_iconBack.frame.size.width+5, 0, (_viewHeader.frame.size.width-2*_iconBack.frame.size.width-10), [LinphoneAppDelegate sharedInstance]._hHeader)];
    
    
    _clvImages.delegate = self;
    _clvImages.dataSource = self;
    [_clvImages setBackgroundColor:[UIColor colorWithRed:(90/255.0) green:(90/255.0) blue:(90/255.0) alpha:1.0]];
    [_clvImages registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
}

#pragma mark - UICollection view delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [[LinphoneAppDelegate sharedInstance].photoGroup numberOfAssets];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    ALAsset *asset     = (ALAsset *)[galleryImages objectAtIndex: indexPath.row];
    UIImage *thumbnail = [UIImage imageWithCGImage:[asset thumbnail]];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.frame];
    [imageView setImage: thumbnail];
    cell.backgroundView = imageView;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    ALAsset *asset     = (ALAsset *)[galleryImages objectAtIndex: indexPath.row];
    // NSString *name = [[asset defaultRepresentation] filename];
    if ([[asset defaultRepresentation] filename] != nil) {
        [LinphoneAppDelegate sharedInstance].imageChooseName = [[asset defaultRepresentation] filename];
    }
    UICollectionViewCell *currentCell = [collectionView cellForItemAtIndexPath: indexPath];
    if ([[currentCell backgroundView] isKindOfClass:[UIImageView class]]) {
        ALAssetRepresentation *rep;
        rep = [asset defaultRepresentation];
        [LinphoneAppDelegate sharedInstance].imageChoose = [UIImage imageWithCGImage:[rep fullScreenImage]];
        [[PhoneMainView instance] changeCurrentView:ShowPictureViewController.compositeViewDescription];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(90, 90);
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5.0;
}

#pragma mark - Private Methods
- (void)fetchGalleryImages {
    [galleryImages removeAllObjects];
    NSMutableArray *testArr = [[NSMutableArray alloc] init];
    if (!testArr.count) {
        //_galleryImages = [NSMutableArray new];
        [[LinphoneAppDelegate sharedInstance].photoGroup enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
            if (asset) {
                [testArr addObject:asset];
            }
        }];
        galleryImages = (NSMutableArray *)[[testArr reverseObjectEnumerator] allObjects];
        [_clvImages reloadData];
    }
}

@end
