//
//  PopupSaveConversation.h
//  linphone
//
//  Created by Ei Captain on 7/19/16.
//
//

#import <UIKit/UIKit.h>
#import "BEMCheckBox.h"

@protocol PopupSaveConversationDelegate
@end

@interface PopupSaveConversation : UIView{
    id<NSObject, PopupSaveConversationDelegate> delegate;
}
@property (nonatomic, strong) UITextView *_twFileName;
@property (nonatomic, strong) UIButton *_btnCancel;
@property (nonatomic, strong) UIButton *_btnYes;

@property (nonatomic, strong) BEMCheckBox *_btnCheckBox;

- (void)showInView:(UIView *)aView animated:(BOOL)animated;
@property (nonatomic, retain) UITapGestureRecognizer *_tapGesture;

@property (nonatomic, assign) BOOL _isGroup;
@property (nonatomic, strong) NSString *_callnexUser;
@property (nonatomic, strong) NSString *_roomName;

@end
