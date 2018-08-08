//
//  AppStrings.h
//  linphone
//
//  Created by admin on 11/5/17.
//
//

#ifndef AppStrings_h
#define AppStrings_h

#define cloudfoneBundleID   @"com.ods.cloudfoneapp"

#define USERNAME ([[NSUserDefaults standardUserDefaults] objectForKey:key_login])
#define PASSWORD ([[NSUserDefaults standardUserDefaults] objectForKey:key_password])
#define SIP_DOMAIN ([[NSUserDefaults standardUserDefaults] objectForKey:key_ip])
#define PORT ([[NSUserDefaults standardUserDefaults] objectForKey:key_port])

//detect iphone5 and ipod5
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

#define link_picutre_chat_group @"http://anh.ods.vn/uploads"

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

#define userimage   @"userimage"

#define playVideoMessage            @"playVideoMessage"
#define receiveIQResultLeaveRoom    @"receiveIQResultLeaveRoom"
#define receiveIQErrorLeaveRoom     @"receiveIQErrorLeaveRoom"
#define getAllGroupsForAccountSuccessful    @"getAllGroupsForAccountSuccessful"

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

#define CreateRequestResetPassword      @"CreateRequestResetPassword"
#define ConfirmRequestResetPassword     @"ConfirmRequestResetPassword"

#define single_cloudfone        @"cloudfone.vn"
#define xmpp_cloudfone          @"xmpp.cloudfone.vn"
#define xmpp_cloudfone_group    @"conference.xmpp.cloudfone.vn"

#pragma mark - Keys for app

#define AuthUser                @"ddb7c103eb98"
#define AuthKey                 @"2b909f73069e47dba6feddb7c103eb98"
#define hash_register           @"hash_register"

#define language_key            @"language_key"
#define key_en                  @"en"
#define key_vi                  @"vi"

#define key_login               @"key_login"
#define key_password            @"key_password"
#define key_ip                  @"key_ip"
#define key_port                @"key_port"
#define hash_register           @"hash_register"
#define time_register_expire    @"time_register_expire"
#define random_key_register     @"random_key_register"

#define text_error_connection   @"text_error_connection"
#define text_default_error      @"text_default_error"

#define time_register_expire    @"time_register_expire"
#define random_key_register     @"random_key_register"

#define text_input_username     @"text_input_username"
#define text_password           @"text_password"

#define text_sign_in            @"text_sign_in"
#define text_sign_up            @"text_sign_up"
#define text_forgot_password    @"text_forgot_password"
#define text_no_account         @"text_no_account"

#define text_email              @"text_email"
#define text_phone              @"text_phone"
#define text_agree_1            @"text_agree_1"
#define text_agree_2            @"text_agree_2"
#define text_agree_3            @"text_agree_3"

#define text_no_account         @"text_no_account"
#define text_have_account       @"text_have_account"

#define text_phone_empty        @"text_phone_empty"
#define text_email_empty        @"text_email_empty"
#define text_phone_invalid      @"text_phone_invalid"
#define text_email_invalid      @"text_email_invalid"
#define text_accept_terms       @"text_accept_terms"

#define text_error              @"text_error"
#define text_reset_password     @"text_reset_password"

#define text_confirm_code       @"text_confirm_code"
#define text_confirm_content1    @"text_confirm_content1"
#define text_confirm_content2    @"text_confirm_content2"
#define text_enter_confirmation @"text_enter_confirmation"
#define text_confirmcode_empty  @"text_confirmcode_empty"

#define text_confirm            @"text_confirm"
#define text_failed             @"text_failed"

#define text_username_empty     @"text_username_empty"
#define text_password_empty     @"text_password_empty"
#define text_no_internet        @"text_no_internet"

#define text_confirm_change_password        @"text_confirm_change_password"
#define text_username_or_email_not_empty    @"text_username_or_email_not_empty"
#define not_connect_to_server   @"not_connect_to_server"


#define img_menu_message_def    @"img_menu_message_def"
#define img_menu_message_act    @"img_menu_message_act"

#define img_menu_history_def    @"img_menu_history_def"
#define img_menu_history_act    @"img_menu_history_act"

#define img_menu_contacts_def   @"img_menu_contacts_def"
#define img_menu_contacts_act   @"img_menu_contacts_act"

#define img_menu_keypad_def     @"img_menu_keypad_def"
#define img_menu_keypad_act     @"img_menu_keypad_act"

#define img_menu_more_def       @"img_menu_more_def"
#define img_menu_more_act       @"img_menu_more_act"

#define text_not_setup_pbx      @"text_not_setup_pbx"
#define text_pbx_server_empty   @"text_pbx_server_empty"
#define text_pbx_username_empty @"text_pbx_username_empty"
#define text_pbx_password_empty @"text_pbx_password_empty"

#define text_trunking_header    @"text_trunking_header"
#define text_refresh            @"text_refresh"
#define text_popup_account      @"text_popup_account"
#define text_popup_account_pbx  @"text_popup_account_pbx"

#define text_delete             @"text_delete"
#define text_cancel             @"text_cancel"
#define text_finish             @"text_finish"
#define text_setup              @"text_setup"
#define text_edit_profile       @"text_edit_profile"

#define text_status_online      @"text_status_online"
#define text_status_offline     @"text_status_offline"
#define text_status_connecting  @"text_status_connecting"

#define img_conference          @"img_conference"
#define img_conference_over     @"img_conference_over"
#define img_conference_dis      @"img_conference_dis"

#define img_keypad              @"img_keypad"
#define img_keypad_over         @"img_keypad_over"
#define img_keypad_dis          @"img_keypad_dis"

#define img_speaker             @"img_speaker"
#define img_speaker_over        @"img_speaker_over"
#define img_speaker_dis         @"img_speaker_dis"

#define img_video               @"img_video"
#define img_video_over          @"img_video_over"
#define img_video_dis           @"img_video_dis"

#define img_hold                @"img_hold"
#define img_hold_over           @"img_hold_over"
#define img_hold_dis            @"img_hold_dis"

#define img_record              @"img_record"
#define img_record_over         @"img_record_over"
#define img_record_dis          @"img_record_dis"

#define img_mute                @"img_mute"
#define img_mute_over           @"img_mute_over"
#define img_mute_dis            @"img_mute_dis"

