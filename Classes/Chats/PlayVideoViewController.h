//
//  PlayVideoViewController.h
//  linphone
//
//  Created by user on 22/12/14.
//
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"
#import "AlertPopupView.h"

@interface PlayVideoViewController : UIViewController<UICompositeViewDelegate, AlertPopupViewDelegate>

@property (retain, nonatomic) IBOutlet UIButton *_iconBack;
@property (retain, nonatomic) IBOutlet UILabel *_lbTitle;

- (IBAction)_iconBackClicked:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *_saveVideoIcon;
- (IBAction)_saveVideoIconClicked:(id)sender;

@end
