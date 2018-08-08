#import "SwipeableTableViewCell.h"

NSString *const kSwipeableTableViewCellCloseEvent = @"SwipeableTableViewCellClose";
CGFloat const kSwipeableTableViewCellMaxCloseMilliseconds = 300;
CGFloat const kSwipeableTableViewCellOpenVelocityThreshold = 0.6;

@interface SwipeableTableViewCell (){
    UIFont *textFont;
    UIFont *textFontBold;
}

@property (nonatomic) NSArray *buttonViews;

@end

@implementation SwipeableTableViewCell
@synthesize _iconAvatar, _lbTitle, _lbTime, _lbContent, _lbSepa, _imgState, _imgBlock, _btnTop, _iconUnread;
@synthesize _isGroup, _idContact, _cloudFoneID;
@synthesize _btnDelete, _btnCall, _btnMute, _cbDelete;

#pragma mark Lifecycle methods

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUp];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) [self setUp];
    return self;
}

#pragma mark Public class methods

+ (void)closeAllCells {
    [self closeAllCellsExcept:nil];
}

+ (void)closeAllCellsExcept:(SwipeableTableViewCell *)cell {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSwipeableTableViewCellCloseEvent object:cell];
}

#pragma mark Public properties

- (BOOL)closed {
    return CGPointEqualToPoint(self.scrollView.contentOffset, CGPointZero);
}

- (CGFloat)leftInset {
    UIView *view = self.buttonViews[SwipeableTableViewCellSideLeft];
    return view.bounds.size.width;
}

- (CGFloat)rightInset {
    UIView *view = self.buttonViews[SwipeableTableViewCellSideRight];
    return view.bounds.size.width;
}

#pragma mark Public methods

