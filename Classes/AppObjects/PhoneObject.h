//
//  PhoneObject.h
//  linphone
//
//  Created by Ei Captain on 3/18/17.
//
//

#import <Foundation/Foundation.h>

@interface PhoneObject : NSObject

@property (nonatomic, strong) NSString *number;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *nameForSearch;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, assign) long contactId;
@property (nonatomic, assign) int phoneType;

@end
