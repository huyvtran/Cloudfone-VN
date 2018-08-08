//
//  NewContactViewController.h
//  linphone
//
//  Created by Ei Captain on 3/17/17.
//
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"

@interface NewContactViewController : UIViewController<UICompositeViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (weak, nonatomic) IBOutlet UIButton *_iconBack;
@property (weak, nonatomic) IBOutlet UILabel *_lbHeader;
@property (weak, nonatomic) IBOutlet UIButton *_iconDone;

@property (weak, nonatomic) IBOutlet UIScrollView *_scrollViewContent;
@property (weak, nonatomic) IBOutlet UIView *_viewInfo;
@property (weak, nonatomic) IBOutlet UIImageView *_imgAvatar;
@property (weak, nonatomic) IBOutlet UIImageView *_imgChangePicture;
@property (weak, nonatomic) IBOutlet UIButton *_btnAvatar;

@property (weak, nonatomic) IBOutlet UITextField *_tfFullName;
@property (weak, nonatomic) IBOutlet UITextField *_tfCloudFoneID;
@property (weak, nonatomic) IBOutlet UITextField *_tfCompany;

@property (weak, nonatomic) IBOutlet UIImageView *_iconType;
@property (weak, nonatomic) IBOutlet UITextField *_tfType;
@property (weak, nonatomic) IBOutlet UIButton *_btnType;

@property (weak, nonatomic) IBOutlet UIImageView *_iconEmail;
@property (weak, nonatomic) IBOutlet UITextField *_tfEmail;

@property (weak, nonatomic) IBOutlet UITableView *_tbPhones;

- (IBAction)_iconBackClicked:(UIButton *)sender;
- (IBAction)_iconDoneClicked:(UIButton *)sender;
- (IBAction)_btnAvatarPressed:(UIButton *)sender;

@property (strong, nonatomic) NSString *currentSipPhone;
@property (strong, nonatomic) NSString *currentPhoneNumber;
@property (strong, nonatomic) NSString *currentName;

@end
