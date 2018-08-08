//
//  ChooseContactsViewController.h
//  linphone
//
//  Created by admin on 1/8/18.
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"
#import "AlertPopupView.h"
#import "strings.h"
#import "OTRConstants.h"
#import "OTRBuddy.h"

@interface ChooseContactsViewController : UIViewController<UICompositeViewDelegate, UITableViewDelegate, UITableViewDataSource, NSXMLParserDelegate, AlertPopupViewDelegate, UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (weak, nonatomic) IBOutlet UIButton *_iconBack;
@property (weak, nonatomic) IBOutlet UILabel *_lbHeader;
@property (weak, nonatomic) IBOutlet UIButton *_iconDone;

@property (weak, nonatomic) IBOutlet UIView *_viewSearch;
@property (weak, nonatomic) IBOutlet UIImageView *_bgSearch;
@property (weak, nonatomic) IBOutlet UIImageView *_imgSearch;
@property (weak, nonatomic) IBOutlet UITextField *_tfSearch;
@property (weak, nonatomic) IBOutlet UIButton *_iconClear;
@property (weak, nonatomic) IBOutlet UILabel *_lbSearch;

@property (retain, nonatomic) IBOutlet UITableView *_tbContents;
@property (weak, nonatomic) IBOutlet UILabel *_lbNoContact;

- (IBAction)_iconBackClicked:(UIButton *)sender;
- (IBAction)_iconDoneClicked:(UIButton *)sender;
- (IBAction)_iconClearClicked:(UIButton *)sender;

@property (nonatomic, retain) NSMutableDictionary *_contactSections;
@property (nonatomic, strong) NSMutableArray *_searchResults;

@property (nonatomic, assign) BOOL _isForwardMessage;
@property (nonatomic, strong) NSString *_idForwardMessage;
@property (nonatomic, assign) BOOL addFromRoomChat;
@property (nonatomic, strong) NSArray *listMembers;


@end
