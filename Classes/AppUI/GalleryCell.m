//
//  GalleryCell.m
//  linphone
//
//  Created by user on 7/11/14.
//
//

#import "GalleryCell.h"

@implementation GalleryCell
@synthesize _avatarGallery, _nameGallery, _numberImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.layer.borderColor = [UIColor blueColor].CGColor;
        self.layer.borderWidth = 2.0;
    }else{
        
    }
}

- (void)dealloc {
}


@end
