//
//  ChatMediaTableViewCell.m
//  iMessageBubble
//
//  Created by admin on 1/2/18.
//  Copyright © 2018 Prateek Grover. All rights reserved.
//

#import "ChatMediaTableViewCell.h"
#import "ChatCellSettings.h"

@interface ChatMediaTableViewCell ()

@property (strong, nonatomic) UIView *Bubble;
@property (strong, nonatomic) UIView *Main;
@property (strong, nonatomic) UIView *UpCurve;
@property (strong, nonatomic) UIView *DownCurve;
@property (strong, nonatomic) UIView *HidingLayerTop;
@property (strong, nonatomic) UIView *HidingLayerSide;

@property (strong, nonatomic) NSLayoutConstraint *height;
@property (strong, nonatomic) NSLayoutConstraint *width;
@property (strong, nonatomic) NSArray *horizontal;
@property (strong, nonatomic) NSArray *vertical;

@property (assign, nonatomic) CGFloat red;
@property (assign, nonatomic) CGFloat blue;
@property (assign, nonatomic) CGFloat green;

@end

@implementation ChatMediaTableViewCell

@synthesize Bubble;
@synthesize Main;
@synthesize UpCurve;
@synthesize DownCurve;
@synthesize HidingLayerTop;
@synthesize HidingLayerSide;
@synthesize chatUserImage;
@synthesize chatTimeLabel;
@synthesize chatMessageImage;
@synthesize playVideoImage;
@synthesize chatMessageBurn;
@synthesize chatMessageStatus;
@synthesize delegate, messageEvent;
@synthesize isGroup, messageId;

