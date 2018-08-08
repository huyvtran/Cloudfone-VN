//
//  AlbumCell.h
//  linphone
//
//  Created by Ei Captain on 4/11/17.
//
//

#import <UIKit/UIKit.h>
#import "BEMCheckBox.h"

@interface AlbumCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *_imgGroup;
@property (weak, nonatomic) IBOutlet UILabel *_lbName;
@property (weak, nonatomic) IBOutlet BEMCheckBox *_cbSelect;
@property (weak, nonatomic) IBOutlet UILabel *_lbSepa;

- (void)setupUIForCell;

@end
