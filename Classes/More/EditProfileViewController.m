//
//  EditProfileViewController.m
//  linphone
//
//  Created by lam quang quan on 10/17/18.
//

#import "EditProfileViewController.h"
#import "NSData+Base64.h"

@interface EditProfileViewController (){
    LinphoneAppDelegate *appDelegate;
    NSString *myAvatar;
}

@end

@implementation EditProfileViewController
@synthesize viewHeader, bgHeader, icBack, lbHeader, btnChooseAvatar, imgAvatar, imgChangeAvatar, tfAccountName, btnCancel, btnSave;

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
    
    LinphoneProxyConfig *defaultConfig = linphone_core_get_default_proxy_config(LC);
    const char *proxyUsername = linphone_address_get_username(linphone_proxy_config_get_identity_address(defaultConfig));
    NSString* defaultUsername = [NSString stringWithFormat:@"%s" , proxyUsername];
    if (defaultUsername != nil) {
        NSString *pbxKeyName = [NSString stringWithFormat:@"%@_%@", @"pbxName", defaultUsername];
        NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey: pbxKeyName];
        if (name != nil){
            tfAccountName.text = name;
        }
        
        NSString *pbxKeyAvatar = [NSString stringWithFormat:@"%@_%@", @"pbxAvatar", defaultUsername];
        NSString *avatar = [[NSUserDefaults standardUserDefaults] objectForKey: pbxKeyAvatar];
        if (avatar != nil && ![avatar isEqualToString:@""]){
            imgAvatar.image = [UIImage imageWithData: [NSData dataFromBase64String: avatar]];
        }else{
            imgAvatar.image = [UIImage imageNamed:@"no_avatar.png"];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)icBackClick:(UIButton *)sender {
}

- (IBAction)btnChooseAvatarPress:(UIButton *)sender {
    [self.view endEditing: YES];
    
    if (myAvatar != nil && ![myAvatar isEqualToString:@""]) {
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

- (IBAction)btnCancelPress:(UIButton *)sender {
}

- (IBAction)btnSavePress:(UIButton *)sender {
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
    
    [tfAccountName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewHeader.mas_bottom).offset(40);
        make.left.equalTo(self.view).offset(50);
        make.right.equalTo(self.view).offset(-50);
        make.height.mas_equalTo(35.0);
    }];
    
    [btnCancel setTitle:[appDelegate.localization localizedStringForKey:@"Cancel"]
               forState:UIControlStateNormal];
    btnCancel.backgroundColor = [UIColor colorWithRed:(210/255.0) green:(51/255.0)
                                                 blue:(92/255.0) alpha:1.0];
    [btnCancel setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnCancel.clipsToBounds = YES;
    btnCancel.layer.cornerRadius = 40.0/2;
    
    [btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tfAccountName.mas_bottom).offset(30);
        make.right.equalTo(tfAccountName.mas_centerX).offset(-10);
        make.width.mas_equalTo(140.0);
        make.height.mas_equalTo(40.0);
    }];
    
    [btnSave setTitle:[appDelegate.localization localizedStringForKey:@"Save"]
             forState:UIControlStateNormal];
    btnSave.backgroundColor = [UIColor colorWithRed:(20/255.0) green:(129/255.0)
                                               blue:(211/255.0) alpha:1.0];
    [btnSave setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnSave.clipsToBounds = YES;
    btnSave.layer.cornerRadius = 40.0/2;
    [btnSave mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(tfAccountName.mas_centerX).offset(10);
        make.centerY.equalTo(btnCancel.mas_centerY);
        make.width.equalTo(btnCancel.mas_width);
        make.height.equalTo(btnCancel.mas_height);
    }];
//    [btnSave addTarget:self
//                action:@selector(saveContactPressed:)
//      forControlEvents:UIControlEventTouchUpInside];
}

//  Tap vào màn hình chính để đóng bàn phím
- (void)whenTapOnMainScreen {
    [self.view endEditing: true];
}


@end
