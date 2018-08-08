//
//  KSettingViewController.h
//  linphone
//
//  Created by mac book on 10/4/15.
//
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"
#import "AlertPopupView.h"

@interface KSettingViewController : UIViewController<UICompositeViewDelegate, UITableViewDataSource, UITableViewDelegate, AlertPopupViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (retain, nonatomic) IBOutlet UIButton *_iconBack;
@property (retain, nonatomic) IBOutlet UILabel *_lbHeader;
@property (weak, nonatomic) IBOutlet UITableView *_tbSettings;

- (IBAction)_iconBackClicked:(id)sender;

@end
