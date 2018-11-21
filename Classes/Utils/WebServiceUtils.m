//
//  WebServiceUtils.m
//  linphone
//
//  Created by lam quang quan on 11/21/18.
//

#import "WebServiceUtils.h"

@implementation WebServiceUtils
@synthesize webService;

+(WebServiceUtils *) sharedInstance{
    static WebServiceUtils* sInstance = nil;
    
    if(sInstance == nil){
        sInstance = [[WebServiceUtils alloc] init];
        sInstance.webService = [[WebServices alloc] init];
    }
    return sInstance;
}

#pragma mark - Web service delegate
-(void)failedToCallWebService:(NSString *)link andError:(NSString *)error {
    
}

-(void)successfulToCallWebService:(NSString *)link withData:(NSDictionary *)data {
    
}

-(void)receivedResponeCode:(NSString *)link withCode:(int)responeCode {
    
}

@end
