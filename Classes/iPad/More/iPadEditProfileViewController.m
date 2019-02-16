//
//  iPadEditProfileViewController.m
//  linphone
//
//  Created by admin on 2/16/19.
//

#import "iPadEditProfileViewController.h"
#import "NSData+Base64.h"
#import "PECropViewController.h"
#import "UploadPicture.h"

@interface iPadEditProfileViewController ()<PECropViewControllerDelegate>{
    NSString *accountID;
    BOOL isRemoveAvatar;
    NSString *myAvatar;
    PECropViewController *PECropController;
}

@end

@implementation iPadEditProfileViewController
@synthesize btnAvatar, tfName, btnSave, btnReset;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self autoLayoutForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [WriteLogsUtils writeForGoToScreen: @"iPadEditProfileViewController"];
    
    self.title = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Edit profile"];
    tfName.placeholder = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Account name"];
    
    accountID = [SipUtils getAccountIdOfDefaultProxyConfig];
    
    if (![AppUtils isNullOrEmpty: accountID]) {
        NSString *pbxKeyName = [NSString stringWithFormat:@"%@_%@", @"pbxName", accountID];
        NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey: pbxKeyName];
        if (name != nil){
            tfName.text = name;
        }
        
        if ([LinphoneAppDelegate sharedInstance]._dataCrop != nil) {
            [btnAvatar setImage:[UIImage imageWithData: [LinphoneAppDelegate sharedInstance]._dataCrop] forState:UIControlStateNormal];
        }else{
            NSString *pbxKeyAvatar = [NSString stringWithFormat:@"%@_%@", @"pbxAvatar", accountID];
            myAvatar = [[NSUserDefaults standardUserDefaults] objectForKey: pbxKeyAvatar];
            if (myAvatar != nil && ![myAvatar isEqualToString:@""])
            {
                [btnAvatar setImage:[UIImage imageWithData: [NSData dataFromBase64String: myAvatar]] forState:UIControlStateNormal];
            }else{
                //  Check avatar exists on server
                [self checkDataExistsOnServer];
            }
        }
    }
}

//  Tap vào màn hình chính để đóng bàn phím
- (void)whenTapOnMainScreen {
    [self.view endEditing: true];
}

- (void)autoLayoutForView {
    //  Tap vào màn hình để đóng bàn phím
    UITapGestureRecognizer *tapOnScreen = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTapOnMainScreen)];
    [self.view setUserInteractionEnabled: true];
    [self.view addGestureRecognizer: tapOnScreen];
    
    //  view header
    float padding = 40.0;
    btnAvatar.layer.borderWidth = 1.0;
    btnAvatar.layer.borderColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0)
                                                   blue:(220/255.0) alpha:1.0].CGColor;
    [btnAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.view).offset(padding);
        make.right.equalTo(self.view).offset(-padding);
        make.height.mas_equalTo(SCREEN_WIDTH - SPLIT_MASTER_WIDTH - 2*padding);
    }];
    
    tfName.borderStyle = UITextBorderStyleNone;
    tfName.layer.cornerRadius = 3.0;
    tfName.layer.borderWidth = 1.0;
    tfName.layer.borderColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                                blue:(230/255.0) alpha:1.0].CGColor;
    tfName.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightThin];
    [tfName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnAvatar.mas_bottom).offset(40.0);
        make.left.equalTo(self.view).offset(30.0);
        make.right.equalTo(self.view).offset(-30.0);
        make.height.mas_equalTo(40.0);
    }];
    tfName.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8.0, 40.0)];
    tfName.leftViewMode = UITextFieldViewModeAlways;
    
    //  cancel button
    btnReset.titleLabel.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightRegular];
    [btnReset setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Cancel"] forState:UIControlStateNormal];
    btnReset.backgroundColor = [UIColor colorWithRed:(250/255.0) green:(80/255.0)
                                                blue:(80/255.0) alpha:1.0];
    [btnReset setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnReset.clipsToBounds = YES;
    btnReset.layer.cornerRadius = 40.0/2;
    
    [btnReset mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tfName.mas_bottom).offset(30);
        make.right.equalTo(tfName.mas_centerX).offset(-10);
        make.left.equalTo(tfName.mas_left);
        make.height.mas_equalTo(40.0);
    }];
    
    btnSave.titleLabel.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightRegular];
    [btnSave setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Save"]
             forState:UIControlStateNormal];
    btnSave.backgroundColor = IPAD_HEADER_BG_COLOR;
    [btnSave setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnSave.clipsToBounds = YES;
    btnSave.layer.cornerRadius = 40.0/2;
    [btnSave mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(tfName.mas_centerX).offset(10);
        make.centerY.equalTo(btnReset.mas_centerY);
        make.right.equalTo(tfName.mas_right);
        make.height.equalTo(btnReset.mas_height);
    }];
}

