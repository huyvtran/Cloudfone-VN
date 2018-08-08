//
//  ChooseAccountCell.h
//  linphone
//
//  Created by Ei Captain on 7/6/16.
//
//

#import <UIKit/UIKit.h>

@interface ChooseAccountCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *_lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *_lbValue;
@property (weak, nonatomic) IBOutlet UIImageView *_imgSelect;
@property (weak, nonatomic) IBOutlet UILabel *_lbSepa;

- (void)setFrameForCell;

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

@end
