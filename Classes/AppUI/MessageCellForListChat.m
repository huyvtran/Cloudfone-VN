//
//  MessageCellForListChat.m
//  linphone
//
//  Created by user on 22/7/14.
//
//

#import "MessageCellForListChat.h"

@implementation MessageCellForListChat
@synthesize avatarBuddy, nameBuddy, statusBuddy, imageStatus;

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
}

@end
