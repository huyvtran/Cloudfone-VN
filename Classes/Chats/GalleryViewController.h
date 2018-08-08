//
//  GalleryViewController.h
//  linphone
//
//  Created by user on 7/11/14.
//
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface GalleryViewController : UIViewController<UICompositeViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (retain, nonatomic) IBOutlet UIButton *_iconBack;
@property (weak, nonatomic) IBOutlet UILabel *_lbHeader;
@property (retain, nonatomic) IBOutlet UICollectionView *_collectionListAlbum;
@property (retain, nonatomic) NSMutableArray *_listAlbum;

//action
- (IBAction)_iconBackClicked:(id)sender;

- (ALAssetsLibrary *)defaultAssetsLibrary;

@end
