//
//  UIHistoryDetailCell.h
//  linphone
//
//  Created by user on 19/3/14.
//
//

#import <UIKit/UIKit.h>

@interface UIHistoryDetailCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *lbTitle;

@property (nonatomic, retain) IBOutlet UIView *viewContent;
@property (weak, nonatomic) IBOutlet UIImageView *imgStatus;
@property (weak, nonatomic) IBOutlet UILabel *lbStateCall;
@property (nonatomic, retain) IBOutlet UILabel *lbTime;
@property (nonatomic, retain) IBOutlet UILabel *lbDuration;

@end
