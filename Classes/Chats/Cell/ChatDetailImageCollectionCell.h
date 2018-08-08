//
//  ChatDetailImageCollectionCell.h
//  linphone
//
//  Created by admin on 1/11/18.
//

#import <UIKit/UIKit.h>

@interface ChatDetailImageCollectionCell : UICollectionViewCell<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *_scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *_imgView;
@property (weak, nonatomic) IBOutlet UIImageView *_imgPlay;

- (void)disableZoomPicture: (BOOL)disable;

@end
