//
//  AllContactsViewController.h
//  linphone
//
//  Created by Ei Captain on 6/30/16.
//
//

#import <UIKit/UIKit.h>

@interface AllContactsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *_viewSearch;
@property (weak, nonatomic) IBOutlet UIImageView *_imgBgSearch;
@property (weak, nonatomic) IBOutlet UITextField *_tfSearch;
@property (weak, nonatomic) IBOutlet UIImageView *_iconSearch;
@property (weak, nonatomic) IBOutlet UILabel *_lbSearch;
@property (weak, nonatomic) IBOutlet UIButton *_iconClear;

@property (weak, nonatomic) IBOutlet UITableView *_tbContacts;
@property (weak, nonatomic) IBOutlet UILabel *_lbNoContacts;

- (IBAction)_iconClearClicked:(id)sender;

@property (nonatomic, strong) NSMutableDictionary *_contactSections;
@property (nonatomic, strong) NSMutableArray *_searchResults;

@end