#define img_transfer            @"img_transfer"
#define img_transfer_over       @"img_transfer_over"
#define img_transfer_dis        @"img_transfer_dis"

#define img_message             @"img_message"
#define img_message_over        @"img_message_over"
#define img_message_dis         @"img_message_dis"

#define img_send                @"img_send"
#define img_send_over           @"img_send_over"
#define img_send_dis            @"img_send_dis"

#define text_connected          @"text_connected"
#define text_quality_good       @"text_quality_good"
#define text_quality_average    @"text_quality_average"
#define text_quality_low        @"text_quality_low"
#define text_quality_very_low   @"text_quality_very_low"
#define text_quality_worse      @"text_quality_worse"
#define text_quality            @"text_quality"

#define CN_CONFERENCE_VC_TITLE  @"CN_TEXT_CONFERENCE_VC_TITLE"
#define CN_TEXT_ADD_CONFERENCE  @"CN_TEXT_ADD_CONFERENCE"
#define CN_TEXT_END_CONFERENCE  @"CN_TEXT_END_CONFERENCE"

#define text_sync_xmpp          @"text_sync_xmpp"
#define text_search_contact     @"text_search_contact"
#define text_list_friend_accept @"text_list_friend_accept"
#define text_no_contact         @"text_no_contact"
#define text_send_request_msg   @"text_send_request_msg"

#define text_login_failed       @"text_login_failed"
#define text_unknown            @"text_unknown"
#define text_pull_to_refresh    @"text_pull_to_refresh"

#define text_contact_detail     @"text_contact_detail"
#define text_detail_call        @"text_detail_call"
#define text_detail_message     @"text_detail_message"
#define text_detail_invite      @"text_detail_invite"
#define text_detail_block       @"text_detail_block"
#define text_detail_unblock     @"text_detail_unblock"
#define text_detail_video_call  @"text_detail_video_call"

#define type_phone_home         @"home"
#define type_phone_work         @"work"
#define type_phone_fax          @"fax"
#define type_phone_mobile       @"mobile"
#define type_phone_other        @"other"
#define type_cloudfone_id       @"cloudfoneID"

#define text_phone_mobile   @"text_phone_mobile"
#define text_phone_work     @"text_phone_work"
#define text_phone_fax      @"text_phone_fax"
#define text_phone_home     @"text_phone_home"
#define text_phone_other    @"text_phone_other"

#define text_popup_delete_contact_title   @"text_popup_delete_contact_title"
#define text_popup_delete_contact_content @"text_popup_delete_contact_content"

#define text_no             @"text_no"
#define text_yes            @"text_yes"
#define text_today          @"text_today"
#define text_yesterday      @"text_yesterday"
#define text_edit           @"text_edit"

#define text_no_recent_call     @"text_no_recent_call"
#define text_no_missed_call     @"text_no_missed_call"
#define text_no_recorded_call   @"text_no_recorded_call"

#define text_more               @"text_more"
#define text_settings           @"text_settings"
#define text_logout             @"text_logout"

#define text_menu_edit_profile      @"text_menu_edit_profile"
#define text_menu_settings          @"text_menu_settings"
#define text_menu_feedback          @"text_menu_feedback"
#define text_menu_privacy_policy    @"text_menu_privacy_policy"
#define text_menu_introduce         @"text_menu_introduce"

#define text_alert_logout_title     @"text_alert_logout_title"
#define text_alert_logout_content   @"text_alert_logout_content"

#define text_notif_setting      @"text_notif_setting"
#define text_acc_setting        @"text_acc_setting"
#define text_sync_contact       @"text_sync_contact"
#define text_lang_setting       @"text_lang_setting"

#define key_sound_call          @"key_sound_call"
#define key_sound_message       @"key_sound_message"
#define key_vibrate_message     @"key_vibrate_message"

#define welcomeToCloudFone      @"Welcome to CloudFone"

#define text_version            @"text_version"
#define text_pbx_on             @"text_pbx_on"
#define text_pbx_off            @"text_pbx_off"

#define text_change_acc_name    @"text_change_acc_name"
#define text_trunking           @"text_trunking"
#define text_change_password    @"text_change_password"
#define text_close_account      @"text_close_account"

#define text_reset_successfully @"text_reset_successfully"
#define text_successfully       @"text_successfully"
#define text_update_failed      @"text_update_failed"

#define text_trunking_account   @"text_trunking_account"
#define text_trunking_pbx       @"text_trunking_pbx"

#define text_trunking_id        @"text_trunking_id"
#define text_trunking_user      @"text_trunking_user"
#define text_trunking_pass      @"text_trunking_pass"
#define text_trunking_clear     @"text_trunking_clear"
#define text_trunking_save      @"text_trunking_save"

#define text_old_pass           @"text_old_pass"
#define text_new_pass           @"text_new_pass"
#define text_confirm_new_pass   @"text_confirm_new_pass"

#define text_change_pass_empty  @"text_change_pass_empty"
#define text_change_pass_len    @"text_change_pass_len"
#define text_old_pass_incorrect @"text_old_pass_incorrect"

#define text_confirm_pass_not_match @"text_confirm_pass_not_match"

#define text_reload_app_for_change_language @"text_reload_app_for_change_language"
#define text_change_language    @"text_change_language"
#define text_lang_vi            @"text_lang_vi"
#define text_lang_en            @"text_lang_en"

#define text_notif_setting  @"text_notif_setting"
#define text_acc_setting    @"text_acc_setting"
#define text_sync_contact   @"text_sync_contact"
#define text_lang_setting   @"text_lang_setting"
#define text_app_settings   @"text_app_settings"
#define text_outbot_proxy   @"text_outbot_proxy"

#define text_thong_bao_am_thanh @"text_thong_bao_am_thanh"
#define text_co_chuong_cuoc_goi @"text_co_chuong_cuoc_goi"
#define text_co_chuong_tin_nhan @"text_co_chuong_tin_nhan"
#define text_thong_bao_rung     @"text_thong_bao_rung"
#define text_rung_tin_nhan      @"text_rung_tin_nhan"

#define text_call_detail_header @"text_call_detail_header"
#define text_add_new_contact    @"text_add_new_contact"
#define text_add_exists_contact @"text_add_exists_contact"

