//
//  BackgroundViewController.h
//  linphone
//
//  Created by user on 25/9/14.
//
//

#import <UIKit/UIKit.h>
#import "UICompositeView.h"
#import "OTRBuddy.h"
#import "WebServices.h"

@interface BackgroundViewController : UIViewController<UICompositeViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, NSXMLParserDelegate, WebServicesDelegate>

@property (weak, nonatomic) IBOutlet UIView *_viewHeader;
@property (retain, nonatomic) IBOutlet UIButton *_iconBack;
@property (retain, nonatomic) IBOutlet UILabel *_lbHeader;

@property (retain, nonatomic) IBOutlet UICollectionView *_bgCollectionView;

- (IBAction)_iconBackClicked:(id)sender;

@property (nonatomic, assign) BOOL _chatGroup;

@end
