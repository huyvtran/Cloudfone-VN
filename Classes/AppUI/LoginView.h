//
//  LoginView.h
//  linphone
//
//  Created by Hung Ho on 7/4/17.
//
//

#import <UIKit/UIKit.h>
#import "SignInView.h"
#import "RegisterView.h"
#import "ConfirmView.h"
#import "ResetPasswordView.h"
#import "WebServices.h"

@protocol LoginViewDelegate
- (void)loginToSipWithInfo: (NSDictionary *)sipInfo;
@end

@interface LoginView : UIView<WebServicesDelegate>

@property (weak, nonatomic) IBOutlet UIView *_viewContent;
@property (weak, nonatomic) IBOutlet UIImageView *_imgLogo;
@property (weak, nonatomic) IBOutlet UIImageView *_imgBackground;
@property (weak, nonatomic) IBOutlet UILabel *_lbWelcome;
@property (weak, nonatomic) IBOutlet UIButton *_btnSignIn;
@property (weak, nonatomic) IBOutlet UILabel *_lbSepa;
@property (weak, nonatomic) IBOutlet UIButton *_btnSignUp;

@property (nonatomic, strong) SignInView *_viewSignIn;
@property (nonatomic, strong) RegisterView *_viewRegister;
@property (nonatomic, strong) ConfirmView *_viewConfirm;
@property (nonatomic, strong) ResetPasswordView *_viewResetPassword;

- (IBAction)_btnSignInPressed:(UIButton *)sender;
- (IBAction)_btnSignUpPressed:(UIButton *)sender;

- (void)setupUIForView;
- (void)addViewRegisterForMainView;

@property (nonatomic, strong) WebServices *webService;
@property (retain) id <NSObject, LoginViewDelegate > delegate;


@end
