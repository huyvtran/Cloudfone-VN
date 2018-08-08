//
//  ChatTableViewCell.h
//  test
//
//  Created by iFlyLabs on 06/04/15.
//  Copyright (c) 2015 iFlyLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageEvent.h"

@protocol GroupChatLeftMediaTableViewCellDelegate<NSObject>
- (void)clickOnPictureOfMessage: (MessageEvent *)messageEvent;
@end

@interface GroupChatLeftMediaTableViewCell : UITableViewCell{
    NSLayoutConstraint *height;
    NSLayoutConstraint *width;
    NSArray *horizontal;
    NSArray *vertical;
    
    CGFloat red;
    CGFloat blue;
    CGFloat green;
}
@property (strong, nonatomic) id <NSObject, GroupChatLeftMediaTableViewCellDelegate> delegate;
@property (strong, nonatomic) UIImageView *chatUserImage;
@property (strong, nonatomic) UILabel *chatNameLabel;
@property (strong, nonatomic) UIImageView *chatMessageImage;
@property (strong, nonatomic) UIImageView *playVideoImage;
@property (strong, nonatomic) UILabel *chatTimeLabel;
@property (nonatomic, assign) AuthorType authorType;
@property (strong, nonatomic) MessageEvent *messageEvent;

@property (nonatomic, strong) NSString *messageId;

@end
