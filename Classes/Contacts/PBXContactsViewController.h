//
//  PBXContactsViewController.h
//  linphone
//
//  Created by Apple on 5/11/17.
//
//

#import <UIKit/UIKit.h>
#import "WebServices.h"

@interface PBXContactsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, WebServicesDelegate>

@property (weak, nonatomic) IBOutlet UIView *_viewSearch;
@property (weak, nonatomic) IBOutlet UIImageView *_imgBgSearch;
@property (weak, nonatomic) IBOutlet UITextField *_tfSearch;
@property (weak, nonatomic) IBOutlet UIImageView *_iconSearch;
@property (weak, nonatomic) IBOutlet UILabel *_lbSearch;
@property (weak, nonatomic) IBOutlet UIButton *_iconClear;

- (IBAction)_iconClearClicked:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UILabel *_lbContacts;
@property (weak, nonatomic) IBOutlet UITableView *_tbContacts;

@property (weak, nonatomic) IBOutlet UIView *_viewSync;
@property (weak, nonatomic) IBOutlet UIImageView *_imgSync;
@property (weak, nonatomic) IBOutlet UILabel *_lbSync;
@property (weak, nonatomic) IBOutlet UILabel *_lbSepa;

@end
