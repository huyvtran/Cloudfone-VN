//
//  ChatPictureDetailsView.m
//  linphone
//
//  Created by admin on 1/11/18.
//

#import "ChatPictureDetailsView.h"
#import "NSDatabase.h"
#import "ChatDetailImageCollectionCell.h"
#import "UIView+Toast.h"

@implementation ChatPictureDetailsView
@synthesize _clvPictures, _viewTop, _btnClose, _btnMore;
@synthesize _remoteParty, _listPhotos, _idMessageShow, _curIndex, isGroup;

- (void)setupUIForView {
    _viewTop.frame = CGRectMake(0, 0, self.frame.size.width, [LinphoneAppDelegate sharedInstance]._hHeader);
    _viewTop.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    _btnClose.frame = CGRectMake(0, ([LinphoneAppDelegate sharedInstance]._hHeader-35)/2, 100, 35);
    _btnMore.frame = CGRectMake(_viewTop.frame.size.width-35-10, _btnClose.frame.origin.y, 35.0, 35.0);
    
    //  Collection view
    margin = 2.0;
    sizeItem =(self.frame.size.width-8*margin)/3;
    
    UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _clvPictures.collectionViewLayout = layout;
    
    [_clvPictures registerNib:[UINib nibWithNibName:@"ChatDetailImageCollectionCell" bundle:[NSBundle mainBundle]]
   forCellWithReuseIdentifier:@"ChatDetailImageCollectionCell"];
    _clvPictures.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _clvPictures.delegate = self;
    _clvPictures.dataSource = self;
    _clvPictures.showsHorizontalScrollIndicator = NO;
    _clvPictures.pagingEnabled = YES;
    _clvPictures.backgroundColor = [UIColor blackColor];
}

- (void)setupUIForViewForFullScreen {
    
    float hStatusBar = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    _viewTop.frame = CGRectMake(0, 0, self.frame.size.width, hStatusBar+[LinphoneAppDelegate sharedInstance]._hHeader);
    _viewTop.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    _btnClose.frame = CGRectMake(0, hStatusBar+([LinphoneAppDelegate sharedInstance]._hHeader-35)/2, 100, 35);
    _btnMore.frame = CGRectMake(_viewTop.frame.size.width-35-10, _btnClose.frame.origin.y, 35.0, 35.0);
    
    //  Collection view
    margin = 2.0;
    sizeItem =(self.frame.size.width-8*margin)/3;
    
    UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _clvPictures.collectionViewLayout = layout;
    
    [_clvPictures registerNib:[UINib nibWithNibName:@"ChatDetailImageCollectionCell" bundle:[NSBundle mainBundle]]
   forCellWithReuseIdentifier:@"ChatDetailImageCollectionCell"];
    _clvPictures.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _clvPictures.delegate = self;
    _clvPictures.dataSource = self;
    _clvPictures.showsHorizontalScrollIndicator = NO;
    _clvPictures.pagingEnabled = YES;
    _clvPictures.backgroundColor = [UIColor blackColor];
}

- (void)loadListPictureForView {
    if (_listPhotos == nil) {
        _listPhotos = [[NSMutableArray alloc] init];
    }else{
        [_listPhotos removeAllObjects];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if (isGroup) {
            _listPhotos = [NSDatabase getListPictureFromMessageOf:USERNAME withRoomChat:_remoteParty];
        }else{
            _listPhotos = [NSDatabase getListPictureFromMessageOf: USERNAME withRemoteParty: _remoteParty];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_idMessageShow != nil && ![_idMessageShow isEqualToString:@""]) {
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id_message == %@", _idMessageShow];
                NSArray *filter = [_listPhotos filteredArrayUsingPredicate: predicate];
                if (filter.count > 0) {
                    NSDictionary *object = [filter objectAtIndex: 0];
                    _curIndex = (int)[_listPhotos indexOfObject: object];
                    _clvPictures.contentOffset = CGPointMake(_curIndex*_clvPictures.frame.size.width, _clvPictures.frame.origin.y);
                    [self checkBurnForMediaMessage: object];
                }
            }else if (_curIndex >= 0){
                _clvPictures.contentOffset = CGPointMake(_curIndex*_clvPictures.frame.size.width, _clvPictures.frame.origin.y);
                
                NSDictionary *object = [_listPhotos objectAtIndex: _curIndex];
                [self checkBurnForMediaMessage: object];
            }
            [_clvPictures reloadData];
            _clvPictures.hidden = NO;
        });
    });
}

