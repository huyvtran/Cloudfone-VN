/* UICallButton.m
 *
 * Copyright (C) 2011  Belledonne Comunications, Grenoble, France
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#import "UICallButton.h"
#import "LinphoneManager.h"
#import "NSDatabase.h"
#import "OutgoingCallViewController.h"
#import "PhoneMainView.h"
#import <CoreTelephony/CTCallCenter.h>

@implementation UICallButton

@synthesize addressField, delegate;

#pragma mark - Lifecycle Functions

- (void)initUICallButton {
	[self addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside];
}

- (id)init {
	self = [super init];
	if (self) {
		[self initUICallButton];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self initUICallButton];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	self = [super initWithCoder:decoder];
	if (self) {
		[self initUICallButton];
	}
	return self;
}

#pragma mark -

//  Hàm loại bỏ tất cả các ký tự ko là số ra khỏi chuỗi
- (NSString *)removeAllSpecialInString: (NSString *)phoneString
{
    NSArray *listNumber = [[NSArray alloc] initWithObjects: @"+", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil];
    NSString *resultStr = @"";
    for (int strCount=0; strCount<phoneString.length; strCount++) {
        char characterChar = [phoneString characterAtIndex: strCount];
        NSString *characterStr = [NSString stringWithFormat:@"%c", characterChar];
        if ([listNumber containsObject: characterStr]) {
            resultStr = [NSString stringWithFormat:@"%@%@", resultStr, characterStr];
        }
    }
    return resultStr;
}

- (void)touchUp:(id)sender {
	NSString *address = addressField.text;
	if (address.length == 0) {
        NSString *phoneNumber = [NSDatabase getLastCallOfUser];
        if (![phoneNumber isEqualToString: @""]) {
            addressField.text = phoneNumber;
            [delegate textfieldAddressChanged: phoneNumber];
        }
        return;
	}
    
    if ([address hasPrefix:@"+84"]) {
        address = [address stringByReplacingOccurrencesOfString:@"+84" withString:@"0"];
    }
    
    if ([address hasPrefix:@"84"]) {
        address = [address substringFromIndex:2];
        address = [NSString stringWithFormat:@"0%@", address];
    }

    address = [self removeAllSpecialInString:address];
    
	if ([address length] > 0) {
		LinphoneAddress *addr = [LinphoneUtils normalizeSipOrPhoneAddress:address];
		[LinphoneManager.instance call:addr];
		if (addr)
			linphone_address_destroy(addr);
	}
    
    OutgoingCallViewController *controller = VIEW(OutgoingCallViewController);
    if (controller != nil) {
        [controller setPhoneNumberForView: address];
    }
    [[PhoneMainView instance] changeCurrentView:[OutgoingCallViewController compositeViewDescription] push:TRUE];
}

- (void)updateIcon {
	if (linphone_core_video_capture_enabled(LC) && linphone_core_get_video_policy(LC)->automatically_initiate) {
		[self setImage:[UIImage imageNamed:@"call_video_start_default.png"] forState:UIControlStateNormal];
		[self setImage:[UIImage imageNamed:@"call_video_start_disabled.png"] forState:UIControlStateDisabled];
	} else {
		[self setImage:[UIImage imageNamed:@"call_audio_start_default.png"] forState:UIControlStateNormal];
		[self setImage:[UIImage imageNamed:@"call_audio_start_disabled.png"] forState:UIControlStateDisabled];
	}

	if (LinphoneManager.instance.nextCallIsTransfer) {
		[self setImage:[UIImage imageNamed:@"call_transfer_default.png"] forState:UIControlStateNormal];
		[self setImage:[UIImage imageNamed:@"call_transfer_disabled.png"] forState:UIControlStateDisabled];
	} else if (linphone_core_get_calls_nb(LC) > 0) {
		[self setImage:[UIImage imageNamed:@"call_add_default.png"] forState:UIControlStateNormal];
		[self setImage:[UIImage imageNamed:@"call_add_disabled.png"] forState:UIControlStateDisabled];
	}
}
@end
