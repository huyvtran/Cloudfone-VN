//
//  GroupChatViewController.h
//  linphone
//
//  Created by Ei Captain on 7/12/16.
//
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import "MarqueeLabel.h"
#import "UIBubbleTableView.h"

typedef enum eGroupMView{
    eGroupMVFile,
    eGroupMVAudio,
    eGroupMVContact,
    eGroupMVCall,
    eGroupMVPhoto,
    eGroupMVVideo,
    eGroupMVLocation,
    eGroupMVTransferMoney,
}eGroupMView;

@interface GroupChatViewController : UIViewController<UITextViewDelegate, UIBubbleTableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

//  View header
@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (weak, nonatomic) IBOutlet UIButton *_iconBack;
@property (weak, nonatomic) IBOutlet UIButton *_iconSetting;
@property (weak, nonatomic) IBOutlet UIImageView *_iconStatus;
@property (weak, nonatomic) IBOutlet MarqueeLabel *_lbGroupName;

@property (weak, nonatomic) IBOutlet UILabel *_lbNoMessage;

- (IBAction)_iconBackClicked:(id)sender;
- (IBAction)_iconSettingClicked:(id)sender;

//  View chat
@property (weak, nonatomic) IBOutlet UIImageView *_bgChat;
@property (weak, nonatomic) IBOutlet UIView *_viewChat;
@property (weak, nonatomic) IBOutlet UIBubbleTableView *_tbChat;

@property (weak, nonatomic) IBOutlet UIView *_viewFooter;
@property (weak, nonatomic) IBOutlet UIButton *_iconEmotion;
@property (weak, nonatomic) IBOutlet UIButton *_iconPhoto;
@property (weak, nonatomic) IBOutlet UITextView *_tvMessage;
@property (weak, nonatomic) IBOutlet UIButton *_icCamera;

@property (weak, nonatomic) IBOutlet UIButton *_iconSend;

- (IBAction)_iconSendClicked:(id)sender;
- (IBAction)_iconEmotionClicked:(UIButton *)sender;
- (IBAction)_iconPhotoClicked:(UIButton *)sender;
- (IBAction)_icCameraClicked:(UIButton *)sender;

@property (nonatomic, strong) NSMutableArray *_listHistoryMessage;


@end
