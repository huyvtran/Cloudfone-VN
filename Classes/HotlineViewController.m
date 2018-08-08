//
//  HotlineViewController.m
//  linphone
//
//  Created by admin on 3/10/18.
//

#import "HotlineViewController.h"
#import "StatusBarView.h"
#import "PhoneMainView.h"

@interface HotlineViewController (){
    const MSList *list;
    NSTimer *timeTimer;
    NSTimer *timerConnecting;
}
@end

@implementation HotlineViewController
@synthesize lbStatus, lbTime, imgClock, imgHotline, btnMute, btnSpeaker, btnEndCall;

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
    if (compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:StatusBarView.class
                                                                 tabBar:nil
                                                               sideMenu:nil
                                                             fullscreen:false
                                                         isLeftFragment:YES
                                                           fragmentWith:nil];
        compositeDescription.darkBackground = true;
    }
    return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
    return self.class.compositeViewDescription;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [self setupUIForView];
    
    lbTime.hidden = YES;
    [timerConnecting invalidate];
    timerConnecting = nil;
    timerConnecting = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateLabelConnecting) userInfo:nil repeats:YES];
    
    [self callDurationUpdate];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(callUpdateEvent:)
                                               name:kLinphoneCallUpdate object:nil];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    [timeTimer invalidate];
    timeTimer = nil;
    
    [timerConnecting invalidate];
    timerConnecting = nil;
    
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)callUpdateEvent:(NSNotification *)notif {
    LinphoneCall *call = [[notif.userInfo objectForKey:@"call"] pointerValue];
    LinphoneCallState state = [[notif.userInfo objectForKey:@"state"] intValue];
    [self callUpdate:call state:state animated:TRUE];
}

- (void)callUpdate:(LinphoneCall *)call state:(LinphoneCallState)state animated:(BOOL)animated
{
    static LinphoneCall *currentCall = NULL;
    if (!currentCall || linphone_core_get_current_call(LC) != currentCall) {
        currentCall = linphone_core_get_current_call(LC);
    }
    
    // Fake call update
    if (call == NULL) {
        return;
    }
    
    switch (state) {
        case LinphoneCallIncomingReceived:{
            NSLog(@"HOTLINE: LinphoneCallIncomingReceived");
            break;
        }
        case LinphoneCallOutgoingInit:{
            NSLog(@"HOTLINE: LinphoneCallOutgoingInit");
            break;
        }
        case LinphoneCallConnected:{
            lbStatus.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_connected];
            lbStatus.textColor = [UIColor colorWithRed:(27/255.0) green:(175/255.0) blue:(153/255.0) alpha:1.0];
            lbStatus.textAlignment = NSTextAlignmentCenter;
            
            [timerConnecting invalidate];
            timerConnecting = nil;
            
            lbTime.hidden = NO;
            timeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self
                                                       selector:@selector(callDurationUpdate)
                                                       userInfo:nil repeats:YES];
            break;
        }
        case LinphoneCallStreamsRunning: {
            NSLog(@"HOTLINE: LinphoneCallStreamsRunning");
            break;
        }
        case LinphoneCallUpdatedByRemote: {
            NSLog(@"HOTLINE: LinphoneCallUpdatedByRemote");
        }
        case LinphoneCallPausing:
        case LinphoneCallPaused:{
            break;
        }
        case LinphoneCallPausedByRemote:{
            NSLog(@"HOTLINE: LinphoneCallUpdatedByRemote");
            break;
        }
            
        case LinphoneCallEnd:{
            NSLog(@"HOTLINE: LinphoneCallEnd");
            [[PhoneMainView instance] popCurrentView];
            break;
        }
        case LinphoneCallError:{
            NSLog(@"HOTLINE: LinphoneCallError");
            [[PhoneMainView instance] popCurrentView];
            break;
        }
        default:
            break;
    }
}

- (void)callDurationUpdate {
    int duration;
    list = linphone_core_get_calls([LinphoneManager getLc]);
    if (list != NULL) {
        duration = linphone_call_get_duration((LinphoneCall*)list->data);
    }else{
        duration = 0;
    }
    
    lbTime.text = [LinphoneUtils durationToString:duration];
}

