//
//  iPadKeypadViewController.m
//  linphone
//
//  Created by admin on 1/11/19.
//

#import "iPadKeypadViewController.h"
#import "DeviceUtils.h"

@interface iPadKeypadViewController ()

@end

@implementation iPadKeypadViewController
@synthesize viewHeader, imgHeader, imgLogo, lbAccount, lbStatus;
@synthesize viewNumber, icAddContact, tfAddress;
@synthesize viewKeypad, oneButton, twoButton, threeButton, fourButton, fiveButton, sixButton, sevenButton, eightButton, nineButton, zeroButton, starButton, sharpButton, btnCall, btnHotline, btnBackspace;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupUIForView];
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

- (IBAction)icAddContactClicked:(UIButton *)sender {
}

- (void)setupUIForView {
    //  header
    
    self.view.backgroundColor = UIColor.whiteColor;
    [viewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(HEIGHT_IPAD_NAV);
    }];
    
    [imgHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(viewHeader);
    }];
    
    float top = STATUS_BAR_HEIGHT + (HEIGHT_IPAD_NAV - STATUS_BAR_HEIGHT - HEIGHT_IPAD_HEADER_BUTTON)/2;
    [imgLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewHeader).offset(10.0);
        make.top.equalTo(viewHeader).offset(top);
        make.width.height.mas_equalTo(HEIGHT_IPAD_HEADER_BUTTON);
    }];
    
    lbAccount.font = [UIFont fontWithName:MYRIADPRO_BOLD size:22.0];
    lbAccount.textAlignment = NSTextAlignmentCenter;
    [lbAccount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(imgLogo);
        make.centerX.equalTo(viewHeader.mas_centerX);
        make.width.mas_equalTo(150);
    }];
    
    //  status label
    lbStatus.font = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
    lbStatus.numberOfLines = 0;
    [lbStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewHeader.mas_centerX);
        make.top.bottom.equalTo(lbAccount);
        make.right.equalTo(viewHeader).offset(-10.0);
    }];
    
    
    //  view keypad
    
    //  Number keypad
    float wIcon = 80.0;
    float spaceMarginY = 20;
    float spaceMarginX = 30;
    float hKeypad = (5*wIcon + 6*spaceMarginY);
    
    viewKeypad.backgroundColor = UIColor.clearColor;
    [viewKeypad mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view.mas_centerY);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(hKeypad);
    }];
    
    //  1, 2, 3
    twoButton.backgroundColor = UIColor.clearColor;
    twoButton.layer.cornerRadius = wIcon/2;
    twoButton.clipsToBounds = YES;
    [twoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewKeypad).offset(spaceMarginY);
        make.centerX.equalTo(viewKeypad.mas_centerX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    oneButton.layer.cornerRadius = wIcon/2;
    oneButton.clipsToBounds = YES;
    [oneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(twoButton);
        make.right.equalTo(twoButton.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    threeButton.layer.cornerRadius = wIcon/2;
    threeButton.clipsToBounds = YES;
    [threeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(twoButton);
        make.left.equalTo(twoButton.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    //  4, 5, 6
    fiveButton.layer.cornerRadius = wIcon/2;
    fiveButton.clipsToBounds = YES;
    [fiveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(twoButton.mas_bottom).offset(spaceMarginY);
        make.centerX.equalTo(twoButton.mas_centerX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    fourButton.layer.cornerRadius = wIcon/2;
    fourButton.clipsToBounds = YES;
    [fourButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fiveButton.mas_top);
        make.right.equalTo(fiveButton.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    sixButton.layer.cornerRadius = wIcon/2;
    sixButton.clipsToBounds = YES;
    [sixButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fiveButton.mas_top);
        make.left.equalTo(fiveButton.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    //  7, 8, 9
    eightButton.layer.cornerRadius = wIcon/2;
    eightButton.clipsToBounds = YES;
    [eightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fiveButton.mas_bottom).offset(spaceMarginY);
        make.centerX.equalTo(viewKeypad.mas_centerX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    sevenButton.layer.cornerRadius = wIcon/2;
    sevenButton.clipsToBounds = YES;
    [sevenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(eightButton.mas_top);
        make.right.equalTo(eightButton.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    nineButton.layer.cornerRadius = wIcon/2;
    nineButton.clipsToBounds = YES;
    [nineButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(eightButton.mas_top);
        make.left.equalTo(eightButton.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    //  *, 0, #
    zeroButton.layer.cornerRadius = wIcon/2;
    zeroButton.clipsToBounds = YES;
    [zeroButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(eightButton.mas_bottom).offset(spaceMarginY);
        make.centerX.equalTo(viewKeypad.mas_centerX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    starButton.layer.cornerRadius = wIcon/2;
    starButton.clipsToBounds = YES;
    [starButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(zeroButton.mas_top);
        make.right.equalTo(zeroButton.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    sharpButton.layer.cornerRadius = wIcon/2;
    sharpButton.clipsToBounds = YES;
    [sharpButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(zeroButton.mas_top);
        make.left.equalTo(zeroButton.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    //  fifth layer
    btnCall.layer.cornerRadius = wIcon/2;
    btnCall.clipsToBounds = YES;
    [btnCall mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(zeroButton.mas_bottom).offset(spaceMarginY);
        make.centerX.equalTo(viewKeypad.mas_centerX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    btnHotline.layer.cornerRadius = wIcon/2;
    btnHotline.clipsToBounds = YES;
    [btnHotline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnCall.mas_top);
        make.right.equalTo(btnCall.mas_left).offset(-spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
    
    btnBackspace.layer.cornerRadius = wIcon/2;
    btnBackspace.clipsToBounds = YES;
    [btnBackspace mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnCall.mas_top);
        make.left.equalTo(btnCall.mas_right).offset(spaceMarginX);
        make.width.height.mas_equalTo(wIcon);
    }];
}

@end
