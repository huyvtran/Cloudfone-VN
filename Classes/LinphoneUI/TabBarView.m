/* TabBarViewController.m
 *
 * Copyright (C) 2012  Belledonne Comunications, Grenoble, France
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Library General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#import "TabBarView.h"

@interface TabBarView (){
    
}

@end

@implementation TabBarView

#pragma mark - ViewController Functions

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

    //  Added by Khai Le on 03/10/2018
    self.lbTopSepa.backgroundColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0) blue:(220/255.0) alpha:1.0];
    [self.lbTopSepa mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(1);
    }];
    //  ---
    
    _historyNotificationView.clipsToBounds = YES;
    _historyNotificationView.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(65/255.0)
                                                                blue:(65/255.0) alpha:1.0];
    [self setBackgroundForTabBarButton];
    
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(changeViewEvent:)
											   name:kLinphoneMainViewChange object:nil];
    
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(callUpdate:)
											   name:kLinphoneCallUpdate object:nil];
    
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(messageReceived:)
											   name:kLinphoneMessageReceived object:nil];
    //  Cập nhật số message chưa đọc
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMainBarNotifications)
                                                 name:k11UpdateBarNotifications object:nil];
    
	[self update:FALSE];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    _historyNotificationView.layer.cornerRadius = _historyNotificationView.frame.size.height/2;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self update:FALSE];
}

#pragma mark - Event Functions

- (void)callUpdate:(NSNotification *)notif {
	// LinphoneCall *call = [[notif.userInfo objectForKey: @"call"] pointerValue];
	// LinphoneCallState state = [[notif.userInfo objectForKey: @"state"] intValue];
	[self updateMissedCall:linphone_core_get_missed_calls_count(LC) appear:TRUE];
}

- (void)changeViewEvent:(NSNotification *)notif {
	UICompositeViewDescription *view = [notif.userInfo objectForKey:@"view"];
	if (view != nil) {
		[self updateSelectedButton:view];
	}
}

- (void)messageReceived:(NSNotification *)notif {
	
}

#pragma mark - UI Update

- (void)update:(BOOL)appear {
    [self updateSelectedButton:[PhoneMainView.instance currentView]];
    [self updateMissedCall:0 appear:appear];
}

- (void)updateMissedCall:(int)missedCall appear:(BOOL)appear {
    _historyNotificationLabel.text = @"";
    [_historyNotificationView stopAnimating:YES];
    
    if ([SipUtils getStateOfDefaultProxyConfig] == eAccountNone) {
        [_historyNotificationView stopAnimating:appear];
        return;
    }
    NSString *account = [SipUtils getAccountIdOfDefaultProxyConfig];
    missedCall = [NSDatabase getUnreadMissedCallHisotryWithAccount: account];
    
	if (missedCall > 0) {
        _historyNotificationView.hidden = NO;
        //  _historyNotificationLabel.text = [NSString stringWithFormat:@"%i", missedCall];
		//  [_historyNotificationView startAnimating:appear];
	} else {
        _historyNotificationView.hidden = YES;
		//  [_historyNotificationView stopAnimating:appear];
	}
}

- (void)updateSelectedButton:(UICompositeViewDescription *)view {
    _historyButton.selected = [view equal:CallsHistoryViewController.compositeViewDescription] ||
    [view equal:HistoryDetailsView.compositeViewDescription];
    
	_contactsButton.selected = [view equal:ContactsViewController.compositeViewDescription] ||
							   [view equal:KContactDetailViewController.compositeViewDescription];
	_dialerButton.selected = [view equal:DialerView.compositeViewDescription];
    _moreButton.selected = [view equal:MoreViewController.compositeViewDescription];
}

#pragma mark - Action Functions

- (IBAction)onHistoryClick:(id)event {
    linphone_core_reset_missed_calls_count(LC);
    [self update:FALSE];
    [PhoneMainView.instance updateApplicationBadgeNumber];
    [PhoneMainView.instance changeCurrentView:CallsHistoryViewController.compositeViewDescription];
}

- (IBAction)onContactsClick:(id)event {
	[ContactSelection setAddAddress:nil];
	[ContactSelection enableEmailFilter:FALSE];
	[ContactSelection setNameOrEmailFilter:nil];
	//  [PhoneMainView.instance changeCurrentView:ContactsListView.compositeViewDescription];
    [PhoneMainView.instance changeCurrentView:ContactsViewController.compositeViewDescription];
}

- (IBAction)onDialerClick:(id)event {
	[PhoneMainView.instance changeCurrentView:DialerView.compositeViewDescription];
}

- (IBAction)onSettingsClick:(id)event {
	[PhoneMainView.instance changeCurrentView:SettingsView.compositeViewDescription];
}

- (IBAction)onChatClick:(id)event {
    [PhoneMainView.instance changeCurrentView:KMessageViewController.compositeViewDescription];
}

- (IBAction)onMoreClick:(UIButton *)sender {
    [PhoneMainView.instance changeCurrentView:MoreViewController.compositeViewDescription];
}

- (void)setBackgroundForTabBarButton
{
    [_historyButton setBackgroundImage:[UIImage imageNamed: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:img_menu_history_def]] forState:UIControlStateNormal];
    [_historyButton setBackgroundImage:[UIImage imageNamed: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:img_menu_history_act]] forState:UIControlStateHighlighted];
    [_historyButton setBackgroundImage:[UIImage imageNamed: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:img_menu_history_act]] forState:UIControlStateSelected];
    
    [_contactsButton setBackgroundImage:[UIImage imageNamed: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:img_menu_contacts_def]] forState:UIControlStateNormal];
    [_contactsButton setBackgroundImage:[UIImage imageNamed: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:img_menu_contacts_act]] forState:UIControlStateHighlighted];
    [_contactsButton setBackgroundImage:[UIImage imageNamed: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:img_menu_contacts_act]] forState:UIControlStateSelected];
    
    [_dialerButton setBackgroundImage:[UIImage imageNamed:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:img_menu_keypad_def]] forState:UIControlStateNormal];
    [_dialerButton setBackgroundImage:[UIImage imageNamed:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:img_menu_keypad_act]] forState:UIControlStateHighlighted];
    [_dialerButton setBackgroundImage:[UIImage imageNamed:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:img_menu_keypad_act]] forState:UIControlStateSelected];
    
    [_moreButton setBackgroundImage:[UIImage imageNamed: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:img_menu_more_def]] forState:UIControlStateNormal];
    [_moreButton setBackgroundImage:[UIImage imageNamed: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:img_menu_more_act]] forState:UIControlStateHighlighted];
    [_moreButton setBackgroundImage:[UIImage imageNamed: [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:img_menu_more_act]] forState:UIControlStateSelected];
}


#pragma mark - Khai Le functions

- (void)updateMainBarNotifications{
    [self update: false];
    
    //  Get all missed call number
    NSString *ExtUser = [SipUtils getAccountIdOfDefaultProxyConfig];
    if (![AppUtils isNullOrEmpty: ExtUser]) {
        int numMissedCall = [NSDatabase getAllMissedCallUnreadofAccount: ExtUser];
        [UIApplication sharedApplication].applicationIconBadgeNumber = numMissedCall;
    }else{
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
}

@end
