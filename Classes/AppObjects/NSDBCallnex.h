//
//  NSDBCallnex.h
//  linphone
//
//  Created by user on 4/3/14.
//
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "FMDB.h"
#import "ContactObject.h"
#import "ContactChatObj.h"
#import "GroupObject.h"
#import "NSBubbleData.h"
#import "ConversationObject.h"
#import "PhoneBookObject.h"
#import "LinphoneAppDelegate.h"

@interface NSDBCallnex : NSObject

//  Thêm hoặc update contact khi đồng bộ
+ (void)addNewOrUpdateContactWithCloudFoneID: (NSString *)CloudFoneID andName: (NSString *)Name andAvatar: (NSString *)Avatar andAddress: (NSString *)address andEmail: (NSString *)email;
+ (void)saveProfileForAccount: (NSString *)account withName: (NSString *)Name andAvatar: (NSString *)Avatar andAddress: (NSString *)address andEmail: (NSString *)email withStatus: (NSString *)status;
+ (NSString *)getStatusXmppOfAccount: (NSString *)CloudFoneID;
+ (NSDictionary *)getProfileInfoOfAccount: (NSString *)account;
+ (NSString *)getAvatarDataOfAccount: (NSString *)account;
+ (NSString *)getProfielNameOfAccount: (NSString *)account;

+ (NSString *)filePath;
+ (void)openDB;
+ (void)closeDB;

+(void) InsertHistory : (NSString *)call_id status : (NSString *)status phoneNumber : (NSString *)phone_number callDirection : (NSString *)callDirection recordFiles : (NSString*) record_files duration : (int)duration date : (NSString *)date time : (NSString *)time time_int : (int)time_int rate : (float)rate sipURI : (NSString*)sipUri MySip : (NSString *)mysip kCallId: (NSString *)kCallId andFlag: (int)flag andUnread: (int)unread;
+(NSMutableArray *) getDateHistory:(BOOL)missed;
+(NSMutableArray *) getDateHistoryLastTime;
+(NSMutableArray *) getAllRowsHistoryByDateLastTime:(NSString *)date;
+(NSArray *) getAllRowsHistoryByDate:(NSString *)date;
+(NSArray *) getAllRowsHistoryByDate:(NSString *)date Missed:(BOOL)missed;
+(NSArray *) getAllRowsHistory;
+(NSString *) checkOutgoingHistory:(NSString *)phone;
+(NSArray *) getAllRowsByCallDirection : (NSString *)direction phone:(NSString *)phoneCall;
+(void) deleteRowsHistoryById: (NSString *)_id;
+(void) deleteAllRowsHistory;

/* Connect to database */
+ (BOOL)connectCallnexDB;
+ (BOOL)connectAddContactCallnexDB;

+ (BOOL)addContactToCallnexDB:(ContactObject *)aContact;
+ (BOOL)addContactToCallnexDBWithThread:(ContactObject *)aContact;
+ (BOOL)addContactToCallnexDBInBackground:(ContactObject *)aContact;

//  Add phone cho thread them moi contact
+ (void)addPhoneOfContactToCallnexDB: (NSArray *)phoneList withIdContact: (int)idContact;
+ (void)addPhoneOfContactToCallnexDBWithThread: (NSArray *)phoneList withIdContact: (int)idContact;
+ (BOOL)addPhoneOfContactToCallnexDBInBackground: (NSArray *)phoneList withIdContact: (int)idContact;

/*--Add list phone cho contact--*/
+ (BOOL)addPhoneForAContact: (NSArray *)phoneList withIdContact: (int)idContact;

+ (int)getIdOfLastContact;
+ (BOOL)disconnectToCallnexDB;
+ (BOOL)disconnectToAddContactCallnexDB;
+ (BOOL)disconnectThreadDB;


+ (NSMutableArray *)getODSContactInDBWithThread;

//  Get danh sach cloudfone binh thuong
+ (NSMutableArray *)getCloudFoneContactInDatabase;

/*--Hàm lấy danh sách Callnex contact khi dang sync--*/
+ (NSMutableArray *)getCallnexContactInCallnexDBWhenSyncing;


+ (NSMutableArray *)getAllContactInCallnexDBWithThread;
+ (NSMutableArray *)getAllContactInCallnexDBWhenSyncingContact;
+ (ContactObject *)getAContactOfDB: (int)idContact;
+ (NSMutableArray *)getPhoneNumberOfAContact: (int)idContact;
+ (NSString *)getCallnexIDOfContact: (int)idContact;

+ (BOOL)updateContactInformation: (int)idContact andUpdateInfo: (ContactObject *)infoUpdate;
+ (void)updatePhoneNumberOfContact: (int)idContact andListPhone: (NSArray *)listPhone;

#pragma mark - groups
+ (ContactObject *)getAContactForAddToGroup: (int)idContact;

// Kiểm tra group nào trong database hay không
+ (BOOL)checkGroupExistsInCallnexDB;

/*--Get list phone in whitelist or Blacklist--*/
+ (NSMutableArray *)getListPhoneIsBlackList: (BOOL)isBlackList isWhiteList: (BOOL)isWhiteList;

/*--Get danh sách callex list trong Whitelist--*/
+ (NSMutableArray *)getAllCallnexListInWhiteList;

