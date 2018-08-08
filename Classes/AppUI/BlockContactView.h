//
//  BlockContactView.h
//  linphone
//
//  Created by Ei Captain on 7/7/16.
//
//

#import <UIKit/UIKit.h>

typedef enum typeBlock{
    eNormalContact,
    eBlockContact,
}typeBlock;

@interface BlockContactView : UIView

@property (nonatomic, strong) UIButton *_btnCancel;
@property (nonatomic, strong) UIButton *_btnYes;
@property (nonatomic, strong) UILabel *_lbContent;

@property (nonatomic, assign) int _typePopup;
@property (nonatomic, retain) UITapGestureRecognizer *_tapGesture;

- (void)showInView:(UIView *)aView animated:(BOOL)animated;

- (void)fadeOut;

@end