- (void)checkBurnForMediaMessage: (NSDictionary *)messageInfo {
    if (messageInfo == nil) {
        return;
    }
    NSString *typeMessage = [messageInfo objectForKey:@"type_message"];
    int expireTime = [[messageInfo objectForKey:@"expire_time"] intValue];
    NSString *status = [messageInfo objectForKey:@"status"];
    NSString *sendPhone = [messageInfo objectForKey:@"send_phone"];
    NSString *idMessage = [messageInfo objectForKey:@"id_message"];
    
    if (expireTime > 0 && [status isEqualToString:@"NO"] && [sendPhone isEqualToString:_remoteParty]) {
        [[LinphoneAppDelegate sharedInstance].myBuddy.protocol sendDisplayedToUser:_remoteParty fromUser:USERNAME andListIdMsg:idMessage];
        [NSDatabase updateSeenForMessage: idMessage];
        
        if ([typeMessage isEqualToString:imageMessage]) {
            [_listPhotos removeAllObjects];
            _listPhotos = [NSDatabase getListPictureFromMessageOf: USERNAME withRemoteParty: _remoteParty];
        }else if ([typeMessage isEqualToString:videoMessage]){
            [[NSNotificationCenter defaultCenter] postNotificationName:playVideoMessage object:messageInfo];
        }
    }
}

- (IBAction)_btnClosePressed:(UIButton *)sender {
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, self.frame.size.height);
    }];
}

- (IBAction)_btnMoreClicked:(UIButton *)sender {
    UIActionSheet *optionsPopup = [[UIActionSheet alloc] initWithTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_options] delegate:self cancelButtonTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_cancel] destructiveButtonTitle:nil otherButtonTitles:
                            [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_send_to_friend],
                            [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_save_to_gallery],
                            nil];
    [optionsPopup showInView: self];
}

#pragma mark - ActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:{
            [self makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:TEXT_OTR_NOT_SUPPORTED]
                   duration:2.0 position:CSToastPositionCenter];
            NSLog(@"Send to friend");
            break;
        }
        case 1:{
            if (_idMessageShow != nil && ![_idMessageShow isEqualToString:@""]) {
                NSString *detailsURL = [NSDatabase getPictureNameOfMessage: _idMessageShow];
                UIImage *saveImage = [AppUtils getImageDataWithName: detailsURL];
                if (saveImage != nil) {
                    UIImageWriteToSavedPhotosAlbum(saveImage, self, @selector(imageSavedToPhotosAlbum: didFinishSavingWithError: contextInfo:), nil);
                }
            }else if (_curIndex >= 0){
                _clvPictures.contentOffset = CGPointMake(_curIndex*_clvPictures.frame.size.width, _clvPictures.frame.origin.y);
            }
            break;
        }
        case 2:{
            NSLog(@"Cancel");
            break;
        }
            
        default:
            break;
    }
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (!error) {
        [self makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_save_image_success]
               duration:2.0 position:CSToastPositionCenter];
    } else {
        [self makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_save_image_failed]
               duration:2.0 position:CSToastPositionCenter];
    }
}

