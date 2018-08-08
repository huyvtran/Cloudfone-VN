//
//  NSBubbleData.m
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import "NSBubbleData.h"
#import <QuartzCore/QuartzCore.h>
#import "OTRConstants.h"
#import "NSDatabase.h"
#import "PhoneMainView.h"
#import "UIImageView+WebCache.h"

@implementation NSBubbleData{
    HMLocalization *localization;
    int durationTime;
    NSTimer *firedTime;
}

#pragma mark - Properties
@synthesize type = _type;
@synthesize view = _view;
@synthesize insets = _insets;
@synthesize time = _time;
@synthesize status = _status;
@synthesize expireTime = _expireTime;
@synthesize isRecall = _isRecall;
@synthesize description = _description;
@synthesize typeMessage = _typeMessage;
@synthesize isGroup = _isGroup;
@synthesize userName = _userName;
@synthesize lbTimeMsg = _lbTimeMsg;
@synthesize lbUserGroup = _lbUserGroup;
@synthesize imgDelivered = _imgDelivered;
@synthesize imgClockView = _imgClockView;
@synthesize imgContent = _imgContent;
@synthesize lbDescForImage = _lbDescForImage;
@synthesize lbAddrForMap = _lbAddrForMap;

@synthesize player = _player;
@synthesize currentPlayButton = _currentPlayButton;
@synthesize timeSlider = _timeSlider;
@synthesize lbTime = _lbTime;
@synthesize isPaused = _isPaused;
@synthesize lbContent = _lbContent;
@synthesize msgAttributeString = _msgAttributeString;

@synthesize contactAvatar = _contactAvatar;
@synthesize contactName = _contactName;

@synthesize _callnexID;

#pragma mark - Lifecycle

#if !__has_feature(objc_arc)
- (void)dealloc
{
    [_view release];
    _view = nil;
    [super dealloc];
}
#endif

#pragma mark - Text bubble

const UIEdgeInsets textInsetsMine = {5, 10, 11, 17};
const UIEdgeInsets textInsetsSomeone = {5, 15, 11, 10};

+ (id)dataWithText:(NSString *)text type:(NSBubbleType)type time:(NSString *)time status:(int)status idMessage: (NSString *)idMessage withExpireTime:(int)expireTime isRecall:(NSString *)isRecall description: (NSString *)description withTypeMessage:(NSString *)typeMessage isGroup: (BOOL)isGroup ofUser: (NSString *)userName
{
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithText:text type:type] autorelease];
#else
    return [[NSBubbleData alloc] initWithText:text type:type time:time status:status idMessage:idMessage withExpireTime:expireTime isRecall:isRecall description:description withTypeMessage:typeMessage isGroup: (BOOL)isGroup ofUser: (NSString *)userName];
#endif
}

