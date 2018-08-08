//
//  GalleryCell.h
//  linphone
//
//  Created by user on 7/11/14.
//
//

#import <UIKit/UIKit.h>
#import "MarqueeLabel.h"

@interface GalleryCell : UICollectionViewCell

@property (retain, nonatomic) IBOutlet UIImageView *_avatarGallery;
@property (retain, nonatomic) IBOutlet MarqueeLabel *_nameGallery;
@property (retain, nonatomic) IBOutlet UILabel *_numberImage;

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

@end
