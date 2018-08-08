//
//  UIBubbleTableViewCell.m
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <QuartzCore/QuartzCore.h>
#import "UIBubbleTableViewCell.h"
#import "NSBubbleData.h"
#import "OTRConstants.h"
#import "NSDatabase.h"

#import "SettingItem.h"
#import "KILabel.h"
#import "NSData+Base64.h"

@interface UIBubbleTableViewCell (){
    UITapGestureRecognizer *tapCloseKeyboard;
}

@property (nonatomic, retain) UIView *customView;
@property (nonatomic, retain) UIImageView *bubbleImage;
@property (nonatomic, retain) UIImageView *avatarImage;
@property (nonatomic, retain) NSRegularExpression *regex;
@property (nonatomic, retain) UIImageView *transferView;
@property (nonatomic, assign) int durationTime;

/*--Popup for link message--*/
@property (nonatomic, strong) MessageLinkPopup *viewOptionsPopup;
@property (nonatomic, strong) NSMutableArray *listOptions;
@property (nonatomic, assign) int typeLink;

- (void) setupInternalData;

@end

@implementation UIBubbleTableViewCell

@synthesize data = _data;
@synthesize customView = _customView;
@synthesize bubbleImage = _bubbleImage;
@synthesize showAvatar = _showAvatar;
@synthesize avatarImage = _avatarImage;
@synthesize receiveProgressView;

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.backgroundColor = [UIColor clearColor];
	[self setupInternalData];
}

#if !__has_feature(objc_arc)
- (void) dealloc
{
    self.data = nil;
    self.customView = nil;
    self.bubbleImage = nil;
    self.avatarImage = nil;
    [super dealloc];
}
#endif

- (void)setDataInternal:(NSBubbleData *)value
{
	self.data = value;
	[self setupInternalData];
}

