//
//  PhoneBookDetailViewController.h
//  linphone
//
//  Created by lam quang quan on 6/24/19.
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"

NS_ASSUME_NONNULL_BEGIN

@interface PhoneBookDetailViewController : UIViewController<UICompositeViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (retain, nonatomic) IBOutlet UIButton *_iconBack;
@property (retain, nonatomic) IBOutlet UILabel *_lbTitle;
@property (retain, nonatomic) IBOutlet UIButton *_iconEdit;
@property (retain, nonatomic) IBOutlet UIImageView *_imgAvatar;
@property (retain, nonatomic) IBOutlet MarqueeLabel *_lbContactName;

@property (weak, nonatomic) IBOutlet UIImageView *bgHeader;

@property (retain, nonatomic) IBOutlet UITableView *_tbContactInfo;

- (IBAction)_iconBackClicked:(id)sender;
- (IBAction)_iconEditClicked:(id)sender;

@end

NS_ASSUME_NONNULL_END
