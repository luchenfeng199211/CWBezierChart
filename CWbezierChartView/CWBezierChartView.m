//
//  CWBezierChartView.m
//  CWBezierChart
//
//  Created by moonmark on 2017/8/18.
//  Copyright © 2017年 ChrisWei. All rights reserved.
//

#import "CWBezierChartView.h"

static const int maxHeight = 120;
#define Bezier_Chart_Tips @[@"头部", @"肩部", @"背部", @"腰部", @"臀部", @"腿部"]

@interface CWBezierChartView ()

@property (nonatomic, strong) CAShapeLayer              *bgShapeLayer;
@property (nonatomic, strong) CAShapeLayer              *lineLayer;
@property (nonatomic, strong) NSMutableArray            *pointArray;
@property (nonatomic, strong) UIView                    *chartBgView;

@property (nonatomic, assign) BOOL                      safeLoop;

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
        _safeLoop = YES;
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
    UIBezierPath *curPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 30)];
    
    self.bgShapeLayer = [CAShapeLayer layer];
    self.bgShapeLayer.fillColor = [UIColor clearColor].CGColor;
    self.bgShapeLayer.lineWidth = 1;
    self.bgShapeLayer.path = curPath.CGPath;
    [self.chartBgView.layer addSublayer:self.bgShapeLayer];
}

- (void)drawChartLayer
{
    CGPoint oldPoint;
    CGPoint newPoint;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    if (_pointArray.count) {
        oldPoint = CGPointMake(0, CGPointFromString(_pointArray[0]).y);
        newPoint = CGPointFromString(_pointArray.firstObject);
        [path moveToPoint:oldPoint];
        [path addCurveToPoint:newPoint controlPoint1:CGPointMake((newPoint.x+oldPoint.x)/2, oldPoint.y) controlPoint2:CGPointMake((newPoint.x+oldPoint.x)/2, newPoint.y)];
        
        CGPoint fristPoint = CGPointMake(0, CGPointFromString(_pointArray[0]).y);
        [_pointArray insertObject:NSStringFromCGPoint(fristPoint) atIndex:0];
        CGPoint curPoint = CGPointFromString([_pointArray lastObject]);
        CGPoint lastPoint = CGPointMake(self.frame.size.width, curPoint.y);
        [_pointArray addObject:NSStringFromCGPoint(lastPoint)];
        for (int i = 0; i < _pointArray.count - 3; i++) {
            CGPoint p1 = CGPointFromString([_pointArray objectAtIndex:i]);
            CGPoint p2 = CGPointFromString([_pointArray objectAtIndex:i+1]);
            CGPoint p3 = CGPointFromString([_pointArray objectAtIndex:i+2]);
            CGPoint p4 = CGPointFromString([_pointArray objectAtIndex:i+3]);
            if (i == 0) {
                [path moveToPoint:p2];
            }
            [self getControlPointx0:p1.x andy0:p1.y x1:p2.x andy1:p2.y x2:p3.x andy2:p3.y x3:p4.x andy3:p4.y path:path];
        }
        
       
//        for (int i = 0; i < _pointArray.count; i++) {
//            
//            if (i == 0) {
//                newPoint = CGPointFromString(_pointArray[i]);
//            } else {
//                oldPoint = CGPointFromString(_pointArray[i - 1]);
//                newPoint = CGPointFromString(_pointArray[i]);
//            }
//            
//            [path addCurveToPoint:newPoint controlPoint1:CGPointMake((newPoint.x+oldPoint.x)/2, oldPoint.y) controlPoint2:CGPointMake((newPoint.x+oldPoint.x)/2, newPoint.y)];
//        }
        oldPoint = CGPointFromString([_pointArray lastObject]);
        newPoint = CGPointMake(self.frame.size.width, oldPoint.y);
        [path addCurveToPoint:newPoint controlPoint1:CGPointMake((newPoint.x+oldPoint.x)/2, oldPoint.y) controlPoint2:CGPointMake((newPoint.x+oldPoint.x)/2, newPoint.y)];
    } else {
        CGFloat standardValue = 20;
        oldPoint = CGPointMake(0, self.frame.size.height/maxHeight * standardValue);
        [path moveToPoint:oldPoint];
        newPoint = CGPointMake(self.frame.size.width, self.frame.size.height/maxHeight * standardValue);
        [path addLineToPoint:newPoint];
    }
    
    self.lineLayer = [[CAShapeLayer alloc] init];
    self.lineLayer.path = path.CGPath;
    self.lineLayer.lineWidth = 1;
    self.lineLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.lineLayer.lineJoin = kCALineJoinRound;
    self.lineLayer.lineCap = kCALineCapRound;
    self.lineLayer.fillColor = [UIColor clearColor].CGColor;
    [self.bgShapeLayer addSublayer:self.lineLayer];
}

