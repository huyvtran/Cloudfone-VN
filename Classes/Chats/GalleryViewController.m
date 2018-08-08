//
//  GalleryViewController.m
//  linphone
//
//  Created by user on 7/11/14.
//
//

#import "GalleryViewController.h"
#import "PicturesViewController.h"
#import "PhoneMainView.h"
#import "GalleryCell.h"
#import <Photos/Photos.h>
#import <Photos/PHAsset.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "StatusBarView.h"

@interface GalleryViewController (){
    float hHeader;
    HMLocalization *localization;
}
@end

@implementation GalleryViewController
@synthesize _viewHeader, _iconBack, _lbHeader, _collectionListAlbum;
@synthesize _listAlbum;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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

#pragma mark - my controller delegate
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    localization = [HMLocalization sharedInstance];
    
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated {
    // Tắt màn hình cảm biến
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled: NO];
    
    [_collectionListAlbum registerNib:[UINib nibWithNibName:@"GalleryCell" bundle:[NSBundle mainBundle]]
          forCellWithReuseIdentifier:@"GalleryCell"];
    [self fetchGalleryListings];
    
    _listAlbum = [[NSMutableArray alloc] init];
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
    [self set_collectionListAlbum:nil];
    [super viewDidUnload];
}

- (IBAction)_iconBackClicked:(id)sender {
    [[PhoneMainView instance] popCurrentView];
}

#pragma mark - my functions
- (void)setupUIForView {
    hHeader = 42.0;
    
    //  view header
    [_viewHeader setFrame: CGRectMake(0, 0, SCREEN_WIDTH, hHeader)];
    [_iconBack setFrame: CGRectMake(0, 0, hHeader, hHeader)];
    [_iconBack setBackgroundImage:[UIImage imageNamed:@"ic_back_act.png"]
                         forState:UIControlStateHighlighted];
    
    [_lbHeader setFrame: CGRectMake(_iconBack.frame.origin.x+_iconBack.frame.size.width+5, 0, (_viewHeader.frame.size.width-2*_iconBack.frame.size.width-10), hHeader)];
    [_lbHeader setText: [localization localizedStringForKey:text_gallery_header]];
    [_lbHeader setFont:[UIFont fontWithName:HelveticaNeue size:18.0]];
    
    _collectionListAlbum.delegate = self;
    _collectionListAlbum.dataSource = self;
    [_collectionListAlbum setBackgroundColor:[UIColor colorWithRed:(90/255.0) green:(90/255.0)
                                                              blue:(90/255.0) alpha:1.0]];
}

#pragma mark - gallery methods and functions
- (ALAssetsLibrary *)defaultAssetsLibrary{
    static dispatch_once_t pred     = 0;
    static ALAssetsLibrary *library = nil;
    
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

- (void)fetchGalleryListings {
    [_listAlbum removeAllObjects];
    ALAssetsLibrary *library = [self defaultAssetsLibrary];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    dispatch_async(queue, ^{
        
        [library enumerateGroupsWithTypes:ALAssetsGroupAlbum|ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                if ([group valueForProperty:ALAssetsGroupPropertyName]) {
                    if (!_listAlbum) {
                        _listAlbum = [[NSMutableArray alloc] init];
                    }
                    /*--Lay nhung album co anh--*/
                    if (group.numberOfAssets > 0) {
                        [_listAlbum addObject:group];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_collectionListAlbum reloadData];
                    });
                }
            }
            
        } failureBlock:^(NSError *error) {
            NSLog(@"error loading assets: %@", [error localizedDescription]);
        }];
    });
}


#pragma mark - collection view delegate and datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_listAlbum count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"GalleryCell";
    GalleryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    ALAssetsGroup *aAlbum = (ALAssetsGroup*)[_listAlbum objectAtIndex:indexPath.row];
    [aAlbum setAssetsFilter:[ALAssetsFilter allPhotos]];
    
    cell._nameGallery.marqueeType = MLContinuous;
    cell._nameGallery.scrollDuration = 15.0f;
    cell._nameGallery.animationCurve = UIViewAnimationOptionCurveEaseInOut;
    cell._nameGallery.fadeLength = 10.0f;
    cell._nameGallery.continuousMarqueeExtraBuffer = 10.0f;
    cell._nameGallery.textColor = [UIColor whiteColor];
    [cell._nameGallery setBackgroundColor:[UIColor blackColor]];
    cell._nameGallery.text = [NSString stringWithFormat:@"%@", [aAlbum valueForProperty:ALAssetsGroupPropertyName]];
    [cell._nameGallery setFont:[UIFont fontWithName:HelveticaNeue size:12.0]];
    cell._nameGallery.alpha = 0.8;
    
    cell._numberImage.text = [NSString stringWithFormat:@"%d", (int)[aAlbum numberOfAssets]];
    [cell._numberImage setFont:[UIFont fontWithName:HelveticaNeue size:12.0]];
    cell._numberImage.alpha = 0.8;
    
    cell._avatarGallery.image = [UIImage imageWithCGImage:[aAlbum posterImage]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    ALAssetsGroup *groupImage = (ALAssetsGroup*)[_listAlbum objectAtIndex:indexPath.row];
    [LinphoneAppDelegate sharedInstance].photoGroup   = groupImage;
    
    [[PhoneMainView instance] changeCurrentView:[PicturesViewController compositeViewDescription]];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(140, 140);
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(20, 10, 10, 10); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 5.0;
}

@end
