//
//  PBXContactPopupView.h
//  linphone
//
//  Created by Apple on 5/12/17.
//
//

#import <UIKit/UIKit.h>

@interface PBXContactPopupView : UIView

@property (nonatomic, strong) UIView *_viewHeader;
@property (nonatomic, strong) UILabel *_lbHeader;
@property (nonatomic, strong) UIImageView *_imgLogo;

@property (nonatomic, strong) UITextField *_tfName;
@property (nonatomic, strong) UITextField *_tfNumber;
@property (nonatomic, strong) UIButton *_btnCancel;
@property (nonatomic, strong) UIButton *_btnYes;

- (void)showInView:(UIView *)aView animated:(BOOL)animated;
- (void)fadeOut;

@end
