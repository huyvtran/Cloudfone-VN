//
//  EmotionView.m
//  linphone
//
//  Created by mac book on 20/4/15.
//
//

#import "EmotionView.h"
#import "EmotionCell.h"

@interface EmotionView (){
    UICollectionView *recentCollection;
    UICollectionView *faceCollection;
    UICollectionView *flowerCollection;
    UICollectionView *ringCollection;
    UICollectionView *otoCollection;
    UICollectionView *symbolCollection;
    
    float hTabEmotion;
    int currentEmotion;
    
    BOOL pageControlBeingUsed;
    int tagChoose;
    
    float hView;
    float wEmotionIcon;
    float margin;
}

@end

@implementation EmotionView

@synthesize _tabEmotion, _iconRecent, _iconFace, _iconNature, _iconObject, _iconPlace, _iconSymbol, _iconDelete, _scrollView, _pageControl;
@synthesize _numOfView, _listRecentEmotion;

- (void)setupBackgroundUIForView {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMessageTextViewInfo:)
                                                 name:getContentChatMessageViewInfo object:nil];
    
    // recent emotion list
    _listRecentEmotion = [[NSMutableArray alloc] init];
    if ([[NSUserDefaults standardUserDefaults] objectForKey: recentEmotionDict] == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:_listRecentEmotion forKey: recentEmotionDict];
    }
    
    hView = 195.0;
    wEmotionIcon = 45.0;
    
    margin = (SCREEN_WIDTH-7*wEmotionIcon)/8;
    
    [_iconRecent setBackgroundImage:[UIImage imageNamed:@"ic_recent_def"]
                           forState:UIControlStateNormal];
    [_iconRecent setBackgroundImage:[UIImage imageNamed:@"ic_recent_act"]
                           forState:UIControlStateSelected];
    
    [_iconFace setBackgroundImage:[UIImage imageNamed:@"ic_emotion_tab_def"]
                         forState:UIControlStateNormal];
    [_iconFace setBackgroundImage:[UIImage imageNamed:@"ic_emotion_tab_act"]
                         forState:UIControlStateSelected];
    
    [_iconNature setBackgroundImage:[UIImage imageNamed:@"ic_flower_def"]
                           forState:UIControlStateNormal];
    [_iconNature setBackgroundImage:[UIImage imageNamed:@"ic_flower_act"]
                           forState:UIControlStateSelected];
    
    [_iconObject setBackgroundImage:[UIImage imageNamed:@"ic_ring_def"]
                           forState:UIControlStateNormal];
    [_iconObject setBackgroundImage:[UIImage imageNamed:@"ic_ring_act"]
                           forState:UIControlStateSelected];
    
    [_iconPlace setBackgroundImage:[UIImage imageNamed:@"ic_oto_def"]
                          forState:UIControlStateNormal];
    [_iconPlace setBackgroundImage:[UIImage imageNamed:@"ic_oto_act"]
                          forState:UIControlStateSelected];
    
    [_iconSymbol setBackgroundImage:[UIImage imageNamed:@"ic_symbols_def"]
                           forState:UIControlStateNormal];
    [_iconSymbol setBackgroundImage:[UIImage imageNamed:@"ic_symbols_act"]
                           forState:UIControlStateSelected];
    
    _iconRecent.tag = emotionRecent;
    [_iconRecent addTarget:self
                    action:@selector(onEmotionTabClicked:)
          forControlEvents:UIControlEventTouchUpInside];
    
    _iconFace.tag = emotionFace;
    [_iconFace addTarget:self
                  action:@selector(onEmotionTabClicked:)
        forControlEvents:UIControlEventTouchUpInside];
    
    _iconNature.tag = emotionFlower;
    [_iconNature addTarget:self
                    action:@selector(onEmotionTabClicked:)
          forControlEvents:UIControlEventTouchUpInside];
    
    _iconObject.tag = emotionRing;
    [_iconObject addTarget:self
                    action:@selector(onEmotionTabClicked:)
          forControlEvents:UIControlEventTouchUpInside];
    
    _iconPlace.tag = emotionOto;
    [_iconPlace addTarget:self
                   action:@selector(onEmotionTabClicked:)
         forControlEvents:UIControlEventTouchUpInside];
    
    _iconSymbol.tag = emotionSymbol;
    [_iconSymbol addTarget:self
                    action:@selector(onEmotionTabClicked:)
          forControlEvents:UIControlEventTouchUpInside];
}

