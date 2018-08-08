//
//  AlbumCell.m
//  linphone
//
//  Created by Ei Captain on 4/11/17.
//
//

#import "AlbumCell.h"

@implementation AlbumCell
@synthesize _lbName, _cbSelect, _lbSepa, _imgGroup;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _lbName.font = [UIFont fontWithName:HelveticaNeue size:15.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupUIForCell {
    _imgGroup.frame = CGRectMake(5, 5, self.frame.size.height-10, self.frame.size.height-10);
    _cbSelect.frame = CGRectMake(self.frame.size.width-22-5, (self.frame.size.height-22)/2, 22, 22);
    _lbName.frame = CGRectMake(_imgGroup.frame.origin.x+_imgGroup.frame.size.width+5, (self.frame.size.height-30)/2, self.frame.size.width-(_imgGroup.frame.origin.x+_imgGroup.frame.size.width+5+_cbSelect.frame.size.width+5), 30);
    _lbSepa.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
}

@end
