//
//  ResetPasswordView.h
//  linphone
//
//  Created by Apple on 5/8/17.
//
//

#import <UIKit/UIKit.h>
#import "ConfirmResetPasswordView.h"
#import "WebServices.h"

@interface ResetPasswordView : UIView<WebServicesDelegate>

@property (nonatomic, strong) ConfirmResetPasswordView *viewConfirmResetPass;

@property (weak, nonatomic) IBOutlet UIScrollView *_scrollViewContent;
@property (weak, nonatomic) IBOutlet UIButton *_iconClose;
@property (weak, nonatomic) IBOutlet UIImageView *_imgBackground;
@property (weak, nonatomic) IBOutlet UIImageView *_imgLogo;
@property (weak, nonatomic) IBOutlet UITextField *_tfAccount;
@property (weak, nonatomic) IBOutlet UILabel *_lbAccount;
@property (weak, nonatomic) IBOutlet UIImageView *_iconAccont;
@property (weak, nonatomic) IBOutlet UILabel *_lbBotAccount;

@property (weak, nonatomic) IBOutlet UILabel *_lbBotEmail;

@property (weak, nonatomic) IBOutlet UIButton *_btnResetPassword;

- (IBAction)_btnResetPasswordPressed:(UIButton *)sender;

- (void)setupUIForView;


@end