- (id)initWithText:(NSString *)text type:(NSBubbleType)type time:(NSString *)time status:(int)status idMessage: (NSString *)idMessage withExpireTime:(int)expireTime isRecall:(NSString *)isRecall description: (NSString *)description withTypeMessage:(NSString *)typeMessage isGroup: (BOOL)isGroup ofUser: (NSString *)userName
{
    localization = [HMLocalization sharedInstance];
    
    UIView *parentView = [[UIView alloc] init];
    
    // Nếu là message recall thì font nhỏ hơn
    UIFont *font;
    if ([isRecall isEqualToString:@"YES"]) {
        font = [UIFont italicSystemFontOfSize: 12.0];
        if (type == BubbleTypeSomeoneElse) {
            _msgAttributeString = [[NSMutableAttributedString alloc] initWithString: [localization localizedStringForKey:text_message_received_recall]];
        }else{
            _msgAttributeString = [[NSMutableAttributedString alloc] initWithString: [localization localizedStringForKey:text_message_sent_recall]];
        }
        [_msgAttributeString addAttribute:NSFontAttributeName
                                    value:font range:NSMakeRange(0, _msgAttributeString.length)];
        [_msgAttributeString addAttribute:NSForegroundColorAttributeName
                                    value:[UIColor grayColor]
                                    range:NSMakeRange(0, _msgAttributeString.length)];
    }else{
        font = [UIFont systemFontOfSize:20.0];
        _msgAttributeString = [AppUtils convertMessageStringToEmojiString: text];
    }
    
    // Kiểm tra độ dài của text nội dung và text thời gian, và gán chiều dài theo text nào dài hơn
    CGSize size = [(_msgAttributeString.string ? _msgAttributeString.string : @"") sizeWithFont:font
                                  constrainedToSize:CGSizeMake(255, 9999)
                                      lineBreakMode:NSLineBreakByWordWrapping];
    
    UIFont *fontlbTime = [UIFont systemFontOfSize:11.0];
    CGSize sizelbTime = [(time ? time : @"") sizeWithFont:fontlbTime
                                  constrainedToSize:CGSizeMake(255, CGFLOAT_MAX)
                                      lineBreakMode:NSLineBreakByWordWrapping];

    float totalWidth = sizelbTime.width;
    // Nếu có expire time thì cộng thêm width vào label time
    if (expireTime > 0) {
        totalWidth = totalWidth + 20;
    }
    if (type == BubbleTypeMine) {
        totalWidth = totalWidth + 25;
    }
    
    if (size.width > 255) {
        size.width = 255;
    }
    
    // Chiều cao ban đầu cho lbContent
    float tmpWidth;
    if (totalWidth < size.width) {
        tmpWidth = size.width;
    }else{
        tmpWidth = totalWidth;
    }
    
    // Nếu size quá nhỏ thì cho độ lớn tối thiểu là 70px
    if (tmpWidth < 70) {
        tmpWidth = 70;
    }
    
    // set frame cho parent view
    [parentView setFrame: CGRectMake(0, 0, tmpWidth+8, 4+size.height+4+sizelbTime.height+3)];
    
    // Hiển thị tên người gửi trong group
    if (isGroup) {
        _lbUserGroup = [[UILabel alloc] initWithFrame:CGRectMake(4, 2, parentView.frame.size.width-8, 12)];
        [_lbUserGroup setFont: [AppUtils fontRegularWithSize: 11.0]];
        [_lbUserGroup setTextColor:[UIColor colorWithRed:(50/255.0) green:(50/255.0)
                                                    blue:(50/255.0) alpha:1.0]];
        [_lbUserGroup setText: userName];
        [_lbUserGroup setBackgroundColor:[UIColor clearColor]];
        [parentView addSubview: _lbUserGroup];
        
        // nội dung của message
        _lbContent = [[KILabel alloc] initWithFrame: CGRectMake(4, _lbUserGroup.frame.origin.y+_lbUserGroup.frame.size.height, parentView.frame.size.width-6, size.height)];
    }else{
        _lbUserGroup = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _lbContent.frame.size.width, 0)];
        [parentView addSubview: _lbUserGroup];
        
        // nội dung của message
        _lbContent = [[KILabel alloc] initWithFrame: CGRectMake(4, 5, parentView.frame.size.width-6, size.height)];
    }
    
    
    [_lbContent setBackgroundColor:[UIColor whiteColor]];
    [_lbContent setAttributedText: _msgAttributeString];
    [_lbContent setTextColor:[UIColor blackColor]];
    [_lbContent setNumberOfLines: 0];
    [_lbContent sizeToFit];
    
    [parentView addSubview: _lbContent];
    
    if (tmpWidth > _lbContent.frame.size.width) {
        if (isGroup) {
            [parentView setFrame: CGRectMake(0, 0, tmpWidth+8, 4+(_lbUserGroup.frame.size.height-5)+_lbContent.frame.size.height+4+sizelbTime.height+3)];
        }else{
            [parentView setFrame: CGRectMake(0, 0, tmpWidth+8, 4+_lbUserGroup.frame.size.height+_lbContent.frame.size.height+4+sizelbTime.height+3)];
        }
    }else{
        if (isGroup) {
            [parentView setFrame: CGRectMake(0, 0, _lbContent.frame.size.width+8, 4+(_lbUserGroup.frame.size.height-5)+_lbContent.frame.size.height+4+sizelbTime.height+3)];
        }else{
            [parentView setFrame: CGRectMake(0, 0, _lbContent.frame.size.width+8, 4+_lbUserGroup.frame.size.height+_lbContent.frame.size.height+4+sizelbTime.height+3)];
        }
    }
    
    // Khởi tạo label thời gian
    _lbTimeMsg = [[UILabel alloc] init];
    [_lbTimeMsg setText: time];
    [_lbTimeMsg setBackgroundColor:[UIColor clearColor]];
    [_lbTimeMsg setFont: [AppUtils fontRegularWithSize: 12.0]];
    [_lbTimeMsg setTextColor:[UIColor darkGrayColor]];
    
    // Hiển thị chi tiết tin nhắn theo từng loại
    if ([typeMessage isEqualToString: typeTextMessage]) {
        if (type == BubbleTypeSomeoneElse) {
            [_lbTimeMsg setTextAlignment: NSTextAlignmentLeft];
            if (expireTime > 0) {
                _imgClockView = [[UIImageView alloc] initWithFrame: CGRectMake(_lbContent.frame.origin.x, _lbContent.frame.origin.y+_lbContent.frame.size.height+3, 13, 13)];
                [_imgClockView setImage:[UIImage imageNamed:@"chat_clock.png"]];
                [parentView addSubview: _imgClockView];
                
                [_lbTimeMsg setFrame: CGRectMake(_imgClockView.frame.origin.x+_imgClockView.frame.size.width+3, _imgClockView.frame.origin.y+(_imgClockView.frame.size.height-sizelbTime.height)/2+1, sizelbTime.width, sizelbTime.height)];
            }else{
                [_lbTimeMsg setFrame: CGRectMake(_lbContent.frame.origin.x, _lbContent.frame.origin.y+_lbContent.frame.size.height+3, sizelbTime.width, sizelbTime.height)];
            }
        }else {
            [_lbTimeMsg setFrame:CGRectMake(parentView.frame.size.width-sizelbTime.width-5, _lbContent.frame.origin.y+_lbContent.frame.size.height+3, sizelbTime.width, sizelbTime.height)];
            [_lbTimeMsg setTextAlignment: NSTextAlignmentRight];
            
            // Add image delivered
            _imgDelivered = [[UIImageView alloc] initWithFrame: CGRectMake(_lbTimeMsg.frame.origin.x - 17, _lbTimeMsg.frame.origin.y+(sizelbTime.height-11)/2, 15, 11)];
            if (status == 0) {
                [_imgDelivered setImage:[UIImage imageNamed:@"chat_message_not_delivered.png"]];
            }else if (status == 1){
                [_imgDelivered setImage:[UIImage imageNamed:@"chat_message_inprogress.png"]];
            }else{
                [_imgDelivered setImage:[UIImage imageNamed:@"chat_message_delivered.png"]];
            }
            [parentView addSubview: _imgDelivered];
            
            // Khởi tạo image expire time
            if (expireTime > 0) {
                _imgClockView = [[UIImageView alloc] initWithFrame: CGRectMake(_imgDelivered.frame.origin.x-15, _imgDelivered.frame.origin.y-(13-_imgDelivered.frame.size.height)/2, 13, 13)];
                [_imgClockView setImage:[UIImage imageNamed:@"chat_clock.png"]];
                [parentView addSubview: _imgClockView];
            }
        }
        [parentView addSubview: _lbTimeMsg];
    }else if ([typeMessage isEqualToString: descriptionMessage]){
        [parentView setFrame: CGRectMake(0, 0, SCREEN_WIDTH, 20)];
        [_lbContent setFrame: CGRectMake(0, 0, SCREEN_WIDTH, 20)];
        [_lbContent setTextAlignment: NSTextAlignmentCenter];
        [parentView addSubview: _lbContent];
    }
    
#if !__has_feature(objc_arc)
    [label autorelease];
#endif
    [_lbTimeMsg setBackgroundColor:[UIColor clearColor]];
    [_lbTimeMsg sizeToFit];
    [_lbContent setBackgroundColor:[UIColor clearColor]];
    [parentView addSubview: _lbContent];
    [parentView setBackgroundColor:[UIColor clearColor]];
    
    UIEdgeInsets insets = (type == BubbleTypeMine ? textInsetsMine : textInsetsSomeone);
    return [self initWithView:parentView type:type insets:insets time:time status:status idMessage:idMessage withExpireTime:expireTime isRecall:isRecall description:description withTypeMessage:typeMessage  isGroup: (BOOL)isGroup ofUser: (NSString *)userName];
}

