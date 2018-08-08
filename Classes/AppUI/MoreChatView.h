//
//  MoreChatView.h
//  linphone
//
//  Created by admin on 12/28/17.
//

#import <UIKit/UIKit.h>

@interface MoreChatView : UIView {
    float marginX;
    float marginY;
    float wIcon;
}

@property (weak, nonatomic) IBOutlet UIButton *iconPicture;
@property (weak, nonatomic) IBOutlet UILabel *lbPicture;
@property (weak, nonatomic) IBOutlet UIButton *iconVideo;
@property (weak, nonatomic) IBOutlet UILabel *lbVideo;
@property (weak, nonatomic) IBOutlet UIButton *iconCamera;
@property (weak, nonatomic) IBOutlet UILabel *lbCamera;
@property (weak, nonatomic) IBOutlet UIButton *iconCall;
@property (weak, nonatomic) IBOutlet UILabel *lbCall;
@property (weak, nonatomic) IBOutlet UIButton *iconLocation;
@property (weak, nonatomic) IBOutlet UILabel *lbLocation;

- (void)setupUIForView: (float)hView;

@end
