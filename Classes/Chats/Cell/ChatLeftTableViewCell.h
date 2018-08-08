//
//  ChatTableViewCell.h
//  test
//
//  Created by iFlyLabs on 06/04/15.
//  Copyright (c) 2015 iFlyLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatLeftTableViewCell : UITableViewCell {
    NSLayoutConstraint *height;
    NSLayoutConstraint *width;
    NSArray *horizontal;
    NSArray *vertical;
    
    CGFloat red;
    CGFloat blue;
    CGFloat green;
}

@property (strong, nonatomic) UIImageView *chatUserImage;
@property (strong, nonatomic) UILabel *chatTimeLabel;
@property (strong, nonatomic) UILabel *chatMessageLabel;
@property (strong, nonatomic) UIImageView *chatMessageBurn;
@property (nonatomic, assign) AuthorType authorType;

@property (nonatomic, strong) NSString *messageId;

@end
