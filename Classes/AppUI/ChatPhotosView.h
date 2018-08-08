//
//  ChatPhotosView.h
//  linphone
//
//  Created by Ei Captain on 4/10/17.
//
//

#import <UIKit/UIKit.h>

@interface ChatPhotosView : UIView<UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *_collectionView;

- (void)setupUIForView;
- (void)getListGroupsPhotos;

@end
