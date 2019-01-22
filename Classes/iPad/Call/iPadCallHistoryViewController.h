//
//  iPadCallHistoryViewController.h
//  linphone
//
//  Created by lam quang quan on 1/16/19.
//

#import <UIKit/UIKit.h>

@interface iPadCallHistoryViewController : UIViewController<UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIScrollView *scvContent;

@property (weak, nonatomic) IBOutlet UIView *viewInfo;
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UILabel *lbPhone;
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UIButton *btnCall;
@property (weak, nonatomic) IBOutlet UIButton *btnSendMessage;

@property (weak, nonatomic) IBOutlet UITableView *tbHistory;

- (IBAction)btnCallPressed:(UIButton *)sender;
- (IBAction)btnSendMessagePressed:(UIButton *)sender;

@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *onDate;

@end
