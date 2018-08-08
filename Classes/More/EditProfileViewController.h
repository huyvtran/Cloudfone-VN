//
//  EditProfileViewController.h
//  linphone
//
//  Created by Apple on 4/28/17.
//
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"

@interface EditProfileViewController : UIViewController<UICompositeViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (weak, nonatomic) IBOutlet UIButton *_iconBack;
@property (weak, nonatomic) IBOutlet UILabel *_lbHeader;

@property (weak, nonatomic) IBOutlet UIScrollView *_scrollViewContent;

@property (weak, nonatomic) IBOutlet UIView *_viewInfo;
@property (weak, nonatomic) IBOutlet UIImageView *_imgAvatar;
@property (strong, nonatomic) IBOutlet UITextField *_tfStatus;
@property (weak, nonatomic) IBOutlet UIButton *_btnAvatar;

@property (weak, nonatomic) IBOutlet UIView *_viewContent;
@property (weak, nonatomic) IBOutlet UILabel *_lbFullname;
@property (weak, nonatomic) IBOutlet UITextField *_tfFullname;
@property (weak, nonatomic) IBOutlet UILabel *_lbEmail;
@property (weak, nonatomic) IBOutlet UITextField *_tfEmail;
@property (weak, nonatomic) IBOutlet UILabel *_lbAddress;
@property (weak, nonatomic) IBOutlet UITextView *_tvAddress;

@property (weak, nonatomic) IBOutlet UIButton *_btnSave;

- (IBAction)_iconBackClicked:(UIButton *)sender;
- (IBAction)_btnSavePressed:(UIButton *)sender;
- (IBAction)_btnAvatarPressed:(UIButton *)sender;

@end
