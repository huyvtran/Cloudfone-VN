//
//  ShowPictureViewController.h
//  linphone
//
//  Created by user on 7/11/14.
//
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"

@interface ShowPictureViewController : UIViewController<UICompositeViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (retain, nonatomic) IBOutlet UILabel *_titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *_iconBack;
@property (retain, nonatomic) IBOutlet UIButton *_iconDone;
@property (retain, nonatomic) IBOutlet UIImageView *_pictureView;

@property (weak, nonatomic) IBOutlet UILabel *_lbDesc;

- (IBAction)_iconBackClicked:(id)sender;
- (IBAction)_iconDoneClicked:(id)sender;

@end
