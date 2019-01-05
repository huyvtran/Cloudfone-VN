//
//  DrawingControlsView.h
//  linphone
//
//  Created by lam quang quan on 1/4/19.
//

#import <UIKit/UIKit.h>

@interface DrawingControlsView : UIView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *clvColors;
@property (nonatomic, strong) UIImageView *imgTransparent;
@property (nonatomic, strong) UISlider *sldWidth;
@property (nonatomic, strong) NSArray *listColor;
@property (nonatomic, assign) float sizeButtonColor;

@end