#pragma mark - collection view

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_listPhotos count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ChatDetailImageCollectionCell";
    ChatDetailImageCollectionCell *cell = (ChatDetailImageCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell setTag: indexPath.row];
    
    NSDictionary *info = [_listPhotos objectAtIndex: indexPath.row];
    NSString *imagePath = [info objectForKey:@"details_url"];
    NSString *typeMessage = [info objectForKey:@"type_message"];
    int expireTime = [[info objectForKey:@"expire_time"] intValue];
    NSString *status = [info objectForKey:@"status"];
    NSString *sendPhone = [info objectForKey:@"send_phone"];
    
    if (imagePath != nil && ![imagePath isEqualToString:@""]) {
        if (expireTime > 0 && [status isEqualToString:@"NO"] && [sendPhone isEqualToString:_remoteParty]) {
            cell._imgView.image = [UIImage imageNamed:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:click_to_view_img]];
        }else{
            cell._imgView.image = [AppUtils getImageDataWithName: imagePath];
        }
    }else{
        cell._imgView.image = [UIImage imageNamed:@"unloaded"];
    }
    
    if ([typeMessage isEqualToString:videoMessage]) {
        cell._imgPlay.frame = CGRectMake((self.frame.size.width-50)/2, (self.frame.size.height-50)/2, 50.0, 50.0);
        cell._imgPlay.hidden = NO;
        [cell disableZoomPicture: YES];
    }else{
        cell._imgPlay.hidden = YES;
        [cell disableZoomPicture: NO];
    }
    
    cell._imgView.tag = indexPath.row;
    UITapGestureRecognizer *tapOnPicture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTapOnPicture:)];
    cell._imgView.userInteractionEnabled = YES;
    [cell._imgView addGestureRecognizer: tapOnPicture];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(self.frame.size.width, self.frame.size.height);
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

#pragma mark - Pagination

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == _clvPictures) {
        float x = _clvPictures.contentOffset.x;
        NSLog(@"---%f", x/_clvPictures.frame.size.width);
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == _clvPictures) {
        float x = _clvPictures.contentOffset.x;
        NSLog(@"---%f", x/_clvPictures.frame.size.width);
    }
}

- (void)videoPlayBackDidFinish:(NSNotification *)notification {
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
}

- (void)whenTapOnPicture: (UIGestureRecognizer *)gesture {
    id object = [gesture view];
    if ([object isKindOfClass:[UIImageView class]]) {
        int index = (int)[(UIImageView *)object tag];
        NSDictionary *info = [_listPhotos objectAtIndex: index];
        NSString *typeMessage = [info objectForKey:@"type_message"];
        NSString *idMessage = [info objectForKey:@"id_message"];
        int expireTime = [[info objectForKey:@"expire_time"] intValue];
        NSString *status = [info objectForKey:@"status"];
        NSString *sendPhone = [info objectForKey:@"send_phone"];
        
        if (expireTime > 0 && [status isEqualToString:@"NO"] && [sendPhone isEqualToString:_remoteParty]) {
            [[LinphoneAppDelegate sharedInstance].myBuddy.protocol sendDisplayedToUser:_remoteParty fromUser:USERNAME andListIdMsg:idMessage];
            [NSDatabase updateSeenForMessage: idMessage];
            
            NSString *imagePath = [info objectForKey:@"details_url"];
            if (imagePath != nil && ![imagePath isEqualToString:@""]) {
                ChatDetailImageCollectionCell *cell = (ChatDetailImageCollectionCell *)[_clvPictures cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                cell._imgView.image = [AppUtils getImageDataWithName: imagePath];
            }else{
                [self makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:image_not_exists]
                       duration:2.0 position:CSToastPositionCenter];
            }
        }
        
        if ([typeMessage isEqualToString:videoMessage])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:playVideoMessage object:info];
        }else{
            if (_viewTop.frame.origin.y == 0) {
                [UIView animateWithDuration:0.2 animations:^{
                    _viewTop.frame = CGRectMake(0, -_viewTop.frame.size.height, _viewTop.frame.size.width, _viewTop.frame.size.height);
                }];
            }else{
                [UIView animateWithDuration:0.2 animations:^{
                    _viewTop.frame = CGRectMake(0, 0, _viewTop.frame.size.width, _viewTop.frame.size.height);
                }];
            }
            NSLog(@"Tap tren anh");
        }
    }
}

@end
