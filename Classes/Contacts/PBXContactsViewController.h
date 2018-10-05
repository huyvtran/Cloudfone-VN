//
//  PBXContactsViewController.h
//  linphone
//
//  Created by Apple on 5/11/17.
//
//

#import <UIKit/UIKit.h>

@interface PBXContactsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *_lbContacts;
@property (weak, nonatomic) IBOutlet UITableView *_tbContacts;

@end
