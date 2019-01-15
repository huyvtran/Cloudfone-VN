//
//  iPadChangePasswordViewController.h
//  linphone
//
//  Created by admin on 1/15/19.
//

#import <UIKit/UIKit.h>
#import "WebServices.h"

@interface iPadChangePasswordViewController : UIViewController<WebServicesDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewContent;
@property (weak, nonatomic) IBOutlet UILabel *lbPassword;
@property (weak, nonatomic) IBOutlet UITextField *tfPassword;

@property (weak, nonatomic) IBOutlet UILabel *lbNewPassword;
@property (weak, nonatomic) IBOutlet UITextField *tfNewPassword;

@property (weak, nonatomic) IBOutlet UILabel *lbConfirmPassword;
@property (weak, nonatomic) IBOutlet UITextField *tfConfirmPassword;
@property (weak, nonatomic) IBOutlet UILabel *lbPasswordDesc;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *icWaiting;

- (IBAction)btnCancelPressed:(UIButton *)sender;
- (IBAction)btnSavePressed:(UIButton *)sender;

@end
