//
//  TypePhoneCell.h
//  linphone
//
//  Created by Ei Captain on 4/3/17.
//
//

#import <UIKit/UIKit.h>

@interface TypePhoneCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *_imgType;
@property (weak, nonatomic) IBOutlet UILabel *_lbType;
@property (weak, nonatomic) IBOutlet UILabel *_lbSepa;

- (void)setupUIForCell;

@end