- (void)addContentForEmotionView {
    hTabEmotion = 40.0;
    
    // Emotion mặc định ban đầu
    _iconFace.selected = YES;
    _numOfView = 6;
    
    // Label ngăn cách giữa tab emotion và emotion view
    UILabel *lbSepa = [[UILabel alloc] initWithFrame: CGRectMake(0, hTabEmotion, SCREEN_WIDTH, 1)];
    lbSepa.backgroundColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0) blue:(230/255.0) alpha:1.0];
    [self addSubview: lbSepa];
    
    _pageControl.frame = CGRectMake(0, hView-hTabEmotion-36, SCREEN_WIDTH, 36);
    _pageControl.backgroundColor = UIColor.clearColor;
    _pageControl.hidden = YES;
    [_pageControl addTarget:self
                     action:@selector(doValueChange)
           forControlEvents:UIControlEventValueChanged];
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    
    int scrollX = 0;
    int scrollY = 0;
    
    for (int iCount = 0; iCount < _numOfView; iCount++) {
        switch (iCount) {
            case emotionRecent:{
                UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc]init];
                recentCollection = [[UICollectionView alloc]initWithFrame:CGRectMake(scrollX, scrollY, SCREEN_WIDTH, hView-hTabEmotion-1) collectionViewLayout:layout];
                recentCollection.backgroundColor = [UIColor clearColor];
                [_scrollView addSubview: recentCollection];
                [recentCollection registerNib:[UINib nibWithNibName:@"EmotionCell" bundle:[NSBundle mainBundle]]
                   forCellWithReuseIdentifier:@"EmotionCell"];
                recentCollection.delegate = self;
                recentCollection.dataSource = self;
                
                scrollX += recentCollection.frame.size.width;
                break;
            }
            case emotionFace:{
                UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc]init];
                faceCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(scrollX, scrollY, SCREEN_WIDTH, hView-hTabEmotion-1) collectionViewLayout:layout];
                faceCollection.backgroundColor = [UIColor clearColor];
                [_scrollView addSubview: faceCollection];
                [faceCollection registerNib:[UINib nibWithNibName:@"EmotionCell" bundle:[NSBundle mainBundle]]
                 forCellWithReuseIdentifier:@"EmotionCell"];
                faceCollection.delegate = self;
                faceCollection.dataSource = self;
                
                scrollX += faceCollection.frame.size.width;
                break;
            }
            case emotionFlower:{
                UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc]init];
                flowerCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(scrollX, scrollY, SCREEN_WIDTH, hView-hTabEmotion-1) collectionViewLayout:layout];
                flowerCollection.backgroundColor = [UIColor clearColor];
                [_scrollView addSubview: flowerCollection];
                [flowerCollection registerNib:[UINib nibWithNibName:@"EmotionCell" bundle:[NSBundle mainBundle]]
                   forCellWithReuseIdentifier:@"EmotionCell"];
                flowerCollection.delegate = self;
                flowerCollection.dataSource = self;
                
                scrollX += flowerCollection.frame.size.width;
                break;
            }
            case emotionRing:{
                UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc]init];
                ringCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(scrollX, scrollY, SCREEN_WIDTH, hView-hTabEmotion-1) collectionViewLayout:layout];
                ringCollection.backgroundColor = [UIColor clearColor];
                [_scrollView addSubview: ringCollection];
                [ringCollection registerNib:[UINib nibWithNibName:@"EmotionCell" bundle:[NSBundle mainBundle]]
                 forCellWithReuseIdentifier:@"EmotionCell"];
                ringCollection.delegate = self;
                ringCollection.dataSource = self;
                
                scrollX += ringCollection.frame.size.width;
                break;
            }
            case emotionOto:{
                UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc]init];
                otoCollection = [[UICollectionView alloc]initWithFrame:CGRectMake(scrollX, scrollY, SCREEN_WIDTH, hView-hTabEmotion-1) collectionViewLayout:layout];
                otoCollection.backgroundColor = [UIColor clearColor];
                [_scrollView addSubview: otoCollection];
                [otoCollection registerNib:[UINib nibWithNibName:@"EmotionCell" bundle:[NSBundle mainBundle]]
                forCellWithReuseIdentifier:@"EmotionCell"];
                otoCollection.delegate = self;
                otoCollection.dataSource = self;
                
                scrollX += otoCollection.frame.size.width;
                break;
            }
            case emotionSymbol:{
                UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc]init];
                symbolCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(scrollX, scrollY, SCREEN_WIDTH, hView-hTabEmotion-1) collectionViewLayout:layout];
                symbolCollection.backgroundColor = [UIColor clearColor];
                [_scrollView addSubview: symbolCollection];
                [symbolCollection registerNib:[UINib nibWithNibName:@"EmotionCell" bundle:[NSBundle mainBundle]]
                   forCellWithReuseIdentifier:@"EmotionCell"];
                symbolCollection.delegate = self;
                symbolCollection.dataSource = self;
                
                scrollX += symbolCollection.frame.size.width;
                break;
            }
            default:{
                UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc]init];
                recentCollection = [[UICollectionView alloc]initWithFrame:CGRectMake(scrollX, scrollY, SCREEN_WIDTH, hView-hTabEmotion-1) collectionViewLayout:layout];
                recentCollection.backgroundColor = [UIColor clearColor];
                [_scrollView addSubview: recentCollection];
                [recentCollection registerNib:[UINib nibWithNibName:@"EmotionCell" bundle:[NSBundle mainBundle]]
                   forCellWithReuseIdentifier:@"EmotionCell"];
                recentCollection.delegate = self;
                recentCollection.dataSource = self;
                
                scrollX += recentCollection.frame.size.width;
                break;
            }
        }
    }
    _pageControl.numberOfPages = _numOfView;
    _pageControl.currentPage = 0;
    
    // set list sẽ hiểnt thị đầu tiên là callnex list
    currentEmotion = 1;
    _scrollView.frame = CGRectMake(0, hTabEmotion, SCREEN_WIDTH, hView-hTabEmotion);
    _scrollView.contentSize = CGSizeMake(scrollX, _scrollView.frame.size.height);
    _scrollView.contentOffset = CGPointMake(currentEmotion*SCREEN_WIDTH, 0);
    _scrollView.pagingEnabled = YES;
}

