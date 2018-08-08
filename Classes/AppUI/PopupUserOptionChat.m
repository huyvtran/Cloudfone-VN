//
//  PopupUserOptionChat.m
//  linphone
//
//  Created by Ei Captain on 7/20/16.
//
//

#import "PopupUserOptionChat.h"
#import "PhoneMainView.h"
#import "MainChatViewController.h"
#import "NSDatabase.h"

@interface PopupUserOptionChat (){
    BOOL isBlock;
    UIView *showMessageView;
}

@end

@implementation PopupUserOptionChat

@synthesize _tbView, _tapGesture, _callnexID, _idContact;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // My code here
        self.backgroundColor = UIColor.whiteColor;
        self.layer.borderWidth = 3.0;
        self.layer.borderColor = [UIColor colorWithRed:(24/255.0) green:(185/255.0)
                                                  blue:(153/255.0) alpha:1.0].CGColor;
        
        _tbView = [[UITableView alloc] initWithFrame: CGRectMake(4, 4, frame.size.width-8, frame.size.height-8)];
        _tbView.scrollEnabled = NO;
        _tbView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tbView.separatorInset = UIEdgeInsetsZero;
        [self addSubview: _tbView];
    }
    return self;
}

- (void)showInView:(UIView *)aView animated:(BOOL)animated {
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
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)fadeOut {
    for (UIView *subView in self.window.subviews) {
        if (subView.tag == 20) {
            [subView removeFromSuperview];
        }
    }
    [UIView animateWithDuration:.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

//  Cập nhật giá trị block cho user
- (void)setupBlockValueForUser {
    isBlock = [NSDatabase checkContactInBlackList:_idContact andCloudfoneID:_callnexID];
    _tbView.delegate = self;
    _tbView.dataSource = self;
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.font = [AppUtils fontRegularWithSize:16.0];
    cell.textLabel.textColor = UIColor.grayColor;
    
    //  set background khi click vào cell
    UIView *selected_bg = [[UIView alloc] init];
    selected_bg.backgroundColor = [UIColor colorWithRed:(223/255.0) green:(255/255.0)
                                                   blue:(133/255.0) alpha:1];
    cell.selectedBackgroundView = selected_bg;
    
    if (indexPath.row != eBanUser) {
        UIView *sepaView = [[UIView alloc] initWithFrame:CGRectMake(0, 39, self.frame.size.width, 1)];
        sepaView.backgroundColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0)
                                                    blue:(220/255.0) alpha:1.0];
        [cell addSubview: sepaView];
    }
    
    switch (indexPath.row) {
        case eStartChat: {
            cell.textLabel.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:TEXT_START_CHAT];
            break;
        }
        case eBlockUser:{
            if (isBlock) {
                cell.textLabel.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_unblock_user];
            }else{
                cell.textLabel.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_block_user];
            }
            break;
        }
        case eKickUser:{
            cell.textLabel.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:TEXT_KICK_USER];
            break;
        }
        case eBanUser:{
            cell.textLabel.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:TEXT_BAN_USER];
            break;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *curCell = [tableView cellForRowAtIndexPath: indexPath];
    curCell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    [self fadeOut];
    switch (indexPath.row)
    {
        case eStartChat: {
            [[NSNotificationCenter defaultCenter] postNotificationName:closeRightChatGroupVC object:nil];
            [[LinphoneAppDelegate sharedInstance] setFriendBuddy: [AppUtils getBuddyOfUserOnList: _callnexID]];
            [[PhoneMainView instance] changeCurrentView:[MainChatViewController compositeViewDescription]
                                                   push:false];
            break;
        }
        case eBlockUser:{
            if (!isBlock) {
                BOOL isBlocked = [NSDatabase addContactToBlacklist:_idContact andCloudFoneID:_callnexID];
                if (isBlocked) {
                    NSArray *blackList = [NSDatabase getAllUserInCallnexBlacklist];
                    [[LinphoneAppDelegate sharedInstance].myBuddy.protocol blockUserInCallnexBlacklist: blackList];
                    [[LinphoneAppDelegate sharedInstance].myBuddy.protocol activeBlackListOfMe];
                    
                    //  reload lại rightVC khi block thành công
                    [[NSNotificationCenter defaultCenter] postNotificationName:reloadRightGroupChatVC object:nil];
                }else{
                    [self makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_failed_block_contact] duration:1.5 position:CSToastPositionCenter];
                }
            }else{
                BOOL isRemoved = [NSDatabase removeContactFromBlacklist:_idContact andCloudFoneID:_callnexID];
                if (isRemoved) {
                    NSArray *blackList = [NSDatabase getAllUserInCallnexBlacklist];
                    [[LinphoneAppDelegate sharedInstance].myBuddy.protocol blockUserInCallnexBlacklist: blackList];
                    [[LinphoneAppDelegate sharedInstance].myBuddy.protocol activeBlackListOfMe];
                    
                    //  reload lại rightVC khi unblock thành công
                    [[NSNotificationCenter defaultCenter] postNotificationName:reloadRightGroupChatVC object:nil];
                }else{
                    [self makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_failed_block_contact] duration:1.5 position:CSToastPositionCenter];
                }
            }
            break;
        }
        case eKickUser:{
            NSString *roomName = [NSDatabase getRoomNameOfRoomWithRoomId: [LinphoneAppDelegate sharedInstance].idRoomChat];
            [[LinphoneAppDelegate sharedInstance].myBuddy.protocol kickOccupantInRoomChat:roomName withNickName:_callnexID];
        }
        case eBanUser:{
            NSString *roomName = [NSDatabase getRoomNameOfRoomWithRoomId: [LinphoneAppDelegate sharedInstance].idRoomChat];
            NSString *user = [NSString stringWithFormat:@"%@%@", _callnexID, xmpp_cloudfone];
            
            [[LinphoneAppDelegate sharedInstance].myBuddy.protocol banOccupantInRoomChat:roomName withUser:user];
            break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}



@end
