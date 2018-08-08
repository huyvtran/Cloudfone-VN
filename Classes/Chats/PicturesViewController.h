//
//  PicturesViewController.h
//  linphone
//
//  Created by user on 7/11/14.
//
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UICompositeView.h"

@interface PicturesViewController : UIViewController<UICompositeViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>{
}

@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (weak, nonatomic) IBOutlet UIButton *_iconBack;
@property (weak, nonatomic) IBOutlet UILabel *_lbHeader;

@property (weak, nonatomic) IBOutlet UICollectionView *_clvImages;

- (IBAction)_iconBackClicked:(UIButton *)sender;

@end
