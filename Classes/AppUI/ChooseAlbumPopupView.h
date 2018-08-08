//
//  ChooseAlbumPopupView.h
//  linphone
//
//  Created by Ei Captain on 4/11/17.
//
//

#import <UIKit/UIKit.h>

@interface ChooseAlbumPopupView : UIView<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *_tbContent;
@property (nonatomic, retain) UITapGestureRecognizer *_tapGesture;

- (void)showInView:(UIView *)aView animated:(BOOL)animated;
- (void)fadeOut;

@property (nonatomic, strong) NSMutableArray *_listAlbum;
@property (nonatomic, assign) float _hCell;
@property (nonatomic, strong) NSString *_curName;

@end
