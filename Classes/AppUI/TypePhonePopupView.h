//
//  TypePhonePopupView.h
//  linphone
//
//  Created by mac book on 7/7/15.
//
//

#import <UIKit/UIKit.h>

@protocol TypePhonePopupViewDelegate
@end

@interface TypePhonePopupView : UIView<UITableViewDelegate, UITableViewDataSource>{
    id <NSObject, TypePhonePopupViewDelegate> delegate;
}
@property (nonatomic, strong) UITableView *_tbContent;
@property (nonatomic, retain) UITapGestureRecognizer *_tapGesture;

- (void)showInView:(UIView *)aView animated:(BOOL)animated;
- (void)fadeOut;

@end
