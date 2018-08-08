//
//  ChatMembersCell.h
//  linphone
//
//  Created by admin on 1/12/18.
//

#import <UIKit/UIKit.h>

@protocol ChatMembersCellDelegate<NSObject>
- (void)addNewMembersToRoomChat;
- (void)viewContactDetailsWithInfo: (NSString *)sipPhone;
@end

@interface ChatMembersCell : UITableViewCell<UICollectionViewDelegate, UICollectionViewDataSource>{
    float wContent;
}
@property (strong, nonatomic) id <NSObject, ChatMembersCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *_lbMember;
@property (weak, nonatomic) IBOutlet UICollectionView *_clvMembers;

@property (nonatomic, strong) NSMutableArray *listMembers;

- (void)setupListMember: (NSArray *)list;
- (void)setupUIForCell;

@end
