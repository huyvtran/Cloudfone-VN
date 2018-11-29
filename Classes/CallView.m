/* InCallViewController.h
 *
 * Copyright (C) 2009  Belledonne Comunications, Grenoble, France
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

#import <AVFoundation/AVAudioSession.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AddressBook/AddressBook.h>
#import <AudioToolbox/AudioToolbox.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/QuartzCore.h>
#import <UserNotifications/UserNotifications.h>

#import "CallView.h"
#import "CallSideMenuView.h"
#import "LinphoneManager.h"
#import "Utils.h"

#include "linphone/linphonecore.h"

#import "NSData+Base64.h"
#import "UIConferenceCell.h"
#import "ContactDetailObj.h"
#import "UIMiniKeypad.h"

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import "UploadPicture.h"
#import "UIImageView+WebCache.h"
#import "ConferenceTableViewCell.h"

#define kMaxRadius 200
#define kMaxDuration 10

#define MIN_FOR_CONFERENCE 2

void message_received(LinphoneCore *lc, LinphoneChatRoom *room, const LinphoneAddress *from, const char *message) {
    printf(" Message [%s] received from [%s] \n",message,linphone_address_as_string (from));
}

const NSInteger SECURE_BUTTON_TAG = 5;
const NSInteger MINI_KEYPAD_TAG = 101;

@interface CallView (){
    LinphoneAppDelegate *appDelegate;
    
    float wCollection;
    float marginX;
    
    BOOL changeConference;
    
    const MSList *list;
    
    NSTimer *updateTimeConf;
    UIMiniKeypad *viewKeypad;
    
    NSTimer *qualityTimer;
    
    BOOL needEnableSpeaker;
    LinphoneCallDir callDirection;
}

@end

@implementation CallView {
	BOOL hiddenVolume;
}
@synthesize bgCall, lbPhoneNumber, lbMute, lbKeypad, lbSpeaker, icAddCall, lbAddCall, lbPause, lbTransfer;
@synthesize _lbQuality, _viewCommand, _scrollView;
@synthesize detailConference, lbConfQuality, lbConfName, lbConfDuration, btnAddCallConf, avatarConference, collectionConference, btnConfMute, btnConfHold, btnConfSpeaker, btnEndConf, tbConf;

@synthesize durationTimer, phoneNumber;

#pragma mark - Lifecycle Functions

- (id)init {
	self = [super initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle mainBundle]];
	if (self != nil) {
		singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleControls:)];
		videoZoomHandler = [[VideoZoomHandler alloc] init];
		videoHidden = TRUE;
	}
	return self;
}

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

#pragma mark - ViewController Functions

- (void)viewDidLoad {
	[super viewDidLoad];

    //  Add ney by Khai Le on 09/11/2017
    appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self setupUIForView];
    
	_routesEarpieceButton.enabled = !IPAD;

// TODO: fixme! video preview frame is too big compared to openGL preview
// frame, so until this is fixed, temporary disabled it.
#if 0
#endif
    singleFingerTap.numberOfTapsRequired = 2;
    singleFingerTap.cancelsTouchesInView = NO;

	[_zeroButton setDigit:'0'];
	[_zeroButton setDtmf:true];
	[_oneButton setDigit:'1'];
	[_oneButton setDtmf:true];
	[_twoButton setDigit:'2'];
	[_twoButton setDtmf:true];
	[_threeButton setDigit:'3'];
	[_threeButton setDtmf:true];
	[_fourButton setDigit:'4'];
	[_fourButton setDtmf:true];
	[_fiveButton setDigit:'5'];
	[_fiveButton setDtmf:true];
	[_sixButton setDigit:'6'];
	[_sixButton setDtmf:true];
	[_sevenButton setDigit:'7'];
	[_sevenButton setDtmf:true];
	[_eightButton setDigit:'8'];
	[_eightButton setDtmf:true];
	[_nineButton setDigit:'9'];
	[_nineButton setDtmf:true];
	[_starButton setDigit:'*'];
	[_starButton setDtmf:true];
	[_hashButton setDigit:'#'];
	[_hashButton setDtmf:true];
    
    
    [_speakerButton setHidden: YES];
    
    //  Added by Khai Le on 06/10/2018
    _durationLabel.text = [appDelegate.localization localizedStringForKey:@"Calling"];
    _durationLabel.textColor = UIColor.whiteColor;
    
    [self addScrollview];
}

- (void)dealloc {
	[PhoneMainView.instance.view removeGestureRecognizer:singleFingerTap];
	// Remove all observer
	[NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

    int count = linphone_core_get_calls_nb([LinphoneManager getLc]);
    if (count > 0) {
        phoneNumber = [self getPhoneNumberOfCall];
    }
    
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"\n\n---------->GO TO CallView"] toFilePath:[LinphoneAppDelegate sharedInstance].logFilePath];
    
    //  [Khai le - 03/11/2018]
    PhoneObject *contact = [ContactUtils getContactPhoneObjectWithNumber: phoneNumber];
    if (![AppUtils isNullOrEmpty: contact.avatar]) {
        _avatarImage.image = [UIImage imageWithData: [NSData dataFromBase64String:contact.avatar]];
    }else{
        _avatarImage.image = [UIImage imageNamed:@"no_avatar.png"];
    }
    
    if (contact.phoneType == ePBXPhone) {
        //  Download avatar of user if exists
        [self checkToDownloadAvatarOfUser: phoneNumber];
    }
    
    //  Leo Kelvin
    _bottomBar.hidden = YES;
    _bottomBar.clipsToBounds = YES;
    
	LinphoneManager.instance.nextCallIsTransfer = NO;
    _nameLabel.text = @"";

	// Update on show
	[self hideRoutes:TRUE animated:FALSE];
	[self hideOptions:TRUE animated:FALSE];
	[self hidePad:TRUE animated:FALSE];
	[self hideSpeaker:LinphoneManager.instance.bluetoothAvailable];
	[self callDurationUpdate];
	[self onCurrentCallChange];
	
	// Enable tap
    singleFingerTap.enabled = YES;
    
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(bluetoothAvailabilityUpdateEvent:)
											   name:kLinphoneBluetoothAvailabilityUpdate object:nil];
    
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(callUpdateEvent:)
											   name:kLinphoneCallUpdate object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(headsetPluginChanged:)
                                               name:@"headsetPluginChanged" object:nil];
    //  Update address
    [self updateAddress];
    
    /*--Khong co goi conference--*/
    if(count < MIN_FOR_CONFERENCE ){
        [self btnHideKeypadPressed];
        
        _callView.hidden = NO;
        _conferenceView.hidden = YES;
        if (count == 0) {
            _durationLabel.text = [appDelegate.localization localizedStringForKey:@"Calling"];
            _durationLabel.textColor = UIColor.whiteColor;
        }else{
            LinphoneCall *curCall = linphone_core_get_current_call([LinphoneManager getLc]);
            if (curCall == NULL) {
                [[PhoneMainView instance] popCurrentView];
            }else{
                callDirection = linphone_call_get_dir(curCall);
                if (callDirection == LinphoneCallIncoming) {
                    [self countUpTimeForCall];
                    [self updateQualityForCall];
                }
            }
        }
    }else{
        _callView.hidden = YES;
        _conferenceView.hidden = NO;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.halo.position = _avatarImage.center;
    if (_avatarImage.frame.origin.y == appDelegate._hStatus + 35.0 + 10) {
        self.halo.hidden = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	UIDevice.currentDevice.proximityMonitoringEnabled = YES;

	[PhoneMainView.instance setVolumeHidden:TRUE];
	hiddenVolume = TRUE;

	// we must wait didAppear to reset fullscreen mode because we cannot change it in viewwillappear
	LinphoneCall *call = linphone_core_get_current_call(LC);
	LinphoneCallState state = (call != NULL) ? linphone_call_get_state(call) : 0;
	[self callUpdate:call state:state animated:FALSE message:@""];
    
    [self requestAccessToMicroIfNot];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

    
	if (hiddenVolume) {
		[PhoneMainView.instance setVolumeHidden:FALSE];
		hiddenVolume = FALSE;
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

	[[UIApplication sharedApplication] setIdleTimerDisabled:false];
	UIDevice.currentDevice.proximityMonitoringEnabled = NO;

	[PhoneMainView.instance fullScreen:false];
	// Disable tap
	[singleFingerTap setEnabled:FALSE];

	if (linphone_core_get_calls_nb(LC) == 0) {
		// reseting speaker button because no more call
		_speakerButton.selected = FALSE;
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	[self hideStatusBar:!videoHidden && (_nameLabel.alpha <= 0.f)];
}

- (void)updateBottomBar:(LinphoneCall *)call state:(LinphoneCallState)state {
	//  [_speakerButton update];
	[_microButton update];
	//  [_callPauseButton update];
	[_conferencePauseButton update];
	[_hangupButton update];

	_optionsButton.enabled = (!call || !linphone_core_sound_resources_locked(LC));
    //  Closed by Khai Le on 07/10/2018
	//  _optionsTransferButton.enabled = call && !linphone_core_sound_resources_locked(LC);
	// enable conference button if 2 calls are presents and at least one is not in the conference
	int confSize = linphone_core_get_conference_size(LC) - (linphone_core_is_in_conference(LC) ? 1 : 0);
	_optionsConferenceButton.enabled =
		((linphone_core_get_calls_nb(LC) > 1) && (linphone_core_get_calls_nb(LC) != confSize));

	switch (state) {
		case LinphoneCallEnd:
		case LinphoneCallError:
		case LinphoneCallIncoming:
		case LinphoneCallOutgoing:
			[self hidePad:TRUE animated:TRUE];
			[self hideOptions:TRUE animated:TRUE];
			[self hideRoutes:TRUE animated:TRUE];
		default:
			break;
	}
}

- (void)toggleControls:(id)sender {
	
}

- (void)hideStatusBar:(BOOL)hide {
	/* we cannot use [PhoneMainView.instance show]; because it will automatically
	 resize current view to fill empty space, which will resize video. This is
	 indesirable since we do not want to crop/rescale video view */
	PhoneMainView.instance.mainViewController.statusBarView.hidden = hide;
}

- (void)callDurationUpdate
{
//    int size = linphone_core_get_conference_size(LC);
//    NSLog(@"KL-----size: %d", size);
    int duration;
    list = linphone_core_get_calls([LinphoneManager getLc]);
    if (list != NULL) {
        duration = linphone_call_get_duration((LinphoneCall*)list->data);
        _durationLabel.text = [LinphoneUtils durationToString:duration];
        _durationLabel.textColor = UIColor.greenColor;
        _lbQuality.hidden = NO;
    }else{
        duration = 0;
        _lbQuality.hidden = YES;
    }
}

//  Call quality
- (void)callQualityUpdate {
    LinphoneCall *call;
    list = linphone_core_get_calls([LinphoneManager getLc]);
    if (list == NULL) {
        if (qualityTimer != nil) {
            [qualityTimer invalidate];
            qualityTimer = nil;
        }
        return;
    }
    call = (LinphoneCall*)list->data;
    
    if(call != NULL) {
        //FIXME double check call state before computing, may cause core dump
        float quality = linphone_call_get_average_quality(call);
        if (quality < 0) {
            //  Hide call quality value if have not connected yet
            viewKeypad.lbQualityValue.hidden = YES;
        }else if(quality < 1) {
            NSString *qualityValue = [appDelegate.localization localizedStringForKey:@"Worse"];
            NSString *quality = [NSString stringWithFormat:@"%@: %@", [appDelegate.localization localizedStringForKey:@"Quality"], qualityValue];
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString: quality];
            [attr addAttribute:NSForegroundColorAttributeName value:UIColor.whiteColor range:NSMakeRange(0, quality.length)];
            [attr addAttribute:NSForegroundColorAttributeName value:UIColor.redColor range:NSMakeRange(quality.length-qualityValue.length, qualityValue.length)];
            
            _lbQuality.attributedText = attr;
            viewKeypad.lbQualityValue.attributedText = attr;
            viewKeypad.lbQualityValue.hidden = NO;
            
        } else if (quality < 2) {
            NSString *qualityValue = [appDelegate.localization localizedStringForKey:@"Very low"];
            NSString *quality = [NSString stringWithFormat:@"%@: %@", [appDelegate.localization localizedStringForKey:@"Quality"], qualityValue];
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString: quality];
            [attr addAttribute:NSForegroundColorAttributeName value:UIColor.whiteColor range:NSMakeRange(0, quality.length)];
            [attr addAttribute:NSForegroundColorAttributeName value:UIColor.orangeColor range:NSMakeRange(quality.length-qualityValue.length, qualityValue.length)];
            
            _lbQuality.attributedText = attr;
            viewKeypad.lbQualityValue.attributedText = attr;
            viewKeypad.lbQualityValue.hidden = NO;
            
        } else if (quality < 3) {
            NSString *qualityValue = [appDelegate.localization localizedStringForKey:@"Low"];
            NSString *quality = [NSString stringWithFormat:@"%@: %@", [appDelegate.localization localizedStringForKey:@"Quality"], qualityValue];
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString: quality];
            [attr addAttribute:NSForegroundColorAttributeName value:UIColor.whiteColor range:NSMakeRange(0, quality.length)];
            [attr addAttribute:NSForegroundColorAttributeName value:UIColor.whiteColor range:NSMakeRange(quality.length-qualityValue.length, qualityValue.length)];
            
            _lbQuality.attributedText = attr;
            viewKeypad.lbQualityValue.attributedText = attr;
            viewKeypad.lbQualityValue.hidden = NO;
            
        } else if(quality < 4){
            NSString *qualityValue = [appDelegate.localization localizedStringForKey:@"Average"];
            NSString *quality = [NSString stringWithFormat:@"%@: %@", [appDelegate.localization localizedStringForKey:@"Quality"], qualityValue];
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString: quality];
            [attr addAttribute:NSForegroundColorAttributeName value:UIColor.whiteColor range:NSMakeRange(0, quality.length)];
            [attr addAttribute:NSForegroundColorAttributeName value:UIColor.greenColor range:NSMakeRange(quality.length-qualityValue.length, qualityValue.length)];
            
            _lbQuality.attributedText = attr;
            viewKeypad.lbQualityValue.attributedText = attr;
            viewKeypad.lbQualityValue.hidden = NO;
            
        } else{
            NSString *qualityValue = [appDelegate.localization localizedStringForKey:@"Good"];
            NSString *quality = [NSString stringWithFormat:@"%@: %@", [appDelegate.localization localizedStringForKey:@"Quality"], qualityValue];
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString: quality];
            [attr addAttribute:NSForegroundColorAttributeName value:UIColor.whiteColor range:NSMakeRange(0, quality.length)];
            [attr addAttribute:NSForegroundColorAttributeName value:UIColor.greenColor range:NSMakeRange(quality.length-qualityValue.length, qualityValue.length)];
            
            _lbQuality.attributedText = attr;
            viewKeypad.lbQualityValue.attributedText = attr;
            viewKeypad.lbQualityValue.hidden = NO;
        }
    }
}

