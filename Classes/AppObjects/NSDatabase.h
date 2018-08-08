//
//  NSDatabase.h
//  linphone
//
//  Created by admin on 11/11/17.
//
//

#import <Foundation/Foundation.h>
#import "ContactObject.h"
#import "NSBubbleData.h"
#import "ConversationObject.h"
#import "ContactChatObj.h"
#import "MessageEvent.h"

@interface NSDatabase : NSObject

/* Connect to database */
+ (BOOL)connectCallnexDB;

/*--Cap nhat tat cac trang thai cua missed call--*/
+ (BOOL)resetAllMissedCallOfUser: (NSString *)user;

/* Get tất cả history call của 1 user */
+ (NSMutableArray *)getHistoryCallListOfUser: (NSString *)mySip isMissed: (BOOL)missed;

/* Get danh sách các cuộc gọi nhỡ trong 1 ngày */
+ (NSMutableArray *)getMissedCallListOnDate: (NSString *)dateStr ofUser: (NSString *)mySip;

/* Get danh sách cho từng section call của user */
+ (NSMutableArray *)getAllCallOnDate: (NSString *)dateStr ofUser: (NSString *)mySip;

//  Get tên file ghi âm của cuộc gọi nếu có
+ (NSString *)getRecordFileNameOfCall: (int)idCall;

/* Hàm xoá 1 record call history trong lịch sử cuộc gọi */
+ (BOOL)deleteRecordCallHistory: (int)idCallRecord withRecordFile: (NSString *)recordFile;

/* Hàm xoá tất cả history calll */
+ (BOOL)deleteAllHistoryCallOfUser: (NSString *)mySip;

+(void) InsertHistory : (NSString *)call_id status : (NSString *)status phoneNumber : (NSString *)phone_number callDirection : (NSString *)callDirection recordFiles : (NSString*) record_files duration : (int)duration date : (NSString *)date time : (NSString *)time time_int : (int)time_int rate : (float)rate sipURI : (NSString*)sipUri MySip : (NSString *)mysip kCallId: (NSString *)kCallId andFlag: (int)flag andUnread: (int)unread;
+ (void)openDB;
+ (void)closeDB;
+ (NSString *)filePath;

+ (NSArray *)getNameAndAvatarOfContactWithPhoneNumber: (NSString *)phonenumber;
+ (NSDictionary *)getProfileInfoOfAccount: (NSString *)account;
+ (NSString *)getAvatarOfAccount: (NSString *)account;
+ (NSString *)getNameOfContactWithPhoneNumber: (NSString *)phonenumber;
+ (NSString *)getAvatarOfContactWithPhoneNumber: (NSString *)phonenumber;

// insert last login cho user
+ (BOOL)insertLastLogoutForUser: (NSString *)account passWord: (NSString *)password andRelogin: (int)relogin;
+ (NSString *)getUserAccountForLastLogin;

/* Lấy tổng số phút gọi đến 1 số */
+ (NSArray *)getTotalDurationAndRateOfCallWithPhone: (NSString *)phoneNumber;

//  kiểm tra cloudfoneId có trong blacklist hay ko?
+ (BOOL)checkCloudFoneIDInBlackList: (NSString *)cloudfoneID ofAccount: (NSString *)account ;

+ (NSMutableArray *)getAllListCallOfMe: (NSString *)mySip withPhoneNumber: (NSString *)phoneNumber andCallDirection: (NSString *)callDirection;

/* Get lịch sử cuộc gọi trong 1 ngày với callDirection */
+ (NSMutableArray *)getAllCallOfMe: (NSString *)mySip withPhone: (NSString *)phoneNumber andCallDirection: (NSString *)callDirection onDate: (NSString *)dateStr;

+(NSArray *) getAllRowsByCallDirection : (NSString *)direction phone:(NSString *)phoneCall;

//  Xoá lịch sử các cuộc gọi nhỡ của user
+ (BOOL)deleteAllMissedCallOfUser: (NSString *)user;

// Get tất cả các section trong của cuoc goi ghi am của 1 user
+ (NSMutableArray *)getHistoryRecordCallListOfUser: (NSString *)mySip;

// Get danh sách cho từng section call của user
+ (NSMutableArray *)getAllRecordCallOnDate: (NSString *)dateStr ofUser: (NSString *)mySip;

