//
//  IntroduceViewController.h
//  linphone
//
//  Created by Apple on 4/28/17.
//
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"

@interface IntroduceViewController : UIViewController<UICompositeViewDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (weak, nonatomic) IBOutlet UIImageView *bgHeader;
@property (weak, nonatomic) IBOutlet UIButton *_iconBack;
@property (weak, nonatomic) IBOutlet UILabel *_lbIntroduce;
@property (weak, nonatomic) IBOutlet UIWebView *_wvIntroduce;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *icWaiting;

- (IBAction)_iconBackClicked:(UIButton *)sender;
@end
