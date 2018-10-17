//
//  UIMiniKeypad.h
//  linphone
//
//  Created by user on 18/12/13.
//
//

#import <UIKit/UIKit.h>
#import "UIDigitButton.h"
#import "UIAddressTextField.h"

@interface UIMiniKeypad : UIView
@property (nonatomic, retain) IBOutlet UIDigitButton* oneButton;
@property (nonatomic, retain) IBOutlet UIDigitButton* twoButton;
@property (nonatomic, retain) IBOutlet UIDigitButton* threeButton;
@property (nonatomic, retain) IBOutlet UIDigitButton* fourButton;
@property (nonatomic, retain) IBOutlet UIDigitButton* fiveButton;
@property (nonatomic, retain) IBOutlet UIDigitButton* sixButton;
@property (nonatomic, retain) IBOutlet UIDigitButton* sevenButton;
@property (nonatomic, retain) IBOutlet UIDigitButton* eightButton;
@property (nonatomic, retain) IBOutlet UIDigitButton* nineButton;
@property (nonatomic, retain) IBOutlet UIDigitButton* starButton;
@property (nonatomic, retain) IBOutlet UIDigitButton* zeroButton;
@property (nonatomic, retain) IBOutlet UIDigitButton* sharpButton;
@property (weak, nonatomic) IBOutlet UIButton *iconBack;
@property (weak, nonatomic) IBOutlet UIButton *iconMiniKeypadEndCall;
@property (weak, nonatomic) IBOutlet UIAddressTextField *tfNumber;
@property (weak, nonatomic) IBOutlet UILabel *lbQuality;
@property (weak, nonatomic) IBOutlet UILabel *lbQualityValue;
@property (weak, nonatomic) IBOutlet UIView *viewKeypad;
@property (weak, nonatomic) IBOutlet UIImageView *bgCall;

- (void)setupUIForView;
- (IBAction)iconEndCallClick:(UIButton *)sender;
- (IBAction)onDigitPress:(UIDigitButton *)sender;

@end
