//
//  PopupChangeSubject.h
//  linphone
//
//  Created by Ei Captain on 7/18/16.
//
//

#import <UIKit/UIKit.h>

@protocol PopupChangeSubjectDelegate
@end

@interface PopupChangeSubject : UIView {
    id <NSObject, PopupChangeSubjectDelegate> delegate;
}

@property (nonatomic, strong) UITextField *_tfSubject;
@property (nonatomic, strong) UIButton *_btnSave;
@property (nonatomic, strong) UIButton *_btnCancel;

@property (nonatomic, retain) UITapGestureRecognizer *_tapGesture;

- (void)showInView:(UIView *)aView animated:(BOOL)animated;

@property (nonatomic, strong) NSString *_roomName;

@end
