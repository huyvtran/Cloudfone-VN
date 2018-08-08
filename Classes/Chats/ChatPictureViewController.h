//
//  ChatPictureViewController.h
//  linphone
//
//  Created by user on 23/12/14.
//
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"

@interface ChatPictureViewController : UIViewController<UICompositeViewDelegate, UIAlertViewDelegate>

@property (retain, nonatomic) IBOutlet UIView *_viewHeader;
@property (retain, nonatomic) IBOutlet UIButton *_iconBack;
@property (retain, nonatomic) IBOutlet UILabel *_lbName;
@property (retain, nonatomic) IBOutlet UILabel *_lbImageIndex;

@property (retain, nonatomic) IBOutlet UIButton *_iconCopy;
- (IBAction)_iconBackClicked:(id)sender;
- (IBAction)_iconCopyClicked:(id)sender;
@property (retain, nonatomic) IBOutlet UIImageView *_picture;
@property (retain, nonatomic) IBOutlet UILabel *_lbDescImage;

@property (nonatomic, strong) NSArray *_listPicture;

@property (nonatomic, strong) NSString *_curIdPicture;

- (void)updateImageAfterReceiveIdPicture;

@end
