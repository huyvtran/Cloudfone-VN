//
//  RecordsCallViewController.h
//  linphone
//
//  Created by Ei Captain on 7/5/16.
//
//

#import <UIKit/UIKit.h>
#import "BEMCheckBox.h"

@interface RecordsCallViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, BEMCheckBoxDelegate>

@property (retain, nonatomic) IBOutlet UILabel *_lbNoCalls;
@property (retain, nonatomic) IBOutlet UITableView *_tbRecordCall;

@end
