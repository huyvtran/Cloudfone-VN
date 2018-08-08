//
//  SettingCell.h
//  linphone
//
//  Created by Apple on 4/26/17.
//
//

#import <UIKit/UIKit.h>

@interface SettingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *_iconImage;
@property (weak, nonatomic) IBOutlet UILabel *_lbTitle;
@property (weak, nonatomic) IBOutlet UIImageView *_iconArrow;
@property (weak, nonatomic) IBOutlet UILabel *_lbSepa;

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

- (void)setupUIForView;

- (void)hideImageIconForView;

@end
