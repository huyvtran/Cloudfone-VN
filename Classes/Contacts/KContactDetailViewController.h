//
//  KContactDetailViewController.h
//  linphone
//
//  Created by mac book on 11/5/15.
//
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"
//  Leo Kelvin
//  #import "AlertPopupView.h"
#import "MarqueeLabel.h"
#import "ContactObject.h"

@interface KContactDetailViewController : UIViewController<UICompositeViewDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

//  view header
@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (retain, nonatomic) IBOutlet UIButton *_iconBack;
@property (retain, nonatomic) IBOutlet UILabel *_lbTitle;
@property (retain, nonatomic) IBOutlet UIButton *_iconDelete;
@property (retain, nonatomic) IBOutlet UIButton *_iconEdit;
@property (weak, nonatomic) IBOutlet UIScrollView *_scrollViewContent;

//  view info
@property (weak, nonatomic) IBOutlet UIView *_viewInfo;
@property (retain, nonatomic) IBOutlet UIImageView *_imgAvatar;
@property (retain, nonatomic) IBOutlet MarqueeLabel *_lbContactName;

//  view call

@property (retain, nonatomic) IBOutlet UITableView *_tbContactInfo;

- (IBAction)_iconBackClicked:(id)sender;
- (IBAction)_iconDeleteClicked:(id)sender;
- (IBAction)_iconEditClicked:(id)sender;

@property (nonatomic, strong) ContactObject *detailsContact;

@end
