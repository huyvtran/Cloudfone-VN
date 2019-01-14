//
//  iPadPBXSettingViewController.h
//  linphone
//
//  Created by lam quang quan on 1/14/19.
//

#import <UIKit/UIKit.h>

@interface iPadPBXSettingViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *icWaiting;

@property (weak, nonatomic) IBOutlet UIView *viewContent;
@property (weak, nonatomic) IBOutlet UILabel *lbPBX;
@property (weak, nonatomic) IBOutlet UISwitch *swChange;
@property (weak, nonatomic) IBOutlet UILabel *lbSepa;
@property (weak, nonatomic) IBOutlet UILabel *lbServerID;
@property (weak, nonatomic) IBOutlet UITextField *tfServerID;
@property (weak, nonatomic) IBOutlet UILabel *lbAccount;
@property (weak, nonatomic) IBOutlet UITextField *tfAccount;
@property (weak, nonatomic) IBOutlet UILabel *lbPassword;
@property (weak, nonatomic) IBOutlet UITextField *tfPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnClear;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UIButton *btnLoginWithPhone;

- (IBAction)btnClearPressed:(UIButton *)sender;
- (IBAction)btnSavePressed:(UIButton *)sender;

@end
