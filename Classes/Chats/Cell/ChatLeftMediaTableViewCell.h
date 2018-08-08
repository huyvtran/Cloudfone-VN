//
//  ChatMediaTableViewCell.h
//  iMessageBubble
//
//  Created by admin on 1/2/18.
//  Copyright © 2018 Prateek Grover. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatLeftMediaTableViewCell.h"
#import "MessageEvent.h"

@protocol ChatLeftMediaTableViewCellDelegate<NSObject>
- (void)clickOnPictureOfMessage: (MessageEvent *)messageEvent;
@end

@interface ChatLeftMediaTableViewCell : UITableViewCell

@property (strong, nonatomic) id <NSObject, ChatLeftMediaTableViewCellDelegate> delegate;
@property (strong, nonatomic) UIImageView *chatUserImage;
@property (strong, nonatomic) UILabel *chatTimeLabel;
@property (strong, nonatomic) UIImageView *chatMessageImage;
@property (strong, nonatomic) UIImageView *playVideoImage;
@property (strong, nonatomic) UIImageView *chatMessageBurn;
@property (nonatomic, assign) AuthorType authorType;
@property (strong, nonatomic) MessageEvent *messageEvent;

@property (nonatomic, assign) BOOL isGroup;
@property (nonatomic, strong) NSString *messageId;

@end
