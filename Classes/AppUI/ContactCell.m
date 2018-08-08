//
//  ContactCell.m
//  linphone
//
//  Created by user on 13/5/14.
//
//

#import "ContactCell.h"
#import "Utils.h"

@implementation ContactCell
@synthesize name, phone, image, btnCallnex, strCallnexId, avatarStr, _lbSepa;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    name.backgroundColor = UIColor.clearColor;
    
    phone.hidden = NO;
    phone.backgroundColor = UIColor.clearColor;
    
    _lbSepa.backgroundColor = [UIColor colorWithRed:(235/255.0) green:(235/255.0)
                                               blue:(235/255.0) alpha:1.0];
    image.layer.masksToBounds = YES;
}

- (void)setupUIForCell{
    image.frame = CGRectMake(5, 5, self.frame.size.height-10, self.frame.size.height-10);
    image.layer.cornerRadius = (self.frame.size.height-10)/2;
    name.frame = CGRectMake(image.frame.origin.x+image.frame.size.width+10, image.frame.origin.y, (self.frame.size.width-(2*image.frame.origin.x+image.frame.size.width+10+45+20)), image.frame.size.height/2);
    phone.frame = CGRectMake(name.frame.origin.x, name.frame.origin.y+name.frame.size.height, name.frame.size.width, name.frame.size.height);
    btnCallnex.frame = CGRectMake(self.frame.size.width-45-20, (self.frame.size.height-45)/2, 45, 45);
    _lbSepa.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithRed:(223/255.0) green:(255/255.0)
                                                blue:(133/255.0) alpha:1];
    }else{
        self.backgroundColor = UIColor.clearColor;
    }
}

- (void)setContact:(Contact *)acontact {
    _contact = acontact;
    if(_contact) {
        [ContactDisplay setDisplayNameLabel:name forContact:_contact];
        btnCallnex.hidden = ! ((_contact.friend && linphone_presence_model_get_basic_status(linphone_friend_get_presence_model(_contact.friend)) == LinphonePresenceBasicStatusOpen) || [FastAddressBook contactHasValidSipDomain:_contact]);
    }
}

- (void)dealloc {
}

@end
