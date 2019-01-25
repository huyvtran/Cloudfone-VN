//
//  iPadEditContactViewController.h
//  linphone
//
//  Created by lam quang quan on 1/25/19.
//

#import <UIKit/UIKit.h>
#import "ContactObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface iPadEditContactViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet UIButton *btnAvatar;
@property (weak, nonatomic) IBOutlet UIImageView *imgChange;
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UITextField *tfName;
@property (weak, nonatomic) IBOutlet UITextField *tfEmail;
@property (weak, nonatomic) IBOutlet UITextField *tfCompany;
@property (weak, nonatomic) IBOutlet UITableView *tbPhone;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *icWaiting;

@property (nonatomic, strong) UIPopoverController *popOver;

@property (nonatomic, strong) ContactObject *detailsContact;
@property (nonatomic, assign) int idContact;
@property (nonatomic, strong) NSString *curPhoneNumber;
- (IBAction)btnAvatarPressed:(UIButton *)sender;

@end

NS_ASSUME_NONNULL_END