- (void)close {
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

- (UIButton *)createButtonWithWidth:(CGFloat)width onSide:(SwipeableTableViewCellSide)side {
    UIView *container = self.buttonViews[side];
    CGSize size = container.bounds.size;

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    button.frame = CGRectMake(size.width, 0, width, size.height);

    // Resize the container to fit the new button.
    CGFloat x;
    switch (side) {
        case SwipeableTableViewCellSideLeft:
            x = -(size.width + width);
            break;
        case SwipeableTableViewCellSideRight:
            x = self.contentView.bounds.size.width;
            break;
    }
    container.frame = CGRectMake(x, 0, size.width + width, size.height);
    [container addSubview:button];

    // Update the scrollable areas outside the scroll view to fit the buttons.
    self.scrollView.contentInset = UIEdgeInsetsMake(0, self.leftInset, 0, self.rightInset);

    return button;
}

- (UIButton *)createButtonDeleteWithWidth:(CGFloat)width onSide:(SwipeableTableViewCellSide)side {
    UIView *container = self.buttonViews[side];
    CGSize size = container.bounds.size;
    
    _btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnDelete.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _btnDelete.frame = CGRectMake(size.width, 0, width, size.height);
    
    // Resize the container to fit the new button.
    CGFloat x;
    switch (side) {
        case SwipeableTableViewCellSideLeft:
            x = -(size.width + width);
            break;
        case SwipeableTableViewCellSideRight:
            x = self.contentView.bounds.size.width;
            break;
    }
    container.frame = CGRectMake(x, 0, size.width + width, size.height);
    [container addSubview:_btnDelete];
    
    // Update the scrollable areas outside the scroll view to fit the buttons.
    self.scrollView.contentInset = UIEdgeInsetsMake(0, self.leftInset, 0, self.rightInset);
    
    return _btnDelete;
}

- (UIButton *)createButtonMuteWithWidth:(CGFloat)width onSide:(SwipeableTableViewCellSide)side {
    UIView *container = self.buttonViews[side];
    CGSize size = container.bounds.size;
    
    _btnMute = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnMute.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _btnMute.frame = CGRectMake(size.width, 0, width, size.height);
    
    // Resize the container to fit the new button.
    CGFloat x;
    switch (side) {
        case SwipeableTableViewCellSideLeft:
            x = -(size.width + width);
            break;
        case SwipeableTableViewCellSideRight:
            x = self.contentView.bounds.size.width;
            break;
    }
    container.frame = CGRectMake(x, 0, size.width + width, size.height);
    [container addSubview:_btnMute];
    
    // Update the scrollable areas outside the scroll view to fit the buttons.
    self.scrollView.contentInset = UIEdgeInsetsMake(0, self.leftInset, 0, self.rightInset);
    
    return _btnMute;
}

- (UIButton *)createButtonCallWithWidth:(CGFloat)width onSide:(SwipeableTableViewCellSide)side {
    UIView *container = self.buttonViews[side];
    CGSize size = container.bounds.size;
    
    _btnCall = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnCall.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _btnCall.frame = CGRectMake(size.width, 0, width, size.height);
    
    // Resize the container to fit the new button.
    CGFloat x;
    switch (side) {
        case SwipeableTableViewCellSideLeft:
            x = -(size.width + width);
            break;
        case SwipeableTableViewCellSideRight:
            x = self.contentView.bounds.size.width;
            break;
    }
    container.frame = CGRectMake(x, 0, size.width + width, size.height);
    [container addSubview:_btnCall];
    
    // Update the scrollable areas outside the scroll view to fit the buttons.
    self.scrollView.contentInset = UIEdgeInsetsMake(0, self.leftInset, 0, self.rightInset);
    
    return _btnCall;
}

- (void)openSide:(SwipeableTableViewCellSide)side {
    [self openSide:side animated:YES];
}

- (void)openSide:(SwipeableTableViewCellSide)side animated:(BOOL)animate {
    [[self class] closeAllCellsExcept:self];
    switch (side) {
        case SwipeableTableViewCellSideLeft:
            [self.scrollView setContentOffset:CGPointMake(-self.leftInset, 0) animated:animate];
            break;
        case SwipeableTableViewCellSideRight:
            [self.scrollView setContentOffset:CGPointMake(self.rightInset, 0) animated:animate];
            break;
    }
}

#pragma mark Private methods

- (UIView *)createButtonsView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.contentView.bounds.size.height)];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.scrollView addSubview:view];
    return view;
}

- (void)handleCloseEvent:(NSNotification *)notification {
    if (notification.object == self) return;
    [self close];
}

