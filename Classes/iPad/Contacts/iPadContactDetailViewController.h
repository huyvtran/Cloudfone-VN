//
//  iPadContactDetailViewController.h
//  linphone
//
//  Created by admin on 1/12/19.
//

#import <UIKit/UIKit.h>
#import "ContactObject.h"

@interface iPadContactDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet MarqueeLabel *lbName;
@property (weak, nonatomic) IBOutlet UIButton *btnCall;
@property (weak, nonatomic) IBOutlet UIButton *btnSendMessage;

- (IBAction)btnSendMessagePressed:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UITableView *tbDetail;
@property (weak, nonatomic) IBOutlet UITableView *tbPBXDetail;

@property (weak, nonatomic) IBOutlet UIView *viewNoContacts;
@property (weak, nonatomic) IBOutlet UILabel *lbNoContacts;
@property (weak, nonatomic) IBOutlet UIImageView *imgNoContacts;

- (IBAction)icCallPBXClicked:(UIButton *)sender;

@property (nonatomic, strong) ContactObject *detailsContact;
@property (nonatomic, strong) PBXContact *detailsPBXContact;

@end