#pragma mark - GROUPS

/*--Thêm một record vào database --*/
+ (BOOL)insertGroupRecordIntoCallnexDB: (GroupObject *)aGroup;
+ (BOOL)insertPersonIntoGroup: (int)groupId andPerson: (int)personId;

/*--Lấy tất cả danh sách group trong database--*/
+ (NSMutableArray *)getAllGroupListInCallnexDB;

/*--Thêm mới group vào database--*/
+ (BOOL)addNewGroupWithGroupName: (NSString *)groupName andDescription: (NSString *)groupDesc andImage: (NSString *)groupAvatar;

/*--Lấy thông tin của 1 group--*/
+ (GroupObject *)getGroupInfoWithId: (int)groupId;

/*--Đếm số thành viên trong 1 groups--*/
+ (int)getNumMemberOfGroup: (int)groupId;

/*--Lấy tất cả các thành viên có trong group--*/
+ (NSMutableArray *)getAllMemberOfGroup: (int)groupId;

// Lấy danh sách các số callnex chưa có trong group hiện tại
+ (NSMutableArray *)getCallnexListForAddToGroup: (int)idGroup;

/*--Lấy danh sách các số callnex chưa có trong group hiện tại--*/
+ (NSMutableArray *)getCallnexUserNotExistsInGroup: (int)groupId;

/*--Thêm tất cả các thành viên đã chọn vào group--*/
+ (BOOL)addAllMemberIntoGroupWith: (int)idGroup andListMember: (NSArray *)listMember;

// Thêm một thành viên vào group
+ (BOOL)addMemberIntoGroup: (int)idMember andGroupId: (int)idGroup;

// Cập nhật member count của group với số contact thêm mới vào
+ (BOOL)updateMemberCountOfGroup: (int)newMemberCount andGroupId: (int)groupId typeUpdate: (NSString *)typeStr;

// Xoá group trong database
+ (BOOL)deleteGroupInCallnexDB: (int)groupId;

/*----Xoá các thành viên được chọn ra khỏi group----*/
+ (BOOL)removeChoosedMemberFromCallnexDB: (int)groupId withRemoveList: (NSArray *)removeList;

// Xoá tất cả các thành viên ra khỏi group
+ (BOOL)removeAllMemberFromGroup: (int)groupId;

// Xoá contact ra khỏi group (trường hợp xoá luôn contact)
+ (BOOL)removeContactFromAllGroup: (int)contactId;

#pragma mark - Blacklist & Whitelist

/*----Lấy tất cả user trong Callnex Blacklist----*/
+ (NSMutableArray *)getAllUserInCallnexBlacklist;

#pragma mark - message history

/*--Lấy nội dung cho save conversation--*/
+ (NSString *)getContentMessageOfMeWithUser: (NSString *)userStr;

+ (BOOL)checkContact: (NSString *)userStr existsInList: (NSMutableArray *)listTmp;

/* get contact name */
+ (NSArray *)getContactNameOfCloudFoneID: (NSString *)cloudFoneID;

/* get contact name and avatar image */
+ (NSArray *)getNameAndAvatarOfContact: (int)contactId;

/* get current time */
+ (NSString*)getDateOrTime: (NSString*)stringDay;

/* get id contact with callnexID (this id of last contact) */
+ (int)getContactIDWithCloudFoneID: (NSString *)cloudFoneID;

/* Add unknown number into Blacklist */
+ (BOOL)addCallnexIDIntoBlacklist: (NSString *)callnexID;

/* Cập id của contact sau khi được thêm mới chuyển từ id = -1 sang id mới thêm vào */
+ (BOOL)updateIdOfGroupMemberWithCallnexID: (NSString *)callnexID andIDForUpdate: (int)idUpdate;

+ (PhoneBookObject *)getAPhoneBookObjectOfContact: (int)idContact andPhoneNumber: (NSString *)phoneNumber;

//  Search contact trong danh bạ PBX
+ (void)searchPhoneNumberInPBXContact: (NSString *)searchStr withCurrentList: (NSMutableArray *)currentList;

//  Search contact trong danh bạ
+ (void)searchPhoneBookWithName: (NSString *)searchStr withCurrentList: (NSMutableArray *)currentList;

+ (NSMutableArray *)searchPhoneBookWithName: (NSString *)searchStr;

// Lấy tên contact theo callnex ID
+ (NSString *)getNameOfContactWithCallnexID: (NSString *)callnexID;

/*--get message chưa đọc của một group--*/
+ (int)getNumberMessageUnreadOfGroup: (int)roomID;

/* Delete all message of me with user */
+ (BOOL)deleteMessageOfMe: (NSString *)meString andUser: (NSString *)userString;

// Xóa conversation của mình với group chat
+ (BOOL)deleteConversationOfMeWithRoomChat: (int)roomID;

/*--Xóa conversation của mình với user--*/
+ (BOOL)deleteConversationOfMeWithUser: (NSString *)user;

/*--Xóa tất cả message và conversation của mình--*/
+ (BOOL)deleteAllMessageAndConversationOfMe: (NSString *)myStr;

/* Get content for foward conversation */
+ (NSString *)getContentMessageForwardOfMe: (NSString *)meStr andUser: (NSString *)userStr;

