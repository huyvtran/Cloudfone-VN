//
//  ColorCollectionCell.m
//  linphone
//
//  Created by lam quang quan on 1/5/19.
//

#import "ColorCollectionCell.h"

@implementation ColorCollectionCell
@synthesize btnColor;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        btnColor = [[UIButton alloc] init];
        [self.contentView addSubview: btnColor];
        [btnColor mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.right.equalTo(self.contentView);
        }];
    }
    return self;
}

@end