- (void)onCurrentCallChange {
	LinphoneCall *call = linphone_core_get_current_call(LC);

	//  _callView.hidden = !call;
	//  _conferenceView.hidden = !linphone_core_is_in_conference(LC);
	//  _callPauseButton.hidden = !call && !linphone_core_is_in_conference(LC);

	//  [_callPauseButton setType:UIPauseButtonType_CurrentCall call:call];
	//  [_conferencePauseButton setType:UIPauseButtonType_Conference call:call];

    //  Leo Kelvin
    //  _callView.hidden = !call;
    
    BOOL check = !call && !linphone_core_is_in_conference(LC);
    if (check) {
        _callPauseButton.selected = YES;
    }else{
        _callPauseButton.selected = NO;
    }
    [_callPauseButton setType:UIPauseButtonType_CurrentCall call:call];
    /*
    _conferenceView.hidden = !linphone_core_is_in_conference(LC);
    [_conferencePauseButton setType:UIPauseButtonType_Conference call:call];    */
    
	if (!_callView.hidden) {
        /*  Leo Kelvin
		const LinphoneAddress *addr = linphone_call_get_remote_address(call);
		[ContactDisplay setDisplayNameLabel:_nameLabel forAddress:addr];
		char *uri = linphone_address_as_string_uri_only(addr);
		ms_free(uri);
		[_avatarImage setImage:[FastAddressBook imageForAddress:addr thumbnail:NO] bordered:YES withRoundedRadius:YES]; */
	}
}

- (void)hidePad:(BOOL)hidden animated:(BOOL)animated {
	if (hidden) {
		[_numpadButton setOff];
	} else {
		[_numpadButton setOn];
	}
	if (hidden != _numpadView.hidden) {
		if (animated) {
			[self hideAnimation:hidden forView:_numpadView completion:nil];
		} else {
			[_numpadView setHidden:hidden];
		}
	}
}

- (void)hideRoutes:(BOOL)hidden animated:(BOOL)animated {
	if (hidden) {
		[_routesButton setOff];
	} else {
		[_routesButton setOn];
	}

	_routesBluetoothButton.selected = LinphoneManager.instance.bluetoothEnabled;
	_routesEarpieceButton.selected = !_routesBluetoothButton.selected;

	if (hidden != _routesView.hidden) {
		if (animated) {
			[self hideAnimation:hidden forView:_routesView completion:nil];
		} else {
			[_routesView setHidden:hidden];
		}
	}
}

- (void)hideOptions:(BOOL)hidden animated:(BOOL)animated {
	if (hidden) {
		[_optionsButton setOff];
	} else {
		[_optionsButton setOn];
	}
	if (hidden != _optionsView.hidden) {
		if (animated) {
			[self hideAnimation:hidden forView:_optionsView completion:nil];
		} else {
			[_optionsView setHidden:hidden];
		}
	}
}

