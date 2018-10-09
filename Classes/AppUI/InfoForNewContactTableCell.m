//
//  InfoForNewContactTableCell.m
//  linphone
//
//  Created by lam quang quan on 10/9/18.
//

#import "InfoForNewContactTableCell.h"

@implementation InfoForNewContactTableCell
@synthesize lbTitle, tfContent;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    lbTitle.font = [UIFont fontWithName:HelveticaNeue size:16.0];
    lbTitle.textColor = [UIColor colorWithRed:(50/255.0) green:(50/255.0)
                                         blue:(50/255.0) alpha:1.0];
    [lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.top.equalTo(self).offset(10);
        make.height.mas_equalTo(25.0);
    }];
    
    tfContent.font = [UIFont fontWithName:HelveticaNeue size:16.0];
    tfContent.textColor = [UIColor colorWithRed:(50/255.0) green:(50/255.0)
                                           blue:(50/255.0) alpha:1.0];
    [tfContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(lbTitle);
        make.top.equalTo(lbTitle.mas_bottom).offset(5);
        make.height.mas_equalTo(35.0);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
