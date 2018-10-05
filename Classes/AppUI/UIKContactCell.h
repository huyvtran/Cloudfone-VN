//
//  UIKContactCell.h
//  linphone
//
//  Created by user on 29/5/14.
//
//

#import <UIKit/UIKit.h>

@interface UIKContactCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *lbTitle;
@property (nonatomic, retain) IBOutlet UILabel *lbValue;
@property (weak, nonatomic) IBOutlet UILabel *_lbSepa;

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

@end
