//
//  DrawingViewController.m
//  linphone
//
//  Created by lam quang quan on 1/4/19.
//

#import "DrawingViewController.h"
#import "MyScrollView.h"
#import "DrawingControlsView.h"

@interface DrawingViewController () {
    MyScrollView *scvContent;
    
    UIView *toolbarView;
    UIButton *btnControl;
    float hToolbar;
    float hIcon;
    
    DrawingControlsView *viewControls;
    float hControlsView;
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
    [self initViewControlsForDrawing];
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
    [btnControl setBackgroundImage:[[UIImage imageNamed:@"ic_controls"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)] forState:UIControlStateNormal];
    [btnControl setBackgroundImage:[[UIImage imageNamed:@"ic_controls_act"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)] forState:UIControlStateSelected];
    [btnControl addTarget:self
                   action:@selector(buttonControlsPress:)
         forControlEvents:UIControlEventTouchUpInside];
    [toolbarView addSubview: btnControl];
    [btnControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(toolbarView);
        make.centerY.equalTo(toolbarView.mas_centerY);
        make.width.height.mas_equalTo(hIcon);
    }];
}

- (void)buttonControlsPress: (UIButton *)sender {
    if (viewControls == nil) {
        viewControls = [[DrawingControlsView alloc] initWithFrame:CGRectMake(0, toolbarView.frame.origin.y, SCREEN_WIDTH, 0)];
        [self.view addSubview: viewControls];
        [viewControls mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(toolbarView.mas_top);
            make.height.mas_equalTo(hControlsView);
        }];
    }
    
    if (viewControls.frame.size.height == 0) {
        [viewControls mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(hControlsView);
        }];
    }else {
        [viewControls mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }

    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }completion:^(BOOL finished) {
        [viewControls.clvColors reloadData];
    }];
}

- (void)initViewControlsForDrawing
{
    viewControls = [[DrawingControlsView alloc] initWithFrame:CGRectMake(0, toolbarView.frame.origin.y, SCREEN_WIDTH, 0)];
    viewControls.backgroundColor = toolbarView.backgroundColor;
    [self.view addSubview: viewControls];
    [viewControls mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(toolbarView.mas_top);
        make.height.mas_equalTo(0.0);
    }];
    
    float sizeButton = (SCREEN_WIDTH - 11 * PADDING_DRAW_CONTROL_VIEW) / 10;
    hControlsView = PADDING_DRAW_CONTROL_VIEW + sizeButton + PADDING_DRAW_CONTROL_VIEW + 65.0;
    viewControls.sizeButtonColor = sizeButton;
}

@end
