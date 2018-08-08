//
//  UploadPicture.h
//  linphone
//
//  Created by admin on 12/9/17.
//

#import <Foundation/Foundation.h>

@interface UploadPicture : NSObject{
    void(^finishUploadBlock)(UploadPicture *uploadSession);
    void(^beginUploadBlock)(UploadPicture *uploadSession);
}

- (void)uploadData:(NSData *)data withName: (NSString *)imageName beginUploadBlock:(void(^)(UploadPicture *uploadSession))beginBlock finishUploadBlock:(void(^)(UploadPicture *uploadSession))finishBlock;

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSString *idMessage;
@property (nonatomic, strong) NSString *namePicture;

@end
