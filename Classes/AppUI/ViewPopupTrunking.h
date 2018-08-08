//
//  ViewPopupTrunking.h
//  ViewPopupTrunking
//
//  Created by user on 21/11/13.
//  Copyright (c) 2013 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ViewPopupTrunkingDelegate
-(void)updateNumberDID:(NSString*)number;
@end


@interface ViewPopupTrunking : UIView<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,retain) NSString *_displayDID;
@property (nonatomic, retain) UITableView *_tableView;
@property (nonatomic, retain) UIButton *_btnRefresh;
@property (nonatomic, retain) UIButton *_btnCancel;
@property (nonatomic, retain) UITapGestureRecognizer *_tapGesture;

- (void)showInView:(UIView *)aView animated:(BOOL)animated;
- (void)fadeOut;

@end
