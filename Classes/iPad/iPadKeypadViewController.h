//
//  iPadKeypadViewController.h
//  linphone
//
//  Created by admin on 1/11/19.
//

#import <UIKit/UIKit.h>
#import "UIAddressTextField.h"

@interface iPadKeypadViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet UIImageView *imgHeader;
@property (weak, nonatomic) IBOutlet UIImageView *imgLogo;
@property (weak, nonatomic) IBOutlet UILabel *lbAccount;
@property (weak, nonatomic) IBOutlet UILabel *lbStatus;

@property (weak, nonatomic) IBOutlet UIView *viewNumber;
@property (weak, nonatomic) IBOutlet UIButton *icAddContact;
@property (weak, nonatomic) IBOutlet UIAddressTextField *tfAddress;


@property (weak, nonatomic) IBOutlet UIView *viewKeypad;
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
@property (weak, nonatomic) IBOutlet UICallButton *btnCall;
@property (weak, nonatomic) IBOutlet UIButton *btnHotline;
@property (weak, nonatomic) IBOutlet UIIconButton *btnBackspace;


- (IBAction)icAddContactClicked:(UIButton *)sender;

@end
