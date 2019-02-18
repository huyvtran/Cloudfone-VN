//
//  iPadAllContactsListViewController.h
//  linphone
//
//  Created by lam quang quan on 2/18/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface iPadAllContactsListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *viewSearch;
@property (weak, nonatomic) IBOutlet UITextField *tfSearch;
@property (weak, nonatomic) IBOutlet UIButton *iconClear;
@property (weak, nonatomic) IBOutlet UITableView *tbContacts;
@property (weak, nonatomic) IBOutlet UILabel *lbNoContact;

- (IBAction)iconClearSearchClick:(UIButton *)sender;

@property (nonatomic, strong) NSMutableDictionary *_contactSections;
@property (nonatomic, strong) NSMutableArray *_searchResults;
@property (nonatomic, strong) NSString *phoneNumber;

@end

NS_ASSUME_NONNULL_END
