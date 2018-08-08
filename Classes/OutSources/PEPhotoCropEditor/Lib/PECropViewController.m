//
//  PECropViewController.m
//  PhotoCropEditor
//
//  Created by kishikawa katsumi on 2013/05/19.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "PECropViewController.h"
#import "PECropView.h"
#import "PhoneMainView.h"

@interface PECropViewController () <UIActionSheetDelegate>{
    
}

@property (nonatomic) PECropView *cropView;
@property (nonatomic) UIActionSheet *actionSheet;

- (void)commonInit;

@end

@implementation PECropViewController
@synthesize rotationEnabled = _rotationEnabled;
@synthesize _viewHeader, _lbHeader, _iconBack, _btnSave, _bgStatus;


#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
    if (compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:nil
                                                                 tabBar:nil
                                                               sideMenu:nil
                                                             fullscreen:false
                                                         isLeftFragment:false
                                                           fragmentWith:nil];
    }
    return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
    return self.class.compositeViewDescription;
}

+ (NSBundle *)bundle
{
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"PEPhotoCropEditor" withExtension:@"bundle"];
        bundle = [[NSBundle alloc] initWithURL:bundleURL];
    });
    
    return bundle;
}

static inline NSString *PELocalizedString(NSString *key, NSString *comment)
{
    return [[PECropViewController bundle] localizedStringForKey:key value:nil table:@"Localizable"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    self.rotationEnabled = YES;
}

#pragma mark -

- (void)loadView
{
    UIView *contentView = [[UIView alloc] init];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentView.backgroundColor = [UIColor blackColor];
    self.view = contentView;
    
    self.cropView = [[PECropView alloc] initWithFrame:contentView.bounds];
    [contentView addSubview:self.cropView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addViewHeaderForMainView];
    
//    self.navigationController.navigationBar.translucent = NO;
//    self.navigationController.toolbar.translucent = NO;
//
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
//                                                                                          target:self
//                                                                                          action:@selector(cancel:)];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
//                                                                                           target:self
//                                                                                           action:@selector(done:)];
    /*  Leo Kelvin
    if (!self.toolbarItems) {
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                       target:nil
                                                                                       action:nil];
        UIBarButtonItem *constrainButton = [[UIBarButtonItem alloc] initWithTitle:PELocalizedString(@"Constrain", nil)
                                                                            style:UIBarButtonItemStyleBordered
                                                                           target:self
                                                                           action:@selector(constrain:)];
        self.toolbarItems = @[flexibleSpace, constrainButton, flexibleSpace];
    }
    self.navigationController.toolbarHidden = self.toolbarHidden;
    */
    self.cropView.image = self.image;
    self.cropView.rotationGestureRecognizer.enabled = _rotationEnabled;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    [self showContentWithCurrentLanguage];
    
    //  controller.delegate = self;
    self.image = [LinphoneAppDelegate sharedInstance]._cropAvatar;
    
    UIImage *image = [LinphoneAppDelegate sharedInstance]._cropAvatar;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat length = MIN(width, height);
    self.imageCropRect = CGRectMake((width - length) / 2,
                                          (height - length) / 2,
                                          length,
                                          length);
    self.keepingCropAspectRatio = true;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.cropAspectRatio != 0) {
        self.cropAspectRatio = self.cropAspectRatio;
    }
    if (!CGRectEqualToRect(self.cropRect, CGRectZero)) {
        self.cropRect = self.cropRect;
    }
    if (!CGRectEqualToRect(self.imageCropRect, CGRectZero)) {
        self.imageCropRect = self.imageCropRect;
    }
    
    self.keepingCropAspectRatio = self.keepingCropAspectRatio;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark -

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.cropView.image = image;
}

- (void)setKeepingCropAspectRatio:(BOOL)keepingCropAspectRatio
{
    _keepingCropAspectRatio = keepingCropAspectRatio;
    self.cropView.keepingCropAspectRatio = self.keepingCropAspectRatio;
}

- (void)setCropAspectRatio:(CGFloat)cropAspectRatio
{
    _cropAspectRatio = cropAspectRatio;
    self.cropView.cropAspectRatio = self.cropAspectRatio;
}

