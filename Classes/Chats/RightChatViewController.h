//
//  RightChatViewController.h
//  linphone
//
//  Created by Ei Captain on 4/11/16.
//
//

#import <UIKit/UIKit.h>
#import "AlertPopupView.h"
#import "ChatImagesView.h"
#import "ChatMembersCell.h"

typedef enum uChatEnum{
    uViewContactInfoRM,
    uChatImagesRM,
    uBlockContactRM,
    uNewContactRM,
    uExpirationRM,
    uSaveConversationRM,
    uDeleteConversationRM,
    uChangeBackgroundRM,
    uEnableEncryptionRM,
    uUnfriend,
}uChatEnum;

typedef enum groupEnum{
    grChangeNameRM,
    grExpireRM,
    grSaveConversationRM,
    grLeaveRoom,
    grDeleteConversationRM,
    grChangeBackgroundRM,
    grChangeSubjectRM,
}groupEnum;

@interface RightChatViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, AlertPopupViewDelegate, ChatImagesViewDelegate, ChatMembersCellDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *_listTableView;

@property (strong, nonatomic) NSMutableArray *_menuData;
@property (strong, nonatomic) NSMutableArray *_settingListGroup;

@end
