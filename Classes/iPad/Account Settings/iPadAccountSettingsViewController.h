//
//  iPadAccountSettingsViewController.h
//  linphone
//
//  Created by lam quang quan on 1/14/19.
//

#import <UIKit/UIKit.h>

@interface iPadAccountSettingsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tbSettings;

@end
