//
//  DrawingViewController.h
//  linphone
//
//  Created by lam quang quan on 1/4/19.
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"

@interface DrawingViewController : UIViewController<UICompositeViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet UIImageView *bgHeader;
@property (weak, nonatomic) IBOutlet UIButton *icBack;
@property (weak, nonatomic) IBOutlet UIButton *icSave;

- (IBAction)icBackClicked:(UIButton *)sender;
- (IBAction)icSaveClicked:(UIButton *)sender;

@end