#define text_block_user         @"text_block_user"
#define text_unblock_user       @"text_unblock_user"
#define text_call_missed        @"text_call_missed"

#define text_policy             @"text_policy"
#define text_policy_title1      @"text_policy_title1"
#define text_policy_content1    @"text_policy_content1"
#define text_policy_title2      @"text_policy_title2"
#define text_policy_content2    @"text_policy_content2"
#define text_policy_title3      @"text_policy_title3"
#define text_policy_content3    @"text_policy_content3"

#define text_introduce          @"text_introduce"
#define text_ods_company        @"text_ods_company"
#define text_introduce_content  @"text_introduce_content"

#define text_feedback           @"text_feedback"
#define text_saving             @"text_saving"
#define text_new_contact        @"text_new_contact"
#define text_contact_name       @"text_contact_name"
#define text_contact_sipPhone   @"text_contact_sipPhone"
#define text_contact_company    @"text_contact_company"
#define text_contact_email      @"text_contact_email"
#define text_contact_phone      @"text_contact_phone"
#define text_contact_type       @"text_contact_type"
#define text_edit_contact       @"text_edit_contact"
#define text_add_contact_failed     @"text_add_contact_failed"
#define text_update_contact_failed  @"text_update_contact_failed"


#define text_not_id_pbx         @"text_not_id_pbx"
#define text_pbx_name           @"text_pbx_name"
#define text_pbx_number         @"text_pbx_number"
#define text_pbx_edit           @"text_pbx_edit"
#define text_pbx_new            @"text_pbx_new"

#define text_name_number_not_empty  @"text_name_number_not_empty"
#define text_sync_pbx_contact       @"text_sync_pbx_contact"
#define text_syncing                @"text_syncing"
#define text_contact_syncing        @"text_contact_syncing"
#define text_pbx_contact_exists     @"text_pbx_contact_exists"
#define text_please_check_your_connection   @"text_please_check_your_connection"

#define text_message_received_recall    @"text_message_received_recall"
#define text_message_sent_recall        @"text_message_sent_recall"
#define text_message_sent_recall_fail   @"text_message_sent_recall_fail"
#define text_message_image_received     @"text_message_image_received"

#define text_message_location           @"text_message_location"
#define text_audio_message_received     @"text_audio_message_received"
#define text_audio_message_sent         @"text_audio_message_sent"
#define text_video_message_sent         @"text_video_message_sent"
#define text_video_message_received     @"text_video_message_received"
#define text_image_message_sent         @"text_image_message_sent"

#define text_gallery_header             @"text_gallery_header"

#define text_show_picture               @"text_show_picture"
#define text_show_picture_desc          @"text_show_picture_desc"

#define text_enter_caption_header       @"text_enter_caption_header"
#define text_enter_caption_desc         @"text_enter_caption_desc"

#define text_chat_not_available         @"text_chat_not_available"
#define text_offline                    @"text_offline"

#define text_expire_title   @"text_expire_title"
#define text_expire_info    @"text_expire_info"

#define text_expire_none    @"text_expire_none"
#define text_expire_5s      @"text_expire_5s"
#define text_expire_10s     @"text_expire_10s"
#define text_expire_30s     @"text_expire_30s"
#define text_expire_1m      @"text_expire_1m"
#define text_expire_30m     @"text_expire_30m"
#define text_expire_1h      @"text_expire_1h"
#define text_expire_24h     @"text_expire_24h"

#define text_signed_out         @"text_signed_out"
#define text_no_message         @"text_no_message"
#define text_choose_background  @"text_choose_background"
#define text_cancel_friend      @"text_cancel_friend"
#define text_pending_xmpp       @"text_pending_xmpp"
#define text_accept_friend      @"text_accept_friend"
#define text_send_request_friend    @"text_send_request_friend"


#define TEXT_CONFIRM        @"TEXT_CONFIRM"

#define text_export_title   @"text_export_title"
#define text_export_content @"text_export_content"
#define text_export_success @"text_export_success"

#define text_enable_in_ear      @"text_enable_in_ear"
#define text_disable_in_ear     @"text_disable_in_ear"
#define text_create_contact     @"text_create_contact"
#define text_view_contact       @"text_view_contact"
#define text_expire             @"text_expire"
#define text_save_conversation  @"text_save_conversation"
#define text_delete_conversation @"text_delete_conversation"
#define text_change_bg          @"text_change_bg"
#define text_enable_encryption  @"text_enable_encryption"
#define text_disable_encryption @"text_disable_encryption"
#define text_participants       @"text_participants"
#define text_leave_room         @"text_leave_room"
#define text_change_subject     @"text_change_subject"

#define text_occupiants         @"text_occupiants"
#define text_occupiant          @"text_occupiant"


#define text_you                @"text_you"
#define text_add                @"text_add"

#define text_joined_room_at     @"text_joined_room_at"
#define text_joined_room        @"text_joined_room"
#define joined_the_room         @"joined_the_room"
#define left_the_room           @"left_the_room"
#define change_subject_to       @"change_subject_to"

#define reloadSubjectForRoom    @"reloadSubjectForRoom"
#define userJoinToRoom          @"userJoinToRoom"
#define failedChangeRoomSubject @"failedChangeRoomSubject"

#define k11UpdateMsgAfterReceivedFile       @"k11UpdateMsgAfterReceivedFile"
#define k11UpdateAfterDeleteExpireMsgMeSend @"k11UpdateAfterDeleteExpireMsgMeSend"
#define k11UpdateDeliveredError             @"k11UpdateDeliveredError"
#define k11ProcessingLinkOnMessage          @"k11ProcessingLinkOnMessage"

#define getTextViewMessageChatInfo      @"getTextViewMessageChatInfo"
#define getContentChatMessageViewInfo   @"getContentChatMessageViewInfo"
#define mapContentForMessageTextView    @"mapContentForMessageTextView"

#define updateTitleAlbumForViewChat @"updateTitleAlbumForViewChat"
#define showListAlbumForView        @"showListAlbumForView"
#define chooseOtherAlbumForSent     @"chooseOtherAlbumForSent"

#define saveNewContactFromChatView      @"saveNewContactFromChatView"
#define whenDeleteConversationInChatView    @"whenDeleteConversationInChatView"

