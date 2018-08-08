//
//  ContactDetailObj.h
//  linphone
//
//  Created by user on 19/11/14.
//
//

#import <Foundation/Foundation.h>

@interface ContactDetailObj : NSObject{
    NSString *_iconStr;
    NSString *_titleStr;
    NSString *_valueStr;
    NSString *_buttonStr;
    NSString *_typePhone;
}

@property (nonatomic, strong) NSString *_iconStr;
@property (nonatomic, strong) NSString *_titleStr;
@property (nonatomic, strong) NSString *_valueStr;
@property (nonatomic, strong) NSString *_buttonStr;
@property (nonatomic, strong) NSString *_typePhone;

@end
