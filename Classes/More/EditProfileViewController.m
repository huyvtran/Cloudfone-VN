//
//  EditProfileViewController.m
//  linphone
//
//  Created by lam quang quan on 10/17/18.
//

#import "EditProfileViewController.h"
#import "NSData+Base64.h"
#import "PECropViewController.h"
#import "UploadPicture.h"

@interface EditProfileViewController ()<PECropViewControllerDelegate>{
    LinphoneAppDelegate *appDelegate;
    NSString *myAvatar;
    PECropViewController *PECropController;
    BOOL isRemoveAvatar;
    
    NSString *accountID;
}

@end

@implementation EditProfileViewController
@synthesize viewHeader, bgHeader, icBack, lbHeader, btnChooseAvatar, imgAvatar, imgChangeAvatar, tfAccountName, btnCancel, btnSave, icWaiting;

#pragma mark - UICompositeViewDelegate Functions
static UICompositeViewDescription *compositeDescription = nil;
+ (UICompositeViewDescription *)compositeViewDescription {
    if (compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:nil
                                                                 tabBar:nil
                                                               sideMenu:nil
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
    appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self autoLayoutForView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    NSString *className = NSStringFromClass([[PhoneMainView instance].currentView class]);
    [WriteLogsUtils writeLogContent:[NSString stringWithFormat:@"\n\n----->Go to %@", className] toFilePath:appDelegate.logFilePath];
    
    accountID = [SipUtils getAccountIdOfDefaultProxyConfig];
    
    lbHeader.text = [appDelegate.localization localizedStringForKey:@"Edit profile"];
    tfAccountName.placeholder = [appDelegate.localization localizedStringForKey:@"Account name"];
    
    if (![AppUtils isNullOrEmpty: accountID]) {
        NSString *pbxKeyName = [NSString stringWithFormat:@"%@_%@", @"pbxName", accountID];
        NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey: pbxKeyName];
        if (name != nil){
            tfAccountName.text = name;
        }
        
        if (appDelegate._dataCrop != nil) {
            imgAvatar.image = [UIImage imageWithData: appDelegate._dataCrop];
        }else{
            NSString *pbxKeyAvatar = [NSString stringWithFormat:@"%@_%@", @"pbxAvatar", accountID];
            myAvatar = [[NSUserDefaults standardUserDefaults] objectForKey: pbxKeyAvatar];
            if (myAvatar != nil && ![myAvatar isEqualToString:@""])
            {
                imgAvatar.image = [UIImage imageWithData: [NSData dataFromBase64String: myAvatar]];
            }else{
                //  Check avatar exists on server
                [self checkDataExistsOnServer];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)icBackClick:(UIButton *)sender {
    appDelegate._dataCrop = nil;
    [[PhoneMainView instance] popCurrentView];
}

- (IBAction)btnChooseAvatarPress:(UIButton *)sender {
    [self.view endEditing: YES];
    
    if (myAvatar != nil && ![myAvatar isEqualToString:@""]) {
        UIActionSheet *popupAddContact = [[UIActionSheet alloc] initWithTitle:[appDelegate.localization localizedStringForKey:@"Options"] delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:@"Cancel"] destructiveButtonTitle:nil otherButtonTitles:
                                          [appDelegate.localization localizedStringForKey:@"Gallery"],
                                          [appDelegate.localization localizedStringForKey:@"Camera"],
                                          [appDelegate.localization localizedStringForKey:@"Remove Avatar"],
                                          nil];
        popupAddContact.tag = 100;
        [popupAddContact showInView:self.view];
    }else{
        UIActionSheet *popupAddContact = [[UIActionSheet alloc] initWithTitle:[appDelegate.localization localizedStringForKey:@"Options"] delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:@"Cancel"] destructiveButtonTitle:nil otherButtonTitles:
                                          [appDelegate.localization localizedStringForKey:@"Gallery"],
                                          [appDelegate.localization localizedStringForKey:@"Camera"],
                                          nil];
        popupAddContact.tag = 101;
        [popupAddContact showInView:self.view];
    }
}

- (IBAction)btnCancelPress:(UIButton *)sender {
}

- (IBAction)btnSavePress:(UIButton *)sender
{
    [self.view endEditing: YES];
    
    if ([LinphoneManager instance].connectivity == none){
        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Please check your internet connection!"] duration:2.0 position:CSToastPositionCenter];
        return;
    }
    
    NSString *pbxServer = [[NSUserDefaults standardUserDefaults] objectForKey:PBX_SERVER];
    if (![AppUtils isNullOrEmpty: accountID] && ![AppUtils isNullOrEmpty: pbxServer]) {
        if (appDelegate._dataCrop != nil) {
            icWaiting.hidden = NO;
            [icWaiting startAnimating];
            isRemoveAvatar = NO;
            
            NSString *avatarName = [NSString stringWithFormat:@"%@_%@.png", pbxServer, accountID];
            [self startUploadImage:appDelegate._dataCrop withName: avatarName];
        }else if ([myAvatar isEqualToString:@""]){
            isRemoveAvatar = YES;
            
            NSString *avatarName = [NSString stringWithFormat:@"%@_%@.png", pbxServer, accountID];
            UIImage *noneImage = [UIImage imageNamed:@"no_avatar.png"];
            [self startUploadImage:UIImagePNGRepresentation(noneImage) withName: avatarName];
        }
    }
}

- (void)autoLayoutForView {
    //  Tap vào màn hình để đóng bàn phím
    float wAvatar = 110.0;
    
    if (SCREEN_WIDTH > 320) {
        lbHeader.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:20.0];
    }else{
        lbHeader.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }
    
    UITapGestureRecognizer *tapOnScreen = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTapOnMainScreen)];
    [self.view setUserInteractionEnabled: true];
    [self.view addGestureRecognizer: tapOnScreen];
    
    //  view header
    [viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(appDelegate._hRegistrationState + 60.0);
    }];
    
    [bgHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(viewHeader);
    }];
    
    [lbHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader).offset(appDelegate._hStatus);
        make.centerX.equalTo(viewHeader.mas_centerX);
        make.width.mas_equalTo(200.0);
        make.height.mas_equalTo(44.0);
    }];
    
    [icBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewHeader);
        make.centerY.equalTo(lbHeader.mas_centerY);
        make.width.height.mas_equalTo(HEADER_ICON_WIDTH);
    }];
    
    imgAvatar.layer.borderColor = UIColor.whiteColor.CGColor;
    imgAvatar.layer.borderWidth = 2.0;
    imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
    imgAvatar.layer.cornerRadius = wAvatar/2;
    imgAvatar.clipsToBounds = YES;
    [imgAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(viewHeader.mas_bottom);
        make.width.height.mas_equalTo(wAvatar);
    }];
    
    [btnChooseAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(imgAvatar);
    }];
    
    [imgChangeAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(imgAvatar.mas_centerX);
        make.bottom.equalTo(imgAvatar.mas_bottom).offset(-10.0);
        make.width.height.mas_equalTo(20.0);
    }];
    
    tfAccountName.borderStyle = UITextBorderStyleNone;
    tfAccountName.layer.cornerRadius = 3.0;
    tfAccountName.layer.borderWidth = 1.0;
    tfAccountName.layer.borderColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                                       blue:(230/255.0) alpha:1.0].CGColor;
    tfAccountName.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    [tfAccountName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgChangeAvatar.mas_bottom).offset(40.0);
        make.left.equalTo(self.view).offset(30.0);
        make.right.equalTo(self.view).offset(-30.0);
        make.height.mas_equalTo(40.0);
    }];
    tfAccountName.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8.0, 40.0)];
    tfAccountName.leftViewMode = UITextFieldViewModeAlways;
    
    //  cancel button
    btnCancel.titleLabel.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    [btnCancel setTitle:[appDelegate.localization localizedStringForKey:@"Cancel"]
               forState:UIControlStateNormal];
    btnCancel.backgroundColor = [UIColor colorWithRed:(250/255.0) green:(80/255.0)
                                                 blue:(80/255.0) alpha:1.0];
    [btnCancel setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnCancel.clipsToBounds = YES;
    btnCancel.layer.cornerRadius = 40.0/2;
    
    [btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tfAccountName.mas_bottom).offset(30);
        make.right.equalTo(tfAccountName.mas_centerX).offset(-10);
        make.left.equalTo(tfAccountName.mas_left);
        make.height.mas_equalTo(40.0);
    }];
    
    btnSave.titleLabel.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    [btnSave setTitle:[appDelegate.localization localizedStringForKey:@"Save"]
             forState:UIControlStateNormal];
    [btnSave setBackgroundImage:[UIImage imageNamed:@"bg_button.png"]
                       forState:UIControlStateNormal];
    [btnSave setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnSave.clipsToBounds = YES;
    btnSave.layer.cornerRadius = 40.0/2;
    [btnSave mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(tfAccountName.mas_centerX).offset(10);
        make.centerY.equalTo(btnCancel.mas_centerY);
        make.right.equalTo(tfAccountName.mas_right);
        make.height.equalTo(btnCancel.mas_height);
    }];