#define CN_CONTACT_VERIFICATION_TEXT            @"CN_CONTACT_VERIFICATION_TEXT"
#define CN_CONTACT_VERIFICATION_CONTENT         @"CN_CONTACT_VERIFICATION_CONTENT"
#define CN_CONTACT_VERIFICATION_ACCEPT          @"CN_CONTACT_VERIFICATION_ACCEPT"
#define CN_CONTACT_VERIFICATION_DECLINE         @"CN_CONTACT_VERIFICATION_DECLINE"

#define TEXT_SAVE_VIDEO_SUCCESS     @"TEXT_SAVE_VIDEO_SUCCESS"
#define TEXT_SAVE_VIDEO_FAILED      @"TEXT_SAVE_VIDEO_FAILED"

#define typeTextMessage     @"textMessage"
#define imageMessage        @"imageMessage"
#define audioMessage        @"audioMessage"
#define contactMessage      @"contactMessage"
#define videoMessage        @"videoMessage"
#define fileMessage         @"fileMessage"
#define trackingMessage     @"trackingMessage"
#define descriptionMessage  @"descriptionMessage"
#define receivingFile       @"receivingFile"
#define locationMessage     @"locationMessage"

#define text_type_to_composte   @"text_type_to_composte"
#define text_new_message        @"text_new_message"

#define text_destructs_5s       @"text_destructs_5s"
#define text_destructs_10s      @"text_destructs_10s"
#define text_destructs_30s      @"text_destructs_30s"
#define text_destructs_1m       @"text_destructs_1m"
#define text_destructs_30m      @"text_destructs_30m"
#define text_destructs_1h       @"text_destructs_1h"
#define text_destructs_24h      @"text_destructs_24h"
#define text_is_typing          @"text_is_typing"
#define text_chat_offline       @"text_chat_offline"

#define TEXT_START_CHAT     @"TEXT_START_CHAT"
#define TEXT_KICK_USER      @"TEXT_KICK_USER"
#define TEXT_BAN_USER       @"TEXT_BAN_USER"

#define TEXT_LEAVE_CONF_TITLE       @"TEXT_LEAVE_CONF_TITLE"
#define TEXT_LEAVE_CONF_CONTENT     @"TEXT_LEAVE_CONF_CONTENT"
#define TEXT_CHANGE_ROOMNAME_TITLE  @"TEXT_CHANGE_ROOMNAME_TITLE"
#define TEXT_CHANGE_ROOMNAME_PLHD   @"TEXT_CHANGE_ROOMNAME_PLHD"
#define TEXT_CHANGE_ROOMNAME_CANCEL @"TEXT_CHANGE_ROOMNAME_CANCEL"
#define TEXT_CHANGE_ROOMNAME_SAVE   @"TEXT_CHANGE_ROOMNAME_SAVE"

#define text_failed_block_contact       @"text_failed_block_contact"

#define text_select_contact             @"text_select_contact"
#define text_list_friend_no_contacts    @"text_list_friend_no_contacts"
#define text_add_new_contact            @"text_add_new_contact"
#define text_add_exists_contact         @"text_add_exists_contact"
#define text_please_enter_confirm_code  @"text_please_enter_confirm_code"
#define choose_contact_for_add_group    @"choose_contact_for_add_group"

#define TEXT_CHANGE_SUBJECT_TITLE   @"TEXT_CHANGE_SUBJECT_TITLE"
#define TEXT_CHANGE_SUBJECT_PLHD    @"TEXT_CHANGE_SUBJECT_PLHD"
#define TEXT_CHANGE_SUBJECT_CANCEL  @"TEXT_CHANGE_SUBJECT_CANCEL"
#define TEXT_CHANGE_SUBJECT_SAVE    @"TEXT_CHANGE_SUBJECT_SAVE"

#define change_subject_failed       @"change_subject_failed"
#define text_update_profile_success @"text_update_profile_success"

#define text_fullname       @"text_fullname"
#define text_address        @"text_address"
#define text_save           @"text_save"

#define leave_room_failed   @"leave_room_failed"


#define receive_call_from   @"receive_call_from"

#pragma mark - Key for notifications

#define showConfirmCodeView     @"showConfirmCodeView"
#define cannotGetHashString     @"cannotGetHashString"
#define registerAccountSuccess  @"registerAccountSuccess"

#define cannotGetHashString     @"cannotGetHashString"
#define registerAccountSuccess  @"registerAccountSuccess"
#define showConfirmCodeView     @"showConfirmCodeView"
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
#define updateProfileSuccessfully       @"updateProfileSuccessfully"
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
#define k11JoinGroupChatSuccessfully    @"k11JoinGroupChatSuccessfully"
#define updateListMemberInRoom              @"updateListMemberInRoom"
#define k11UpdateAllNotisWhenBecomActive    @"k11UpdateAllNotisWhenBecomActive"
#define k11GetListUserInRoomChat            @"k11GetListUserInRoomChat"
#define kOTRMessageReceived                 @"MessageReceivedNotification"
#define k11ShowPopupNewContact              @"k11ShowPopupNewContact"
#define k11ReceiveMsgOtherRoomChat          @"k11ReceiveMsgOtherRoomChat"
#define k11ReceivedRoomChatMessage          @"k11ReceivedRoomChatMessage"
#define updateUnreadMessageForUser          @"updateUnreadMessageForUser"
#define k11ReceiveAudioMessage              @"k11ReceiveAudioMessage"
#define k11DeleteAllMessageAccept           @"k11DeleteAllMessageAccept"
#define closeRightChatGroupVC               @"closeRightChatGroupVC"
#define reloadRightGroupChatVC              @"reloadRightGroupChatVC"


#define text_can_not_save_picture   @"text_can_not_save_picture"
#define text_message_delete         @"text_message_delete"
#define text_message_forward        @"text_message_forward"
#define text_message_recall         @"text_message_recall"
#define text_message_resend         @"text_message_resend"
#define text_message_copy           @"text_message_copy"
#define TEXT_COPIED                 @"TEXT_COPIED"
#define TEXT_RESEND_FAILED          @"TEXT_RESEND_FAILED"

