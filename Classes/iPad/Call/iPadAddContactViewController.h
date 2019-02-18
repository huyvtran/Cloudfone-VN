//
//  iPadAddContactViewController.h
//  linphone
//
//  Created by lam quang quan on 2/18/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface iPadAddContactViewController : UIViewController<UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UIButton *btnAvatar;
@property (weak, nonatomic) IBOutlet UITableView *tbContents;
- (IBAction)btnAvatarPressed:(UIButton *)sender;

@property (strong, nonatomic) NSString *currentPhoneNumber;
@property (strong, nonatomic) NSString *currentName;

@end

NS_ASSUME_NONNULL_END
