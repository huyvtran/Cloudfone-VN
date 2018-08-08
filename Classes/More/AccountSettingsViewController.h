//
//  AccountSettingsViewController.h
//  linphone
//
//  Created by Apple on 4/26/17.
//
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"
#import "CallnexSwitchButton.h"
#import "QRCodeReaderDelegate.h"
#import "WebServices.h"

typedef enum eTypePBX{
    eTurnOffPBX = 1,
    eClearPBX = 2,
    eTurnOnPBX = 3,
    eSavePBX = 4,
}eTypePBX;

typedef enum eTypeProxyConfig{
    clearAll = 0,
    loginSIP,
    loginPBX,
}eTypeProxyConfig;

@interface AccountSettingsViewController : UIViewController<UICompositeViewDelegate, QRCodeReaderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, WebServicesDelegate>{
@private
    LinphoneProxyConfig *new_config;
    int number_of_configs_before;
}

@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (weak, nonatomic) IBOutlet UIButton *_iconBack;
@property (weak, nonatomic) IBOutlet UILabel *_lbHeader;

@property (weak, nonatomic) IBOutlet UIScrollView *_scrollViewContent;

@property (weak, nonatomic) IBOutlet UIView *_viewTrunking;
@property (weak, nonatomic) IBOutlet UILabel *_lbTrunking;
@property (weak, nonatomic) IBOutlet UILabel *_lbPBXStatus;

@property (weak, nonatomic) IBOutlet UIImageView *_imgTrunking;

@property (weak, nonatomic) IBOutlet UIView *_viewPBXState;
@property (weak, nonatomic) IBOutlet UILabel *_lbPBXState;
@property (nonatomic, strong) CallnexSwitchButton *_swPBX;

@property (weak, nonatomic) IBOutlet UIView *_viewChangePassword;
@property (weak, nonatomic) IBOutlet UIImageView *_imgChangePassword;
@property (weak, nonatomic) IBOutlet UILabel *_lbChangePassword;

- (IBAction)_iconBackClicked:(UIButton *)sender;

@property (nonatomic, strong) UIView *_viewPBXInfo;
@property (nonatomic, strong) UITextField *_tfPBXInfoID;
@property (nonatomic, strong) UITextField *_tfPBXInfoAcc;
@property (nonatomic, strong) UITextField *_tfPBXInfoPass;
@property (nonatomic, strong) UIView *_viewPBXInfoFooter;
@property (nonatomic, strong) UIButton *_btnPBXClear;
@property (nonatomic, strong) UIButton *_icQRCode;
@property (nonatomic, strong) UIButton *_btnPBXSave;

@end
