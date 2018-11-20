//
//  AppStrings.h
//  linphone
//
//  Created by admin on 11/5/17.
//
//

#ifndef AppStrings_h
#define AppStrings_h

#define SHOW_LOGS @"[Show logs]"
#define HEADER_ICON_WIDTH 35.0
#define cloudfoneBundleID   @"com.ods.cloudfoneapp"

#define simulator       @"x86_64"
#define Iphone5_1       @"iPhone5,1"
#define Iphone5_2       @"iPhone5,2"
#define Iphone5c_1      @"iPhone5,3"
#define Iphone5c_2      @"iPhone5,4"
#define Iphone5s_1      @"iPhone6,1"
#define Iphone5s_2      @"iPhone6,2"
#define Iphone6         @"iPhone7,2"
#define Iphone6_Plus    @"iPhone7,1"
#define Iphone6s        @"iPhone8,1"
#define Iphone6s_Plus   @"iPhone8,2"
#define IphoneSE        @"iPhone8,4"
#define Iphone7_1       @"iPhone9,1"
#define Iphone7_2       @"iPhone9,3"
#define Iphone7_Plus1   @"iPhone9,2"
#define Iphone7_Plus2   @"iPhone9,4"
#define Iphone8_1       @"iPhone10,1"
#define Iphone8_2       @"iPhone10,4"
#define Iphone8_Plus1   @"iPhone10,2"
#define Iphone8_Plus2   @"iPhone10,5"
#define IphoneX_1       @"iPhone10,3"
#define IphoneX_2       @"iPhone10,6"
#define IphoneXR        @"iPhone11,8"
#define IphoneXS        @"iPhone11,2"
#define IphoneXS_Max1   @"iPhone11,6"
#define IphoneXS_Max2   @"iPhone11,4"

//  [Khai le - 25/10/2018]
#define logsFolderName @"LogFiles"

#define USERNAME ([[NSUserDefaults standardUserDefaults] objectForKey:key_login])
#define PASSWORD ([[NSUserDefaults standardUserDefaults] objectForKey:key_password])
#define SIP_DOMAIN ([[NSUserDefaults standardUserDefaults] objectForKey:key_ip])
#define PORT ([[NSUserDefaults standardUserDefaults] objectForKey:key_port])

//detect iphone5 and ipod5
#define IS_IPHONE ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone" ] )
#define IS_IPOD   ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPod touch" ] )

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define IS_NORMALSCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )480 ) < DBL_EPSILON )
#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IS_IPHONE_5 ( IS_IPHONE && IS_WIDESCREEN )
#define IS_IPHONE_4 (IS_IPHONE && IS_NORMALSCREEN)

#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#define IS_IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)

#define IS_IOS6 ([[[UIDevice currentDevice] systemVersion] floatValue] < 7 && [[[UIDevice currentDevice] systemVersion] floatValue] >= 6)

#define IS_IOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)

#define IS_IOS10 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10)

#define IS_IOS11 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11)

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#pragma mark - Fonts

#define link_picture_chat_group @"http://anh.ods.vn/uploads"

#define MYRIADPRO_REGULAR       @"MYRIADPRO-REGULAR"
#define MYRIADPRO_BOLD          @"MYRIADPRO-BOLD"
#define HelveticaNeue           @"HelveticaNeue"
#define HelveticaNeueBold       @"HelveticaNeue-Bold"
#define HelveticaNeueConBold    @"HelveticaNeue-CondensedBold"
#define HelveticaNeueItalic     @"HelveticaNeue-Italic"
#define HelveticaNeueLight      @"HelveticaNeue-Light"
#define HelveticaNeueThin       @"HelveticaNeue-Thin"

#define idContactUnknown    -9999
#define idSyncPBX           @"keySyncPBX"
#define accSyncPBX          @"accSyncPBX"
#define nameContactSyncPBX  @"CloudFone PBX"
#define nameSyncCompany     @"Online Data Services"
#define keySyncPBX          @"CloudFonePBX"

