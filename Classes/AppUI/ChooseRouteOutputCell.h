//
//  ChooseRouteOutputCell.h
//  linphone
//
//  Created by admin on 3/21/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChooseRouteOutputCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgType;
@property (weak, nonatomic) IBOutlet UILabel *lbContent;
@property (weak, nonatomic) IBOutlet UIImageView *imgSelected;
@property (weak, nonatomic) IBOutlet UILabel *lbSepa;

@end

NS_ASSUME_NONNULL_END
