//
//  ChangePasswordPopupView.h
//  linphone
//
//  Created by admin on 12/17/17.
//

#import <UIKit/UIKit.h>

@interface ChangePasswordPopupView : UIView

@property (nonatomic, strong) UITextField *_tfOldPass;
@property (nonatomic, strong) UITextField *_tfNewPass;
@property (nonatomic, strong) UITextField *_tfConfirmPass;
@property (nonatomic, strong) UILabel *_lbError;
@property (nonatomic, strong) UIView *_viewFooter;
@property (nonatomic, strong) UIButton *_btnCancel;
@property (nonatomic, strong) UIButton *_btnConfirm;

@property (nonatomic, retain) UITapGestureRecognizer *_tapGesture;

- (void)showInView:(UIView *)aView animated:(BOOL)animated;
- (void)fadeOut;
- (void)showContentWithCurrentLanguage;

@end
