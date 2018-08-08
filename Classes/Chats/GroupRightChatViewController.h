//
//  GroupRightChatViewController.h
//  linphone
//
//  Created by Ei Captain on 7/12/16.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "ChatImagesView.h"
#import "ChatMembersCell.h"

typedef enum eRigtRoom{
//    eRInEar,
    eRExpire,
    eRSaveConversation,
    eRDeleteConversation,
    eRLeave,
    eRChangeBg,
    eRChangeSubject,
}eRigtRoom;

@interface GroupRightChatViewController: UIViewController<UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, ChatImagesViewDelegate, ChatMembersCellDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *_tbContent;


@end