//  Search contact trong danh bạ PBX
+ (void)searchPhoneNumberInPBXContact: (NSString *)searchStr withCurrentList: (NSMutableArray *)currentList;

//  Kiểm tra trùng tên và contact trong phonebook
+ (ContactObject *)checkContactExistsInDatabase: (NSString *)contactName andCloudFone: (NSString *)cloudFoneID;

// Kết nối CSDL cho sync contact
+ (BOOL)connectDatabaseForSyncContact;

/*--Get last call goi di--*/
+ (NSString *)getLastCallOfUser;

+ (void)saveRoomSubject: (NSString *)subject forRoom: (NSString *)roomName;
+ (NSString *)getStatusXmppOfAccount: (NSString *)CloudFoneID;
+ (void)saveProfileForAccount: (NSString *)account withName: (NSString *)Name andAvatar: (NSString *)Avatar andAddress: (NSString *)address andEmail: (NSString *)email withStatus: (NSString *)status;
//  Cập nhật tên của phòng
+ (void)updateGroupNameOfRoom: (NSString *)roomName andNewGroupName: (NSString *)newGroupName;
+ (BOOL)removeAnUserFromRequestedList: (NSString *)user;

/*
 Khi join vào room chat -> trả về 1 số tin nhắn trước đó
 -> Kiểm tra tin nhắn nhận đc hay chưa -> nếu chưa mới thêm mới vào
 */
+ (BOOL)checkMessageExistsInDatabase: (NSString *)idMessage;

/*  -> Nếu room đã tồn tại thì update trạng thái
 -> Nếu chưa tồn tại thì thêm mới
 */
+ (void)saveRoomChatIntoDatabase: (NSString *)roomName andGroupName: (NSString *)groupName;

/* Get id của room chat với room name */
+ (int)getIdRoomChatWithRoomName: (NSString *)roomName;

/*--Save một conversation cho room chat--*/
+ (void)saveConversationForRoomChat: (NSString *)roomID isUnread: (BOOL)isUnread;

+ (BOOL)checkRequestFriendExistsOnList: (NSString *)cloudfoneID;
+ (BOOL)addUserToWaitAcceptList: (NSString *)cloudfoneID;

// Cập nhật delivered của user
+ (void)updateDeliveredMessageOfUser: (NSString *)user idMessage: (NSString *)idMessage;

/* Hàm recall message */
+ (BOOL)updateMessageRecallMeReceive: (NSString *)idMessage;

// Cập nhật message recall
+ (BOOL)updateMessageForRecall: (NSString *)idMessage;
//  Cập nhật subject của room chat
+ (BOOL)updateSubjectOfRoom: (NSString *)roomName withSubject: (NSString *)subject;

//  Cập nhật trạng thái deliverd của message gửi trong room chat
+ (BOOL)updateMessageDeliveredWithId: (NSString *)idMessage ofRoom: (NSString *)roomName;

// remove details của message media
+ (void)removeDetailsMessageForRecallWithIdMessage: (NSString *)idMessage;

//  Kiểm tra user có nằm trong danh sách tắt thông báo hay không?
+ (BOOL)checkUserExistsInMuteNotificationsList: (NSString *)user;

/*--get Id cua room chat theo room name--*/
+ (int)getRoomIDOfRoomChatWithRoomName: (NSString *)roomID;

// Xoá user ra khỏi request list
+ (BOOL)removeUserFromRequestSent: (NSString *)userStr;

// Xoá thông tin user của bảng request
+ (void)removeAllUserFromRequestSentOfAccount: (NSString *)account;

/*--Xoa group ra khoi database--*/
+ (BOOL)deleteARoomChatWithRoomName: (NSString *)roomName;

+ (void)removeAllUserInGroupChat;

// Xóa conversation của mình với group chat
+ (BOOL)deleteConversationOfMeWithRoomChat: (NSString *)roomID;
// Hàm delete 1 message
+ (BOOL)deleteOneMessageWithId: (NSString *)idMessage;
+ (void)removeAllUserInGroupChat: (NSString *)roomName;

//  Xoa 1 user vao bang room chat
+ (void)removeUser: (NSString *)user fromRoomChat: (NSString *)roomName forAccount: (NSString *)account;

