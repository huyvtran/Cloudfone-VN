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
    eContactSip,
    eContactAll,
    eContactPBX,
}eContact;

@interface ContactsViewController : UIViewController<UICompositeViewDelegate, UIPageViewControllerDelegate, UIPageViewControllerDataSource, UITextFieldDelegate>

@property (nonatomic, retain) UIPageViewController *_pageViewController;

@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (weak, nonatomic) IBOutlet UIButton *_iconAddNew;
@property (weak, nonatomic) IBOutlet UIButton *_iconODS;
@property (weak, nonatomic) IBOutlet UIButton *_iconAll;
@property (weak, nonatomic) IBOutlet UIButton *_iconPBX;

- (IBAction)_iconAddNewClicked:(id)sender;
- (IBAction)_iconODSClicked:(id)sender;
- (IBAction)_iconAllClicked:(id)sender;
- (IBAction)_iconPBXClicked:(UIButton *)sender;

@property (nonatomic, strong) NSMutableArray *_listSyncContact;
@property (nonatomic, strong) NSString *_phoneForSync;

@end
