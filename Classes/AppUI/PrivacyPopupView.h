//
//  PrivacyPopupView.h
//  linphone
//
//  Created by Hung Ho on 10/11/17.
//
//

#import <UIKit/UIKit.h>

/*  Leo Kelvin
@protocol PrivacyPopupViewDelegate
- (void)testButtonPressed:(UIButton *)sender;
@end
*/

@interface PrivacyPopupView : UIView

//  @property (nonatomic,strong) id <NSObject, PrivacyPopupViewDelegate> delegate;
@property (nonatomic, retain) UIWebView *_webView;
@property (nonatomic, retain) UITapGestureRecognizer *_tapGesture;

- (void)showInView:(UIView *)aView animated:(BOOL)animated;
- (void)fadeOut;

@end
