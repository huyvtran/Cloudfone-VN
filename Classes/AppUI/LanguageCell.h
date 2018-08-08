//
//  LanguageCell.h
//  linphone
//
//  Created by Apple on 5/10/17.
//
//

#import <UIKit/UIKit.h>

@interface LanguageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *_imgFlag;
@property (weak, nonatomic) IBOutlet UILabel *_lbTitle;
@property (weak, nonatomic) IBOutlet UIImageView *_imgSelect;
@property (weak, nonatomic) IBOutlet UILabel *_lbSepa;

- (void)setupUIForCell;

@end
