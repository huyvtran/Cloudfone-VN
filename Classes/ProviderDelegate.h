//
//  ProviderDelegate.h
//  linphone
//
//  Created by REIS Benjamin on 29/11/2016.
//
//

#import <CallKit/CallKit.h>

#ifndef ProviderDelegate_h
#define ProviderDelegate_h

@interface ProviderDelegate : NSObject <CXProviderDelegate, CXCallObserverDelegate>

@property (nonatomic, strong) CXProvider *provider;
@property (nonatomic, strong) CXCallObserver *observer;
@property (nonatomic, strong) CXCallController *controller;
@property (nonatomic, strong) NSMutableDictionary *calls;
@property (nonatomic, strong) NSMutableDictionary *uuids;
@property LinphoneCall *pendingCall;
@property LinphoneAddress *pendingAddr;
@property BOOL pendingCallVideo;
@property int callKitCalls;

- (void)reportIncomingCallwithUUID:(NSUUID *)uuid handle:(NSString *)handle video:(BOOL)video;
- (void)config;
- (void)configAudioSession:(AVAudioSession *)audioSession;
@end

#endif /* ProviderDelegate_h */