/*--Save ảnh với tham số truyền vào là tên ảnh muốn save và data của ảnh--*/
+ (void)saveImageToDocumentWithName: (NSString *)imageName andImageData: (NSString *)dataStr;

#pragma mark - chats viewcontroller
// Get sendphone của một message
+ (NSString *)getSendPhoneOfMessage: (NSString *)idMessage;

// Hàm get tên file của message forward
+ (NSString *)getFileNameAndTypeMessageForward: (NSString *)idMessage;

// Hàm get details url của message cho resend
+ (NSString *)getDetailUrlForMessageResend: (NSString *)idMessage;

/*---Save ảnh của tin nhắn đc forward và trả về dictionay chứa tên của thumb image và detail image---*/
+ (NSDictionary *)copyImageOfMessageForward: (NSString *)idMsgForward;

/*--Copy file ghi âm khi forward message--*/
+ (NSDictionary *)copyAudioFileOfMessageForward: (NSString *)idMsgForward;

/*---Get data của một message---*/
+ (NSBubbleData *)getDataOfMessage: (NSString *)idMessage;

/*---Get tên ảnh của một tin nhắn hình ảnh---*/
+ (NSString *)getPictureNameOfMessage: (NSString *)idMessage;

/*---Cập nhật nội dung của message recall nhận---*/
+ (BOOL)updateMessageRecallMeSend: (NSString *)idMessage;

/*---Cập nhật trạng thái của message thành đã nhận---*/
+ (BOOL)updateMessageDelivered: (NSString *)idMessage;

/*---Cập nhật trạng thái của message bị lỗi---*/
+ (BOOL)updateMessageDeliveredError: (NSString *)idMessage;

/*---Kiểm tra message đã được nhận hay chưa---*/
+ (BOOL)checkMessageIsReceivedToUser: (NSString *)idMessage;

/*---Update image message vào callnex DB---*/
+ (void)updateImageMessageWithDetailsUrl: (NSString *)detailsUrl andThumbUrl: (NSString *)thumbUrl ofImageMessage: (NSString *)idMessage;

// Cập nhật delivered của user
+ (void)updateDeliveredMessageOfUser: (NSString *)user idMessage: (NSString *)idMessage;

/*---Hàm chuyển trạng thái tin nhắn từ NO->YES khi vào room chat---*/
+ (BOOL)changeStatusMessageOfGroup: (int)roomID;

/*---Ham xoa 1 message theo id---*/
+ (void)deleteOneExpireMessageMeSend: (NSString *)mePhone andIdMsg: (NSString *)idMessage;

/* Hàm xoá 1 expire message nhận được, nếu thành công sẽ post notification
    đến view chat để cập nhật lại nội dung
*/
+ (void)deleteOneExpireMessageMeReceive: (NSString *)mePhone withUser: (NSString *)userPhone andIdMsg: (NSString *)idMsg;

// Hàm delete 1 message
+ (BOOL)deleteOneMessageWithId: (NSString *)idMessage;

// Hàm remove details của 1 message
+ (void)deleteDetailsOfMessageWithId: (NSString *)idMessage;

// get lịch sử tin nhắn giữa hai số
+ (NSMutableArray *)getListMessagesHistory: (NSString*)myID withPhone: (NSString*)friendID;

/* Save message vào callnex DB với status là NO */
+ (void)saveMessage: (NSString*)sendPhone toPhone: (NSString*)receivePhone withContent: (NSString*)content andStatus: (BOOL)messageStatus withDelivered: (int)typeDelivered andIdMsg: (NSString *)idMsg detailsUrl: (NSString *)detailsUrl andThumbUrl: (NSString *)thumbUrl withTypeMessage: (NSString *)typeMessage andExpireTime: (int)expireTime andRoomID: (NSString *)roomID andExtra: (NSString *)extra andDesc: (NSString *)description;

/* Cập nhật nội dung của message send file sau khi send xong */
+ (BOOL)updateDeliveredMessageAfterSend: (NSString *)idMessage;

/*--Get nội dung của một location mesage--*/
+ (NSDictionary *)getContentOfLocationMessage: (NSString *)idMessage;

#pragma mark - History Call

/* Lấy tổng số phút gọi đến 1 số */
+ (NSArray *)getTotalDurationAndRateOfCallWithPhone: (NSString *)phoneNumber;

/* Get danh sách cho từng section call của user */
+ (NSMutableArray *)getAllCallOnDate: (NSString *)dateStr ofUser: (NSString *)mySip;

// Get danh sách cho từng section call của user
+ (NSMutableArray *)getAllRecordCallOnDate: (NSString *)dateStr ofUser: (NSString *)mySip;

/* Lấy tên contact theo callnexID, nếu ko có trả về Unknown */
+ (NSArray *)getCallNameAndAvatarIntoCallnexID: (NSString *)callnexID;

/* Lấy tất cả message chưa đọc*/
+ (int)getAllMessageUnreadForUIMainBar;

/*----Hàm lấy tất cả các số có trong Callnex Blacklist--*/
+ (NSMutableArray *)getAllNumberInCallnexBlacklist;

/* Hàm lấy tất cả danh sách của Whitelist */
+ (NSMutableArray *)getAllNumberInCallnexWhitelist;

