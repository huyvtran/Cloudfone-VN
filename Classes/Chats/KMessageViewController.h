//
//  KMessageViewController.h
//  linphone
//
//  Created by mac book on 30/4/15.
//
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"
#import "AlertPopupView.h"
#import "BEMCheckBox.h"
#import "XMPPOutgoingFileTransfer.h"

@interface KMessageViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UICompositeViewDelegate, AlertPopupViewDelegate, UITextFieldDelegate, BEMCheckBoxDelegate>


@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (weak, nonatomic) IBOutlet UIImageView *_imgSearch;
@property (weak, nonatomic) IBOutlet UIButton *_btnDelete;
@property (weak, nonatomic) IBOutlet UITextField *_tfSearch;
@property (weak, nonatomic) IBOutlet UILabel *_lbSearch;

@property (weak, nonatomic) IBOutlet UIButton *_iconClear;
@property (weak, nonatomic) IBOutlet UIButton *_btnNewMsg;
@property (weak, nonatomic) IBOutlet UIButton *_btnDone;

@property (retain, nonatomic) IBOutlet UITableView *_tbMessage;
@property (weak, nonatomic) IBOutlet UILabel *_lbNoMsg;

- (IBAction)_iconSearchClicked:(id)sender;
- (IBAction)_btnDeletePressed:(UIButton *)sender;
- (IBAction)_btnDonePressed:(UIButton *)sender;
- (IBAction)_btnNewMsgPressed:(UIButton *)sender;

@property (nonatomic, strong) NSMutableArray *listHistoryMessage;
@property (nonatomic, strong) NSMutableArray *listFilterd;
@property (nonatomic, strong) NSMutableArray *_listOptions;

@property (nonatomic, strong) XMPPOutgoingFileTransfer *_fileTransfer;

@end
