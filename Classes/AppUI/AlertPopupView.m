//
//  AlertPopupView.m
//  linphone
//
//  Created by user on 19/8/14.
//
//

#import "AlertPopupView.h"
#import "PhoneMainView.h"
#import "NSDatabase.h"

@implementation AlertPopupView
@synthesize _buttonNo, _buttonYes, _firstRect, delegate, _typePopup, _infoDict, _tapGesture;

- (id)initWithTypePopup: (int)type frame: (CGRect)frame info: (NSDictionary *)info{
    self = [super initWithFrame: frame];
    if (self) {
        _typePopup = type;
        if (info != nil) {
            _infoDict = [[NSDictionary alloc] initWithDictionary: info];
        }
        
        // Initialization code
        [self setBackgroundColor:[UIColor whiteColor]];
        [self.layer setBorderWidth: 3.0];
        [self.layer setBorderColor: [UIColor colorWithRed:(23/255.0) green:(184/255.0)
                                                     blue:(151/255.0) alpha:1.0].CGColor];
        //  Add logo image
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(3, 3, frame.size.width-6, 40)];
        [headerView setBackgroundColor:[UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                                        blue:(230/255.0) alpha:1.0]];
        
        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.height, headerView.frame.size.height)];
        [logoImageView setImage:[UIImage imageNamed:@"ic_offline.png"]];
        [headerView addSubview: logoImageView];
        
        //Add Label
        CGRect nameLabelRect = CGRectMake(45, 0, 200, 40);
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameLabelRect];
        nameLabel.textColor = [UIColor colorWithRed:(138/255.0) green:(138/255.0)
                                               blue:(138/255.0) alpha:1];
        [nameLabel setFont:[UIFont fontWithName:HelveticaNeue size:18.0]];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setTextAlignment: NSTextAlignmentLeft];
        
        //Adds
        UILabel *labelInfo = [[UILabel alloc] initWithFrame:CGRectMake(10, headerView.frame.origin.y+headerView.frame.size.height+10, frame.size.width-20-10, frame.size.height-8-40-20-35)];
        [labelInfo setFont:[UIFont fontWithName:HelveticaNeue size:16.0]];
        [labelInfo setBackgroundColor:[UIColor clearColor]];
        [labelInfo setTextAlignment: NSTextAlignmentCenter];
        [labelInfo setNumberOfLines: 5];
        [labelInfo setTextColor:[UIColor colorWithRed:(71/255.0) green:(32/255.0)
                                                 blue:(102/255.0) alpha:1]];
        
        //  Add button
        float buttonWidth = (frame.size.width-8-2)/2;
        _buttonYes = [[UIButton alloc] initWithFrame: CGRectMake(4, frame.size.height-35-4, buttonWidth, 35)];
        [_buttonYes setBackgroundColor: [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                         blue:(200/255.0) alpha:1.0]];
        [_buttonYes.titleLabel setFont:[UIFont fontWithName:HelveticaNeueBold size:16.0]];
        [_buttonYes setContentVerticalAlignment: UIControlContentVerticalAlignmentCenter];
        
        [_buttonYes addTarget:self
                       action:@selector(buttonHighlight:)
             forControlEvents:UIControlEventTouchDown];
        
        [_buttonYes addTarget:self
                       action:@selector(buttonYesClicked)
             forControlEvents:UIControlEventTouchUpInside];
        
        //Add button
        _buttonNo = [[UIButton alloc] initWithFrame: CGRectMake(_buttonYes.frame.origin.x+buttonWidth+2, _buttonYes.frame.origin.y, buttonWidth, 35)];
        [_buttonNo setBackgroundColor:[UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                       blue:(200/255.0) alpha:1]];
        [_buttonNo setContentVerticalAlignment: UIControlContentVerticalAlignmentCenter];
        [_buttonNo.titleLabel setFont:[UIFont fontWithName:HelveticaNeueBold size:16.0]];
        [_buttonNo addTarget:self
                      action:@selector(buttonHighlight:)
            forControlEvents:UIControlEventTouchDown];
        [_buttonNo addTarget:self
                      action:@selector(buttonNoClicked)
            forControlEvents:UIControlEventTouchUpInside];
        
        switch (type) {
            case deleteContactPop:{
                /*  Leo Kelvin
                [nameLabel setText: NSLocalizedString(text_popup_delete_contact_title, nil)];
                [labelInfo setText: NSLocalizedString(text_popup_delete_contact_content, nil)];
                [_buttonNo setTitle:NSLocalizedString(text_no, nil) forState:UIControlStateNormal];
                [_buttonYes setTitle:NSLocalizedString(text_yes, nil) forState:UIControlStateNormal];
                */
                break;
            }
            //  Thông báo kết bạn
            case requestFriendPopup:{
                /*  Leo Kelvin
                NSString *cloudFoneID = @"";
                if ([info isKindOfClass:[NSDictionary class]]) {
                    cloudFoneID = [info objectForKey:@"user"];
                }
                NSString *contactName = [NSDBCallnex getNameOfContactWithPhoneNumber: cloudFoneID];
                [nameLabel setText: NSLocalizedString(CN_CONTACT_VERIFICATION_TEXT, nil)];
                [labelInfo setText: [NSString stringWithFormat:@"\"%@\"%@", contactName,NSLocalizedString(CN_CONTACT_VERIFICATION_CONTENT, nil)]];
                [_buttonNo setTitle:NSLocalizedString(CN_CONTACT_VERIFICATION_DECLINE, nil)
                           forState:UIControlStateNormal];
                [_buttonYes setTitle:NSLocalizedString(CN_CONTACT_VERIFICATION_ACCEPT, nil)
                            forState:UIControlStateNormal];
                */
                break;
            }
            case deleteGroupPopup:{
                /*  Leo Kelvin
                [nameLabel setText: NSLocalizedString(CN_ALERT_POPUP_DELETE_GROUP_TITLE, nil)];
                [labelInfo setText: NSLocalizedString(CN_ALERT_POPUP_DELETE_GROUP_CONTENT, nil)];
                [_buttonNo setTitle: NSLocalizedString(text_no, nil) forState:UIControlStateNormal];
                [_buttonYes setTitle: NSLocalizedString(text_yes, nil) forState:UIControlStateNormal];
                */
                break;
            }
            case logoutPopup:{
                /*  Leo Kelvin
                [nameLabel setText: NSLocalizedString(text_alert_logout_title, nil)];
                [labelInfo setText: NSLocalizedString(text_alert_logout_content, nil)];
                [_buttonNo setTitle: NSLocalizedString(text_no, nil) forState:UIControlStateNormal];
                [_buttonYes setTitle: NSLocalizedString(text_yes, nil) forState:UIControlStateNormal];
                */
                break;
            }
            case whitelistPopup:{
                /*  Leo Kelvin
                [nameLabel setText: NSLocalizedString(CN_PROFILE_VC_PASS_CONFIRM, nil)];
                [labelInfo setText: NSLocalizedString(CN_CONTACT_GROUP_VC_WHITELIST, nil)];
                [_buttonNo setTitle:NSLocalizedString(text_no, nil) forState:UIControlStateNormal];
                [_buttonYes setTitle:NSLocalizedString(text_yes, nil) forState:UIControlStateNormal];
                */
                break;
            }
            case deleteAllHistoryMessage:{
                /*  Leo Kelvin
                [nameLabel setText: NSLocalizedString(CN_ALERT_POPUP_DELETE_CONV_TITLE, nil)];
                [labelInfo setText: NSLocalizedString(CN_ALERT_POPUP_DELETE_CONV_CONTENT, nil)];
                [_buttonNo setTitle:NSLocalizedString(text_no, nil) forState:UIControlStateNormal];
                [_buttonYes setTitle:NSLocalizedString(text_yes, nil) forState:UIControlStateNormal];
                */
                break;
            }
            case saveImageInViewChat:{
                /*  Leo Kelvin
                [nameLabel setText: NSLocalizedString(CN_ALERT_POPUP_SAVE_PICTURE_TITLE, nil)];
                [labelInfo setText: NSLocalizedString(CN_ALERT_POPUP_SAVE_PICTURE_CONTENT, nil)];
                [_buttonNo setTitle: NSLocalizedString(text_no, nil)
                           forState:UIControlStateNormal];
                [_buttonYes setTitle: NSLocalizedString(text_yes, nil)
                            forState:UIControlStateNormal];
                */
                break;
            }
            case saveVideoInViewChat:{
                /*  Leo Kelvin
                nameLabel.text = @"Save video";
                //[labelInfo setText: [LinphoneAppDelegate sharedInstance].contentPopup];
                [_buttonNo setTitle:@"NO" forState:UIControlStateNormal];
                [_buttonYes setTitle:@"YES" forState:UIControlStateNormal];
                */
                break;
            }
            case notTrunking:{
                /*  Leo Kelvin
                nameLabel.text = @"SIP Trunking";
                [labelInfo setText: @"SIP Trunking is not available.\nPlease contact our customer service for futher information."];
                [_buttonNo setTitle:@"Call" forState:UIControlStateNormal];
                [_buttonYes setTitle:@"Cancel" forState:UIControlStateNormal];
                */
                break;
            }
            case videoCallNotif:{
                /*  Leo Kelvin
                [nameLabel setText: NSLocalizedString(CN_INCALL_VC_VIDEO_CALL_TITLE, nil)];
                [labelInfo setText: NSLocalizedString(CN_INCALL_VC_VIDEO_CALL_INFO, nil)];
                [_buttonNo setTitle:NSLocalizedString(CN_INCALL_VC_VIDEO_CALL_DECLINE, nil)
                           forState:UIControlStateNormal];
                [_buttonYes setTitle:NSLocalizedString(CN_INCALL_VC_VIDEO_CALL_ACCEPT, nil)
                            forState:UIControlStateNormal];
                */
                break;
            }
            case deletePhoneNumber:{
                /*  Leo Kelvin
                [nameLabel setText: NSLocalizedString(POPUP_DELETE_PHONE_TITLE, nil)];
                [labelInfo setText: [NSString stringWithFormat:@"%@ %@?", NSLocalizedString(POPUP_DELETE_PHONE_CONTENT, nil), [_infoDict objectForKey:@"phoneNumber"]]];
                [_buttonNo setTitle:NSLocalizedString(POPUP_DELETE_PHONE_NO, nil)
                           forState:UIControlStateNormal];
                [_buttonYes setTitle:NSLocalizedString(POPUP_DELETE_PHONE_YES, nil)
                            forState:UIControlStateNormal];
                */
                break;
            }
            case deleteAllPersonInGroup:{
                /*  Leo Kelvin
                [nameLabel setText: NSLocalizedString(TEXT_CONFIRM, nil)];
                [labelInfo setText: [_infoDict objectForKey:@"content"]];
                [_buttonNo setTitle:NSLocalizedString(POPUP_DELETE_PHONE_NO, nil)
                           forState:UIControlStateNormal];
                [_buttonYes setTitle:NSLocalizedString(POPUP_DELETE_PHONE_YES, nil)
                            forState:UIControlStateNormal];
                */
                break;
            }
            case warningAccessNumber:{
                /*  Leo Kelvin
                [nameLabel setText: NSLocalizedString(TEXT_CONFIRM, nil)];
                [labelInfo setText: [_infoDict objectForKey:@"content"]];
                [_buttonYes setTitle:NSLocalizedString(TEXT_CALL_PRE, nil)
                            forState:UIControlStateNormal];
                [_buttonNo setTitle:NSLocalizedString(TEXT_SETTING_PRE, nil)
                           forState:UIControlStateNormal];
                */
                break;
            }
            case eHideMsgPopup:{
                /*  Leo Kelvin
                [nameLabel setText: NSLocalizedString(TEXT_CONFIRM, nil)];
                [labelInfo setText: NSLocalizedString(TEXT_CHANGE_HIDE_MESSAGE, nil)];
                [_buttonNo setTitle:NSLocalizedString(POPUP_DELETE_PHONE_NO, nil)
                           forState:UIControlStateNormal];
                [_buttonYes setTitle:NSLocalizedString(POPUP_DELETE_PHONE_YES, nil)
                            forState:UIControlStateNormal];
                */
                break;
            }
            
            default:
                break;
        }
        //Add subviews to view
        [headerView addSubview: nameLabel];
        [self addSubview: headerView];
        [self addSubview: labelInfo];
        [self addSubview:_buttonNo];
        [self addSubview:_buttonYes];
        _firstRect = self.frame;
    }
    return self;
}

