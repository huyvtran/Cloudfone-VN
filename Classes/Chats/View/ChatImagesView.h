//
//  ChatImagesView.h
//  linphone
//
//  Created by admin on 1/11/18.
//

#import <UIKit/UIKit.h>
#import "ChatPictureDetailsView.h"

@protocol ChatImagesViewDelegate
- (void)iconBackOnChatImagesClicked;
@end

@interface ChatImagesView : UIView<UICollectionViewDelegate, UICollectionViewDataSource>{
    float sizeItem;
    float margin;
    ChatPictureDetailsView *viewPictures;
}

@property (weak, nonatomic) id<ChatImagesViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (weak, nonatomic) IBOutlet UIButton *_iconBack;
@property (weak, nonatomic) IBOutlet UILabel *_lbHeader;
@property (weak, nonatomic) IBOutlet UICollectionView *_clvImages;
@property (strong, nonatomic) NSMutableArray *_listPhotos;
@property (nonatomic, strong) NSString *_remoteParty;
@property (nonatomic, assign) BOOL isGroup;

- (IBAction)_iconBackClicked:(UIButton *)sender;
- (void)setupUIForView;
- (void)loadListPictureForView;

@end
