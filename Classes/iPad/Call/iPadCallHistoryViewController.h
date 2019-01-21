//
//  iPadCallHistoryViewController.h
//  linphone
//
//  Created by lam quang quan on 1/16/19.
//

#import <UIKit/UIKit.h>

@interface iPadCallHistoryViewController : UIViewController<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UIScrollView *scvContent;
@property (weak, nonatomic) IBOutlet UITableView *tbHistory;

@end