- (void)setUp {
    if (SCREEN_WIDTH > 320) {
        textFont = [UIFont fontWithName:HelveticaNeue size: 16.0];
        textFontBold = [UIFont fontWithName:HelveticaNeueBold size: 18.0];
    }else{
        textFont = [UIFont fontWithName:HelveticaNeue size: 14.0];
        textFontBold = [UIFont fontWithName:HelveticaNeueBold size: 16.0];
    }
    
    // Create the scroll view which enables the horizontal swiping.
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.contentSize = self.contentView.bounds.size;
    scrollView.delegate = self;
    scrollView.scrollsToTop = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    [self.contentView addSubview:scrollView];
    self.scrollView = scrollView;

    // Create the containers which will contain buttons on the left and right sides.
    self.buttonViews = @[[self createButtonsView], [self createButtonsView]];

    // Set up main content area.
    UIView *contentView = [[UIView alloc] initWithFrame:scrollView.bounds];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:contentView];
    self.scrollViewContentView = contentView;

    _cbDelete = [[BEMCheckBox alloc] initWithFrame: CGRectMake(10, (self.frame.size.height-20)/2, 20, 20)];
    _cbDelete.lineWidth = 1.0;
    _cbDelete.boxType = BEMBoxTypeCircle;
    _cbDelete.onAnimationType = BEMAnimationTypeStroke;
    _cbDelete.offAnimationType = BEMAnimationTypeStroke;
    _cbDelete.tintColor = [UIColor colorWithRed:(17/255.0) green:(186/255.0)
                                           blue:(153/255.0) alpha:1.0];
    _cbDelete.onTintColor = [UIColor colorWithRed:(17/255.0) green:(186/255.0)
                                             blue:(153/255.0) alpha:1.0];
    _cbDelete.onFillColor = [UIColor colorWithRed:(17/255.0) green:(186/255.0)
                                             blue:(153/255.0) alpha:1.0];
    _cbDelete.onCheckColor = UIColor.whiteColor;
    [_cbDelete setOn:false animated: true];
    _cbDelete.hidden = YES;
    
    [self.scrollViewContentView addSubview: _cbDelete];
    
    //  icon avatar
    _iconAvatar = [[UIImageView alloc] initWithFrame: CGRectMake(5, 5, self.frame.size.height-10, self.frame.size.height-10)];
    _iconAvatar.clipsToBounds = YES;
    _iconAvatar.layer.cornerRadius = (self.frame.size.height-10)/2;
    [self.scrollViewContentView addSubview: _iconAvatar];
    
    //  label title
    _lbTitle = [[UILabel alloc] initWithFrame: CGRectMake(_iconAvatar.frame.origin.x+_iconAvatar.frame.size.width+_iconAvatar.frame.origin.x, _iconAvatar.frame.origin.y, (self.frame.size.width-_iconAvatar.frame.origin.x*3 - _iconAvatar.frame.size.width)/2, _iconAvatar.frame.size.height/3)];
    _lbTitle.font = textFontBold;
    _lbTitle.textColor = [UIColor colorWithRed:(30/255.0) green:(30/255.0)
                                          blue:(30/255.0) alpha:1.0];
    [self.scrollViewContentView addSubview:_lbTitle];
    
    //  label time
    _lbTime = [[UILabel alloc] initWithFrame: CGRectMake(_lbTitle.frame.origin.x+_lbTitle.frame.size.width, _lbTitle.frame.origin.y, _lbTitle.frame.size.width, _lbTitle.frame.size.height)];
    _lbTime.textAlignment = NSTextAlignmentRight;
    _lbTime.font = textFont;
    _lbTime.textColor = [UIColor colorWithRed:(80/255.0) green:(80/255.0)
                                         blue:(80/255.0) alpha:1.0];
    [self.scrollViewContentView addSubview: _lbTime];
    
    //  label content
    _lbContent = [[UILabel alloc] initWithFrame: CGRectMake(_lbTitle.frame.origin.x, _lbTitle.frame.origin.y+_lbTitle.frame.size.height, _lbTitle.frame.size.width*2, _iconAvatar.frame.size.height*2/3)];
    [_lbContent setNumberOfLines: 3.0];
    _lbContent.font = textFont;
    _lbContent.textColor = [UIColor colorWithRed:(80/255.0) green:(80/255.0)
                                         blue:(80/255.0) alpha:1.0];
    [self.scrollViewContentView addSubview: _lbContent];
    
    //  image state
    _imgState = [[UIImageView alloc] init];
    [self.scrollViewContentView addSubview: _imgState];
    
    //  image block
    _imgBlock = [[UIImageView alloc] init];
    _imgBlock.image = [UIImage imageNamed:@"icon-lock.png"];
    [self.scrollViewContentView addSubview: _imgBlock];
    
    //  image block
    _iconUnread = [[UIButton alloc] init];
    [_iconUnread setBackgroundImage:[UIImage imageNamed:@"missed_message_bg.png"]
                           forState:UIControlStateNormal];
    _iconUnread.titleLabel.font = textFont;
    [self.scrollViewContentView addSubview: _iconUnread];
    
    //  button top
    _btnTop = [UIButton buttonWithType: UIButtonTypeCustom];
    [_btnTop addTarget:self
                action:@selector(btnTopTouchDown:)
      forControlEvents:UIControlEventTouchDown];
    [_btnTop addTarget:self
                action:@selector(btnTopPressed:)
      forControlEvents:UIControlEventTouchUpInside];
    
    [self.scrollViewContentView addSubview: _btnTop];
    
    _lbSepa = [[UILabel alloc] initWithFrame: CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1)];
    _lbSepa.backgroundColor = [UIColor colorWithRed:(220/255.0) green:(220/255.0)
                                               blue:(220/255.0) alpha:1.0];
    [self.scrollViewContentView addSubview: _lbSepa];
    
    // Put a label in the scroll view content area.
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(contentView.bounds, 10, 0)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.scrollViewContentView addSubview:label];
    self.scrollViewLabel = label;

    // Listen for events that tell cells to hide their buttons.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleCloseEvent:)
                                                 name:kSwipeableTableViewCellCloseEvent
                                               object:nil];
}