- (void)setupUIForView
{
    float wAvatar = 140.0;
    float wIcon = 75.0;
    
    imgHotline.frame = CGRectMake((SCREEN_WIDTH-wAvatar)/2, SCREEN_HEIGHT*2/9, wAvatar, wAvatar);
    
    CGSize textSize = [AppUtils getSizeWithText:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_status_connecting] withFont:lbStatus.font andMaxWidth:SCREEN_WIDTH];
    lbStatus.frame = CGRectMake((SCREEN_WIDTH-25-textSize.width)/2, imgHotline.frame.origin.y+imgHotline.frame.size.height, textSize.width+25, 40.0);
    lbStatus.font = [UIFont fontWithName:HelveticaNeue size:20.0];
    lbStatus.textAlignment = NSTextAlignmentLeft;
    lbStatus.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_status_connecting];
    
    //  float originY = SCREEN_HEIGHT/2 + (SCREEN_HEIGHT/2 - wIcon)/2;
    float originY = SCREEN_HEIGHT - wIcon - 70.0;
    
    btnEndCall.frame = CGRectMake((SCREEN_WIDTH-wIcon)/2, originY, wIcon, wIcon);
    [btnEndCall setBackgroundImage:[UIImage imageNamed:@"decline_call_over"]
                          forState:UIControlStateHighlighted];
    [btnEndCall addTarget:self
                   action:@selector(endHotlineCall)
         forControlEvents:UIControlEventTouchUpInside];
    
    lbTime.frame = CGRectMake(0, btnEndCall.frame.origin.y-10-30, SCREEN_WIDTH, 30);
    lbTime.backgroundColor = UIColor.clearColor;
    lbTime.font = [UIFont fontWithName:HelveticaNeue size:26.0];
    
    float wSmallIcon = (wIcon-20);
    btnSpeaker.frame = CGRectMake(btnEndCall.frame.origin.x-20-wSmallIcon, originY+(wIcon-wSmallIcon)/2, wSmallIcon, wSmallIcon);
    [btnSpeaker setBackgroundImage:[UIImage imageNamed:@"call_speaker_on"] forState:UIControlStateNormal];
    [btnSpeaker setBackgroundImage:[UIImage imageNamed:@"call_speaker_on_selected"]
                          forState:UIControlStateHighlighted];
    [btnSpeaker setBackgroundImage:[UIImage imageNamed:@"call_speaker_on_selected"]
                          forState:UIControlStateSelected];
    btnSpeaker.layer.cornerRadius = wSmallIcon/2;
    btnSpeaker.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0)
                                                  blue:(255/255.0) alpha:0.15];
    
    btnMute.frame = CGRectMake(btnEndCall.frame.origin.x+btnEndCall.frame.size.width+20, btnSpeaker.frame.origin.y, wSmallIcon, wSmallIcon);
    [btnMute setBackgroundImage:[UIImage imageNamed:@"call_microphone_off"]
                       forState:UIControlStateNormal];
    [btnMute setBackgroundImage:[UIImage imageNamed:@"call_microphone_off_selected"]
                       forState:UIControlStateHighlighted];
    [btnMute setBackgroundImage:[UIImage imageNamed:@"call_microphone_off_selected"]
                       forState:UIControlStateSelected];
    btnMute.layer.cornerRadius = btnSpeaker.layer.cornerRadius;
    btnMute.backgroundColor = btnSpeaker.backgroundColor;
    
    
    return;
    /*
    lbStatus.frame = CGRectMake(0, 0, SCREEN_WIDTH, 80.0);
    lbStatus.backgroundColor = [UIColor colorWithRed:(0/255.0) green:(0/255.0)
                                                blue:(0/255.0) alpha:0.1];
    lbStatus.font = [UIFont fontWithName:HelveticaNeueBold size:30.0];
    
    lbTime.frame = CGRectMake(0, lbStatus.frame.origin.y+lbStatus.frame.size.height, SCREEN_WIDTH, 50);
    lbTime.backgroundColor = UIColor.clearColor;
    lbTime.font = [UIFont fontWithName:HelveticaNeue size:26.0];
    
    imgHotline.frame = CGRectMake((SCREEN_WIDTH-wAvatar)/2, (SCREEN_HEIGHT-wAvatar)/2, wAvatar, wAvatar);
    
    //  float originY = SCREEN_HEIGHT/2 + (SCREEN_HEIGHT/2 - wIcon)/2;
    float originY = SCREEN_HEIGHT - wIcon - 70.0;
    
    btnEndCall.frame = CGRectMake((SCREEN_WIDTH-wIcon)/2, originY, wIcon, wIcon);
    [btnEndCall setBackgroundImage:[UIImage imageNamed:@"decline_call_over"]
                          forState:UIControlStateHighlighted];
    [btnEndCall addTarget:self
                   action:@selector(endHotlineCall)
         forControlEvents:UIControlEventTouchUpInside];
    
    float wSmallIcon = (wIcon-20);
    btnSpeaker.frame = CGRectMake(btnEndCall.frame.origin.x-20-wSmallIcon, originY+(wIcon-wSmallIcon)/2, wSmallIcon, wSmallIcon);
    [btnSpeaker setBackgroundImage:[UIImage imageNamed:@"call_speaker_on"] forState:UIControlStateNormal];
    [btnSpeaker setBackgroundImage:[UIImage imageNamed:@"call_speaker_on_selected"]
                          forState:UIControlStateHighlighted];
    [btnSpeaker setBackgroundImage:[UIImage imageNamed:@"call_speaker_on_selected"]
                          forState:UIControlStateSelected];
    btnSpeaker.layer.cornerRadius = wSmallIcon/2;
    btnSpeaker.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0)
                                                  blue:(255/255.0) alpha:0.15];
    
    btnMute.frame = CGRectMake(btnEndCall.frame.origin.x+btnEndCall.frame.size.width+20, btnSpeaker.frame.origin.y, wSmallIcon, wSmallIcon);
    [btnMute setBackgroundImage:[UIImage imageNamed:@"call_microphone_off"]
                       forState:UIControlStateNormal];
    [btnMute setBackgroundImage:[UIImage imageNamed:@"call_microphone_off_selected"]
                       forState:UIControlStateHighlighted];
    [btnMute setBackgroundImage:[UIImage imageNamed:@"call_microphone_off_selected"]
                       forState:UIControlStateSelected];
    btnMute.layer.cornerRadius = btnSpeaker.layer.cornerRadius;
    btnMute.backgroundColor = btnSpeaker.backgroundColor;   */
}

- (void)endHotlineCall {
    linphone_core_terminate_all_calls([LinphoneManager getLc]);
}

- (void)updateLabelConnecting {
    NSString *result = [NSString stringWithFormat:@"%@....", [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_status_connecting]];
    if ([lbStatus.text isEqualToString: result]) {
        lbStatus.text = [NSString stringWithFormat:@"%@", [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_status_connecting]];
    }else{
        lbStatus.text = [NSString stringWithFormat:@"%@.", lbStatus.text];
    }
}

@end
