//
//  RequestHeaderView.m
//  linphone
//
//  Created by Ei Captain on 3/15/17.
//
//

#import "RequestHeaderView.h"

@implementation RequestHeaderView
@synthesize _iconAccept, _imgDetail, _lbTitle, _lbNotifications;

- (void)setupUIForCell
{
    _lbTitle.backgroundColor = UIColor.clearColor;
    _lbTitle.font = [UIFont fontWithName:HelveticaNeue size:16.0];
    _lbTitle.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_list_friend_accept];
    self.backgroundColor = UIColor.clearColor;
    
    _lbNotifications.clipsToBounds = YES;
    _lbNotifications.font = [UIFont fontWithName:HelveticaNeue size:12.0];
    _lbNotifications.layer.cornerRadius = 10.0;
    _lbNotifications.backgroundColor = UIColor.redColor;
    _lbNotifications.textColor = UIColor.whiteColor;
}

- (void)updateUIForView {
    _iconAccept.frame = CGRectMake((self.frame.size.height-50)/2, (self.frame.size.height-50)/2, 50.0, 50.0);
    _imgDetail.frame = CGRectMake(self.frame.size.width-50, _iconAccept.frame.origin.y, _iconAccept.frame.size.width, _iconAccept.frame.size.height);
    
    _lbNotifications.frame = CGRectMake(_imgDetail.frame.origin.x-40.0-5, (self.frame.size.height-26.0)/2, 26.0, 26.0);
    _lbNotifications.layer.cornerRadius = 13.0;
    _lbTitle.frame = CGRectMake(_iconAccept.frame.origin.x+_iconAccept.frame.size.width+5, _iconAccept.frame.origin.y, _lbNotifications.frame.origin.x-5-(_iconAccept.frame.origin.x+_iconAccept.frame.size.width+5), _iconAccept.frame.size.height);
}


@end