#pragma mark - Image bubble

const UIEdgeInsets imageInsetsMine = {11, 13, 16, 22};
const UIEdgeInsets imageInsetsSomeone = {11, 18, 16, 14};

+ (id)dataWithImage:(UIImage *)image type:(NSBubbleType)type time:(NSString *)time status:(int)status idMessage: (NSString *)idMessage withExpireTime:(int)expireTime isRecall:(NSString *)isRecall description:(NSString *)description withTypeMessage:(NSString *)typeMessage isGroup: (BOOL)isGroup ofUser: (NSString *)userName
{
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithImage:image type:type] autorelease];
#else
    return [[NSBubbleData alloc] initWithImage:image type:type time:time status:status idMessage:idMessage withExpireTime:expireTime isRecall:isRecall description:description withTypeMessage:typeMessage isGroup: (BOOL)isGroup ofUser: (NSString *)userName];
#endif    
}

- (id)initWithImage:(UIImage *)image type:(NSBubbleType)type time:(NSString *)time status:(int)status idMessage: (NSString *)idMessage withExpireTime:(int)expireTime isRecall:(NSString *)isRecall description:(NSString *)description withTypeMessage:(NSString *)typeMessage isGroup: (BOOL)isGroup ofUser: (NSString *)userName
{
    CGSize size = image.size;
    if (size.width > 220) {
        size.height /= (size.width / 220);
        size.width = 220;
    }
    float sizeImage = 200.0;
    float totalHeight = sizeImage;
    
    UIFont *fontlbTime = [UIFont systemFontOfSize: 11.0];
    CGSize sizelbTime = [(time ? time : @"") sizeWithFont:fontlbTime
                                        constrainedToSize:CGSizeMake(sizeImage, 9999)
                                            lineBreakMode:NSLineBreakByWordWrapping];
    
    UIFont *fontlbDesc = [UIFont systemFontOfSize:11.0];
    CGSize sizelbDesc;
    CGSize sizelbAddr;
    
    NSArray *infos = nil;
    if ([typeMessage isEqualToString: locationMessage]) {
        infos = [description componentsSeparatedByString:@"|"];
        if (infos.count >= 4) {
            sizelbDesc = [([infos objectAtIndex: 3] ? [infos objectAtIndex:3] : @"")
                          sizeWithFont:fontlbDesc constrainedToSize:CGSizeMake(sizeImage, 9999)
                          lineBreakMode:NSLineBreakByWordWrapping];
            // Nếu location description
            if (![[infos objectAtIndex: 3] isEqualToString:@""]) {
                totalHeight = totalHeight + sizelbDesc.height + 4;
            }
            sizelbAddr = [([infos objectAtIndex: 2] ? [infos objectAtIndex:2] : @"")
                          sizeWithFont:fontlbDesc constrainedToSize:CGSizeMake(sizeImage, 9999)
                          lineBreakMode:NSLineBreakByWordWrapping];
        }
    }else{
        sizelbDesc = [(description ? description : @"")
                      sizeWithFont:fontlbDesc constrainedToSize:CGSizeMake(sizeImage, 9999)
                      lineBreakMode:NSLineBreakByWordWrapping];
    }
    
    // set chiều cao cho parentView
    if (![description isEqualToString:@""]) {
        if ([typeMessage isEqualToString: locationMessage]) {
            totalHeight = totalHeight + 4 + sizelbAddr.height;
        }else{
            totalHeight = totalHeight + 4 + sizelbDesc.height;
        }
    }else{
        if (expireTime > 0) {
            totalHeight = 3 + totalHeight;
        }
    }
    totalHeight = totalHeight + 8; // 8: margin top va bottom
    totalHeight = totalHeight + sizelbTime.height + 4;  // cong them height label time
    
    // image anh
    _imgContent = [[UIImageView alloc] initWithFrame:CGRectMake(4, 4, sizeImage, sizeImage)];
    [_imgContent.layer setCornerRadius: 5.0];
    [_imgContent.layer setMasksToBounds: TRUE];
    
    // Kiểm tra nếu image nhận có expire time thì không hiển thị lên
    if ([typeMessage isEqualToString: imageMessage] || [typeMessage isEqualToString:videoMessage]) {
        if (expireTime > 0 && type == BubbleTypeSomeoneElse) {
            [_imgContent setImage: [UIImage imageNamed:@"unloaded.png"]];
        }else{
            if (image == nil) {
                NSString *linkImage = [NSDatabase getLinkImageOfMessage: idMessage];
                NSString *urlStr = [NSString stringWithFormat:@"%@/%@", link_picutre_chat_group, linkImage];
                [_imgContent sd_setImageWithURL:[NSURL URLWithString: urlStr]
                               placeholderImage:[UIImage imageNamed:@"unloaded.png"]];
            }else{
                [_imgContent setImage: [self squareImageWithImage:image scaledToSize:CGSizeMake(sizeImage, sizeImage)]];
            }
        }
    }else if([typeMessage isEqualToString: locationMessage]){
        [_imgContent setImage: [self squareImageWithImage:image scaledToSize:CGSizeMake(sizeImage, sizeImage)]];
        UIImageView *locationImage = [[UIImageView alloc] initWithFrame:CGRectMake((sizeImage-30)/2, (sizeImage-38)/2-15, 30, 38)];
        
        // Button to go location view
        UIButton *tmpButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, sizeImage, sizeImage)];
        [tmpButton.titleLabel setText: idMessage];
        [tmpButton.titleLabel setTextColor:[UIColor clearColor]];
        
        if (type == BubbleTypeSomeoneElse) {
            /*  Leo Kelvin
            if ([LinphoneAppDelegate sharedInstance].userImage == nil) {
                [locationImage setImage:[UIImage imageNamed:@"marker_default_avatar.png"]];
            }else{
                [locationImage setImage:[UIImage imageNamed:@"marker_none_avatar_small.png"]];
                UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(4, 4, 22, 22)];
                [avatarView.layer setCornerRadius: 11.0];
                [avatarView setImage: [LinphoneAppDelegate sharedInstance].userImage];
                [avatarView setClipsToBounds: YES];
                [locationImage addSubview: avatarView];
            }
             */
        }else{
            //  set avatar
            NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:userAvatar];
            if (dict == nil) {
                [locationImage setImage:[UIImage imageNamed:@"marker_default_avatar.png"]];
            }else{
                NSData *avatarData = [dict objectForKey:USERNAME];
                if (avatarData == nil) {
                    [locationImage setImage:[UIImage imageNamed:@"marker_default_avatar.png"]];
                }else{
                    [locationImage setImage:[UIImage imageNamed:@"marker_none_avatar_small.png"]];
                    UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(4, 4, 22, 22)];
                    [avatarView setImage: [UIImage imageWithData: avatarData]];
                    [avatarView.layer setCornerRadius: 11.0];
                    [avatarView setClipsToBounds: YES];
                    [locationImage addSubview: avatarView];
                }
            }
        }
        [_imgContent addSubview: locationImage];
        [_imgContent setUserInteractionEnabled: YES];
        
        [_imgContent addSubview: tmpButton];
    }
    
    // Nếu ảnh có description thì cộng thêm chiều cao của nó vào
    UIView *parentView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, sizeImage+8, totalHeight)];
