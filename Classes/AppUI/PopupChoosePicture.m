//
//  PopupChoosePicture.m
//  linphone
//
//  Created by user on 7/11/14.
//
//

#import "PopupChoosePicture.h"
#import "PhoneMainView.h"
#import "GalleryViewController.h"
#import "OTRConstants.h"

@implementation PopupChoosePicture
@synthesize delegate, _optionsTbView, _tapGesture, _listOptions, _listTitle;
@synthesize _typePopup;

#pragma mark - my view functions
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // My code
        self.backgroundColor = UIColor.whiteColor;
        self.layer.borderWidth = 3.0;
        self.layer.borderColor = [UIColor colorWithRed:(24/255.0) green:(185/255.0)
                                                  blue:(153/255.0) alpha:1.0].CGColor;
        
        _optionsTbView  = [[UITableView alloc] initWithFrame:CGRectMake(3, 3, frame.size.width-6, frame.size.height-6)];
        _optionsTbView.delegate = self;
        _optionsTbView.dataSource = self;
        _optionsTbView.scrollEnabled = NO;
        _optionsTbView.backgroundColor = UIColor.clearColor;
        _optionsTbView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview: _optionsTbView];
    }
    return self;
}

- (void)dealloc{
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
    self.alpha = 0;
    CGRect oldRect = CGRectMake(-(SCREEN_WIDTH-self.frame.size.width)/2, (SCREEN_HEIGHT-self.frame.size.height)/2, self.frame.size.width, self.frame.size.height);
    self.frame = oldRect;
    CGRect newRect = CGRectMake((SCREEN_WIDTH-self.frame.size.width)/2, (SCREEN_HEIGHT-self.frame.size.height)/2, self.frame.size.width, self.frame.size.height);
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = newRect;
        self.alpha = 1;
    }];
}

- (void)fadeOut {
    for (UIView *subView in self.window.subviews)
    {
        if (subView.tag == 20)
        {
            [subView removeFromSuperview];
        }
    }
    CGRect oldRect = CGRectMake((SCREEN_WIDTH-self.frame.size.width), (SCREEN_HEIGHT-self.frame.size.height)/2, self.frame.size.width, self.frame.size.height);
    [UIView animateWithDuration:0.25 animations:^{
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

/* Xử lý đóng màn hình khi click ra ngoài */
- (void)closePopupViewWhenTagOut{
    [self fadeOut];
    [self.superview removeGestureRecognizer:_tapGesture];
}

#pragma mark - tableview delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _listOptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    //set background khi click vào cell
    UIView *selected_bg = [[UIView alloc] init];
    selected_bg.backgroundColor = [UIColor colorWithRed:(223/255.0) green:(255/255.0)
                                                   blue:(133/255.0) alpha:1];
    cell.selectedBackgroundView = selected_bg;
    
    UIView *sepaView = [[UIView alloc] initWithFrame:CGRectMake(0, 39, self.frame.size.width, 1)];
    sepaView.backgroundColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0) blue:(220/255.0) alpha:1.0];
    [cell addSubview: sepaView];
    
    cell.textLabel.font = [AppUtils fontRegularWithSize: 14.0];
    cell.textLabel.textColor = UIColor.grayColor;
    cell.textLabel.text = [_listOptions objectAtIndex: indexPath.row];
    cell.imageView.image = [UIImage imageNamed:[_listTitle objectAtIndex: indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_typePopup == 1) {
        int typeChoose = (int)indexPath.row;
        switch (typeChoose) {
            case chooseGallery:{
                [self fadeOut];
                [[PhoneMainView instance] changeCurrentView:[GalleryViewController compositeViewDescription]];
                break;
            }
            case chooseCamera:{
                [self fadeOut];
                [[NSNotificationCenter defaultCenter] postNotificationName:k11ChooseTakePhoto object:nil];
                break;
            }
        }
    }else{
        int typeChoose = (int)indexPath.row;
        switch (typeChoose) {
            case chooseGallery:{
                [self fadeOut];
                [[NSNotificationCenter defaultCenter] postNotificationName:k11ChooseGalleryVideo object:nil];
                break;
            }
            case chooseCamera:{
                [self fadeOut];
                [[NSNotificationCenter defaultCenter] postNotificationName:k11ChooseRecordVideo object:nil];
                break;
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40.0;
}

@end
