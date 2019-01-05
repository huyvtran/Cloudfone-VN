//
//  DrawingControlsView.m
//  linphone
//
//  Created by lam quang quan on 1/4/19.
//

#import "DrawingControlsView.h"
#import "ColorCollectionCell.h"

@implementation DrawingControlsView
@synthesize clvColors, imgTransparent, sldWidth, listColor, sizeButtonColor;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    if (self) {
        self.clipsToBounds = YES;
        
        listColor = @[UIColor.redColor, UIColor.blackColor, UIColor.whiteColor, UIColor.grayColor, UIColor.yellowColor, UIColor.greenColor, UIColor.orangeColor, UIColor.blueColor, UIColor.purpleColor, UIColor.brownColor];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = PADDING_DRAW_CONTROL_VIEW;
        layout.minimumInteritemSpacing = PADDING_DRAW_CONTROL_VIEW;
        
        clvColors = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
        clvColors.backgroundColor = UIColor.clearColor;
        clvColors.delegate = self;
        clvColors.dataSource = self;
        [clvColors registerClass:[ColorCollectionCell class] forCellWithReuseIdentifier:[ColorCollectionCell description]];
        [self addSubview: clvColors];
        [clvColors mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self).offset(PADDING_DRAW_CONTROL_VIEW);
            make.right.equalTo(self).offset(-PADDING_DRAW_CONTROL_VIEW);
            make.height.mas_equalTo(sizeButtonColor);
        }];
        
        imgTransparent = [[UIImageView alloc] init];
        imgTransparent.backgroundColor = UIColor.clearColor;
        imgTransparent.image = [UIImage imageNamed:@"bg_transparent"];
        [self addSubview: imgTransparent];
        [imgTransparent mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(PADDING_DRAW_CONTROL_VIEW);
            make.top.equalTo(clvColors.mas_bottom).offset(PADDING_DRAW_CONTROL_VIEW);
            make.right.equalTo(self.mas_centerX).offset(-PADDING_DRAW_CONTROL_VIEW);
            make.bottom.equalTo(self).offset(-PADDING_DRAW_CONTROL_VIEW);
        }];
        
        sldWidth = [[UISlider alloc] init];
        sldWidth.backgroundColor = UIColor.orangeColor;
        [self addSubview: sldWidth];
        [sldWidth mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_centerX).offset(PADDING_DRAW_CONTROL_VIEW);
            make.centerY.equalTo(imgTransparent.mas_centerY);
            make.right.equalTo(self).offset(-PADDING_DRAW_CONTROL_VIEW);
            make.height.mas_equalTo(32.0);
        }];
    }
    return self;
}

- (void)layoutSubviews {
    NSLog(@"layoutSubviews");
    
    [clvColors mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self).offset(PADDING_DRAW_CONTROL_VIEW);
        make.right.equalTo(self).offset(-PADDING_DRAW_CONTROL_VIEW);
        make.height.mas_equalTo(sizeButtonColor);
    }];
    
    [imgTransparent mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(PADDING_DRAW_CONTROL_VIEW);
        make.top.equalTo(clvColors.mas_bottom).offset(PADDING_DRAW_CONTROL_VIEW);
        make.right.equalTo(self.mas_centerX).offset(-PADDING_DRAW_CONTROL_VIEW);
        make.bottom.equalTo(self).offset(-PADDING_DRAW_CONTROL_VIEW);
    }];
    
    [sldWidth mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_centerX).offset(PADDING_DRAW_CONTROL_VIEW);
        make.centerY.equalTo(imgTransparent.mas_centerY);
        make.right.equalTo(self).offset(-PADDING_DRAW_CONTROL_VIEW);
        make.height.mas_equalTo(32.0);
    }];
    
    
}

#pragma mark - UICollection delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return listColor.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ColorCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[ColorCollectionCell description] forIndexPath:indexPath];
    cell.clipsToBounds = YES;
    
    UIColor *curColor = [listColor objectAtIndex: indexPath.row];
    cell.btnColor.backgroundColor = curColor;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(sizeButtonColor, sizeButtonColor);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return PADDING_DRAW_CONTROL_VIEW;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, PADDING_DRAW_CONTROL_VIEW/2, 0, PADDING_DRAW_CONTROL_VIEW/2);
}

@end
