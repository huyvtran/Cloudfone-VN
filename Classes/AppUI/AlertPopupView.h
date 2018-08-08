//
//  AlertPopupView.h
//  linphone
//
//  Created by user on 19/8/14.
//
//

#import <UIKit/UIKit.h>

@protocol AlertPopupViewDelegate
@end

enum typePopup{
    deleteContactPop,   // 0
    requestFriendPopup, // 1
    deleteGroupPopup,   // 2
    logoutPopup,        // 3
    whitelistPopup,     // 4
    delConversation,    // 8
    deleteAllHistoryMessage,    // 10
    saveImageInViewChat,    //11
    saveVideoInViewChat,    //12
    joinToRoomChat,     //13
    trackingMessageNotif,
    notTrunking,
    videoCallNotif,
    deletePhoneNumber,
    deleteAllPersonInGroup,
    warningAccessNumber,
    eHideMsgPopup,
};

@interface AlertPopupView : UIView{
    id <NSObject,AlertPopupViewDelegate> delegate;
}

@property (nonatomic,strong) id <NSObject, AlertPopupViewDelegate> delegate;
@property (nonatomic, strong) UIButton *_buttonNo;
@property (nonatomic, strong) UIButton *_buttonYes;
@property (nonatomic, assign) CGRect _firstRect;
@property (nonatomic, assign) int _typePopup;
@property (nonatomic, strong) NSDictionary *_infoDict;

@property (nonatomic, retain) UITapGestureRecognizer *_tapGesture;

- (void)showInView:(UIView *)aView animated:(BOOL)animated;
- (id)initWithTypePopup: (int)type frame: (CGRect)frame info: (NSDictionary *)info;


@end
