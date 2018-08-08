//
//  SavePicturePopupView.h
//  linphone
//
//  Created by Hung Ho on 9/7/17.
//
//

#import <UIKit/UIKit.h>

@interface SavePicturePopupView : UIView

@property (nonatomic, strong) UIButton *_btnNo;
@property (nonatomic, strong) UIButton *_btnYes;
@property (nonatomic, strong) UILabel *_lbContent;

@property (nonatomic, retain) UITapGestureRecognizer *_tapGesture;

- (void)showInView:(UIView *)aView animated:(BOOL)animated;
- (void)fadeOut;

@end
