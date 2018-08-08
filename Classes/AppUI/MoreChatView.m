//
//  MoreChatView.m
//  linphone
//
//  Created by admin on 12/28/17.
//

#import "MoreChatView.h"

@implementation MoreChatView
@synthesize lbPicture, iconPicture, lbVideo, iconVideo, lbCamera, iconCamera, lbCall, iconCall, lbLocation, iconLocation;

- (void)setupUIForView: (float)hView {
    wIcon = 50.0;
    marginY = (hView - (wIcon+20)*2)/3;
    marginX = (self.frame.size.width-4*wIcon)/5;
    //  picture
    iconPicture.frame = CGRectMake(marginX, marginY, wIcon, wIcon);
    iconPicture.layer.cornerRadius = wIcon/2;
    iconPicture.layer.borderWidth = 1.0;
    iconPicture.layer.borderColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                     blue:(200/255.0) alpha:1.0].CGColor;
    iconPicture.backgroundColor = [UIColor colorWithRed:(240/255.0) green:(240/255.0)
                                                   blue:(240/255.0) alpha:1.0];
    
    lbPicture.frame = CGRectMake(marginX/2, iconPicture.frame.origin.y+iconPicture.frame.size.height, wIcon+marginX, 20);
    
    //  video
    iconVideo.frame = CGRectMake(iconPicture.frame.origin.x+iconPicture.frame.size.width+marginX, iconPicture.frame.origin.y, wIcon, wIcon);
    iconVideo.layer.cornerRadius = wIcon/2;
    iconVideo.layer.borderWidth = 1.0;
    iconVideo.layer.borderColor = iconPicture.layer.borderColor;
    iconVideo.backgroundColor = iconPicture.backgroundColor;
    
    lbVideo.frame = CGRectMake(iconVideo.frame.origin.x-marginX/2, lbPicture.frame.origin.y, lbPicture.frame.size.width, lbPicture.frame.size.height);
    
    //  Camera
    iconCamera.frame = CGRectMake(iconVideo.frame.origin.x+iconVideo.frame.size.width+marginX, iconPicture.frame.origin.y, wIcon, wIcon);
    iconCamera.layer.cornerRadius = wIcon/2;
    iconCamera.layer.borderWidth = 1.0;
    iconCamera.layer.borderColor = iconPicture.layer.borderColor;
    iconCamera.backgroundColor = iconPicture.backgroundColor;
    
    lbCamera.frame = CGRectMake(iconCamera.frame.origin.x-marginX/2, lbPicture.frame.origin.y, lbPicture.frame.size.width, lbPicture.frame.size.height);
    
    //  Call
    iconCall.frame = CGRectMake(iconCamera.frame.origin.x+iconCamera.frame.size.width+marginX, iconPicture.frame.origin.y, wIcon, wIcon);
    iconCall.layer.cornerRadius = wIcon/2;
    iconCall.layer.borderWidth = 1.0;
    iconCall.layer.borderColor = iconPicture.layer.borderColor;
    iconCall.backgroundColor = iconPicture.backgroundColor;
    
    lbCall.frame = CGRectMake(iconCall.frame.origin.x-marginX/2, lbPicture.frame.origin.y, lbPicture.frame.size.width, lbPicture.frame.size.height);
    
    //  Location
    iconLocation.frame = CGRectMake(iconPicture.frame.origin.x, lbPicture.frame.origin.y+lbPicture.frame.size.height+marginY, wIcon, wIcon);
    iconLocation.layer.cornerRadius = wIcon/2;
    iconLocation.layer.borderWidth = 1.0;
    iconLocation.layer.borderColor = iconPicture.layer.borderColor;
    iconLocation.backgroundColor = iconPicture.backgroundColor;
    
    lbLocation.frame = CGRectMake(lbPicture.frame.origin.x, iconLocation.frame.origin.y+iconLocation.frame.size.height, lbPicture.frame.size.width, lbPicture.frame.size.height);
}

@end
