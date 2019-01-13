//
//  iPadAboutViewController.h
//  linphone
//
//  Created by admin on 1/13/19.
//

#import <UIKit/UIKit.h>

@interface iPadAboutViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet UILabel *lbHeader;
@property (weak, nonatomic) IBOutlet UIImageView *imgLogo;
@property (weak, nonatomic) IBOutlet UILabel *lbVersion;
@property (weak, nonatomic) IBOutlet UIButton *btnCheckForUpdate;
@property (weak, nonatomic) IBOutlet UIButton *btnCallHotline;
@property (weak, nonatomic) IBOutlet UIButton *btnYoutube;
@property (weak, nonatomic) IBOutlet UIButton *btnFacebook;

- (IBAction)btnCallHotlinePressed:(UIButton *)sender;
- (IBAction)btnYoutubePressed:(UIButton *)sender;
- (IBAction)btnFacebookPressed:(UIButton *)sender;

@end
