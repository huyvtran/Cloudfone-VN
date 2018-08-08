//
//  PopupUserOptionChat.h
//  linphone
//
//  Created by Ei Captain on 7/20/16.
//
//

#import <UIKit/UIKit.h>

typedef enum eUserOptions{
    eStartChat,
    eBlockUser,
    eKickUser,
    eBanUser,
}eUserOptions;

@protocol PopupUserOptionChatDelegate
@end

@interface PopupUserOptionChat : UIView<UITableViewDelegate, UITableViewDataSource>{
    id<NSObject, PopupUserOptionChatDelegate> delegate;
}

@property (nonatomic, strong) UITableView *_tbView;
@property (nonatomic, retain) UITapGestureRecognizer *_tapGesture;
@property (nonatomic, strong) NSString *_callnexID;
@property (nonatomic, assign) int _idContact;

- (void)showInView:(UIView *)aView animated:(BOOL)animated;

//  Cập nhật giá trị block cho user
- (void)setupBlockValueForUser;

@end
