//
//  iPadSettingsViewController.h
//  linphone
//
//  Created by lam quang quan on 1/14/19.
//

#import <UIKit/UIKit.h>

@interface iPadSettingsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tbSettings;

@end