/* Get tất cả history call của 1 user */
+ (NSMutableArray *)getHistoryCallListOfUser: (NSString *)mySip isMissed: (BOOL)missed;

/* Get danh sách các cuộc gọi nhỡ trong 1 ngày */
+ (NSMutableArray *)getMissedCallListOnDate: (NSString *)dateStr ofUser: (NSString *)mySip;

// Get tất cả các section trong của cuoc goi ghi am của 1 user
+ (NSMutableArray *)getHistoryRecordCallListOfUser: (NSString *)mySip;

+ (NSString *)getNameOfPBXPhone: (NSString *)phoneNumber;

/* Lấy tên contact, avatar với phonenumber */
+ (NSArray *)getContactInfosWithPhoneNumber: (NSString *)phoneNumber;


/* Get số section cho tableview trong history call */
+ (int)getSectionForHistoryCall: (NSString *)mySip withPhone: (NSString *)phoneNumber andCallDirection: (NSString *)callDirection;

+ (NSMutableArray *)getAllListCallOfMe: (NSString *)mySip withPhoneNumber: (NSString *)phoneNumber andCallDirection: (NSString *)callDirection;

/* Get lịch sử cuộc gọi trong 1 ngày với callDirection */
+ (NSMutableArray *)getAllCallOfMe: (NSString *)mySip withPhone: (NSString *)phoneNumber andCallDirection: (NSString *)callDirection onDate: (NSString *)dateStr;

/* Hàm xoá 1 record call history trong lịch sử cuộc gọi */
+ (BOOL)deleteRecordCallHistory: (int)idCallRecord withRecordFile: (NSString *)recordFile;

//  Get tên file ghi âm của cuộc gọi nếu có
+ (NSString *)getRecordFileNameOfCall: (int)idCall;

/* Get danh sách record call trong lịch sử cuộc gọi */
+ (NSMutableArray *)getListRecordCallOfUser: (NSString *)mySip;

/* Hàm xoá tất cả history calll */
+ (BOOL)deleteAllHistoryCallOfUser: (NSString *)mySip;

+ (NSArray *)changePhoneMobileWithSavingCall: (NSString *)phoneStr;

/* Get danh sách các contact trong ds cuộc gọi cuối cùng */
+ (NSMutableArray *)getContactInHistoryCallWithRow: (int)numGet andSeachNumber: (NSString *)searchStr;

/* Cập nhật trạng thái flag cho history call trong phần detail */
+ (BOOL)updateCostAndFlagForHistoryCall: (NSString *)phoneNumber andMySip: (NSString *)mySip;

#pragma mark - Access Number
// Kiểm tra một quốc gia có trong list hay không?
+ (BOOL)checkCountryCodeExistsInCurrentList: (NSString *)countryCode;

// Lấy access number ngẫu nhiên của một country
+ (NSString *)getAccessNumberDefaultWithCountry: (NSString *)country;

// Lấy state name theo access number
+ (NSString *)getStateNameOfCountryWithAccessNumber: (NSString *)accessNum;

// Hàm get tên của country theo  code country: US -> United States
+ (NSString *)getCountryNameFromCountryCode: (NSString *)countryCode;

// Kiểm tra 1 access number có thuộc country đó hay không
+ (BOOL)checkAnAccessNumber: (NSString *)accessNum mapWithCountry: (NSString *)country;

// Đếm số contact hiện tại trong list
+ (int)getNumberCurrentOfCountryInList;

#pragma mark - ListPicturesViewController

/* Lấy tên ảnh của một image message */
+ (NSArray *)getPictureURLOfMessageImage: (NSString *)idMessage;


#pragma mark - EXPIRE MESSAGE

// Cập nhật last_time_expire của một msg có expire_time
+ (BOOL)updateLastTimeExpireOfImageMessage: (NSString *)idMessage;

// Get trạng thái delivered của message
+ (int)getDeliveredOfMessage: (NSString *)idMessage;

// Đếm các tin nhắn expire đã đọc text của 1 room chat
+ (int)getAllMessageExpireOfMeInRoomChat: (int)roomID;

// Đếm các tin nhắn expire của 1 user
+ (int)getAllMessageExpireOfMe;

// Cập nhật last_time_expire cho message của user hiện tại
+ (void)updateLastTimeExpireForMessageOfUser: (NSString *)user;

// Xoá tất cả tin nhắn expire đã hết hạn (Thời gian hiện tại >= thời gian hết hạn)
+ (void)deleteAllMesageExpiredOfMe;

// Get danh sách id các msg đã hết hạn
+ (NSArray *)getAllMessageExpireEndedOfMeWithUser: (NSString *)user;

// Get danh sách ID của các message hết hạn của một group (để remove khỏi list chat)
+ (NSArray *)getAllMessageExpireEndedOfMeWithGroup: (int)groupID;

// Hàm get tất cả danh sách ảnh
+ (NSMutableArray *)getAllImageIdOfMeWithUser: (NSString *)userStr;

// Cập nhật last_time_expire khi click play audio có expire time
+ (BOOL)updateExpireTimeWhenClickPlayExpireAudioMessage: (NSString *)idMessage withAudioLength: (int)expireAudio;

#pragma mark - recall message

