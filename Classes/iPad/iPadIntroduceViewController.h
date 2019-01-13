//
//  iPadIntroduceViewController.h
//  linphone
//
//  Created by admin on 1/12/19.
//

#import <UIKit/UIKit.h>

@interface iPadIntroduceViewController : UIViewController<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet UILabel *lbHeader;
@property (weak, nonatomic) IBOutlet UIWebView *wvContent;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *icWaiting;

@end