- (void)setCropRect:(CGRect)cropRect
{
    _cropRect = cropRect;
    _imageCropRect = CGRectZero;
    
    CGRect cropViewCropRect = self.cropView.cropRect;
    cropViewCropRect.origin.x += cropRect.origin.x;
    cropViewCropRect.origin.y += cropRect.origin.y;
    
    CGSize size = CGSizeMake(fminf(CGRectGetMaxX(cropViewCropRect) - CGRectGetMinX(cropViewCropRect), CGRectGetWidth(cropRect)),
                             fminf(CGRectGetMaxY(cropViewCropRect) - CGRectGetMinY(cropViewCropRect), CGRectGetHeight(cropRect)));
    cropViewCropRect.size = size;
    self.cropView.cropRect = cropViewCropRect;
}

- (void)setImageCropRect:(CGRect)imageCropRect
{
    _imageCropRect = imageCropRect;
    _cropRect = CGRectZero;
    
    self.cropView.imageCropRect = imageCropRect;
}

- (BOOL)isRotationEnabled
{
    return _rotationEnabled;
}

- (void)setRotationEnabled:(BOOL)rotationEnabled
{
    _rotationEnabled = rotationEnabled;
    self.cropView.rotationGestureRecognizer.enabled = _rotationEnabled;
}

- (CGAffineTransform)rotationTransform
{
    return self.cropView.rotation;
}

- (CGRect)zoomedCropRect
{
    return self.cropView.zoomedCropRect;
}

- (void)resetCropRect
{
    [self.cropView resetCropRect];
}

- (void)resetCropRectAnimated:(BOOL)animated
{
    [self.cropView resetCropRectAnimated:animated];
}

#pragma mark -

- (void)cancel:(id)sender
{
    /*  Leo Kelvin
    if ([self.delegate respondsToSelector:@selector(cropViewControllerDidCancel:)]) {
        [self.delegate cropViewControllerDidCancel:self];
    }
    */
    //  [self.delegate cropViewControllerDidCancel:self];
    [[PhoneMainView instance] popCurrentView];
}

- (void)done:(id)sender
{
    UIImage *cropImage = [AppUtils cropImageWithSize:CGSizeMake(500, 500) fromImage:self.cropView.croppedImage];
    [LinphoneAppDelegate sharedInstance]._dataCrop = UIImageJPEGRepresentation(cropImage, 1);
//    [LinphoneAppDelegate sharedInstance]._dataCrop = UIImagePNGRepresentation(cropImage);
    [[PhoneMainView instance] popCurrentView];
}

- (void)constrain:(id)sender
{
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                   delegate:self
                                          cancelButtonTitle:PELocalizedString(@"Cancel", nil)
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:
                        PELocalizedString(@"Original", nil),
                        PELocalizedString(@"Square", nil),
                        PELocalizedString(@"3 x 2", nil),
                        PELocalizedString(@"3 x 5", nil),
                        PELocalizedString(@"4 x 3", nil),
                        PELocalizedString(@"4 x 6", nil),
                        PELocalizedString(@"5 x 7", nil),
                        PELocalizedString(@"8 x 10", nil),
                        PELocalizedString(@"16 x 9", nil), nil];
    [self.actionSheet showFromToolbar:self.navigationController.toolbar];
}

