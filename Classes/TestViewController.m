//
//  TestViewController.m
//  linphone
//
//  Created by lam quang quan on 1/17/19.
//

#import "TestViewController.h"

@interface TestViewController () {
    UIImageView *imgView;
    UITableView *tbView;
    UIScrollView *scvContent;
    float tbHeight;
    
    MASConstraint *heightConstraint;
    float firstHeight;
    
    CGPoint startPoint;
    CGPoint endPoint;
}

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    tbHeight = SCREEN_WIDTH;
    imgView = [[UIImageView alloc] init];
    imgView.image = [UIImage imageNamed:@"messi.jpg"];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview: imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(tbHeight);
    }];
    
    scvContent = [[UIScrollView alloc] init];
    scvContent.delegate = self;
    scvContent.backgroundColor = UIColor.clearColor;
    scvContent.contentSize = CGSizeMake(SCREEN_WIDTH, 1200);
    scvContent.translatesAutoresizingMaskIntoConstraints  = NO;
    [self.view addSubview: scvContent];
    [scvContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.bottom.left.equalTo(self.view);
        make.width.mas_equalTo(SCREEN_WIDTH);
    }];
    
    tbView = [[UITableView alloc] init];
    tbView.backgroundColor = UIColor.orangeColor;
    [scvContent addSubview: tbView];
    [tbView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(scvContent).offset(tbHeight/2);
        make.left.equalTo(scvContent);
        make.height.mas_equalTo(500.0);
        make.width.mas_equalTo(SCREEN_WIDTH);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableview Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"Article %d", (int)indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"%f", scrollView.contentOffset.y);
    if (scrollView.contentOffset.y <= 0) {
        [imgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
        }];
    }else{
        if (scrollView.contentOffset.y < tbHeight/2) {
            [imgView mas_updateConstraints:^(MASConstraintMaker *make) {
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
