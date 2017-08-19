//
//  CWBezierChartView.m
//  CWBezierChart
//
//  Created by moonmark on 2017/8/18.
//  Copyright © 2017年 ChrisWei. All rights reserved.
//

#import "CWBezierChartView.h"

@interface CWBezierChartView ()

@property (nonatomic, strong) CAShapeLayer              *bgShapeLayer;
@property (nonatomic, strong) CAShapeLayer              *lineLayer;
@property (nonatomic, strong) NSMutableArray            *pointArray;
@property (nonatomic, strong) UIView                    *chartBgView;

@end

@implementation CWBezierChartView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.pointArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)drawBezierChart
{
    [self drawBgLayer];
    [self drawChartLayer];
}

- (void)drawBgLayer
{
    //背景画板
    UIBezierPath *curPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    self.bgShapeLayer = [CAShapeLayer layer];
    self.bgShapeLayer.fillColor = [UIColor clearColor].CGColor;
    self.bgShapeLayer.lineWidth = 1;
    self.bgShapeLayer.path = curPath.CGPath;
    [self.chartBgView.layer addSublayer:self.bgShapeLayer];
}

- (void)drawChartLayer
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGFloat standardValue = 80;
    CGPoint oldPoint = CGPointMake(0, self.frame.size.height - self.frame.size.height/100 * standardValue);
    CGPoint newPoint;
    [path moveToPoint:oldPoint];
    
    if (_pointArray.count) {
        for (int i = 0; i < _pointArray.count; i++) {
            if (i == 0) {
                newPoint = CGPointFromString(_pointArray[i]);
            } else {
                oldPoint = CGPointFromString(_pointArray[i - 1]);
                newPoint = CGPointFromString(_pointArray[i]);
            }
            [path addCurveToPoint:newPoint controlPoint1:CGPointMake((newPoint.x+oldPoint.x)/2, oldPoint.y) controlPoint2:CGPointMake((newPoint.x+oldPoint.x)/2, newPoint.y)];
        }
        oldPoint = CGPointFromString([_pointArray lastObject]);
        newPoint = CGPointMake(self.frame.size.width, self.frame.size.height - self.frame.size.height/100 * standardValue);
        [path addCurveToPoint:newPoint controlPoint1:CGPointMake((newPoint.x+oldPoint.x)/2, oldPoint.y) controlPoint2:CGPointMake((newPoint.x+oldPoint.x)/2, newPoint.y)];
    } else {
        newPoint = CGPointMake(self.frame.size.width, self.frame.size.height - self.frame.size.height/100 * standardValue);
        [path addLineToPoint:newPoint];
    }
    
    self.lineLayer = [[CAShapeLayer alloc] init];
    self.lineLayer.path = path.CGPath;
    self.lineLayer.lineWidth = 2;
    self.lineLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.lineLayer.lineJoin = kCALineJoinRound;
    self.lineLayer.lineCap = kCALineCapRound;
    self.lineLayer.fillColor = [UIColor clearColor].CGColor;
    [self.bgShapeLayer addSublayer:self.lineLayer];
}

- (void)setDatas:(NSArray *)datas
{
    _datas = datas;
    if (self.chartBgView) {
        [self.chartBgView removeFromSuperview];
    }
    if (self.pointArray.count) {
        [self.pointArray removeAllObjects];
    }
    
    self.chartBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:self.chartBgView];
    
    if (_datas.count) {
        for (int i = 0; i < _datas.count; i++) {
            CGFloat x = self.frame.size.width/(_datas.count + 1) * (i + 1);
            CGFloat y = self.frame.size.height - self.frame.size.height/100 * [_datas[i] intValue];
            CGPoint point = CGPointMake(x, y);
            [self.pointArray addObject:NSStringFromCGPoint(point)];
            //每个拐点的点
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.chartBgView addSubview:btn];
            btn.frame = CGRectMake(0, 0, 8, 8);
            btn.tag = i;
            btn.center = point;
            btn.layer.cornerRadius = 4;
            btn.layer.masksToBounds = YES;
            btn.backgroundColor = [UIColor whiteColor];
            [btn addTarget:self action:@selector(choicePointClick:) forControlEvents:UIControlEventTouchUpInside];
            
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(btn.frame.origin.x + btn.frame.size.width/2.0, btn.frame.origin.y + btn.frame.size.height, 0.5, self.chartBgView.frame.size.height - btn.frame.origin.y - btn.frame.size.height)];
            lineView.backgroundColor = [UIColor whiteColor];
            lineView.alpha = 0.6;
            lineView.tag = i + 1000;
            [self.chartBgView addSubview:lineView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(btn.frame.origin.x + btn.frame.size.width/2.0 - 10, btn.frame.origin.y - 30, 20, 30)];
            label.backgroundColor = [UIColor redColor];
            label.tag = i + 2000;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:12];
            [self.chartBgView addSubview:label];
            label.hidden = YES;
        }
    }
    [self drawBezierChart];
}

- (void)showAllLine
{
    for (int i = 0; i < _datas.count; i++) {
        UIView *curView = [self.chartBgView viewWithTag:1000+i];
        curView.hidden = NO;
    }
}

- (void)showLineWithTag:(NSInteger)tag
{
    for (int i = 0; i < _datas.count; i++) {
        UIView *curView = [self.chartBgView viewWithTag:1000+i];
        if (tag == i) {
            curView.hidden = NO;
        } else {
            curView.hidden = YES;
        }
    }
}

- (void)showTitleWithTag:(NSInteger)tag
{
    for (int i = 0; i < _datas.count; i++) {
        UILabel *curTitle = [self.chartBgView viewWithTag:2000+i];
        if (tag == i) {
            curTitle.hidden = NO;
            curTitle.text = [NSString stringWithFormat:@"%@",_datas[i]];
        } else {
            curTitle.hidden = YES;
        }
    }
}

- (void)hiddenAllTitle
{
    for (int i = 0; i < _datas.count; i++) {
        UILabel *curTitle = [self.chartBgView viewWithTag:2000+i];
        curTitle.hidden = YES;
    }
}

#pragma mark - Btn Click
- (void)choicePointClick:(UIButton *)btn
{
    [self showLineWithTag:btn.tag];
    [self showTitleWithTag:btn.tag];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(bezierChartSelectPointCount:)]) {
        [self.delegate bezierChartSelectPointCount:btn.tag];
    }
}



@end
