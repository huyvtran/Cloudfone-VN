//
//  ChatPhotosView.m
//  linphone
//
//  Created by Ei Captain on 4/10/17.
//
//

#import "ChatPhotosView.h"
#import "ChatImageCell.h"
#import "ChooseAlbumPopupView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ShowPictureViewController.h"
#import "PhoneMainView.h"

@interface ChatPhotosView (){
    ALAssetsLibrary *assetsLibrary;
    NSMutableArray *groups;
    float hViewPhoto;
    
    NSMutableArray *assets;
    float wCell;
}

@end

@implementation ChatPhotosView
@synthesize _collectionView;

- (void)setupUIForView
{
    wCell = (SCREEN_WIDTH-10*4)/3;
    hViewPhoto = 175.0;
    
    //  [_collectionView setFrame: CGRectMake(5, 5, self.frame.size.width-10, hViewPhoto-10)];
    [_collectionView registerNib:[UINib nibWithNibName:@"ChatImageCell" bundle:[NSBundle mainBundle]]
      forCellWithReuseIdentifier:@"ChatImageCell"];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPopupChooseAlbum)
                                                 name:showListAlbumForView object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadListImageForAlbum:)
                                                 name:chooseOtherAlbumForSent object:nil];
}

- (void)reloadListImageForAlbum: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[ALAssetsGroup class]]) {
        [self getListImageForOneAlbumForAlbum: object];
    }
}

- (void)getListGroupsPhotos {
    if (assetsLibrary == nil) {
        assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    
    if (groups == nil) {
        groups = [[NSMutableArray alloc] init];
    }else {
        [groups removeAllObjects];
    }
    
    // setup our failure view controller in case enumerateGroupsWithTypes fails
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        NSString *errorMessage = nil;
        switch ([error code]) {
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
                errorMessage = @"The user has declined access to it.";
                break;
            default:
                errorMessage = @"Reason unknown.";
                break;
        }
    };
    
    // emumerate through our groups and only add groups that contain photos
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        if ([group numberOfAssets] > 0)
        {
            [groups addObject:group];
        }
        else
        {
            [self performSelectorOnMainThread:@selector(getImageForAlbum) withObject:nil waitUntilDone:NO];
        }
    };
    
    // enumerate only photos
    NSUInteger groupTypes = ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos;
    [assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
}

//  sau khi get list album xong
- (void)getImageForAlbum {
    if (groups.count > 0) {
        ALAssetsGroup *assetsGroup = [groups objectAtIndex: 0];
        [self getListImageForOneAlbumForAlbum: assetsGroup];
    }
}

//  //  get danh sách hình ảnh cho một album
- (void)getListImageForOneAlbumForAlbum: (ALAssetsGroup *)curGroup {
    //  Cập nhật header album cho view chat
    NSString *albumName = [curGroup valueForProperty:ALAssetsGroupPropertyName];
    [[NSNotificationCenter defaultCenter] postNotificationName:updateTitleAlbumForViewChat
                                                        object:albumName];
    
    if (!assets) {
        assets = [[NSMutableArray alloc] init];
    } else {
        [assets removeAllObjects];
    }
    
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            NSLog(@"Added");
            [assets addObject:result];
        }else{
            NSLog(@"Da lay xong");
            [_collectionView reloadData];
        }
    };
    
    ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
    [curGroup setAssetsFilter:onlyPhotosFilter];
    [curGroup enumerateAssetsUsingBlock:assetsEnumerationBlock];
}

#pragma mark - collection view delegate and datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return (int)[assets count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"ChatImageCell";
    ChatImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // load the asset for this cell
    ALAsset *asset = assets[indexPath.row];
    CGImageRef thumbnailImageRef = [asset thumbnail];
    UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
    
    // apply the image to the cell
    cell._imgPicture.image = thumbnail;
    cell._btnTop.tag = indexPath.row;
    [cell._btnTop addTarget:self
                     action:@selector(chooseImageForSent:)
           forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)chooseImageForSent:(UIButton *)sender {
    int index = (int)[sender tag];
    
    ALAsset *asset  = (ALAsset *)assets[index];
    // NSString *name = [[asset defaultRepresentation] filename];
    if ([[asset defaultRepresentation] filename] != nil) {
        [LinphoneAppDelegate sharedInstance].imageChooseName = [[asset defaultRepresentation] filename];
    }
    ALAssetRepresentation *rep;
    rep = [asset defaultRepresentation];
    [LinphoneAppDelegate sharedInstance].imageChoose = [UIImage imageWithCGImage:[rep fullScreenImage]];
    
    [[PhoneMainView instance] changeCurrentView: ShowPictureViewController.compositeViewDescription
                                           push: TRUE];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(wCell, wCell);
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 5.0;
}

#pragma mark - my functions

- (void)showPopupChooseAlbum {
    ChooseAlbumPopupView *popupChoose = [[ChooseAlbumPopupView alloc] initWithFrame: CGRectMake(20, (SCREEN_HEIGHT-40*5)/2, SCREEN_WIDTH-40, 40*5)];
    if (popupChoose._listAlbum == nil) {
        popupChoose._listAlbum = [[NSMutableArray alloc] init];
        [popupChoose._listAlbum addObjectsFromArray:groups];
    }else{
        [popupChoose._listAlbum removeAllObjects];
        [popupChoose._listAlbum addObjectsFromArray:groups];
    }
    
    [popupChoose showInView:[LinphoneAppDelegate sharedInstance].window animated:YES];
}

@end
