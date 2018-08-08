//
//  PopupSaveConversation.m
//  linphone
//
//  Created by Ei Captain on 7/19/16.
//
//

#import "PopupSaveConversation.h"
#import "NSDatabase.h"

@interface PopupSaveConversation (){
    NSMutableArray *listData;
    NSString *strHTML;
    UIFont *textFont;
}

@end

@implementation PopupSaveConversation
@synthesize _twFileName, _btnCheckBox, _btnCancel, _btnYes, _tapGesture;
@synthesize _isGroup, _callnexUser, _roomName;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // My code here
        if (SCREEN_WIDTH > 320) {
            textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:18.0];
        }else{
            textFont = [UIFont fontWithName:MYRIADPRO_REGULAR size:16.0];
        }
        
        strHTML = @"";
        
        self.backgroundColor = UIColor.whiteColor;
        self.layer.borderWidth = 3.0;
        self.layer.borderColor = [UIColor colorWithRed:(24/255.0) green:(185/255.0)
                                                  blue:(153/255.0) alpha:1.0].CGColor;
        
        // Add logo image
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(4, 4, frame.size.width-8, 40)];
        headerView.backgroundColor = [UIColor colorWithRed:(230/255.0) green:(230/255.0)
                                                      blue:(230/255.0) alpha:1.0];
        
        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.height, headerView.frame.size.height)];
        logoImageView.image = [UIImage imageNamed:@"ic_offline.png"];
        [headerView addSubview: logoImageView];
        
        // label header
        UILabel *lbTitle = [[UILabel alloc] initWithFrame: CGRectMake(50, 0, frame.size.width-90, 40)];
        lbTitle.backgroundColor = UIColor.clearColor;
        lbTitle.textColor = [UIColor colorWithRed:(138/255.0) green:(138/255.0)
                                             blue:(138/255.0) alpha:1];
        lbTitle.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_export_title];
        lbTitle.font = textFont;
        lbTitle.textAlignment = NSTextAlignmentLeft;
        [headerView addSubview: lbTitle];
        [self addSubview: headerView];
        
        _twFileName = [[UITextView alloc] initWithFrame:CGRectMake(6, headerView.frame.origin.y+headerView.frame.size.height+10, frame.size.width-12, 50)];
        _twFileName.layer.borderColor = UIColor.darkGrayColor.CGColor;
        _twFileName.layer.borderWidth = 1.0;
        _twFileName.layer.cornerRadius = 5.0;
        _twFileName.font = textFont;
        _twFileName.editable = NO;
        [self addSubview: _twFileName];
        
        // checkbox
        UIColor *cbColor = [UIColor colorWithRed:(110/255.0) green:(80/255.0)
                                            blue:(148/255.0) alpha:1.0];
        _btnCheckBox = [[BEMCheckBox alloc] initWithFrame:CGRectMake(20, _twFileName.frame.origin.y+_twFileName.frame.size.height+10, 18, 18)];
        _btnCheckBox.lineWidth = 2.0;
        _btnCheckBox.boxType = BEMBoxTypeSquare;
        _btnCheckBox.onAnimationType = BEMAnimationTypeStroke;
        _btnCheckBox.offAnimationType = BEMAnimationTypeStroke;
        _btnCheckBox.tintColor = cbColor;
        _btnCheckBox.onTintColor = cbColor;
        _btnCheckBox.onFillColor = cbColor;
        _btnCheckBox.onCheckColor = UIColor.whiteColor;
        _btnCheckBox.on = NO;
        _btnCheckBox.tag = 0;
        [self addSubview: _btnCheckBox];
        
        UILabel *lbDesciption = [[UILabel alloc] initWithFrame:CGRectMake(_btnCheckBox.frame.origin.x+_btnCheckBox.frame.size.width+10, _btnCheckBox.frame.origin.y, frame.size.width-_btnCheckBox.frame.size.width-50, _btnCheckBox.frame.size.height)];
        lbDesciption.text = [[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_export_content];
        lbDesciption.textColor = UIColor.blackColor;
        lbDesciption.font = textFont;
        lbDesciption.userInteractionEnabled = YES;

        UITapGestureRecognizer *tapOnDescription = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(whenTapOnLabelDescription)];
        [lbDesciption addGestureRecognizer: tapOnDescription];
        
        [self addSubview: lbDesciption];
        
        //  ADD YES BUTTON
        float buttonWidth = (frame.size.width-8-2)/2;
        _btnYes = [[UIButton alloc] initWithFrame: CGRectMake(4, frame.size.height-35-4, buttonWidth, 35)];
        _btnYes.backgroundColor = [UIColor colorWithRed:(150/255.0) green:(150/255.0)
                                                   blue:(150/255.0) alpha:1];
        _btnYes.titleLabel.font = textFont;
        [_btnYes setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_yes]
                 forState:UIControlStateNormal];
        
        [_btnYes addTarget:self
                    action:@selector(whenButtonTouchDown:)
          forControlEvents:UIControlEventTouchDown];
        
        [_btnYes addTarget:self
                    action:@selector(onButtonYesPresed:)
          forControlEvents:UIControlEventTouchUpInside];
        [self addSubview: _btnYes];
        
        //  ADD CANCEL BUTTON
        _btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(_btnYes.frame.origin.x+_btnYes.frame.size.width+2, _btnYes.frame.origin.y, buttonWidth, 35)];
        _btnCancel.backgroundColor = _btnYes.backgroundColor;
        _btnCancel.titleLabel.font = textFont;
        [_btnCancel setTitle:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_no]
                    forState:UIControlStateNormal];
        [_btnCancel addTarget:self
                       action:@selector(whenButtonTouchDown:)
             forControlEvents:UIControlEventTouchDown];
        
        [_btnCancel addTarget:self
                       action:@selector(fadeOut)
             forControlEvents:UIControlEventTouchUpInside];
        [self addSubview: _btnCancel];
    }
    return self;
}