- (void)buttonNoClicked {
    [_buttonNo setBackgroundColor:[UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                   blue:(200/255.0) alpha:1]];
    [self fadeOut];
    switch (_typePopup) {
        case deleteContactPop:
            //do not thing
            break;
        case requestFriendPopup:{
            /*  Leo Kelvin
            NSString *cloudFoneID = [_infoDict objectForKey:@"user"];
            NSString *user = [NSString stringWithFormat:@"%@@%@", cloudFoneID, xmpp_cloudfone];
            NSString *me = [NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone];
             
            [[LinphoneAppDelegate sharedInstance].myBuddy.protocol rejectRequestFromUser:user toMe: me];
            [NSDBCallnex removeAnUserFromRequestedList: cloudFoneID];
            [[NSNotificationCenter defaultCenter] postNotificationName:k11ReloadListFriendsRequested
                                                                object:nil];
            */
            break;
        }
        case videoCallNotif: {
            /*  Leo Kelvin
            NSNumber *valueNumber = [NSNumber numberWithInt: 0];
            [[NSNotificationCenter defaultCenter] postNotificationName:k11ProccessRequestVideoCall object:valueNumber];
            */
            break;
        }
        case whitelistPopup:{
            /*  Leo Kelvin
            [[NSNotificationCenter defaultCenter] postNotificationName:k11DeclineEnableWhiteList object:nil];
            */
            break;
        }
        case eHideMsgPopup:{
            /*  Leo Kelvin
            [[NSNotificationCenter defaultCenter] postNotificationName:k11DeclineEnableHideMsg object:nil];
            */
            break;
        }
        case warningAccessNumber:{
            break;
        }
        default:
            //do not thing
            break;
    }
}

