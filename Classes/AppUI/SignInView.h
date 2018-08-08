//
//  SignInView.h
//  linphone
//
//  Created by Ei Captain on 2/28/17.
//
//

#import <UIKit/UIKit.h>
#import "YBHud.h"

@interface SignInView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *_imgBackground;
@property (weak, nonatomic) IBOutlet UIScrollView *_scrollViewContent;
@property (weak, nonatomic) IBOutlet UIImageView *_imgLogo;
@property (weak, nonatomic) IBOutlet UITextField *_tfUsername;
@property (weak, nonatomic) IBOutlet UIImageView *_iconUsername;
@property (weak, nonatomic) IBOutlet UILabel *_lbUsername;
@property (weak, nonatomic) IBOutlet UILabel *_lbBotUsername;

@property (weak, nonatomic) IBOutlet UITextField *_tfPassword;
@property (weak, nonatomic) IBOutlet UIImageView *_iconPassword;
@property (weak, nonatomic) IBOutlet UILabel *_lbPassword;
@property (weak, nonatomic) IBOutlet UILabel *_lbBotPassword;
@property (weak, nonatomic) IBOutlet UIButton *_btnShowHidePass;

@property (weak, nonatomic) IBOutlet UIButton *_btnSignIn;

@property (weak, nonatomic) IBOutlet UIButton *_btnForgotPassword;

@property (weak, nonatomic) IBOutlet UILabel *_lbNoAccount;
@property (weak, nonatomic) IBOutlet UIButton *_btnSignUp;

@property (nonatomic, strong) YBHud *waitingHud;

- (void)setupUIForView;

- (IBAction)_btnSignUpPressed:(id)sender;
- (IBAction)_btnShowHidePassPressed:(UIButton *)sender;

@end
