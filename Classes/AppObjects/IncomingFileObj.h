//
//  IncomingFileObj.h
//  linphone
//
//  Created by mac book on 28/5/15.
//
//

#import <Foundation/Foundation.h>
#import "XMPPJID.h"
#import "XMPPIncomingFileTransfer.h"

@interface IncomingFileObj : NSObject{
    XMPPIFTState _transferState;
    
    XMPPJID *_senderJID;
    
    NSString *_streamhostsQueryId;
    NSString *_streamhostUsed;
    
    NSMutableData *_receivedData;
    NSString *_receivedFileName;
    NSUInteger _totalDataSize;
    NSUInteger _receivedDataSize;
    NSString *_idMessage;
}

@property (nonatomic, assign) XMPPIFTState _transferState;
@property (nonatomic, strong) XMPPJID *_senderJID;
@property (nonatomic, strong) NSString *_streamhostsQueryId;
@property (nonatomic, strong) NSString *_streamhostUsed;

@property (nonatomic, strong) NSMutableData *_receivedData;
@property (nonatomic, strong) NSString *_receivedFileName;
@property (nonatomic, assign) NSUInteger _totalDataSize;
@property (nonatomic, assign) NSUInteger _receivedDataSize;
@property (nonatomic, strong) NSString *_idMessage;


@end
