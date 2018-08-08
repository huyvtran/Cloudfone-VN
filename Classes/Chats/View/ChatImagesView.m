//
//  ChatImagesView.m
//  linphone
//
//  Created by admin on 1/11/18.
//

#import "ChatImagesView.h"
#import "ChatImageCollectionCell.h"
#import "NSDatabase.h"

@implementation ChatImagesView
@synthesize _viewHeader, _iconBack, _lbHeader, _clvImages, delegate;
@synthesize _listPhotos, _remoteParty, isGroup;

- (IBAction)_iconBackClicked:(UIButton *)sender {
    [delegate iconBackOnChatImagesClicked];
}

- (void)setupUIForView {
    _listPhotos = [[NSMutableArray alloc] init];
    
    //  Header
    float statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    _viewHeader.frame = CGRectMake(0, 0, self.frame.size.width, [LinphoneAppDelegate sharedInstance]._hHeader+statusBarHeight);
    _iconBack.frame = CGRectMake(0, statusBarHeight, [LinphoneAppDelegate sharedInstance]._hHeader, [LinphoneAppDelegate sharedInstance]._hHeader);
    [_iconBack setBackgroundImage:[UIImage imageNamed:@"ic_back_act.png"]
                         forState:UIControlStateHighlighted];
    _lbHeader.frame = CGRectMake(_iconBack.frame.origin.x+_iconBack.frame.size.width+5, statusBarHeight, self.frame.size.width-2*(_iconBack.frame.origin.x+_iconBack.frame.size.width+5), [LinphoneAppDelegate sharedInstance]._hHeader);
    
    //  Collection view
    margin = 2.0;
    sizeItem =(self.frame.size.width-8*margin)/3;
    
    _clvImages.frame = CGRectMake(margin, _viewHeader.frame.origin.y+_viewHeader.frame.size.height+margin, self.frame.size.width-2*margin, self.frame.size.height-_viewHeader.frame.size.height-2*margin);
    
    [_clvImages registerNib:[UINib nibWithNibName:@"ChatImageCollectionCell" bundle:[NSBundle mainBundle]]
       forCellWithReuseIdentifier:@"ChatImageCollectionCell"];
    _clvImages.delegate = self;
    _clvImages.dataSource = self;
    _clvImages.backgroundColor = [UIColor whiteColor];
}

- (void)loadListPictureForView {
    if (isGroup) {
        _listPhotos = [NSDatabase getListPictureFromMessageOf:USERNAME withRoomChat:_remoteParty];
    }else{
        _listPhotos = [NSDatabase getListPictureFromMessageOf: USERNAME withRemoteParty: _remoteParty];
    }
    [_clvImages reloadData];
}

- (void)addViewDetailsForView {
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"ChatPictureDetailsView" owner:nil options:nil];
    for(id currentObject in subviewArray){
        if ([currentObject isKindOfClass:[ChatPictureDetailsView class]]) {
            viewPictures = (ChatPictureDetailsView *) currentObject;
            break;
        }
    }
    [viewPictures._btnClose addTarget:self
                               action:@selector(loadListPictureForView)
                     forControlEvents:UIControlEventTouchUpInside];
    viewPictures.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, self.frame.size.height);
    [viewPictures setupUIForViewForFullScreen];
    [self addSubview: viewPictures];
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
    static NSString *cellIdentifier = @"ChatImageCollectionCell";
    ChatImageCollectionCell *cell = (ChatImageCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell setTag: indexPath.row];
    
    NSDictionary *info = [_listPhotos objectAtIndex: indexPath.row];
    NSString *imagePath = [info objectForKey:@"thumb_url"];
    NSString *typeMessage = [info objectForKey:@"type_message"];
    int expireTime = [[info objectForKey:@"expire_time"] intValue];
    NSString *status = [info objectForKey:@"status"];
    NSString *sendPhone = [info objectForKey:@"send_phone"];
    
    if (imagePath != nil && ![imagePath isEqualToString:@""]) {
        if (expireTime > 0 && [status isEqualToString:@"NO"] && [sendPhone isEqualToString:_remoteParty]) {
            cell._image.image = [UIImage imageNamed:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:click_to_view_img]];
        }else{
            cell._image.image = [AppUtils getImageDataWithName: imagePath];
        }
    }else{
        cell._image.image = [UIImage imageNamed:@"unload"];
    }
    
    if ([typeMessage isEqualToString: videoMessage]) {
        cell._imgPlay.hidden = NO;
    }else{
        cell._imgPlay.hidden = YES;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _clvImages) {
        NSDictionary *info = [_listPhotos objectAtIndex: indexPath.row];
        NSString *typeMessage = [info objectForKey:@"type_message"];
        if ([typeMessage isEqualToString: videoMessage]) {
            int expireTime = [[info objectForKey:@"expire_time"] intValue];
            NSString *status = [info objectForKey:@"status"];
            NSString *sendPhone = [info objectForKey:@"send_phone"];
            NSString *idMessage = [info objectForKey:@"id_message"];
            
            if (expireTime > 0 && [status isEqualToString:@"NO"] && [sendPhone isEqualToString:_remoteParty]) {
                [[LinphoneAppDelegate sharedInstance].myBuddy.protocol sendDisplayedToUser:_remoteParty fromUser:USERNAME andListIdMsg:idMessage];
                [NSDatabase updateSeenForMessage: idMessage];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:playVideoMessage object:info];
        }else{
            if (viewPictures == nil) {
                [self addViewDetailsForView];
            }
            
            viewPictures._remoteParty = _remoteParty;
            viewPictures._clvPictures.hidden = YES;
            viewPictures.isGroup = isGroup;
            [UIView animateWithDuration:0.2 animations:^{
                viewPictures.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            }completion:^(BOOL finished) {
                viewPictures._curIndex = (int)indexPath.row;
                [viewPictures loadListPictureForView];
            }];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(sizeItem, sizeItem);
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(margin, margin, margin, margin); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return margin;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 2*margin;
}

@end
