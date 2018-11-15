//
//  PBXSettingViewController.h
//  linphone
//
//  Created by admin on 8/4/18.
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"
#import "WebServices.h"
#import "QRCodeReaderDelegate.h"
#import "RegisterPBXWithPhoneView.h"
#import "CustomSwitchButton.h"
#import "WebServices.h"

typedef enum{
    normalLogin,
    qrCodeLogin,
}typeLoginPBX;

@interface PBXSettingViewController : UIViewController<UICompositeViewDelegate, WebServicesDelegate, QRCodeReaderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RegisterPBXWithPhoneViewDelegate, CustomSwitchButtonDelegate>
@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (weak, nonatomic) IBOutlet UIButton *_iconBack;
@property (weak, nonatomic) IBOutlet UILabel *_lbTitle;
@property (weak, nonatomic) IBOutlet UIButton *_iconQRCode;
@property (weak, nonatomic) IBOutlet UIImageView *bgHeader;

@property (weak, nonatomic) IBOutlet UIView *_viewContent;
@property (weak, nonatomic) IBOutlet UILabel *_lbPBX;
@property (weak, nonatomic) IBOutlet UILabel *_lbSepa;
@property (weak, nonatomic) IBOutlet UILabel *_lbServerID;
@property (weak, nonatomic) IBOutlet UITextField *_tfServerID;

@property (weak, nonatomic) IBOutlet UILabel *_lbAccount;
@property (weak, nonatomic) IBOutlet UITextField *_tfAccount;

@property (weak, nonatomic) IBOutlet UILabel *_lbPassword;
@property (weak, nonatomic) IBOutlet UITextField *_tfPassword;
@property (weak, nonatomic) IBOutlet UIButton *_btnClear;
@property (weak, nonatomic) IBOutlet UIButton *_btnSave;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *_icWaiting;


- (IBAction)_iconBackClicked:(UIButton *)sender;
- (IBAction)_iconQRCodeClicked:(UIButton *)sender;
- (IBAction)_btnClearPressed:(UIButton *)sender;
- (IBAction)_btnSavePressed:(UIButton *)sender;

@property (nonatomic, strong) WebServices *webService;
@property (weak, nonatomic) IBOutlet UIButton *btnLoginWithPhone;

- (IBAction)btnLoginWithPhonePress:(UIButton *)sender;

@end
