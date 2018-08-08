//
//  OTRShareSetting.m
//  Off the Record
//
//  Created by David on 11/10/12.
//  Copyright (c) 2012 Chris Ballinger. All rights reserved.
//

#import "OTRShareSetting.h"
#import "strings.h"

#define ACTIONSHEET_SHARE_TAG 2
#define ACTIONSHEET_LINK_TAG 1

@implementation OTRShareSetting

@synthesize delegate;
@synthesize lastActionLink;



-(id)initWithTitle:(NSString *)newTitle description:(NSString *)newDescription
{
    self = [super initWithTitle:newTitle description:newDescription];
    if (self) {
        self.action = @selector(showActionSheet);
    }
    return self;
}

-(void)showActionSheet
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:SHARE_STRING delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    NSArray *buttonTitles = [self buttonTitlesForShareButton];
    for (NSString *title in buttonTitles) {
        [sheet addButtonWithTitle:title];
    }
    sheet.tag = ACTIONSHEET_SHARE_TAG;
    sheet.cancelButtonIndex = [buttonTitles count] - 1;
}

- (NSArray*) buttonTitlesForShareButton {
    NSMutableArray *titleArray = [NSMutableArray arrayWithCapacity:4];
    [titleArray addObject:@"SMS"];
    [titleArray addObject:@"E-mail"];
    [titleArray addObject:@"QR Code"];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
    {
        [titleArray addObject:@"Twitter"];
    }
    [titleArray addObject:CANCEL_STRING];
    return titleArray;
}

- (NSString*) shareString {
    return [NSString stringWithFormat:@"%@: http://get.chatsecure.org", SHARE_MESSAGE_STRING];
}

- (NSString*) twitterShareString {
    return [NSString stringWithFormat:@"%@ @ChatSecure", [self shareString]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (actionSheet.tag == ACTIONSHEET_SHARE_TAG) {
        if (buttonIndex == 0) // SMS
        {
            if (![MFMessageComposeViewController canSendText]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_STRING message:[NSString stringWithFormat:@"SMS %@", NOT_AVAILABLE_STRING] delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil];
                [alert show];
            } else {
                MFMessageComposeViewController *sms = [[MFMessageComposeViewController alloc] init];
                sms.messageComposeDelegate = self;
                sms.body = [self shareString];
                sms.modalPresentationStyle = UIModalPresentationFormSheet;
                [delegate presentModalViewController:sms animated:YES];
            }
        }
        else if (buttonIndex == 1) // Email
        {
            if (![MFMailComposeViewController canSendMail])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_STRING message:[NSString stringWithFormat:@"E-mail %@", NOT_AVAILABLE_STRING] delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                MFMailComposeViewController *email = [[MFMailComposeViewController alloc] init];
                email.mailComposeDelegate = self;
                [email setSubject:@"ChatSecure"];
                [email setMessageBody:[self shareString] isHTML:NO];
                email.modalPresentationStyle = UIModalPresentationFormSheet;
                
                [delegate presentModalViewController:email animated:YES];
            }
        }
        else if (buttonIndex == 2) // QR code
        {
        } else if (buttonIndex == [[self buttonTitlesForShareButton] count] - 2 && [[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
        {
//            TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
//            [tweetSheet setInitialText:[self twitterShareString]];
//            [delegate presentModalViewController:tweetSheet animated:YES];
        }
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.absoluteString isEqualToString:@"file:///"]) {
        return YES;
    }
    if ([[UIApplication sharedApplication] canOpenURL:request.URL])
    {
        
    }
    return NO;
}

#pragma mark MFMessageComposeViewControllerDelegate methods

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [delegate dismissModalViewControllerAnimated:YES];
}

#pragma mark MFMailComposeViewControllerDelegate Methods

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [delegate dismissModalViewControllerAnimated:YES];
}

@end