#pragma mark -

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        CGRect cropRect = self.cropView.cropRect;
        CGSize size = self.cropView.image.size;
        CGFloat width = size.width;
        CGFloat height = size.height;
        CGFloat ratio;
        if (width < height) {
            ratio = width / height;
            cropRect.size = CGSizeMake(CGRectGetHeight(cropRect) * ratio, CGRectGetHeight(cropRect));
        } else {
            ratio = height / width;
            cropRect.size = CGSizeMake(CGRectGetWidth(cropRect), CGRectGetWidth(cropRect) * ratio);
        }
        self.cropView.cropRect = cropRect;
    } else if (buttonIndex == 1) {
        self.cropView.cropAspectRatio = 1.0f;
    } else if (buttonIndex == 2) {
        self.cropView.cropAspectRatio = 2.0f / 3.0f;
    } else if (buttonIndex == 3) {
        self.cropView.cropAspectRatio = 3.0f / 5.0f;
    } else if (buttonIndex == 4) {
        CGFloat ratio = 3.0f / 4.0f;
        CGRect cropRect = self.cropView.cropRect;
        CGFloat width = CGRectGetWidth(cropRect);
        cropRect.size = CGSizeMake(width, width * ratio);
        self.cropView.cropRect = cropRect;
    } else if (buttonIndex == 5) {
        self.cropView.cropAspectRatio = 4.0f / 6.0f;
    } else if (buttonIndex == 6) {
        self.cropView.cropAspectRatio = 5.0f / 7.0f;
    } else if (buttonIndex == 7) {
        self.cropView.cropAspectRatio = 8.0f / 10.0f;
    } else if (buttonIndex == 8) {
        CGFloat ratio = 9.0f / 16.0f;
        CGRect cropRect = self.cropView.cropRect;
        CGFloat width = CGRectGetWidth(cropRect);
        cropRect.size = CGSizeMake(width, width * ratio);
        self.cropView.cropRect = cropRect;
    }
}

#pragma mark - my functions

- (void)addViewHeaderForMainView {
    //  [self.navigationController setNavigationBarHidden:YES animated:NO];
    UIFont *textFont;
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:20.0];
    }else{
        textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    }
    
    _viewHeader = [[UIView alloc] init];
    [_viewHeader setFrame: CGRectMake(0, 0, SCREEN_WIDTH, [LinphoneAppDelegate sharedInstance]._hHeader)];
    [_viewHeader setBackgroundColor:[UIColor colorWithRed:(21/255.0) green:(41/255.0)
                                                     blue:(52/255.0) alpha:1.0]];
    
    _iconBack = [UIButton buttonWithType: UIButtonTypeCustom];
    [_iconBack setFrame: CGRectMake(0, 0, [LinphoneAppDelegate sharedInstance]._hHeader, [LinphoneAppDelegate sharedInstance]._hHeader)];
    [_iconBack setBackgroundImage:[UIImage imageNamed:@"ic_back_def.png"]
                         forState:UIControlStateNormal];
    [_iconBack setBackgroundImage:[UIImage imageNamed:@"ic_back_act.png"]
                         forState:UIControlStateHighlighted];
    [_iconBack addTarget:self
                  action:@selector(cancel:)
        forControlEvents:UIControlEventTouchUpInside];
    
    [_viewHeader addSubview: _iconBack];
    
    _lbHeader = [[UILabel alloc] init];
    [_lbHeader setFrame: CGRectMake(_iconBack.frame.origin.x+_iconBack.frame.size.width+5, 0, (_viewHeader.frame.size.width-2*_iconBack.frame.size.width-10), [LinphoneAppDelegate sharedInstance]._hHeader)];
    [_lbHeader setFont: textFont];
    [_lbHeader setTextColor:[UIColor whiteColor]];
    [_lbHeader setTextAlignment: NSTextAlignmentCenter];
    [_viewHeader addSubview: _lbHeader];
    
    [self.view addSubview: _viewHeader];
    
    _btnSave = [UIButton buttonWithType: UIButtonTypeCustom];
    [_btnSave setFrame: CGRectMake(SCREEN_WIDTH-15-70, SCREEN_HEIGHT-[LinphoneAppDelegate sharedInstance]._hStatus-15-40, 70, 40)];
    [_btnSave setBackgroundImage:[UIImage imageNamed:@"btn_send_default.png"]
                        forState:UIControlStateNormal];
    [_btnSave setBackgroundImage:[UIImage imageNamed:@"btn_send_press.png"]
                        forState:UIControlStateHighlighted];
    [_btnSave addTarget:self
                 action:@selector(done:)
       forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: _btnSave];
}

- (void)showContentWithCurrentLanguage
{
    HMLocalization *localization = [HMLocalization sharedInstance];
    [_lbHeader setText:[localization localizedStringForKey: text_crop_image]];
    [_btnSave setTitle:[localization localizedStringForKey:text_save] forState:UIControlStateNormal];
}


@end
