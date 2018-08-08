//
//  ConfirmView.m
//  linphone
//
//  Created by Ei Captain on 3/16/17.
//
//

#import "ConfirmView.h"
#import "JSONKit.h"
#import "WebServices.h"
#import <CommonCrypto/CommonDigest.h>

@interface ConfirmView ()<WebServicesDelegate>{
    float hView;
    float hTextfield;
    float marginY;
    
    UIFont *textFont;
    WebServices *webService;
}
@end

@implementation NSString (MD5)
- (NSString *)MD5String {
    const char *cstr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, (int)strlen(cstr), result);
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}
@end

@implementation ConfirmView
@synthesize _scrollView, _imgLogo, _lbContent, _tfConfirm, _btnConfirm, _btnNotReceive, waitingHud;

- (void)setupUIForView
{
    webService = [[WebServices alloc] init];
    webService.delegate = self;
    
    //  Add waiting view
    waitingHud = [[YBHud alloc] initWithHudType:DGActivityIndicatorAnimationTypeLineScale andText:@""];
    //  hud.tintColor = [UIColor colorWithRed:(24/255.0) green:(185/255.0) blue:(153/255.0) alpha:1.0];
    waitingHud.tintColor = [UIColor whiteColor];
    waitingHud.dimAmount = 0.5;
    
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:HelveticaNeue size:18.0];
    }else{
        textFont = [UIFont fontWithName:HelveticaNeue size:16.0];
    }
    
    hView = self.frame.size.height;
    hTextfield = 40.0;
    marginY = 20.0;
    
    UITapGestureRecognizer *tapOnScreen = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTapOnScreen)];
    [self setUserInteractionEnabled: true];
    [self addGestureRecognizer: tapOnScreen];
    
    _scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    
    float logoWidth = SCREEN_WIDTH/3+30;
    _imgLogo.frame = CGRectMake((self.frame.size.width-logoWidth)/2, 0, logoWidth, logoWidth);
    
    float tmpWidth = (_scrollView.frame.size.width/8);
    
    //  confirm code
    _lbContent.frame = CGRectMake(tmpWidth, _imgLogo.frame.origin.y+_imgLogo.frame.size.height+marginY, SCREEN_WIDTH-2*tmpWidth, 2*hTextfield);
    _lbContent.textAlignment = NSTextAlignmentCenter;
    _lbContent.font = textFont;
    
    NSString *content = [NSString stringWithFormat:@"%@\r%@", [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_confirm_content1], [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_confirm_content2]];
    _lbContent.text = content;
    
    _tfConfirm.frame = CGRectMake(_lbContent.frame.origin.x, _lbContent.frame.origin.y+_lbContent.frame.size.height+marginY, _lbContent.frame.size.width, hTextfield);
    _tfConfirm.font = textFont;
    _tfConfirm.borderStyle = UITextBorderStyleNone;
    _tfConfirm.layer.borderColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                    blue:(200/255.0) alpha:1.0].CGColor;
    _tfConfirm.layer.borderWidth = 1.0;
    _tfConfirm.layer.cornerRadius = 0.0;
    _tfConfirm.placeholder = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_enter_confirmation];
    _tfConfirm.keyboardType = UIKeyboardTypeNumberPad;
    
    UIView *pConfirm = [[UIView alloc] initWithFrame: CGRectMake(0, 0, hTextfield/2, hTextfield)];
    pConfirm.backgroundColor = UIColor.clearColor;
    _tfConfirm.leftView = pConfirm;
    _tfConfirm.leftViewMode = UITextFieldViewModeAlways;
    
    //  button confirm
    _btnConfirm.frame = CGRectMake(_tfConfirm.frame.origin.x, _tfConfirm.frame.origin.y+_tfConfirm.frame.size.height+marginY, _tfConfirm.frame.size.width, hTextfield+10);
    [_btnConfirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _btnConfirm.layer.cornerRadius = (hTextfield+10)/2;
    
    if (SCREEN_WIDTH > 320) {
        _btnConfirm.titleLabel.font = [UIFont fontWithName:HelveticaNeue size:20.0];
    }else{
        _btnConfirm.titleLabel.font = [UIFont fontWithName:HelveticaNeue size:18.0];
    }
    _btnConfirm.backgroundColor = [UIColor colorWithRed:(0/255.0) green:(188/255.0)
                                                   blue:(157/255.0) alpha:1.0];
    _btnConfirm.layer.borderWidth = 1.0;
    _btnConfirm.layer.borderColor = [UIColor colorWithRed:(0/255.0) green:(188/255.0)
                                                     blue:(157/255.0) alpha:1.0].CGColor;
    [_btnConfirm setTitle:[[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_confirm] capitalizedString]
                  forState:UIControlStateNormal];
    [_btnConfirm addTarget:self
                     action:@selector(btnConfirmTouchDown:)
           forControlEvents:UIControlEventTouchDown];
    
    _btnNotReceive.frame = CGRectMake(_btnConfirm.frame.origin.x, _btnConfirm.frame.origin.y+_btnConfirm.frame.size.height+2*marginY, _btnConfirm.frame.size.width, hTextfield);
    _btnNotReceive.titleLabel.font = textFont;
    
    _scrollView.contentSize = CGSizeMake(0, _btnNotReceive.frame.origin.y+_btnNotReceive.frame.size.height+marginY);
}

