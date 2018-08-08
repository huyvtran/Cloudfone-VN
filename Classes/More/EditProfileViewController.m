//
//  EditProfileViewController.m
//  linphone
//
//  Created by Apple on 4/28/17.
//
//

#import "EditProfileViewController.h"
#import "PhoneMainView.h"
#import "SettingItem.h"
#import "NSData+Base64.h"
#import "MenuCell.h"
#import "NSDatabase.h"
#import "PECropViewController.h"

@interface EditProfileViewController ()<PECropViewControllerDelegate>{
    LinphoneAppDelegate *appDelegate;
    float hInfo;
    float marginY;
    
    YBHud *waitingHud;
    NSDictionary *profile;
    
    NSString *strAvatar;
    UIFont *textFont;
    
    NSTimer *updateProfile;
}

@end

@implementation EditProfileViewController
@synthesize _viewHeader, _iconBack, _lbHeader;
@synthesize _scrollViewContent, _viewInfo, _imgAvatar, _tfStatus, _viewContent, _lbFullname, _tfFullname, _lbEmail, _tfEmail, _lbAddress, _tvAddress, _btnSave, _btnAvatar;

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

#pragma mark - My Controller Delegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

//  View không bị thay đổi sau khi vào pickerview controller
- (void) viewDidLayoutSubviews {
    if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        CGRect viewBounds = self.view.bounds;
        CGFloat topBarOffset = self.topLayoutGuide.length;
        viewBounds.origin.y = topBarOffset * -1;
        self.view.bounds = viewBounds;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //  my code here
    appDelegate = (LinphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self setupUIForView];
    
    //  add waiting view
    waitingHud = [[YBHud alloc] initWithHudType:DGActivityIndicatorAnimationTypeLineScale andText:@""];
    waitingHud.tintColor = [UIColor whiteColor];
    waitingHud.dimAmount = 0.5;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [self showContentWithCurrentLanguage];
    
    //  Hiển thị trạng thái chat
    profile = [NSDatabase getProfileInfoOfAccount: USERNAME];
    
    //  Hiển thị thông tin profile của user
    [self showProfileInformationOfUser];
    
    if (appDelegate._dataCrop != nil) {
        [_imgAvatar setImage:[UIImage imageWithData: appDelegate._dataCrop]];
        strAvatar = [appDelegate._dataCrop base64EncodedStringWithOptions: 0];
    }else{
        strAvatar = [profile objectForKey:@"avatar"];
        if (strAvatar != nil && ![strAvatar isEqualToString: @""] && ![strAvatar isEqualToString: @"null"] && ![strAvatar isEqualToString: @"(null)"] && ![strAvatar isEqualToString: @"<null>"]) {
            NSData *myAvatar = [NSData dataFromBase64String: strAvatar];
            _imgAvatar.image = [UIImage imageWithData: myAvatar];
        }else{
            _imgAvatar.image = [UIImage imageNamed:@"no_avatar"];
        }
    }
    
    //  notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedUpdateProfile)
                                                 name:updateProfileSuccessfully object:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)_iconBackClicked:(UIButton *)sender {
    appDelegate._dataCrop = nil;
    appDelegate._cropAvatar = nil;
    [[PhoneMainView instance] popCurrentView];
}

- (IBAction)_btnSavePressed:(UIButton *)sender {
    [self.view endEditing: true];
    
    [sender setTitleColor:[UIColor colorWithRed:(24/255.0) green:(185/255.0)
                                           blue:(153/255.0) alpha:1.0]
                 forState:UIControlStateNormal];
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self
                                   selector:@selector(changeTitleColorForButton)
                                   userInfo:nil repeats:false];
}

- (void)changeTitleColorForButton {
    [_btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    if (!appDelegate._internetActive) {
        [self.view makeToast:[appDelegate.localization localizedStringForKey:text_please_check_your_connection]
                    duration:1.5 position:CSToastPositionCenter];
    }else{
        [waitingHud showInView:self.view animated:YES];
        
        updateProfile = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self
                                                       selector:@selector(updateProfileTimeOut)
                                                       userInfo:nil repeats:false];
        
        //  profile info
        [appDelegate.myBuddy.protocol setProfileForAccountWithName: _tfFullname.text email: _tfEmail.text address: _tvAddress.text avatar: strAvatar];
        
        //  Cập nhật trạng thái
        NSString *status = _tfStatus.text;
        if ([status isEqualToString: @""]) {
            status = welcomeToCloudFone;
        }
        
        NSString *user = [NSString stringWithFormat:@"%@@%@", USERNAME, xmpp_cloudfone];
        [appDelegate.myBuddy.protocol setStatus:status withUser: user];
    }
}

