//
//  iPadSendLogsViewController.h
//  linphone
//
//  Created by lam quang quan on 1/14/19.
//

#import <UIKit/UIKit.h>

@interface iPadSendLogsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tbLogs;

- (IBAction)btnSendPressed:(UIButton *)sender;
@end