- (void)getControlPointx0:(CGFloat)x0 andy0:(CGFloat)y0
                       x1:(CGFloat)x1 andy1:(CGFloat)y1
                       x2:(CGFloat)x2 andy2:(CGFloat)y2
                       x3:(CGFloat)x3 andy3:(CGFloat)y3
                     path:(UIBezierPath*) path{
    CGFloat smooth_value = 0.6;
    CGFloat ctrl1_x;
    CGFloat ctrl1_y;
    CGFloat ctrl2_x;
    CGFloat ctrl2_y;
    CGFloat xc1 = (x0 + x1) /2.0;
    CGFloat yc1 = (y0 + y1) /2.0;
    CGFloat xc2 = (x1 + x2) /2.0;
    CGFloat yc2 = (y1 + y2) /2.0;
    CGFloat xc3 = (x2 + x3) /2.0;
    CGFloat yc3 = (y2 + y3) /2.0;
    CGFloat len1 = sqrt((x1-x0) * (x1-x0) + (y1-y0) * (y1-y0));
    CGFloat len2 = sqrt((x2-x1) * (x2-x1) + (y2-y1) * (y2-y1));
    CGFloat len3 = sqrt((x3-x2) * (x3-x2) + (y3-y2) * (y3-y2));
    CGFloat k1 = len1 / (len1 + len2);
    CGFloat k2 = len2 / (len2 + len3);
    CGFloat xm1 = xc1 + (xc2 - xc1) * k1;
    CGFloat ym1 = yc1 + (yc2 - yc1) * k1;
    CGFloat xm2 = xc2 + (xc3 - xc2) * k2;
    CGFloat ym2 = yc2 + (yc3 - yc2) * k2;
    ctrl1_x = xm1 + (xc2 - xm1) * smooth_value + x1 - xm1;
    ctrl1_y = ym1 + (yc2 - ym1) * smooth_value + y1 - ym1;
    ctrl2_x = xm2 + (xc2 - xm2) * smooth_value + x2 - xm2;
    ctrl2_y = ym2 + (yc2 - ym2) * smooth_value + y2 - ym2;
    [path addCurveToPoint:CGPointMake(x2, y2) controlPoint1:CGPointMake(ctrl1_x, ctrl1_y) controlPoint2:CGPointMake(ctrl2_x, ctrl2_y)];
}

