//
//  AddParticientsViewController.h
//  linphone
//
//  Created by user on 27/12/14.
//
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"
#import "ContactAddGroupCell.h"

@interface AddParticientsViewController : UIViewController<UICompositeViewDelegate, UITableViewDataSource, UITableViewDelegate, BEMCheckBoxDelegate>


@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (retain, nonatomic) IBOutlet UIButton *_iconBack;
@property (retain, nonatomic) IBOutlet UIButton *_iconDone;
@property (retain, nonatomic) IBOutlet UILabel *_lbTitle;


@property (weak, nonatomic) IBOutlet UIView *_viewSearch;
@property (weak, nonatomic) IBOutlet UIImageView *_bgSearch;
@property (weak, nonatomic) IBOutlet UIImageView *_iconSearch;
@property (weak, nonatomic) IBOutlet UITextField *_tfSearch;
@property (weak, nonatomic) IBOutlet UIButton *_iconClear;
@property (weak, nonatomic) IBOutlet UILabel *_lbSearch;

@property (retain, nonatomic) IBOutlet UITableView *_listTableView;
@property (weak, nonatomic) IBOutlet UILabel *_lbNoContacts;

- (IBAction)_iconClearClicked:(UIButton *)sender;
- (IBAction)_iconBackClicked:(id)sender;
- (IBAction)_iconDoneClicked:(id)sender;

@property (nonatomic, retain) NSMutableDictionary *_contactSections;
@property (nonatomic, retain) NSMutableArray *_listSearch;

//  Biến cho biết add thành viên từ group đang chat hay từ màn hình đang chat với user
@property (nonatomic, assign) BOOL _addFromGroupChat;

//  Hàm cập nhật giá trị cho _addFromGroupChat
- (void)updateValueForController: (BOOL)value;

@end
