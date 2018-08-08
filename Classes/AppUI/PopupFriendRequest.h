//
//  PopupFriendRequest.h
//  linphone
//
//  Created by Ei Captain on 7/7/16.
//
//

#import <UIKit/UIKit.h>

@protocol PopupFriendRequestDelegate
@end

@interface PopupFriendRequest : UIView<UITextFieldDelegate>{
    id <NSObject, PopupFriendRequestDelegate> delegate;
}

@property (strong, nonatomic) id <NSObject, PopupFriendRequestDelegate> delegate;
@property (nonatomic, strong) UIButton *_btnCancel;
@property (nonatomic, strong) UIButton *_btnSend;
@property (nonatomic, strong) UILabel *_lbHeader;
@property (nonatomic, strong) UITextField *_tfRequest;
@property (nonatomic, strong) NSString *_cloudfoneID;

@property (nonatomic, retain) UITapGestureRecognizer *_tapGesture;

- (void)showInView:(UIView *)aView animated:(BOOL)animated;

- (void)fadeOut;

@end
