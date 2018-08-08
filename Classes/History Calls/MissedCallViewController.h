//
//  MissedCallViewController.h
//  linphone
//
//  Created by Ei Captain on 7/5/16.
//
//

#import <UIKit/UIKit.h>
#import "BEMCheckBox.h"

@interface MissedCallViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, BEMCheckBoxDelegate>

@property (weak, nonatomic) IBOutlet UILabel *_lbNoCalls;
@property (weak, nonatomic) IBOutlet UITableView *_tbListCalls;


@end
