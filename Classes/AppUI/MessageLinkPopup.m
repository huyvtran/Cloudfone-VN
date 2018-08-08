//
//  MessageLinkPopup.m
//  linphone
//
//  Created by Designer 01 on 3/16/15.
//
//

#import "MessageLinkPopup.h"
#import "SettingItem.h"
#import "OTRConstants.h"
#import "OptionsCell.h"

@implementation MessageLinkPopup
@synthesize _optionsTableView, _listOptions, _tapGesture, delegate, typeData, strValue;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        //My code here
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fadeOut)
                                                     name:@"closeSettingPopupView" object:nil];
        self.layer.borderWidth = 3.0;
        self.layer.borderColor = [UIColor colorWithRed:(23/255.0) green:(184/255.0)
                                                  blue:(151/255.0) alpha:1.0].CGColor;
        
        _optionsTableView = [[UITableView alloc] initWithFrame: CGRectMake(3, 3, frame.size.width-6, frame.size.height-6)];
        _optionsTableView.scrollEnabled = NO;
        _optionsTableView.delegate = self;
        _optionsTableView.dataSource = self;
        _optionsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview: _optionsTableView];
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _listOptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"OptionsCell";
    OptionsCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"OptionsCell" owner:self options:nil];
        cell = topLevelObjects[0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, _optionsTableView.frame.size.width, 40);
    [cell setupUIForCell];
    
    SettingItem *curItem = [_listOptions objectAtIndex: indexPath.row];
    cell.tag = indexPath.row;
    cell._imgIcon.image = [UIImage imageNamed: curItem._imageStr];
    cell._lbTitle.text = curItem._valueStr;
    cell.textLabel.textColor = UIColor.grayColor;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:(int)indexPath.row],@"typeAction",[NSNumber numberWithInt:self.typeData],@"typeData", self.strValue, @"value", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:k11ProcessingLinkOnMessage object:dict];
    [self fadeOut];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}


#pragma mark - delegate
- (void)showInView:(UIView *)aView animated:(BOOL)animated {
    //Add transparent
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopupViewWhenTagOut)];
    
    UIView *viewBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    viewBackground.backgroundColor = UIColor.blackColor;
    viewBackground.alpha = 0.5;
    viewBackground.tag = 25;
    [viewBackground addGestureRecognizer:_tapGesture];
    
    [aView addSubview:viewBackground];
    [aView addSubview:self];
    
    if (animated) {
        [self fadeIn];
    }
}

- (void)fadeIn {
    //self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    CGRect oldRect = CGRectMake((SCREEN_WIDTH-self.frame.size.width)/2, -self.frame.size.height, self.frame.size.width, self.frame.size.height);
    self.frame = oldRect;
    CGRect newRect = CGRectMake((SCREEN_WIDTH-self.frame.size.width)/2, (SCREEN_HEIGHT-self.frame.size.height)/2, self.frame.size.width, self.frame.size.height);
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = newRect;
        self.alpha = 1;
        //self.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)fadeOut {
    for (UIView *subView in self.window.subviews)
    {
        if (subView.tag == 25)
        {
            [subView removeFromSuperview];
        }
    }
    CGRect oldRect = CGRectMake((SCREEN_WIDTH-self.frame.size.width)/2, -self.frame.size.height, self.frame.size.width, self.frame.size.height);
    [UIView animateWithDuration:0.5 animations:^{
        //self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.frame = oldRect;
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self removeFromSuperview];
        }
    }];
}

- (void)closePopupViewWhenTagOut{
    [self fadeOut];
    [self.superview removeGestureRecognizer:_tapGesture];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
