//
//  ConfirmResetPasswordView.h
//  linphone
//
//  Created by Hung Ho on 8/1/17.
//
//

#import <UIKit/UIKit.h>

@interface ConfirmResetPasswordView : UIView

@property (weak, nonatomic) IBOutlet UIScrollView *_scrollViewContent;
@property (weak, nonatomic) IBOutlet UIImageView *_imgLogo;
@property (weak, nonatomic) IBOutlet UITextField *_tfConfirm;
@property (weak, nonatomic) IBOutlet UILabel *_lbConfirm;
@property (weak, nonatomic) IBOutlet UIImageView *_icPassword;

@property (weak, nonatomic) IBOutlet UILabel *_lbBotConfirm;

@property (weak, nonatomic) IBOutlet UIButton *_btnConfirmReset;
@property (weak, nonatomic) IBOutlet UIImageView *_imgBackgroud;
@property (weak, nonatomic) IBOutlet UIButton *_iconClose;

- (void)setupUIForView;

@end
