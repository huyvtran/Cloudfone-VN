//
//  SearchContactPopupView.h
//  linphone
//
//  Created by lam quang quan on 10/29/18.
//

#import <UIKit/UIKit.h>

@interface SearchContactPopupView : UIView<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) NSMutableArray *contacts;
@property (nonatomic, strong) UITableView *tbContacts;
@property (nonatomic, retain) UITapGestureRecognizer *tapGesture;

- (void)showInView:(UIView *)aView animated:(BOOL)animated;
- (void)fadeOut;

@end