- (void)buttonYesClicked {
    [_buttonYes setBackgroundColor:[UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                   blue:(200/255.0) alpha:1]];

    [self fadeOut];
    switch (_typePopup) {
        case deleteContactPop:
            /*  Leo Kelvin
            [[NSNotificationCenter defaultCenter] postNotificationName:k11DeleteContactClicked
                                                                object:self];
            */
            break;
        case requestFriendPopup:{
            if (_infoDict != nil) {
                NSString *callnexID = [_infoDict objectForKey:@"user"];
                [self showAddNewContactView: callnexID];
            }
            break;
        }
        case deleteGroupPopup:
            /*  Leo Kelvin
            [[NSNotificationCenter defaultCenter] postNotificationName:k11DeleteGroupClicked
                                                                object: nil];
            */
            break;
        case logoutPopup:
            /*  Leo Kelvin
            [[NSNotificationCenter defaultCenter] postNotificationName:k11LogoutYesClicked
                                                                object: nil];
            */
            break;
        case whitelistPopup:
            /*  Leo Kelvin
            [[NSNotificationCenter defaultCenter] postNotificationName:k11WhitelistChange
                                                                object: nil];
            */
            break;
        case delConversation: {
            break;
        }
        case deleteAllHistoryMessage:{
            break;
        }
        case saveImageInViewChat:{
            /*  Leo Kelvin
            [[NSNotificationCenter defaultCenter] postNotificationName:k11SaveImageToGallery
                                                                object: nil];
            */
            break;
        }
        case saveVideoInViewChat:{
            /*  Leo Kelvin
            [[NSNotificationCenter defaultCenter] postNotificationName:k11SaveVideoToGallery
                                                                object: nil];
            */
            break;
        }
        case videoCallNotif:{
            /*  Leo Kelvin
            NSNumber *valueNumber = [NSNumber numberWithInt: 1];
            [[NSNotificationCenter defaultCenter] postNotificationName:k11ProccessRequestVideoCall object:valueNumber];
            */
            break;
        }
        case deletePhoneNumber:{
            /*  Leo Kelvin
            [[NSNotificationCenter defaultCenter] postNotificationName:k11AcceptDeletePhoneNumber
                                                                object:[_infoDict objectForKey:@"phoneIndex"]];
            */
            break;
        }
        case deleteAllPersonInGroup:{
            /*  Leo Kelvin
            [[NSNotificationCenter defaultCenter] postNotificationName:k11AcceptDeleteAllPersonInGroup object:nil];
            */
            break;
        }
        case eHideMsgPopup:{
            /*  Leo Kelvin
            [[NSNotificationCenter defaultCenter] postNotificationName:k11AcceptChangeHideMsg object:nil];
            */
            break;
        }
        case warningAccessNumber:{
            /*  Leo Kelvin
            [self fadeOut];
            [[NSNotificationCenter defaultCenter] postNotificationName:k11AcceptCallPremium object: nil];
            */
            break;
        }
        default:
            break;
    }
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
    self.frame = _firstRect;
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
    UIView *view = [[UIApplication sharedApplication] keyWindow].rootViewController.view;
    for (UIView *subView in view.subviews) {
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // dismiss self
}

- (void)buttonHighlight: (UIButton *)sender{
    [sender setBackgroundColor: [UIColor colorWithRed:(223/255.0) green:(255/255.0)
                                                 blue:(133/255.0) alpha:1]];
}

- (void)removeBackGround: (id)sender {
    UIButton *currentButton = (UIButton *)sender;
    currentButton.backgroundColor = [UIColor clearColor];
}

- (NSString *)removeAllSpecialInString: (NSString *)phoneString {
    NSString *resultStr = @"";
    for (int strCount=0; strCount<phoneString.length; strCount++) {
        char characterChar = [phoneString characterAtIndex: strCount];
        NSString *characterStr = [NSString stringWithFormat:@"%c", characterChar];
        if ([characterStr isEqualToString:@" "] || [characterStr isEqualToString:@"-"] || [characterStr isEqualToString:@"("] || [characterStr isEqualToString:@")"] || [characterStr isEqualToString:@" "]) {
            //do not thing
        }else{
            resultStr = [NSString stringWithFormat:@"%@%@", resultStr, characterStr];
        }
    }
    return resultStr;
}

//  Hiển thị options khu đồng ý yêu cầu kết bạn
- (void)showAddNewContactView: (NSString *)cloudFoneID
{
    /*  Leo Kelvin
    BOOL exists = [NSDBCallnex checkACloudFoneIDInPhoneBook: cloudFoneID];
    // Nếu callnexID đã tồn tại thì accept và không thêm mới
    if (exists) {
        NSString *user = [NSString stringWithFormat:@"%@@%@", cloudFoneID, xmpp_cloudfone];
        NSString *me = [NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone];
        [[LinphoneAppDelegate sharedInstance].myBuddy.protocol sendAcceptRequestFromMe:me toUser:user];
        
        [NSDBCallnex removeAnUserFromRequestedList: cloudFoneID];
        [[NSNotificationCenter defaultCenter] postNotificationName:k11ReloadListFriendsRequested
                                                            object:nil];
    }else{
        // Lưu thông tin contact muốn thêm vào đối tượng
        [[LinphoneAppDelegate sharedInstance]._contactForAdd set_callnexID: cloudFoneID];
        [[LinphoneAppDelegate sharedInstance]._contactForAdd set_phoneNumber: @""];
        [[LinphoneAppDelegate sharedInstance]._contactForAdd set_accept: YES];
    }
    */
}

@end