- (void)hideSpeaker:(BOOL)hidden {
	_speakerButton.hidden = hidden;
	_routesButton.hidden = !hidden;
}

#pragma mark - Event Functions

- (void)bluetoothAvailabilityUpdateEvent:(NSNotification *)notif {
    dispatch_async(dispatch_get_main_queue(), ^{
        bool available = [[notif.userInfo objectForKey:@"available"] intValue];
        [self hideSpeaker:available];
    });
}

- (void)callUpdateEvent:(NSNotification *)notif {
    NSString *message = [notif.userInfo objectForKey:@"message"];
	LinphoneCall *call = [[notif.userInfo objectForKey:@"call"] pointerValue];
	LinphoneCallState state = [[notif.userInfo objectForKey:@"state"] intValue];
    [self callUpdate:call state:state animated:TRUE message: message];
}

- (NSString *)createDirectory {
    NSString *appFolderPath = [[NSBundle mainBundle] resourcePath];
    NSString *path = [NSString stringWithFormat:@"%@/%@", appFolderPath, @"test.mp3"];
    NSLog(@"%@", path);
    return path;
}

- (void)callUpdate:(LinphoneCall *)call state:(LinphoneCallState)state animated:(BOOL)animated message: (NSString *)message
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"\n%s", __FUNCTION__] toFilePath:appDelegate.logFilePath];
    
    // Add tất cả các cuộc gọi vào nhóm
    if (linphone_core_get_calls_nb(LC) >= 2) {
        linphone_core_add_all_to_conference([LinphoneManager getLc]);
    }
    
	[self updateBottomBar:call state:state];
	if (hiddenVolume) {
		[PhoneMainView.instance setVolumeHidden:FALSE];
		hiddenVolume = FALSE;
	}
    
    /*--Khong co goi conference--*/
    if(linphone_core_get_calls_nb([LinphoneManager getLc]) < MIN_FOR_CONFERENCE ){
        [self btnHideKeypadPressed];
        
        _callView.hidden = NO;
        _conferenceView.hidden = YES;
    }else{
        _callView.hidden = YES;
        _conferenceView.hidden = NO;
    }

	static LinphoneCall *currentCall = NULL;
	if (!currentCall || linphone_core_get_current_call(LC) != currentCall) {
		currentCall = linphone_core_get_current_call(LC);
		[self onCurrentCallChange];
	}

	// Fake call update
	if (call == NULL) {
		return;
	}

	if (state != LinphoneCallPausedByRemote) {
		_pausedByRemoteView.hidden = YES;
	}

	switch (state) {
        case LinphoneCallOutgoingRinging:{
            [WriteLogsUtils writeLogContent:@"Call state is LinphoneCallOutgoingRinging"
                                 toFilePath:appDelegate.logFilePath];
            
            _durationLabel.text = [appDelegate.localization localizedStringForKey:@"Ringing"];
            _durationLabel.textColor = UIColor.whiteColor;
            
            [self getPhoneNumberOfCall];
            break;
        }
        case LinphoneCallIncomingReceived:{
            [WriteLogsUtils writeLogContent:@"Call state is LinphoneCallIncomingReceived"
                                 toFilePath:appDelegate.logFilePath];
            
            [self getPhoneNumberOfCall];
            NSLog(@"incomming");
            break;
        }
        case LinphoneCallOutgoingProgress:{
            [WriteLogsUtils writeLogContent:@"Call state is LinphoneCallOutgoingProgress"
                                 toFilePath:appDelegate.logFilePath];
            
            _durationLabel.text = [appDelegate.localization localizedStringForKey:@"Calling"];
            _durationLabel.textColor = UIColor.whiteColor;
            
            break;
        }
        case LinphoneCallOutgoingInit:{
            [WriteLogsUtils writeLogContent:@"Call state is LinphoneCallOutgoingInit"
                                 toFilePath:appDelegate.logFilePath];
            
            //  Added by Khai Le on 21/10/2018
            if (self.halo == nil) {
                [self addAnimationForOutgoingCall];
            }
            self.halo.hidden = YES;
            [self.halo start];
            
            // Nếu không phải Outgoing trong conference thì set disable các button
            if (!changeConference) {
                _microButton.enabled = YES;
                _numpadButton.enabled = YES;
                _speakerButton.enabled = YES;
                icAddCall.enabled = NO;
                _callPauseButton.enabled = NO;
                _optionsTransferButton.enabled = NO;
            }
            break;
        }
        case LinphoneCallConnected:{
            [WriteLogsUtils writeLogContent:@"Call state is LinphoneCallConnected"
                                 toFilePath:appDelegate.logFilePath];
            
            //  Check if in call with hotline
            if (![phoneNumber isEqualToString:hotline]) {
                icAddCall.enabled = YES;
                _optionsTransferButton.enabled = YES;
            }else{
                icAddCall.enabled = NO;
                _optionsTransferButton.enabled = NO;
                
            }
            _numpadButton.enabled = YES;
            _callPauseButton.enabled = YES;
            _microButton.enabled = YES;
            
            _lbQuality.hidden = NO;
            
            // Add tất cả các cuộc gọi vào nhóm
            if (linphone_core_get_calls_nb(LC) >= 2) {
                linphone_core_add_all_to_conference([LinphoneManager getLc]);
            }
            
            [self countUpTimeForCall];
            [self updateQualityForCall];
            
            //  Stop halo waiting
            self.halo.hidden = YES;
            [self.halo start];
            self.halo = nil;
            [self.halo removeFromSuperlayer];
            
            break;
        }
		case LinphoneCallStreamsRunning: {
            [WriteLogsUtils writeLogContent:@"Call state is LinphoneCallStreamsRunning"
                                 toFilePath:appDelegate.logFilePath];
            
            // check video
			if (!linphone_call_params_video_enabled(linphone_call_get_current_params(call))) {
				const LinphoneCallParams *param = linphone_call_get_current_params(call);
				const LinphoneCallAppData *callAppData =
					(__bridge const LinphoneCallAppData *)(linphone_call_get_user_pointer(call));
				if (state == LinphoneCallStreamsRunning && callAppData->videoRequested &&
					linphone_call_params_low_bandwidth_enabled(param)) {
				}
			}
            icAddCall.enabled = YES;
            _numpadButton.enabled = YES;
            _callPauseButton.enabled = YES;
            _microButton.enabled = YES;
            _optionsTransferButton.enabled = YES;
            
            // Add tất cả các cuộc gọi vào nhóm
            if (linphone_core_get_calls_nb(LC) >= 2) {
                linphone_core_add_all_to_conference([LinphoneManager getLc]);
            }
            
			break;
		}
		case LinphoneCallUpdatedByRemote: {
			const LinphoneCallParams *current = linphone_call_get_current_params(call);
			const LinphoneCallParams *remote = linphone_call_get_remote_params(call);

			/* remote wants to add video */
			if ((linphone_core_video_display_enabled(LC) && !linphone_call_params_video_enabled(current) &&
				 linphone_call_params_video_enabled(remote)) &&
				(!linphone_core_get_video_policy(LC)->automatically_accept ||
				 (([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) &&
				  floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max))) {
				linphone_core_defer_call_update(LC, call);
				
			} else if (linphone_call_params_video_enabled(current) && !linphone_call_params_video_enabled(remote)) {
				
			}
			break;
		}
		case LinphoneCallPausing:
        case LinphoneCallPaused:{
            [WriteLogsUtils writeLogContent:@"Call state is LinphoneCallPaused"
                                 toFilePath:appDelegate.logFilePath];
            
            break;
        }
		case LinphoneCallPausedByRemote:
			if (call == linphone_core_get_current_call(LC)) {
				//  _pausedByRemoteView.hidden = NO;
			}
			break;
        case LinphoneCallEnd:{
            [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"Call state is LinphoneCallEnd, with message: %@", message] toFilePath:appDelegate.logFilePath];
            
            if (durationTimer != nil) {
                [durationTimer invalidate];
                durationTimer = nil;
            }
            if (qualityTimer != nil) {
                [qualityTimer invalidate];
                qualityTimer = nil;
            }
            
            //  Stop halo waiting
            self.halo.hidden = YES;
            [self.halo start];
            self.halo = nil;
            [self.halo removeFromSuperlayer];
            
            break;
        }
        case LinphoneCallError:{
            [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"Call state is LinphoneCallError, with message: %@", message] toFilePath:appDelegate.logFilePath];
            
            if (durationTimer != nil) {
                [durationTimer invalidate];
                durationTimer = nil;
            }
            if (qualityTimer != nil) {
                [qualityTimer invalidate];
                qualityTimer = nil;
            }
            [self displayCallError:call message:message];
            [self performSelector:@selector(hideCallView) withObject:nil afterDelay:2.0];
            break;
        }
        case LinphoneCallReleased:{
            [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"Call state is LinphoneCallReleased, with message: %@", message] toFilePath:appDelegate.logFilePath];
            
            if (durationTimer != nil) {
                [durationTimer invalidate];
                durationTimer = nil;
            }
            if (qualityTimer != nil) {
                [qualityTimer invalidate];
                qualityTimer = nil;
            }
            
            //  Stop halo waiting
            self.halo.hidden = YES;
            [self.halo start];
            self.halo = nil;
            [self.halo removeFromSuperlayer];
            
            [self performSelector:@selector(hideCallView) withObject:nil afterDelay:2.0];
            break;
        }
		default:
			break;
	}
}

