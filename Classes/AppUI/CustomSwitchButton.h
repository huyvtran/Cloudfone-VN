//
//  CustomSwitchButton.h
//  linphone
//
//  Created by lam quang quan on 11/7/18.
//

#import <UIKit/UIKit.h>

@protocol CustomSwitchButtonDelegate
- (void)switchButtonDisabled;
- (void)switchButtonEnabled;
@end

@interface CustomSwitchButton : UIView

@property (nonatomic,strong) id <NSObject, CustomSwitchButtonDelegate> delegate;
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
- (void)setUIForDisableStateWithActionTarget: (BOOL)action;
- (void)setUIForEnableStateWithActionTarget: (BOOL)action;

@property (nonatomic, assign) BOOL isEnabled;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint endPoint;

@end