- (void) setupInternalData
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (!self.bubbleImage)
    {
#if !__has_feature(objc_arc)
        self.bubbleImage = [[[UIImageView alloc] init] autorelease];
#else
        self.bubbleImage = [[UIImageView alloc] init];        
#endif
        [self addSubview:self.bubbleImage];
    }
    NSBubbleType type = _data.type;
    
    CGFloat width = _data.view.frame.size.width;
    CGFloat height = _data.view.frame.size.height;

    CGFloat x = (type == BubbleTypeSomeoneElse) ? 0 : self.frame.size.width - width - _data.insets.left - _data.insets.right;
    CGFloat y = 0;
    
    // Set avatar cho bubble chat
    if (_showAvatar)
    {
        [_avatarImage removeFromSuperview];
        
        _avatarImage = [[UIImageView alloc] init];
        [_avatarImage.layer setMasksToBounds: YES];
        
        CGFloat avatarX = 0;
        if (type == BubbleTypeSomeoneElse) {
            avatarX = 5;
        }else{
            avatarX = self.frame.size.width - 5 -30;
        }
        [_avatarImage setFrame: CGRectMake(avatarX, 0, 30, 30)];
        [self addSubview: _avatarImage];
        
        CGFloat delta = self.frame.size.height - (_data.insets.top+_data.insets.bottom + _data.view.frame.size.height);
        if (delta > 0) y = delta;
        if (type == BubbleTypeSomeoneElse) x += 35;
        if (type == BubbleTypeMine) x -= 54;
    }else{
        CGFloat delta = self.frame.size.height - (_data.insets.top + _data.insets.bottom + _data.view.frame.size.height);
        if (delta > 0) y = delta;
        
        if (type == BubbleTypeSomeoneElse) x += 35;
        if (type == BubbleTypeMine) x -= 54;
    }
    
    [_avatarImage setClipsToBounds: true];
    [_avatarImage.layer setCornerRadius:5.0];
    
    [_customView removeFromSuperview];
    _customView = _data.view;
    if ([_data.typeMessage isEqualToString: descriptionMessage]) {
        [_customView setFrame: CGRectMake(0, 0, SCREEN_WIDTH, 20)];
        [_data.lbContent setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    }else{
        [_customView setFrame: CGRectMake(x+5 + _data.insets.left, _data.insets.top-5, width, height)];
    }
    
    // Click vào number, link or email
    _data.lbContent.urlLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        [[NSNotificationCenter defaultCenter] postNotificationName:k11DismissKeyboardInViewChat object:nil];
        
        [self createDataForPhoneNumber:NO andLink:YES isMail:NO];
        _typeLink = linkWebsite;
        _viewOptionsPopup = [[MessageLinkPopup alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-230)/2, (SCREEN_HEIGHT-_listOptions.count*40+6)/2, 230, _listOptions.count*40+5)];
        _viewOptionsPopup.delegate = self;
        _viewOptionsPopup._listOptions = _listOptions;
        _viewOptionsPopup.typeData = _typeLink;
        _viewOptionsPopup.strValue = string;
        [_viewOptionsPopup showInView:self.superview.window animated:YES];
    };
    
    [self setUserInteractionEnabled: true];
    tapCloseKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToCloseKeyboard)];;
    [tapCloseKeyboard setDelegate: self];
    [self addGestureRecognizer: tapCloseKeyboard];
    
    _data.lbContent.urlNumberTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        [[NSNotificationCenter defaultCenter] postNotificationName:k11DismissKeyboardInViewChat object:nil];
        
        [self createDataForPhoneNumber:YES andLink:NO isMail:NO];
        _typeLink = phoneNumber;
        _viewOptionsPopup = [[MessageLinkPopup alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-230)/2, (SCREEN_HEIGHT-_listOptions.count*40+6)/2, 230, _listOptions.count*40+5)];
        _viewOptionsPopup.delegate = self;
        _viewOptionsPopup._listOptions = _listOptions;
        _viewOptionsPopup.typeData = _typeLink;
        _viewOptionsPopup.strValue = string;
        [_viewOptionsPopup showInView:self.superview.window animated:YES];
    };
    
    _data.lbContent.urlEmailTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        [[NSNotificationCenter defaultCenter] postNotificationName:k11DismissKeyboardInViewChat object:nil];
        
        [self createDataForPhoneNumber:NO andLink:NO isMail:YES];
        _typeLink = linkEmail;
        
        _viewOptionsPopup = [[MessageLinkPopup alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-230)/2, (SCREEN_HEIGHT-_listOptions.count*40+6)/2, 230, _listOptions.count*40+5)];
        _viewOptionsPopup.delegate = self;
        _viewOptionsPopup._listOptions = _listOptions;
        _viewOptionsPopup.typeData = _typeLink;
        _viewOptionsPopup.strValue = string;
        [_viewOptionsPopup showInView:self.superview.window animated:YES];
    };
    
    if ([_data.typeMessage isEqualToString:descriptionMessage]) {
        [_avatarImage setHidden: YES];
        if ([_data.lbContent isKindOfClass:[KILabel class]]) {
            [_data.lbContent setText: _data.msgAttributeString.string];
            [_data.lbContent setTextAlignment:NSTextAlignmentCenter];
            [_data.imgClockView setHidden: YES];
            [_data.lbTimeMsg setHidden: YES];
            [_data.imgDelivered setHidden: YES];
            
            [_data.lbContent setTextColor:[UIColor blackColor]];
            [_data.lbContent setFont: [AppUtils fontRegularWithSize: 14.0]];
        }
    }else{
        // Message nhận được
        if (type == BubbleTypeSomeoneElse)
        {
            if (_data.isGroup) {
                NSString *avatarStr = [NSDatabase getAvatarOfContactWithPhoneNumber: _data._callnexID];
                
                if ([avatarStr isEqualToString: @""] || [avatarStr isEqualToString: @"(null)"] || [avatarStr isEqualToString: @"<null>"] || [avatarStr isEqualToString: @"null"])
                {
                    [_avatarImage setImage:[UIImage imageNamed:@"no_avatar.png"]];
                }else{
                    [_avatarImage setImage:[UIImage imageWithData:[NSData dataFromBase64String: avatarStr]]];
                }
            }else{
                if ([LinphoneAppDelegate sharedInstance].userImage == nil) {
                    [_avatarImage setImage: [UIImage imageNamed:@"no_avatar.png"]];
                }else{
                    [_avatarImage setImage: [LinphoneAppDelegate sharedInstance].userImage];
                }
            }
            // Hiển thị bubble cho message
            [_bubbleImage setImage:[[UIImage imageNamed:@"bubbleSomeone.png"] stretchableImageWithLeftCapWidth:21 topCapHeight:26]];
        }else{
            if (_data.status == 0) {
                [_data.imgDelivered setImage:[UIImage imageNamed:@"chat_message_not_delivered.png"]];
            }else if (_data.status == 1){
                [_data.imgDelivered setImage:[UIImage imageNamed:@"chat_message_inprogress.png"]];
            }else{
                [_data.imgDelivered setImage:[UIImage imageNamed:@"chat_message_delivered.png"]];
            }
            
            // Hiển thị avatar của mình nếu có
            NSString *avatar = [NSDatabase getAvatarOfContactWithPhoneNumber: USERNAME];
            
            if (avatar != nil && ![avatar isEqualToString: @""]) {
                NSData *myAvatar = [NSData dataFromBase64String: avatar];
                [_avatarImage setImage:[UIImage imageWithData: myAvatar]];
            }else{
                [_avatarImage setImage:[UIImage imageNamed:@"no_avatar.png"]];
            }
            
            // Hiển thị bubble cho message
            [_bubbleImage setImage:[[UIImage imageNamed:@"bubbleMine.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:26]];
        }
        
        // Kiểm tra nếu là message chứa hình ảnh
        if ([_data.typeMessage isEqualToString: imageMessage] || [_data.typeMessage isEqualToString:locationMessage] || [_data.typeMessage isEqualToString:videoMessage]) {
            if (type == BubbleTypeSomeoneElse) {
                [_bubbleImage setFrame: CGRectMake(x+7, 0, width+6, height)];
                [_customView setFrame: CGRectMake(_bubbleImage.frame.origin.x+6, _bubbleImage.frame.origin.y, width, height)];
            }else{
                [_bubbleImage setFrame:CGRectMake(x+45, 0, width+6, height)];
                [_customView setFrame: CGRectMake(_bubbleImage.frame.origin.x, _bubbleImage.frame.origin.y, width, height)];
            }
        }else if ([_data.typeMessage isEqualToString: audioMessage]){
            if (type == BubbleTypeSomeoneElse) {
                [_bubbleImage setFrame: CGRectMake(x+5, 0, width+6, height)];
                [_customView setFrame: CGRectMake(_bubbleImage.frame.origin.x+7, _bubbleImage.frame.origin.y, width, height)];
            }else{
                [_bubbleImage setFrame:CGRectMake(x+23, 0, width+7, height)];
                [_customView setFrame: CGRectMake(_bubbleImage.frame.origin.x+2, _bubbleImage.frame.origin.y, width, height)];
            }
        }else{
            if (type == BubbleTypeSomeoneElse) {
                if ([_data.typeMessage isEqualToString: contactMessage]) {
                    [_bubbleImage setFrame: CGRectMake(x+5, 0, width+_data.insets.left+_data.insets.right, height+_data.insets.top+_data.insets.bottom-28)];
                    [_customView setFrame: CGRectMake(_bubbleImage.frame.origin.x+12, _bubbleImage.frame.origin.y+4, width, height)];
                }else{
                    [_bubbleImage setFrame: CGRectMake(x+5, 0, width+8, height)];
                    [_customView setFrame: CGRectMake(_bubbleImage.frame.origin.x+7, _bubbleImage.frame.origin.y, width, height)];
                }
            }else{
                if ([_data.typeMessage isEqualToString: contactMessage]) {
                    [_bubbleImage setFrame: CGRectMake(x+15, 0, width + _data.insets.left+_data.insets.right, height+_data.insets.top+_data.insets.bottom-28)];
                    [_customView setFrame: CGRectMake(_bubbleImage.frame.origin.x+5, _bubbleImage.frame.origin.y+4, width, height)];
                }else{
                    [_bubbleImage setFrame: CGRectMake(x+35, 0, width + 7, height)];
                    [_customView setFrame: CGRectMake(_bubbleImage.frame.origin.x, _bubbleImage.frame.origin.y, width, height)];
                }
            }
        }
    }
    [self.contentView addSubview: _customView];
}

/*----- Hàm tạo dữ liệu khi click vào link hay phone number -----*/
- (void)createDataForPhoneNumber: (BOOL)isPhoneNumber andLink: (BOOL)isLink isMail: (BOOL)isMail
{
    HMLocalization *localization = [HMLocalization sharedInstance];
    
    _listOptions = [[NSMutableArray alloc] init];
    
    SettingItem *item = [[SettingItem alloc] init];
    [item set_imageStr: @"ic_copy_message.png"];
    [item set_valueStr: [localization localizedStringForKey:TEXT_LINK_COPY]];
    [_listOptions addObject: item];
    
    if (isPhoneNumber) {
        item = [[SettingItem alloc] init];
        [item set_imageStr: @"ic_call_message.png"];
        [item set_valueStr: [localization localizedStringForKey:TEXT_LINK_CALL]];
        [_listOptions addObject: item];
    }else if (isLink){
        item = [[SettingItem alloc] init];
        [item set_imageStr: @"ic_open_page.png"];
        [item set_valueStr: [localization localizedStringForKey:TEXT_LINK_OPEN]];
        [_listOptions addObject: item];
    }else{
        item = [[SettingItem alloc] init];
        [item set_imageStr: @"ic_send_email.png"];
        [item set_valueStr: [localization localizedStringForKey:TEXT_LINK_MAILTO]];
        [_listOptions addObject: item];
    }
}

- (void)tapToCloseKeyboard {
    [[NSNotificationCenter defaultCenter] postNotificationName:k11DismissKeyboardInViewChat object:nil];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView: _data.lbContent]) {
        return NO;
    }
    return YES;
}

@end
