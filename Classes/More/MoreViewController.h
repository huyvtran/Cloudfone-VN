//
//  MoreViewController.h
//  linphone
//
//  Created by user on 1/7/14.
//
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"
#import "WebServices.h"

enum moreValue{
    eEditProfile,
    eSettingsAccount,
    eSettings,
    eFeedback,
    ePolicy,
    eIntroduce,
};

enum stateLogout {
    eRemoveTokenSIP = 1,
    eRemoveTokenPBX
};

@interface MoreViewController : UIViewController<UICompositeViewDelegate, UITableViewDelegate, UITableViewDataSource, WebServicesDelegate>

@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (weak, nonatomic) IBOutlet UILabel *_lbHeader;

@property (weak, nonatomic) IBOutlet UIView *_viewInfo;
@property (weak, nonatomic) IBOutlet UIImageView *_imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *_lbName;
@property (weak, nonatomic) IBOutlet UILabel *_lbEmail;

@property (weak, nonatomic) IBOutlet UITableView *_tbContent;
@property (weak, nonatomic) IBOutlet UIButton *_btnSignOut;


- (IBAction)_btnSignOutPressed:(UIButton *)sender;

@end
