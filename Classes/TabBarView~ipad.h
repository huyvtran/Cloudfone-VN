//
//  TabBarView~ipad.h
//  linphone
//
//  Created by lam quang quan on 10/31/18.
//

#import "TPMultiLayoutViewController.h"

@interface TabBarView_ipad : TPMultiLayoutViewController

@property (weak, nonatomic) IBOutlet UIButton *historyButton;
@property (weak, nonatomic) IBOutlet UIButton *contactsButton;
@property (weak, nonatomic) IBOutlet UIButton *dialerButton;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;

- (IBAction)historyButtonPress:(UIButton *)sender;
- (IBAction)contactsButtonPress:(UIButton *)sender;
- (IBAction)dialerButtonPress:(UIButton *)sender;
- (IBAction)moreButtonPress:(UIButton *)sender;

@end
