//
//  ChooseAvatarPopupView.m
//  linphone
//
//  Created by mac book on 15/6/15.
//
//

#import "ChooseAvatarPopupView.h"
#import "SettingItem.h"

@implementation ChooseAvatarPopupView
@synthesize _listOptions, _optionsTableView, _tapGesture, delegate, _infoDict;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        //My code here
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fadeOut)
                                                     name:@"closeSettingPopupView" object:nil];
        self.layer.borderWidth = 3.0;
        self.layer.borderColor = [UIColor colorWithRed:(23/255.0) green:(184/255.0)
                                                  blue:(151/255.0) alpha:1.0].CGColor;
        
        _optionsTableView = [[UITableView alloc] initWithFrame:CGRectMake(3, 3, self.frame.size.width-6, self.frame.size.height-6)];
        [_optionsTableView setScrollEnabled: NO];
        if ([_optionsTableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_optionsTableView setSeparatorInset: UIEdgeInsetsZero];
        }
        _optionsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview: _optionsTableView];
    }
    return self;
}

#pragma mark - delegate
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
            [self removeFromSuperview];
        }
    }];
}

- (void)closePopupViewWhenTagOut{
    [self fadeOut];
    [self.superview removeGestureRecognizer:_tapGesture];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithRed:(223/255.0) green:(255/255.0) blue:(133/255.0) alpha:1];
    }else{
        self.backgroundColor = UIColor.clearColor;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
