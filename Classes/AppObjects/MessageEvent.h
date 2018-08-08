//
//  MessageEvent.h
//  linphone
//
//  Created by admin on 1/4/18.
//

#import <Foundation/Foundation.h>

@interface MessageEvent : NSObject

@property (nonatomic, strong) NSString *idMessage;
@property (nonatomic, strong) NSString *sendPhone;
@property (nonatomic, strong) NSString *receivePhone;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, assign) int deliveredStatus;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *detailsUrl;
@property (nonatomic, strong) NSString *thumbUrl;
@property (nonatomic, strong) NSString *typeMessage;
@property (nonatomic, assign) double time;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *isRecall;
@property (nonatomic, strong) NSString *dateTime;
@property (nonatomic, strong) NSMutableAttributedString *contentAttrString;
@property (nonatomic, assign) BOOL isBurn;
@property (nonatomic, strong) NSString *sendPhoneName;
@property (nonatomic, strong) NSString *roomID;

//  "delivered_status" INTEGER,"is_recall" VARCHAR,"details_url" VARCHAR DEFAULT (null) ,"" VARCHAR DEFAULT (null) ,"" VARCHAR,"" INTEGER DEFAULT (null) ,"expire_time" INTEGER,"room_id" VARCHAR,"extra" VARCHAR,"" VARCHAR,"last_time_expire" INTEGER DEFAULT (0) )

@end
