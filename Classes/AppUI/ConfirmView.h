//
//  ConfirmView.h
//  linphone
//
//  Created by Ei Captain on 3/16/17.
//
//

#import <UIKit/UIKit.h>
#import "YBHud.h"

@interface ConfirmView : UIView

@property (weak, nonatomic) IBOutlet UIScrollView *_scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *_imgLogo;
@property (weak, nonatomic) IBOutlet UILabel *_lbContent;
@property (weak, nonatomic) IBOutlet UITextField *_tfConfirm;
@property (weak, nonatomic) IBOutlet UIButton *_btnConfirm;
@property (weak, nonatomic) IBOutlet UIButton *_btnNotReceive;
@property (nonatomic, strong) YBHud *waitingHud;

- (void)setupUIForView;

- (IBAction)_btnConfirmPressed:(UIButton *)sender;

@end
