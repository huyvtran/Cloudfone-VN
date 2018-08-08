//
//  SipContactsViewController.h
//  linphone
//
//  Created by admin on 11/7/17.
//
//

#import <UIKit/UIKit.h>

@interface SipContactsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *_viewSearch;
@property (weak, nonatomic) IBOutlet UIImageView *_imgBgSearch;
@property (weak, nonatomic) IBOutlet UIImageView *_iconSearch;
@property (weak, nonatomic) IBOutlet UITextField *_tfSearch;
@property (weak, nonatomic) IBOutlet UILabel *_lbSearch;
@property (weak, nonatomic) IBOutlet UIButton *_iconClear;

@property (weak, nonatomic) IBOutlet UILabel *_lbNoContacts;
@property (weak, nonatomic) IBOutlet UITableView *_tbContacts;

- (IBAction)_iconClearClicked:(id)sender;

@property (nonatomic, strong) NSMutableDictionary *_contactSections;
@property (nonatomic, strong) NSMutableArray *_searchResults;

@property (weak, nonatomic) IBOutlet UIView *_viewSync;
@property (weak, nonatomic) IBOutlet UIImageView *_imgSync;
@property (weak, nonatomic) IBOutlet UILabel *_lbSync;

@end
