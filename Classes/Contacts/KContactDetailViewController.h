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

@property (weak, nonatomic) IBOutlet UIView *_viewAction;
@property (retain, nonatomic) IBOutlet UIButton *_btnCall;
@property (weak, nonatomic) IBOutlet UILabel *_lbCall;

@property (retain, nonatomic) IBOutlet UIButton *_btnMessage;
@property (weak, nonatomic) IBOutlet UILabel *_lbMessage;

@property (weak, nonatomic) IBOutlet UIButton *_btnVideoCall;
@property (weak, nonatomic) IBOutlet UILabel *_lbVideoCall;

@property (retain, nonatomic) IBOutlet UIButton *_btnBlock;
@property (weak, nonatomic) IBOutlet UILabel *_lbBlock;

@property (retain, nonatomic) IBOutlet UITableView *_tbContactInfo;

- (IBAction)_iconBackClicked:(id)sender;
- (IBAction)_iconDeleteClicked:(id)sender;
- (IBAction)_iconEditClicked:(id)sender;
- (IBAction)_btnMessagePressed:(id)sender;
- (IBAction)_btnInvitePressed:(id)sender;
- (IBAction)_btnBlockPressed:(id)sender;
- (IBAction)_btnVideoCallPressed:(UIButton *)sender;

@property (nonatomic, strong) ContactObject *detailsContact;

@end
