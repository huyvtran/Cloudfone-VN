//
//  ChatMediaTableViewCell.h
//  iMessageBubble
//
//  Created by admin on 1/2/18.
//  Copyright © 2018 Prateek Grover. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatTableViewCell.h"
#import "MessageEvent.h"

@protocol ChatMediaTableViewCellDelegate<NSObject>
- (void)clickOnPictureOfMessage: (MessageEvent *)messageEvent;
@end

@interface ChatMediaTableViewCell : UITableViewCell

@property (strong, nonatomic) id <NSObject, ChatMediaTableViewCellDelegate> delegate;
@property (strong, nonatomic) UIImageView *chatUserImage;
@property (strong, nonatomic) UILabel *chatTimeLabel;
@property (strong, nonatomic) UIImageView *chatMessageImage;
@property (strong, nonatomic) UIImageView *playVideoImage;
@property (strong, nonatomic) UIImageView *chatMessageStatus;
@property (strong, nonatomic) UIImageView *chatMessageBurn;
@property (nonatomic, assign) AuthorType authorType;
@property (strong, nonatomic) MessageEvent *messageEvent;

@property (nonatomic, assign) BOOL isGroup;
@property (nonatomic, strong) NSString *messageId;

@end