//    if ([typeMessage isEqualToString: locationMessage]){
//        if (infos.count >= 4) {
//            // Kiểm tra có chú thích hay không?
//            if (![[infos objectAtIndex: 3] isEqualToString:@""] && [infos objectAtIndex: 3] != nil) {
//                [parentView setFrame:CGRectMake(0, 0, sizeImage, sizeImage+sizelbAddr.height+sizelbDesc.height+sizelbTime.height+30)];
//            }else{
//                [parentView setFrame:CGRectMake(0, 0, sizeImage, sizeImage+sizelbAddr.height+sizelbTime.height+15)];
//            }
//        }else{
//            [parentView setFrame:CGRectMake(0, 0, sizeImage, sizeImage+sizelbDesc.height+15+sizelbTime.height)];
//        }
//    }

    // Khởi tạo label thời gian
    _lbTimeMsg = [[UILabel alloc] init];
    [_lbTimeMsg setText: time];
    [_lbTimeMsg setFont: [AppUtils fontRegularWithSize: 12.0]];
    [_lbTimeMsg setTextColor:[UIColor darkGrayColor]];
    
    // Hiển thị chi tiết tin nhắn theo từng loại
    if ([typeMessage isEqualToString: locationMessage]) {
        if (infos.count >= 4) {
            // Khai báo label chứa địa chỉ cho location message
            _lbAddrForMap = [[UILabel alloc] init];
            [_lbAddrForMap setNumberOfLines: 5];
            [_lbAddrForMap setText:[infos objectAtIndex: 2]];
            [_lbAddrForMap setTextColor:[UIColor blackColor]];
            [_lbAddrForMap setFont: [AppUtils fontRegularWithSize: 12.0]];
            
            // Nếu location có chú thích
            if (![[infos objectAtIndex: 3] isEqualToString:@""])
            {
                // Set vị trí cho label description
                _lbDescForImage = [[UILabel alloc] initWithFrame:CGRectMake(_imgContent.frame.origin.x, _imgContent.frame.origin.y+_imgContent.frame.size.height+4, sizeImage, sizelbDesc.height)];
                [_lbDescForImage setFont: [AppUtils fontRegularWithSize: 12.0]];
                [_lbDescForImage setNumberOfLines: 5];
                [_lbDescForImage setTextColor:[UIColor colorWithRed:(71/255.0) green:(32/255.0) blue:(102/255.0) alpha:1]];
                [_lbDescForImage setText:[infos objectAtIndex: 3]];
                [parentView addSubview: _lbDescForImage];
                
                // Set label địa chỉ theo label description
                [_lbAddrForMap setFrame:CGRectMake(_imgContent.frame.origin.x, _lbDescForImage.frame.origin.y+_lbDescForImage.frame.size.height+4, _lbDescForImage.frame.size.width, sizelbAddr.height)];
            }else{
                // Set label địa chỉ theo _imgContent
                [_lbAddrForMap setFrame:CGRectMake(_imgContent.frame.origin.x, _imgContent.frame.origin.y+_imgContent.frame.size.height+4, _imgContent.frame.size.width, sizelbAddr.height)];
            }
            [parentView addSubview: _lbAddrForMap];
            
            // Set label time và image delivered, expire time
            if (type == BubbleTypeSomeoneElse)
            {   // Nếu có expire time thì hiển thị clockView
                if (expireTime > 0) {
                    _imgClockView = [[UIImageView alloc] initWithFrame:CGRectMake(_imgContent.frame.origin.x, _lbAddrForMap.frame.origin.y+_lbAddrForMap.frame.size.height+3, 13, 13)];
                    [_imgClockView setImage:[UIImage imageNamed:@"chat_clock.png"]];
                    [parentView addSubview: _imgClockView];
                    
                    // Set label time theo imgClockView
                    [_lbTimeMsg setFrame:CGRectMake(_imgClockView.frame.origin.x+_imgClockView.frame.size.width + 4, _imgClockView.frame.origin.y+(_imgClockView.frame.size.height-sizelbTime.height)/2, sizelbTime.width, sizelbTime.height)];
                    [_lbTimeMsg setTextAlignment:NSTextAlignmentLeft];
                }else{
                    [_lbTimeMsg setFrame:CGRectMake(_imgContent.frame.origin.x, _lbAddrForMap.frame.origin.y+_lbAddrForMap.frame.size.height+3, sizelbTime.width, sizelbTime.height)];
                    [_lbTimeMsg setTextAlignment:NSTextAlignmentLeft];
                }
            }else{
                [_lbTimeMsg setFrame:CGRectMake(_imgContent.frame.origin.x+_imgContent.frame.size.width-sizelbTime.width, _lbAddrForMap.frame.origin.y+_lbAddrForMap.frame.size.height+4, sizelbTime.width, sizelbTime.height)];
                [_lbTimeMsg setTextAlignment:NSTextAlignmentRight];
                
                // Set image delivered theo label time
                _imgDelivered = [[UIImageView alloc] initWithFrame: CGRectMake(_lbTimeMsg.frame.origin.x - 17, _lbTimeMsg.frame.origin.y, 15, 11)];
                if (status == 0) {
                    [_imgDelivered setImage: [UIImage imageNamed:@"chat_message_not_delivered.png"]];
                }else if (status == 1){
                    [_imgDelivered setImage: [UIImage imageNamed:@"chat_message_inprogress.png"]];
                }else{
                    [_imgDelivered setImage: [UIImage imageNamed:@"chat_message_delivered.png"]];
                }
                [parentView addSubview: _imgDelivered];
                
                // Add clockView nếu có expire time
                if (expireTime > 0) {
                    _imgClockView = [[UIImageView alloc] initWithFrame:CGRectMake(_imgDelivered.frame.origin.x - 15, _imgDelivered.frame.origin.y, 13, 13)];
                    [_imgClockView setImage:[UIImage imageNamed:@"chat_clock.png"]];
                    [parentView addSubview: _imgClockView];
                }
            }
        }
    }else{
        // Nếu ảnh có description
        if (![description isEqualToString:@""]) {
            [_lbDescForImage setHidden: FALSE];
            _lbDescForImage = [[UILabel alloc] initWithFrame:CGRectMake(_imgContent.frame.origin.x, _imgContent.frame.origin.y+_imgContent.frame.size.height+4, _imgContent.frame.size.width, sizelbDesc.height)];
            [_lbDescForImage setText: description];
            [_lbDescForImage setTextColor:[UIColor colorWithRed:(50/255.0) green:(50/255.0)
                                                           blue:(50/255.0) alpha:1.0]];
            [_lbDescForImage setNumberOfLines: 3];
            [_lbDescForImage setFont: [AppUtils fontRegularWithSize: 12.0]];
            [parentView addSubview: _lbDescForImage];
            
            if (type == BubbleTypeSomeoneElse) {
                [_lbTimeMsg setTextAlignment: NSTextAlignmentLeft];
                if (expireTime > 0) {
                    // vị trí icon expire
                    _imgClockView = [[UIImageView alloc] initWithFrame:CGRectMake(_imgContent.frame.origin.x, _lbDescForImage.frame.origin.y+_lbDescForImage.frame.size.height + 5, 13, 13)];
                    [_imgClockView setImage:[UIImage imageNamed:@"chat_clock.png"]];
                    [parentView addSubview: _imgClockView];
                    
                    // vị trí label time
                    [_lbTimeMsg setFrame:CGRectMake(_imgClockView.frame.origin.x+_imgClockView.frame.size.width+3, _imgClockView.frame.origin.y+2, sizelbTime.width, sizelbTime.height)];
                }else{
                    [_lbTimeMsg setFrame:CGRectMake(_imgContent.frame.origin.x, _lbDescForImage.frame.origin.y+_lbDescForImage.frame.size.height+5, sizelbTime.width, sizelbTime.height)];
                }
            }else{
                // Set vị trí cho label time
                [_lbTimeMsg setFrame:CGRectMake(_imgContent.frame.size.width-sizelbTime.width, _lbDescForImage.frame.origin.y+_lbDescForImage.frame.size.height+5, sizelbTime.width, sizelbTime.height)];
                [_lbTimeMsg setTextAlignment: NSTextAlignmentRight];
                
                // Set image delivered
                _imgDelivered = [[UIImageView alloc] initWithFrame: CGRectMake(_lbTimeMsg.frame.origin.x - 17, _lbTimeMsg.frame.origin.y+1, 15, 11)];
                if (status == 0) {
                    [_imgDelivered setImage:[UIImage imageNamed:@"chat_message_not_delivered.png"]];
                }else if (status == 1){
                    [_imgDelivered setImage:[UIImage imageNamed:@"chat_message_inprogress.png"]];
                }else{
                    [_imgDelivered setImage:[UIImage imageNamed:@"chat_message_delivered.png"]];
                }
                [parentView addSubview: _imgDelivered];
                
                // Add clockView nếu có expire time
                if (expireTime > 0) {
                    _imgClockView = [[UIImageView alloc] initWithFrame:CGRectMake(_imgDelivered.frame.origin.x - 15, _imgDelivered.frame.origin.y-(13-_imgDelivered.frame.size.height)/2, 13, 13)];
                    [_imgClockView setImage:[UIImage imageNamed:@"chat_clock.png"]];
                    [parentView addSubview: _imgClockView];
                }
            }
        }else{
            [_lbDescForImage setHidden: TRUE];
            if (type == BubbleTypeSomeoneElse)
            {   // icon expire time
                if (expireTime > 0) {
                    _imgClockView = [[UIImageView alloc] initWithFrame:CGRectMake(_imgContent.frame.origin.x, _imgContent.frame.origin.y+_imgContent.frame.size.height+3, 13, 13)];
                    [_imgClockView setImage:[UIImage imageNamed:@"chat_clock.png"]];
                    [parentView addSubview: _imgClockView];
                    
                    // Set label time theo image clock
                    [_lbTimeMsg setFrame:CGRectMake(_imgClockView.frame.origin.x+_imgClockView.frame.size.width+3, _imgClockView.frame.origin.y+1, sizelbTime.width, sizelbTime.height)];
                }else{
                    [_lbTimeMsg setFrame:CGRectMake(_imgContent.frame.origin.x, _imgContent.frame.origin.y+_imgContent.frame.size.height+4, sizelbTime.width, sizelbTime.height)];
                }
                [_lbTimeMsg setTextAlignment: NSTextAlignmentLeft];
            }else{
                [_lbTimeMsg setFrame:CGRectMake(_imgContent.frame.size.width-sizelbTime.width, _imgContent.frame.origin.y+_imgContent.frame.size.height+4, sizelbTime.width, sizelbTime.height)];
                [_lbTimeMsg setTextAlignment:NSTextAlignmentRight];
                
                // Set image delivered theo label time
                _imgDelivered = [[UIImageView alloc] initWithFrame:CGRectMake(_lbTimeMsg.frame.origin.x - 17, _lbTimeMsg.frame.origin.y+1, 15, 11)];
                if (status == 0) {
                    [_imgDelivered setImage:[UIImage imageNamed:@"chat_message_not_delivered.png"]];
                }else if (status == 1){
                    [_imgDelivered setImage:[UIImage imageNamed:@"chat_message_inprogress.png"]];
                }else{
                    [_imgDelivered setImage:[UIImage imageNamed:@"chat_message_delivered.png"]];
                }
                [parentView addSubview: _imgDelivered];
                
                // Add clockView nếu có expire time
                if (expireTime > 0) {
                    _imgClockView = [[UIImageView alloc] initWithFrame:CGRectMake(_imgDelivered.frame.origin.x - 15, _imgDelivered.frame.origin.y-(13-_imgDelivered.frame.size.height)/2, 13, 13)];
                    [_imgClockView setImage:[UIImage imageNamed:@"chat_clock.png"]];
                    [parentView addSubview: _imgClockView];
                }
            }
        }
    }
    [parentView addSubview: _lbTimeMsg];
    [parentView addSubview: _imgContent];
    [_lbTime setBackgroundColor:[UIColor clearColor]];
    [_lbTimeMsg setBackgroundColor:[UIColor clearColor]];
    [_lbTimeMsg sizeToFit];
    [_lbDescForImage setBackgroundColor:[UIColor clearColor]];
    [parentView setBackgroundColor:[UIColor clearColor]];
    
    if ([typeMessage isEqualToString:videoMessage]) {
        UIButton *viewButton = [[UIButton alloc] initWithFrame:CGRectMake((_imgContent.frame.size.width-22)/2, (_imgContent.frame.size.height-23)/2, 22, 23)];
        [viewButton setBackgroundImage:[UIImage imageNamed:@"play_default.png"] forState:UIControlStateNormal];
        [viewButton setBackgroundImage:[UIImage imageNamed:@"play_over.png"] forState:UIControlStateHighlighted];
        [parentView addSubview: viewButton];
    }
    
