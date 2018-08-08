//
//  DeleteContactPBXPopupView.h
//  linphone
//
//  Created by Apple on 5/12/17.
//
//

#import <UIKit/UIKit.h>

@interface DeleteContactPBXPopupView : UIView

@property (nonatomic, strong) UILabel *_lbTitle;
@property (nonatomic, strong) UILabel *_lbContent;
@property (nonatomic, strong) UIButton *_btnCancel;
@property (nonatomic, strong) UIButton *_btnYes;

- (void)showInView:(UIView *)aView animated:(BOOL)animated;
- (void)fadeOut;

@end
