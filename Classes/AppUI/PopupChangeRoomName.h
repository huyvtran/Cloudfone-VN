//
//  PopupChangeRoomName.h
//  linphone
//
//  Created by Ei Captain on 7/19/16.
//
//

#import <UIKit/UIKit.h>

@protocol PopupChangeRoomNameDelegate
@end

@interface PopupChangeRoomName : UIView {
    id <NSObject, PopupChangeRoomNameDelegate> delegate;
}

@property (nonatomic, strong) UITextField *_tfRoomName;
@property (nonatomic, strong) UIButton *_btnSave;
@property (nonatomic, strong) UIButton *_btnCancel;

@property (nonatomic, retain) UITapGestureRecognizer *_tapGesture;

- (void)showInView:(UIView *)aView animated:(BOOL)animated;

@property (nonatomic, strong) NSString *_roomName;

@end
