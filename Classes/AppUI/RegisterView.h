//
//  RegisterView.h
//  linphone
//
//  Created by Ei Captain on 3/14/17.
//
//

#import <UIKit/UIKit.h>
#import "BEMCheckBox.h"
#import "PrivacyPopupView.h"
#import "YBHud.h"
#import "WebServices.h"

@interface RegisterView : UIView<WebServicesDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *_scrollViewContent;
@property (weak, nonatomic) IBOutlet UIImageView *_imgLogo;

@property (weak, nonatomic) IBOutlet UIImageView *_iconEmail;
@property (weak, nonatomic) IBOutlet UITextField *_tfEmail;
@property (weak, nonatomic) IBOutlet UILabel *_lbEmail;
@property (weak, nonatomic) IBOutlet UILabel *_lbBotEmail;

@property (weak, nonatomic) IBOutlet UITextField *_tfPhone;
@property (weak, nonatomic) IBOutlet UIImageView *_iconPhone;
@property (weak, nonatomic) IBOutlet UILabel *_lbPhone;
@property (weak, nonatomic) IBOutlet UILabel *_lbBotPhone;
@property (weak, nonatomic) IBOutlet UIButton *_iconFlag;
@property (weak, nonatomic) IBOutlet UILabel *_lbCode;

@property (weak, nonatomic) IBOutlet BEMCheckBox *_icCheckBox;
@property (weak, nonatomic) IBOutlet UILabel *_lbAgree1;
@property (weak, nonatomic) IBOutlet UILabel *_lbAgree2;
@property (weak, nonatomic) IBOutlet UILabel *_lbAgree3;
@property (weak, nonatomic) IBOutlet UIButton *_btnRegister;
@property (weak, nonatomic) IBOutlet UILabel *_lbHaveAccount;
@property (weak, nonatomic) IBOutlet UIButton *_btnLogin;

@property (weak, nonatomic) IBOutlet UIImageView *_imgBackground;

- (IBAction)_btnRegisterPressed:(UIButton *)sender;
- (IBAction)_btnLoginPressed:(UIButton *)sender;
- (void)setupUIForView;

@property (nonatomic, strong) YBHud *waitingHud;
@property (nonatomic, strong) WebServices *webService;

@end