#define TEXT_FAILED_FOR_DELETE_MESSAGE      @"TEXT_FAILED_FOR_DELETE_MESSAGE"
#define TEXT_MESSSAGE_RECEIVED_RECALLED     @"TEXT_MESSSAGE_RECEIVED_RECALLED"
#define TEXT_MESSSAGE_SENT_RECALLED         @"TEXT_MESSSAGE_SENT_RECALLED"
#define TEXT_MESSSAGE_SENT_RECALL_FAILED    @"TEXT_MESSSAGE_SENT_RECALL_FAILED"

#define text_missed_call_from   @"text_missed_call_from"
#define text_can_not_send_image_for_group   @"text_can_not_send_image_for_group"
#define text_can_not_send_image_for_user    @"text_can_not_send_image_for_user"

#define imageMessage        @"imageMessage"
#define audioMessage        @"audioMessage"
#define contactMessage      @"contactMessage"
#define videoMessage        @"videoMessage"
#define fileMessage         @"fileMessage"
#define trackingMessage     @"trackingMessage"
#define descriptionMessage  @"descriptionMessage"
#define receivingFile       @"receivingFile"
#define locationMessage     @"locationMessage"
#define userAvatar          @"userAvatar"

#pragma mark - flags

#define TEXT_CLICK_TO_VIEW      @"TEXT_CLICK_TO_VIEW"
#define TEXT_HOLD_TO_VIEW       @"TEXT_HOLD_TO_VIEW"
#define TEXT_LINK_COPY          @"TEXT_LINK_COPY"
#define TEXT_LINK_OPEN          @"TEXT_LINK_OPEN"
#define TEXT_LINK_CALL          @"TEXT_LINK_CALL"
#define TEXT_LINK_MAILTO        @"TEXT_LINK_MAILTO"

#define PBX_ID                  @"PBX_ID"
#define PBX_USERNAME            @"PBX_USERNAME"
#define PBX_PASSWORD            @"PBX_PASSWORD"
#define PBX_PORT                @"PBX_PORT"
#define PBX_IP_ADDRESSS         @"PBX_IP_ADDRESSS"
#define callnexPBXFlag          @"callnexPBXFlag"
#define transport_udp           @"UDP"

#define chat_resouce            @"chat_resouce"
#define group_chat              @"groupchat"
#define folder_call_records     @"calls_records"

#define text_outging_call       @"text_outging_call"
#define text_incomming_call     @"text_incomming_call"
#define text_minutes            @"text_minutes"
#define text_minute             @"text_minute"
#define text_call_free          @"text_call_free"
#define text_call_aborted       @"text_call_aborted"
#define text_call_declined      @"text_call_declined"

#define missed_call             @"Missed"
#define success_call            @"Success"
#define aborted_call            @"Aborted"
#define declined_call           @"Declined"

#define incomming_call          @"Incomming"
#define outgoing_call           @"Outgoing"
#define text_phone_not_exists   @"text_phone_not_exists"
#define hotline                 @"4113"

#define text_dien_day_tu_thong_tin  @"text_dien_day_tu_thong_tin"
#define text_contact_name           @"text_contact_name"
#define text_contact_cloudfoneId    @"text_contact_cloudfoneId"
#define text_contact_company        @"text_contact_company"
#define text_contact_email          @"text_contact_email"
#define text_contact_phone          @"text_contact_phone"
#define text_contact_type           @"text_contact_type"

#define text_gallery        @"text_gallery"
#define text_camera         @"text_camera"
#define text_remove         @"text_remove"
#define text_crop_image     @"text_crop_image"

#define can_not_send_friend_request @"can_not_send_friend_request"
#define TEXT_TYPE_INDIVIDUAL        @"TEXT_TYPE_INDIVIDUAL"
#define TEXT_TYPE_COMPANY           @"TEXT_TYPE_COMPANY"

#define text_gallery            @"text_gallery"
#define text_camera             @"text_camera"
#define text_remove             @"text_remove"
#define text_crop_image         @"text_crop_image"

#define text_save               @"text_save"
#define text_edit_profile       @"text_edit_profile"
#define text_register_success   @"text_register_success"
#define text_type_to_search     @"text_type_to_search"
#define text_contact_message    @"text_contact_message"

#define login_pbx_success_not_update_token  @"login_pbx_success_not_update_token"
#define register_pbx_failed     @"register_pbx_failed"
#define pbx_has_been_deleted    @"pbx_has_been_deleted"
#define pbx_turn_off            @"pbx_turn_off"
#define pbx_turn_on             @"pbx_turn_on"

#define text_delete_conv_title          @"text_delete_conv_title"
#define text_delete_conv_content        @"text_delete_conv_content"
#define text_choose_contact_for_chat    @"text_choose_contact_for_chat"
#define text_type_to_chat               @"text_type_to_chat"

#define TEXT_DENY_COPY_EXPIRE_IMAGE         @"TEXT_DENY_COPY_EXPIRE_IMAGE"
#define CN_ALERT_POPUP_SAVE_PICTURE_TITLE   @"TEXT_ALERT_POPUP_SAVE_PICTURE_TITLE"
#define CN_ALERT_POPUP_SAVE_PICTURE_CONTENT @"TEXT_ALERT_POPUP_SAVE_PICTURE_CONTENT"

#define kOTRBuddyListUpdate             @"BuddyListUpdateNotification"
#define k11SaveExpireTimeForUser        @"k11SaveExpireTimeForUser"
#define k11EncryptionReloadTb           @"k11EncryptionReloadTb"
#define k11DisableTapGestureChat        @"k11DisableTapGestureChat"

#define k11AudioReceivedOnMessageHistory    @"Audio received"
#define k11ImageReceivedOnMessageHistory    @"Image received"
#define k11LocationReceivedMessage          @"Location Message"

#define future_not_support  @"future_not_support"

#define CN_MESSAGE_VC_POPUP_BLOCK_CONTACT   @"TEXT_MESSAGE_VC_POPUP_BLOCK_CONTACT"
#define CN_MESSAGE_VC_POPUP_UNBLOCK_CONTACT @"TEXT_MESSAGE_VC_POPUP_UNBLOCK_CONTACT"

#define text_warning_block_contact      @"text_warning_block_contact"
#define text_warning_unblock_contact    @"text_warning_unblock_contact"

