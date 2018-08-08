//
//  PopupLeaveConference.h
//  linphone
//
//  Created by Ei Captain on 7/18/16.
//
//

#import <UIKit/UIKit.h>

@protocol PopupLeaveConferenceDelegate
@end

@interface PopupLeaveConference : UIView {
    id <NSObject, PopupLeaveConferenceDelegate> delegate;
}

@property (nonatomic, strong) UIButton *_btnYes;
@property (nonatomic, strong) UIButton *_btnNo;

@property (nonatomic, retain) UITapGestureRecognizer *_tapGesture;

- (void)showInView:(UIView *)aView animated:(BOOL)animated;

@property (nonatomic, strong) NSString *_roomName;

@end
