//
//  iPadNewContactViewController.h
//  linphone
//
//  Created by lam quang quan on 1/16/19.
//

#import <UIKit/UIKit.h>

@interface iPadNewContactViewController : UIViewController<UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UIButton *btnAvatar;
@property (weak, nonatomic) IBOutlet UITableView *tbContents;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *icWaiting;

- (IBAction)btnAvatarPressed:(UIButton *)sender;

@property (strong, nonatomic) NSString *currentPhoneNumber;
@property (strong, nonatomic) NSString *currentName;

@end