- (IBAction)_btnAvatarPressed:(UIButton *)sender {
    [self.view endEditing: true];
    
    if (appDelegate._dataCrop != nil) {
        [self showPopupChooseAvatarWithCurrentAvatar: YES];
    }else{
        if (strAvatar != nil && ![strAvatar isEqualToString: @""] && ![strAvatar isEqualToString: @"null"] && ![strAvatar isEqualToString: @"(null)"] && ![strAvatar isEqualToString: @"<null>"])
        {
            [self showPopupChooseAvatarWithCurrentAvatar: YES];
        }else{
            [self showPopupChooseAvatarWithCurrentAvatar: NO];
        }
    }
}

- (void)showPopupChooseAvatarWithCurrentAvatar: (BOOL)hasAvatar {
    if (hasAvatar) {
        UIActionSheet *popupAddContact = [[UIActionSheet alloc] initWithTitle:[appDelegate.localization localizedStringForKey:text_options] delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:text_cancel] destructiveButtonTitle:nil otherButtonTitles:
                                          [appDelegate.localization localizedStringForKey:text_gallery],
                                          [appDelegate.localization localizedStringForKey:text_camera],
                                          [appDelegate.localization localizedStringForKey:text_remove],
                                          nil];
        popupAddContact.tag = 100;
        [popupAddContact showInView:self.view];
    }else{
        UIActionSheet *popupAddContact = [[UIActionSheet alloc] initWithTitle:[appDelegate.localization localizedStringForKey:text_options] delegate:self cancelButtonTitle:[appDelegate.localization localizedStringForKey:text_cancel] destructiveButtonTitle:nil otherButtonTitles:
                                          [appDelegate.localization localizedStringForKey:text_gallery],
                                          [appDelegate.localization localizedStringForKey:text_camera],
                                          nil];
        popupAddContact.tag = 101;
        [popupAddContact showInView:self.view];
    }
}

#pragma mark - my functions

- (void)updateProfileTimeOut {
    [waitingHud dismissAnimated:YES];
    [self.view makeToast:[appDelegate.localization localizedStringForKey:text_failed]
                duration:1.5 position:CSToastPositionCenter];
    
    [updateProfile invalidate];
    updateProfile = nil;
}

- (void)finishedUpdateProfile {
    [updateProfile invalidate];
    updateProfile = nil;
    
    [waitingHud dismissAnimated:YES];
    [self.view makeToast:[appDelegate.localization localizedStringForKey:text_update_profile_success]
                duration:1.5 position:CSToastPositionCenter];
    
    [NSDatabase saveProfileForAccount:USERNAME withName:_tfFullname.text
                             andAvatar:strAvatar andAddress:_tvAddress.text
                              andEmail:_tfEmail.text withStatus:_tfStatus.text];
    
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self
                                   selector:@selector(backToPopupController)
                                   userInfo:nil repeats:false];
}

- (void)backToPopupController {
    appDelegate._dataCrop = nil;
    [[PhoneMainView instance] popCurrentView];
}

- (void)showContentWithCurrentLanguage {
    _lbHeader.text = [appDelegate.localization localizedStringForKey:text_edit_profile];
    _lbFullname.text = [appDelegate.localization localizedStringForKey:text_fullname];
    _lbEmail.text = [appDelegate.localization localizedStringForKey:text_email];
    _lbAddress.text = [appDelegate.localization localizedStringForKey:text_address];
    [_btnSave setTitle:[appDelegate.localization localizedStringForKey:text_save] forState:UIControlStateNormal];
}

