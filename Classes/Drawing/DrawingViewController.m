//
//  DrawingViewController.m
//  linphone
//
//  Created by lam quang quan on 1/4/19.
//

#import "DrawingViewController.h"
#import "MyScrollView.h"

@interface DrawingViewController () {
    MyScrollView *scvContent;
    
    UIView *toolbarView;
    UIButton *btnControl;
    float hToolbar;
    float hIcon;
}

@end

@implementation DrawingViewController
@synthesize viewHeader, bgHeader, icBack, icSave;

#pragma mark - UICompositeViewDelegate Functions
static UICompositeViewDescription *compositeDescription = nil;
+ (UICompositeViewDescription *)compositeViewDescription {
    if (compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:nil
                                                                 tabBar:TabBarView.class
                                                               sideMenu:nil
                                                             fullscreen:FALSE
                                                         isLeftFragment:YES
                                                           fragmentWith:0];
        //        compositeDescription.darkBackground = true;
    }
    return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
    return self.class.compositeViewDescription;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initContentForView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)icBackClicked:(UIButton *)sender {
}

- (IBAction)icSaveClicked:(UIButton *)sender {
}

- (void)initContentForView {
    [viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo([LinphoneAppDelegate sharedInstance]._hRegistrationState);
    }];
    
    hToolbar = 50.0;
    hIcon = 40.0;
    toolbarView = [[UIView alloc] init];
    toolbarView.backgroundColor = [UIColor colorWithRed:(13/255.0) green:(45/255.0)
                                                   blue:(70/255.0) alpha:1.0];
    [self.view addSubview: toolbarView];
    [toolbarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(hToolbar);
    }];
    
    btnControl = [[UIButton alloc] init];
    [btnControl setBackgroundImage:[UIImage imageNamed:@"ic_controls"] forState:UIControlStateNormal];
    [btnControl setBackgroundImage:[UIImage imageNamed:@"ic_controls_act"] forState:UIControlStateSelected];
    [toolbarView addSubview: btnControl];
    [btnControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(toolbarView);
        make.centerY.equalTo(toolbarView.mas_centerY);
        make.width.height.mas_equalTo(hIcon);
    }];
}

@end
