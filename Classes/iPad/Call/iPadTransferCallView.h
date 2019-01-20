//
//  iPadTransferCallView.h
//  linphone
//
//  Created by admin on 1/20/19.
//

#import <UIKit/UIKit.h>
#import "UIAddressTextField.h"

@interface iPadTransferCallView : UIView

@property (weak, nonatomic) IBOutlet UIView *viewKeypad;
@property (weak, nonatomic) IBOutlet UIAddressTextField *addressField;
@property (weak, nonatomic) IBOutlet UIDigitButton *oneButton;
@property (weak, nonatomic) IBOutlet UIDigitButton *twoButton;
@property (weak, nonatomic) IBOutlet UIDigitButton *threeButton;
@property (weak, nonatomic) IBOutlet UIDigitButton *fourButton;
@property (weak, nonatomic) IBOutlet UIDigitButton *fiveButton;
@property (weak, nonatomic) IBOutlet UIDigitButton *sixButton;
@property (weak, nonatomic) IBOutlet UIDigitButton *sevenButton;
@property (weak, nonatomic) IBOutlet UIDigitButton *eightButton;
@property (weak, nonatomic) IBOutlet UIDigitButton *nineButton;
@property (weak, nonatomic) IBOutlet UIDigitButton *starButton;
@property (weak, nonatomic) IBOutlet UIDigitButton *zeroButton;
@property (weak, nonatomic) IBOutlet UIDigitButton *sharpButton;
@property (weak, nonatomic) IBOutlet UIButton *backToCallButton;
@property (weak, nonatomic) IBOutlet UIIconButton *backspaceButton;
@property (weak, nonatomic) IBOutlet UIButton *transferCallButton;


- (void)setupUIForView;
- (IBAction)onDigitPress:(UIDigitButton *)sender;

@end
