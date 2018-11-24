//
//  SearchContactPopupView.m
//  linphone
//
//  Created by lam quang quan on 10/29/18.
//

#import "SearchContactPopupView.h"
#import "ContactCell.h"
#import "NSData+Base64.h"

@implementation SearchContactPopupView
@synthesize tbContacts, tapGesture, contacts;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame: frame];
    if (self) {
        // Initialization code
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 12.0;
        
        tbContacts = [[UITableView alloc] init];
        tbContacts.delegate = self;
        tbContacts.dataSource = self;
        tbContacts.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview: tbContacts];
        
        [tbContacts mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.right.equalTo(self);
        }];
    }
    return self;
}

- (void)showInView:(UIView *)aView animated:(BOOL)animated {
    //Add transparent
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopupViewWhenTagOut)];
    UIView *viewBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    viewBackground.backgroundColor = UIColor.blackColor;
    viewBackground.alpha = 0.5;
    viewBackground.tag = 20;
    [aView addSubview:viewBackground];
    
    [viewBackground addGestureRecognizer:tapGesture];
    
    [aView addSubview:self];
    if (animated) {
        [self fadeIn];
    }
}

- (void)fadeIn {
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)fadeOut {
    for (UIView *subView in self.window.subviews)
    {
        if (subView.tag == 20)
        {
            [subView removeFromSuperview];
        }
    }
    
    [UIView animateWithDuration:.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self removeFromSuperview];
        }
    }];
}

- (void)closePopupViewWhenTagOut{
    [self fadeOut];
    [self.superview removeGestureRecognizer:tapGesture];
}

#pragma mark - UITableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ContactCell";
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ContactCell" owner:self options:nil];
        cell = topLevelObjects[0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    PhoneObject *phone = [contacts objectAtIndex: indexPath.row];
    
    cell.icCall.hidden = YES;
    cell.name.text = phone.name;
    cell.phone.text = phone.number;
    if (![AppUtils isNullOrEmpty: phone.avatar]) {
        cell.image.image = [UIImage imageWithData:[NSData dataFromBase64String: phone.avatar]];
    }else{
        cell.image.image = [UIImage imageNamed:@"no_avatar.png"];
    }
    cell.icCall.hidden = YES;
    
    [cell._lbSepa mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(cell);
        make.height.mas_equalTo(1.0);
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self fadeOut];
    PhoneObject *phone = [contacts objectAtIndex: indexPath.row];
    [self.delegate selectContactFromSearchPopup: phone.number];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}



@end
