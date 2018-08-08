//
//  ContactNormalCell.h
//  linphone
//
//  Created by user on 9/29/15.
//
//

#import <UIKit/UIKit.h>

@interface ContactNormalCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *_contactAvatar;
@property (weak, nonatomic) IBOutlet UILabel *_contactName;
@property (weak, nonatomic) IBOutlet UILabel *_lbSepa;

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

- (void)setupUIForCell;

@end
