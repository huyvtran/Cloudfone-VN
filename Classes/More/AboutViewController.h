//
//  AboutViewController.h
//  linphone
//
//  Created by lam quang quan on 10/26/18.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController<UICompositeViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet UIImageView *bgHeader;
@property (weak, nonatomic) IBOutlet UIButton *icBack;
@property (weak, nonatomic) IBOutlet UILabel *lbHeader;

@property (weak, nonatomic) IBOutlet UIImageView *imgAppLogo;
@property (weak, nonatomic) IBOutlet UILabel *lbVersion;
@property (weak, nonatomic) IBOutlet UIButton *btnCheckForUpdate;


- (IBAction)icBackClick:(UIButton *)sender;
- (IBAction)btnCheckForUpdatePress:(UIButton *)sender;

@end
