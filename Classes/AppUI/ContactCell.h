//
//  ContactCell.h
//  linphone
//
//  Created by user on 13/5/14.
//
//

#import <UIKit/UIKit.h>
#import "Contact.h"

@interface ContactCell : UITableViewCell{
    IBOutlet UILabel *name;
    IBOutlet UILabel *phone;
    IBOutlet UIImageView *image;
    NSString *strCallnexId;
    NSString *avatarStr;
}

@property(nonatomic, strong) IBOutlet UILabel *name;
@property(nonatomic, retain) IBOutlet UILabel *phone;
@property(nonatomic, retain) IBOutlet UIImageView *image;
@property (nonatomic, strong) NSString *strCallnexId;
@property (nonatomic, strong) NSString *avatarStr;
@property (weak, nonatomic) IBOutlet UILabel *_lbSepa;
@property (weak, nonatomic) IBOutlet UIButton *icCall;

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;
@property(nonatomic, assign) Contact *contact;

@end
