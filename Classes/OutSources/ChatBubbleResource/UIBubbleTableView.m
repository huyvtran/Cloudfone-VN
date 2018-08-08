//
//  UIBubbleTableView.m
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import "UIBubbleTableView.h"
#import "KContactDetailViewController.h"
#import "ChatPictureViewController.h"
#import "PlayVideoViewController.h"

#import "NSBubbleData.h"
#import "UIBubbleHeaderTableViewCell.h"
#import "UIBubbleTypingTableViewCell.h"
#import "OTRConstants.h"
#import "PhoneMainView.h"

//  Popup khi click vao link hay phone
#import "SettingItem.h"
#import "NSDatabase.h"

@interface UIBubbleTableView (){
    // Popup for link message
    MessageLinkPopup *viewOptionsPopup;
    NSMutableArray *listOptions;
    int typeLink;
}

@end

@implementation UIBubbleTableView

@synthesize bubbleDataSource = _bubbleDataSource;
@synthesize snapInterval = _snapInterval;
@synthesize bubbleSection;
@synthesize bubbleData;
@synthesize typingBubble = _typingBubble;
@synthesize showAvatars = _showAvatars;

#pragma mark - Initializators

- (void)initializator
{
    // UITableView properties
    
    self.backgroundColor = [UIColor clearColor];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    assert(self.style == UITableViewStylePlain);
    
    self.delegate = self;
    self.dataSource = self;
    
    // UIBubbleTableView default properties
    
    self.snapInterval = 120;
    self.typingBubble = NSBubbleTypingTypeNobody;
    
    listOptions = [[NSMutableArray alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) [self initializator];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) [self initializator];
    //Notification lấy danh sách rows đang được visible từ view chat
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getRowsVisibleInViewChat)
                                                 name:getRowsVisibleViewChat object:nil];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) [self initializator];
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    if (self) [self initializator];
    return self;
}

#if !__has_feature(objc_arc)
- (void)dealloc
{
    [bubbleSection release];
	bubbleSection = nil;
	_bubbleDataSource = nil;
    [bubbleData release];
    bubbleData = nil;
    [super dealloc];
}
#endif

#pragma mark - Override

- (void)reloadData
{
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    
    // Cleaning up
	self.bubbleSection = nil;
    self.bubbleData = nil;
    
    // Loading new data
    int count = 0;
#if !__has_feature(objc_arc)
    self.bubbleSection = [[[NSMutableArray alloc] init] autorelease];
    self.bubbleData = [[[NSMutableArray alloc] init] autorelease];
#else
    self.bubbleSection = [[NSMutableArray alloc] init];
    self.bubbleData = [[NSMutableArray alloc] init];
#endif
    
    if (self.bubbleDataSource && (count = (int)[self.bubbleDataSource rowsForBubbleTable:self]) > 0)
    {
#if !__has_feature(objc_arc)
        self.bubbleData = [[[NSMutableArray alloc] initWithCapacity:count] autorelease];
#else
        self.bubbleData = [[NSMutableArray alloc] initWithCapacity:count];
#endif
        
        for (int i = 0; i < count; i++)
        {
            NSObject *object = [self.bubbleDataSource bubbleTableView:self dataForRow:i];
            assert([object isKindOfClass:[NSBubbleData class]]);
            [bubbleData addObject:object];
        }
        
//        [_bubbleData sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
//         {
//             NSBubbleData *bubbleData1 = (NSBubbleData *)obj1;
//             NSBubbleData *bubbleData2 = (NSBubbleData *)obj2;
//             
//             return [bubbleData1.date compare:bubbleData2.date];            
//         }];
    }
    [super reloadData];
}

#pragma mark - UITableViewDelegate implementation

