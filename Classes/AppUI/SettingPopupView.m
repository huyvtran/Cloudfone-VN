//
//  SettingPopupView.m
//  linphone
//
//  Created by user on 25/9/14.
//
//

#import "SettingPopupView.h"
#import "OTRConstants.h"
#import "OptionsCell.h"
#import "SettingItem.h"

@implementation SettingPopupView
@synthesize delegate, _settingTableView, _tapGesture, listOptions, idMessage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //  MY CODE HERE
        self.userInteractionEnabled = YES;
        self.layer.borderWidth = 3.0;
        self.layer.borderColor = [UIColor colorWithRed:(23/255.0) green:(184/255.0)
                                                  blue:(151/255.0) alpha:1.0].CGColor;
        
        _settingTableView = [[UITableView alloc] initWithFrame:CGRectMake(3, 3, frame.size.width-6, frame.size.height-6)];
        _settingTableView.delegate = self;
        _settingTableView.dataSource = self;
        _settingTableView.scrollEnabled = NO;
        _settingTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview: _settingTableView];
    }
    return self;
}

- (void)showInView:(UIView *)aView animated:(BOOL)animated {
    //Add transparent
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopupViewWhenTagOut)];
    
    UIView *viewBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    viewBackground.backgroundColor = UIColor.blackColor;
    viewBackground.alpha = 0.5;
    viewBackground.tag = 20;
    [viewBackground addGestureRecognizer:_tapGesture];
    [aView addSubview:viewBackground];
    
    [aView addSubview:self];

    if (animated) {
        [self fadeIn];
    }
}

- (void)fadeIn {
    CGSize mainSize = [[UIScreen mainScreen] bounds].size;
    //self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    CGRect oldRect = CGRectMake((mainSize.width-self.frame.size.width)/2, -self.frame.size.height, self.frame.size.width, self.frame.size.height);
    self.frame = oldRect;
    CGRect newRect = CGRectMake((mainSize.width-self.frame.size.width)/2, (mainSize.height-self.frame.size.height)/2, self.frame.size.width, self.frame.size.height);
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = newRect;
        self.alpha = 1;
        //self.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)fadeOut {
    for (UIView *subView in self.window.subviews){
        if (subView.tag == 20){
            [subView removeFromSuperview];
        }
    }
    CGSize mainSize = [[UIScreen mainScreen] bounds].size;
    CGRect oldRect = CGRectMake((mainSize.width-self.frame.size.width)/2, -self.frame.size.height, self.frame.size.width, self.frame.size.height);
    [UIView animateWithDuration:0.5 animations:^{
        //self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.frame = oldRect;
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

/*----- Xử lý đóng màn hình khi click ra ngoài -----*/
- (void)closePopupViewWhenTagOut{
    [self fadeOut];
    [self.superview removeGestureRecognizer:_tapGesture];
}

- (void)saveListOptions: (NSMutableArray *)list {
    if (listOptions == nil) {
        listOptions = [[NSMutableArray alloc] init];
    }
    [listOptions removeAllObjects];
    [listOptions addObjectsFromArray: list];
    
    [_settingTableView reloadData];
}

#pragma mark - UITableview Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [listOptions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"OptionsCell";
    OptionsCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"OptionsCell" owner:self options:nil];
        cell = topLevelObjects[0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, _settingTableView.frame.size.width, 40.0);
    [cell setupUIForCell];
    
    SettingItem *aItem = [listOptions objectAtIndex: indexPath.row];
    cell._imgIcon.image = [UIImage imageNamed: aItem._imageStr];
    cell._lbTitle.text = aItem._valueStr;
    cell.tag = indexPath.row;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self fadeOut];
    [delegate selectOnMessage:idMessage withRow:(int)indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40.0;
}

@end
