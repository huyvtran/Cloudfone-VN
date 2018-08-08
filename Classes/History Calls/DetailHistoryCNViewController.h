//
//  DetailHistoryCNViewController.h
//  linphone
//
//  Created by user on 18/3/14.
//
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"

@interface DetailHistoryCNViewController : UIViewController<UICompositeViewDelegate, NSXMLParserDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate >

@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (weak, nonatomic) IBOutlet UIButton *_iconBack;
@property (retain, nonatomic) IBOutlet UILabel *_lbHeader;
@property (weak, nonatomic) IBOutlet UIButton *_iconAddNew;

@property (weak, nonatomic) IBOutlet UIView *_viewInfo;
@property (weak, nonatomic) IBOutlet UIImageView *_imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *_lbName;
@property (weak, nonatomic) IBOutlet UILabel *_lbPhone;

@property (weak, nonatomic) IBOutlet UIView *_viewButton;
@property (weak, nonatomic) IBOutlet UIButton *_iconCall;
@property (weak, nonatomic) IBOutlet UILabel *_lbCall;
@property (weak, nonatomic) IBOutlet UIButton *_iconMessage;
@property (weak, nonatomic) IBOutlet UILabel *_lbMessage;
@property (weak, nonatomic) IBOutlet UIButton *_iconVideo;
@property (weak, nonatomic) IBOutlet UILabel *_lbVideo;
@property (weak, nonatomic) IBOutlet UIButton *_iconBlockUnblock;
@property (weak, nonatomic) IBOutlet UILabel *_lbBlockUnblock;
@property (weak, nonatomic) IBOutlet UITableView *_tbHistory;

- (IBAction)_iconBackClicked:(UIButton *)sender;
- (IBAction)_iconAddNewClicked:(UIButton *)sender;
- (IBAction)_iconCallClicked:(UIButton *)sender;
- (IBAction)_iconMessageClicked:(UIButton *)sender;
- (IBAction)_iconVideoClicked:(UIButton *)sender;
- (IBAction)_iconBlockUnblockClicked:(UIButton *)sender;

@property (nonatomic, retain) NSString *phoneNumber;
@property (strong, nonatomic) UIRefreshControl *_refreshControl;
@property (nonatomic, strong) NSString *_phoneNumberDetail;

- (void)reloadData;
- (void)setPhoneNumberForView:(NSString *)phoneNumberStr;

@end
