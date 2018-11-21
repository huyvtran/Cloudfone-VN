//
//  WebServiceUtils.h
//  linphone
//
//  Created by lam quang quan on 11/21/18.
//

#import <UIKit/UIKit.h>
#import "WebServices.h"

@interface WebServiceUtils : UIView<WebServicesDelegate>

+(WebServiceUtils *) sharedInstance;
@property (nonatomic, strong) WebServices *webService;

@end