- (IBAction)btnSavePress:(UIButton *)sender {
    [self.view endEditing: YES];
    
    if ([LinphoneManager instance].connectivity == none){
        [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Please check your internet connection!"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    NSString *pbxServer = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_SERVER];
    if (![AppUtils isNullOrEmpty: accountID] && ![AppUtils isNullOrEmpty: pbxServer]) {
        if ([LinphoneAppDelegate sharedInstance]._dataCrop != nil) {
            [[LinphoneAppDelegate sharedInstance] showWaiting: YES];
            
            isRemoveAvatar = NO;
            
            NSString *avatarName = [NSString stringWithFormat:@"%@_%@.png", pbxServer, accountID];
            [self startUploadImage:[LinphoneAppDelegate sharedInstance]._dataCrop withName: avatarName];
        }else if ([myAvatar isEqualToString:@""]){
            isRemoveAvatar = YES;
            
            NSString *avatarName = [NSString stringWithFormat:@"%@_%@.png", pbxServer, accountID];
            UIImage *noneImage = [UIImage imageNamed:@"no_avatar.png"];
            [self startUploadImage:UIImagePNGRepresentation(noneImage) withName: avatarName];
        }
    }
}

- (IBAction)btnResetPress:(UIButton *)sender {
}

- (IBAction)btnAvatarPress:(UIButton *)sender {
    [self.view endEditing: YES];
    
    LinphoneAppDelegate *appDelegate = [LinphoneAppDelegate sharedInstance];
    
    if (myAvatar != nil && ![myAvatar isEqualToString:@""]) {
        UIActionSheet *popupAvatar = [[UIActionSheet alloc] initWithTitle:[appDelegate.localization localizedStringForKey:@"Options"] delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:@"Cancel"] destructiveButtonTitle:nil otherButtonTitles:
                                          [appDelegate.localization localizedStringForKey:@"Gallery"],
                                          [appDelegate.localization localizedStringForKey:@"Camera"],
                                          [appDelegate.localization localizedStringForKey:@"Remove Avatar"],
                                          nil];
        popupAvatar.tag = 100;
        [popupAvatar showFromRect:btnAvatar.bounds inView:btnAvatar animated:YES];
    }else{
        UIActionSheet *popupAvatar = [[UIActionSheet alloc] initWithTitle:[appDelegate.localization localizedStringForKey:@"Options"] delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:@"Cancel"] destructiveButtonTitle:nil otherButtonTitles:
                                          [appDelegate.localization localizedStringForKey:@"Gallery"],
                                          [appDelegate.localization localizedStringForKey:@"Camera"],
                                          nil];
        popupAvatar.tag = 101;
        [popupAvatar showFromRect:btnAvatar.bounds inView:btnAvatar animated:YES];
    }
}

- (void)startUploadImage: (NSData *)uploadData withName: (NSString *)imageName
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        UploadPicture *session = [[UploadPicture alloc] init];
        [session uploadData:uploadData withName:imageName beginUploadBlock:nil finishUploadBlock:^(UploadPicture *uploadSession) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[LinphoneAppDelegate sharedInstance] showWaiting: NO];
                
                if (uploadSession.uploadError != nil) {
                    [self.view makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Failed. Please try later!"] duration:2.0 position:CSToastPositionCenter];
                }else{
                    if (isRemoveAvatar) {
                        [[LinphoneAppDelegate sharedInstance].window makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Your avatar has been removed"] duration:2.0 position:CSToastPositionCenter];
                    }else{
                        [[LinphoneAppDelegate sharedInstance].window makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:@"Your avatar has been uploaded"] duration:2.0 position:CSToastPositionCenter];
                    }
                    
                    //  save avatar to get from local
                    NSString *pbxKeyAvatar = [NSString stringWithFormat:@"%@_%@", @"pbxAvatar", accountID];
                    
                    NSString *strAvatar = @"";
                    if ([uploadData respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
                        strAvatar = [uploadData base64EncodedStringWithOptions: 0];
                    } else {
                        strAvatar = [uploadData base64Encoding];
                    }
                    
                    [[NSUserDefaults standardUserDefaults] setObject:strAvatar forKey:pbxKeyAvatar];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
                if (tfName.text.length > 0) {
                    NSString *pbxKeyName = [NSString stringWithFormat:@"%@_%@", @"pbxName", accountID];
                    [[NSUserDefaults standardUserDefaults] setObject: tfName.text forKey:pbxKeyName];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            });
        }];
    });
}