#if !__has_feature(objc_arc)
    [imageView autorelease];
#endif
    
    UIEdgeInsets insets = (type == BubbleTypeMine ? imageInsetsMine : imageInsetsSomeone);
    return [self initWithView:parentView type:type insets:insets time:time status:status idMessage:idMessage withExpireTime:expireTime isRecall:isRecall description:description withTypeMessage:typeMessage isGroup: (BOOL)isGroup ofUser: (NSString *)userName];
}

#pragma mark - Custom view bubble
+ (id)dataWithView:(UIView *)view type:(NSBubbleType)type insets:(UIEdgeInsets)insets time:(NSString *)time status:(int)status idMessage: (NSString *)idMessage withExpireTime:(int)expireTime isRecall:(NSString *)isRecall description: (NSString *)description withTypeMessage:(NSString *)typeMessage  isGroup: (BOOL)isGroup ofUser: (NSString *)userName
{
#if !__has_feature(objc_arc)
    return [[[NSBubbleData alloc] initWithView:view type:type insets:insets] autorelease];
#else
    return [[NSBubbleData alloc] initWithView:view type:type insets:insets time:time status:status idMessage:idMessage withExpireTime:expireTime isRecall:isRecall description:description withTypeMessage:typeMessage  isGroup: (BOOL)isGroup ofUser: (NSString *)userName];
#endif    
}

