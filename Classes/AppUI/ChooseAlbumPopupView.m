//
//  ChooseAlbumPopupView.m
//  linphone
//
//  Created by Ei Captain on 4/11/17.
//
//

#import "ChooseAlbumPopupView.h"
#import "AlbumCell.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation ChooseAlbumPopupView
@synthesize _tbContent, _tapGesture;
@synthesize _listAlbum, _hCell, _curName;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame: frame];
    if (self) {
        
        // Initialization code
        self.layer.borderWidth = 3.0;
        self.layer.borderColor = [UIColor colorWithRed:(23/255.0) green:(184/255.0)
                                                  blue:(151/255.0) alpha:1.0].CGColor;
        _hCell = 50.0;
        
        _tbContent = [[UITableView alloc] initWithFrame: CGRectMake(3, 3, frame.size.width-6, frame.size.height-6)];
        _tbContent.delegate = self;
        _tbContent.dataSource = self;
        _tbContent.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tbContent.scrollEnabled = NO;
        
        [self addSubview: _tbContent];
    }
    return self;
}

- (void)showInView:(UIView *)aView animated:(BOOL)animated {
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopupViewWhenTagOut)];
    UIView *viewBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    viewBackground.backgroundColor = UIColor.blackColor;
    viewBackground.alpha = 0.5;
    viewBackground.tag = 20;
    [aView addSubview:viewBackground];
    
    [viewBackground addGestureRecognizer:_tapGesture];
    
    [aView addSubview:self];
    if (animated) {
        [self fadeIn];
    }
}

- (void)fadeIn {
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1, 1);
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
    
    [UIView animateWithDuration:.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
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


#pragma mark - UITableview Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_listAlbum count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"AlbumCell";
    AlbumCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"AlbumCell" owner:self options:nil];
        cell = topLevelObjects[0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, _tbContent.frame.size.width, _hCell);
    [cell setupUIForCell];
    
    ALAssetsGroup *groupForCell = _listAlbum[indexPath.row];
    CGImageRef posterImageRef = [groupForCell posterImage];
    UIImage *posterImage = [UIImage imageWithCGImage:posterImageRef];
    cell._imgGroup.image = posterImage;
    cell._lbName.text = [groupForCell valueForProperty:ALAssetsGroupPropertyName];
    
    if ([[groupForCell valueForProperty:ALAssetsGroupPropertyName] isEqualToString: _curName]) {
        cell._cbSelect.on = YES;
    }else{
        cell._cbSelect.on = NO;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self fadeOut];
    ALAssetsGroup *assetsGroup = [_listAlbum objectAtIndex: indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:chooseOtherAlbumForSent
                                                        object:assetsGroup];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _hCell;
}

@end
