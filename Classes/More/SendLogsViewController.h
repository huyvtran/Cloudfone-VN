//
//  SendLogsViewController.h
//  linphone
//
//  Created by lam quang quan on 11/27/18.
//

#import <UIKit/UIKit.h>

@interface SendLogsViewController : UIViewController<UICompositeViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet UIImageView *bgHeader;
@property (weak, nonatomic) IBOutlet UIButton *icBack;
@property (weak, nonatomic) IBOutlet UILabel *lbHeader;
@property (weak, nonatomic) IBOutlet UIButton *icSend;

@property (weak, nonatomic) IBOutlet UITableView *tbLogs;

- (IBAction)icBackClicked:(UIButton *)sender;
- (IBAction)icSendClicked:(UIButton *)sender;

@end
