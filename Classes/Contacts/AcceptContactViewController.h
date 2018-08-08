//
//  AcceptContactViewController.h
//  linphone
//
//  Created by Apple on 5/20/17.
//
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"

@interface AcceptContactViewController : UIViewController<UICompositeViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (weak, nonatomic) IBOutlet UIButton *_iconBack;
@property (weak, nonatomic) IBOutlet UILabel *_lbHeader;
@property (weak, nonatomic) IBOutlet UIButton *_iconDone;

@property (weak, nonatomic) IBOutlet UIScrollView *_scrollViewContent;
@property (weak, nonatomic) IBOutlet UIView *_viewInfo;
@property (weak, nonatomic) IBOutlet UIImageView *_imgAvatar;
@property (weak, nonatomic) IBOutlet UIImageView *_imgChangePicture;
@property (weak, nonatomic) IBOutlet UIButton *_btnAvatar;

@property (weak, nonatomic) IBOutlet UITextField *_tfFirstName;
@property (weak, nonatomic) IBOutlet UILabel *_lbFirstName;
@property (weak, nonatomic) IBOutlet UILabel *_lbBotFirstName;

@property (weak, nonatomic) IBOutlet UITextField *_tfLastName;
@property (weak, nonatomic) IBOutlet UILabel *_lbLastName;
@property (weak, nonatomic) IBOutlet UILabel *_lbBotLastName;

@property (weak, nonatomic) IBOutlet UITextField *_tfCompany;
@property (weak, nonatomic) IBOutlet UILabel *_lbCompany;
@property (weak, nonatomic) IBOutlet UILabel *_lbBotCompany;

@property (weak, nonatomic) IBOutlet UITextField *_tfCloudFoneID;
@property (weak, nonatomic) IBOutlet UILabel *_lbCloudFoneID;
@property (weak, nonatomic) IBOutlet UILabel *_lbBotID;

@property (weak, nonatomic) IBOutlet UITextField *_tfEmail;
@property (weak, nonatomic) IBOutlet UILabel *_lbEmail;
@property (weak, nonatomic) IBOutlet UILabel *_lbBotEmail;

@property (weak, nonatomic) IBOutlet UITableView *_tbPhones;

@property (weak, nonatomic) IBOutlet UITextView *_tvDescription;
@property (weak, nonatomic) IBOutlet UILabel *_lbDescription;

- (IBAction)_btnAvatarPressed:(UIButton *)sender;
- (IBAction)_iconBackClicked:(UIButton *)sender;
- (IBAction)_iconDoneClicked:(UIButton *)sender;

@end
