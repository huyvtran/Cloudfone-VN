//
//  LanguageCell.m
//  linphone
//
//  Created by Apple on 5/10/17.
//
//

#import "LanguageCell.h"

@implementation LanguageCell
@synthesize _imgFlag, _lbTitle, _imgSelect, _lbSepa;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setupUIForCell {
    _imgFlag.frame = CGRectMake(10, (self.frame.size.height-25)/2, 25.0, 25.0);
    _imgSelect.frame = CGRectMake(self.frame.size.width-10-30.0, (self.frame.size.height-25.0)/2, 25.0, 25.0);
    
    _lbTitle.frame = CGRectMake(_imgFlag.frame.origin.x+_imgFlag.frame.size.width+10, (self.frame.size.height-30)/2, self.frame.size.width-10*4-25.0-30.0, 30.0);
    
    _lbSepa.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, 1);
}

@end
