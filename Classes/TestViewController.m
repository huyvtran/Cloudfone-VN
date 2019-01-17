//
//  TestViewController.m
//  linphone
//
//  Created by lam quang quan on 1/17/19.
//

#import "TestViewController.h"

@interface TestViewController () {
    MASConstraint *heightConstraint;
    float firstHeight;
}

@end

@implementation TestViewController
@synthesize viewContnet, tbContent;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    viewContnet.backgroundColor = UIColor.orangeColor;
    firstHeight = 150.0;
    [viewContnet mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(firstHeight);
        make.top.left.right.equalTo(self.view);
    }];
    
    tbContent.delegate = self;
    tbContent.dataSource = self;
    [tbContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewContnet.mas_bottom);
        make.bottom.left.right.equalTo(self.view);
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
    NSLog(@"%f", firstHeight + scrollView.contentOffset.y);
    [viewContnet mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(firstHeight + scrollView.contentOffset.y);
    }];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
}

@end
