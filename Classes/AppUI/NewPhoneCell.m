//
//  NewPhoneCell.m
//  linphone
//
//  Created by Ei Captain on 3/18/17.
//
//

#import "NewPhoneCell.h"

@interface NewPhoneCell (){
    float hTextfield;
}

@end

@implementation NewPhoneCell
@synthesize _iconTypePhone, _tfPhone, _iconNewPhone;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    if (SCREEN_WIDTH > 320) {
        hTextfield = 35.0;
        _tfPhone.font = [UIFont fontWithName:HelveticaNeue size:18.0];
    }else{
        hTextfield = 30.0;
        _tfPhone.font = [UIFont fontWithName:HelveticaNeue size:16.0];
    }
    _tfPhone.leftView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 5, hTextfield)];
    _tfPhone.leftViewMode = UITextFieldViewModeAlways;
    
    //  my code here
    _tfPhone.textColor = [UIColor colorWithRed:(50/255.0) green:(50/255.0)
                                          blue:(50/255.0) alpha:1.0];
    _tfPhone.keyboardType = UIKeyboardTypePhonePad;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setupUIForCell {
    float marginX = 10.0;
    _iconNewPhone.frame = CGRectMake(marginX, (self.frame.size.height-hTextfield)/2, hTextfield, hTextfield);
    _iconTypePhone.frame = CGRectMake(self.frame.size.width - (_iconNewPhone.frame.size.width+marginX), _iconNewPhone.frame.origin.y, hTextfield, hTextfield);
    _tfPhone.frame = CGRectMake(_iconNewPhone.frame.origin.x+_iconNewPhone.frame.size.width+marginX, _iconNewPhone.frame.origin.y, _iconTypePhone.frame.origin.x-marginX-(_iconNewPhone.frame.origin.x+_iconNewPhone.frame.size.width+marginX), hTextfield);
}

@end
