//
//  iPadDialerViewController.h
//  linphone
//
//  Created by lam quang quan on 1/11/19.
//

#import <UIKit/UIKit.h>
#import "BEMCheckBox.h"

@interface iPadDialerViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, BEMCheckBoxDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet UIButton *btnAll;
@property (weak, nonatomic) IBOutlet UIButton *btnMissed;

@property (weak, nonatomic) IBOutlet UITableView *tbCalls;
@property (weak, nonatomic) IBOutlet UIImageView *imgNoCalls;
@property (weak, nonatomic) IBOutlet UILabel *lbNoCalls;

- (IBAction)btnAllPress:(UIButton *)sender;
- (IBAction)btnMissedPress:(UIButton *)sender;

@end
