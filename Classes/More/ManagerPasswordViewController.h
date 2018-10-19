//
//  ManagerPasswordViewController.h
//  linphone
//
//  Created by admin on 9/30/18.
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"
#import "WebServices.h"
#import "WebServices.h"

@interface ManagerPasswordViewController : UIViewController<UICompositeViewDelegate, WebServicesDelegate>

@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (weak, nonatomic) IBOutlet UIButton *_icBack;
@property (weak, nonatomic) IBOutlet UILabel *_lbHeader;
@property (weak, nonatomic) IBOutlet UIImageView *bgHeader;

@property (weak, nonatomic) IBOutlet UIView *_viewContent;
@property (weak, nonatomic) IBOutlet UILabel *_lbPassword;
@property (weak, nonatomic) IBOutlet UITextField *_tfPassword;
@property (weak, nonatomic) IBOutlet UILabel *_lbNewPassword;
@property (weak, nonatomic) IBOutlet UITextField *_tfNewPassword;
@property (weak, nonatomic) IBOutlet UILabel *_lbConfirmPassword;
@property (weak, nonatomic) IBOutlet UITextField *_tfConfirmPassword;
@property (weak, nonatomic) IBOutlet UILabel *_lbPasswordDesc;
@property (weak, nonatomic) IBOutlet UIButton *_btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *_btnSave;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *_icWaiting;
@property (weak, nonatomic) IBOutlet UILabel *lbVersion;

- (IBAction)_icBackClicked:(UIButton *)sender;
- (IBAction)_btnCancelPressed:(UIButton *)sender;
- (IBAction)_btnSavePressed:(UIButton *)sender;

@end