/* Hàm recall message */
+ (BOOL)updateMessageRecallMeReceive: (NSString *)idMessage;


#pragma mark - room chats

/* Get id của room chat với room name */
+ (int)getIdRoomChatWithRoomName: (NSString *)roomName;

//  Hàm trả về tên contact (nếu tồn tại) hoặc cloudfoneID
+ (NSString *)getFullnameOfContactWithCloudFoneID: (NSString *)cloudfoneID;

/*--Get full name cua mot user--*/
+ (NSString *)getFullnameOfContactWithPhoneNumber: (NSString *)phoneNumber;

/*--Get fullname of contact with contact ID--*/
+ (NSString *)getFullNameOfContactWithID: (int)idContact;

/*--Hàm trả về tên contact (nếu tồn tại) hoặc callnexID--*/
+ (NSString *)getFullnameOfContactForGroupWithCallnexID: (NSString *)callnexID;

#pragma mark - PLACES
/*--Get danh sách location đã send--*/
+ (NSMutableArray *)getLocationListMeSend;

/*--Get list location send trong ngày--*/
+ (NSMutableDictionary *)getListLocationSendOnDate: (NSString *)date;

/*--Get danh sách location nhận--*/
+ (NSMutableArray *)getLocationListMeReceive;

/*--Get list location nhận trong ngày--*/
+ (NSMutableDictionary *)getListLocationReceiveOnDate: (NSString *)date;

/*--Save locaion hiện tại của user--*/
+ (BOOL)saveLocationWithLat: (NSString *)latitude lng: (NSString *)longtitude address: (NSString *)address description: (NSString *)description from: (NSString *)from to: (NSString *)to;

/*--Get danh sách location đã save--*/
+ (NSMutableArray *)getListLocationSaved;

/*--Get danh sách location theo ngày--*/
+ (NSMutableDictionary *)getListLocationSavedOnDate: (NSString *)date;

#pragma mark - tracking contact

/*--get avatar string của một callnex id--*/
+ (NSString *)getAvatarDataStringOfCallnexID: (NSString *)callnexID;

/*--get danh sách group có thể tham gia--*/
+ (NSMutableArray *)getListGroupOfMe;

/*--Xoa group ra khoi database--*/
+ (BOOL)deleteARoomChatWithRoomName: (NSString *)roomName;

/*--get Id cua room chat theo room name--*/
+ (int)getRoomIDOfRoomChatWithRoomName: (NSString *)roomID;

#pragma mark - CONVERSATIONS

/*--Save một conversation cho room chat--*/
+ (void)saveConversationForRoomChat: (int)roomID isUnread: (BOOL)isUnread;

/*--Get nội dung message cuối cùng của một room chat--*/
+ (NSArray *)getContentOfLastMessageOfRoomChat: (int)roomID;

/*--save expire time cho một group--*/
+ (BOOL)saveExpireTimeForGroup: (NSString *)groupId withExpireTime: (int)expireTime;

/*--save expire time cho một user--*/
+ (BOOL)saveExpireTimeForUser: (NSString *)user withExpireTime: (int)expireTime;

/*--Get expire time cua một user--*/
+ (int)getExpireTimeForUser: (NSString *)user;

/*--Get expire time cua một group--*/
+ (int)getExpireTimeForGroup: (int)groupID;

/*--Get background cua user--*/
+ (NSString *)getChatBackgroundOfUser: (NSString *)user;

/*--Kiểm tra user đã có message chưa đọc khi chạy background chưa--*/
+ (BOOL)checkBadgeMessageOfUserWhenRunBackground: (NSString *)user;

/*--Cập nhật trạng thái message khi send file thất bại--*/
+ (BOOL)updateMessageWhenSendFileFailed: (NSString *)idMessage;

/*--Cập nhật audio message sau khi nhận thành công--*/
+ (BOOL)updateAudioMessageAfterReceivedSuccessfullly: (NSString *)idMessage;

//  Kiểm tra số cloudfoneID tồn tại trong db hay chưa
+ (BOOL)checkACloudFoneIDInPhoneBook: (NSString *)cloudfoneID;

#pragma makr - SYNC PHONEBOOK

/*--Get tat ca message chua doc--*/
+ (int)getAllNumberMessageUnreadForBackground;

/*--Get danh sach message sau 1 message--*/
+ (NSMutableArray *)getListMessageAfterAMessage: (NSString *)idMessage ofUser: (NSString *)user;

/*--Get last call goi di--*/
+ (NSString *)getLastCallOfUser;

/*--Kiem tra user co trong request table hay khong--*/
+ (BOOL)checkRequestOfUser: (NSString *)user;

// Kiểm tra user có trong danh sách request hay chưa
+ (BOOL)checkUserExistsInRequestList: (NSString *)user;

// Xoá user ra khỏi request list
+ (BOOL)removeUserFromRequestSent: (NSString *)userStr;

// Thêm user vào request list
+ (BOOL)addUserToRequestSent: (NSString *)user withIdRequest: (NSString *)idRequeset;

// Get xmpp của user ứng với id_request
+ (NSString *)getStringOfUserWithRequestID: (NSString *)requestID;

/*--Get missed call--*/
+ (int)getNumberMissedCallInHistoryOfUser: (NSString *)user;