+ (void)saveUser: (NSString *)user toRoomChat: (NSString *)roomName forAccount: (NSString *)account;

// Kiểm tra message có trong failed list hay chưa
+ (BOOL)checkMessageExistsOnFailedList: (NSString *)idMessage;

// Add msg ko thể send được vào list
+ (BOOL)addNewFailedMessageForAccountWithIdMessage: (NSString *)idMessage;

/* Save message vào callnex DB với status là NO */
+ (void)saveMessage: (NSString*)sendPhone toPhone: (NSString*)receivePhone withContent: (NSString*)content andStatus: (BOOL)messageStatus withDelivered: (int)typeDelivered andIdMsg: (NSString *)idMsg detailsUrl: (NSString *)detailsUrl andThumbUrl: (NSString *)thumbUrl withTypeMessage: (NSString *)typeMessage andExpireTime: (int)expireTime andRoomID: (NSString *)roomID andExtra: (NSString *)extra andDesc: (NSString *)description;
+ (MessageEvent *)getMessageEventWithId: (NSString *)idMessage;;

/*--Cập nhật audio message sau khi nhận thành công--*/
+ (BOOL)updateAudioMessageAfterReceivedSuccessfullly: (NSString *)idMessage;


/*---Update image message vào callnex DB---*/
+ (void)updateImageMessageWithDetailsUrl: (NSString *)detailsUrl andThumbUrl: (NSString *)thumbUrl ofImageMessage: (NSString *)idMessage;

+ (NSString *)getLinkImageOfMessage: (NSString *)idMessage;

// Cập nhật last_time_expire khi click play audio có expire time
+ (BOOL)updateExpireTimeWhenClickPlayExpireAudioMessage: (NSString *)idMessage withAudioLength: (int)expireAudio;

// get callnex id cua contact nhan duoc
+ (NSString *)getCallnexIDOfContactReceived: (NSString *)idMessage;

+ (NSData *)getAvatarDataFromCacheFolderForUser: (NSString *)callnexID;

// get id contact da send theo id message
+ (NSString *)getExtraOfMessageWithMessageId: (NSString *)idMessage;

// Get trạng thái delivered của message
+ (int)getDeliveredOfMessage: (NSString *)idMessage;

// Hàm get tất cả danh sách ảnh
+ (NSMutableArray *)getAllImageIdOfMeWithUser: (NSString *)userStr;

/* Lấy tên ảnh của một image message */
+ (NSArray *)getPictureURLOfMessageImage: (NSString *)idMessage;

// Cập nhật last_time_expire của một msg có expire_time
+ (BOOL)updateLastTimeExpireOfImageMessage: (NSString *)idMessage;

/* get id contact with callnexID (this id of last contact) */
+ (int)getContactIDWithCloudFoneID: (NSString *)cloudFoneID;

//  Kiểm tra một số callnex và id contact có trong blacklist hay không
+ (BOOL)checkContactInBlackList: (int)idContact andCloudfoneID: (NSString *)cloudfoneID;

/* get contact name */
+ (NSArray *)getContactNameOfCloudFoneID: (NSString *)cloudFoneID;
+ (NSString *)getNameOfPBXPhone: (NSString *)phoneNumber;
/*---Get tên ảnh của một tin nhắn hình ảnh---*/
+ (NSString *)getPictureNameOfMessage: (NSString *)idMessage;

/*--Get background cua user--*/
+ (NSString *)getChatBackgroundOfUser: (NSString *)user;

/*--Kiểm tra user đã có message chưa đọc khi chạy background chưa--*/
+ (BOOL)checkBadgeMessageOfUserWhenRunBackground: (NSString *)user;

// Lấy tên contact theo callnex ID
+ (NSString *)getNameOfContactWithCallnexID: (NSString *)callnexID;

/*--get avatar string của một callnex id--*/
+ (NSString *)getAvatarDataStringOfCallnexID: (NSString *)callnexID;

/*---Get data của một message---*/
+ (NSBubbleData *)getDataOfMessage: (NSString *)idMessage;

/*--Hàm trả về tên contact (nếu tồn tại) hoặc callnexID--*/
+ (NSString *)getFullnameOfContactForGroupWithCallnexID: (NSString *)callnexID;

