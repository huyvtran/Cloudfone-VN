//
//  CallsHistoryViewController.h
//  linphone
//
//  Created by Ei Captain on 7/5/16.
//
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"

typedef enum eTypeHistory{
    eAllCalls,
    eMissedCalls,
    eRecordCalls,
}eTypeHistory;

@interface CallsHistoryViewController : UIViewController<UICompositeViewDelegate, UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic, retain) UIPageViewController *_pageViewController;
@property (nonatomic) NSInteger _vcIndex;

@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (weak, nonatomic) IBOutlet UIButton *_btnEdit;
@property (weak, nonatomic) IBOutlet UILabel *_lbDelete;

@property (weak, nonatomic) IBOutlet UIButton *_iconAll;
@property (weak, nonatomic) IBOutlet UIButton *_iconMissed;
@property (weak, nonatomic) IBOutlet UIButton *_iconRecord;
@property (weak, nonatomic) IBOutlet UIButton *_btnDone;

- (IBAction)_btnEditPressed:(id)sender;
- (IBAction)_iconAllClicked:(id)sender;
- (IBAction)_iconMissedClicked:(id)sender;
- (IBAction)_iconRecordClicked:(id)sender;
- (IBAction)_btnDonePressed:(id)sender;

@end
