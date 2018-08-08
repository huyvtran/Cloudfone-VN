//
//  NewChatViewController.h
//  linphone
//
//  Created by admin on 1/3/18.
//

#import <UIKit/UIKit.h>
#import "MarqueeLabel.h"
#import "ChatMediaTableViewCell.h"
#import "ChatLeftMediaTableViewCell.h"
#import "ChatPictureDetailsView.h"
#import "SettingPopupView.h"

@interface NewChatViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ChatLeftMediaTableViewCellDelegate, ChatMediaTableViewCellDelegate, SettingPopupViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (weak, nonatomic) IBOutlet UIButton *_iconBack;
@property (weak, nonatomic) IBOutlet UIImageView *_icStatus;
@property (weak, nonatomic) IBOutlet MarqueeLabel *_lbUserName;
@property (weak, nonatomic) IBOutlet MarqueeLabel *_lbStatus;
@property (weak, nonatomic) IBOutlet UIButton *_icSetting;


@property (weak, nonatomic) IBOutlet UIImageView *_bgChat;
@property (weak, nonatomic) IBOutlet UILabel *_lbNoMessage;

@property (weak, nonatomic) IBOutlet UIView *_viewChat;
@property (weak, nonatomic) IBOutlet UITableView *_tbChat;

@property (weak, nonatomic) IBOutlet UIView *_viewFooter;
@property (weak, nonatomic) IBOutlet UIButton *_icCamera;

@property (weak, nonatomic) IBOutlet UIButton *_iconEmotion;

@property (weak, nonatomic) IBOutlet UITextView *_tvMessage;
@property (weak, nonatomic) IBOutlet UIButton *_iconSend;
@property (weak, nonatomic) IBOutlet UIButton *_iconMore;

- (IBAction)_iconSendClicked:(UIButton *)sender;
- (IBAction)_iconEmotionClicked:(UIButton *)sender;
- (IBAction)_iconMoreClicked:(UIButton *)sender;
- (IBAction)_iconBackClicked:(UIButton *)sender;
- (IBAction)_iconCameraClicked:(id)sender;
- (IBAction)_icSettingClicked:(UIButton *)sender;

@end
