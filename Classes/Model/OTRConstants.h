//
//  OTRConstants.h
//  Off the Record
//
//  Created by David Chiles on 6/28/12.
//  Copyright (c) 2012 Chris Ballinger. All rights reserved.
//
//  This file is part of ChatSecure.
//
//  ChatSecure is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ChatSecure is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ChatSecure.  If not, see <http://www.gnu.org/licenses/>.

/*
    K11 declare
*/
//Tạo notification cho sự kiện click vào nút cancel khi gọi
#define k11UpdateRosterList @"k11UpdateRosterList"

#define kOTRProtocolLoginSuccess @"LoginSuccessNotification"
#define kOTRProtocolLoginFail @"LoginFailedNotification"
#define kOTRBuddyListUpdate @"BuddyListUpdateNotification"
#define kOTRProtocolLogout @"LogoutNotification"
#define kOTRMessageReceived @"MessageReceivedNotification"
#define kOTRMessageReceiptResonseReceived @"MessageReceiptResponseNotification" 
#define kOTRProtocolDiconnect @"DisconnectedNotification"
#define kOTRSendMessage @"SendMessageNotification"

#define kOTRFacebookDomain @"chat.facebook.com"
#define kOTRGoogleTalkDomain @"talk.google.com"
#define kOTRProtocolTypeXMPP @"xmpp"
#define kOTRProtocolTypeAIM @"prpl-oscar"

#define kOTRNotificationAccountNameKey @"kOTRNotificationAccountNameKey"
#define kOTRNotificationUserNameKey @"kOTRNotificationUserNameKey"
#define kOTRNotificationProtocolKey @"kOTRNotificationProtocolKey"

#define kOTRXMPPAccountAllowSelfSignedSSLKey @"kOTRXMPPAccountAllowSelfSignedSSLKey"
#define kOTRXMPPAccountSendDeliveryReceiptsKey @"kOTRXMPPAccountSendDeliveryReceiptsKey"
#define kOTRXMPPAccountSendTypingNotificationsKey @"kOTRXMPPAccountSendTypingNotificationsKey"
#define kOTRXMPPAccountAllowSSLHostNameMismatch @"kOTRXMPPAccountAllowSSLHostNameMismatch"
#define kOTRXMPPAccountPortNumber @"kOTRXMPPAccountPortNumber"

#define kOTRXMPPResource @"Callnex-XMPP"

#define kOTRFacebookUsernameLink @"http://www.facebook.com/help/?faq=211813265517027#What-are-usernames?"

#define kOTRFeedbackEmail @"support@chatsecure.org"

#define kOTRChatStatePausedTimeout 5
#define kOTRChatStateInactiveTimeout 120

//K11 declare
#define k11ThreeMenuClicked @"k11ThreeMenuClicked"

#define k11TypeOptionsOnTouchGroupMessage @"k11TypeOptionsOnTouchGroupMessage"
#define k11DeleteAllMessageAccept @"k11DeleteAllMessageAccept"

#define k11GetLastRowTableChat @"k11GetLastRowTableChat"
#define k11ClickToVideoViewChat @"k11ClickToVideoViewChat"
#define k11UpdateViewChatsAfterReceivedFile @"k11UpdateViewChatsAfterReceivedFile"
#define k11DeleteReceicingFile @"k11DeleteReceicingFile"
#define k11UpdateAfterDeleteExpireMsgMeSend @"k11UpdateAfterDeleteExpireMsgMeSend"

#define k11ReStartDeleteExpireTimerOfMe @"k11ReStartDeleteExpireTimerOfMe"

#define k11ReceiveCallOnLockScreen @"k11ReceiveCallOnLockScreen"
#define k11ReceiveCallOnBanner @"k11ReceiveCallOnBanner"


#define k11ChooseTakePhoto @"k11ChooseTakePhoto"
#define k11ChooseRecordVideo @"k11ChooseRecordVideo"
#define k11ChooseGalleryVideo @"k11ChooseGalleryVideo"

//Alert popup type
#define k11WhitelistChange @"k11WhitelistChange"
#define k11DeleteGroupClicked @"k11DeleteGroupClicked"
#define k11DeleteContactClicked @"k11DeleteContactClicked"

#define k11LogoutYesClicked @"k11LogoutYesClicked"
#define k11UpdateListChatAfterReceiveFile @"k11UpdateListChatAfterReceiveFile"
#define k11StartTransferMoney @"k11StartTransferMoney"
#define k11DeleteAllHistoryMessage @"k11DeleteAllHistoryMessage"
#define k11ReceiveAudioMessage @"k11ReceiveAudioMessage"
#define k11UpdateMsgAfterReceivedFile @"k11UpdateMsgAfterReceivedFile"
#define k11SaveImageToGallery @"k11SaveImageToGallery"
#define k11SaveVideoToGallery @"k11SaveVideoToGallery"
#define k11UpdateRoomChat @"k11UpdateRoomChat"


#define k11OpenSettingView @"k11OpenSettingView"
#define k11OpenLeftMenuViewChat @"k11OpenLeftMenuViewChat"

#define k11UpdateDeliveredError @"k11UpdateDeliveredError"
#define k11AddDescriptionLocation @"k11AddDescriptionLocation"
#define k11UpdateYourLocation @"k11UpdateYourLocation"
#define k11UpdateLocationSuccess @"k11UpdateLocationSuccess"
#define k11GetYourLocation @"k11GetYourLocation"
#define k11MapsVCGetYourLocation @"k11MapsVCGetYourLocation"
#define k11MapsVCGetLocationSuccess @"k11MapsVCGetLocationSuccess"
#define k11ShowLocationWhenTrack @"k11ShowLocationWhenTrack"
//
#define k11GetRateOfDefaultCurrency @"k11GetRateOfDefaultCurrency"
#define k11ChooseValueForTransferMoney @"k11ChooseValueForTransferMoney"
#define k11GetOptionsOnLocationMessage @"k11GetOptionsOnLocationMessage"

