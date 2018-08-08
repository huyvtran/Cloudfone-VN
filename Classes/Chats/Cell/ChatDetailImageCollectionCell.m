//
//  ChatDetailImageCollectionCell.m
//  linphone
//
//  Created by admin on 1/11/18.
//

#import "ChatDetailImageCollectionCell.h"

@implementation ChatDetailImageCollectionCell
@synthesize _scrollView, _imgView, _imgPlay;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _imgView.userInteractionEnabled = NO;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imgView;
}

- (void)disableZoomPicture: (BOOL)disable {
    if (disable) {
        _scrollView.maximumZoomScale = 1.0;
        _scrollView.minimumZoomScale = 1.0;
    }else{
        _scrollView.maximumZoomScale = 3.0;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.delegate = self;
    }
}

@end
