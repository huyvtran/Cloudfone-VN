//
//  MessageCellForListChat.h
//  linphone
//
//  Created by user on 22/7/14.
//
//

#import <UIKit/UIKit.h>

@interface MessageCellForListChat : UITableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *avatarBuddy;
@property (retain, nonatomic) IBOutlet UILabel *nameBuddy;
@property (retain, nonatomic) IBOutlet UILabel *statusBuddy;    //dong chia se cua tai khoan
@property (retain, nonatomic) IBOutlet UIImageView *imageStatus;

@end
