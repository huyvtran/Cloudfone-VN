//
//  iPadCallHistoryViewController.m
//  linphone
//
//  Created by lam quang quan on 1/16/19.
//

#import "iPadCallHistoryViewController.h"

@interface iPadCallHistoryViewController () {
    float tbHeight;
}

@end

@implementation iPadCallHistoryViewController
@synthesize imgAvatar, scvContent, tbHistory;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupUIForView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUIForView {
    tbHeight = SCREEN_WIDTH;
    [imgAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(tbHeight);
    }];
    
    scvContent.delegate = self;
    scvContent.backgroundColor = UIColor.clearColor;
    [scvContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(self.view);
        make.width.mas_equalTo(SCREEN_WIDTH);
    }];
    
    tbHistory.backgroundColor = UIColor.orangeColor;
    [tbHistory mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(scvContent).offset(tbHeight/2);
        make.left.equalTo(scvContent);
        make.height.mas_equalTo(500.0);
        make.width.mas_equalTo(SCREEN_WIDTH);
    }];
}

#pragma mark - Scrollview Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y <= 0) {
        [imgAvatar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
        }];
    }else{
        if (scrollView.contentOffset.y < tbHeight/2) {
            [imgAvatar mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view).offset(-scrollView.contentOffset.y);
            }];
        }else{
            
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
}


@end