//  Hiển thị bàn phím
- (void)keyboardDidShow: (NSNotification *) notif{
    CGSize keyboardSize = [[[notif userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.05 animations:^{
        _scrollViewContent.frame = CGRectMake(0, _viewHeader.frame.origin.y+_viewHeader.frame.size.height, _scrollViewContent.frame.size.width, SCREEN_HEIGHT-(appDelegate._hStatus+appDelegate._hHeader+keyboardSize.height));
    }];
}

//  Ẩn bàn phím
- (void)keyboardDidHide: (NSNotification *) notif{
    [UIView animateWithDuration:0.05 animations:^{
        _scrollViewContent.frame = CGRectMake(0, _viewHeader.frame.origin.y+_viewHeader.frame.size.height, _scrollViewContent.frame.size.width, SCREEN_HEIGHT-(appDelegate._hStatus+appDelegate._hHeader));
    }];
}

- (BOOL)checkExistsValue: (NSString *)string {
    if (![string isEqualToString:@""] && string != nil && ![string isEqualToString:@"null"] && ![string isEqualToString:@"(null)"] && ![string isEqualToString:@"<null>"]) {
        return true;
    }else{
        return false;
    }
}

//  Hiển thị thông tin profile của user
- (void)showProfileInformationOfUser {
    
    strAvatar = [profile objectForKey:@"avatar"];
    if (strAvatar != nil && ![strAvatar isEqualToString: @""] && ![strAvatar isEqualToString: @"null"] && ![strAvatar isEqualToString: @"(null)"] && ![strAvatar isEqualToString: @"<null>"]) {
        NSData *myAvatar = [NSData dataFromBase64String: strAvatar];
        _imgAvatar.image = [UIImage imageWithData: myAvatar];
    }else{
        _imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
    }
    
    NSString *status = [profile objectForKey:@"status"];
    if (status != nil && ![status isKindOfClass:[NSNull class]]) {
        _tfStatus.text = status;
    }else{
        _tfStatus.text = welcomeToCloudFone;
    }
    
    NSString *name = [profile objectForKey:@"name"];
    if (name != nil && ![name isKindOfClass:[NSNull class]]) {
        _tfFullname.text = name;
    }else{
        _tfFullname.text = @"";
    }
    
    NSString *email = [profile objectForKey:@"email"];
    if (email != nil && ![email isKindOfClass:[NSNull class]]) {
        _tfEmail.text = email;
    }else{
        _tfEmail.text = @"";
    }
    
    NSString *address = [profile objectForKey:@"address"];
    if (address != nil && ![address isKindOfClass:[NSNull class]]) {
        _tvAddress.text = address;
    }else{
        _tvAddress.text = @"";
    }
}

- (void)closeKeyboard {
    [self.view endEditing: true];
}

//  setup ui trong view
- (void)setupUIForView {
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
        _lbHeader.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:20.0];
    }else{
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
        _lbHeader.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }
    
    //  header view
    _viewHeader.frame = CGRectMake(0, -appDelegate._hStatus, SCREEN_WIDTH, appDelegate._hStatus+appDelegate._hHeader);
    _iconBack.frame = CGRectMake(0, appDelegate._hStatus, appDelegate._hHeader, appDelegate._hHeader);
    [_iconBack setBackgroundImage:[UIImage imageNamed:@"ic_back_act.png"]
                         forState:UIControlStateHighlighted];
    
    _lbHeader.frame = CGRectMake(_iconBack.frame.origin.x+_iconBack.frame.size.width+5, _iconBack.frame.origin.y, _viewHeader.frame.size.width-2*(_iconBack.frame.origin.x+_iconBack.frame.size.width+10), _iconBack.frame.size.height);
    
    //  scrollview content
    _scrollViewContent.frame = CGRectMake(0, _viewHeader.frame.origin.y+_viewHeader.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT-(appDelegate._hStatus+appDelegate._hHeader));
    
    UITapGestureRecognizer *tapClose = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard)];
    _scrollViewContent.userInteractionEnabled = YES;
    [_scrollViewContent addGestureRecognizer: tapClose];
    
    hInfo = 76.0;
    _viewInfo.frame = CGRectMake(0, 0, _scrollViewContent.frame.size.width, hInfo);
    _imgAvatar.frame = CGRectMake(8, 8, hInfo-16, hInfo-16);
    _imgAvatar.clipsToBounds = YES;
    _imgAvatar.layer.cornerRadius = (hInfo-16)/2;
    
    _btnAvatar.frame = _imgAvatar.frame;
    
    UIColor *textColor = [UIColor colorWithRed:(80/255.0) green:(80/255.0)
                                          blue:(80/255.0) alpha:1.0];
    
    _tfStatus.frame = CGRectMake(2*_imgAvatar.frame.origin.x+_imgAvatar.frame.size.width, (_viewInfo.frame.size.height-30)/2, _viewInfo.frame.size.width-(3*_imgAvatar.frame.origin.x+_imgAvatar.frame.size.width), 30);
    _tfStatus.textColor = textColor;
    _tfStatus.borderStyle = UITextBorderStyleNone;
    _tfStatus.font = textFont;
    
    //  content
    _viewContent.frame = CGRectMake(0, _viewInfo.frame.origin.y+_viewInfo.frame.size.height, _scrollViewContent.frame.size.width, _scrollViewContent.frame.size.height-_viewInfo.frame.size.height);
    marginY = 10.0;
    
    //  fullname
    
    float tmpWidth = (_viewContent.frame.size.width-30)/3;
    _lbFullname.frame = CGRectMake(10, 10, tmpWidth-25, 32);
    _lbFullname.textColor = UIColor.darkGrayColor;
    _lbFullname.font = textFont;
    
    _tfFullname.frame = CGRectMake(_lbFullname.frame.origin.x+_lbFullname.frame.size.width+10, _lbFullname.frame.origin.y, 2*tmpWidth+25, _lbFullname.frame.size.height);
    _tfFullname.textColor = textColor;
    _tfFullname.font = textFont;
    
    //  email
    _lbEmail.frame = CGRectMake(_lbFullname.frame.origin.x, _lbFullname.frame.origin.y+_lbFullname.frame.size.height+marginY, _lbFullname.frame.size.width, _lbFullname.frame.size.height);
    _lbEmail.textColor = UIColor.darkGrayColor;
    _lbEmail.font = textFont;
    
    _tfEmail.frame = CGRectMake(_tfFullname.frame.origin.x, _lbEmail.frame.origin.y, _tfFullname.frame.size.width, _tfFullname.frame.size.height);
    _tfEmail.textColor = textColor;
    _tfEmail.font = textFont;
    
    //  address
    _lbAddress.frame = CGRectMake(_lbEmail.frame.origin.x, _lbEmail.frame.origin.y+_lbEmail.frame.size.height+marginY, _lbEmail.frame.size.width, _lbEmail.frame.size.height);
    _lbAddress.textColor = UIColor.darkGrayColor;
    _lbAddress.font = textFont;
    
    _tvAddress.frame = CGRectMake(_tfEmail.frame.origin.x, _lbAddress.frame.origin.y, _tfEmail.frame.size.width, _tfEmail.frame.size.height*2.5);
    _tvAddress.layer.borderWidth = 1.0;
    _tvAddress.layer.borderColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0)
                                                    blue:(220/255.0) alpha:1.0].CGColor;
    _tvAddress.layer.cornerRadius = 5.0;
    _tvAddress.font = textFont;
    _tvAddress.textColor = textColor;
    
    CGSize textSize = [AppUtils getSizeWithText:[appDelegate.localization localizedStringForKey:text_save]
                                          withFont:textFont
                                       andMaxWidth:_viewContent.frame.size.width];
    
    [_btnSave setFrame: CGRectMake(_viewHeader.frame.size.width-(textSize.width+20), appDelegate._hStatus, textSize.width+20, _viewHeader.frame.size.height-appDelegate._hStatus)];
    [_btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnSave.titleLabel setFont:textFont];
    
    textSize = [AppUtils getSizeWithText:[appDelegate.localization localizedStringForKey:text_cancel]
                                   withFont:textFont
                                andMaxWidth:_viewContent.frame.size.width];
    
    _viewContent.frame = CGRectMake(_viewContent.frame.origin.x, _viewContent.frame.origin.y, _viewContent.frame.size.width, _tvAddress.frame.origin.y+_tvAddress.frame.size.height+marginY);
    _scrollViewContent.contentSize = CGSizeMake(_scrollViewContent.frame.size.width, _viewContent.frame.origin.y+_viewContent.frame.size.height);
}

