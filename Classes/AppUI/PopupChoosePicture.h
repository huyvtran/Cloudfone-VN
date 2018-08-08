//
//  PopupChoosePicture.h
//  linphone
//
//  Created by user on 7/11/14.
//
//

#import <UIKit/UIKit.h>

typedef enum typeChoose{
    chooseGallery,
    chooseCamera,
}typeChoose;

@protocol PopupChoosePictureDelegate
@end

@interface PopupChoosePicture : UIView<UITableViewDataSource, UITableViewDelegate>{
    id <NSObject, PopupChoosePictureDelegate> delegate;
}
@property (nonatomic, retain) id <NSObject, PopupChoosePictureDelegate> delegate;
@property (nonatomic, retain) UITableView *_optionsTbView;
@property (nonatomic, retain) UITapGestureRecognizer *_tapGesture;
@property (nonatomic, retain) NSArray *_listOptions;
@property (nonatomic, retain) NSArray *_listTitle;
@property (nonatomic, assign) int _typePopup;

- (void)showInView:(UIView *)aView animated:(BOOL)animated;

@end
