//
//  XLineChartDelegate.h
//  XJYChart
//
//  Created by Alexandr Kachanov on 04/01/2019.
//  Copyright © 2019 JunyiXie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XLineChart;

NS_ASSUME_NONNULL_BEGIN

@protocol XLineChartDelegate <NSObject>
- (BOOL)canHighlightPointWithValue:(CGFloat)value forLineAtIndex:(NSInteger) index;
- (void)lineChart:(XLineChart *)chart didHighlightPointWithValue:(CGFloat)value forLineAtIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
