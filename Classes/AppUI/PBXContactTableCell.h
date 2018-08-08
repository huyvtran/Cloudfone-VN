//
//  PBXContactTableCell.h
//  linphone
//
//  Created by admin on 12/14/17.
//

#import <UIKit/UIKit.h>

@interface PBXContactTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *_imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *_lbName;
@property (weak, nonatomic) IBOutlet UILabel *_lbPhone;
@property (weak, nonatomic) IBOutlet UILabel *_lbSepa;

- (void)updateUIForCell;
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

@end
