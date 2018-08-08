//
//  ChatProfileCell.h
//  linphone
//
//  Created by Ei Captain on 7/6/16.
//
//

#import <UIKit/UIKit.h>
#import "MarqueeLabel.h"

@interface ChatProfileCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *_imgAvatar;
@property (weak, nonatomic) IBOutlet UIImageView *_imgClock;
@property (weak, nonatomic) IBOutlet MarqueeLabel *_lbName;
@property (weak, nonatomic) IBOutlet MarqueeLabel *_lbStatus;
@property (weak, nonatomic) IBOutlet UILabel *_lbSepa;

@property (nonatomic, strong) NSString *_callnexID;
@property (nonatomic, assign) int _idContact;

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

- (void)setupUIForCell;

@end
