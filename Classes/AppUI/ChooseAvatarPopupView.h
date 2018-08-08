//
//  ChooseAvatarPopupView.h
//  linphone
//
//  Created by mac book on 15/6/15.
//
//

#import <UIKit/UIKit.h>

@protocol ChooseAvatarPopupViewDelegate
@end

@interface ChooseAvatarPopupView : UIView{
    id <NSObject,ChooseAvatarPopupViewDelegate> delegate;
}

@property (nonatomic,strong) id <NSObject,ChooseAvatarPopupViewDelegate> delegate;
@property (nonatomic, retain) UITableView *_optionsTableView;
@property (nonatomic, retain) NSArray *_listOptions;
@property (nonatomic, strong) NSDictionary *_infoDict;
@property (nonatomic, retain) UITapGestureRecognizer *_tapGesture;

- (void)showInView:(UIView *)aView animated:(BOOL)animated;

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

- (void)fadeOut;

@end