//    [btnSave addTarget:self
//                action:@selector(saveContactPressed:)
//      forControlEvents:UIControlEventTouchUpInside];
    
    icWaiting.backgroundColor = UIColor.whiteColor;
    icWaiting.alpha = 0.5;
    [icWaiting mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
    icWaiting.hidden = YES;
}

//  Tap vào màn hình chính để đóng bàn phím
- (void)whenTapOnMainScreen {
    [self.view endEditing: true];
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
    appDelegate.fromImagePicker = YES;
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    [self presentViewController:pickerController animated:YES completion:nil];
}

- (void)pressOnCamera {
    appDelegate.fromImagePicker = YES;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    [picker setDelegate: self];
    [picker setSourceType: UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)removeAvatar {
    if (appDelegate._dataCrop != nil) {
        appDelegate._dataCrop = nil;
        if ([AppUtils isNullOrEmpty: myAvatar]) {
            imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
        }else{
            imgAvatar.image = [UIImage imageWithData: [NSData dataFromBase64String: myAvatar]];
        }
    }else if (myAvatar != nil && ![myAvatar isEqualToString:@""]){
        myAvatar = @"";
        imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
    }
}

#pragma mark - ContactDetailsImagePickerDelegate Functions

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    appDelegate._cropAvatar = image;
    
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
    PECropController.image = appDelegate._cropAvatar;
    
    UIImage *image = appDelegate._cropAvatar;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat length = MIN(width, height);
    PECropController.imageCropRect = CGRectMake((width - length) / 2,
                                                (height - length) / 2,
                                                length,
                                                length);
    PECropController.keepingCropAspectRatio = true;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController: PECropController];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [[PhoneMainView instance] changeCurrentView:PECropViewController.compositeViewDescription
                                           push:true];
    
    //  [self presentViewController:navigationController animated:YES completion:NULL];
}