/*--Cap nhat tat cac trang thai cua missed call--*/
+ (BOOL)resetAllMissedCallOfUser: (NSString *)user;

// Cap nhat serverID cua so phone cua mot user
+ (BOOL)updateIDServerOfPhone: (NSString *)phone ofUserID: (int)userID withServerID: (long)idServer;

// get id contact da send theo id message
+ (NSString *)getExtraOfMessageWithMessageId: (NSString *)idMessage;

// get callnex id cua contact nhan duoc
+ (NSString *)getCallnexIDOfContactReceived: (NSString *)idMessage;

// Get thong tin cua contact voi id message
+ (NSArray *)getContactInfoOfMessage: (NSString *)idMessage;

// Them moi contact tu bubble chat
+ (BOOL)addNewContactFromBubbleChat: (NSMutableDictionary *)contactInfoDict;

// Thêm mới hoặc cập nhật một country
+ (void)addNewOrUpdateCountryOnList: (NSString *)countryName andCode: (NSString *)countryCode;

// Xoa access number cua mot coutnry
+ (BOOL)deleteAllAccessNumberOfCountry: (NSString *)countryCode;

// Thêm mới một access number của state cho country
+ (void)addNewAccessNumber: (NSString *)accessNum ofState: (NSString *)stateName forCountry: (NSString *)countryCode;

// insert last login cho user
+ (BOOL)insertLastLogoutForUser: (NSString *)account passWord: (NSString *)password andRelogin: (int)relogin;

// check trạng thái relogin
+ (BOOL)checkReloginStateForUser;

// Get thông tin register cho user
+ (NSArray *)getBackupInfoReloginForUser;

// Cập nhật id mới cho message transfer file
+ (BOOL)updateMessageIdOfMessageWithNewMessage: (NSString *)newMessageID andOldMessageID: (NSString *)oldMessageID;

// Cập nhật message recall
+ (BOOL)updateMessageForRecall: (NSString *)idMessage;

// remove details của message media
+ (void)removeDetailsMessageForRecallWithIdMessage: (NSString *)idMessage;

#pragma mark - failed message

// Kiểm tra message có trong failed list hay chưa
+ (BOOL)checkMessageExistsOnFailedList: (NSString *)idMessage;

// Add msg ko thể send được vào list
+ (BOOL)addNewFailedMessageForAccountWithIdMessage: (NSString *)idMessage;

// Get receivePhone và nội dung của message fail
+ (NSArray *)getInfoForSendFailedMessage: (NSString *)idMessage;

// resend tất cả msg đã send thất bại của user
+ (void)resendAllFailedMessageOfAccount: (NSString *)account;

// Kiểm tra số phone có tồn tại trong contact hay chưa
+ (BOOL)checkAPhoneNumber: (NSString *)phoneNumer isExistsOnContact: (int)idContact;

// Get danh sách tất cả các callnex list
+ (NSMutableArray *)getListUserCallnex;

+ (void)updateAvatarForUserWithThread: (NSString *)callnexID withAvatarData: (NSData *)imgData;

// Kiểm tra user upload thành công hay thất bại
+ (BOOL)checkUploadAvatarFailed: (NSString *)account;

+ (void)updateProfileFailedToServer: (NSString *)account;

// Kiểm tra có message unread giữa 2 user hay không?
+ (BOOL)checkUnreadMessageOfMeWithUser: (NSString *)callnexUser;

// Kiểm tra có message unread trong room chat hay không?
+ (BOOL)checkUnreadMessageInRoom: (NSString *)roomID;

+ (NSData *)getAvatarDataFromCacheFolderForUser: (NSString *)callnexID;

#pragma mark - friends request
+ (BOOL)checkRequestFriendExistsOnList: (NSString *)cloudfoneID;

+ (BOOL)addUserToWaitAcceptList: (NSString *)cloudfoneID;

+ (BOOL)checkListAcceptOfUser: (NSString *)account withSendUser: (NSString *)sendUser;

// Get danh sach request ket ban
+ (NSMutableArray *)getListFriendsForAcceptOfAccount: (NSString *)account;

// Dem so luong request ket ban
+ (int)getCountListFriendsForAcceptOfAccount: (NSString *)account;

//  Xoá tất cả các user trong request list hiện tại
+ (void)removeAllUserFromRequestList;

+ (BOOL)removeAnUserFromRequestedList: (NSString *)user;

+ (int)getCountOfRequestedOnList;

+ (void)removeIDServer;

#pragma mark - Sync Phone Book
// Kết nối CSDL cho sync contact
+ (BOOL)connectDatabaseForSyncContact;

// Get list id contact cho sync phonebook
+ (NSString *)sync_pb_getIdsOfContactForSyncPhoneBook;

//  Kiểm tra một tên có trong phone book hay chưa?
+ (BOOL)sync_pb_checkAContactNameInPhoneBook: (NSString *)contactName;

// Thêm contact khi sync phonebook
+ (void)sync_pb_addNewContact:(ContactObject *)aContact;

// Lấy contact id theo tên khi sync phonebook
+ (int)sync_pb_getContactIDWithFullname: (NSString *)fullname;

