//
//  RegisterPBXWithPhoneView.h
//  linphone
//
//  Created by lam quang quan on 10/19/18.
//

#import <UIKit/UIKit.h>

@protocol RegisterPBXWithPhoneViewDelegate
- (void)onIconCloseClick;
- (void)onIconQRCodeScanClick;
- (void)onButtonContinuePress;
@end

@interface RegisterPBXWithPhoneView : UIView
@property (weak, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet UIImageView *bgHeader;
@property (weak, nonatomic) IBOutlet UIButton *icClose;
@property (weak, nonatomic) IBOutlet UILabel *lbHeader;
@property (weak, nonatomic) IBOutlet UIButton *icQRCode;
@property (weak, nonatomic) IBOutlet UILabel *lbPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *tfPhoneNumber;
@property (weak, nonatomic) IBOutlet UIButton *btnContinue;
@property (nonatomic,strong) id <NSObject,RegisterPBXWithPhoneViewDelegate> delegate;

- (IBAction)btnContinuePress:(UIButton *)sender;
- (IBAction)icCloseClick:(UIButton *)sender;
- (IBAction)icQRCodeClick:(UIButton *)sender;

- (void)setupUIForView;

@end