#define TEXT_ADD_FRIEND_TITLE       @"TEXT_ADD_FRIEND_TITLE"
#define TEXT_SEND_REQUEST           @"TEXT_SEND_REQUEST"
#define TEXT_CANCEL_REQUEST         @"TEXT_CANCEL_REQUEST"
#define TEXT_PLACEHOLDER_REQUEST    @"TEXT_PLACEHOLDER_REQUEST"


#define text_calling        @"text_calling"
#define text_ringing        @"text_ringing"
#define text_busy           @"text_busy"
#define text_terminating    @"text_terminating"
#define text_terminated     @"text_terminated"

#define Close   @"Close"

#define text_options @"text_options"
#define text_send_to_friend @"text_send_to_friend"
#define text_save_to_gallery @"text_save_to_gallery"
#define text_save_image_success @"text_save_image_success"
#define text_save_image_failed @"text_save_image_failed"

#define text_in @"text_in"
#define click_to_view_img   @"click_to_view_img"
#define image_not_exists    @"image_not_exists"

#define sent_message_to_you @"sent_message_to_you"
#define sent_photo_to_you   @"sent_photo_to_you"
#define sent_video_to_you   @"sent_video_to_you"

#define text_contacts_xmpp_sync_success @"text_contacts_xmpp_sync_success"

#define TEXT_OTR_NOT_SUPPORTED  @"TEXT_OTR_NOT_SUPPORTED"
#define scan_from_photo     @"scan_from_photo"
#define text_notification   @"text_notification"
#define cannot_find_qrcode  @"cannot_find_qrcode"
#define text_close          @"text_close"
#define text_load_more      @"text_load_more"
#define text_hi             @"text_hi"

#define text_leave_room     @"text_leave_room"
#define text_is_member      @"text_is_member"

#define text_clear_history_group_chat   @"text_clear_history_group_chat"
#define TEXT_NONE           @"TEXT_NONE"

#define text_leave_and_clear_history_group  @"text_leave_and_clear_history_group"


#define check_pbx_account       @"check_pbx_account"
#define clear_pbx_successfully  @"clear_pbx_successfully"

#define please_input_phone_number   @"please_input_phone_number"
#define text_message_settings   @"text_message_settings"
#define text_call_settings      @"text_call_settings"
#define text_wait_starting_app  @"text_wait_starting_app"

#define text_alert    @"text_alert"
#define text_close    @"text_close"
#define text_ok         @"text_ok"

#define text_unfriend_content   @"text_unfriend_content"
#define text_cannot_send_video  @"text_cannot_send_video"
#define text_cannot_send_picture  @"text_cannot_send_picture"
#define text_clear_chat_history @"text_clear_chat_history"

#define can_not_reset_password  @"can_not_reset_password"
#define reset_password_done     @"reset_password_done"

#define text_not_received       @"text_not_received"
#define text_not_send_message   @"text_not_send_message"

#define text_show_pass   @"text_show_pass"
#define text_hide_pass   @"text_hide_pass"
#define text_capture_sent   @"text_capture_sent"


//Added by David
static NSString *const XMPPMUCAllowInvite = @"muc#roomconfig_allowinvites";
static NSString *const XMPPMUCPrivateStorage = @"jabber:iq:private";
static NSString *const XMPPMUCOwnerInforNamespace = @"http://jabber.org/protocol/disco#info";
static NSString *const XMPPMUCSetLeave = @"sf:group";
static NSString *const XMPPMUCChatState = @"http://jabber.org/protocol/chatstates";
static NSString *const XMPPMUCConfigPersistentRoom = @"muc#roomconfig_persistentroom";
static NSString *const XMPPMUCConfigMemberOnly = @"muc#roomconfig_membersonly";
static NSString *const XMPPMUCConfigPublicRoom = @"muc#roomconfig_publicroom";

// OTRSettingsViewController
#define SETTINGS_STRING NSLocalizedString(@"Settings", @"Title for the Settings screen")
#define SHARE_STRING NSLocalizedString(@"Share", @"Title for sharing a link to the app")
#define NOT_AVAILABLE_STRING NSLocalizedString(@"Not Available", @"Shown when a feature is not available, for example SMS")
#define SHARE_MESSAGE_STRING NSLocalizedString(@"Chat with me securely", @"Body of SMS or email when sharing a link to the app")
#define CONNECTED_STRING NSLocalizedString(@"Connected", @"Whether or not account is logged in")

#define SEND_FEEDBACK_STRING NSLocalizedString(@"Send Feedback", @"String on button to email feedback")

// OTRSettingsDetailViewController
#define SAVE_STRING NSLocalizedString(@"Save", "Title for button for saving a setting")
// OTRDoubleSettingViewController
#define NEW_STRING NSLocalizedString(@"New", "For a new settings value")
#define OLD_STRING NSLocalizedString(@"Old", "For an old settings value")

// OTRQRCodeViewController
#define DONE_STRING NSLocalizedString(@"Done", "Title for button to press when user is finished")
#define QR_CODE_INSTRUCTIONS_STRING NSLocalizedString(@"This QR Code contains a link to http://omniqrcode.com/q/chatsecure and will redirect to the App Store.", @"Instructions label text underneath QR code")

// OTRAppDelegate
#define EXPIRATION_STRING NSLocalizedString(@"Background session will expire in one minute.", @"Message displayed in Notification Manager when session will expire in one minute")
#define READ_STRING NSLocalizedString(@"Read", @"Title for action button on alert dialog, used as a verb in the present tense")

// OTRNewAccountViewControler
#define NEW_ACCOUNT_STRING NSLocalizedString(@"New Account", @"Title for New Account View")

//OTRAccount
#define AIM_STRING NSLocalizedString(@"AOL Instant Messenger", "the name for AIM")
#define GOOGLE_TALK_STRING NSLocalizedString(@"Google Talk", "the name for google talk")
#define FACEBOOK_STRING NSLocalizedString(@"Facebook","the name for facebook")
#define JABBER_STRING NSLocalizedString(@"Jabber (XMPP)","the name for jabber, also include (XMPP) at the end")

