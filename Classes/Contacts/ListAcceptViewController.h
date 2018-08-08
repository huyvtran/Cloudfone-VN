//
//  ListAcceptViewController.h
//  linphone
//
//  Created by user on 10/14/15.
//
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"

@interface ListAcceptViewController : UIViewController<UICompositeViewDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (weak, nonatomic) IBOutlet UIButton *_iconBack;
@property (weak, nonatomic) IBOutlet UILabel *_lbHeader;
@property (weak, nonatomic) IBOutlet UITableView *_tbListFriends;
@property (weak, nonatomic) IBOutlet UILabel *_lbNoContacts;

@property (nonatomic, strong) NSMutableArray *_listRequest;

- (IBAction)_iconBackClicked:(id)sender;

@end
