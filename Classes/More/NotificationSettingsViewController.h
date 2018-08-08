//
//  NotificationSettingsViewController.h
//  linphone
//
//  Created by Apple on 4/26/17.
//
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"

@interface NotificationSettingsViewController : UIViewController<UICompositeViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (weak, nonatomic) IBOutlet UIButton *_iconBack;
@property (weak, nonatomic) IBOutlet UILabel *_lbHeader;
@property (weak, nonatomic) IBOutlet UITableView *_tbSettings;

- (IBAction)_iconBackClicked:(UIButton *)sender;
@end