#define prefix_CHAT_NOTIF   @"prefix_CHAT_NOTIF"
#define prefix_CHAT_BURN    @"prefix_CHAT_BURN"
#define prefix_CHAT_BLOCK   @"prefix_CHAT_BLOCK"

#pragma mark - API

#define link_api                @"https://wssf.cloudfone.vn/api/SoftPhone"
#define funcLogin               @"Login"
#define getLoginInfoFunc        @"GetLoginInfo"
#define createRequestFunc       @"CreateRequest"
#define confirmRequestFunc      @"ConfirmRequest"
#define getServerInfoFunc       @"GetServerInfo"
#define changePasswordFunc      @"ChangeUserPassword"
#define forgotPassword          @"ChangePassword"
#define getServerContacts       @"GetServerContacts"
#define getImagesBackground     @"GetImagesBackground"
#define ChangeCustomerIOSToken  @"ChangeCustomerIOSToken"
#define DecryptRSA              @"DecryptRSA"
#define PushSharp               @"PushSharp"
#define GetUserInChatRoom       @"GetUserInChatRoom"
#define GetInfoMissCall         @"GetInfoMissCall"
#define ChangeExtPass           @"ChangeExtPass"



#pragma mark - Keys for app

#define AuthUser                @"ddb7c103eb98"
#define AuthKey                 @"2b909f73069e47dba6feddb7c103eb98"

#define language_key            @"language_key"
#define key_en                  @"en"
#define key_vi                  @"vi"

#define key_login               @"key_login"
#define key_password            @"key_password"
#define key_ip                  @"key_ip"
#define key_port                @"key_port"


#define img_menu_history_def    @"img_menu_history_def"
#define img_menu_history_act    @"img_menu_history_act"

#define img_menu_contacts_def   @"img_menu_contacts_def"
#define img_menu_contacts_act   @"img_menu_contacts_act"

#define img_menu_keypad_def     @"img_menu_keypad_def"
#define img_menu_keypad_act     @"img_menu_keypad_act"

#define img_menu_more_def       @"img_menu_more_def"
#define img_menu_more_act       @"img_menu_more_act"

#define type_phone_home         @"home"
#define type_phone_work         @"work"
#define type_phone_fax          @"fax"
#define type_phone_mobile       @"mobile"
#define type_phone_other        @"other"
#define type_cloudfone_id       @"cloudfoneID"

#define key_sound_call          @"key_sound_call"





#define text_please_enter_confirm_code  @"text_please_enter_confirm_code"



#pragma mark - Key for notifications

#define closeViewForgotPassword @"closeViewForgotPassword"
#define registerWithAccount     @"registerWithAccount"
#define callnexFriendsRequest   @"callnexFriendsRequest"
#define k11UpdateNewGroupName   @"k11UpdateNewGroupName"
#define updateDeliveredChat     @"updateDeliveredChat"
#define getRowsVisibleViewChat  @"getRowsVisibleViewChat"
#define k11TouchOnMessage       @"k11TouchOnMessage"
#define k11SaveConversationChat @"k11SaveConversationChat"
#define recentEmotionDict       @"recentEmotionDict"
#define resetPasswordSucces     @"resetPasswordSucces"
#define closeViewResetPassword  @"closeViewResetPassword"

#define resetPasswordSucces     @"resetPasswordSucces"
#define networkChanged          @"networkChanged"
#define updateTokenForXmpp      @"updateTokenForXmpp"

#define k11RegistrationUpdate   @"k11RegistrationUpdate"

#define addNewContactInContactView          @"addNewContactInContactView"
#define k11ReloadAfterDeleteAllCall         @"k11ReloadAfterDeleteAllCall"
#define updateNumberHistoryCallRemove       @"updateNumberHistoryCallRemove"
#define k11SendMailAfterSaveConversation    @"k11SendMailAfterSaveConversation"