// Cập nhật hoặc thêm mới số phong cho contact
+ (void)sync_pb_addNewOrUpdateIDServerPhoneForContact: (int)idContact listPhone: (NSArray *)listPhone;

// Get fullname của một contact khi sync phonebook
+ (NSString *)sync_pb_getFullNameOfContactWithID: (int)idContact;

//  Update id server cho contact name va phone
+ (BOOL)updateIDServerForNewContactAfterSync: (int)idServer name: (NSString *)name phone: (NSString *)phone;

// Xoá tất cả các contact cho re add
+ (BOOL)removeAllContactForReAdd;


+ (NSMutableArray *)getListRequestSent: (NSString *)callnexID;

+ (BOOL)checkPendingOfMeWithUser: (NSString *)user;

#pragma mark - other functions

+ (NSString *)getLastLoginUsername;

//+ (BOOL)checkContactIsRequestSent;

//  Kiểm tra trùng tên và contact trong phonebook
+ (NSArray *)checkContactExistsInPhoneBook: (NSString *)contactName andCloudFone: (NSString *)cloudFoneID;

//  Kiểm tra trùng tên và contact trong phonebook
+ (NSString *)checkContactExistsInDatabase: (NSString *)contactName andCloudFone: (NSString *)cloudFoneID;

// Get danh sách số phone chưa được sync
+ (NSString *)getListNewPhoneNumberForSyncContact;
+ (NSMutableArray *)getListPhonesForSyncNewContact;

+ (NSString *)getStringPhoneNumberForSyncOfContact: (int)idContact;
+ (NSString *)threadGetFullNameOfContactWithID: (int)idContact;

#pragma mark - My Functions

//  Hàm lấy danh sách tất cả contact
+ (NSMutableArray *)getAllContactInCallnexDB;

//  Hàm get tất cả các id contact ko nằm trong blacklist để đưa vào whitelist
+ (BOOL)addAllContactsToWhiteList;

//  Xoá lịch sử các cuộc gọi nhỡ của user
+ (BOOL)deleteAllMissedCallOfUser: (NSString *)user;

//  Hàm tạo group chat trong database
+ (BOOL)createRoomChatInDatabase: (NSString *)roomName andGroupName: (NSString *)groupName withSubject: (NSString *)subject;

//  Get lịch sử message của room chat
+ (NSMutableArray *)getListMessagesOfAccount: (NSString *)account withRoomID: (int)roomID;

//  Cập nhật các tin nhắn chưa đọc thành đã đọc cho room chat
+ (void)updateAllMessagesInRoomChat: (int)roomID withAccount: (NSString *)account;

//  Get danh sách conversation của account
+ (NSMutableArray *)getAllConversationForHistoryMessageOfUser: (NSString *)user;

//  Get conversation của các group chat
+ (NSMutableArray *)getAllConversationForGroupOfUser;

+ (ConversationObject *)getConversationForGroup: (NSString *)roomID;

//  Get 1 conversation cua user
+ (ConversationObject *)getConversationOfUser: (NSString *)user;

//  Get danh sách các room chat
+ (NSMutableArray *)getAllRoomChatOfAccount: (NSString *)account;

/*  -> Nếu room đã tồn tại thì update trạng thái
 -> Nếu chưa tồn tại thì thêm mới
 */
+ (void)saveRoomChatIntoDatabase: (NSString *)roomName andGroupName: (NSString *)groupName;

//  Cập nhật tên của phòng
+ (void)updateGroupNameOfRoom: (NSString *)roomName andNewGroupName: (NSString *)newGroupName;

/*
    Khi join vào room chat -> trả về 1 số tin nhắn trước đó
    -> Kiểm tra tin nhắn nhận đc hay chưa -> nếu chưa mới thêm mới vào
*/
+ (BOOL)checkMessageExistsInDatabase: (NSString *)idMessage;

//  get list user trong room hiệnt tại (theo các tin nhắn -> lấy avatar cho bubble cell)
+ (NSMutableArray *)listUserInGroup: (int)roomID;

//  Cập nhật trạng thái deliverd của message gửi trong room chat
+ (BOOL)updateMessageDeliveredWithId: (NSString *)idMessage ofRoom: (NSString *)roomName;

//  Lấy tên của room chat
+ (NSString *)getRoomNameOfRoomWithRoomId: (int)roomId;

//  Lấy tên đại diện của room chat
+ (NSString *)getGroupNameOfRoom: (NSString *)roomName;

//  Lấy tên đại diện của room với roomID
+ (NSString *)getGroupNameOfRoomWithId: (int)roomID;

//  Hàm trả về contact với callnexID
+ (ContactChatObj *)getContactInfoWithCallnexID: (NSString *)callnexID;

//  Kiểm tra user có nằm trong danh sách tắt thông báo hay không?
+ (BOOL)checkUserExistsInMuteNotificationsList: (NSString *)user;

//  Kiểm tra group có trong danh sách mute hay ko
+ (BOOL)checkRoomInMutesNotificationsList: (NSString *)roomID;

//  Tạo unread message cho user
+ (void)markUnreadMessageOfMeWithUser: (NSString *)userStr;

//  chuyển message của room chat thành chưa đọc
+ (void)markUnReadMessageForRoomChat: (NSString *)roomID;

