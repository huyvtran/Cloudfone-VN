//
//  PhoneObject.h
//  linphone
//
//  Created by Ei Captain on 3/18/17.
//
//

#import <Foundation/Foundation.h>

@interface PhoneObject : NSObject

@property (nonatomic, strong) NSString *_phoneType;
@property (nonatomic, strong) NSString *_phoneNumber;
@property (nonatomic, assign) BOOL _isNew;

@end