#pragma mark - UITableViewDataSource implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Num rows: %ld", (unsigned long)bubbleData.count);
    return bubbleData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSBubbleData *data = [bubbleData objectAtIndex:indexPath.row];
    if ([data.typeMessage isEqualToString: descriptionMessage]) {
        return 25.0;
    }else{
        if ([data.typeMessage isEqualToString: imageMessage] || [data.typeMessage isEqualToString: videoMessage] || [data.typeMessage isEqualToString: locationMessage]) {
            return data.view.frame.size.height+8;
        }else{
            return data.view.frame.size.height+8;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Standard bubble    
    static NSString *cellId = @"tblBubbleCell";
    UIBubbleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    NSBubbleData *data = (NSBubbleData *)[bubbleData objectAtIndex: indexPath.row];
    if (cell == nil) {
        cell = [[UIBubbleTableViewCell alloc] init];
    }
    cell.tag = indexPath.row;
    
    // Add su kien touch va giu vao buble
    UILongPressGestureRecognizer *longPressTap =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(whenLongTouchOnMessage:)];
    longPressTap.minimumPressDuration = 1.0;
    cell.data = data;
    if (![cell.data.typeMessage isEqualToString: descriptionMessage]) {
        [cell.data.view setTag: indexPath.row];
        [cell.data.view setUserInteractionEnabled: true];
        [cell.data.view addGestureRecognizer: longPressTap];
        // [cell addGestureRecognizer: longPressTap];
    }
    
    // Kiểm tra tin nhắn trước đó có phải của mình hay không?
    if (data.isGroup) {
        if (indexPath.row > 0) {
            NSBubbleData *prevMessage = [bubbleData objectAtIndex: indexPath.row-1];
            if (data.type == prevMessage.type) {
                if ([data.userName isEqualToString:prevMessage.userName]) {
                    cell.showAvatar = NO;
                }else{
                    cell.showAvatar = YES;
                }
            }else{
                cell.showAvatar = YES;
            }
        }else{
            cell.showAvatar = YES;
        }
    }else{
        if (indexPath.row > 0) {
            NSBubbleData *prevMessage = [bubbleData objectAtIndex: indexPath.row-1];
            if (data.type == prevMessage.type) {
                cell.showAvatar = NO;
            }else{
                cell.showAvatar = YES;
            }
        }else{
            cell.showAvatar = YES;
        }
    }
    
    if (cell.data != nil) {
        // Gắn action đối với các tin nhắn có chức năng xem
        if ([cell.data.typeMessage isEqualToString: imageMessage])
        {
            // Nếu có expire time touch và hold mới xem được
            UIButton *buttonBg = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, cell.data.view.frame.size.width, cell.data.view.frame.size.height)];
            [buttonBg setBackgroundColor:[UIColor clearColor]];
            [buttonBg.titleLabel setText: cell.data.idMessage];
            [buttonBg setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
            [buttonBg addTarget:self action:@selector(clickToViewPicture:) forControlEvents:UIControlEventTouchUpInside];
            [cell.data.view addSubview: buttonBg];
        }else if ([cell.data.typeMessage isEqualToString: videoMessage])
        {
            UIButton *buttonBg = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, cell.data.view.frame.size.width, cell.data.view.frame.size.height)];
            [buttonBg setBackgroundColor:[UIColor clearColor]];
            [buttonBg.titleLabel setText: cell.data.idMessage];
            [buttonBg setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
            [buttonBg addTarget:self action:@selector(clickToViewVideo:) forControlEvents:UIControlEventTouchUpInside];
            [cell.data.view addSubview: buttonBg];
        }else if ([cell.data.typeMessage isEqualToString: contactMessage])
        {
            // Gắn sự kiện view contact đối với contact message mình send
            UIButton *buttonBg = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, cell.data.view.frame.size.width, cell.data.view.frame.size.height)];
            [buttonBg setBackgroundColor:[UIColor clearColor]];
            [buttonBg.titleLabel setText: cell.data.idMessage];
            [buttonBg setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
            if (cell.data.type == BubbleTypeMine) {
                [buttonBg addTarget:self
                             action:@selector(clickOnContactMessage:)
                   forControlEvents:UIControlEventTouchUpInside];
            }else{
                [buttonBg addTarget:self
                             action:@selector(addContactMessage:)
                   forControlEvents:UIControlEventTouchUpInside];
            }
            [cell.data.view addSubview: buttonBg];
        }
    }
    return cell;
}

//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSInteger lastSectionIndex = [tableView numberOfSections] - 1;
//    NSInteger lastRowIndex = [tableView numberOfRowsInSection:lastSectionIndex] - 1;
//    if ((indexPath.section == lastSectionIndex) && (indexPath.row == lastRowIndex)) {
//        // This is the last cell
//        [[NSNotificationCenter defaultCenter] postNotificationName:k11GetCurrentNumberMessage
//                                                            object:nil];
//    }
//}

//  Sự kiện thả nút ghi âm
- (void)finishDragged: (UIButton *)button withEvent: (UIEvent *)event{
    NSLog(@"Da tha ra");
}

// Lấy id của tin nhắn hình ảnh khi click vào hình
- (void)clickToViewPicture: (UIButton *)button {
    ChatPictureViewController *controller = VIEW(ChatPictureViewController);
    if (controller != nil) {
        [controller set_curIdPicture: [button.titleLabel text]];
        [controller updateImageAfterReceiveIdPicture];
    }
    [[PhoneMainView instance] changeCurrentView:[ChatPictureViewController compositeViewDescription] push:TRUE];
}