- (id)initWithView:(UIView *)view type:(NSBubbleType)type insets:(UIEdgeInsets)insets time:(NSString *)time status:(int)status idMessage: (NSString *)idMessage withExpireTime:(int)expireTime isRecall:(NSString *)isRecall description: (NSString *)description withTypeMessage:(NSString *)typeMessage  isGroup: (BOOL)isGroup ofUser: (NSString *)userName
{
    self = [super init];
    if (self)
    {
        if ([typeMessage isEqualToString: audioMessage]) {
            _lbTime = [[UILabel alloc] init];
            _timeSlider = [[UISlider alloc] init];
            
            NSArray *listChilds = [view subviews];
            for (id object in listChilds) {
                if ([object isKindOfClass:[UIButton class]]) {
                    _currentPlayButton = object;
                    [_currentPlayButton addTarget:self
                                           action:@selector(clickToPlayAudio:)
                                 forControlEvents:UIControlEventTouchUpInside];
                }else if ([object isKindOfClass:[UILabel class]]){
                    _lbTime = object;
                }else if ([object isKindOfClass:[UISlider class]]){
                    _timeSlider = object;
                    [_timeSlider setThumbImage:[UIImage imageNamed:@"lk_slider.png"]
                                      forState:UIControlStateNormal];
                    [_timeSlider setMinimumTrackImage:[UIImage imageNamed:@"left_slider"]
                                             forState:UIControlStateNormal];
                    [_timeSlider setMaximumTrackImage:[UIImage imageNamed:@"right_slider"]
                                             forState: UIControlStateNormal];
                }
            }
            NSURL *recordURL = [self getUrlOfRecordFile: description];
            NSError *error = nil;
            
            _player = [[AVAudioPlayer alloc] initWithContentsOfURL:recordURL error:&error];
            
            // Lấy độ dài của record file
            AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:recordURL options:nil];
            CMTime audioDuration = audioAsset.duration;
            durationTime = ceil(CMTimeGetSeconds(audioDuration));
            
            // add độ dài audio cho button play
            [_currentPlayButton setTag: durationTime];
            
            
            [_lbTime setText:[NSString stringWithFormat:@"0:%d", durationTime]];
            [_timeSlider setMinimumValue: 0];
            [_timeSlider setMaximumValue: durationTime];
            
            UIFont *fontlbTime = [UIFont systemFontOfSize: 11.0];
            CGSize sizelbTime = [(time ? time : @"") sizeWithFont:fontlbTime
                                                constrainedToSize:CGSizeMake(255, 9999)
                                                    lineBreakMode:NSLineBreakByWordWrapping];
            // Khởi tạo label thời gian
            _lbTimeMsg = [[UILabel alloc] init];
            [_lbTimeMsg setText: time];
            [_lbTimeMsg setFont: [AppUtils fontRegularWithSize: 12.0]];
            [_lbTimeMsg setTextColor:[UIColor darkGrayColor]];
            
            // Hiển thị chi tiết tin nhắn theo từng loại
            if (type == BubbleTypeSomeoneElse) {
                // Khởi tạo image expire time
                if (expireTime > 0) {
                    _imgClockView = [[UIImageView alloc] initWithFrame:CGRectMake(4, view.frame.size.height-13-3, 13, 13)];
                    [_imgClockView setImage:[UIImage imageNamed:@"chat_clock.png"]];
                    [view addSubview: _imgClockView];
                    
                    // label time
                    [_lbTimeMsg setFrame:CGRectMake(_imgClockView.frame.origin.x+_imgClockView.frame.size.width+3, _imgClockView.frame.origin.y, sizelbTime.width, sizelbTime.height)];
                    [_lbTimeMsg setTextAlignment: NSTextAlignmentLeft];
                }else{
                    [_lbTimeMsg setFrame:CGRectMake(4, view.frame.size.height-sizelbTime.height-3, sizelbTime.width, sizelbTime.height)];
                    [_lbTimeMsg setTextAlignment: NSTextAlignmentLeft];
                }
            }else{
                [_lbTimeMsg setFrame:CGRectMake(view.frame.size.width-sizelbTime.width-5, view.frame.size.height-sizelbTime.height-3, sizelbTime.width, sizelbTime.height)];
                [_lbTimeMsg setTextAlignment: NSTextAlignmentRight];
                
                // Khởi tạo image delivered
                _imgDelivered = [[UIImageView alloc] initWithFrame: CGRectMake(_lbTimeMsg.frame.origin.x - 17, _lbTimeMsg.frame.origin.y+(_lbTimeMsg.frame.size.height-11)/2, 15, 11)];
                if (status == 0) {
                    [_imgDelivered setImage:[UIImage imageNamed:@"chat_message_not_delivered.png"]];
                }else if (status == 1){
                    [_imgDelivered setImage:[UIImage imageNamed:@"chat_message_inprogress.png"]];
                }else{
                    [_imgDelivered setImage:[UIImage imageNamed:@"chat_message_delivered.png"]];
                }
                [view addSubview: _imgDelivered];
                
                // Khởi tạo image expire time
                if (expireTime > 0) {
                    _imgClockView = [[UIImageView alloc] initWithFrame: CGRectMake(_imgDelivered.frame.origin.x - 13 - 5, _lbTimeMsg.frame.origin.y, 13, 13)];
                    [_imgClockView setImage:[UIImage imageNamed:@"chat_clock.png"]];
                    [view addSubview: _imgClockView];
                }
            }
            [view addSubview: _lbTimeMsg];
        }else if ([typeMessage isEqualToString: contactMessage]){
            UIFont *fontlbTime = [AppUtils fontRegularWithSize: 11.0];
            CGSize sizelbTime = [(time ? time : @"") sizeWithFont:fontlbTime
                                                constrainedToSize:CGSizeMake(220, 9999)
                                                    lineBreakMode:NSLineBreakByWordWrapping];
            
            UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(5, 5, view.frame.size.width-10, view.frame.size.width-10)];
            [backgroundView setBackgroundColor:[UIColor colorWithRed:(220/255.0) green:(220/255.0)
                                                                blue:(220/255.0) alpha:1.0]];
            [backgroundView.layer setShadowColor:[UIColor grayColor].CGColor];
            [backgroundView.layer setShadowOpacity:0.8];
            [backgroundView.layer setShadowRadius:3.0];
            [backgroundView.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
            
            UILabel *lbBgAvatar = [[UILabel alloc] initWithFrame: CGRectMake(2, 2, backgroundView.frame.size.width-4, backgroundView.frame.size.height-4)];
            [lbBgAvatar setBackgroundColor: [UIColor whiteColor]];
            [backgroundView addSubview: lbBgAvatar];
            
            // Hiển thị avtar của contact nhận được
            _contactAvatar = [[UIImageView alloc] initWithFrame: CGRectMake((backgroundView.frame.size.width-80)/2, 5, 80, 80)];
            NSString *contactCallnexID = [NSDatabase getCallnexIDOfContactReceived: idMessage];
            NSData *tmpData = [NSDatabase getAvatarDataFromCacheFolderForUser: contactCallnexID];
            if (tmpData == nil) {
                [_contactAvatar setImage: [UIImage imageNamed:@"no_avatar.png"]];
            }else{
                [_contactAvatar setImage: [UIImage imageWithData: tmpData]];
            }
            [backgroundView addSubview: _contactAvatar];
            
            _contactName = [[UILabel alloc] initWithFrame: CGRectMake(0, _contactAvatar.frame.origin.y+_contactAvatar.frame.size.height+3, backgroundView.frame.size.width, 20)];
            [_contactName setFont: [AppUtils fontRegularWithSize: 13.0]];
            [_contactName setTextAlignment: NSTextAlignmentCenter];
            [_contactName setText: description];
            [backgroundView addSubview: _contactName];
            
            //  
            _lbTimeMsg = [[UILabel alloc] init];
            [_lbTimeMsg setText: time];
            [_lbTimeMsg setFont: [AppUtils fontRegularWithSize: 11.0]];
            [_lbTimeMsg setTextColor:[UIColor darkGrayColor]];
            
            // Hiển thị chi tiết tin nhắn theo từng loại
            if (type == BubbleTypeSomeoneElse) {
                [_lbTimeMsg setFrame:CGRectMake(0, backgroundView.frame.origin.y+backgroundView.frame.size.height+7, sizelbTime.width, sizelbTime.height)];
                [_lbTimeMsg setTextAlignment: NSTextAlignmentLeft];
                
                // Khởi tạo image expire time
                if (expireTime > 0) {
                    _imgClockView = [[UIImageView alloc] initWithFrame:CGRectMake(_lbTimeMsg.frame.origin.x + _lbTimeMsg.frame.size.width + 5, _lbTimeMsg.frame.origin.y-2, 13, 13)];
                    [_imgClockView setImage:[UIImage imageNamed:@"chat_clock.png"]];
                    
                    [view addSubview: _imgClockView];
                }
            }else{
                [_lbTimeMsg setFrame:CGRectMake(view.frame.size.width-sizelbTime.width, backgroundView.frame.origin.y+backgroundView.frame.size.height+7, sizelbTime.width, sizelbTime.height)];
                [_lbTimeMsg setTextAlignment: NSTextAlignmentRight];
                
                // Khởi tạo image delivered
                _imgDelivered = [[UIImageView alloc] initWithFrame: CGRectMake(_lbTimeMsg.frame.origin.x - 17, _lbTimeMsg.frame.origin.y, 15, 11)];
                if (status == 0) {
                    [_imgDelivered setImage:[UIImage imageNamed:@"chat_message_not_delivered.png"]];
                }else if (status == 1){
                    [_imgDelivered setImage:[UIImage imageNamed:@"chat_message_inprogress.png"]];
                }else{
                    [_imgDelivered setImage:[UIImage imageNamed:@"chat_message_delivered.png"]];
                }
                [view addSubview: _imgDelivered];
                
                // Khởi tạo image expire time
                if (expireTime > 0) {
                    _imgClockView = [[UIImageView alloc] init];
                    [_imgClockView setImage:[UIImage imageNamed:@"chat_clock.png"]];
                    [_imgClockView setFrame:CGRectMake(_imgDelivered.frame.origin.x - _imgDelivered.frame.size.width - 5, _lbTimeMsg.frame.origin.y-2, 13, 13)];
                    [view addSubview: _imgClockView];
                }
            }
            [view addSubview: _lbTimeMsg];
            [view addSubview: backgroundView];
        }else if ([typeMessage isEqualToString: imageMessage]){
            if (expireTime > 0) {
                UILabel *lbClickToView = [[UILabel alloc] initWithFrame: CGRectMake(0, view.frame.size.height/2+30, view.frame.size.width, 20)];
                [lbClickToView setBackgroundColor:[UIColor clearColor]];
                [lbClickToView setFont: [AppUtils fontRegularWithSize: 12.0]];
                [lbClickToView setTextAlignment: NSTextAlignmentCenter];
                [lbClickToView setText: [localization localizedStringForKey:TEXT_CLICK_TO_VIEW]];
                [lbClickToView setTextColor:[UIColor blackColor]];
                [view addSubview: lbClickToView];
            }
        }
        
        [_lbTimeMsg sizeToFit];
        
#if !__has_feature(objc_arc)
        _view = [view retain];
#else
        _view = view;
#endif
        _type = type;
        _insets = insets;
        _time = time;
        _status = status;
        _idMessage = idMessage;
        _expireTime = expireTime;
        _isRecall = isRecall;
        _description = description;
        _typeMessage = typeMessage;
        _isGroup = isGroup;
        _userName = userName;
    }
    return self;
}

