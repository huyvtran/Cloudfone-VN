//
//  CustomSwitchButton.h
//  linphone
//
//  Created by lam quang quan on 11/7/18.
//

#import <UIKit/UIKit.h>

@interface CustomSwitchButton : UIView

@property (nonatomic, strong) UILabel *lbBackground;
@property (nonatomic, strong) UIButton *btnEnable;
@property (nonatomic, strong) UIButton *btnDisable;
@property (nonatomic, strong) UIButton *btnThumb;
@property (nonatomic, strong) UILabel *lbState;
@property (nonatomic, assign) BOOL curState;
@property (nonatomic, assign) float border;
@property (nonatomic, assign) float wIcon;
@property (nonatomic, strong) UIColor *bgOn;
@property (nonatomic, strong) UIColor *bgOff;

- (id)initWithState: (BOOL)state frame: (CGRect)frame;

<<<<<<< HEAD
- (void)setUIForDisableStateWithActionTarget: (BOOL)action;
- (void)setUIForEnableStateWithActionTarget: (BOOL)action;
=======
//  Set trạng thái của switch khi đc disable
- (void)setUIForDisableState;

//  Set trạng thái của switch khi đc enable
- (void)setUIForEnableState;
>>>>>>> parent of b9b2b55b... update

@end
