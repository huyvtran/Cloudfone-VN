//
//  TestViewController.h
//  linphone
//
//  Created by lam quang quan on 1/17/19.
//

#import <UIKit/UIKit.h>

@interface TestViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) IBOutlet UITableView *tbContent;
@property(nonatomic, strong) IBOutlet UIView *viewContnet;

@end
