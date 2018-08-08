//
//  ExportConversationPopupView.h
//  linphone
//
//  Created by Ei Captain on 4/14/17.
//
//

#import <UIKit/UIKit.h>
#import "BEMCheckBox.h"

@interface ExportConversationPopupView : UIView

@property (nonatomic, strong) UITextView *_tvFileName;
@property (nonatomic, strong) UIButton *_buttonNo;
@property (nonatomic, strong) UIButton *_buttonYes;

@property (nonatomic, strong) BEMCheckBox *_checkButton;

- (void)showInView:(UIView *)aView animated:(BOOL)animated;
@property (nonatomic, retain) UITapGestureRecognizer *_tapGesture;

@end
