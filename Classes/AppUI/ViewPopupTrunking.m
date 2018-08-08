//
//  ViewPopupTrunking.m
//  ViewPopupTrunking
//
//  Created by user on 21/11/13.
//  Copyright (c) 2013 user. All rights reserved.
//

#import "ViewPopupTrunking.h"
#import "ChooseAccountCell.h"

@interface ViewPopupTrunking(){
    CGRect oldFrame;
}
@end

@implementation ViewPopupTrunking {
    NSIndexPath *indexPathOld;
}
@synthesize _displayDID, _tableView, _btnRefresh, _btnCancel, _tapGesture;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        self.layer.borderWidth = 3.0;
        self.layer.borderColor = [UIColor colorWithRed:(24/255.0) green:(185/255.0)
                                                  blue:(153/255.0) alpha:1.0].CGColor;

        //Add logo image
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(4, 4, frame.size.width-8, 40)];
        headerView.backgroundColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                                      blue:(230/255.0) alpha:1.0];
        
        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        logoImageView.image = [UIImage imageNamed:@"ic_offline.png"];
        [headerView addSubview: logoImageView];
        
        //Add Label
        UILabel *lbHeader = [[UILabel alloc] initWithFrame: CGRectMake(44, 0, 200, 40)];
        lbHeader.textColor = [UIColor colorWithRed:(138/255.0) green:(138/255.0)
                                              blue:(138/255.0) alpha:1];
        lbHeader.font = [AppUtils fontRegularWithSize: 19.0];
        lbHeader.backgroundColor = [UIColor clearColor];
        lbHeader.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_trunking_header];
        [headerView addSubview: lbHeader];
        [self addSubview: headerView];
        
        //Add table
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(4, headerView.frame.origin.y+headerView.frame.size.height, self.frame.size.width-8, 80)];
        oldFrame = _tableView.frame;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.scrollEnabled = NO;
        _tableView.backgroundColor = UIColor.clearColor;
        [self addSubview:_tableView];
        
        //Add button
        float buttonWidth = (frame.size.width-8-2)/2;
        _btnRefresh = [[UIButton alloc] initWithFrame: CGRectMake(4, _tableView.frame.origin.y+_tableView.frame.size.height, buttonWidth, 35)];
        _btnRefresh.backgroundColor = [UIColor colorWithRed:(188/255.0) green:(188/255.0)
                                                       blue:(188/255.0) alpha:1.0];
        [_btnRefresh setBackgroundImage:[UIImage imageNamed:@"button_refresh_did.png"]
                                  forState:UIControlStateNormal];
        _btnRefresh.titleLabel.font = [AppUtils fontRegularWithSize: 16.0];
        [_btnRefresh setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_refresh] forState:UIControlStateNormal];
        _btnRefresh.titleEdgeInsets = UIEdgeInsetsMake(4.0, 20.0, 0.0, 0.0);
        [self addSubview:_btnRefresh];

        //Add button
        _btnCancel = [[UIButton alloc] initWithFrame: CGRectMake(_btnRefresh.frame.origin.x+_btnRefresh.frame.size.width+2, _btnRefresh.frame.origin.y, buttonWidth, 35)];
        _btnCancel.backgroundColor = [UIColor colorWithRed:(188/255.0) green:(188/255.0)
                                                       blue:(188/255.0) alpha:1.0];
        [_btnCancel setBackgroundImage:[UIImage imageNamed:@"button_cancel_did.png"]
                               forState:UIControlStateNormal];
        _btnCancel.titleLabel.font = [AppUtils fontRegularWithSize: 16.0];
        [_btnCancel setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_cancel] forState:UIControlStateNormal];
        _btnCancel.titleEdgeInsets = UIEdgeInsetsMake(4.0, 20.0, 0.0, 0.0);
        [_btnCancel addTarget:self action:@selector(cancelTrunking)
                forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_btnCancel];
    }
    return self;
}

#pragma mark - Tableview datasource & delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"ChooseAccountCell";
    
    ChooseAccountCell *cell = (ChooseAccountCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ChooseAccountCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == 0) {
        cell._lbTitle.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_popup_account];
        cell._lbValue.text = USERNAME;
    }else{
        cell._lbTitle.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_popup_account_pbx];
        
        NSString *accountPBX   = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_USERNAME];
        if (accountPBX != nil || ![accountPBX isEqualToString: @""]) {
            cell._lbValue.text = accountPBX;
        }else{
            cell._lbValue.text = @"";
        }
    }
    [cell setFrameForCell];
    
    //  setup tài khoản đang được chọn
    NSNumber *pbxFlag = [[NSUserDefaults standardUserDefaults] objectForKey:callnexPBXFlag];
    if (pbxFlag == nil || [pbxFlag intValue] == 0) {
        if (indexPath.row == 0) {
            cell._imgSelect.image = [UIImage imageNamed:@"menu_select_did_checked.png"];
        }else{
            cell._imgSelect.image = [UIImage imageNamed:@"menu_select_did_not_check.png"];
        }
    }else{
        if (indexPath.row == 0) {
            cell._imgSelect.image = [UIImage imageNamed:@"menu_select_did_not_check.png"];
        }else{
            cell._imgSelect.image = [UIImage imageNamed:@"menu_select_did_checked.png"];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self fadeOut];
    [[NSNotificationCenter defaultCenter] postNotificationName:registerWithAccount
                                                        object:[NSNumber numberWithInt:(int)indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (void)showInView:(UIView *)aView animated:(BOOL)animated {
    //Add transparent
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopupViewWhenTagOut)];
    
    UIView *viewBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    viewBackground.backgroundColor = UIColor.blackColor;
    viewBackground.alpha = 0.5;
    viewBackground.tag = 20;
    [viewBackground addGestureRecognizer:_tapGesture];
    
    [aView addSubview:viewBackground];

    [aView addSubview:self];
    if (animated) {
        [self fadeIn];
    }
}

- (void)closePopupViewWhenTagOut{
    [self fadeOut];
    [self.superview removeGestureRecognizer:_tapGesture];
}

- (void)fadeIn {
    [self setAlpha: 0.0];
    [self setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.3, 1.3)];
    
    [UIView animateWithDuration:.35 animations:^{
        [self setAlpha: 1.0];
        [self setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
    }];
}

- (void)fadeOut {
    //xoa background black
    for (UIView *subView in self.window.subviews){
        if (subView.tag == 20){
            [subView removeFromSuperview];
        }
    }
    
    [UIView animateWithDuration:.35 animations:^{
        [self setAlpha: 0.0];
        [self setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.3, 1.3)];
    }completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // dismiss self
}

- (void)cancelTrunking{
    [self fadeOut];
}

@end
