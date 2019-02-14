//
//  XLineChartDelegate.h
//  XJYChart
//
//  Created by Alexandr Kachanov on 04/01/2019.
//  Copyright © 2019 JunyiXie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XLineChart;

extern NSString *const kLineChartPointsInfoKey;
extern NSString *const kLineChartTouchInfoKey;

NS_ASSUME_NONNULL_BEGIN

@protocol XLineChartDelegate <NSObject>
- (BOOL)canHighlightPointAtIndex:(NSInteger)pointIndex forLineAtIndex:(NSInteger)lineIndex;
@optional
- (void)lineChart:(XLineChart *)chart didSelectChartsPointsWithInfo:(NSDictionary *)info;
- (void)lineChartDidFinishTouches:(XLineChart *)chart;
@end

NS_ASSUME_NONNULL_END