// Hàm trả về đường dẫn đến file record
- (NSURL *)getUrlOfRecordFile: (NSString *)fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pathFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/records/%@", fileName]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath: pathFile];
    
    if (!fileExists) {
        return nil;
    }else{
        return [[NSURL alloc] initFileURLWithPath: pathFile];
    }
}

/*----- Khi click để play một record -----*/
- (void)clickToPlayAudio: (UIButton *)playButton {
    if (_expireTime > 0) {
        BOOL success = [NSDatabase updateExpireTimeWhenClickPlayExpireAudioMessage:_idMessage withAudioLength: (int)playButton.tag];
        if (!success) {
            NSLog(@"Can not update expire time of audio message");
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:k11ReStartDeleteExpireTimerOfMe object:nil];
    }
    
    _player.delegate = self;
    if (!_isPaused) {
        [_player prepareToPlay];
        [_player play];
        
        firedTime = [NSTimer scheduledTimerWithTimeInterval:1 target:self
                                                   selector:@selector(timerFired:)
                                                   userInfo:playButton repeats:YES];
        
        [_player playAtTime: _player.currentTime];
        [playButton setBackgroundImage:[UIImage imageNamed:@"pause_file_transfer.png"]
                                      forState:UIControlStateNormal];
        _isPaused = YES;
    }else{
        [_player pause];
        [firedTime invalidate];
        [playButton setBackgroundImage:[UIImage imageNamed:@"play_file_transfer.png"]
                                      forState:UIControlStateNormal];
        _isPaused = NO;
    }
}