#pragma mark - Action Functions

- (IBAction)onNumpadClick:(id)sender {
    NSArray *toplevelObject = [[NSBundle mainBundle] loadNibNamed:@"UIMiniKeypad" owner:nil options:nil];
    
    for(id currentObject in toplevelObject){
        if ([currentObject isKindOfClass:[UIMiniKeypad class]]) {
            viewKeypad = (UIMiniKeypad *) currentObject;
            break;
        }
    }
    
    viewKeypad.tag = MINI_KEYPAD_TAG;
    [viewKeypad.zeroButton setDigit:'0'];
    [viewKeypad.zeroButton setDtmf:true] ;
    [viewKeypad.oneButton    setDigit:'1'];
    [viewKeypad.oneButton setDtmf:true];
    [viewKeypad.twoButton    setDigit:'2'];
    [viewKeypad.twoButton setDtmf:true];
    [viewKeypad.threeButton  setDigit:'3'];
    [viewKeypad.threeButton setDtmf:true];
    [viewKeypad.fourButton   setDigit:'4'];
    [viewKeypad.fourButton setDtmf:true];
    [viewKeypad.fiveButton   setDigit:'5'];
    [viewKeypad.fiveButton setDtmf:true];
    [viewKeypad.sixButton    setDigit:'6'];
    [viewKeypad.sixButton setDtmf:true];
    [viewKeypad.sevenButton  setDigit:'7'];
    [viewKeypad.sevenButton setDtmf:true];
    [viewKeypad.eightButton  setDigit:'8'];
    [viewKeypad.eightButton setDtmf:true];
    [viewKeypad.nineButton   setDigit:'9'];
    [viewKeypad.nineButton setDtmf:true];
    [viewKeypad.starButton   setDigit:'*'];
    [viewKeypad.starButton setDtmf:true];
    [viewKeypad.sharpButton  setDigit:'#'];
    [viewKeypad.sharpButton setDtmf:true];
    [viewKeypad setBackgroundColor:[UIColor clearColor]];
    
    [_callView addSubview:viewKeypad];
    [self fadeIn:viewKeypad];
    
    
    [viewKeypad mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(_callView);
    }];
    [viewKeypad setupUIForView];
    
    [viewKeypad.iconBack addTarget:self
                            action:@selector(hideMiniKeypad)
                  forControlEvents:UIControlEventTouchUpInside];
    
    [viewKeypad.iconMiniKeypadEndCall addTarget:self
                                         action:@selector(endCallInMiniKeypad)
                               forControlEvents:UIControlEventTouchUpInside];
    
    [self callQualityUpdate];
}

- (void)hideMiniKeypad {
    for (UIView *subView in _callView.subviews) {
        if (subView.tag == MINI_KEYPAD_TAG) {
            [UIView animateWithDuration:.35 animations:^{
                subView.transform = CGAffineTransformMakeScale(1.3, 1.3);
                subView.alpha = 0.0;
            } completion:^(BOOL finished) {
                if (finished) {
                    [subView removeFromSuperview];
                }
            }];
        }
    }
    _numpadButton.selected = NO;
}

- (void)endCallInMiniKeypad {
    linphone_core_terminate_all_calls(LC);
}

- (void)fadeIn :(UIView*)view{
    view.transform = CGAffineTransformMakeScale(1.3, 1.3);
    view.alpha = 0.0;
    [UIView animateWithDuration:.35 animations:^{
        view.transform = CGAffineTransformMakeScale(1.0, 1.0);
        view.alpha = 1.0;
    }];
}

- (IBAction)onChatClick:(id)sender {
	[PhoneMainView.instance changeCurrentView:ChatsListView.compositeViewDescription];
}

- (IBAction)onRoutesBluetoothClick:(id)sender {
	[self hideRoutes:TRUE animated:TRUE];
	[LinphoneManager.instance setSpeakerEnabled:FALSE];
	[LinphoneManager.instance setBluetoothEnabled:TRUE];
}

- (IBAction)onRoutesEarpieceClick:(id)sender {
	[self hideRoutes:TRUE animated:TRUE];
	[LinphoneManager.instance setSpeakerEnabled:FALSE];
	[LinphoneManager.instance setBluetoothEnabled:FALSE];
}

- (IBAction)onRoutesSpeakerClick:(id)sender {
    //  [self hideRoutes:TRUE animated:TRUE];
    if (![(UIButton *)sender isSelected]) {
        [LinphoneManager.instance setBluetoothEnabled:TRUE];
        [LinphoneManager.instance setSpeakerEnabled:FALSE];
    }else{
        [LinphoneManager.instance setBluetoothEnabled:FALSE];
        [LinphoneManager.instance setSpeakerEnabled:TRUE];
    }
}

- (IBAction)onRoutesClick:(id)sender {
	if ([_routesView isHidden]) {
		[self hideRoutes:FALSE animated:ANIMATED];
	} else {
		[self hideRoutes:TRUE animated:ANIMATED];
	}
}

- (IBAction)onOptionsClick:(id)sender {
	if ([_optionsView isHidden]) {
		[self hideOptions:FALSE animated:ANIMATED];
	} else {
		[self hideOptions:TRUE animated:ANIMATED];
	}
}

- (IBAction)onOptionsTransferClick:(id)sender
{
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"\n%s", __FUNCTION__] toFilePath:appDelegate.logFilePath];
    
	[self hideOptions:TRUE animated:TRUE];
	DialerView *view = VIEW(DialerView);
	[view setAddress:@""];
	LinphoneManager.instance.nextCallIsTransfer = YES;
	[PhoneMainView.instance changeCurrentView:view.compositeViewDescription];
}

- (IBAction)onOptionsAddClick:(id)sender {
	[self hideOptions:TRUE animated:TRUE];
	DialerView *view = VIEW(DialerView);
	[view setAddress:@""];
	LinphoneManager.instance.nextCallIsTransfer = NO;
	[PhoneMainView.instance changeCurrentView:view.compositeViewDescription];
}

- (IBAction)onOptionsConferenceClick:(id)sender {
	[self hideOptions:TRUE animated:TRUE];
	linphone_core_add_all_to_conference(LC);
}

#pragma mark - Animation

- (void)hideAnimation:(BOOL)hidden forView:(UIView *)target completion:(void (^)(BOOL finished))completion {
	if (hidden) {
	int original_y = target.frame.origin.y;
	CGRect newFrame = target.frame;
	newFrame.origin.y = self.view.frame.size.height;
	[UIView animateWithDuration:0.5
		delay:0.0
		options:UIViewAnimationOptionCurveEaseIn
		animations:^{
		  target.frame = newFrame;
		}
		completion:^(BOOL finished) {
		  CGRect originFrame = target.frame;
		  originFrame.origin.y = original_y;
		  target.hidden = YES;
		  target.frame = originFrame;
		  if (completion)
			  completion(finished);
		}];
	} else {
		CGRect frame = target.frame;
		int original_y = frame.origin.y;
		frame.origin.y = self.view.frame.size.height;
		target.frame = frame;
		frame.origin.y = original_y;
		target.hidden = NO;

		[UIView animateWithDuration:0.5
			delay:0.0
			options:UIViewAnimationOptionCurveEaseOut
			animations:^{
			  target.frame = frame;
			}
			completion:^(BOOL finished) {
			  target.frame = frame; // in case application did not finish
			  if (completion)
				  completion(finished);
			}];
	}
}

#pragma mark - Bounce

- (void)updateUnreadMessage:(BOOL)appear {
	int unreadMessage = [LinphoneManager unreadMessageCount];
	if (unreadMessage > 0) {
		_chatNotificationLabel.text = [NSString stringWithFormat:@"%i", unreadMessage];
		[_chatNotificationView startAnimating:appear];
	} else {
		[_chatNotificationView stopAnimating:appear];
	}
}

#pragma mark - My Functions

//  Hide keypad mini
- (void)btnHideKeypadPressed{
    _viewCommand.hidden = NO;
    
    for (UIView *subView in _callView.subviews) {
        if (subView.tag == 10) {
            [UIView animateWithDuration:.35 animations:^{
                subView.transform = CGAffineTransformMakeScale(1.3, 1.3);
                subView.alpha = 0.0;
            } completion:^(BOOL finished) {
                if (finished) {
                    [subView removeFromSuperview];
                }
            }];
        }
    }
}

