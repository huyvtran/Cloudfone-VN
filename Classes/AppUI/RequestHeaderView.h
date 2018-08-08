//
//  RequestHeaderView.h
//  linphone
//
//  Created by Ei Captain on 3/15/17.
//
//

#import <UIKit/UIKit.h>

@interface RequestHeaderView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *_iconAccept;
@property (weak, nonatomic) IBOutlet UILabel *_lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *_lbNotifications;
@property (weak, nonatomic) IBOutlet UIImageView *_imgDetail;

- (void)setupUIForCell;
- (void)updateUIForView;

@end
