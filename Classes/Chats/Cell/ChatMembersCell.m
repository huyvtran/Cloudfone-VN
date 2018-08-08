//
//  ChatMembersCell.m
//  linphone
//
//  Created by admin on 1/12/18.
//

#import "ChatMembersCell.h"
#import "MemberCollectionCell.h"
#import "NSDatabase.h"
#import "NSData+Base64.h"

@implementation ChatMembersCell
@synthesize _lbMember, _clvMembers, listMembers, delegate;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    wContent = SCREEN_WIDTH - [LinphoneAppDelegate sharedInstance]._wSubMenu;
    
    [_clvMembers registerNib:[UINib nibWithNibName:@"MemberCollectionCell" bundle:[NSBundle mainBundle]]
   forCellWithReuseIdentifier:@"MemberCollectionCell"];
    _clvMembers.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _clvMembers.delegate = self;
    _clvMembers.dataSource = self;
    _clvMembers.backgroundColor = [UIColor clearColor];
    _clvMembers.scrollEnabled = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupListMember: (NSArray *)list {
    if (listMembers == nil) {
        listMembers = [[NSMutableArray alloc] init];
    }
    [listMembers removeAllObjects];
    [listMembers addObjectsFromArray: list];
    
    [_clvMembers reloadData];
}

- (void)setupUIForCell {
    _lbMember.frame = CGRectMake(15, 5, wContent-10, 25);
    _clvMembers.frame = CGRectMake(_lbMember.frame.origin.x, _lbMember.frame.origin.y+_lbMember.frame.size.height+5, wContent-2*_lbMember.frame.origin.x, self.frame.size.height-(5+_lbMember.frame.size.height+5+5));
}

#pragma mark - collection view

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [listMembers count] + 1;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MemberCollectionCell";
    MemberCollectionCell *cell = (MemberCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell setTag: indexPath.row];
    
    if (indexPath.row == 0) {
        cell._imgAvatar.image = [UIImage imageNamed:@"ic_add_member"];
        cell._imgAvatar.backgroundColor = [UIColor colorWithRed:(12/255.0) green:(188/255.0)
                                                           blue:(154/255.0) alpha:0.3];
        cell._lbName.hidden = YES;
    }else{
        NSString *sipPhone = [listMembers objectAtIndex: (indexPath.row-1)];
        if ([sipPhone isEqualToString:USERNAME]) {
            cell._lbName.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_you];
            NSString *avatar = [NSDatabase getAvatarOfAccount: sipPhone];
            if ([avatar isEqualToString:@""]) {
                cell._imgAvatar.image = [UIImage imageNamed:@"no_avatar"];
            }else{
                cell._imgAvatar.image = [UIImage imageWithData:[NSData dataFromBase64String:avatar]];
            }
        }else{
            NSString *name = [NSDatabase getNameOfContactWithPhoneNumber: sipPhone];
            if ([name isEqualToString:@""]) {
                name = sipPhone;
            }
            cell._lbName.text = name;
            
            NSString *avatar = [NSDatabase getAvatarOfContactWithPhoneNumber: sipPhone];
            if ([avatar isEqualToString:@""]) {
                cell._imgAvatar.image = [UIImage imageNamed:@"no_avatar"];
            }else{
                cell._imgAvatar.image = [UIImage imageWithData:[NSData dataFromBase64String: avatar]];
            }
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [delegate addNewMembersToRoomChat];
    }else{
        NSString *sipPhone = [listMembers objectAtIndex: (indexPath.row-1)];
        if (![sipPhone isEqualToString:USERNAME]) {
            [delegate viewContactDetailsWithInfo: sipPhone];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(70, 90);
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

@end
