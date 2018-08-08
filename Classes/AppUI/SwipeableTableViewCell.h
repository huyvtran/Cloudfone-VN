#import <UIKit/UIKit.h>
#import "BEMCheckBox.h"

typedef NS_ENUM(NSUInteger, SwipeableTableViewCellSide) {
    SwipeableTableViewCellSideLeft,
    SwipeableTableViewCellSideRight,
};

extern NSString *const kSwipeableTableViewCellCloseEvent;
/**
 * The maximum number of milliseconds that closing the buttons may take after release.
 *
 * If the time for the buttons to be hidden exceeds this number, they will be animated
 * to close quickly.
 */
extern CGFloat const kSwipeableTableViewCellMaxCloseMilliseconds;
/**
 * The minimum velocity required to open buttons if released before completely open.
 */
extern CGFloat const kSwipeableTableViewCellOpenVelocityThreshold;

@interface SwipeableTableViewCell : UITableViewCell <UIScrollViewDelegate>

@property (nonatomic, readonly) BOOL closed;
@property (nonatomic, readonly) CGFloat leftInset;
@property (nonatomic, readonly) CGFloat rightInset;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIView *scrollViewContentView;
@property (nonatomic, weak) UILabel *scrollViewLabel;

@property (nonatomic, strong) UIImageView *_iconAvatar;
@property (nonatomic, strong) UILabel *_lbTitle;
@property (nonatomic, strong) UILabel *_lbContent;
@property (nonatomic, strong) UILabel *_lbSepa;
@property (nonatomic, strong) UILabel *_lbTime;
@property (nonatomic, strong) UIImageView *_imgState;
@property (nonatomic, strong) UIImageView *_imgBlock;
@property (nonatomic, strong) UIButton *_iconUnread;
@property (nonatomic, strong) UIButton *_btnTop;

+ (void)closeAllCells;
+ (void)closeAllCellsExcept:(SwipeableTableViewCell *)cell;
- (void)close;
- (UIButton *)createButtonWithWidth:(CGFloat)width onSide:(SwipeableTableViewCellSide)side;
- (UIButton *)createButtonDeleteWithWidth:(CGFloat)width onSide:(SwipeableTableViewCellSide)side;
- (UIButton *)createButtonMuteWithWidth:(CGFloat)width onSide:(SwipeableTableViewCellSide)side;
- (UIButton *)createButtonCallWithWidth:(CGFloat)width onSide:(SwipeableTableViewCellSide)side;

- (void)openSide:(SwipeableTableViewCellSide)side;
- (void)openSide:(SwipeableTableViewCellSide)side animated:(BOOL)animate;

- (void)updateUIForCell;
- (void)showDeleteViewForCell;

@property (retain, nonatomic) NSString *_cloudFoneID;
@property (nonatomic, assign) BOOL _isGroup;
@property (nonatomic, assign) int _idContact;

@property (nonatomic, strong) UIButton *_btnDelete;
@property (nonatomic, strong) UIButton *_btnMute;
@property (nonatomic, strong) UIButton *_btnCall;
@property (nonatomic, strong) BEMCheckBox *_cbDelete;

@end
