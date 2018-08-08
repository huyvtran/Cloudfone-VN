//
//  CallHistoryObject.h
//  linphone
//
//  Created by user on 29/11/14.
//
//

#import <Foundation/Foundation.h>

@interface CallHistoryObject : NSObject{
    NSString *_time;
    NSString *_status;
    int _duration;
    float _rate;
    NSString *_date;
}

@property (nonatomic, strong) NSString *_time;
@property (nonatomic, strong) NSString *_status;
@property (nonatomic, assign) int _duration;
@property (nonatomic, assign) float _rate;
@property (nonatomic, strong) NSString *_date;

@end
