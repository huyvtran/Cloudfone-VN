//
//  NSBubbleData.h
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "KILabel.h"

typedef enum _NSBubbleType
{
    BubbleTypeMine = 0,
    BubbleTypeSomeoneElse = 1
} NSBubbleType;

@interface NSBubbleData : NSObject<AVAudioPlayerDelegate, AVAudioRecorderDelegate, UITextViewDelegate>

@property (assign, nonatomic) NSBubbleType type;
@property (retain, nonatomic, strong) UIView *view;
@property (assign, nonatomic) UIEdgeInsets insets;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, assign) int status;
@property (nonatomic, strong) NSString *idMessage;
@property (nonatomic, assign) int expireTime;
@property (nonatomic, strong) NSString *isRecall;
@property (nonatomic, strong) NSString *descriptionStr;
@property (nonatomic, strong) NSString *typeMessage;
@property (nonatomic, assign) BOOL isGroup;
@property (nonatomic, strong) NSString *userName;

@property (nonatomic, strong) UILabel *lbTimeMsg;
@property (nonatomic, strong) UILabel *lbUserGroup;
@property (nonatomic, strong) UIImageView *imgDelivered;
@property (nonatomic, strong) UIImageView *imgClockView;

@property (nonatomic, strong) UILabel *lbDescForImage;
@property (nonatomic, strong) UILabel *lbAddrForMap;
@property (nonatomic, strong) UIImageView *imgContent;

/* Audio */
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) UIButton *currentPlayButton;
@property (nonatomic, strong) UISlider *timeSlider;
@property (nonatomic, strong) UILabel *lbTime;
@property (nonatomic, assign) BOOL isPaused;

@property (nonatomic, strong) KILabel *lbContent;

@property (nonatomic, strong) NSMutableAttributedString *msgAttributeString;

// Send contact message
@property (nonatomic, strong) UIImageView *contactAvatar;
@property (nonatomic, strong) UILabel *contactName;


@property (nonatomic, strong) NSString *_callnexID;


- (id)initWithText:(NSString *)text type:(NSBubbleType)type time: (NSString *)time status: (int)status idMessage: (NSString *)idMessage withExpireTime: (int) expireTime isRecall: (NSString *)isRecall description: (NSString *)description withTypeMessage: (NSString *)typeMessage isGroup: (BOOL)isGroup ofUser: (NSString *)userName;
+ (id)dataWithText:(NSString *)text type:(NSBubbleType)type time: (NSString *)time status: (int)status idMessage: (NSString *)idMessage withExpireTime: (int) expireTime isRecall: (NSString *)isRecall description: (NSString *)description withTypeMessage: (NSString *)typeMessage isGroup: (BOOL)isGroup ofUser: (NSString *)userName;

- (id)initWithImage:(UIImage *)image type:(NSBubbleType)type time: (NSString *)time status: (int)status idMessage: (NSString *)idMessage withExpireTime: (int) expireTime isRecall: (NSString *)isRecall description: (NSString *)description withTypeMessage: (NSString *)typeMessage isGroup: (BOOL)isGroup ofUser: (NSString *)userName;
+ (id)dataWithImage:(UIImage *)image type:(NSBubbleType)type time: (NSString *)time status: (int)status idMessage: (NSString *)idMessage withExpireTime: (int) expireTime isRecall: (NSString *)isRecall description: (NSString *)description withTypeMessage: (NSString *)typeMessage isGroup: (BOOL)isGroup ofUser: (NSString *)userName;

- (id)initWithView:(UIView *)view type:(NSBubbleType)type insets:(UIEdgeInsets)insets time: (NSString *)time status: (int)status idMessage: (NSString *)idMessage withExpireTime: (int) expireTime isRecall: (NSString *)isRecall description: (NSString *)description withTypeMessage: (NSString *)typeMessage  isGroup: (BOOL)isGroup ofUser: (NSString *)userName;
+ (id)dataWithView:(UIView *)view type:(NSBubbleType)type insets:(UIEdgeInsets)insets time: (NSString *)time status: (int)status idMessage: (NSString *)idMessage withExpireTime: (int) expireTime isRecall: (NSString *)isRecall description: (NSString *)description withTypeMessage: (NSString *)typeMessage  isGroup: (BOOL)isGroup ofUser: (NSString *)userName;

@end
