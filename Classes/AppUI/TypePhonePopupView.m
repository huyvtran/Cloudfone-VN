//
//  TypePhonePopupView.m
//  linphone
//
//  Created by mac book on 7/7/15.
//
//

#import "TypePhonePopupView.h"
#import "TypePhoneCell.h"
#import "TypePhoneObject.h"

@interface TypePhonePopupView (){
    NSArray *listTypePhone;
    float hCell;
    UIFont *textFont;
}

@end

@implementation TypePhonePopupView
@synthesize _tbContent, _tapGesture;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame: frame];
    if (self) {
        
        if (SCREEN_WIDTH > 320) {
            hCell = 50.0;
            textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
        }else{
            hCell = 40.0;
            textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
        }
        
        [self createTypePhoneList];
        
        // Initialization code
        self.layer.borderWidth = 3.0;
        self.layer.borderColor = [UIColor colorWithRed:(23/255.0) green:(184/255.0)
                                                  blue:(151/255.0) alpha:1.0].CGColor;
        
        _tbContent = [[UITableView alloc] initWithFrame: CGRectMake(3, 3, frame.size.width-6, frame.size.height-6)];
        _tbContent.delegate = self;
        _tbContent.dataSource = self;
        _tbContent.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tbContent.scrollEnabled = NO;
        
        [self addSubview: _tbContent];
    }
    return self;
}

- (void)createTypePhoneList {
    TypePhoneObject *type1 = [[TypePhoneObject alloc] init];
    type1._strIcon = @"btn_contacts_mobile.png";
    type1._strTitle = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_phone_mobile];
    type1._strType = type_phone_mobile;
    
    TypePhoneObject *type2 = [[TypePhoneObject alloc] init];
    type2._strIcon = @"btn_contacts_work.png";
    type2._strTitle = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_phone_work];
    type2._strType = type_phone_work;
    
    TypePhoneObject *type3 = [[TypePhoneObject alloc] init];
    type3._strIcon = @"btn_contacts_fax.png";
    type3._strTitle = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_phone_fax];
    type3._strType = type_phone_fax;
    
    TypePhoneObject *type4 = [[TypePhoneObject alloc] init];
    type4._strIcon = @"btn_contacts_home.png";
    type4._strTitle = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_phone_home];
    type4._strType = type_phone_home;
    
    listTypePhone = [[NSArray alloc] initWithObjects: type1, type2, type3, type4, nil];
}

- (void)showInView:(UIView *)aView animated:(BOOL)animated {
    //Add transparent
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopupViewWhenTagOut)];
    UIView *viewBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    viewBackground.backgroundColor = UIColor.blackColor;
    viewBackground.alpha = 0.5;
    viewBackground.tag = 20;
    [aView addSubview:viewBackground];
    
    [viewBackground addGestureRecognizer:_tapGesture];
    
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
    [self.superview removeGestureRecognizer:_tapGesture];
}


#pragma mark - UITableview Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [listTypePhone count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"TypePhoneCell";
    TypePhoneCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TypePhoneCell" owner:self options:nil];
        cell = topLevelObjects[0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, _tbContent.frame.size.width, hCell);
    [cell setupUIForCell];
    
    TypePhoneObject *curType = [listTypePhone objectAtIndex: indexPath.row];
    cell._lbType.text = curType._strTitle;
    cell._lbType.font = textFont;
    cell._imgType.image = [UIImage imageNamed: curType._strIcon];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self fadeOut];
    TypePhoneObject *curType = [listTypePhone objectAtIndex: indexPath.row];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:selectTypeForPhoneNumber
                                                        object:curType];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return hCell;
}

@end