#define k11AcceptTrackingRequest @"k11AcceptTrackingRequest"
#define k11SendTrackingMessage @"k11SendTrackingMessage"

#define k11JoinToGroupExists @"k11JoinToGroupExists"
#define k11ChangeRoomSubject @"k11ChangeRoomSubject"
#define k11UpdateNewGroupName @"k11UpdateNewGroupName"
#define k11CannotChangeRoomName @"k11CannotChangeRoomName"

#define k11UpdateOTRState @"k11UpdateOTRState"
#define k11ReloadContactTableAfterDelete @"k11ReloadContactTableAfterDelete"
#define k11ChooseCountryAccessNumber @"k11ChooseCountryAccessNumber"
#define k11UpdateCountryAccessNumber @"k11UpdateCountryAccessNumber"
#define k11UpdateValueAccessNumber @"k11UpdateValueAccessNumber"


// Khai báo chuỗi mặc định cho app
#define k11Warning @"Warning"
#define k11Error @"Error"
#define k11Confirm @"Confirm"
#define k11CannotConnectToDB @"Can not connect to database!"
#define k11SaveExpireTimeForUser @"k11SaveExpireTimeForUser"
#define Blacklist @"Blacklist"

#define textVideoMessage @"Video message"
#define k11ChatViewController @"k11ChatViewController"


#define k11TransferMoneyText @"Credit transferred"

#define k11UpdateAllNotisWhenBecomActive @"k11UpdateAllNotisWhenBecomActive"

#pragma mark - chuỗi định nghĩa notification cho banner

#define bannerNotifFriendReqest @"bannerNotifFriendReqest"
#define bannerNotifUserMessage @"bannerNotifUserMessage"
#define bannerNotifInviteRoom @"bannerNotifInviteRoom"


#define k11ProcessingLinkOnMessage @"k11ProcessingLinkOnMessage"
#define k11EnableEncryption @"k11EnableEncryption"
#define k11EncryptionReloadTb @"k11EncryptionReloadTb"
#define k11DisableEncryption @"k11DisableEncryption"


#define k11CallHotlineForProduct @"k11CallHotlineForProduct"
#define k11AfterChooseImageForGroup @"k11AfterChooseImageForGroup"
#define k11ShowPopupAfterChooseAvatarForGroup @"k11ShowPopupAfterChooseAvatarForGroup"
#define k11ClearBackgroundWhenReceiveCall @"k11ClearBackgroundWhenReceiveCall"
#define k11UpdateBlockUnblockUser @"k11UpdateBlockUnblockUser"
#define k11ShowPopupNewContact @"k11ShowPopupNewContact"
#define k11UpdateViewChatOfCurrentUserWhenLockScreen @"k11UpdateViewChatOfCurrentUserWhenLockScreen"

#define disableRightMenuWhenChatWithAgent @"disableRightMenuWhenChatWithAgent"
#define k11ShowCallDiclinedForUser @"k11ShowCallDiclinedForUser"
#define k11ProccessRequestVideoCall @"k11ProccessRequestVideoCall"

#define k11EnableWhiteList @"k11EnableWhiteList"
#define k11DeclineEnableWhiteList @"k11DeclineEnableWhiteList"
#define k11SetNewPhoneForRecipient @"k11SetNewPhoneForRecipient"
#define k11ShowPopupAddContactOnBubble @"k11ShowPopupAddContactOnBubble"
#define k11ShowViewTrunkingPBX @"k11ShowViewTrunkingPBX"
#define k11EnableTrunkingAccount @"k11EnableTrunkingAccount"
#define k11EnableScrolledForTableView @"k11EnableScrolledForTableView"
#define k11AcceptDeletePhoneNumber @"k11AcceptDeletePhoneNumber"
#define k11WhenClickOnCustomerServices @"k11WhenClickOnCustomerServices"
#define k11AcceptDeleteAllPersonInGroup @"k11AcceptDeleteAllPersonInGroup"
#define k11CancelEditAvatarForContact @"k11CancelEditAvatarForContact"
#define k11UpdateAndHideLbNewMessage @"k11UpdateAndHideLbNewMessage"
#define k11CloseKeyBoardWhenTapViewChat @"k11CloseKeyBoardWhenTapViewChat"
#define k11UpdateAmountForCallnexPinless @"k11UpdateAmountForCallnexPinless"

#define k11ImportContactSuccessfully @"k11ImportContactSuccessfully"

#define k11UpdateNotisWhenDeleteConversation @"k11UpdateNotisWhenDeleteConversation"
#define k11ResendImageToUser @"k11ResendImageToUser"

#define listContactForImport @"listContactForImport"
#define k11ListContactForAdd @"k11ListContactForAdd"
#define k11NotConnectToInternet @"k11NotConnectToInternet"

#define k11ListSyncContact @"k11ListSyncContact"

#pragma mark - Khai báo cho loại phone
#define typePhoneHome @"home"
#define typePhoneWork @"work"
#define typePhoneMobile @"mobile"
#define typePhoneFax @"fax"


#define recentEmotionDict @"recentEmotionDict"
#define customer_service @"customer_service"
#define listXmppCS @"listXmppCS"

#define accessNumber @"accessNumber"
#define keyCountry @"keyCountry"
#define keyAccessNumber @"keyAccessNumber"
#define addSubViewForMenuIcon @"addSubViewForMenuIcon"
#define closeAllRadialMenu @"closeAllRadialMenu"

#define k11HeightToolbar 42.0

