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

@property (nonatomic, strong) NSArray *datas;
@property (nonatomic, weak) id <CWBezierChartDelegate> delegate;

- (void)showAllLine;
- (void)showLineWithTag:(NSInteger)tag;

- (void)hiddenAllTitle;
- (void)showTitleWithTag:(NSInteger)tag;

@end