#define finishLoadContacts      @"finishLoadContacts"
#define editHistoryCallView     @"editHistoryCallView"
#define finishRemoveHistoryCall @"finishRemoveHistoryCall"
#define reloadHistoryCall       @"reloadHistoryCall"

#define k11ClickOnViewTrunkingPBX       @"k11ClickOnViewTrunkingPBX"
#define k11EnableWhiteList              @"k11EnableWhiteList"
#define k11DeclineEnableWhiteList       @"k11DeclineEnableWhiteList"
#define k11DeclineEnableHideMsg         @"k11DeclineEnableHideMsg"
#define selectTypeForPhoneNumber        @"selectTypeForPhoneNumber"
#define saveNewContactFromChatView      @"saveNewContactFromChatView"
#define k11DismissKeyboardInViewChat    @"k11DismissKeyboardInViewChat"
#define activeOutgoingFileTransfer      @"activeOutgoingFileTransfer"
#define reloadCloudFoneContactAfterSync @"reloadCloudFoneContactAfterSync"

#define k11AcceptRequestedSuccessfully  @"k11AcceptRequestedSuccessfully"
#define updatePreviewImageForVideo      @"updatePreviewImageForVideo"

#define k11RejectFriendRequestSuccessfully  @"k11RejectFriendRequestSuccessfully"
#define k11ReloadListFriendsRequested       @"k11ReloadListFriendsRequested"
#define k11DeleteMsgWithRecallID            @"k11DeleteMsgWithRecallID"
#define k11SubjectOfRoomChanged             @"k11SubjectOfRoomChanged"

#define k11UpdateBarNotifications           @"k11UpdateBarNotifications"

#define afterLeaveFromRoomChat          @"afterLeaveFromRoomChat"
#define aUserLeaveRoomChat              @"aUserLeaveRoomChat"
#define whenRoomDestroyed               @"whenRoomDestroyed"
#define k11CreateGroupChatSuccessfully  @"k11CreateGroupChatSuccessfully"

#define updateListMemberInRoom              @"updateListMemberInRoom"
#define k11UpdateAllNotisWhenBecomActive    @"k11UpdateAllNotisWhenBecomActive"
#define k11GetListUserInRoomChat            @"k11GetListUserInRoomChat"
#define kOTRMessageReceived                 @"MessageReceivedNotification"
#define k11ShowPopupNewContact              @"k11ShowPopupNewContact"
#define k11ReceiveMsgOtherRoomChat          @"k11ReceiveMsgOtherRoomChat"
#define k11ReceivedRoomChatMessage          @"k11ReceivedRoomChatMessage"
#define updateUnreadMessageForUser          @"updateUnreadMessageForUser"
#define k11DeleteAllMessageAccept           @"k11DeleteAllMessageAccept"
#define closeRightChatGroupVC               @"closeRightChatGroupVC"
#define reloadRightGroupChatVC              @"reloadRightGroupChatVC"



#define userAvatar          @"userAvatar"

#pragma mark - flags

#define PBX_ID                  @"PBX_ID"
#define PBX_SERVER              @"PBX_SERVER"
#define PBX_USERNAME            @"PBX_USERNAME"
#define PBX_PASSWORD            @"PBX_PASSWORD"
#define PBX_PORT                @"PBX_PORT"
#define PBX_IP_ADDRESSS         @"PBX_IP_ADDRESSS"
#define callnexPBXFlag          @"callnexPBXFlag"
#define transport_udp           @"UDP"

#define folder_call_records     @"calls_records"


#define missed_call             @"Missed"
#define success_call            @"Success"
#define aborted_call            @"Aborted"
#define declined_call           @"Declined"

#define incomming_call          @"Incomming"
#define outgoing_call           @"Outgoing"
#define hotline                 @"4113"


#define Close   @"Close"

#endif /* AppStrings_h */
