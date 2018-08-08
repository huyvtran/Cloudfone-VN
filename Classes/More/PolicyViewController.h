//
//  PolicyViewController.h
//  linphone
//
//  Created by Apple on 4/28/17.
//
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"

@interface PolicyViewController : UIViewController<UICompositeViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (weak, nonatomic) IBOutlet UIButton *_iconBack;
@property (weak, nonatomic) IBOutlet UILabel *_lbHeader;
@property (weak, nonatomic) IBOutlet UIWebView *_wvPolicy;

- (IBAction)_iconBackClicked:(UIButton *)sender;

@end