// tap trên label description
- (void)whenTapOnLabelDescription {
    if (_btnCheckBox.on) {
        [_btnCheckBox setOn:false animated:true];
    }else{
        [_btnCheckBox setOn:true animated:true];
    }
}

- (void)showInView:(UIView *)aView animated:(BOOL)animated {
    //Add transparent
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopupViewWhenTagOut)];
    
    UIView *viewBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    viewBackground.backgroundColor = UIColor.blackColor;
    viewBackground.alpha = 0.5;
    viewBackground.tag = 20;
    [viewBackground addGestureRecognizer:_tapGesture];
    [aView addSubview:viewBackground];
    
    [aView addSubview:self];
    
    if (animated) {
        [self fadeIn];
    }
}

- (void)closePopupViewWhenTagOut{
    [self fadeOut];
    [self.superview removeGestureRecognizer:_tapGesture];
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
    for (UIView *subView in self.window.subviews) {
        if (subView.tag == 20) {
            [subView removeFromSuperview];
        }
    }
    [UIView animateWithDuration:.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

- (void)whenButtonTouchDown: (UIButton *)sender{
    sender.backgroundColor = [UIColor colorWithRed:(223/255.0) green:(255/255.0)
                                              blue:(133/255.0) alpha:1];
}

- (void)onButtonYesPresed: (UIButton *)sender {
    sender.backgroundColor = [UIColor colorWithRed:(223/255.0) green:(255/255.0)
                                              blue:(133/255.0) alpha:1];
    NSString *fileName = _twFileName.text;
    if (![fileName isEqualToString:@""]) {
        NSRange range = [fileName rangeOfString:@".html" options:NSCaseInsensitiveSearch];
        if (range.location == NSNotFound) {
            fileName = [NSString stringWithFormat:@"%@.html", fileName];
        }
        [self fadeOut];
        
        //  Lưu conversation
        [self saveCurrentConversation];
        [self makeToast:[[LinphoneAppDelegate sharedInstance].localization localizedStringForKey:text_export_success] duration:1.5 position:CSToastPositionCenter];
        
        if (_btnCheckBox.on) {
            NSData *fileData = [strHTML dataUsingEncoding: NSUTF8StringEncoding];
            [[NSNotificationCenter defaultCenter] postNotificationName:k11SendMailAfterSaveConversation
                                                                object:[NSDictionary dictionaryWithObjectsAndKeys:fileData, @"fileData", _twFileName.text, @"fileName", nil]];
        }
    }
}

//  Get dữ liệu -> tạo file và lưu
- (void)saveCurrentConversation {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", @"export"]];
    BOOL isDir;
    BOOL exists = [fileManager fileExistsAtPath:databasePath isDirectory:&isDir];
    if (!exists) {
        [[NSFileManager defaultManager] createDirectoryAtPath:databasePath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    strHTML = [NSString stringWithFormat:@"<html><head><meta http-equiv=\"content-type\" content=\"text/html;charset=UTF-8\"></head><body>%@</body><html>", [self createDataForSaveConversation]];
    
    NSString *fileLocation = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Export/%@", _twFileName.text]];
    [strHTML writeToFile:fileLocation atomically:NO encoding:NSUTF8StringEncoding error:&error];
}

//  Tạo dữ liệu để save conversation
- (NSString *)createDataForSaveConversation
{
    NSString *result = @"";
    
    if (_isGroup) {
        if (listData == nil) {
            listData = [[NSMutableArray alloc] init];
        }
        [listData removeAllObjects];
        
        [listData addObjectsFromArray:[NSDatabase getListMessagesOfAccount:USERNAME withRoomID: [LinphoneAppDelegate sharedInstance].roomChatName]];
        result = [self getContentForGroupConversation];
    }else{
        
    }
    return result;
}

//  Lấy nội dung đoạn hội thoại của nhóm
- (NSString *)getContentForGroupConversation
{
    NSString *result = @""@"";
    
    for (int iCount = 0; iCount<listData.count; iCount++)
    {
        NSBubbleData *curData = [listData objectAtIndex: iCount];
        if ([curData.typeMessage isEqualToString: typeTextMessage]) {
            NSString *content = [curData.lbContent text];
            if (curData.type == BubbleTypeSomeoneElse) {
                content = [NSString stringWithFormat:@"<b>%@</b>(%@):&nbsp;&nbsp;%@", curData.userName, curData.time, content];
            }else{
                content = [NSString stringWithFormat:@"<b>%@</b>(%@):&nbsp;&nbsp;%@", USERNAME, curData.time, content];
            }
            result = [NSString stringWithFormat:@"%@<br/>%@", result, content];
        }else if([curData.typeMessage isEqualToString: imageMessage]){
            NSString *content = @"";
            if (curData.type == BubbleTypeSomeoneElse) {
                content = [NSString stringWithFormat:@"%@(%@)<br/> Send image", USERNAME, curData.time];
            }else{
                content = [NSString stringWithFormat:@"%@(%@)<br/> Send image", curData.userName, curData.time];
            }
            result = [NSString stringWithFormat:@"%@<br/>%@", result, content];
        }else if([curData.typeMessage isEqualToString: audioMessage]){
            NSString *content = @"";
            if (curData.type == BubbleTypeSomeoneElse) {
                content = [NSString stringWithFormat:@"%@(%@)<br/> Send audio", USERNAME, curData.time];
            }else{
                content = [NSString stringWithFormat:@"%@(%@)<br/> Send audio", curData.userName, curData.time];
            }
            result = [NSString stringWithFormat:@"%@<br/>%@", result, content];
        }else if ([curData.typeMessage isEqualToString: videoMessage]){
            NSString *content = @"";
            if (curData.type == BubbleTypeSomeoneElse) {
                content = [NSString stringWithFormat:@"%@(%@)<br/> Send video", USERNAME, curData.time];
            }else{
                content = [NSString stringWithFormat:@"%@(%@)<br/> Send video", curData.userName, curData.time];
            }
            result = [NSString stringWithFormat:@"%@<br/>%@", result, content];
        }
    }
    return result;
}

@end
