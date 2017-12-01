//
//  ViewController.m
//  CWBezierChart
//
//  Created by moonmark on 2017/8/18.
//  Copyright © 2017年 ChrisWei. All rights reserved.
//

#import "ViewController.h"

#import "CWBezierChartView.h"

@interface ViewController () <CWBezierChartDelegate>
{
    NSInteger         _selectPoint;
    BOOL              _changeOne;
}

@property (nonatomic, strong) CWBezierChartView *bezierChartView;

@property (nonatomic, strong) NSArray           *pointCounts;
@property (nonatomic, strong) NSMutableArray    *pointDatas;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)[self colorWithHex:0x00111a].CGColor, (__bridge id)[self colorWithHex:0x002b59].CGColor];
    gradientLayer.locations = @[@0.3, @0.5, @1.0];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1.0);
    gradientLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.view.layer addSublayer:gradientLayer];
    // Do any additional setup after loading the view, typically from a nib.
    [self initDatas];
    
    CGFloat curHeight = 160;
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 100, self.view.bounds.size.width - 20, curHeight)];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.alpha = 0.2;
    [self.view addSubview:bgView];
    
    self.bezierChartView = [[CWBezierChartView alloc] initWithFrame:CGRectMake(10, 100, self.view.bounds.size.width - 20, curHeight + 30)];
    self.bezierChartView.backgroundColor = [UIColor clearColor];
    self.bezierChartView.heightPoints = self.pointCounts;
    self.bezierChartView.heightDatas = self.pointDatas;
    self.bezierChartView.delegate = self;
    [self.view addSubview:self.bezierChartView];
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(self.view.frame.size.width/2.0 - 50, 350, 100, 40);
    addBtn.backgroundColor = [UIColor redColor];
    [addBtn setTitle:@"up" forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addBtn];
    UIButton *cutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cutBtn.frame = CGRectMake(self.view.frame.size.width/2.0 - 50, 400, 100, 40);
    cutBtn.backgroundColor = [UIColor blueColor];
    [cutBtn setTitle:@"down" forState:UIControlStateNormal];
    [cutBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cutBtn];
    
    UIButton *resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    resetBtn.frame = CGRectMake(self.view.frame.size.width/2.0 - 50, 450, 100, 40);
    resetBtn.backgroundColor = [UIColor blueColor];
    [resetBtn setTitle:@"reset" forState:UIControlStateNormal];
    [resetBtn addTarget:self action:@selector(resetClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetBtn];
    
    
    addBtn.tag = 10001;
    cutBtn.tag = 10002;
}

- (void)resetClick
{
    _selectPoint = 0;
    _changeOne = NO;
    
    self.bezierChartView.heightPoints = self.pointCounts;
    self.bezierChartView.heightDatas = self.pointDatas;
    [self.bezierChartView showAllLine];
    [self.bezierChartView hiddenAllTitle];
}

- (void)initDatas
{
    self.pointCounts = @[@0, @1, @3, @4, @6, @10];
    self.pointDatas = [[NSMutableArray alloc] initWithArray:@[@24,@40,@35,@28,@25,@36,@26,@40,@15,@28,@35,@26]];
    
    _selectPoint = 0;
    _changeOne = NO;
}

- (void)btnClick:(UIButton *)btn
{
    NSLog(@"告诉view改变点的高度");
    if (btn.tag == 10001) {
        if (_changeOne) {
            int curInt = [self.pointDatas[_selectPoint] intValue];
            if (curInt < 99) {
                curInt++;
                [self.pointDatas replaceObjectAtIndex:_selectPoint withObject:[NSNumber numberWithInt:curInt]];
            }
        } else {
            for (int i = 0; i < self.pointDatas.count; i++) {
                int curInt = [self.pointDatas[i] intValue];
                if (curInt < 99) {
                    curInt++;
                    [self.pointDatas replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:curInt]];
                }
            }
        }
    }else{
        if (_changeOne) {
            int curInt = [self.pointDatas[_selectPoint] intValue];
            if (curInt > 0) {
                curInt--;
                [self.pointDatas replaceObjectAtIndex:_selectPoint withObject:[NSNumber numberWithInt:curInt]];
            }
        } else {
            for (int i = 0; i < self.pointDatas.count; i++) {
                int curInt = [self.pointDatas[i] intValue];
                if (curInt > 0) {
                    curInt--;
                    [self.pointDatas replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:curInt]];
                }
            }
        }
    }
    self.bezierChartView.heightPoints = self.pointCounts;
    self.bezierChartView.heightDatas = self.pointDatas;
    if (_changeOne) {
        [self.bezierChartView showLineWithTag:_selectPoint];
        [self.bezierChartView showTitleWithTag:_selectPoint];
    } else {
        [self.bezierChartView showAllLine];
        [self.bezierChartView hiddenAllTitle];
    }
}

#pragma mark - BezierChart Delegate
- (void)bezierChartSelectPointCount:(NSInteger)pointCount
{
    _selectPoint = pointCount;
    _changeOne = YES;
    NSLog(@"点击了第%ld个,数据为%d",pointCount,[_pointDatas[pointCount] intValue]);
}

/*---------------------------------------------------------------------------------------------------------*/
- (UIColor*) colorWithHex:(long)hexColor;
{
    return [self colorWithHex:hexColor alpha:1.0];
}

- (UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity
{
    float red = ((float)((hexColor & 0xFF0000) >> 16))/255.0;
    float green = ((float)((hexColor & 0xFF00) >> 8))/255.0;
    float blue = ((float)(hexColor & 0xFF))/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:opacity];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

