//
//  LanguageViewController.h
//  linphone
//
//  Created by Apple on 5/10/17.
//
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"

@interface LanguageViewController : UIViewController<UICompositeViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (weak, nonatomic) IBOutlet UIButton *_iconBack;
@property (weak, nonatomic) IBOutlet UILabel *_lbHeader;

@property (weak, nonatomic) IBOutlet UITableView *_tbLanguage;

- (IBAction)_iconBackClicked:(UIButton *)sender;

@end