- (void)btnTopTouchDown: (UIButton *)sender {
    self.backgroundColor = UIColor.clearColor;
}

- (void)btnTopPressed: (UIButton *)sender {
    self.backgroundColor = UIColor.clearColor;
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ((self.leftInset == 0 && scrollView.contentOffset.x < 0) || (self.rightInset == 0 && scrollView.contentOffset.x > 0)) {
        scrollView.contentOffset = CGPointZero;
    }

    UIView *leftView = self.buttonViews[SwipeableTableViewCellSideLeft];
    UIView *rightView = self.buttonViews[SwipeableTableViewCellSideRight];
    if (scrollView.contentOffset.x < 0) {
        // Make the left buttons stay in place.
        leftView.frame = CGRectMake(scrollView.contentOffset.x, 0, self.leftInset, leftView.frame.size.height);
        leftView.hidden = NO;
        // Hide the right buttons.
        rightView.hidden = YES;
    } else if (scrollView.contentOffset.x > 0) {
        // Make the right buttons stay in place.
        rightView.frame = CGRectMake(self.contentView.bounds.size.width - self.rightInset + scrollView.contentOffset.x, 0,
                                     self.rightInset, rightView.frame.size.height);
        rightView.hidden = NO;
        // Hide the left buttons.
        leftView.hidden = YES;
    } else {
        leftView.hidden = YES;
        rightView.hidden = YES;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [[self class] closeAllCellsExcept:self];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    CGFloat x = scrollView.contentOffset.x, left = self.leftInset, right = self.rightInset;
    if (left > 0 && (x < -left || (x < 0 && velocity.x < -kSwipeableTableViewCellOpenVelocityThreshold))) {
        targetContentOffset->x = -left;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"openDeleteViewForCell" object:nil];
    } else if (right > 0 && (x > right || (x > 0 && velocity.x > kSwipeableTableViewCellOpenVelocityThreshold))) {
        targetContentOffset->x = right;
    } else {
        *targetContentOffset = CGPointZero;

        // If the scroll isn't on a fast path to zero, animate it instead.
        CGFloat ms = x / -velocity.x;
        if (velocity.x == 0 || ms < 0 || ms > kSwipeableTableViewCellMaxCloseMilliseconds) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [scrollView setContentOffset:CGPointZero animated:YES];
            });
        }
    }
}

#pragma mark UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    // This is necessary to ensure that the content size scales with the view.
    self.scrollView.contentSize = self.contentView.bounds.size;
    self.scrollView.contentOffset = CGPointZero;
}