// Cập nhật thời gian chạy của record
- (void)timerFired: (NSTimer*)curTimer {
    int currentTime = durationTime - (int)ceil(_player.currentTime);
    NSLog(@"Current time: %d -- total: %d", currentTime, durationTime);
    NSString* currentTimeString = [NSString stringWithFormat:@"%d", (int)currentTime];
    
    [_lbTime setText:[NSString stringWithFormat:@"0:%@", currentTimeString]];
    _timeSlider.value = (int)ceil(_player.currentTime);
}

// Khi play hết audio message
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [firedTime invalidate];
    [_currentPlayButton setBackgroundImage:[UIImage imageNamed:@"play_file_transfer.png"]
                                  forState:UIControlStateNormal];
    [_lbTime setText:[NSString stringWithFormat:@"0:%d", durationTime]];
    _timeSlider.value = 0;
    _isPaused = NO;
}

- (UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    double ratio;
    double delta;
    CGPoint offset;
    
    // make a new square size, that is the resized imaged width
    CGSize sz = CGSizeMake(newSize.width, newSize.width);
    
    //figure out if the picture is landscape or portrait, then
    //calculate scale factor and offset
    if (image.size.width > image.size.height) {
        ratio = newSize.width / image.size.width;
        delta = (ratio*image.size.width - ratio*image.size.height);
        offset = CGPointMake(delta/2, 0);
    } else {
        ratio = newSize.width / image.size.height;
        delta = (ratio*image.size.height - ratio*image.size.width);
        offset = CGPointMake(0, delta/2);
    }
    
    //make the final clipping rect based on the calculated values
    CGRect clipRect = CGRectMake(-offset.x, -offset.y,
                                 (ratio * image.size.width) + delta,
                                 (ratio * image.size.height) + delta);
    
    
    // start a new context, with scale factor 0.0 so retina displays get
    // high quality image
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(sz, YES, 0.0);
    } else {
        UIGraphicsBeginImageContext(sz);
    }
    UIRectClip(clipRect);
    [image drawInRect:clipRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


//  Lấy tên image từ đường link
- (NSString *)getImageNameFromLinkProduct: (NSString *)productLink
{
    NSString *imageName = @"";
    if (productLink.length > 0) {
        productLink = [productLink stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
        NSArray *arr = [productLink componentsSeparatedByString:@"/"];
        if (arr.count > 0) {
            imageName = [arr lastObject];
        }
    }
    return imageName;
}

@end
