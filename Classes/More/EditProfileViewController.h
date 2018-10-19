//
//  EditProfileViewController.h
//  linphone
//
//  Created by lam quang quan on 10/17/18.
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"

@interface EditProfileViewController : UIViewController<UICompositeViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet UIImageView *bgHeader;
@property (weak, nonatomic) IBOutlet UIButton *icBack;
@property (weak, nonatomic) IBOutlet UILabel *lbHeader;
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UIImageView *imgChangeAvatar;
@property (weak, nonatomic) IBOutlet UIButton *btnChooseAvatar;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UITextField *tfAccountName;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *icWaiting;

- (IBAction)icBackClick:(UIButton *)sender;
- (IBAction)btnChooseAvatarPress:(UIButton *)sender;
- (IBAction)btnCancelPress:(UIButton *)sender;
- (IBAction)btnSavePress:(UIButton *)sender;

@end
