//
//  OptionsCell.h
//  linphone
//
//  Created by Ei Captain on 4/14/17.
//
//

#import <UIKit/UIKit.h>

@interface OptionsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *_imgIcon;
@property (weak, nonatomic) IBOutlet UILabel *_lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *_lbSepa;

- (void)setupUIForCell;

@end
