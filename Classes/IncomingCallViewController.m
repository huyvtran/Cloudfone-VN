//
//  IncomingCallViewController.m
//  linphone
//
//  Created by Hung Ho on 7/6/17.
//
//

#import "IncomingCallViewController.h"
#import "StatusBarView.h"
#import "NSData+Base64.h"
#import "NSDatabase.h"

@interface IncomingCallViewController ()
{
    HMLocalization *localization;
}
@end

@implementation IncomingCallViewController
@synthesize call, delegate;

@synthesize _viewHeader, _bgHeader, _lbName, _lbPhone;
@synthesize _imgBackground, _imgAvatar, _lbIncoming, _btnDecline, _lbSepa, _btnAccept;

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
    if (compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:nil
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

#pragma mark - My Controller

- (void)viewDidLoad {
    [super viewDidLoad];
    //  My code here
    localization = [HMLocalization sharedInstance];
    
    [self setupUIForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(callUpdateEvent:)
                                               name:kLinphoneCallUpdate object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NSNotificationCenter.defaultCenter removeObserver:self name:kLinphoneCallUpdate object:nil];
    call = NULL;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)_btnDeclinePressed:(UIButton *)sender {
    //  linphone_core_terminate_call(LC, call);
    [delegate incomingCallDeclined: call];
}

- (IBAction)_btnAnswerPressed:(UIButton *)sender {
    [delegate incomingCallAccepted:call evenWithVideo:NO];
    //  [delegate incomingCallAccepted:call evenWithVideo:NO];
}

#pragma mark - my functions

- (void)setupUIForView {
    //  Setup font cho các UI
    [_btnDecline setBackgroundImage:[UIImage imageNamed:@"decline_call_over.png"]
                           forState:UIControlStateHighlighted];
    [_btnAccept setBackgroundImage:[UIImage imageNamed:@"answer_call_over.png"]
                          forState:UIControlStateHighlighted];
    
    //  Background status
    UILabel *lbBgStatus = [[UILabel alloc] initWithFrame: CGRectMake(0, -[LinphoneAppDelegate sharedInstance]._hStatus, SCREEN_WIDTH, [LinphoneAppDelegate sharedInstance]._hStatus)];
    [lbBgStatus setBackgroundColor:[UIColor colorWithRed:(21/255.0) green:(41/255.0)
                                                    blue:(52/255.0) alpha:1.0]];
    [self.view addSubview: lbBgStatus];
    
    float hHeader = SCREEN_WIDTH*445/1280;
    [_viewHeader setFrame: CGRectMake(0, 0, SCREEN_WIDTH, hHeader)];
    [_bgHeader setFrame: CGRectMake(0, 0, _viewHeader.frame.size.width, _viewHeader.frame.size.height)];
    [_lbName setFrame: CGRectMake(20, (hHeader-80)/2, _viewHeader.frame.size.width-40, 40)];
    [_lbName setFont:[UIFont fontWithName:HelveticaNeue size:30.0]];
    
    [_lbPhone setFrame: CGRectMake(_lbName.frame.origin.x, _lbName.frame.origin.y+_lbName.frame.size.height, _lbName.frame.size.width, _lbPhone.frame.size.height)];
    [_lbPhone setFont:[UIFont fontWithName:HelveticaNeue size:20.0]];
    
    [_imgBackground setFrame: CGRectMake(0, _viewHeader.frame.origin.y+_viewHeader.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT-[LinphoneAppDelegate sharedInstance]._hStatus-hHeader)];
    [_imgAvatar setFrame: CGRectMake(SCREEN_WIDTH/3-10, _imgBackground.frame.origin.y+SCREEN_WIDTH/6, SCREEN_WIDTH/3+20, SCREEN_WIDTH/3+20)];
    [_imgAvatar setClipsToBounds: true];
    [_imgAvatar.layer setCornerRadius: 10];
    
    [_lbIncoming setFrame: CGRectMake(_lbName.frame.origin.x, _imgAvatar.frame.origin.y+_imgAvatar.frame.size.height+10, _lbName.frame.size.width, 30)];
    [_lbIncoming setFont:[UIFont fontWithName:HelveticaNeue size:16.0]];
    
    float wButton = 60.0;
    float space = 25.0;
    float marginX = (SCREEN_WIDTH-(wButton + 40 + 40 + wButton))/2;
    [_btnDecline setFrame: CGRectMake(marginX, SCREEN_HEIGHT-[LinphoneAppDelegate sharedInstance]._hStatus-wButton-space, wButton, wButton)];
    [_btnAccept setFrame: CGRectMake(_btnDecline.frame.origin.x+_btnDecline.frame.size.width+2*40, _btnDecline.frame.origin.y, _btnDecline.frame.size.width, _btnDecline.frame.size.height)];
    [_lbSepa setFrame: CGRectMake(SCREEN_WIDTH/2, _btnDecline.frame.origin.y, 1, _btnDecline.frame.size.height)];
}



- (void)setCall:(LinphoneCall *)aCall {
    call = aCall;
    [self update];
    [self callUpdate:call state:linphone_call_get_state(aCall)];
}

- (void)update {
    [self view]; //Force view load
    
    [_imgAvatar setImage:[UIImage imageNamed:@"unknown_large.png"]];
    
    const LinphoneAddress* addr = linphone_call_get_remote_address(call);
    if (addr != NULL) {
        NSString *phonenumber = [NSString stringWithUTF8String:linphone_address_get_username(addr)];
        
        NSArray *info = [NSDatabase getNameAndAvatarOfContactWithPhoneNumber: phonenumber];
        NSString *name = [info objectAtIndex: 0];
        NSString *avatar = [info objectAtIndex: 1];
        if ([name isEqualToString:@""]) {
            _lbName.text = [localization localizedStringForKey: text_unknown];
        }else{
            _lbName.text = name;
        }
        
        _lbPhone.text = phonenumber;
        
        if (![avatar isEqualToString:@""]) {
            [_imgAvatar setImage:[UIImage imageWithData:[NSData dataFromBase64String:avatar]]];
        }else{
            [_imgAvatar setImage:[UIImage imageNamed:@"unknown_large.png"]];
        }
    }
}

- (void)callUpdate:(LinphoneCall *)acall state:(LinphoneCallState)astate {
    if (call == acall && (astate == LinphoneCallEnd || astate == LinphoneCallError)) {
        [delegate incomingCallAborted:call];
    } else if ([LinphoneManager.instance lpConfigBoolForKey:@"auto_answer"]) {
        LinphoneCallState state = linphone_call_get_state(call);
        if (state == LinphoneCallIncomingReceived) {
            NSLog(@"Auto answering call");
            [self _btnAnswerPressed:nil];
        }
    }
}

#pragma mark - Event Functions

- (void)callUpdateEvent:(NSNotification *)notif {
    LinphoneCall *acall = [[notif.userInfo objectForKey:@"call"] pointerValue];
    LinphoneCallState astate = [[notif.userInfo objectForKey:@"state"] intValue];
    [self callUpdate:acall state:astate];
}


@end
