//
//  ChatSettingCell.h
//  linphone
//
//  Created by admin on 1/12/18.
//

#import <UIKit/UIKit.h>

@interface ChatSettingCell : UITableViewCell{
    float wContent;
}

@property (weak, nonatomic) IBOutlet UILabel *_lbTitle;
@property (weak, nonatomic) IBOutlet UISwitch *_swAction;
@property (weak, nonatomic) IBOutlet UILabel *_lbSepa;
@property (weak, nonatomic) IBOutlet UIImageView *_imgArrow;

- (void)setupUIForCell;

@end
