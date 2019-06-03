//
//  TestViewController.m
//  linphone
//
//  Created by lam quang quan on 1/17/19.
//

#import "TestViewController.h"
#import "DialerView.h"
#import "AESCrypt.h"

@interface TestViewController () {
}

@end

@implementation TestViewController

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
    if (compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:StatusBarView.class
                                                                 tabBar:TabBarView.class
                                                               sideMenu:SideMenuView.class
                                                             fullscreen:false
                                                         isLeftFragment:YES
                                                           fragmentWith:nil];
        compositeDescription.darkBackground = true;
    }
    return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
    return self.class.compositeViewDescription;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *crashFile = [[NSUserDefaults standardUserDefaults] objectForKey:@"crash_file"];
    NSString *crashContent = [[NSUserDefaults standardUserDefaults] objectForKey:@"crash_content"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    
    NSString *emailTitle =  @"Ứng dụng của bạn đã bị crash trước đây";
    NSString *messageBody = [NSString stringWithFormat:@"Xin vui lòng gửi thông tin cho chúng tôi để cải thiện sản phầm tốt hơn.\nXin chân thành cảm ơn.\n\n%@", crashContent];
    NSArray *toRecipents = @[@"lekhai0212@gmail.com"];
    NSArray *ccRecipents = @[@"cfreport@cloudfone.vn"];
    
    //  get content file
    NSString *path = [NgnFileUtils getPathOfFileWithSubDir:[NSString stringWithFormat:@"%@/%@", logsFolderName, crashFile]];
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    NSString *encryptStr = [AESCrypt encrypt:content password:AES_KEY];
    NSData *logFileData = [encryptStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *nameForSend = [DeviceUtils convertLogFileName: crashFile];
    [mc addAttachmentData:logFileData mimeType:@"text/plain" fileName:nameForSend];
    
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    [mc setCcRecipients: ccRecipents];
    
    [self presentViewController:mc animated:YES completion:NULL];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"crash_file"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"crash_content"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [[PhoneMainView instance] changeCurrentView:[DialerView compositeViewDescription]];
    [controller dismissViewControllerAnimated:TRUE
                                   completion:^{
                                       
                                   }];
}

@end