/*---Cập nhật trạng thái của message thành đã nhận---*/
+ (BOOL)updateMessageDelivered: (NSString *)idMessage withValue: (int)status;

/*---Cập nhật trạng thái của message bị lỗi---*/
+ (BOOL)updateMessageDeliveredError: (NSString *)idMessage;

// get lịch sử tin nhắn giữa hai số
+ (NSMutableArray *)getListMessagesHistory: (NSString*)myID withPhone: (NSString*)friendID;
+ (NSMutableArray *)getListMessagesHistory: (NSString*)myID withPhone: (NSString*)friendID withCurrentPage: (int)curPage andNumPerPage: (int)numPerPage;

// Cập nhật trạng thái đã đọc khi vào view chat
+ (void)changeStatusMessageAFriend: (NSString*)user;

/*---Save ảnh của tin nhắn đc forward và trả về dictionay chứa tên của thumb image và detail image---*/
+ (NSDictionary *)copyImageOfMessageForward: (NSString *)idMsgForward;
/*--Cập nhật trạng thái message khi send file thất bại--*/
+ (BOOL)updateMessageWhenSendFileFailed: (NSString *)idMessage;

/* Cập nhật nội dung của message send file sau khi send xong */
+ (BOOL)updateDeliveredMessageAfterSend: (NSString *)idMessage;

// Hàm get details url của message cho resend
+ (NSString *)getDetailUrlForMessageResend: (NSString *)idMessage;

+ (void)updateImageMessageUserWithId: (NSString *)idMsgImage andDetailURL: (NSString *)detailURL andThumbURL: (NSString *)thumbURL andContent: (NSString *)link;

// Hàm remove details của 1 message
+ (void)deleteDetailsOfMessageWithId: (NSString *)idMessage;

/*--Save ảnh với tham số truyền vào là tên ảnh muốn save và data của ảnh--*/
+ (void)saveImageToDocumentWithName: (NSString *)imageName andImageData: (NSString *)dataStr;

+ (NSMutableArray *)getListOccupantsInGroup: (NSString *)roomName ofAccount: (NSString *)account;

+ (NSString *)getAvatarDataOfAccount: (NSString *)account;
+ (NSString *)getProfielNameOfAccount: (NSString *)account;

/*--Xóa conversation của mình với user--*/
+ (BOOL)deleteConversationOfMeWithUser: (NSString *)user;

//  Lấy tên của room chat
+ (NSString *)getRoomNameOfRoomWithRoomId: (int)roomId;

//  Get subject của room chat
+ (NSString *)getSubjectOfRoom: (NSString *)roomName;

// Get trạng thái của user
+ (int)getStatusNumberOfUserOnList: (NSString *)callnexUser;

//  Get danh sách conversation của account
+ (NSMutableArray *)getAllConversationForHistoryMessageOfUser: (NSString *)user;

//  Get 1 conversation cua user
+ (ConversationObject *)getConversationOfUser: (NSString *)user;

//  Get conversation của các group chat
+ (NSMutableArray *)getAllConversationForGroupOfUser;

//  Get tất cả các message chưa đọc của mình với 1 user
+ (int)getNumberMessageUnread: (NSString*)account andUser: (NSString*)user;
+ (ConversationObject *)getConversationForGroup: (NSString *)roomID;

//  Get tất cả các message chưa đọc của 1 room chat
+ (int)getNumberMessageUnreadOfRoom: (NSString *)roomID;
//  Get conact có cloudfone
+ (NSMutableArray *)getAllCloudFoneContactWithSearch: (NSString *)search;

//  Lưu background chat của group vào conversation
+ (BOOL)saveBackgroundChatForRoom: (NSString *)roomID withBackground: (NSString *)background;

//  Lưu background chat của user vào conversation
+ (BOOL)saveBackgroundChatForUser: (NSString *)user withBackground: (NSString *)background;

// Get danh sách ID của các message hết hạn của một group (để remove khỏi list chat)
+ (NSArray *)getAllMessageExpireEndedOfMeWithGroup: (int)groupID;

//  Lấy background đã lưu cho view chat room
+ (NSString *)getChatBackgroundForRoom: (NSString *)roomID;

//  Hàm delete tất cả message của 1 user
+ (void)deleteAllMessageOfRoomChat:(NSString *)roomID;

