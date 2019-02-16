//
//  iPadEditProfileViewController.h
//  linphone
//
//  Created by admin on 2/16/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface iPadEditProfileViewController : UIViewController<UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnAvatar;
@property (weak, nonatomic) IBOutlet UITextField *tfName;
@property (weak, nonatomic) IBOutlet UIButton *btnReset;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;

- (IBAction)btnSavePress:(UIButton *)sender;
- (IBAction)btnResetPress:(UIButton *)sender;
- (IBAction)btnAvatarPress:(UIButton *)sender;

@end

NS_ASSUME_NONNULL_END
