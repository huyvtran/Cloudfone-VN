//
//  ChatViewController.h
//  linphone
//
//  Created by Ei Captain on 3/20/17.
//
//

#import <UIKit/UIKit.h>
#import "MarqueeLabel.h"
#import "UIBubbleTableView.h"

typedef enum eTouchType{
    eTextRecallOrExpireTime,
    eImageReceived,
    eImageReceivedWithExpireTime,
    eNormalMessageReceived,
    eMyMessageWithResend,
    eMyMessageNoResend,
    eMyImageSendNoReSend,
    eMyImageSendWithResend,
}eTouchType;

typedef enum eMyMessageResend{
    eMmrResend,
    eMmrCopy,
    eMmrForward,
    eMmrDelete,
    eMmrRecall,
}eMyMessageResend;

typedef enum myMyMessageWithNoResend{
    eMmnrCopy,
    eMmnrForward,
    eMmnrDelete,
    eMmnrRecall,
}myMyMessageWithNoResend;

typedef enum eMoreView{
    eMoreFile,
    eMoreAudio,
    eMoreContact,
    eMoreCall,
    eMorePhoto,
    eMoreVideo,
    eMoreLocation,
    eMoreTransferMoney,
}eMoreView;


@interface ChatViewController : UIViewController<UIBubbleTableViewDataSource, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (weak, nonatomic) IBOutlet UIButton *_iconBack;
@property (weak, nonatomic) IBOutlet UIImageView *_icStatus;
@property (weak, nonatomic) IBOutlet MarqueeLabel *_lbUserName;
@property (weak, nonatomic) IBOutlet MarqueeLabel *_lbStatus;
@property (weak, nonatomic) IBOutlet UIButton *_icSetting;

- (IBAction)_iconBackClicked:(UIButton *)sender;
- (IBAction)_iconSettingsClicked:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIImageView *_bgChat;
@property (weak, nonatomic) IBOutlet UILabel *_lbNoMessage;

@property (weak, nonatomic) IBOutlet UIView *_viewChat;
@property (weak, nonatomic) IBOutlet UIBubbleTableView *_tbChat;

@property (weak, nonatomic) IBOutlet UIView *_viewFooter;
@property (weak, nonatomic) IBOutlet UIButton *_icCamera;

@property (weak, nonatomic) IBOutlet UIButton *_iconEmotion;

@property (weak, nonatomic) IBOutlet UITextView *_tvMessage;
@property (weak, nonatomic) IBOutlet UIButton *_iconSend;
@property (weak, nonatomic) IBOutlet UIButton *_iconMore;

- (IBAction)_iconEmotionClicked:(UIButton *)sender;
- (IBAction)_iconSendClicked:(UIButton *)sender;
- (IBAction)_iconPhotoClicked:(UIButton *)sender;
- (IBAction)_icCameraClicked:(UIButton *)sender;
- (IBAction)_iconMoreClicked:(UIButton *)sender;

@property (nonatomic, assign) int typeTouchOnMessage;

@end