//  Get lịch sử message của room chat
+ (NSMutableArray *)getListMessagesOfAccount: (NSString *)account withRoomID: (NSString *)roomID;
+ (NSMutableArray *)getListMessagesOfAccount: (NSString *)account withRoomID: (NSString *)roomID withCurrentPage: (int)curPage andNumPerPage: (int)numPerPage;

//  Cập nhật các tin nhắn chưa đọc thành đã đọc cho room chat
+ (void)updateAllMessagesInRoomChat: (NSString *)roomID withAccount: (NSString *)account;

//  Hàm tạo group chat trong database
+ (BOOL)createRoomChatInDatabase: (NSString *)roomName andGroupName: (NSString *)groupName withSubject: (NSString *)subject;

//  Thêm một contact vào Blacklist
+ (BOOL)addContactToBlacklist: (int)idContact andCloudFoneID: (NSString *)cloudFoneID;

/*----Lấy tất cả user trong Callnex Blacklist----*/
+ (NSMutableArray *)getAllUserInCallnexBlacklist;

// Xoá một contact vào Blacklist
+ (BOOL)removeContactFromBlacklist: (int)idContact andCloudFoneID: (NSString *)cloudFoneID;

//  Hàm trả về contact với callnexID
+ (ContactChatObj *)getContactInfoWithCallnexID: (NSString *)callnexID;

/*--Kiem tra user co trong request table hay khong--*/
+ (BOOL)checkRequestOfUser: (NSString *)user;

+ (BOOL)checkListAcceptOfUser: (NSString *)account withSendUser: (NSString *)sendUser;

/*--save expire time cho một user--*/
+ (BOOL)saveExpireTimeForUser: (NSString *)user withExpireTime: (int)expireTime;

+ (BOOL)updateMessage: (NSString *)idMessage withImageName: (NSString *)imageName andThumbnail: (NSString *)thumbnail;

//  Xoá tất cả các user trong request list hiện tại
+ (void)removeAllUserFromRequestList;

// resend tất cả msg đã send thất bại của user
+ (void)resendAllFailedMessageOfAccount: (NSString *)account;

//  Get danh sách các room chat
+ (NSMutableArray *)getAllRoomChatOfAccount: (NSString *)account;

// Get receivePhone và nội dung của message fail
+ (NSArray *)getInfoForSendFailedMessage: (NSString *)idMessage;

+ (NSMutableArray *)getListPictureFromMessageOf: (NSString *)account withRemoteParty: (NSString *)remoteParty;
+ (NSMutableArray *)getListPictureFromMessageOf: (NSString *)account withRoomChat: (NSString *)roomName;

/*--Hàm trả về đường dẫn đến file video--*/
+ (NSURL *)getUrlOfVideoFile: (NSString *)fileName;

+ (BOOL)checkVideoHadDownloadedFromServer: (NSString *)videoName;
+ (BOOL)updateContent: (NSString *)content forMessage: (NSString *)idMessage;
+ (BOOL)setRecallForMessage: (NSString *)idMessage;
+ (NSMutableArray *)getAllMessageUnseenReceivedOfRemoteParty: (NSString *)remoteParty;
+ (void)updateAllMessageUnSeenReceivedOfRemoteParty: (NSString *)remoteParty;
+ (void)updateSeenStatusForMessage: (NSString*)idMessage;
+ (void)deleteTextAndLocationBurnMessageOfRemoteParty: (NSString *)remoteParty;
+ (void)deleteMediaBurnMessageOfRemoteParty: (NSString *)remoteParty;

/* Lấy tất cả message chưa đọc*/
+ (int)getAllMessageUnreadForUIMainBar;
+ (void)updateSeenForMessage: (NSString *)idMessage;
+ (int)getTotalMessagesOfMe: (NSString *)account withRemoteParty: (NSString *)remoteParty;
+ (int)getTotalMessagesOfMe: (NSString *)account ofRoomName: (NSString *)roomName;

// Thêm user vào request list
+ (BOOL)addUserToRequestSent: (NSString *)user withIdRequest: (NSString *)idRequeset;

// Dem so luong request ket ban
+ (int)getCountListFriendsForAcceptOfAccount: (NSString *)account;

// Get danh sach request ket ban
+ (NSMutableArray *)getListFriendsForAcceptOfAccount: (NSString *)account;

@end
