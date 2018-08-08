//
//  MemberCollectionCell.m
//  linphone
//
//  Created by admin on 1/12/18.
//

#import "MemberCollectionCell.h"

@implementation MemberCollectionCell
@synthesize _lbName, _imgAvatar;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _lbName.font = [UIFont systemFontOfSize:11.0];
    _lbName.textColor = [UIColor darkGrayColor];
    
    _imgAvatar.clipsToBounds = YES;
    _imgAvatar.layer.cornerRadius = _imgAvatar.frame.size.height/2;
}

@end
