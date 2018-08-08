//
//  ViewChangePassword.h
//  linphone
//
//  Created by Ei Captain on 7/5/16.
//
//

#import <UIKit/UIKit.h>

@interface ViewChangePassword : UIView

@property (weak, nonatomic) IBOutlet UITextField *_tfOldPass;
@property (weak, nonatomic) IBOutlet UITextField *_tfNewPass;
@property (weak, nonatomic) IBOutlet UITextField *_tfConfirmPass;
@property (weak, nonatomic) IBOutlet UILabel *_lbNotification;
@property (weak, nonatomic) IBOutlet UIButton *_btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *_btnConfirm;
@property (weak, nonatomic) IBOutlet UIView *_viewFooter;

- (void)setupUIForView;
- (void)showContentWithCurrentLanguage;
@end
