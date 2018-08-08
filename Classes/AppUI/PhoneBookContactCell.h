//
//  PhoneBookContactCell.h
//  linphone
//
//  Created by user on 11/8/14.
//
//

#import <UIKit/UIKit.h>

@interface PhoneBookContactCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (retain, nonatomic) IBOutlet UILabel *name;
@property (retain, nonatomic) IBOutlet UILabel *phone;
@property (weak, nonatomic) IBOutlet UILabel *_lbSepa;
@property (weak, nonatomic) IBOutlet UIButton *_iconChat;

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

- (void)setupUIForCell;

@end
