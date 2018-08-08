//
//  PrivacyPopupView.m
//  linphone
//
//  Created by Hung Ho on 10/11/17.
//
//

#import "PrivacyPopupView.h"

@interface PrivacyPopupView (){
    
}

@end

@implementation PrivacyPopupView
@synthesize _webView, _tapGesture;
//  @synthesize delegate;

//- (void)buttonPressed:(UIButton *)sender {
//    [delegate testButtonPressed: _btnClose];
//    //    NSLog(@"Display DID : %@",_displayDID);
//}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self)
    {
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 5.0;
        self.backgroundColor = [UIColor colorWithRed:(240/255.0) green:(240/255.0)
                                                blue:(240/255.0) alpha:(240/255.0)];
        
        float tmpMargin = 0;
        //  web view content
        _webView = [[UIWebView alloc] initWithFrame: CGRectMake(tmpMargin, tmpMargin, frame.size.width-2*tmpMargin, frame.size.height-2*tmpMargin)];
        _webView.layer.borderColor = [UIColor colorWithRed:(200/255.0) green:(200/255.0)
                                                      blue:(200/255.0) alpha:1.0].CGColor;
        _webView.layer.borderWidth = 1.0;
        _webView.layer.cornerRadius = 5.0;
        _webView.backgroundColor = UIColor.whiteColor;
        [self addSubview: _webView];
        
        
        NSString *url = @"http://dieukhoan.cloudfone.vn";
        NSURL *nsurl=[NSURL URLWithString:url];
        NSURLRequest *nsrequest = [NSURLRequest requestWithURL: nsurl];
        [_webView loadRequest:nsrequest];
    }
    return self;
}


- (void)showInView:(UIView *)aView animated:(BOOL)animated {
    //Add transparent
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopupViewWhenTagOut)];
    
    UIView *viewBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    viewBackground.backgroundColor = UIColor.blackColor;
    viewBackground.alpha = 0.5;
    viewBackground.tag = 20;
    [viewBackground addGestureRecognizer:_tapGesture];
    
    [aView addSubview: viewBackground];
    
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
    [self setAlpha: 0.0];
    [self setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.3, 1.3)];
    
    [UIView animateWithDuration:.35 animations:^{
        [self setAlpha: 1.0];
        [self setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
    }];
}

- (void)fadeOut {
    //xoa background black
    for (UIView *subView in self.window.subviews){
        if (subView.tag == 20){
            [subView removeFromSuperview];
        }
    }
    
    [UIView animateWithDuration:.35 animations:^{
        [self setAlpha: 0.0];
        [self setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.3, 1.3)];
    }completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // dismiss self
}

- (void)cancelTrunking{
    
}

@end
