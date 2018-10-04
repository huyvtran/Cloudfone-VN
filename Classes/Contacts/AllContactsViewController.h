//
//  AllContactsViewController.h
//  linphone
//
//  Created by Ei Captain on 6/30/16.
//
//

#import <UIKit/UIKit.h>

@interface AllContactsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *_tbContacts;
@property (weak, nonatomic) IBOutlet UILabel *_lbNoContacts;

@property (nonatomic, strong) NSMutableDictionary *_contactSections;
@property (nonatomic, strong) NSMutableArray *_searchResults;

@end