//  Get tất cả các message chưa đọc của mình với 1 user
+ (int)getNumberMessageUnread: (NSString*)account andUser: (NSString*)user;

//  Get tất cả các message chưa đọc của 1 room chat
+ (int)getNumberMessageUnreadOfRoom: (NSString *)roomID;

//  Cập nhật trạng thái mute notification của user
+ (void)updateMuteNotificationsOfUser: (NSString *)user;

//  Cập nhật bật tắt thông báo tin nhắn cho room chat
+ (void)updateMuteNotificationForRoomChat: (NSString *)roomID;

// Cập nhật trạng thái đã đọc khi vào view chat
+ (void)changeStatusMessageAFriend: (NSString*)user;

//  Cập nhật subject của room chat
+ (BOOL)updateSubjectOfRoom: (NSString *)roomName withSubject: (NSString *)subject;

//  Get subject của room chat
+ (NSString *)getSubjectOfRoom: (NSString *)roomName;

//  Lưu background chat của user vào conversation
+ (BOOL)saveBackgroundChatForUser: (NSString *)user withBackground: (NSString *)background;

//  Lưu background chat của group vào conversation
+ (BOOL)saveBackgroundChatForRoom: (NSString *)roomID withBackground: (NSString *)background;

//  Lấy background đã lưu cho view chat room
+ (NSString *)getChatBackgroundForRoom: (NSString *)roomID;

//  Hàm delete tất cả message của 1 user
+ (void)deleteAllMessageWithUser: (NSString *)user;

//  Hàm delete tất cả message của 1 user
+ (void)deleteAllMessageOfRoomChat:(NSString *)roomID;

//  Kiểm tra một số callnex và id contact có trong blacklist hay không
+ (BOOL)checkContactInBlackList: (int)idContact andCloudfoneID: (NSString *)cloudfoneID;

//  kiểm tra cloudfoneId có trong blacklist hay ko?
+ (BOOL)checkCloudFoneIDInBlackList: (NSString *)cloudfoneID ofAccount: (NSString *)account ;

//  Thêm một contact vào Blacklist
+ (BOOL)addContactToBlacklist: (int)idContact andCloudFoneID: (NSString *)cloudFoneID;

// Xoá một contact vào Blacklist
+ (BOOL)removeContactFromBlacklist: (int)idContact andCloudFoneID: (NSString *)cloudFoneID;

#pragma mark - new functions

//  Get conact có cloudfone
+ (NSMutableArray *)getAllCloudFoneContactWithSearch: (NSString *)search;

//  Xoá 1 cloudfoneID ra khỏi blacklist
+ (void)removeCloudFoneFromBlackList: (NSString *)cloudfoneID ofAccount: (NSString *)account;

+ (void)addCloudFoneIDToBlackList: (NSString *)cloudfoneID andIdContact: (int)idContact ofAccount: (NSString *)account;

//  Get tất cả các contact theo search string
+ (NSMutableArray *)getAllContactInCallnexDBWithSearch: (NSString *)search;

+ (void)addPBXContactToDBWithName: (NSString *)name andNumber: (NSString *)number;

//  Xoá tất cả các PBX contacts trước khi thêm
+ (void)removeAllPBXContacts;

+ (NSMutableArray *)getPBXContactsOfUser;

+ (NSMutableArray *)getPBXContactsWithName: (NSString *)name andNumber: (NSString *)number;

//  cập nhật PBX
+ (BOOL)updatePBXContactWithName: (NSString *)name andNumber: (NSString *)number withID: (int)idContact;

+ (BOOL)checkPBXContactExistInDBWithName: (NSString *)name andNumber: (NSString *)number;

//  Lấy pbx name
+ (NSString *)getnameOfContactIfIsPBXContact: (NSString *)number;

+ (BOOL)deletePBXContactWithID: (int)idContact;

//  get id cuoi cung them vao app
+ (int)getLastIDContactFromApp;

// Lọc callnex contact bị trùng trong danh sách
+ (NSMutableArray *)getAllCallnexListForFilterContact;

#pragma mark - ODS
//  Xoa 1 user vao bang room chat
+ (void)removeUser: (NSString *)user fromRoomChat: (NSString *)roomName forAccount: (NSString *)account;

+ (void)saveUser: (NSString *)user toRoomChat: (NSString *)roomName forAccount: (NSString *)account;

+ (void)saveRoomSubject: (NSString *)subject forRoom: (NSString *)roomName;

+ (NSMutableArray *)getListOccupantsInGroup: (NSString *)roomName ofAccount: (NSString *)account;

+ (void)removeAllUserInGroupChat;
+ (void)removeAllUserInGroupChat: (NSString *)roomName;

+ (void)updateContactInfo: (int)idContact withInfo: (NSDictionary *)info;
+ (void)updateContactInfo: (int)idContact withInfo: (NSDictionary *)info andNewId: (int)newContactId;

+ (NSString *)getLinkImageOfMessage: (NSString *)idMessage;

+ (void)updateImageMessageUserWithId: (NSString *)idMsgImage andDetailURL: (NSString *)detailURL andThumbURL: (NSString *)thumbURL andContent: (NSString *)link;

+ (void)updateLastTimeExpireForMessageOfGroupId: (int)idGroup;


@end
