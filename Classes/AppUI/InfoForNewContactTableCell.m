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
    
    float hLabel = 25.0;
    float hTextfield = 38.0;
    float marginTop = 10.0;
    if (!IS_IPHONE && !IS_IPOD) {
        hLabel = 35.0;
        hTextfield = IPAD_HEIGHT_TF;
        marginTop = 15.0;
    }
    
    lbTitle.font = [UIFont fontWithName:HelveticaNeue size:17.0];
    lbTitle.textColor = [UIColor colorWithRed:(50/255.0) green:(50/255.0)
                                         blue:(50/255.0) alpha:1.0];
    [lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.top.equalTo(self).offset(marginTop);
        make.height.mas_equalTo(hLabel);
    }];
    
    tfContent.borderStyle = UITextBorderStyleNone;
    tfContent.font = [UIFont fontWithName:HelveticaNeue size:17.0];
    tfContent.textColor = [UIColor colorWithRed:(50/255.0) green:(50/255.0)
                                           blue:(50/255.0) alpha:1.0];
    tfContent.clipsToBounds = YES;
    tfContent.layer.cornerRadius = 3.0;
    tfContent.layer.borderWidth = 1.0;
    tfContent.layer.borderColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0)
                                                   blue:(235/255.0) alpha:1.0].CGColor;
    [tfContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(lbTitle);
        make.top.equalTo(lbTitle.mas_bottom).offset(5.0);
        make.height.mas_equalTo(hTextfield);
    }];
    
    UIView *pView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, hTextfield)];
    tfContent.leftView = pView;
    tfContent.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *pRight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, hTextfield)];
    tfContent.rightView = pRight;
    tfContent.rightViewMode = UITextFieldViewModeAlways;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