/*----- Kết thúc cuộc gọi trong màn hình video call -----*/
- (void)endVideoCall{
    LinphoneCore* lc = [LinphoneManager getLc];
    LinphoneCall* currentcall = linphone_core_get_current_call(lc);
    if (currentcall != nil) {
        linphone_core_terminate_call(lc, currentcall);
    }
}

- (void)updateAddress {
    [self view]; //Force view load
    PhoneObject *contact = [ContactUtils getContactPhoneObjectWithNumber: phoneNumber];
    
    if ([phoneNumber isEqualToString:hotline]) {
        _avatarImage.image = [UIImage imageNamed:@"hotline_avatar.png"];
    }else{
        if ([AppUtils isNullOrEmpty: contact.avatar]) {
            _avatarImage.image = [UIImage imageNamed:@"no_avatar.png"];
        }else{
            _avatarImage.image = [UIImage imageWithData:[NSData dataFromBase64String: contact.avatar]];
        }
    }
    _nameLabel.text = contact.name;
    lbPhoneNumber.text = phoneNumber;
}

//  add scroll view khi goi
- (void)addScrollview
{
    
    float wFeatureIcon = 70.0;
    if (!IS_IPHONE && !IS_IPOD) {
        wFeatureIcon = 100.0;
    }else{
        NSString *deviceMode = [DeviceUtils getModelsOfCurrentDevice];
        if ([deviceMode isEqualToString: Iphone5_1] || [deviceMode isEqualToString: Iphone5_2] || [deviceMode isEqualToString: Iphone5c_1] || [deviceMode isEqualToString: Iphone5c_2] || [deviceMode isEqualToString: Iphone5s_1] || [deviceMode isEqualToString: Iphone5s_2] || [deviceMode isEqualToString: IphoneSE])
        {
            wFeatureIcon = 60.0;
        }else if ([deviceMode isEqualToString: Iphone6] || [deviceMode isEqualToString: Iphone6s] || [deviceMode isEqualToString: Iphone7_1] || [deviceMode isEqualToString: Iphone7_2] || [deviceMode isEqualToString: Iphone8_1] || [deviceMode isEqualToString: Iphone8_2])
        {
            wFeatureIcon = 70.0;
        }else if ([deviceMode isEqualToString: Iphone6_Plus] || [deviceMode isEqualToString: Iphone6s_Plus] || [deviceMode isEqualToString: Iphone7_Plus1] || [deviceMode isEqualToString: Iphone7_Plus2] || [deviceMode isEqualToString: Iphone8_Plus1] || [deviceMode isEqualToString: Iphone8_Plus2])
        {
            wFeatureIcon = 80.0;
        }else if ([deviceMode isEqualToString: IphoneX_1] || [deviceMode isEqualToString: IphoneX_2] || [deviceMode isEqualToString: IphoneXR] || [deviceMode isEqualToString: IphoneXS] || [deviceMode isEqualToString: IphoneXS_Max1] || [deviceMode isEqualToString: IphoneXS_Max2])
        {
            wFeatureIcon = 80.0;
        }
    }
    
    float marginX = (SCREEN_WIDTH - 3*wFeatureIcon)/4;
    
    _scrollView.minimumZoomScale = 0.5;
    _scrollView.maximumZoomScale = 3;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.scrollEnabled = NO;
    
    //  numpad button
    lbKeypad.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
    [lbKeypad mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_scrollView.mas_centerY);
        make.centerX.equalTo(_scrollView.mas_centerX);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(wFeatureIcon+marginX);
    }];
    lbKeypad.backgroundColor = UIColor.clearColor;
    lbKeypad.text = [appDelegate.localization localizedStringForKey:@"Keypad"];
    
    [_numpadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(lbKeypad.mas_top);
        make.centerX.equalTo(_scrollView.mas_centerX);
        make.width.height.mas_equalTo(wFeatureIcon);
    }];
    [_numpadButton setBackgroundImage:[UIImage imageNamed:@"ic_keypad_def.png"] forState:UIControlStateNormal];
    [_numpadButton setBackgroundImage:[UIImage imageNamed:@"ic_keypad_act.png"] forState:UIControlStateSelected];
    [_numpadButton setBackgroundImage:[UIImage imageNamed:@"ic_keypad_dis.png"] forState:UIControlStateDisabled];
    _numpadButton.backgroundColor = UIColor.clearColor;
    _numpadButton.enabled = NO;
    
    //  mute
    [_microButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_numpadButton);
        make.right.equalTo(_numpadButton.mas_left).offset(-marginX);
        make.width.height.mas_equalTo(wFeatureIcon);
    }];
    [_microButton setBackgroundImage:[UIImage imageNamed:@"ic_mute_def.png"] forState:UIControlStateNormal];
    [_microButton setBackgroundImage:[UIImage imageNamed:@"ic_mute_act.png"] forState:UIControlStateSelected];
    [_microButton setBackgroundImage:[UIImage imageNamed:@"ic_mute_dis.png"] forState:UIControlStateDisabled];
    _microButton.backgroundColor = UIColor.clearColor;
    _microButton.enabled = NO;
    
    lbMute.font = lbKeypad.font;
    [lbMute mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbKeypad.mas_top);
        make.centerX.equalTo(_microButton.mas_centerX);
        make.height.equalTo(lbKeypad.mas_height);
        make.width.equalTo(lbKeypad.mas_width);
    }];
    lbMute.backgroundColor = UIColor.clearColor;
    lbMute.text = [appDelegate.localization localizedStringForKey:@"Mute"];
    
    //  speaker
    [_speakerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_numpadButton);
        make.left.equalTo(_numpadButton.mas_right).offset(marginX);
        make.width.height.mas_equalTo(wFeatureIcon);
    }];
    [_speakerButton setBackgroundImage:[UIImage imageNamed:@"ic_speaker_def.png"] forState:UIControlStateNormal];
    [_speakerButton setBackgroundImage:[UIImage imageNamed:@"ic_speaker_act.png"] forState:UIControlStateSelected];
    [_speakerButton setBackgroundImage:[UIImage imageNamed:@"ic_speaker_dis.png"] forState:UIControlStateDisabled];
    _speakerButton.backgroundColor = UIColor.clearColor;
    _speakerButton.enabled = NO;
    
    lbSpeaker.font = lbKeypad.font;
    [lbSpeaker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbKeypad.mas_top);
        make.centerX.equalTo(_speakerButton.mas_centerX);
        make.height.equalTo(lbKeypad.mas_height);
        make.width.equalTo(lbKeypad.mas_width);
    }];
    lbSpeaker.backgroundColor = UIColor.clearColor;
    lbSpeaker.text = [appDelegate.localization localizedStringForKey:@"Speaker"];
    
    //  Hold call
    [_callPauseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_scrollView.mas_centerY).offset(10);
        make.centerX.equalTo(_scrollView.mas_centerX);
        make.width.height.mas_equalTo(wFeatureIcon);
    }];
    [_callPauseButton setBackgroundImage:[UIImage imageNamed:@"ic_pause_def.png"] forState:UIControlStateNormal];
    [_callPauseButton setBackgroundImage:[UIImage imageNamed:@"ic_pause_act.png"] forState:UIControlStateSelected];
    [_callPauseButton setBackgroundImage:[UIImage imageNamed:@"ic_pause_dis.png"] forState:UIControlStateDisabled];
    _callPauseButton.backgroundColor = UIColor.clearColor;
    _callPauseButton.enabled = NO;
    
    lbPause.font = lbKeypad.font;
    [lbPause mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_callPauseButton.mas_bottom);
        make.centerX.equalTo(_callPauseButton.mas_centerX);
        make.height.equalTo(lbKeypad.mas_height);
        make.width.equalTo(lbKeypad.mas_width);
    }];
    lbPause.backgroundColor = UIColor.clearColor;
    lbPause.text = [appDelegate.localization localizedStringForKey:@"Hold"];
    
    //  Add call
    [icAddCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_callPauseButton);
        make.right.equalTo(_callPauseButton.mas_left).offset(-marginX);
        make.width.height.mas_equalTo(wFeatureIcon);
    }];
    [icAddCall setBackgroundImage:[UIImage imageNamed:@"ic_addcall_def.png"] forState:UIControlStateNormal];
    [icAddCall setBackgroundImage:[UIImage imageNamed:@"ic_addcall_act.png"] forState:UIControlStateSelected];
    [icAddCall setBackgroundImage:[UIImage imageNamed:@"ic_addcall_dis.png"] forState:UIControlStateDisabled];
    icAddCall.backgroundColor = UIColor.clearColor;
    icAddCall.enabled = NO;
    [icAddCall addTarget:self
                  action:@selector(onAddCallClick:)
        forControlEvents:UIControlEventTouchUpInside];
    
    lbAddCall.font = lbKeypad.font;
    [lbAddCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbPause.mas_top);
        make.centerX.equalTo(icAddCall.mas_centerX);
        make.height.equalTo(lbKeypad.mas_height);
        make.width.equalTo(lbKeypad.mas_width);
    }];
    lbAddCall.backgroundColor = UIColor.clearColor;
    lbAddCall.text = [appDelegate.localization localizedStringForKey:@"Add call"];
    
    //  transfer call
    [_optionsTransferButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_callPauseButton);
        make.left.equalTo(_callPauseButton.mas_right).offset(marginX);
        make.width.height.mas_equalTo(wFeatureIcon);
    }];
    [_optionsTransferButton setBackgroundImage:[UIImage imageNamed:@"ic_transfer_def.png"] forState:UIControlStateNormal];
    [_optionsTransferButton setBackgroundImage:[UIImage imageNamed:@"ic_transfer_act.png"] forState:UIControlStateSelected];
    [_optionsTransferButton setBackgroundImage:[UIImage imageNamed:@"ic_transfer_dis.png"] forState:UIControlStateDisabled];
    _optionsTransferButton.backgroundColor = UIColor.clearColor;
    _optionsTransferButton.enabled = NO;
