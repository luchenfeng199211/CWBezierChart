//
//  CWBezierChartView.h
//  CWBezierChart
//
//  Created by moonmark on 2017/8/18.
//  Copyright © 2017年 ChrisWei. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ChangePointTypeAll = 0,
    ChangePointTypeHeader,
    ChangePointTypeShoulder,
} ChangePointType;

@protocol CWBezierChartDelegate <NSObject>

- (void)bezierChartSelectPointCount:(NSInteger)pointCount;

@end

@interface CWBezierChartView : UIView

@property (nonatomic, strong) NSArray *pressureDatas;
@property (nonatomic, strong) NSArray *heightPoints;
@property (nonatomic, strong) NSArray *heightDatas;
@property (nonatomic, weak) id <CWBezierChartDelegate> delegate;

- (void)showAllLine;
- (void)showAllTitle;
- (void)showLineWithTag:(NSInteger)tag;

- (void)hiddenAllTitle;
- (void)showTitleWithTag:(NSInteger)tag;

- (void)selectPointWithIndex:(NSInteger)index;
@end

