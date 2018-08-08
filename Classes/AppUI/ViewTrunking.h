//
//  ViewTrunking.h
//  linphone
//
//  Created by mac book on 17/4/15.
//
//

#import <UIKit/UIKit.h>
#import "CallnexSwitchButton.h"

@interface ViewTrunking : UIView

@property (retain, nonatomic) IBOutlet UILabel *_lbPBX;
@property (strong, nonatomic) CallnexSwitchButton *_switchPBX;

@property (retain, nonatomic) IBOutlet UIView *_viewPBX;

@property (retain, nonatomic) IBOutlet UITextField *_tfPBXID;
@property (retain, nonatomic) IBOutlet UITextField *_tfPBXUsername;
@property (retain, nonatomic) IBOutlet UITextField *_tfPBXPassword;


@property (weak, nonatomic) IBOutlet UIView *_viewFooter;
@property (weak, nonatomic) IBOutlet UIButton *_btnReset;
@property (weak, nonatomic) IBOutlet UIButton *_btnSave;
@property (weak, nonatomic) IBOutlet UIButton *_iconSearchQRCode;

- (void)setupUIForView;
- (void)showContentWithCurrentLanguage;
- (void)showViewPBXForTrunkingView: (float)hTrunkingView;

@end
