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
@property (weak, nonatomic) IBOutlet UIImageView *bgHeader;
@property (weak, nonatomic) IBOutlet UILabel *lbHeader;
@property (weak, nonatomic) IBOutlet UIButton *icEdit;
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet MarqueeLabel *lbName;
@property (weak, nonatomic) IBOutlet UIButton *icCallPBX;
@property (weak, nonatomic) IBOutlet UITableView *tbDetail;

@property (weak, nonatomic) IBOutlet UIView *viewNoContacts;
@property (weak, nonatomic) IBOutlet UILabel *lbNoContacts;
@property (weak, nonatomic) IBOutlet UIImageView *imgNoContacts;

- (IBAction)icEditClicked:(UIButton *)sender;
- (IBAction)icCallPBXClicked:(UIButton *)sender;

@property (nonatomic, strong) ContactObject *detailsContact;

@end
