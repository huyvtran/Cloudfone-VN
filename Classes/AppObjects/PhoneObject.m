//
//  PhoneObject.m
//  linphone
//
//  Created by Ei Captain on 3/18/17.
//
//

#import "PhoneObject.h"

@implementation PhoneObject

@synthesize number, name, nameForSearch, avatar, contactId, phoneType;

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.number forKey:@"number"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.nameForSearch forKey:@"nameForSearch"];
    [encoder encodeObject:self.avatar forKey:@"avatar"];
    [encoder encodeInteger:self.contactId forKey:@"contactId"];
    [encoder encodeInteger:self.phoneType forKey:@"phoneType"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if((self = [super init])) {
        self.number = [decoder decodeObjectForKey:@"number"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.nameForSearch = [decoder decodeObjectForKey:@"nameForSearch"];
        self.avatar = [decoder decodeObjectForKey:@"avatar"];
        self.contactId = [decoder decodeIntegerForKey:@"contactId"];
        self.phoneType = (int)[decoder decodeIntegerForKey:@"phoneType"];
    }
    return self;
}

@end