static ChatCellSettings *chatCellSettings = nil;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        chatCellSettings = [ChatCellSettings getInstance];
    });
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor = [UIColor clearColor];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    Bubble = [[UIView alloc] init];
    Bubble.backgroundColor = [UIColor clearColor];
    
    [Bubble setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    Main = [[UIView alloc] init];
    [Main setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    UpCurve = [[UIView alloc] init];
    [UpCurve setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    DownCurve = [[UIView alloc] init];
    [DownCurve setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    HidingLayerTop = [[UIView alloc] init];
    [HidingLayerTop setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    HidingLayerSide = [[UIView alloc] init];
    [HidingLayerSide setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    chatUserImage = [[UIImageView alloc] init];
    [chatUserImage setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    chatTimeLabel = [[UILabel alloc] init];
    [chatTimeLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    chatMessageImage = [[UIImageView alloc] init];
    [chatMessageImage setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    UITapGestureRecognizer *tapOnPicture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTapOnPictureMessage)];
    chatMessageImage.userInteractionEnabled = YES;
    [chatMessageImage addGestureRecognizer: tapOnPicture];
    
    chatMessageBurn = [[UIImageView alloc] init];
    chatMessageBurn.image = [UIImage imageNamed:@"ic_burn"];
    [chatMessageBurn setTranslatesAutoresizingMaskIntoConstraints: NO];
    
    chatMessageStatus = [[UIImageView alloc] init];
    [chatMessageStatus setTranslatesAutoresizingMaskIntoConstraints: NO];
    chatMessageStatus.backgroundColor = [UIColor clearColor];
    
    playVideoImage = [[UIImageView alloc] init];
    playVideoImage.image = [UIImage imageNamed:@"play-button"];
    [playVideoImage setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.contentView addSubview:Bubble];
    
    [Bubble addSubview:DownCurve];
    [Bubble addSubview:HidingLayerTop];
    [Bubble addSubview:Main];
    [Bubble addSubview:UpCurve];
    [Bubble addSubview:HidingLayerSide];
    [Bubble addSubview:chatUserImage];
    
    [Main addSubview:chatTimeLabel];
    [Main addSubview:chatMessageImage];
    [Main addSubview:chatMessageStatus];
    [Main addSubview:chatMessageBurn];
    [Main addSubview:playVideoImage];
    
    chatUserImage.image = [UIImage imageNamed:@"defaultUser.png"];
    chatTimeLabel.text = @"chatTimeLabel";
    chatMessageImage.image = [UIImage imageNamed:@"unloaded"];
    [chatTimeLabel setNumberOfLines:1];
    chatTimeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    //Common placement of the different views
    
    //Setting constraints for Bubble. It should be at a zero distance from top, bottom and 8 distance right hand side of the superview, i.e., self.contentView (The default superview for all tableview cell elements)
    
    
    self.vertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[Bubble]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(Bubble)];
    
    self.width = [NSLayoutConstraint constraintWithItem:Bubble attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:128.0f];
    
    [self.contentView addConstraint:self.width];
    
    
    [self.contentView addConstraints:self.vertical];
    
    // /////////////////////////////////////////////////////////////////////////////////////////////
    
    //Setting constraints for Main block. It contains name, message and time labels. Main should be at a zero distance from bottom and left of its superview, i.e., Bubble
    
    
    self.vertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[Main]-(0)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(Main)];
    
    [Bubble addConstraints:self.vertical];
    
    self.height = [NSLayoutConstraint constraintWithItem:Main attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:32.0f];
    
    self.width = [NSLayoutConstraint constraintWithItem:Main attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:38.0f];
    
    
    [Bubble addConstraints:@[self.height,self.width]];
    
    // /////////////////////////////////////////////////////////////////////////////////////////////
    
    //Setting constraints for UpCurve. It should be at zero distance from Main on left side, -1 distance from bottom and 10 distance from right of the superview, i.e., Bubble. Height and Width should be 32 and 20 respectively
    
    self.height = [NSLayoutConstraint constraintWithItem:UpCurve attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:32.0f];
    
    self.width = [NSLayoutConstraint constraintWithItem:UpCurve attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:20.0f];
    
    
    [Bubble addConstraints:@[self.height,self.width]];
    
    
    self.vertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[UpCurve]-(-1)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(UpCurve)];
    
    [Bubble addConstraints:self.vertical];
    
    // /////////////////////////////////////////////////////////////////////////////////////////////
    
    //Setting constraints for DownCurve. It should be at a 0 distance from right and bottom of superview and -20 distance from Main on the left. Its superview is Bubble. The height and width should be 25 and 50 respectively.
    
    self.height = [NSLayoutConstraint constraintWithItem:DownCurve attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:25.0f];
    
    self.width = [NSLayoutConstraint constraintWithItem:DownCurve attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:50.0f];
    
    
    [Bubble addConstraints:@[self.height,self.width]];
    
    
    self.vertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[DownCurve]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(DownCurve)];
    
    [Bubble addConstraints:self.vertical];
    
    // /////////////////////////////////////////////////////////////////////////////////////////////
    
    //Setting constraints for HidingLayerSide. Superview is Bubble. Right and bottom distances should be 0 and top should be greater than 0. Height and Width are 32 and 15 respectively.
    
    self.height = [NSLayoutConstraint constraintWithItem:HidingLayerSide attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:32.0f];
    
    self.width = [NSLayoutConstraint constraintWithItem:HidingLayerSide attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:15.0f];
    
    
    self.vertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[HidingLayerSide]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(HidingLayerSide)];
    
    [Bubble addConstraints:@[self.height,self.width]];
    
    [Bubble addConstraints:self.vertical];
    
    
    // /////////////////////////////////////////////////////////////////////////////////////////////
    
    //Setting constraints for HidingLayerTop. Superview is Bubble. Right, left and top distances should be 0 and bottom should be 20.
    
    
    self.vertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[HidingLayerTop]-20-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(HidingLayerTop)];
    
    
    [Bubble addConstraints:self.vertical];
    
    // /////////////////////////////////////////////////////////////////////////////////////////////
    
    //Setting constraints for chatUserImage. Its superview is Bubble. It should be at 0 distance from right and bottom of superview and 5 distance from Main. Height and width should be 25 and 25.
    
    self.height = [NSLayoutConstraint constraintWithItem:chatUserImage attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:25.0f];
    
    self.width = [NSLayoutConstraint constraintWithItem:chatUserImage attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:25.0f];
    
    
    self.vertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[chatUserImage]-0-|" options:NSLayoutFormatAlignAllBottom metrics:nil views:NSDictionaryOfVariableBindings(chatUserImage)];
    
    [Bubble addConstraints:@[self.height,self.width]];
    [Bubble addConstraints:self.vertical];
    
    // ////////////////////////////////////////////////////////////////////////////////////////////
    
    //Setting the constraints for chatNameLabel. It should be at 16 distance from right and left of superview, i.e., Main and 8 distance from top and chatMessageImage which is at 8 distance from chatTimeLabel which is at 8 distance from bottom of superview.
    
    self.vertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[chatMessageImage]-8-[chatTimeLabel]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(chatMessageImage,chatTimeLabel)];
    
    [Main addConstraints:self.vertical];
    
    // /////////////////////////////////////////////////////////////////////////////////////////////
    
    self.contentView.backgroundColor = [UIColor clearColor];
    
    
    Bubble.backgroundColor = [UIColor clearColor];
    Main.backgroundColor = [UIColor clearColor];
    
    UpCurve.backgroundColor = [UIColor clearColor];
    UpCurve.hidden = YES;
    
    HidingLayerTop.backgroundColor = [UIColor clearColor];
    HidingLayerTop.hidden = YES;
    
    HidingLayerSide.backgroundColor = [UIColor clearColor];
    HidingLayerSide.hidden = YES;
    
    chatTimeLabel.textAlignment = NSTextAlignmentRight;
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onCellLongGesturePressed:)];
    [Bubble addGestureRecognizer: longGesture];
    
    return self;
}

