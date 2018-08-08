//
//  MessageLinkPopup.h
//  linphone
//
//  Created by Designer 01 on 3/16/15.
//
//

#import <UIKit/UIKit.h>
typedef enum typeData{
    phoneNumber,
    linkWebsite,
    linkEmail,
}typeData;


@protocol MessageLinkPopupDelegate
@end

@interface MessageLinkPopup : UIView<MessageLinkPopupDelegate, UITableViewDataSource, UITableViewDelegate>{
    id <NSObject, MessageLinkPopupDelegate> delegate;
}

@property (nonatomic, strong) id <NSObject, MessageLinkPopupDelegate> delegate;
@property (nonatomic, strong) UITableView *_optionsTableView;
@property (nonatomic, strong) NSArray *_listOptions;
@property (nonatomic, strong) UITapGestureRecognizer *_tapGesture;
@property (nonatomic, assign) int typeData;
@property (nonatomic, strong) NSString *strValue;

- (void)showInView: (UIView *)aView animated: (BOOL)animated;

@end
