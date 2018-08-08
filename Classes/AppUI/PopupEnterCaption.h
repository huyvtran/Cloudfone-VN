//
//  PopupEnterCaption.h
//  linphone
//
//  Created by user on 7/11/14.
//
//

#import <UIKit/UIKit.h>

@interface PopupEnterCaption : UIView

@property (nonatomic, strong) UIButton *_btnNo;
@property (nonatomic, strong) UIButton *_btnYes;
@property (nonatomic, strong) UITextField *_tfDesc;

@property (nonatomic, retain) UITapGestureRecognizer *_tapGesture;

- (void)showInView:(UIView *)aView animated:(BOOL)animated;
- (void)fadeOut;

@end