- (void)setHeightPoints:(NSArray *)heightPoints
{
    _heightPoints = heightPoints;
    NSMutableArray *pointArray = [[NSMutableArray alloc] initWithArray:_heightPoints];
    if (self.chartBgView) {
        [self.chartBgView removeFromSuperview];
    }
    if (self.pointArray.count) {
        [self.pointArray removeAllObjects];
    }
    
    self.chartBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:self.chartBgView];
    if (_heightDatas.count) {
        for (int i = 0; i < _heightDatas.count; i++) {
            CGFloat x = self.frame.size.width/(_heightDatas.count + 1) * (i + 1);
            CGFloat pointHeight = ([_heightDatas[i] intValue] + 20);
            if (pointHeight > 99) {
                pointHeight = 99;
            }
            CGFloat y = self.frame.size.height/maxHeight * pointHeight;
            // CGFloat y = self.frame.size.height - self.frame.size.height/100 * [_datas[i] intValue];
            CGPoint point = CGPointMake(x, y);
            [self.pointArray addObject:NSStringFromCGPoint(point)];
            if ([pointArray containsObject:[NSNumber numberWithInt:i]]) {
                // 每个拐点的点
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [self.chartBgView addSubview:btn];
                btn.frame = CGRectMake(0, 0, 30, 30);
                btn.tag = i;
                btn.center = point;
                btn.backgroundColor = [UIColor clearColor];
                [btn addTarget:self action:@selector(choicePointClick:) forControlEvents:UIControlEventTouchUpInside];

                UIImageView *btnPoint = [[UIImageView alloc] initWithFrame:CGRectMake(btn.frame.size.width/2.0 - 4, btn.frame.size.height/2.0 - 4, 8, 8)];
                btnPoint.backgroundColor = [UIColor whiteColor];
                btnPoint.center = point;
                btnPoint.layer.cornerRadius = 4;
                btnPoint.layer.masksToBounds = YES;
                [self.chartBgView addSubview:btnPoint];

                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(btnPoint.frame.origin.x + btnPoint.frame.size.width/2.0, btnPoint.frame.origin.y + btnPoint.frame.size.height, 0.5, self.chartBgView.frame.size.height - btnPoint.frame.origin.y - btnPoint.frame.size.height - 30)];
                lineView.backgroundColor = [UIColor whiteColor];
                lineView.alpha = 0.6;
                lineView.tag = i + 1000;
                [self.chartBgView addSubview:lineView];

                UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(point.x - 20, lineView.frame.origin.y + lineView.frame.size.height, 40, 20)];
                NSInteger tipCount = [pointArray indexOfObject:[NSNumber numberWithInt:i]];
                tipLabel.text = Bezier_Chart_Tips[tipCount];
                tipLabel.textColor = [UIColor whiteColor];
                tipLabel.textAlignment = NSTextAlignmentCenter;
                tipLabel.font = [UIFont systemFontOfSize:12];
                [self.chartBgView addSubview:tipLabel];

                UIImageView *pointLabelImg = [[UIImageView alloc] initWithFrame:CGRectMake(btnPoint.frame.origin.x + btnPoint.frame.size.width/2.0 - 15, btnPoint.frame.origin.y - 30, 30, 30)];
                pointLabelImg.image = [UIImage imageNamed:@"ic_arrow"];
                [self.chartBgView addSubview:pointLabelImg];
                pointLabelImg.tag = 3000 + i;
                pointLabelImg.hidden = YES;

                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(btnPoint.frame.origin.x + btnPoint.frame.size.width/2.0 - 15, btnPoint.frame.origin.y - 30, pointLabelImg.frame.size.width, pointLabelImg.frame.size.height)];
                label.backgroundColor = [UIColor clearColor];
                label.tag = i + 2000;
                label.textAlignment = NSTextAlignmentCenter;
//                label.font = [UIFont fontWithName:FZLTHK_GKB_1_0 size:12];
                [self.chartBgView addSubview:label];
                label.hidden = YES;
            }
        }
    }

    [self drawBezierChart];
}

- (void)setHeightDatas:(NSArray *)heightDatas
{
    _heightDatas = heightDatas;
}

- (void)setPressureDatas:(NSArray *)pressureDatas
{
    _pressureDatas = pressureDatas;
}

- (void)showAllLine
{
    for (int i = 0; i < _pressureDatas.count; i++) {
        UIView *curView = [self.chartBgView viewWithTag:1000+i];
        curView.hidden = NO;
    }
}

- (void)showLineWithTag:(NSInteger)tag
{
    for (int i = 0; i < _pressureDatas.count; i++) {
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
    for (int i = 0; i < _pressureDatas.count; i++) {
        UILabel *curTitle = [self.chartBgView viewWithTag:2000+i];
        UIImageView *curImgView = [self.chartBgView viewWithTag:3000+i];
        if (tag == i) {
            curTitle.hidden = NO;
            curImgView.hidden = NO;
            
            curTitle.text = [NSString stringWithFormat:@"%@",_pressureDatas[i]];
        } else {
            curTitle.hidden = YES;
            curImgView.hidden = YES;
        }
    }
}

- (void)showAllTitle {
    for (int i = 0; i < _pressureDatas.count; i++) {
        UILabel *curTitle = [self.chartBgView viewWithTag:2000+i];
        UIImageView *curImgView = [self.chartBgView viewWithTag:3000+i];
        curTitle.hidden = NO;
        curImgView.hidden = NO;
        curTitle.text = [NSString stringWithFormat:@"%@",_pressureDatas[i]];
    }
}

- (void)hiddenAllTitle
{
    for (int i = 0; i < _pressureDatas.count; i++) {
        UILabel *curTitle = [self.chartBgView viewWithTag:2000+i];
        UIImageView *curImgView = [self.chartBgView viewWithTag:3000+i];
        curTitle.hidden = YES;
        curImgView.hidden = YES;
    }
}

- (void)selectPointWithIndex:(NSInteger)index
{
    UIButton *curBtn = [self.chartBgView viewWithTag:index];
    [self choicePointClick:curBtn];
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