//    [_optionsTransferButton addTarget:self
//                               action:@selector(onTransfer)
//                     forControlEvents:UIControlEventTouchUpInside];
    lbTransfer.font = lbKeypad.font;
    [lbTransfer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbPause.mas_top);
        make.centerX.equalTo(_optionsTransferButton.mas_centerX);
        make.height.equalTo(lbKeypad.mas_height);
        make.width.equalTo(lbKeypad.mas_width);
    }];
    lbTransfer.backgroundColor = UIColor.clearColor;
    lbTransfer.text = [appDelegate.localization localizedStringForKey:@"Transfer"];
}

/*----- Click vao button conference trong scrollView  -----*/
-(void)onConference {
    changeConference = YES;
    icAddCall.backgroundColor = UIColor.clearColor;
    _callView.hidden = YES;
    _conferenceView.hidden = NO;
    
//    NSDictionary *info = [NSDatabase getProfileInfoOfAccount: USERNAME];
//    if (info != nil) {
//        NSString *strAvatar = [info objectForKey:@"avatar"];
//        if (strAvatar != nil && ![strAvatar isEqualToString: @""]) {
//            NSData *myAvatar = [NSData dataFromBase64String: strAvatar];
//            avatarConference.image = [UIImage imageWithData: myAvatar];
//        }else{
//            avatarConference.image = [UIImage imageNamed:@"no_avatar"];
//        }
//    }else{
//        avatarConference.image = [UIImage imageNamed:@"no_avatar"];
//    }
    
    updateTimeConf = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateConference) userInfo:nil repeats:YES];
}

- (void)updateConference {
    LinphoneCore *lc = [LinphoneManager getLc];
    [collectionConference reloadData];
    
    int count = 0;
    list = linphone_core_get_calls(lc);
    while (list != NULL) {
        count++;
        list = list->next;
    }
    
    if (count > 2) {
        changeConference = NO;
    }
    
    if (count == 1 && changeConference == NO) {
        [self hiddenConference];
        //Update address
        [self updateAddress];
        
        [updateTimeConf invalidate];
        updateTimeConf = nil;
        //  updateTime = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCall) userInfo:nil repeats:YES];
    }
    
    if (count < 1) {
        [updateTimeConf invalidate];
        updateTimeConf = nil;
    }
}

//  Ẩn confernce
- (void)hiddenConference{
    [_callView setHidden: NO];
    [_conferenceView setHidden: YES];
}

