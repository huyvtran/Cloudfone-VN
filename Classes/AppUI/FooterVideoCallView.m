//
//  FooterVideoCallView.m
//  linphone
//
//  Created by admin on 12/27/17.
//

#import "FooterVideoCallView.h"

@implementation FooterVideoCallView
@synthesize footerSpeaker, footerMute, footerEndCall, footerCameraOff, footerCameraSwitch;

- (void)setupUIForView
{
    self.backgroundColor = UIColor.clearColor;
    
    float marginX = 15.0;
    float alpha = 0.15;
    
    float hIconEndCall = self.frame.size.height - 10*2;
    float hSmallIcon = hIconEndCall-10;
    float originX = (self.frame.size.width-(hSmallIcon + marginX + hSmallIcon + marginX + hIconEndCall + marginX + hSmallIcon + marginX + hSmallIcon))/2;
    float originY = 10 + (hIconEndCall-hSmallIcon)/2;
    
    //  video speaker
    footerSpeaker.frame = CGRectMake(originX, originY, hSmallIcon, hSmallIcon);
    
    [(UIButton *)footerSpeaker setBackgroundImage:[UIImage imageNamed:@"call_speaker_on"]
                                         forState:UIControlStateNormal];
    [(UIButton *)footerSpeaker setBackgroundImage:[UIImage imageNamed:@"call_speaker_on_selected"]
                                         forState:UIControlStateHighlighted];
    [(UIButton *)footerSpeaker setBackgroundImage:[UIImage imageNamed:@"call_speaker_on_selected"]
                                         forState:UIControlStateSelected];
    footerSpeaker.layer.cornerRadius = hSmallIcon/2;
    footerSpeaker.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0)
                                                     blue:(255/255.0) alpha:alpha];
    
    //  mute button
    footerMute.frame = CGRectMake(footerSpeaker.frame.origin.x+footerSpeaker.frame.size.width+marginX, originY, hSmallIcon, hSmallIcon);
    [(UIButton *)footerMute setBackgroundImage:[UIImage imageNamed:@"call_microphone_off"]
                                      forState:UIControlStateNormal];
    [(UIButton *)footerMute setBackgroundImage:[UIImage imageNamed:@"call_microphone_off_selected"]
                                      forState:UIControlStateHighlighted];
    [(UIButton *)footerMute setBackgroundImage:[UIImage imageNamed:@"call_microphone_off_selected"]
                                      forState:UIControlStateSelected];
    footerMute.layer.cornerRadius = hSmallIcon/2;
    footerMute.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0)
                                                  blue:(255/255.0) alpha:alpha];
    
    //  End video call
    footerEndCall.frame = CGRectMake((self.frame.size.width-hIconEndCall)/2, (self.frame.size.height-hIconEndCall)/2, hIconEndCall, hIconEndCall);
    
    //  turn off video
    footerCameraOff.frame = CGRectMake(footerEndCall.frame.origin.x+footerEndCall.frame.size.width+marginX, originY, hSmallIcon, hSmallIcon);
    
    [footerCameraOff setBackgroundImage:[UIImage imageNamed:@"call_camera_off"]
                               forState:UIControlStateNormal];
    [footerCameraOff setBackgroundImage:[UIImage imageNamed:@"call_camera_off_selected"]
                               forState:UIControlStateHighlighted];
    [footerCameraOff setBackgroundImage:[UIImage imageNamed:@"call_camera_off_selected"]
                               forState:UIControlStateSelected];
    footerCameraOff.layer.cornerRadius = hSmallIcon/2;
    footerCameraOff.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0)
                                                       blue:(255/255.0) alpha:alpha];
    
    //  switch camera
    footerCameraSwitch.frame = CGRectMake(footerCameraOff.frame.origin.x+footerCameraOff.frame.size.width+marginX, originY, hSmallIcon, hSmallIcon);
    [(UIButton *)footerCameraSwitch setBackgroundImage:[UIImage imageNamed:@"call_camera_switcher"]
                                          forState:UIControlStateNormal];
    [(UIButton *)footerCameraSwitch setBackgroundImage:[UIImage imageNamed:@"call_camera_switcher_selected"]
                                          forState:UIControlStateHighlighted];
    footerCameraSwitch.layer.cornerRadius = hSmallIcon/2;
    footerCameraSwitch.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0)
                                                      blue:(255/255.0) alpha:alpha];
}


@end