#define BUDDY_LIST_STRING NSLocalizedString(@"Buddy List", @"Title for the buddy list tab")
#define CONVERSATIONS_STRING NSLocalizedString(@"Conversations", @"Title for the conversations tab")
#define ACCOUNTS_STRING NSLocalizedString(@"Accounts", @"Title for the accounts tab")
#define ABOUT_STRING NSLocalizedString(@"About", @"Title for the about page")
#define CHAT_STRING NSLocalizedString(@"Chat", @"Title for chat view")
#define CANCEL_STRING NSLocalizedString(@"Cancel", @"Cancel an alert window")
#define INITIATE_ENCRYPTED_CHAT_STRING NSLocalizedString(@"Initiate Encrypted Chat", @"Shown when starting an encrypted chat session")
#define CANCEL_ENCRYPTED_CHAT_STRING NSLocalizedString(@"Cancel Encrypted Chat", @"Shown when ending an encrypted chat session")
#define VERIFY_STRING NSLocalizedString(@"Verify", @"Shown when verifying fingerprints")
#define CLEAR_CHAT_HISTORY_STRING NSLocalizedString(@"Clear Chat History", @"String shown in dialog for removing chat history")
#define SEND_STRING NSLocalizedString(@"Send", @"For sending a message")
#define OK_STRING NSLocalizedString(@"OK", @"Accept the dialog")
#define RECENT_STRING NSLocalizedString(@"Recent", @"Title for header of Buddy list view with Recent Buddies")

// Used in OTRChatViewController
#define YOUR_FINGERPRINT_STRING NSLocalizedString(@"Fingerprint for you", @"your fingerprint")
#define THEIR_FINGERPRINT_STRING NSLocalizedString(@"Purported fingerprint for", @"the alleged fingerprint of their other person")
#define SECURE_CONVERSATION_STRING NSLocalizedString(@"You must be in a secure conversation first.", @"Inform user that they must be secure their conversation before doing that action")
#define VERIFY_FINGERPRINT_STRING NSLocalizedString(@"Verify Fingerprint", "Title of the dialog for fingerprint verification")
#define CHAT_INSTRUCTIONS_LABEL_STRING NSLocalizedString(@"Log in on the Settings page (found on top right corner of buddy list) and then select a buddy from the Buddy List to start chatting.", @"Instructions on how to start using the program")
#define OPEN_IN_SAFARI_STRING NSLocalizedString(@"Open in Safari", @"Shown when trying to open a link, asking if they want to switch to Safari to view it")
#define DISCONNECTED_TITLE_STRING NSLocalizedString(@"Disconnected", @"Title of alert when user is disconnected from protocol")
#define DISCONNECTED_MESSAGE_STRING NSLocalizedString(@"You (%@) have disconnected.", @"Message shown when user is disconnected")
#define DISCONNECTION_WARNING_STRING NSLocalizedString(@"When you leave this conversation it will be deleted forever.", @"Warn user that conversation will be deleted after leaving it")
#define CONVERSATION_NOT_SECURE_WARNING_STRING NSLocalizedString(@"Warning: This chat is not encrypted", @"Warn user that the current chat is not secure")
#define CONVERSATION_NO_LONGER_SECURE_STRING NSLocalizedString(@"The conversation with %@ is no longer secure.", @"Warn user that the current chat is no longer secure")
#define CONVERSATION_SECURE_WARNING_STRING NSLocalizedString(@"This chat is secured",@"Warns user that the current chat is secure")
#define CONVERSATION_SECURE_AND_VERIFIED_WARNING_STRING NSLocalizedString(@"This chat is secured and verified",@"Warns user that the current chat is secure and verified")

#define CHAT_STATE_ACTIVE_STRING NSLocalizedString(@"Active",@"String to be displayed when a buddy is Active")
#define CHAT_STATE_COMPOSING_STRING NSLocalizedString(@"Typing",@"String to be displayed when a buddy is currently composing a message")
#define CHAT_STATE_PAUSED_STRING NSLocalizedString(@"Entered Text",@"String to be displayed when a buddy has stopped composing and text has been entered")
#define CHAT_STATE_INACTVIE_STRING NSLocalizedString(@"Inactive",@"String to be displayed when a budy has become inactive")
#define CHAT_STATE_GONE_STRING NSLocalizedString(@"Gone",@"String to be displayed when a buddy is inactive for an extended period of time")

// OTRBuddyListViewController
#define IGNORE_STRING NSLocalizedString(@"Ignore", @"Ignore an incoming message")
#define REPLY_STRING NSLocalizedString(@"Reply", @"Reply to an incoming message")
#define OFFLINE_STRING NSLocalizedString(@"Offline", @"Label in buddylist for users that are offline")
#define AWAY_STRING NSLocalizedString(@"Away", @"Label in buddylist for users that are away")
#define AVAILABLE_STRING NSLocalizedString(@"Available", "Label in buddylist for users that are available")
#define OFFLINE_MESSAGE_STRING NSLocalizedString(@"is now offline", @"Message shown inline for users that are offline")
#define AWAY_MESSAGE_STRING NSLocalizedString(@"is now away", @"Message shown inline for users that are away")
#define AVAILABLE_MESSAGE_STRING NSLocalizedString(@"is now available", "Message shown inline for users that are available")
#define SECURITY_WARNING_STRING NSLocalizedString(@"Security Warning", @"Title of alert box warning about security issues")
#define AGREE_STRING NSLocalizedString(@"Agree", "Agree to EULA")
#define DISAGREE_STRING NSLocalizedString(@"Disagree",@"Disagree with EULA")
#define EULA_WARNING_STRING NSLocalizedString(@"If you require true security, meet in person. This software, its dependencies, or the underlying OTR protocol could contain security issues. The full source code is available on Github but has not yet been audited by an independent security expert. Use at your own risk.", @"Text describing possible security risks")
#define EULA_BSD_STRING @"Modified BSD License:\nTHIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."

