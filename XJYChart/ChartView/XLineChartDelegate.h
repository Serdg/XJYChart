//
//  XLineChartDelegate.h
//  XJYChart
//
//  Created by Alexandr Kachanov on 04/01/2019.
//  Copyright © 2019 JunyiXie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XLineChartDelegate <NSObject>
- (BOOL)canHighlightPointWithValue:(CGFloat)value forLineAtIndex:(NSInteger) index;
@end

NS_ASSUME_NONNULL_END