-  (void)onCellLongGesturePressed:(UILongPressGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateBegan){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"longGestureOnMessage"
                                                            object:messageId];
    }
}

-(void)layoutSubviews
{
//    CGSize size = chatMessageImage.superview.frame.size;
//    [chatMessageImage setCenter:CGPointMake(size.width/2, size.height/2)];
    
    Main.layer.cornerRadius = 10.0f;
    UpCurve.layer.cornerRadius = 10.0f;
    DownCurve.layer.cornerRadius = 25.0f;
    chatUserImage.layer.cornerRadius = 12.5f;
    chatUserImage.layer.masksToBounds = YES;
}

- (void)updateFramesForAuthorType:(AuthorType)type
{
    
    //Setting constraints for Bubble. It should be at a zero distance from top, bottom and 8 distance right hand side of the superview, i.e., self.contentView (The default superview for all tableview cell elements)
    
    self.horizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[Bubble]-8-|" options:NSLayoutFormatDirectionLeftToRight metrics:nil views:NSDictionaryOfVariableBindings(Bubble)];
    
    
    [self.contentView addConstraints:self.horizontal];
    
    // /////////////////////////////////////////////////////////////////////////////////////////////
    
    //Setting constraints for Main block. It contains name, message and time labels. Main should be at a zero distance from bottom and left of its superview, i.e., Bubble
    
    self.horizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[Main]" options:NSLayoutFormatDirectionLeftToRight metrics:nil views:NSDictionaryOfVariableBindings(Main)];
    
    
    [Bubble addConstraints:self.horizontal];
    
    // /////////////////////////////////////////////////////////////////////////////////////////////
    
    //Setting constraints for UpCurve. It should be at zero distance from Main on left side, -1 distance from bottom and 10 distance from right of the superview, i.e., Bubble. Height and Width should be 32 and 20 respectively
    
    
    self.horizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[Main]-0-[UpCurve]-10-|" options:NSLayoutFormatDirectionLeftToRight metrics:nil views:NSDictionaryOfVariableBindings(Main,UpCurve)];
    
    
    [Bubble addConstraints:self.horizontal];
    
    // /////////////////////////////////////////////////////////////////////////////////////////////
    
    //Setting constraints for DownCurve. It should be at a 0 distance from right and bottom of superview and -20 distance from Main on the left. Its superview is Bubble. The height and width should be 25 and 50 respectively.
    
    
    self.horizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[Main]-(-20)-[DownCurve]-(0)-|" options:NSLayoutFormatDirectionLeftToRight metrics:nil views:NSDictionaryOfVariableBindings(Main,DownCurve)];
    
    [Bubble addConstraints:self.horizontal];
    
    // /////////////////////////////////////////////////////////////////////////////////////////////
    
    //Setting constraints for HidingLayerSide. Superview is Bubble. Right and bottom distances should be 0 and top should be greater than 0. Height and Width are 32 and 15 respectively.
    
    self.horizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[HidingLayerSide]-0-|" options:NSLayoutFormatDirectionLeftToRight metrics:nil views:NSDictionaryOfVariableBindings(HidingLayerSide)];
    
    [Bubble addConstraints:self.horizontal];
    
    // /////////////////////////////////////////////////////////////////////////////////////////////
    
    //Setting constraints for HidingLayerTop. Superview is Bubble. Right, left and top distances should be 0 and bottom should be 20.
    
    self.horizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[HidingLayerTop]-0-|" options:NSLayoutFormatDirectionLeftToRight metrics:nil views:NSDictionaryOfVariableBindings(HidingLayerTop)];
    
    
    
    [Bubble addConstraints:self.horizontal];
    
    // /////////////////////////////////////////////////////////////////////////////////////////////
    
    //Setting constraints for chatUserImage. Its superview is Bubble. It should be at 0 distance from right and bottom of superview and 5 distance from Main. Height and width should be 25 and 25.
    
    
    self.horizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[Main]-5-[chatUserImage]-0-|" options:NSLayoutFormatDirectionLeftToRight metrics:nil views:NSDictionaryOfVariableBindings(Main,chatUserImage)];
    
    [Bubble addConstraints:self.horizontal];
    
    // /////////////////////////////////////////////////////////////////////////////////////////////
    
    //Setting the constraints for chatTimeLabel. It should be 16 distance from right and left of superview, i.e., Main.
    
    self.horizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[chatTimeLabel]-8-|" options:NSLayoutFormatDirectionLeftToRight metrics:nil views:NSDictionaryOfVariableBindings(chatTimeLabel)];
    
    [Main addConstraints:self.horizontal];
    
    NSArray *constraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[chatMessageStatus]-5-[chatMessageBurn]-5-[chatTimeLabel]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(chatMessageStatus, chatMessageBurn, chatTimeLabel)];
    
    NSArray *constraint_POS_V  = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[chatMessageStatus]-5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(chatMessageStatus)];
    
    NSArray *tmpWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[chatMessageStatus(16.5)]" options:NSLayoutFormatDirectionLeftToRight metrics:nil views:NSDictionaryOfVariableBindings(chatMessageStatus)];
    
    NSArray *tmpHeight = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[chatMessageStatus(16.5)]" options:NSLayoutFormatDirectionLeftToRight metrics:nil views:NSDictionaryOfVariableBindings(chatMessageStatus)];
    
    [Main addConstraints:constraint_POS_H];
    [Main addConstraints:constraint_POS_V];
    [Main addConstraints:tmpWidth];
    [Main addConstraints:tmpHeight];
    
    
    //  message burn
    NSArray *tmpWidthBurn = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[chatMessageBurn(16.5)]" options:NSLayoutFormatDirectionLeftToRight metrics:nil views:NSDictionaryOfVariableBindings(chatMessageBurn)];
    
    NSArray *tmpHeightBurn = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[chatMessageBurn(16.5)]" options:NSLayoutFormatDirectionLeftToRight metrics:nil views:NSDictionaryOfVariableBindings(chatMessageBurn)];
    
    NSArray *constraint_POS_V_BURN  = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[chatMessageBurn]-5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(chatMessageBurn)];
    
    [Main addConstraints:tmpWidthBurn];
    [Main addConstraints:tmpHeightBurn];
    [Main addConstraints:constraint_POS_V_BURN];
    
    self.vertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[chatMessageImage]-8-[chatTimeLabel]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(chatMessageImage,chatTimeLabel)];
    
    //  play button
    NSArray *tmpWidthPlayVideo = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[playVideoImage(40)]" options:NSLayoutFormatDirectionLeftToRight metrics:nil views:NSDictionaryOfVariableBindings(playVideoImage)];
    
    NSArray *tmpHeighttmpWidthPlayVideo = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[playVideoImage(40)]" options:NSLayoutFormatDirectionLeftToRight metrics:nil views:NSDictionaryOfVariableBindings(playVideoImage)];
    
    [Main addConstraints:tmpWidthPlayVideo];
    [Main addConstraints:tmpHeighttmpWidthPlayVideo];
    
    
    NSLayoutConstraint *xCenterConstraint = [NSLayoutConstraint constraintWithItem:playVideoImage attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:chatMessageImage attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    [Main addConstraint:xCenterConstraint];
    
    NSLayoutConstraint *yCenterConstraint = [NSLayoutConstraint constraintWithItem:playVideoImage attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:chatMessageImage attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    [Main addConstraint:yCenterConstraint];
    
    // /////////////////////////////////////////////////////////////////////////////////////////////
    
    //Setting the constraints for chatMessageImage. It should be 16 distance from right and left of superview, i.e., Main.
    
    self.horizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[chatMessageImage]-8-|" options:NSLayoutFormatDirectionLeftToRight metrics:nil views:NSDictionaryOfVariableBindings(chatMessageImage)];
    
    [Main addConstraints:self.horizontal];
    
    // /////////////////////////////////////////////////////////////////////////////////////////////
    
    if(![chatCellSettings getSenderBubbleTail])
    {
        [DownCurve setHidden:YES];
        [UpCurve setHidden:YES];
    }
    else
    {
        [DownCurve setHidden:NO];
        [UpCurve setHidden:NO];
    }
    
    
    Main.backgroundColor = [chatCellSettings getSenderBubbleColor];
    
    //  DownCurve.backgroundColor = [chatCellSettings getSenderBubbleColor];
    DownCurve.backgroundColor = [UIColor clearColor];
    
    NSArray *textColor = [chatCellSettings getSenderBubbleTextColor];
    chatTimeLabel.textColor = textColor[2];
    
    NSArray *fontWithSize = [chatCellSettings getSenderBubbleFontWithSize];
    chatTimeLabel.font = fontWithSize[2];
    
    NSArray *constraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[chatMessageImage(150)]"
                                                                    options:0 metrics:nil
                                                                      views:NSDictionaryOfVariableBindings(chatMessageImage)];
    [Main addConstraints: constraint_H];
    
    NSArray *constraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[chatMessageImage(150)]"
                                                                    options:0 metrics:nil
                                                                      views:NSDictionaryOfVariableBindings(chatMessageImage)];
    [Main addConstraints: constraint_V];
}

- (void)setAuthorType:(AuthorType)type
{
    _authorType = type;
    [self updateFramesForAuthorType:_authorType];
}

- (void) dismissKeyboard
{
    
}

- (void)whenTapOnPictureMessage {
    [delegate clickOnPictureOfMessage: messageEvent];
}

@end
