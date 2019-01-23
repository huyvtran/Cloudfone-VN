//
//  TestViewController.m
//  linphone
//
//  Created by lam quang quan on 1/17/19.
//

#import "TestViewController.h"

@interface TestViewController () {
    UIImageView *imgView;
    UITableView *tbView;
    UIScrollView *scvContent;
    float tbHeight;
    
    MASConstraint *heightConstraint;
    float firstHeight;
    
    CGPoint startPoint;
    CGPoint endPoint;
}

@end

@implementation TestViewController

#define TOP_LEFT(X, Y) CGPointMake(rect.origin.x + X * limitedRadius, rect.origin.y + Y * limitedRadius)
#define TOP_RIGHT(X, Y) CGPointMake(rect.origin.x + rect.size.width - X * limitedRadius, rect.origin.y + Y * limitedRadius)
#define BOTTOM_RIGHT(X, Y) CGPointMake(rect.origin.x + rect.size.width - X * limitedRadius, rect.origin.y + rect.size.height - Y * limitedRadius)
#define BOTTOM_LEFT(X, Y) CGPointMake(rect.origin.x + X * limitedRadius, rect.origin.y + rect.size.height - Y * limitedRadius)

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    float rectSize = 275.;
    
    BOOL supportStroke = YES;
    float stroke = 0.0;
    if (supportStroke) {
        stroke = 4.0;
    }
    
    
    CGRect rectangle = CGRectMake(0, 0, rectSize-2*stroke, rectSize-2*stroke);

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(275, 275), false, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, CGRectMake(0, 0, rectSize, rectSize));
    
    CGContextSaveGState(context);
    
    //set rect size for draw
    
    // offset the draw to allow the line thickness to not get clipped
    if (supportStroke) {
        CGContextTranslateCTM(context, stroke, stroke);
    }
    
    //Rounded rectangle
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetFillColorWithColor(context, UIColor.greenColor.CGColor);
    
    //Rectangle from Fours Bezier Curves
    UIBezierPath *bezierCurvePath = [UIBezierPath bezierPath];
    if (supportStroke) {
        bezierCurvePath.lineWidth = 4.0;
    }

    //set coner points
    float radius = 8.0;
    CGPoint topLPoint = CGPointMake(CGRectGetMinX(rectangle), CGRectGetMinY(rectangle));
    topLPoint.x += radius;
    topLPoint.y += radius;
    
    CGPoint topRPoint = CGPointMake(CGRectGetMaxX(rectangle), CGRectGetMinY(rectangle));
    topRPoint.x -= radius;
    topRPoint.y += radius;
    
    CGPoint botLPoint = CGPointMake(CGRectGetMinX(rectangle), CGRectGetMaxY(rectangle));
    botLPoint.x += radius;
    botLPoint.y -= radius;
    
    CGPoint botRPoint = CGPointMake(CGRectGetMaxX(rectangle), CGRectGetMaxY(rectangle));
    botRPoint.x -= radius;
    botRPoint.y -= radius;
    
//    //set start-end points
    CGPoint midRPoint = CGPointMake(CGRectGetMaxX(rectangle), CGRectGetMidY(rectangle));
    CGPoint botMPoint = CGPointMake(CGRectGetMidX(rectangle), CGRectGetMaxY(rectangle));
    CGPoint topMPoint = CGPointMake(CGRectGetMidX(rectangle), CGRectGetMinY(rectangle));
    CGPoint midLPoint = CGPointMake(CGRectGetMinX(rectangle), CGRectGetMidY(rectangle));
    

    //Four Bezier Curve
    [bezierCurvePath moveToPoint:midLPoint];
    [bezierCurvePath addQuadCurveToPoint:CGPointMake(midLPoint.x+5, midLPoint.y/4) controlPoint:CGPointMake(midLPoint.x+10, midLPoint.y/2)];
    
    [bezierCurvePath moveToPoint:CGPointMake(midLPoint.x+10, midLPoint.y/2)];
    [bezierCurvePath addCurveToPoint:topMPoint controlPoint1:topLPoint controlPoint2:topLPoint];
    [bezierCurvePath moveToPoint:topMPoint];
    [bezierCurvePath addCurveToPoint:midRPoint controlPoint1:topRPoint controlPoint2:topRPoint];
    [bezierCurvePath moveToPoint:midRPoint];
    [bezierCurvePath addCurveToPoint:botMPoint controlPoint1:botRPoint controlPoint2:botRPoint];
    [bezierCurvePath moveToPoint:botMPoint];
    [bezierCurvePath addCurveToPoint:midLPoint controlPoint1:botLPoint controlPoint2:botLPoint];

    [bezierCurvePath stroke];
    [bezierCurvePath fill];
    
    CGContextSetFillColorWithColor(context, UIColor.yellowColor.CGColor);
    UIBezierPath *testPath = [UIBezierPath bezierPath];
    [testPath moveToPoint: midLPoint];
    [testPath addLineToPoint: topMPoint];
    [testPath addLineToPoint: midRPoint];
    [testPath addLineToPoint: botMPoint];
    [testPath closePath];
    [testPath fill];
    [bezierCurvePath appendPath: testPath];
    
    //  UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    CGContextRestoreGState(context);

    UIGraphicsEndImageContext();
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = bezierCurvePath.CGPath;
    
    
    [self.view.layer addSublayer:shapeLayer];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-rectSize)/2, (SCREEN_HEIGHT-rectSize)/2, rectSize, rectSize)];
    imgView.image = [UIImage imageNamed:@"avatar"];
    imgView.backgroundColor = UIColor.orangeColor;
    imgView.layer.mask = shapeLayer;
    
    //  [self.view addSubview: imgView];
    
    /*
    tbHeight = SCREEN_WIDTH;
    imgView = [[UIImageView alloc] init];
    imgView.image = [UIImage imageNamed:@"messi.jpg"];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview: imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(tbHeight);
    }];
    
    scvContent = [[UIScrollView alloc] init];
    scvContent.delegate = self;
    scvContent.backgroundColor = UIColor.clearColor;
    scvContent.contentSize = CGSizeMake(SCREEN_WIDTH, 1200);
    scvContent.translatesAutoresizingMaskIntoConstraints  = NO;
    [self.view addSubview: scvContent];
    [scvContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.bottom.left.equalTo(self.view);
        make.width.mas_equalTo(SCREEN_WIDTH);
    }];
    
    tbView = [[UITableView alloc] init];
    tbView.backgroundColor = UIColor.orangeColor;
    [scvContent addSubview: tbView];
    [tbView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(scvContent).offset(tbHeight/2);
        make.left.equalTo(scvContent);
        make.height.mas_equalTo(500.0);
        make.width.mas_equalTo(SCREEN_WIDTH);
    }]; */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableview Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"Article %d", (int)indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"%f", scrollView.contentOffset.y);
    if (scrollView.contentOffset.y <= 0) {
        [imgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
        }];
    }else{
        if (scrollView.contentOffset.y < tbHeight/2) {
            [imgView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view).offset(-scrollView.contentOffset.y);
            }];
        }else{

        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
}

@end
