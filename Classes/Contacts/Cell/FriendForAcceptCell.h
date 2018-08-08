//
//  FriendForAcceptCell.h
//  linphone
//
//  Created by user on 10/14/15.
//
//

#import <UIKit/UIKit.h>

@interface FriendForAcceptCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *_imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *_lbName;
@property (weak, nonatomic) IBOutlet UILabel *_lbNumber;
@property (weak, nonatomic) IBOutlet UIButton *_btnAccept;
@property (weak, nonatomic) IBOutlet UIButton *_btnDecline;
@property (weak, nonatomic) IBOutlet UILabel *_lbSepa;

- (void)setupUIForCell;

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

@end
