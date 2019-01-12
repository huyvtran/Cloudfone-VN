//
//  iPadContactsViewController.h
//  linphone
//
//  Created by lam quang quan on 1/11/19.
//

#import <UIKit/UIKit.h>

@interface iPadContactsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet UIImageView *bgHeader;
@property (weak, nonatomic) IBOutlet UIButton *btnPBX;
@property (weak, nonatomic) IBOutlet UIButton *btnAll;
@property (weak, nonatomic) IBOutlet UITextField *tfSearch;
@property (weak, nonatomic) IBOutlet UITableView *tbContacts;
@property (weak, nonatomic) IBOutlet UIButton *icSync;
@property (weak, nonatomic) IBOutlet UIButton *icAddNew;
@property (weak, nonatomic) IBOutlet UILabel *lbNoContacts;

- (IBAction)btnPBXPressed:(UIButton *)sender;
- (IBAction)btnAllPressed:(UIButton *)sender;
- (IBAction)icSyncClicked:(UIButton *)sender;
- (IBAction)icAddNewClicked:(UIButton *)sender;

@end