#pragma mark - UITableview Delegate
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *curCell = [tableView cellForRowAtIndexPath: indexPath];
    curCell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    if (curCell.tag == 0) {
 
    }else if (curCell.tag == 1) {
        // Go to camera
 
    }else{
        //  [newContact set_avatar: @""];
        [_imgAvatar setImage:[UIImage imageNamed:@"no_avatar.png"]];
        strAvatar = @"";
        appDelegate._dataCrop = nil;
    }
    [popupChooseAvatar fadeOut];
}
*/

#pragma mark - Actionsheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 100) {
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
                NSLog(@"Remove");
                break;
            }
            case 3:{
                NSLog(@"Cancel");
                break;
            }
        }
    }else if (actionSheet.tag == 101){
        switch (buttonIndex) {
            case 0:{
                [self pressOnGallery];
                break;
            }
            case 1:{
                [self pressOnCamera];
                break;
            }
        }
    }
}

- (void)pressOnCamera {
    appDelegate.fromImagePicker = YES;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    [picker setDelegate: self];
    [picker setSourceType: UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)pressOnGallery {
    appDelegate.fromImagePicker = YES;
    
    UILabel *testLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, -20, 320, 20)];
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    [pickerController.view addSubview: testLabel];
    
    pickerController.delegate = self;
    [self presentViewController:pickerController animated:YES completion:nil];
}

#pragma mark - Picker image

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    // Crop image trong edits contact
    appDelegate._chooseMyAvatar = NO;
    
    appDelegate._cropAvatar = image;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self openEditor];
    }];
}

- (void)openEditor {
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    controller.image = appDelegate._cropAvatar;
    
    UIImage *image = appDelegate._cropAvatar;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat length = MIN(width, height);
    controller.imageCropRect = CGRectMake((width - length) / 2,
                                          (height - length) / 2,
                                          length,
                                          length);
    controller.keepingCropAspectRatio = true;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [[PhoneMainView instance] changeCurrentView:PECropViewController.compositeViewDescription push: true];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    //  [lbStatusBg setBackgroundColor:[UIColor blackColor]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
