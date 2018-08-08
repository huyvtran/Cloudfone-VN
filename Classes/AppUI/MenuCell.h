//
//  MenuCell.h
//  linphone
//
//  Created by Apple on 4/26/17.
//
//

#import <UIKit/UIKit.h>

@interface MenuCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *_iconImage;
@property (weak, nonatomic) IBOutlet UILabel *_lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *_lbSepa;

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

- (void)setupUIForCell;
- (void)setupCellForPopupView;

@end
