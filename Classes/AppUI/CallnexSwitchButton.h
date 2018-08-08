//
//  CallnexSwitchButton.h
//  linphone
//
//  Created by mac book on 20/7/15.
//
//

#import <UIKit/UIKit.h>

typedef enum typeSwitchButton{
    eSwitchFavoriteList,
    eSwitchWhiteList,
    eSwitchTrukingPBX,
    eSwitchSoundCall,
    eSwitchSoundMsg,
    eSwitchVibrateMsg,
}typeSwitchButton;

@interface CallnexSwitchButton : UIView

@property (nonatomic, strong) UILabel *_lbBackground;
@property (nonatomic, strong) UIButton *_btnEnable;
@property (nonatomic, strong) UIButton *_btnDisable;
@property (nonatomic, strong) UIButton *_btnThumb;
@property (nonatomic, assign) BOOL _status;
@property (nonatomic, assign) int _typeSwitch;

- (id)initWithState: (BOOL)state frame: (CGRect)frame;

//  Set trạng thái của switch khi đc disable
- (void)setUIForDisableState;

//  Set trạng thái của switch khi đc enable
- (void)setUIForEnableState;



@end
