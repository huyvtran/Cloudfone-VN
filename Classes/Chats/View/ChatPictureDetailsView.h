//
//  ChatPictureDetailsView.h
//  linphone
//
//  Created by admin on 1/11/18.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ChatPictureDetailsView : UIView<UICollectionViewDelegate, UICollectionViewDataSource, UIActionSheetDelegate>{
    float sizeItem;
    float margin;
}

@property (weak, nonatomic) IBOutlet UICollectionView *_clvPictures;
@property (weak, nonatomic) IBOutlet UIView *_viewTop;
@property (weak, nonatomic) IBOutlet UIButton *_btnClose;
@property (weak, nonatomic) IBOutlet UIButton *_btnMore;

@property (strong, nonatomic) NSMutableArray *_listPhotos;
@property (nonatomic, strong) NSString *_remoteParty;
@property (nonatomic, strong) NSString *_idMessageShow;
@property (nonatomic, assign) int _curIndex;
@property (nonatomic, assign) BOOL isGroup;

- (void)setupUIForView;
- (void)setupUIForViewForFullScreen;
- (void)loadListPictureForView;

- (IBAction)_btnClosePressed:(UIButton *)sender;
- (IBAction)_btnMoreClicked:(UIButton *)sender;

@end
