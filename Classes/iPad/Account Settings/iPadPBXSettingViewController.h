//
//  iPadPBXSettingViewController.h
//  linphone
//
//  Created by lam quang quan on 1/14/19.
//

#import <UIKit/UIKit.h>
#import "CustomSwitchButton.h"
#import "WebServices.h"
#import "RegisterPBXWithPhoneView.h"
#import "QRCodeReaderDelegate.h"

@interface iPadPBXSettingViewController : UIViewController<CustomSwitchButtonDelegate, WebServicesDelegate, RegisterPBXWithPhoneViewDelegate, QRCodeReaderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

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
- (IBAction)btnLoginWithPhonePressed:(UIButton *)sender;

@property (nonatomic, strong) WebServices *webService;

@end