- (void)checkDataExistsOnServer {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *pbxServer = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_SERVER];
        NSData * data = nil;
        if (![AppUtils isNullOrEmpty: accountID] && ![AppUtils isNullOrEmpty: pbxServer]) {
            NSString *avatarName = [NSString stringWithFormat:@"%@_%@.png", pbxServer, accountID];
            
            NSString *linkAvatar = [NSString stringWithFormat:@"%@/%@", link_picture_chat_group, avatarName];
            data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: linkAvatar]];
            NSString *strAvatar = @"";
            if (data != nil) {
                if ([data respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
                    strAvatar = [data base64EncodedStringWithOptions: 0];
                } else {
                    strAvatar = [data base64Encoding];
                }
            }
            
            NSString *pbxKeyAvatar = [NSString stringWithFormat:@"%@_%@", @"pbxAvatar", accountID];
            [[NSUserDefaults standardUserDefaults] setObject:strAvatar forKey:pbxKeyAvatar];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (data == nil) {
                [btnAvatar setImage:[UIImage imageNamed:@"man_user"] forState:UIControlStateNormal];
            }else{
                [btnAvatar setImage:[UIImage imageWithData: data] forState:UIControlStateNormal];
            }
        });
    });
}

#pragma mark - ActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 101) {
        switch (buttonIndex) {
            case 0:{
                [self pressOnGallery];
                break;
            }
            case 1:{
                [self pressOnCamera];
                break;
            }
            case 2:{
                NSLog(@"Cancel");
                break;
            }
        }
    }else if (actionSheet.tag == 100){
        switch (buttonIndex) {
            case 0:{
                [self pressOnGallery];
                break;
            }
            case 1:{
                [self pressOnCamera];
                break;
            }
            case 2:{
                [self removeAvatar];
                break;
            }
            case 3:{
                NSLog(@"Cancel");
                break;
            }
        }
    }
}

- (void)pressOnGallery {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [LinphoneAppDelegate sharedInstance].fromImagePicker = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
            pickerController.delegate = self;
            [self presentViewController:pickerController animated:YES completion:nil];
        });
    });
}

- (void)pressOnCamera {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [LinphoneAppDelegate sharedInstance].fromImagePicker = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            [picker setDelegate: self];
            [picker setSourceType: UIImagePickerControllerSourceTypeCamera];
            [self presentViewController:picker animated:YES completion:NULL];
        });
    });
}

- (void)removeAvatar {
    if ([LinphoneAppDelegate sharedInstance]._dataCrop != nil) {
        [LinphoneAppDelegate sharedInstance]._dataCrop = nil;
        if ([AppUtils isNullOrEmpty: myAvatar]) {
            [btnAvatar setImage:[UIImage imageNamed:@"man_user"] forState:UIControlStateNormal];
        }else{
            [btnAvatar setImage:[UIImage imageWithData: [NSData dataFromBase64String: myAvatar]] forState:UIControlStateNormal];
        }
    }else if (myAvatar != nil && ![myAvatar isEqualToString:@""]){
        myAvatar = @"";
        [btnAvatar setImage:[UIImage imageNamed:@"man_user"] forState:UIControlStateNormal];
    }
}

#pragma mark - PECropViewControllerDelegate methods

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage transform:(CGAffineTransform)transform cropRect:(CGRect)cropRect
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    [LinphoneAppDelegate sharedInstance]._dataCrop = UIImagePNGRepresentation(croppedImage);
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - ContactDetailsImagePickerDelegate Functions

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = newBackButton;
    
    [LinphoneAppDelegate sharedInstance]._cropAvatar = image;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self openEditor];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)openEditor {
    PECropController = [[PECropViewController alloc] init];
    PECropController.delegate = self;
    PECropController.image = [LinphoneAppDelegate sharedInstance]._cropAvatar;
    
    UIImage *image = [LinphoneAppDelegate sharedInstance]._cropAvatar;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat length = MIN(width, height);
    PECropController.imageCropRect = CGRectMake((width - length) / 2, (height - length) / 2, length, length);
    PECropController.keepingCropAspectRatio = true;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController: PECropController];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [self.navigationController pushViewController:PECropController animated:YES];
}


@end
