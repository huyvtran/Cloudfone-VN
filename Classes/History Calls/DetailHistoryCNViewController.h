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
@property (weak, nonatomic) IBOutlet UIButton *icDelete;

@property (weak, nonatomic) IBOutlet UIImageView *_imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *_lbName;

@property (weak, nonatomic) IBOutlet UITableView *_tbHistory;
@property (weak, nonatomic) IBOutlet UIButton *btnCall;
@property (weak, nonatomic) IBOutlet UIImageView *bgHeader;

- (IBAction)_iconBackClicked:(UIButton *)sender;
- (IBAction)_iconAddNewClicked:(UIButton *)sender;
- (IBAction)icDeleteClick:(UIButton *)sender;

@property (nonatomic, retain) NSString *phoneNumber;
@property (nonatomic, strong) NSString *onDate;

- (void)setPhoneNumberForView:(NSString *)phone andDate: (NSString *)date;
- (IBAction)btnCallPressed:(UIButton *)sender;

@end
