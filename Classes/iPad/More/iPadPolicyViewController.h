//
//  iPadPolicyViewController.h
//  linphone
//
//  Created by admin on 1/12/19.
//

#import <UIKit/UIKit.h>

@interface iPadPolicyViewController : UIViewController<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *wvContent;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *icWaiting;

@end
