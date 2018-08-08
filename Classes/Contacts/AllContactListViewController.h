//
//  AllContactListViewController.h
//  linphone
//
//  Created by admin on 1/29/18.
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"

@interface AllContactListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UICompositeViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet UIButton *iconBack;
@property (weak, nonatomic) IBOutlet UILabel *lbHeader;

@property (weak, nonatomic) IBOutlet UIView *viewSearch;
@property (weak, nonatomic) IBOutlet UIImageView *bgSearch;
@property (weak, nonatomic) IBOutlet UIImageView *imgSearch;
@property (weak, nonatomic) IBOutlet UITextField *tfSearch;
@property (weak, nonatomic) IBOutlet UILabel *lbSearch;
@property (weak, nonatomic) IBOutlet UIButton *iconClear;
@property (weak, nonatomic) IBOutlet UITableView *tbContacts;
@property (weak, nonatomic) IBOutlet UILabel *lbNoContact;

- (IBAction)iconBackClicked:(UIButton *)sender;
- (IBAction)iconCloseClicked:(UIButton *)sender;

@property (nonatomic, strong) NSMutableDictionary *_contactSections;
@property (nonatomic, strong) NSMutableArray *_searchResults;
@property (nonatomic, strong) NSString *phoneNumber;

@end
