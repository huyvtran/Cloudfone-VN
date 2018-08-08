//
//  EmotionView.h
//  linphone
//
//  Created by mac book on 20/4/15.
//
//

#import <UIKit/UIKit.h>

typedef enum eEmotionView{
    emotionRecent,
    emotionFace,
    emotionFlower,
    emotionRing,
    emotionOto,
    emotionSymbol,
}eEmotionView;

@interface EmotionView : UIView<UICollectionViewDataSource, UICollectionViewDelegate>
@property (retain, nonatomic) IBOutlet UIView *_tabEmotion;
@property (retain, nonatomic) IBOutlet UIButton *_iconRecent;
@property (retain, nonatomic) IBOutlet UIButton *_iconFace;
@property (retain, nonatomic) IBOutlet UIButton *_iconNature;
@property (retain, nonatomic) IBOutlet UIButton *_iconObject;
@property (retain, nonatomic) IBOutlet UIButton *_iconPlace;
@property (retain, nonatomic) IBOutlet UIButton *_iconSymbol;
@property (retain, nonatomic) IBOutlet UIButton *_iconDelete;
@property (retain, nonatomic) IBOutlet UIScrollView *_scrollView;
@property (retain, nonatomic) IBOutlet UIPageControl *_pageControl;

@property (nonatomic, assign) int _numOfView;
@property (nonatomic, strong) NSMutableArray *_listRecentEmotion;

- (void)setupBackgroundUIForView;
- (void)addContentForEmotionView;
- (void)updateFrameForView;

@end
