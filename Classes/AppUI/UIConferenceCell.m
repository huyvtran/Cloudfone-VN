//
//  UIConferenceCell.m
//  linphone
//
//  Created by Designer 01 on 3/6/15.
//
//

#import "UIConferenceCell.h"
#import "LinphoneManager.h"
#import "FastAddressBook.h"
#import "NSDatabase.h"
#import "NSData+Base64.h"

@interface UIConferenceCell (){
    UIFont *textFont;
}

@end

@implementation UIConferenceCell
@synthesize _userAvatar, _userName, _timeCall, _btnPause, _btnEndCall, duration, call;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)setupUIForCell
{
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
    }else{
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:14.0];
    }
    _userAvatar.frame = CGRectMake(5, 5, self.frame.size.width-10, self.frame.size.width-10);
    _userName.frame = CGRectMake(_userAvatar.frame.origin.x, self.frame.size.width, _userAvatar.frame.size.width, 20);
    _userName.textColor = UIColor.whiteColor;
    _userName.font = textFont;
    _userName.backgroundColor = UIColor.clearColor;
    _timeCall.font = textFont;
    
    if (SCREEN_WIDTH > 320) {
        _btnEndCall.frame = CGRectMake(self.frame.size.width-35.0-_userAvatar.frame.origin.x, _userName.frame.origin.y + _userName.frame.size.height + (self.frame.size.height-_userName.frame.origin.y-_userName.frame.size.height-35.0)/2, 35.0, 35.0);
        _btnPause.frame = CGRectMake(_btnEndCall.frame.origin.x-5-_btnEndCall.frame.size.width, _btnEndCall.frame.origin.y, _btnEndCall.frame.size.width, _btnEndCall.frame.size.height);
    }else{
        _btnEndCall.frame = CGRectMake(self.frame.size.width-30.0-_userAvatar.frame.origin.x, _userName.frame.origin.y + _userName.frame.size.height + (self.frame.size.height-_userName.frame.origin.y-_userName.frame.size.height-30.0)/2, 30.0, 30.0);
        _btnPause.frame = CGRectMake(_btnEndCall.frame.origin.x-5-_btnEndCall.frame.size.width, _btnEndCall.frame.origin.y, _btnEndCall.frame.size.width, _btnEndCall.frame.size.height);
    }
    _timeCall.frame = CGRectMake(_userName.frame.origin.x, _btnPause.frame.origin.y, _btnPause.frame.origin.x-_userName.frame.origin.x-5, _btnPause.frame.size.height);
}

- (void)updateCell
{
    _userAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
    
    const LinphoneAddress* addr = linphone_call_get_remote_address(call);
    NSString *phoneNumber = @"Unknown";
    if (addr != NULL) {
        // contact name
        char* lAddress = linphone_address_as_string_uri_only(addr);
        if(lAddress) {
            NSString *normalizedSipAddress = [FastAddressBook normalizeSipURI:[NSString stringWithUTF8String:lAddress]];
            if (normalizedSipAddress.length >= 7) {
                phoneNumber = [normalizedSipAddress substringWithRange:NSMakeRange(4, 10)];
            }
            ms_free(lAddress);
        }
    }
    
    NSArray *infos = [NSDatabase getNameAndAvatarOfContactWithPhoneNumber: phoneNumber];
    if (![[infos objectAtIndex:0] isEqualToString: @""]) {
        _userName.text = [infos objectAtIndex: 0];
    }else{
        _userName.text = phoneNumber;
    }
    _userName.text = phoneNumber;
    
    NSString *avatar = [infos objectAtIndex:1];
    if (![avatar isEqualToString: @""] && avatar != nil && ![avatar isEqualToString:@"null"] && ![avatar isEqualToString:@"(null)"] && ![avatar isEqualToString:@"<null>"]) {
        _userAvatar.image = [UIImage imageWithData:[NSData dataFromBase64String:[infos objectAtIndex:1]]];
    }
    _timeCall.text = [NSString stringWithFormat:@"%02i:%02i", (duration/60), duration - 60 * (duration / 60), nil];
}

- (void)dealloc {
    [_userAvatar release];
    [_userName release];
    [_timeCall release];
    [_btnPause release];
    [_btnEndCall release];
    [super dealloc];
}
@end