#pragma mark - my functions
- (void)updateUIForCell
{
    _cbDelete.hidden = YES;
    _cbDelete.frame = CGRectMake(10, (self.frame.size.height-_cbDelete.frame.size.height)/2, _cbDelete.frame.size.height, _cbDelete.frame.size.height);
    _iconAvatar.frame = CGRectMake(7, 7, self.frame.size.height-14, self.frame.size.height-14);
    _iconAvatar.layer.cornerRadius = (self.frame.size.height-14)/2;
    _imgBlock.frame = CGRectMake(_iconAvatar.frame.origin.x+_iconAvatar.frame.size.width-10, _iconAvatar.frame.origin.y+(_iconAvatar.frame.size.height-20)/2, 20, 20);
    
    [_lbTime sizeToFit];
    _lbTime.frame = CGRectMake(self.frame.size.width-_iconAvatar.frame.origin.x-_lbTime.frame.size.width, _iconAvatar.frame.origin.y, _lbTime.frame.size.width, 20);
    _lbTitle.frame = CGRectMake(_imgBlock.frame.origin.x+_imgBlock.frame.size.width+5, _iconAvatar.frame.origin.y, self.frame.size.width-(_imgBlock.frame.origin.x*2+5+_imgBlock.frame.size.width+_lbTime.frame.size.width), _iconAvatar.frame.size.height/2);
    
    _imgState.frame = CGRectMake(self.frame.size.width-40, _lbTime.frame.origin.y+_lbTime.frame.size.height, 40, 40);
    _iconUnread.frame = CGRectMake(_imgState.frame.origin.x-25, _imgState.center.y-30/2, 25, 30);
    [_iconUnread setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    _lbContent.frame = CGRectMake(_lbTitle.frame.origin.x, _lbTitle.frame.origin.y+_lbTitle.frame.size.height, self.frame.size.width-(3*_iconAvatar.frame.origin.x+_iconAvatar.frame.size.width+_imgState.frame.size.width), _iconAvatar.frame.size.height/2);
    
    _btnTop.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _lbSepa.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
}

- (void)showDeleteViewForCell {
    _cbDelete.hidden = NO;
    _cbDelete.frame = CGRectMake(10, (self.frame.size.height-_cbDelete.frame.size.height)/2, _cbDelete.frame.size.height, _cbDelete.frame.size.height);
    
    _iconAvatar.frame = CGRectMake(_cbDelete.frame.origin.x+_cbDelete.frame.size.width+5, 7, self.frame.size.height-14, self.frame.size.height-14);
    _iconAvatar.layer.cornerRadius = (self.frame.size.height-14)/2;
    
    _imgBlock.frame = CGRectMake(_iconAvatar.frame.origin.x+_iconAvatar.frame.size.width-10, _iconAvatar.frame.origin.y+(_iconAvatar.frame.size.height-20)/2, 20, 20);
    
    [_lbTime sizeToFit];
    _lbTime.frame = CGRectMake(self.frame.size.width-(_cbDelete.frame.origin.x+_lbTime.frame.size.width), _iconAvatar.frame.origin.y, _lbTime.frame.size.width, _iconAvatar.frame.size.height/2);
    _lbTitle.frame = CGRectMake(_iconAvatar.frame.origin.x+_iconAvatar.frame.size.width+5, _iconAvatar.frame.origin.y, self.frame.size.width-(_iconAvatar.frame.origin.x+_iconAvatar.frame.size.width+5+_lbTime.frame.size.width+5+_cbDelete.frame.origin.x), _lbTime.frame.size.height);
    
    _imgState.frame = CGRectMake(self.frame.size.width-30, _lbTime.frame.origin.y+_lbTime.frame.size.height, 30, 30);
    _iconUnread.frame = CGRectMake(_imgState.frame.origin.x-25, _imgState.center.y-30/2, 25, 30);
    [_iconUnread setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    _lbContent.frame = CGRectMake(_lbTitle.frame.origin.x, _lbTitle.frame.origin.y+_lbTitle.frame.size.height, self.frame.size.width-(3*_iconAvatar.frame.origin.x+_iconAvatar.frame.size.width+_imgState.frame.size.width), _iconAvatar.frame.size.height/2);
    _btnTop.frame = CGRectMake(_cbDelete.frame.origin.x+_cbDelete.frame.size.width+5, 0, self.frame.size.width-(_cbDelete.frame.origin.x+_cbDelete.frame.size.width+5), self.frame.size.height);
    _lbSepa.frame = CGRectMake(_btnTop.frame.origin.x, self.frame.size.height-1, self.frame.size.width-_btnTop.frame.origin.x, 1);
}

@end