#pragma mark - PECropViewControllerDelegate methods

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage transform:(CGAffineTransform)transform cropRect:(CGRect)cropRect
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    appDelegate._dataCrop = UIImagePNGRepresentation(croppedImage);
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

- (void)startUploadImage: (NSData *)uploadData withName: (NSString *)imageName
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        UploadPicture *session = [[UploadPicture alloc] init];
        [session uploadData:uploadData withName:imageName beginUploadBlock:nil finishUploadBlock:^(UploadPicture *uploadSession) {
            dispatch_async(dispatch_get_main_queue(), ^{
                icWaiting.hidden = YES;
                [icWaiting stopAnimating];
                
                if (uploadSession.uploadError != nil) {
                    [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Failed. Please try later!"] duration:2.0 position:CSToastPositionCenter];
                }else{
                    if (isRemoveAvatar) {
                        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Your avatar has been removed"] duration:2.0 position:CSToastPositionCenter];
                    }else{
                        [self.view makeToast:[appDelegate.localization localizedStringForKey:@"Your avatar has been uploaded"] duration:2.0 position:CSToastPositionCenter];
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
                
                if (tfAccountName.text.length > 0) {
                    NSString *pbxKeyName = [NSString stringWithFormat:@"%@_%@", @"pbxName", accountID];
                    [[NSUserDefaults standardUserDefaults] setObject:tfAccountName.text forKey:pbxKeyName];
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
                imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
            }else{
                imgAvatar.image = [UIImage imageWithData: data];
            }
        });
    });
}



@end
