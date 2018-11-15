/* DialerViewController.h
 *
 * Copyright (C) 2009  Belledonne Comunications, Grenoble, France
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#import <UIKit/UIKit.h>
#import "UICompositeView.h"
#import "UICamSwitch.h"
#import "UICallButton.h"
#import "UIDigitButton.h"
#import "SearchContactPopupView.h"

@class UICallButton;
@interface DialerView
	: TPMultiLayoutViewController <UITextFieldDelegate, UICompositeViewDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, UICallButtonDelegate, UIAlertViewDelegate, UITextViewDelegate, SearchContactPopupViewDelegate, WebServicesDelegate> {
}


@property(nonatomic, strong) IBOutlet UICallButton *callButton;
@property(nonatomic, strong) IBOutlet UIButton *backButton;
@property(weak, nonatomic) IBOutlet UIIconButton *backspaceButton;

@property(nonatomic, strong) IBOutlet UIDigitButton *oneButton;
@property(nonatomic, strong) IBOutlet UIDigitButton *twoButton;
@property(nonatomic, strong) IBOutlet UIDigitButton *threeButton;
@property(nonatomic, strong) IBOutlet UIDigitButton *fourButton;
@property(nonatomic, strong) IBOutlet UIDigitButton *fiveButton;
@property(nonatomic, strong) IBOutlet UIDigitButton *sixButton;
@property(nonatomic, strong) IBOutlet UIDigitButton *sevenButton;
@property(nonatomic, strong) IBOutlet UIDigitButton *eightButton;
@property(nonatomic, strong) IBOutlet UIDigitButton *nineButton;
@property(nonatomic, strong) IBOutlet UIDigitButton *starButton;
@property(nonatomic, strong) IBOutlet UIDigitButton *zeroButton;
@property(nonatomic, strong) IBOutlet UIDigitButton *hashButton;
@property(weak, nonatomic) IBOutlet UIView *padView;

- (IBAction)onAddContactClick:(id)event;
- (IBAction)onBackClick:(id)event;
- (IBAction)onAddressChange:(id)sender;
- (IBAction)onBackspaceClick:(id)sender;

- (void)setAddress:(NSString *)address;

@property (weak, nonatomic) IBOutlet UIView *_viewNumber;
@property(nonatomic, strong) IBOutlet UITextField *addressField;
@property(nonatomic, strong) IBOutlet UIButton *addContactButton;

@property (weak, nonatomic) IBOutlet UIButton *_btnAddCall;
@property (weak, nonatomic) IBOutlet UIButton *_btnTransferCall;

@property (weak, nonatomic) IBOutlet UIButton *_btnHotline;

@property (weak, nonatomic) IBOutlet UIView *_viewStatus;
@property (weak, nonatomic) IBOutlet UIImageView *_imgLogoSmall;
@property (weak, nonatomic) IBOutlet UILabel *_lbAccount;
@property (weak, nonatomic) IBOutlet UILabel *_lbStatus;

- (IBAction)_btnAddCallPressed:(UIButton *)sender;
- (IBAction)_btnTransferPressed:(UIButton *)sender;
- (IBAction)_btnHotlinePressed:(UIButton *)sender;

- (IBAction)_btnNumberPressed:(id)sender;
- (IBAction)_btnCallPressed:(UIButton *)sender;

@property (nonatomic, strong) WebServices *webService;

@end