- (void)setupUIForView
{
    float bottomHangupIcon = 20.0;
    
    float wEndCall = 70.0;
    float wAvatar = 120.0;
    float hDuration = 45.0;
    float margin = 10.0;
    NSString *deviceMode = [DeviceUtils getModelsOfCurrentDevice];
    
    if ([deviceMode isEqualToString: Iphone5_1] || [deviceMode isEqualToString: Iphone5_2] || [deviceMode isEqualToString: Iphone5s_1] || [deviceMode isEqualToString: Iphone5s_2] || [deviceMode isEqualToString: Iphone5c_1] || [deviceMode isEqualToString: Iphone5c_2] || [deviceMode isEqualToString: IphoneSE])
    {
        wEndCall = 60.0;
        wAvatar = 100.0;
        hDuration = 30.0;
        margin = 5.0;
    }else if ([deviceMode isEqualToString: Iphone6] || [deviceMode isEqualToString: Iphone6s] || [deviceMode isEqualToString: Iphone7_1] || [deviceMode isEqualToString: Iphone7_2] || [deviceMode isEqualToString: Iphone8_1] || [deviceMode isEqualToString: Iphone8_2])
    {
        wEndCall = 70.0;
        wAvatar = 120.0;
        hDuration = 45.0;
        margin = 10.0;
    }else if ([deviceMode isEqualToString: Iphone6_Plus] || [deviceMode isEqualToString: Iphone6s_Plus] || [deviceMode isEqualToString: Iphone7_Plus1] || [deviceMode isEqualToString: Iphone7_Plus2] || [deviceMode isEqualToString: Iphone8_Plus1] || [deviceMode isEqualToString: Iphone8_Plus2])
    {
        wEndCall = 80.0;
        wAvatar = 140.0;
        hDuration = 45.0;
        margin = 10.0;
        bottomHangupIcon = 40.0;
    }else if ([deviceMode isEqualToString: IphoneX_1] || [deviceMode isEqualToString: IphoneX_2] || [deviceMode isEqualToString: IphoneXR] || [deviceMode isEqualToString: IphoneXS] || [deviceMode isEqualToString: IphoneXS_Max1] || [deviceMode isEqualToString: IphoneXS_Max2] || [deviceMode isEqualToString: simulator])
    {
        wEndCall = 80.0;
        wAvatar = 140.0;
        hDuration = 45.0;
        margin = 10.0;
        bottomHangupIcon = 40.0;
    }
    
    //  View call binh thuong
    [_callView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
    
    [_hangupButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_callView).offset(-bottomHangupIcon);
        make.centerX.equalTo(_callView.mas_centerX);
        make.width.height.mas_equalTo(wEndCall);
    }];
    [_hangupButton addTarget:self
                      action:@selector(btnHangupButtonPressed)
            forControlEvents:UIControlEventTouchUpInside];
    
    [bgCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(_callView);
    }];
    
    _lbQuality.text = [appDelegate.localization localizedStringForKey: @"Quality"];
    _lbQuality.backgroundColor = UIColor.clearColor;
    _lbQuality.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
    _lbQuality.textColor = UIColor.whiteColor;
    _lbQuality.textAlignment = NSTextAlignmentCenter;
    [_lbQuality mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_callView).offset([LinphoneAppDelegate sharedInstance]._hStatus);
        make.right.equalTo(_callView).offset(-20);
        make.left.equalTo(_callView).offset(20);
        make.height.mas_equalTo(35.0);
    }];
    
    _avatarImage.clipsToBounds = YES;
    _avatarImage.layer.cornerRadius = wAvatar/2;
    _avatarImage.layer.borderColor = [UIColor colorWithRed:(45/255.0) green:(136/255.0)
                                                      blue:(250/255.0) alpha:1.0].CGColor;
    _avatarImage.layer.borderWidth = 3.0;
    _avatarImage.backgroundColor = UIColor.clearColor;
    [_avatarImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lbQuality.mas_bottom).offset(10);
        make.centerX.equalTo(_callView.mas_centerX);
        make.width.mas_equalTo(wAvatar);
        make.height.mas_equalTo(wAvatar);
    }];
    
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_avatarImage.mas_bottom).offset(10);
        make.left.equalTo(_callView).offset(20);
        make.right.equalTo(_callView).offset(-20);
        make.height.mas_equalTo(30.0);
    }];
    _nameLabel.text = @"";
    _nameLabel.font = [UIFont systemFontOfSize:28.0 weight:UIFontWeightMedium];
    _nameLabel.textColor = UIColor.whiteColor;
    _nameLabel.backgroundColor = UIColor.clearColor;
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    
    [lbPhoneNumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_nameLabel.mas_bottom).offset(5);
        make.left.equalTo(_callView).offset(20);
        make.right.equalTo(_callView).offset(-20);
        make.height.mas_equalTo(20.0);
    }];
    lbPhoneNumber.textAlignment = NSTextAlignmentCenter;
    lbPhoneNumber.textColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                               blue:(200/255.0) alpha:1.0];
    lbPhoneNumber.font = [UIFont systemFontOfSize: 16.0];
    
    [_durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbPhoneNumber.mas_bottom).offset(margin);
        make.left.equalTo(_callView).offset(20);
        make.right.equalTo(_callView).offset(-20);
        make.height.mas_equalTo(hDuration);
    }];
    _durationLabel.font = [UIFont systemFontOfSize:32.0 weight:UIFontWeightThin];
    _durationLabel.backgroundColor = UIColor.clearColor;
    
    [_viewCommand mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_durationLabel.mas_bottom).offset(10);
        make.left.right.equalTo(_callView);
        make.bottom.equalTo(_hangupButton.mas_top).offset(-10);
    }];
    _viewCommand.backgroundColor = UIColor.clearColor;
    
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(_viewCommand);
    }];
    
    //  conference
    [_conferenceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
    
    [lbConfQuality mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_conferenceView).offset(appDelegate._hStatus);
        make.left.right.equalTo(_conferenceView);
        make.height.mas_equalTo(50.0);
    }];
    lbConfQuality.text = @"Quality: Good";
    lbConfQuality.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:26.0];
    lbConfQuality.textAlignment = NSTextAlignmentCenter;
    
    [lbConfName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbConfQuality.mas_bottom);
        make.left.equalTo(_conferenceView).offset(15.0);
        make.right.equalTo(_conferenceView.mas_centerX);
        make.height.equalTo(lbConfName.mas_height);
    }];
    lbConfName.textAlignment = NSTextAlignmentLeft;
    lbConfName.text = @"Conference call";
    lbConfName.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:26.0];
    
    [lbConfDuration mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbConfQuality.mas_bottom);
        make.left.equalTo(_conferenceView.mas_centerX);
        make.right.equalTo(_conferenceView.mas_right).offset(-15.0);
        make.height.equalTo(lbConfName.mas_height);
    }];
    lbConfDuration.textColor = UIColor.greenColor;
    lbConfDuration.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:26.0];
    lbConfDuration.textAlignment = NSTextAlignmentRight;
    lbConfDuration.text = @"05:06";
    
    [btnEndConf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_conferenceView).offset(-bottomHangupIcon);
        make.centerX.equalTo(_conferenceView.mas_centerX);
        make.width.height.mas_equalTo(wEndCall);
    }];
    
    float wConfIcon = 60.0;
    btnConfHold.backgroundColor = UIColor.clearColor;
    btnConfHold.clipsToBounds = YES;
    btnConfHold.layer.cornerRadius = wConfIcon/2;
    [btnConfHold mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_conferenceView.mas_centerX);
        make.bottom.equalTo(btnEndConf.mas_top).offset(-40);
        make.width.height.mas_equalTo(wConfIcon);
    }];
    
    btnConfMute.backgroundColor = UIColor.clearColor;
    btnConfMute.clipsToBounds = YES;
    btnConfMute.layer.cornerRadius = wConfIcon/2;
    [btnConfMute mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(btnConfHold.mas_left).offset(-30);
        make.top.equalTo(btnConfHold);
        make.width.height.mas_equalTo(wConfIcon);
    }];
    
    btnConfSpeaker.backgroundColor = UIColor.clearColor;
    btnConfSpeaker.clipsToBounds = YES;
    btnConfSpeaker.layer.cornerRadius = wConfIcon/2;
    [btnConfSpeaker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(btnConfHold.mas_right).offset(30);
        make.top.equalTo(btnConfHold);
        make.width.height.mas_equalTo(wConfIcon);
    }];
    
    [tbConf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lbConfName.mas_bottom);
        make.left.right.equalTo(_conferenceView);
        make.bottom.equalTo(btnConfSpeaker.mas_top).offset(-20);
    }];
    tbConf.delegate = self;
    tbConf.dataSource = self;
    
    //  Setup for conference collection
    [collectionConference registerNib:[UINib nibWithNibName:@"UIConferenceCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"UIConferenceCell"];
    [collectionConference setDelegate: self];
    [collectionConference setDataSource: self];
    [collectionConference setBackgroundColor:[UIColor clearColor]];
    collectionConference.hidden = YES;
    
    [btnAddCallConf setTitle:[appDelegate.localization localizedStringForKey:@"CN_TEXT_ADD_CONFERENCE"]
                    forState:UIControlStateNormal];
    [btnAddCallConf setBackgroundImage:[UIImage imageNamed:@"btn_add_conf_over.png"]
                              forState:UIControlStateHighlighted];
    [btnAddCallConf setTitleColor:[UIColor whiteColor]
                         forState:UIControlStateNormal];
    [btnAddCallConf addTarget:self
                       action:@selector(onAddCallForConference)
             forControlEvents:UIControlEventTouchUpInside];
    
    [btnEndConf addTarget:self
                       action:@selector(endConferenceCall)
             forControlEvents:UIControlEventTouchUpInside];
}

- (void)onAddCallForConference
{
    [appDelegate set_acceptCall: true];
    
    //  [self hideOptions:TRUE animated:TRUE];
    DialerView *view = VIEW(DialerView);
    [view setAddress:@""];
    LinphoneManager.instance.nextCallIsTransfer = NO;
    [PhoneMainView.instance changeCurrentView:view.compositeViewDescription];
}

//  Kết thúc gọi conference
- (void)endConferenceCall{
    linphone_core_terminate_all_calls([LinphoneManager getLc]);
}

//  Kết thúc cuộc gọi hiện tại
- (void)btnHangupButtonPressed {
    // Bien cho biết mình kết thúc cuộc gọi
    appDelegate._meEnded = YES;
}

#pragma mark - Call Conference
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    int count = linphone_core_get_calls_nb([LinphoneManager getLc]);
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"UIConferenceCell";
    UIConferenceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell setFrame: CGRectMake(cell.frame.origin.x, cell.frame.origin.y, wCollection, wCollection+60)];
    [cell setupUIForCell];
    
    LinphoneCore *lc = [LinphoneManager getLc];
    list = linphone_core_get_calls(lc);
    int i = 0;
    while (i < indexPath.row) {
        i++;
        list = list->next;
    }
    
    cell.call =(LinphoneCall*)list->data;
    int duration = linphone_call_get_duration((LinphoneCall*)list->data);
    [cell setDuration: duration];
    
    //set tag for ui
    [cell._btnPause setTag: indexPath.row];
    [cell._btnEndCall setTag: indexPath.row];
    
    int callState = linphone_call_get_state((LinphoneCall *)list->data);
    
    if (callState == LinphoneCallPaused) {
        [cell._btnPause setBackgroundImage:[UIImage imageNamed:@"button-stop-default.png"]
                                  forState:UIControlStateNormal];
        [cell._btnPause setBackgroundImage:[UIImage imageNamed:@"button-stop-active.png"]
                                  forState:UIControlStateHighlighted];
    }else{
        [cell._btnPause setBackgroundImage:[UIImage imageNamed:@"button-play-default.png"]
                                  forState:UIControlStateNormal];
        [cell._btnPause setBackgroundImage:[UIImage imageNamed:@"button-play-active.png"]
                                  forState:UIControlStateHighlighted];
    }
    [cell._btnPause addTarget:self action:@selector(onClickPause:)
             forControlEvents:UIControlEventTouchUpInside];
    
    [cell._btnEndCall addTarget:self action:@selector(onClickEndCallConf:)
               forControlEvents:UIControlEventTouchUpInside];
    
    [cell updateCell];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(wCollection, wCollection+60);
}

#pragma mark collection view cell paddings
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(marginX, marginX, marginX, marginX); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return marginX;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return marginX;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return TRUE;
}

- (NSString *)getPhoneNumberOfCall {
    __block NSString *addressPhoneNumber = @"";
    LinphoneCore* lc = [LinphoneManager getLc];
    list = linphone_core_get_calls(lc);
    if (list != NULL) {
        LinphoneCall* call = list->data;
        const LinphoneAddress* addr = linphone_call_get_remote_address(call);
        if (addr != NULL) {
            // contact name
            char* lAddress = linphone_address_as_string_uri_only(addr);
            if(lAddress) {
                NSString *normalizedSipAddress = [FastAddressBook normalizeSipURI:[NSString stringWithUTF8String:lAddress]];
                NSRange range = NSMakeRange(3, [normalizedSipAddress rangeOfString:@"@"].location - 3);
                NSString *tmp = [normalizedSipAddress substringWithRange:range];
                // tmp: -> :8889998007
                if (tmp.length > 2) {
                    NSString *phoneStr = [tmp substringFromIndex: 1];
                    addressPhoneNumber = [[NSString alloc] initWithString: phoneStr];
                    return addressPhoneNumber;
                }
                ms_free(lAddress);
            }
        }
    }
    return @"";
}

/*----- Pasuse and resume call -----*/
- (void)onClickPause:(UIButton *)sender {
    NSIndexPath *curIndex = [NSIndexPath indexPathForItem:sender.tag inSection:0];
    UIConferenceCell *curCell = (UIConferenceCell *)[collectionConference cellForItemAtIndexPath: curIndex];
    LinphoneCallState state = linphone_call_get_state(curCell.call);
    if (state == LinphoneCallStreamsRunning){
        linphone_core_pause_call([LinphoneManager getLc], curCell.call);
    }else if (state == LinphoneCallPaused){
        linphone_core_resume_call([LinphoneManager getLc], curCell.call);
    }
}