// OTRLoginViewController
#define ERROR_STRING NSLocalizedString(@"Error!", "Title of error message popup box")
#define OSCAR_FAIL_STRING NSLocalizedString(@"Failed to start authenticating. Please try again.", @"Authentication failed, tell user to try again")
#define XMPP_FAIL_STRING NSLocalizedString(@"Failed to connect to XMPP server. Please check your login credentials and internet connection and try again.", @"Message when cannot connect to XMPP server")
#define XMPP_PORT_FAIL_STRING NSLocalizedString(@"Domain needs to be set manually when specifying a custom port", @"Message when port is changed but domain not set")
#define LOGGING_IN_STRING NSLocalizedString(@"Logging in...", @"shown during the login proceess")
#define USER_PASS_BLANK_STRING NSLocalizedString(@"You must enter a username and a password to login.", @"error message shown when user doesnt fill in a username or password")
#define BASIC_STRING NSLocalizedString(@"Basic", @"string to describe basic set of settings")
#define ADVANCED_STRING NSLocalizedString(@"Advanced", "stirng to describe advanced set of settings")
#define SSL_MISMATCH_STRING NSLocalizedString(@"SSL Hostname Mismatch",@"stirng for settings to allow ssl mismatch")
#define SELF_SIGNED_SSL_STRING NSLocalizedString(@"Self Signed SSL",@"string for settings to allow self signed ssl stirng")
#define PORT_STRING NSLocalizedString(@"Port", @"Label for port number field for connecting to service")
#define GOOGLE_TALK_EXAMPLE_STRING NSLocalizedString(@"user@gmail.com", @"example of a google talk account");
#define REQUIRED_STRING NSLocalizedString(@"Required",@"String to let user know a certain field like a password is required to create an account")
#define SEND_DELIVERY_RECEIPT_STRING NSLocalizedString(@"Send Delivery Receipts",@"String in login settings asking to send delivery receipts")
#define SEND_TYPING_NOTIFICATION_STRING NSLocalizedString(@"Send Typing Notificaction",@"Stirng in login settings asking to send typing notification")

// OTRAccountsViewController
#define LOGOUT_STRING NSLocalizedString(@"Log Out", @"log out from account")
#define LOGIN_STRING NSLocalizedString(@"Log In", "log in to account")
#define LOGOUT_FROM_AIM_STRING NSLocalizedString(@"Logout from AIM?", "Ask user if they want to logout of AIM")
#define LOGOUT_FROM_XMPP_STRING NSLocalizedString(@"Logout from XMPP?", "ask user if they want to log out of xmpp")
#define DELETE_ACCOUNT_TITLE_STRING NSLocalizedString(@"Delete Account?", @"Ask user if they want to delete the stored account information")
#define DELETE_ACCOUNT_MESSAGE_STRING NSLocalizedString(@"Permanently delete", @"Ask user if they want to delete the stored account information")
#define NO_ACCOUNT_SAVED_STRING NSLocalizedString (@"No Saved Accounts", @"Message infomring user that there are no accounts currently saved")

// OTRAboutViewController
#define ATTRIBUTION_STRING NSLocalizedString(@"ChatSecure is brought to you by many open source projects", @"for attribution of other projects")
#define SOURCE_STRING NSLocalizedString(@"Check out the source here on Github", "let users know source is on Github")
#define CONTRIBUTE_TRANSLATION_STRING NSLocalizedString(@"Contribute a translation", @"label for a link to contribute a new translation")
#define PROJECT_HOMEPAGE_STRING NSLocalizedString(@"Project Homepage", @"label for link to ChatSecure project website")
#define VERSION_STRING NSLocalizedString(@"Version", @"when displaying version numbers such as 1.0.0")

// OTRLoginViewController
#define USERNAME_STRING NSLocalizedString(@"Username", @"Label text for username field on login screen")
#define PASSWORD_STRING NSLocalizedString(@"Password", @"Label text for password field on login screen")
#define DOMAIN_STRING NSLocalizedString(@"Domain", @"Label text for domain field on login scree")
#define LOGIN_TO_STRING NSLocalizedString(@"Login to", @"Label for button describing which protocol you're logging into, will be followed by a protocol such as XMPP or AIM during layout")
#define REMEMBER_USERNAME_STRING NSLocalizedString(@"Remember username", @"label for switch for whether or not we should save their username between launches")
#define REMEMBER_PASSWORD_STRING NSLocalizedString(@"Remember password", @"label for switch for whether or not we should save their password between launches")
#define OPTIONAL_STRING NSLocalizedString(@"Optional", @"Hint text for domain field telling user this field is not required")
#define FACEBOOK_HELP_STRING NSLocalizedString( @"Your Facebook username is not the email address that you use to login to Facebook",@"Text that makes it clear which username to use")


// OTRSettingsManager
#define CRITTERCISM_TITLE_STRING NSLocalizedString(@"Send Crash Reports", @"Title for crash reports settings switch")
#define CRITTERCISM_DESCRIPTION_STRING NSLocalizedString(@"Automatically send anonymous crash logs (opt-in)", @"Description for crash reports settings switch")
#define OTHER_STRING NSLocalizedString(@"Other", @"Title for other miscellaneous settings group")
#define ALLOW_SELF_SIGNED_CERTIFICATES_STRING NSLocalizedString(@"Self-Signed SSL", @"Title for settings cell on whether or not the XMPP library should allow self-signed SSL certificates")
#define ALLOW_SSL_HOSTNAME_MISMATCH_STRING NSLocalizedString(@"Hostname Mismatch", @"Title for settings cell on whether or not the XMPP library should allow SSL hostname mismatch")
#define SECURITY_WARNING_DESCRIPTION_STRING NSLocalizedString(@"Warning: Use with caution! This may reduce your security.", @"Cell description text that warns users that enabling that option may reduce their security.")
#define DELETE_CONVERSATIONS_ON_DISCONNECT_TITLE_STRING NSLocalizedString(@"Auto-delete", @"Title for automatic conversation deletion setting")
#define DELETE_CONVERSATIONS_ON_DISCONNECT_DESCRIPTION_STRING NSLocalizedString(@"Delete chats on disconnect", @"Description for automatic conversation deletion")
#define FONT_SIZE_STRING NSLocalizedString(@"Font Size", @"Size for the font in the chat screen")
#define FONT_SIZE_DESCRIPTION_STRING NSLocalizedString(@"Size for font in chat view", @"description for what the font size setting affects")
#define DISCONNECTION_WARNING_TITLE_STRING NSLocalizedString(@"Signout Warning", @"Title for setting about showing a warning before disconnection")
#define DISCONNECTION_WARNING_DESC_STRING NSLocalizedString(@"1 Minute Alert Before Disconnection", @"Description for disconnection warning setting")

#endif /* AppStrings_h */
