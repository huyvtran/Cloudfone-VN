//
//  DeleteConversationPopupView.h
//  linphone
//
//  Created by Ei Captain on 4/8/17.
//
//

#import <UIKit/UIKit.h>

@interface DeleteConversationPopupView : UIView

@property (nonatomic, strong) UIButton *_btnDelete;
@property (nonatomic, strong) UIButton *_btnCancel;

@property (nonatomic, retain) UITapGestureRecognizer *_tapGesture;

- (void)showInView:(UIView *)aView animated:(BOOL)animated;

- (void)fadeOut;

@end