//  Tap trên màn hình để close keyboard
- (void)whenTapOnScreen {
    [self endEditing: true];
}

- (void)btnConfirmTouchDown: (UIButton *)sender {
    sender.backgroundColor = UIColor.clearColor;
    [sender setTitleColor:[UIColor colorWithRed:(0/255.0) green:(188/255.0)
                                           blue:(157/255.0) alpha:1.0]
                 forState:UIControlStateNormal];
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self
                                   selector:@selector(btnConfirmPressed)
                                   userInfo:nil repeats:false];
}

- (void)btnConfirmPressed {
    [self endEditing: YES];
    
    _btnConfirm.backgroundColor = [UIColor colorWithRed:(0/255.0) green:(188/255.0)
                                                   blue:(157/255.0) alpha:1.0];
    [_btnConfirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    if ([_tfConfirm.text isEqualToString: @""]) {
        [self makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_confirmcode_empty]
               duration:2.0 position:CSToastPositionCenter];
    }else{
        NSString *hashString = [[NSUserDefaults standardUserDefaults] objectForKey:hash_register];
        NSString *randomKey = [[NSUserDefaults standardUserDefaults] objectForKey:random_key_register];
        if (hashString != nil && randomKey != nil) {
            [waitingHud showInView:self animated:YES];
            
            NSString *string = [NSString stringWithFormat:@"%@%@", randomKey, _tfConfirm.text];
            NSString *md5String = [[string MD5String] lowercaseString];
            [self confirmRequestWithHashString:hashString andMd5String:md5String];
        }else{
            [self makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_default_error]
                   duration:2.0 position:CSToastPositionCenter];
            [NSTimer scheduledTimerWithTimeInterval:2.0 target:self
                                           selector:@selector(whenCannotGetHashStringFromStep1)
                                           userInfo:nil repeats:false];
        }
    }
}

- (IBAction)_btnConfirmPressed:(UIButton *)sender {
    
}

//
- (void)whenCannotGetHashStringFromStep1 {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:time_register_expire];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:hash_register];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [waitingHud dismissAnimated: YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:cannotGetHashString object:nil];
}

#pragma mark - API

- (void)confirmRequestWithHashString: (NSString *)hashString andMd5String: (NSString *)MD5String
{
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:AuthUser forKey:@"AuthUser"];
    [jsonDict setObject:AuthKey forKey:@"AuthKey"];
    [jsonDict setObject:hashString forKey:@"HashString"];
    [jsonDict setObject:MD5String forKey:@"MD5String"];
    
    [webService callWebServiceWithLink:confirmRequestFunc withParams:jsonDict];
}

#pragma mark - Web service delegate

- (void)receivedResponeCode:(NSString *)link withCode:(int)responeCode {
    
}

- (void)successfulToCallWebService:(NSString *)link withData:(NSDictionary *)data {
    [waitingHud dismissAnimated: YES];
    
    if ([link isEqualToString: confirmRequestFunc]) {
        NSString *login = [data objectForKey:@"loginUser"];
        NSString *password = [data objectForKey:@"password"];
        NSString *ip = [data objectForKey:@"ip"];
        NSString *port = [data objectForKey:@"port"];
        
        if (![login isKindOfClass:[NSNull class]] && login != nil && ![password isKindOfClass:[NSNull class]] && password != nil && ![ip isKindOfClass:[NSNull class]] && ip != nil && ![port isKindOfClass:[NSNull class]] && port != nil)
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:time_register_expire];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:random_key_register];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:hash_register];
            
            [[NSUserDefaults standardUserDefaults] setObject:login forKey:key_login];
            [[NSUserDefaults standardUserDefaults] setObject:password forKey:key_password];
            [[NSUserDefaults standardUserDefaults] setObject:ip forKey:key_ip];
            [[NSUserDefaults standardUserDefaults] setObject:port forKey:key_port];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:registerAccountSuccess
                                                                object:nil];
        }
    }
}

-(void)failedToCallWebService:(NSString *)link andError:(NSString *)error {
    [waitingHud dismissAnimated: YES];
    if ([link isEqualToString: confirmRequestFunc]) {
        [self makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:error]
               duration:1.5 position:CSToastPositionCenter];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:registerAccountSuccess
                                                            object:nil];
    }
}

@end