/*----- End call conference trong từng cell -----*/
- (void)onClickEndCallConf:(UIControl *)sender {
    NSIndexPath *curIndex = [NSIndexPath indexPathForItem:sender.tag inSection:0];
    UIConferenceCell *curCell = (UIConferenceCell *)[collectionConference cellForItemAtIndexPath: curIndex];
    linphone_core_terminate_call([LinphoneManager getLc], curCell.call);
    changeConference = NO;
}

- (void)countUpTimeForCall {
    if (durationTimer != nil) {
        [durationTimer invalidate];
        durationTimer = nil;
    }
    durationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self
                                                   selector:@selector(callDurationUpdate)
                                                   userInfo:nil repeats:YES];
}

- (void)displayCallError:(LinphoneCall *)call message:(NSString *)message
{
    if (call != NULL) {
        const char *lUserNameChars = linphone_address_get_username(linphone_call_get_remote_address(call));
        NSString *lUserName =
        lUserNameChars ? [[NSString alloc] initWithUTF8String:lUserNameChars] : NSLocalizedString(@"Unknown", nil);
        NSString *lMessage;
        
        switch (linphone_call_get_reason(call)) {
            case LinphoneReasonNotFound:
                lMessage = [NSString stringWithFormat:NSLocalizedString(@"%@ is not registered.", nil), lUserName];
                break;
            case LinphoneReasonBusy:
                _durationLabel.text = [appDelegate.localization localizedStringForKey:@"The user is busy"];
                _durationLabel.textColor = UIColor.whiteColor;
                break;
            default:
                if (message != nil) {
                    lMessage = [NSString stringWithFormat:NSLocalizedString(@"%@\nReason was: %@", nil), lMessage, message];
                }
                break;
        }
    }
}

- (void)hideCallView {
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"%s", __FUNCTION__] toFilePath:appDelegate.logFilePath];
    
    [self hideMiniKeypad];
    
    int count = linphone_core_get_calls_nb([LinphoneManager getLc]);
    if (count == 0) {
        if (durationTimer != nil) {
            [durationTimer invalidate];
            durationTimer = nil;
        }
        
        phoneNumber = @"";
        
        // Remove observer
        [NSNotificationCenter.defaultCenter removeObserver:self];
    }else{
        NSLog(@"Van con call ne");
    }
    
    [[PhoneMainView instance] popCurrentView];
}

- (void)updateQualityForCall {
    if (qualityTimer != nil) {
        [qualityTimer invalidate];
        qualityTimer = nil;
    }
    [self callQualityUpdate];
    qualityTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(callQualityUpdate) userInfo:nil repeats:YES];
}

- (void)checkToDownloadAvatarOfUser: (NSString *)phone
{
    if (phone.length > 9 || [phone isEqualToString:hotline]) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *pbxServer = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_SERVER];
        NSString *avatarName = [NSString stringWithFormat:@"%@_%@.png", pbxServer, phoneNumber];
        NSString *linkAvatar = [NSString stringWithFormat:@"%@/%@", link_picture_chat_group, avatarName];
        NSData *data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: linkAvatar]];
        
        if (data != nil) {
            NSString *folder = [NSString stringWithFormat:@"/avatars/%@", avatarName];
            [AppUtils saveFileToFolder:data withName: folder];
            
            //  set avatar value for pbx contact list if exists
            PBXContact *contact = [AppUtils getPBXContactFromListWithPhoneNumber: phoneNumber];
            if (contact != nil) {
                if ([data respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
                    contact._avatar = [data base64EncodedStringWithOptions: 0];
                } else {
                    contact._avatar = [data base64Encoding];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^(void){
                _avatarImage.image = [UIImage imageWithData: data];
            });
        }
    });
}

- (void)headsetPluginChanged: (NSNotification *)notif {
    if (notif.object != nil && [notif.object isKindOfClass:[NSNumber class]]) {
        int routeChangeReason = [notif.object intValue];
        if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
            if (needEnableSpeaker) {
                [_speakerButton setOn];
                _speakerButton.selected = YES;
            }else{
                [_speakerButton setOff];
                _speakerButton.selected = NO;
            }
            NSLog(@"%@ - %@", SHOW_LOGS, @"Tai nghe da duoc rut ra");
        }
        if (routeChangeReason == kAudioSessionRouteChangeReason_NewDeviceAvailable) {
            needEnableSpeaker = _speakerButton.isEnabled;
            [_speakerButton setOff];
            _speakerButton.selected = NO;
            
            NSLog(@"%@ - %@", SHOW_LOGS, @"Tai nghe da duoc cam vao");
        }
    }
}

- (void)addAnimationForOutgoingCall {
    LinphoneCall *call = linphone_core_get_current_call(LC);
    LinphoneCallState state = (call != NULL) ? linphone_call_get_state(call) : 0;
    
    if (callDirection == LinphoneCallOutgoing && state != LinphoneCallConnected && state != LinphoneCallStreamsRunning) {
        // basic setup
        PulsingHaloLayer *layer = [PulsingHaloLayer layer];
        self.halo = layer;
        [_avatarImage.superview.layer insertSublayer:self.halo below:_avatarImage.layer];
        [self setupInitialValuesWithNumLayer:5 radius:0.8 duration:0.45
                                       color:[UIColor colorWithRed:(230/255.0) green:(230/255.0) blue:(230/255.0) alpha:0.7]];
    }
}

- (void)setupInitialValuesWithNumLayer: (int)numLayer radius: (float)radius duration: (float)duration color: (UIColor *)color
{
    self.halo.haloLayerNumber = numLayer;
    self.halo.radius = radius * kMaxRadius;
    self.halo.animationDuration = duration * kMaxDuration;
    [self.halo setBackgroundColor:color.CGColor];
}

- (void)onAddCallClick: (UIButton *)sender {
    if (!appDelegate.enableForTest) {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"This feature have not supported yet. Please try later!"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    DialerView *view = VIEW(DialerView);
    [view setAddress:@""];
    LinphoneManager.instance.nextCallIsTransfer = NO;
    [PhoneMainView.instance changeCurrentView:view.compositeViewDescription];
}

#pragma mark - UITableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int count = linphone_core_get_calls_nb(LC);
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ConferenceTableViewCell";
    ConferenceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ConferenceTableViewCell" owner:self options:nil];
        cell = topLevelObjects[0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    list = linphone_core_get_calls(LC);
    int i = 0;
    while (i < indexPath.row) {
        i++;
        list = list->next;
    }
    
    NSString *phone = [self getPhoneNumberOfCall: (LinphoneCall *)list->data];
    if (![AppUtils isNullOrEmpty: phone]) {
        PhoneObject *contact = [ContactUtils getContactPhoneObjectWithNumber: phone];
        cell.lbName.text = contact.name;
        cell.lbPhone.text = contact.number;
    }else{
        cell.lbName.text = @"Ten";
        cell.lbPhone.text = @"So phone";
    }
    
    //set tag for ui
    int callState = linphone_call_get_state((LinphoneCall *)list->data);
    if (callState == LinphoneCallPaused) {
        [cell.icPause setBackgroundImage:[UIImage imageNamed:@"ic-pause-default.png"]
                                  forState:UIControlStateNormal];
    }else{
        [cell.icPause setBackgroundImage:[UIImage imageNamed:@"ic-play-default.png"]
                                forState:UIControlStateNormal];
    }
    [cell.icPause addTarget:self action:@selector(onClickPause:)
             forControlEvents:UIControlEventTouchUpInside];
    
    [cell.icEndCall addTarget:self action:@selector(onClickEndCallConf:)
               forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (NSString *)getPhoneNumberOfCall: (LinphoneCall *)call {
    NSString *phone = @"";
    const LinphoneAddress* addr = linphone_call_get_remote_address(call);
    if (addr != NULL) {
        // contact name
        char* lAddress = linphone_address_as_string_uri_only(addr);
        if(lAddress) {
            NSString *normalizedSipAddress = [FastAddressBook normalizeSipURI:[NSString stringWithUTF8String:lAddress]];
            if (normalizedSipAddress.length >= 7) {
                phone = [normalizedSipAddress substringWithRange:NSMakeRange(4, 10)];
            }
            ms_free(lAddress);
        }
    }
    return phone;
}

- (void)requestAccessToMicroIfNot {
    //show warning Microphone
    if (IS_IOS7) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted){
            if (granted) {
                NSLog(@"granted");
            } else {
                NSLog(@"denied");
                //  [[iMomeetAppDelegate sharedInstance] performSelectorOnMainThread:@selector(warningNoMicrophoneAccess) withObject:nil waitUntilDone:NO];
            }
        }];
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted){
            if (granted) {
                NSLog(@"granted");
            } else {
                NSLog(@"denied");
                //  [[iMomeetAppDelegate sharedInstance] performSelectorOnMainThread:@selector(warningNoCameraAccess) withObject:nil waitUntilDone:NO];
            }
        }];
    }
}

@end
