//
//  SettingPopupView.h
//  linphone
//
//  Created by user on 25/9/14.
//
//

#import <UIKit/UIKit.h>

@protocol SettingPopupViewDelegate
- (void)selectOnMessage: (NSString *)idMessage withRow: (int)row;
@end

@interface SettingPopupView : UIView<UITableViewDelegate, UITableViewDataSource>{
    id <NSObject,SettingPopupViewDelegate> delegate;
}

@property (nonatomic,strong) id <NSObject,SettingPopupViewDelegate> delegate;
@property (nonatomic, strong) UITableView *_settingTableView;
@property (nonatomic, strong) UITapGestureRecognizer *_tapGesture;
@property (nonatomic, strong) NSMutableArray *listOptions;
@property (nonatomic, strong) NSString *idMessage;

- (void)showInView:(UIView *)aView animated:(BOOL)animated;
- (void)fadeOut;
- (void)saveListOptions: (NSMutableArray *)list;
@end
