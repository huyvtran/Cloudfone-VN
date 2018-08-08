//
//  UIHistoryDetailCell.h
//  linphone
//
//  Created by user on 19/3/14.
//
//

#import <UIKit/UIKit.h>

@interface UIHistoryDetailCell : UITableViewCell
@property (nonatomic, retain) IBOutlet UIView *viewContent;
@property (nonatomic, retain) IBOutlet UIView *viewTitle;
@property (nonatomic, retain) IBOutlet UILabel *lbTitle;
@property (nonatomic, retain) IBOutlet UILabel *lbTime;
@property (nonatomic, retain) IBOutlet UILabel *lbDuration;
@property (nonatomic, retain) IBOutlet UILabel *lbRate;
@property (retain, nonatomic) IBOutlet UIImageView *_imageClock;

- (void)setupUIForCell;

@end
