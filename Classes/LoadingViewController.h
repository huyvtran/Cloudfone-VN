//
//  LoadingViewController.h
//  linphone
//
//  Created by admin on 2/4/18.
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"

@interface LoadingViewController : UIViewController<UICompositeViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *_imgLogo;
@property (weak, nonatomic) IBOutlet UILabel *_lbStarting;
@property (weak, nonatomic) IBOutlet UILabel *_lbCompany;
@property (weak, nonatomic) IBOutlet UIImageView *_imgBottom;

@end