- (void)clickToViewVideo: (UIButton *)button{
    [LinphoneAppDelegate sharedInstance].idVideoMessage = [button.titleLabel text];
    [[PhoneMainView instance] changeCurrentView:[PlayVideoViewController compositeViewDescription] push:TRUE];
}

// Sự kiện click vào contact mình đã send
- (void)clickOnContactMessage: (UIButton *)button{
    NSString *messageId = [button.titleLabel text];
    NSString *extra = [NSDatabase getExtraOfMessageWithMessageId: messageId];
    if (![extra isEqualToString:@""]) {
        [LinphoneAppDelegate sharedInstance].idContact = [extra intValue];
        [[PhoneMainView instance] changeCurrentView:[KContactDetailViewController compositeViewDescription] push:TRUE];
    }
}

// Click vao contact tren Bubble nhan duoc
- (void)addContactMessage: (UIButton *)button
{
    NSString *idMessage = [button.titleLabel text];
    [[NSNotificationCenter defaultCenter] postNotificationName:k11ShowPopupAddContactOnBubble object:idMessage];
}

//  Touch và giữ vào message
- (void)whenLongTouchOnMessage:(UILongPressGestureRecognizer *)lpt
{
    if (lpt.state == UIGestureRecognizerStateBegan) {
        NSNumber *numTag = [[NSNumber alloc] initWithInt: (int)lpt.view.tag];
        
        UIBubbleTableViewCell *cell = (UIBubbleTableViewCell *)[[lpt.view superview] superview];
        
        if (cell.data.type == BubbleTypeSomeoneElse) {
            [LinphoneAppDelegate sharedInstance].typeBubbleTouch = BubbleTypeSomeoneElse;
        }else{
            [LinphoneAppDelegate sharedInstance].typeBubbleTouch = BubbleTypeMine;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:k11TouchOnMessage object:numTag];
    }
}

#pragma mark - Public interface

- (void) scrollBubbleViewToBottomAnimated:(BOOL)animated
{
    NSInteger lastSectionIdx = [self numberOfSections] - 1;
    
    if (lastSectionIdx >= 0)
    {
    	[self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([self numberOfRowsInSection:lastSectionIdx] - 1) inSection:lastSectionIdx] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

//  Lấy last cell của dòng cuối khi scroll xong
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSArray *tmpArr = [self indexPathsForVisibleRows];
    if (tmpArr.count > 0) {
        NSIndexPath *lastCell = [tmpArr lastObject];
        [[NSNotificationCenter defaultCenter] postNotificationName:k11GetLastRowTableChat object:lastCell];
    }
}

// Hàm get row chuối cùng
- (void)getRowsVisibleInViewChat{
    NSArray *tmpArr = [self indexPathsForVisibleRows];
    if (tmpArr.count > 0) {
        [LinphoneAppDelegate sharedInstance].lastRowVisibleChat = [tmpArr lastObject];
    }else{
        [LinphoneAppDelegate sharedInstance].lastRowVisibleChat = nil;
    }
}

//  Hàm tạo dữ liệu khi click vào link hay phone number
- (void)createDataForPhoneNumber: (BOOL)isPhoneNumber andLink: (BOOL)isLink isMail: (BOOL)isMail{
    listOptions = [[NSMutableArray alloc] init];
    
    SettingItem *item = [[SettingItem alloc] init];
    item._imageStr = @"ic_copy_message.png";
    item._valueStr = @"Copy";
    [listOptions addObject: item];
    
    if (isPhoneNumber) {
        item = [[SettingItem alloc] init];
        item._imageStr = @"ic_call_message.png";
        item._valueStr = @"Call";
        [listOptions addObject: item];
    }else if (isLink){
        item = [[SettingItem alloc] init];
        item._imageStr = @"ic_open_page.png";
        item._valueStr = @"Open";
        [listOptions addObject: item];
    }else{
        item = [[SettingItem alloc] init];
        item._imageStr = @"ic_send_email.png";
        item._valueStr = @"Mail to";
        [listOptions addObject: item];
    }
}

//  Nếu tổng số msg lớn hơn lastrow thì load lại
- (void)currentAllMessageForLastRow: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[NSNumber class]]) {
        int allMessage = [object intValue];
        NSInteger lastSectionIndex = [self numberOfSections] - 1;
        NSInteger lastRowIndex = [self numberOfRowsInSection:lastSectionIndex] - 1;
        if (lastRowIndex < allMessage-1) {
            //[self reloadData];
            //[self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(allMessage-1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:k11UpdateAndHideLbNewMessage object:nil];
        }
    }
}

@end