- (void)doValueChange {
    CGRect frame;
    frame.origin.x = _scrollView.frame.size.width * _pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = _scrollView.frame.size;
    [_scrollView scrollRectToVisible:frame animated:YES];
    
    pageControlBeingUsed = YES;
}

//  Sự kiện click vào emotion tab
- (void)onEmotionTabClicked: (UIButton *)sender {
    currentEmotion = (int)sender.tag;
    _pageControl.currentPage = currentEmotion;
    _scrollView.contentOffset = CGPointMake(currentEmotion*SCREEN_WIDTH, 0);
    [self changeActiveTabEmotion: currentEmotion];
}

- (void)getMessageTextViewInfo: (NSNotification *)notif {
    id object = [notif object];
    if ([object isKindOfClass:[NSDictionary class]]) {
        int curLocation = [[object objectForKey:@"location"] intValue];
        NSMutableString *curTextMessage = [object objectForKey:@"message"];
        
        NSDictionary *dict = [[NSDictionary alloc] init];
        switch (currentEmotion) {
            case 0:
                dict = [_listRecentEmotion objectAtIndex: tagChoose];
                break;
            case 1:
                dict = [[LinphoneAppDelegate sharedInstance]._listFace objectAtIndex: tagChoose];
                break;
            case 2:
                dict = [[LinphoneAppDelegate sharedInstance]._listNature objectAtIndex: tagChoose];
                break;
            case 3:
                dict = [[LinphoneAppDelegate sharedInstance]._listObject objectAtIndex: tagChoose];
                break;
            case 4:
                dict = [[LinphoneAppDelegate sharedInstance]._listPlace objectAtIndex: tagChoose];
                break;
            case 5:
                dict = [[LinphoneAppDelegate sharedInstance]._listSymbol objectAtIndex: tagChoose];
                break;
        }
        
        NSString *k11Str = [dict objectForKey:@"u_code"];
        NSString *totalStr = [NSString stringWithFormat:@"{\"emoji\":\"%@\"}", k11Str];
        
        const char *jsonString = [totalStr UTF8String];
        NSData *jsonData = [NSData dataWithBytes:jsonString length:strlen(jsonString)];
        NSError *error;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        NSString *str = [jsonDict objectForKey:@"emoji"];
        [curTextMessage insertString:str atIndex: curLocation];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:mapContentForMessageTextView
                                                            object:curTextMessage];
        
        // Lưu emotion vào recent tab nếu emotion chưa tồn tại
        NSString *currentImage = [dict objectForKey:@"image"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"image LIKE[cd] %@", currentImage];
        NSArray *filter = [_listRecentEmotion filteredArrayUsingPredicate: predicate];
        if (filter.count == 0) {
            [_listRecentEmotion insertObject:dict atIndex:0];
            [[NSUserDefaults standardUserDefaults] setObject:_listRecentEmotion forKey: recentEmotionDict];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

#pragma mark - UICollection View
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (collectionView == recentCollection) {
        return [_listRecentEmotion count];
    }else if (collectionView == faceCollection){
        return [[LinphoneAppDelegate sharedInstance]._listFace count];
    }else if (collectionView == flowerCollection){
        return [[LinphoneAppDelegate sharedInstance]._listNature count];
    }else if (collectionView == ringCollection){
        return [[LinphoneAppDelegate sharedInstance]._listObject count];
    }else if(collectionView == otoCollection){
        return [[LinphoneAppDelegate sharedInstance]._listPlace count];
    }else{
        return [[LinphoneAppDelegate sharedInstance]._listSymbol count];
    }
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = nil;
    static NSString *cellIdentifier = @"EmotionCell";
    EmotionCell *cell = (EmotionCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if (collectionView == recentCollection) {
        NSArray *emoUserArr = [[NSUserDefaults standardUserDefaults] objectForKey: recentEmotionDict];
        dict = [emoUserArr objectAtIndex: indexPath.row];
    }else if (collectionView == faceCollection){
        dict = [[LinphoneAppDelegate sharedInstance]._listFace objectAtIndex: indexPath.row];
    }else if (collectionView == flowerCollection){
        dict = [[LinphoneAppDelegate sharedInstance]._listNature objectAtIndex: indexPath.row];
    }else if (collectionView == ringCollection){
        dict = [[LinphoneAppDelegate sharedInstance]._listObject objectAtIndex: indexPath.row];
    }else if (collectionView == otoCollection){
        dict = [[LinphoneAppDelegate sharedInstance]._listPlace objectAtIndex: indexPath.row];
    }else{
        dict = [[LinphoneAppDelegate sharedInstance]._listSymbol objectAtIndex: indexPath.row];
    }
    
    NSString *k11Str = [dict objectForKey:@"u_code"];
    NSString *totalStr = [NSString stringWithFormat:@"{\"emoji\":\"%@\"}", k11Str];
    const char *jsonString = [totalStr UTF8String];
    
    NSData *jsonData = [NSData dataWithBytes:jsonString length:strlen(jsonString)];
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    NSString *str = [jsonDict objectForKey:@"emoji"];
    
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, wEmotionIcon, wEmotionIcon);
    cell.btnEmotion.frame = CGRectMake(0, 0, wEmotionIcon, wEmotionIcon);
    cell.btnEmotion.titleEdgeInsets = UIEdgeInsetsMake(6, 4, 0, 0);
    cell.btnEmotion.tag = indexPath.row;
    [cell.btnEmotion setTitle:str forState:UIControlStateNormal];
    [cell.btnEmotion addTarget:self
                        action:@selector(onIconEmotionClicked:)
              forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

//  Click trên icon emotion
- (void)onIconEmotionClicked: (id)sender {
    // Lấy ảnh emotion
    tagChoose = (int)[(UIButton*)sender tag];
    
    // Lấy vị trí cursor của _chatMessageTextView
    [[NSNotificationCenter defaultCenter] postNotificationName:getTextViewMessageChatInfo
                                                        object:nil];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(wEmotionIcon, wEmotionIcon);
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(margin/2, margin, margin/2, margin); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return margin;
}

#pragma mark - UIScrollView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    pageControlBeingUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int page = (int)_pageControl.currentPage;
    currentEmotion = page;
    pageControlBeingUsed = NO;
    [self changeActiveTabEmotion: currentEmotion];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    if (!pageControlBeingUsed) {
        // Switch the indicator when more than 50% of the previous/next page is visible
        CGFloat pageWidth = _scrollView.frame.size.width;
        int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        _pageControl.currentPage = page;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _pageControl.currentPage = page;
}

- (void)changeActiveTabEmotion: (int)emotionActive {
    switch (emotionActive) {
        case emotionRecent:{
            _iconRecent.selected = YES;
            _iconFace.selected = NO;
            _iconNature.selected = NO;
            _iconObject.selected = NO;
            _iconPlace.selected = NO;
            _iconSymbol.selected = NO;
            [recentCollection reloadData];
            break;
        }
        case emotionFace:{
            _iconRecent.selected = NO;
            _iconFace.selected = YES;
            _iconNature.selected = NO;
            _iconObject.selected = NO;
            _iconPlace.selected = NO;
            _iconSymbol.selected = NO;
            break;
        }
        case emotionFlower:{
            _iconRecent.selected = NO;
            _iconFace.selected = NO;
            _iconNature.selected = YES;
            _iconObject.selected = NO;
            _iconPlace.selected = NO;
            _iconSymbol.selected = NO;
            break;
        }
        case emotionRing:{
            _iconRecent.selected = NO;
            _iconFace.selected = NO;
            _iconNature.selected = NO;
            _iconObject.selected = YES;
            _iconPlace.selected = NO;
            _iconSymbol.selected = NO;
            break;
        }
        case emotionOto:{
            _iconRecent.selected = NO;
            _iconFace.selected = NO;
            _iconNature.selected = NO;
            _iconObject.selected = NO;
            _iconPlace.selected = YES;
            _iconSymbol.selected = NO;
            
            break;
        }
        case emotionSymbol:{
            _iconRecent.selected = NO;
            _iconFace.selected = NO;
            _iconNature.selected = NO;
            _iconObject.selected = NO;
            _iconPlace.selected = NO;
            _iconSymbol.selected = YES;
            break;
        }
    }
}

- (void)updateFrameForView {
    float marginY = 8.5;
    float wIcon = (hTabEmotion - 2*marginY);
    float marginX = (self.frame.size.width - 7*wIcon)/8;
    _iconRecent.frame = CGRectMake(marginX, marginY, wIcon, wIcon);
    _iconFace.frame = CGRectMake(_iconRecent.frame.origin.x+wIcon+marginX, _iconRecent.frame.origin.y, wIcon, wIcon);
    _iconNature.frame = CGRectMake(_iconFace.frame.origin.x+wIcon+marginX, _iconFace.frame.origin.y, wIcon, wIcon);
    _iconObject.frame = CGRectMake(_iconNature.frame.origin.x+wIcon+marginX, _iconNature.frame.origin.y, wIcon, wIcon);
    _iconPlace.frame = CGRectMake(_iconObject.frame.origin.x+wIcon+marginX, _iconObject.frame.origin.y, wIcon, wIcon);
    _iconSymbol.frame = CGRectMake(_iconPlace.frame.origin.x+wIcon+marginX, _iconPlace.frame.origin.y, wIcon, wIcon);
    _iconDelete.frame = CGRectMake(_iconSymbol.frame.origin.x+wIcon+marginX, _iconSymbol.frame.origin.y, wIcon, wIcon);
}


@end
