//
//  PhoneCell.h
//  linphone
//
//  Created by user on 31/8/14.
//
//

#import <UIKit/UIKit.h>

@interface PhoneCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *_iconImage;
@property (retain, nonatomic) IBOutlet UILabel *_stringValue;
@property (weak, nonatomic) IBOutlet UILabel *_lbSepa;

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

- (void)setupUIForCell;
- (void)hideIconForCell;

@end
