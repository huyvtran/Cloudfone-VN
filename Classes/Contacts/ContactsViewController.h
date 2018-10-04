//
//  ContactsViewController.h
//  linphone
//
//  Created by Ei Captain on 6/30/16.
//
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"

typedef enum eContact{
    eContactPBX,
    eContactAll,
}eContact;

@interface ContactsViewController : UIViewController<UICompositeViewDelegate, UIPageViewControllerDelegate, UIPageViewControllerDataSource, UITextFieldDelegate>

@property (nonatomic, retain) UIPageViewController *_pageViewController;

@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (weak, nonatomic) IBOutlet UIButton *_iconAddNew;
@property (weak, nonatomic) IBOutlet UIButton *_iconAll;
@property (weak, nonatomic) IBOutlet UIButton *_iconPBX;
@property (weak, nonatomic) IBOutlet UIButton *_iconSyncPBXContact;
@property (weak, nonatomic) IBOutlet UITextField *_tfSearch;
@property (weak, nonatomic) IBOutlet UIImageView *imgBackground;
@property (weak, nonatomic) IBOutlet UIButton *_icClearSearch;

- (IBAction)_iconAddNewClicked:(id)sender;
- (IBAction)_iconAllClicked:(id)sender;
- (IBAction)_iconPBXClicked:(UIButton *)sender;
- (IBAction)_iconSyncPBXContactClicked:(UIButton *)sender;
- (IBAction)_icClearSearchClicked:(UIButton *)sender;

@property (nonatomic, strong) NSMutableArray *_listSyncContact;
@property (nonatomic, strong) NSString *_phoneForSync;

@end
