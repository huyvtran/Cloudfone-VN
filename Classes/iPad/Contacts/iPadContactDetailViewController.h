//
//  iPadContactDetailViewController.h
//  linphone
//
//  Created by admin on 1/12/19.
//

#import <UIKit/UIKit.h>
#import "ContactObject.h"

@interface iPadContactDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet MarqueeLabel *lbName;
@property (weak, nonatomic) IBOutlet UIButton *btnCall;
@property (weak, nonatomic) IBOutlet UIButton *btnSendMessage;

- (IBAction)btnSendMessagePressed:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UITableView *tbDetail;
@property (weak, nonatomic) IBOutlet UITableView *tbPBXDetail;

- (IBAction)icCallPBXClicked:(UIButton *)sender;

@property (nonatomic, strong) ContactObject *detailsContact;
@property (nonatomic, strong) PBXContact *detailsPBXContact;
- (void)registerNotifications;

@end
