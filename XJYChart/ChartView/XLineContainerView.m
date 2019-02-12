//
//  XLineContainerView.m
//  RecordLife
//
//  Created by 谢俊逸 on 17/03/2017.
//  Copyright © 2017 谢俊逸. All rights reserved.
//
// macOS  和 iOS 的坐标系问题

#import "XLineContainerView.h"
#import "XAuxiliaryCalculationHelper.h"
#import "XColor.h"
#import "XAnimationLabel.h"
#import "XAnimation.h"
#import "XPointDetect.h"
#import "CALayer+XLayerSelectHelper.h"
#import "CAShapeLayer+XLayerHelper.h"
#import "XJYNumberLabelDecoration.h"
#pragma mark - Macro

#define LineWidth 4.0
#define PointDiameter 10.0
#define ExpandMaxCount 5

// Control Touch Area
CGFloat touchLineWidth = 20;

@interface XLineContainerView ()
@property(nonatomic, strong) CABasicAnimation* pathAnimation;

@property(nonatomic, strong) CAShapeLayer* coverLayer;
/**
 All lines points
 */
@property(nonatomic, strong)
    NSMutableArray<NSMutableArray<NSValue*>*>* pointsArrays;
@property(nonatomic, strong) NSMutableArray<CAShapeLayer*>* shapeLayerArray;
@property(nonatomic, strong) NSMutableArray<CAShapeLayer*>* pointLayerArray;
@property(nonatomic, strong) XJYNumberLabelDecoration* numberLabelDecoration;
@property (nonatomic, strong) NSArray <NSValue *> *pointsForHightlight;
@end

@implementation XLineContainerView

- (instancetype)initWithFrame:(CGRect)frame
                dataItemArray:(NSMutableArray<XLineChartItem*>*)dataItemArray
                    topNumber:(NSNumber*)topNumber
                 bottomNumber:(NSNumber*)bottomNumber
                configuration:(XNormalLineChartConfiguration*)configuration {
  if (self = [super initWithFrame:frame]) {
    self.configuration = configuration;
    self.backgroundColor = self.configuration.chartBackgroundColor;

    self.coverLayer = [CAShapeLayer layer];
    self.shapeLayerArray = [NSMutableArray new];
    self.pointsArrays = [NSMutableArray new];
    self.numberLabelDecoration = [[XJYNumberLabelDecoration alloc] initWithViewer:self];
    self.pointLayerArray = [NSMutableArray new];

    self.dataItemArray = dataItemArray;
    self.top = topNumber;
    self.bottom = bottomNumber;
  }
  return self;
}

#pragma mark - Draw

// Draw Template
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [self cleanPreDrawLayerAndData];
    
    if (self.configuration.background == XLineChartBackgroundGrid) {
        [self strokeGridInContext:contextRef];
    } else {
        [self strokeAuxiliaryLineInContext:contextRef];
    }
    
    [self strokeLineChart];
    [self strokePointInContext];
    [self strokeNumberLabels];
    [self strokeIndicatorLineWithContext:contextRef];
}

/// Stroke Auxiliary
- (void)strokeAuxiliaryLineInContext:(CGContextRef)context {
  if (self.configuration.isShowAuxiliaryDashLine) {
    CGContextSetStrokeColorWithColor(context, self.configuration.auxiliaryDashLineColor.CGColor);
    CGContextSaveGState(context);
    CGFloat lengths[2] = {5.0, 5.0};
    CGContextSetLineDash(context, 0, lengths, 2);
    CGContextSetLineWidth(context, self.configuration.auxiliaryDashLineWidth);
    for (int i = 0; i < 11; i++) {
      CGContextMoveToPoint(
                           context, 5, self.frame.size.height - (self.frame.size.height) / 11 * i);
      CGContextAddLineToPoint(
                              context, self.frame.size.width,
                              self.frame.size.height - ((self.frame.size.height) / 11) * i);
      CGContextStrokePath(context);
    }
    CGContextRestoreGState(context);
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, self.configuration.auxiliaryDashLineColor.CGColor);
  }

  
  if (self.configuration.isShowCoordinate) {
    // ordinate
    CGContextMoveToPoint(context, 5, 0);
    CGContextAddLineToPoint(context, 5, self.frame.size.height);
    CGContextStrokePath(context);
    
    // abscissa
    CGContextMoveToPoint(context, 5, self.frame.size.height);
    CGContextAddLineToPoint(context, self.frame.size.width,
                            self.frame.size.height);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    // arrow
    UIBezierPath* arrow = [[UIBezierPath alloc] init];
    arrow.lineWidth = 0.7;
    [arrow moveToPoint:CGPointMake(0, 8)];
    [arrow addLineToPoint:CGPointMake(5, 0)];
    [arrow moveToPoint:CGPointMake(5, 0)];
    [arrow addLineToPoint:CGPointMake(10, 8)];
    [[UIColor black75PercentColor] setStroke];
    arrow.lineCapStyle = kCGLineCapRound;
    [arrow stroke];
  }
}

- (void)strokeGridInContext:(CGContextRef)context {
    NSInteger horizontalLinesCount = 8;
    CGFloat verticalLinesSpacing = [UIScreen mainScreen].bounds.size.width / 8.f;
    NSInteger verticalLinesCount = self.frame.size.width / verticalLinesSpacing;
    
    CGContextSetStrokeColorWithColor(context, self.configuration.auxiliaryDashLineColor.CGColor);
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, self.configuration.auxiliaryDashLineWidth);
    
    CGContextMoveToPoint(context, 0.f, 0.f);
    CGContextAddLineToPoint(context, self.frame.size.width, 0.f);
    CGContextStrokePath(context);
    
    for (int i = 0; i < horizontalLinesCount; i++) {
        CGContextMoveToPoint(
                             context, 0, self.frame.size.height - (self.frame.size.height) / horizontalLinesCount * i);
        CGContextAddLineToPoint(
                                context, self.frame.size.width,
                                self.frame.size.height - ((self.frame.size.height) / horizontalLinesCount) * i);
        CGContextStrokePath(context);
    }
    
    CGFloat xPos = 0.f;
    for (int i = 0; i < verticalLinesCount + 2; i++) {
        CGContextMoveToPoint(context, xPos, 0);
        CGContextAddLineToPoint(context, xPos, self.frame.size.height);
        CGContextStrokePath(context);
        
        xPos = verticalLinesSpacing * (CGFloat) i;
    }
    
    CGContextMoveToPoint(context, self.frame.size.width, 0.f);
    CGContextAddLineToPoint(context, self.frame.size.width, self.frame.size.height);
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, self.configuration.auxiliaryDashLineColor.CGColor);
}

- (void)strokeIndicatorLineWithContext:(CGContextRef)contextRef {
    if (!self.pointsForHightlight.count) {
        return;
    }
    
    CGPoint highlightablePoint = self.pointsForHightlight.firstObject.CGPointValue;
    if (highlightablePoint.x == CGFLOAT_MIN) {
        for (NSValue *pointValue in self.pointsForHightlight) {
            CGPoint point = pointValue.CGPointValue;
            if (point.x != CGFLOAT_MIN) {
                highlightablePoint = point;
                break;
            }
        }
    }
    
    if (highlightablePoint.x == CGFLOAT_MIN) {
        return;
    }
    
    UIColor *indicatorColor = self.configuration.indicatorLineColor ? self.configuration.indicatorLineColor : [UIColor redColor];
    
    CGContextSetStrokeColorWithColor(contextRef, indicatorColor.CGColor);
    CGContextSaveGState(contextRef);
    CGContextSetLineWidth(contextRef, 1.f);
    
    CGContextMoveToPoint(contextRef, highlightablePoint.x, 0.f);
    CGContextAddLineToPoint(contextRef, highlightablePoint.x, self.frame.size.height);
    CGContextStrokePath(contextRef);
    
    for (NSValue *pointValue in self.pointsForHightlight) {
        CGPoint point = pointValue.CGPointValue;
        
        if (point.x == CGFLOAT_MIN) {
            continue;
        }
        
        UIColor *color = self.dataItemArray[[self.pointsForHightlight indexOfObject:pointValue]].color;
        CAShapeLayer* pointLayer = [CAShapeLayer pointLayerWithDiameter:PointDiameter color:color center:point];
        [self.pointLayerArray addObject:pointLayer];
        [self.layer addSublayer:pointLayer];
    }
}

- (void)cleanPreDrawLayerAndData {
  [self.coverLayer removeFromSuperlayer];
  [self.shapeLayerArray
      enumerateObjectsUsingBlock:^(CAShapeLayer* _Nonnull obj, NSUInteger idx,
                                   BOOL* _Nonnull stop) {
        [obj removeFromSuperlayer];
      }];

  [self.numberLabelDecoration removeNumberLabels];
  
  [self.pointLayerArray enumerateObjectsUsingBlock:^(CAShapeLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    [obj removeFromSuperlayer];
  }];

  [self.pointsArrays removeAllObjects];
  [self.shapeLayerArray removeAllObjects];
  [self.pointLayerArray removeAllObjects];
}

/// Stroke Point
- (void)strokePointInContext {
  
  if (self.configuration.isShowPoint) {
    self.pointsArrays = [self getPointsArrays];
    [self.pointsArrays enumerateObjectsUsingBlock:^(NSMutableArray* _Nonnull obj,
                                                    NSUInteger idx,
                                                    BOOL* _Nonnull stop) {
      
      UIColor *color = self.dataItemArray[idx].color;
      
      [obj enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx,
                                        BOOL* _Nonnull stop) {
        NSValue* pointValue = obj;
        CGPoint point = pointValue.CGPointValue;
        /// Change To CALayer
        CAShapeLayer* pointLayer = [CAShapeLayer pointLayerWithDiameter:PointDiameter color:color center:point];
        
        [self.pointLayerArray addObject:pointLayer];
        [self.layer addSublayer:pointLayer];
        
      }];
    }];
  }

}

/// Stroke Line
- (void)strokeLineChart {
  self.pointsArrays = [self getPointsArrays];
  [self.pointsArrays enumerateObjectsUsingBlock:^(NSMutableArray* _Nonnull obj,
                                                  NSUInteger idx,
                                                  BOOL* _Nonnull stop) {

    [self.shapeLayerArray
          addObject:[self lineShapeLayerWithPoints:obj
                                            colors:self.dataItemArray[idx].color
                                          lineMode:self.configuration.lineMode]];
  }];

  [self.shapeLayerArray
      enumerateObjectsUsingBlock:^(CAShapeLayer* _Nonnull obj, NSUInteger idx,
                                   BOOL* _Nonnull stop) {
        [self.layer addSublayer:obj];
      }];
}


// 绘制number label
- (void)strokeNumberLabels {
  if (!self.configuration.isEnableNumberLabel) {
    return;
  }
  
  for (int i = 0; i < self.pointsArrays.count; i++) {
    [self.numberLabelDecoration drawWithPoints:self.pointsArrays[i] TextNumbers:self.dataItemArray[i].numberArray isEnableAnimation:self.configuration.isEnableNumberAnimation];
  }
}



// compute Points Arrays
- (NSMutableArray<NSMutableArray<NSValue*>*>*)getPointsArrays {
  // 避免重复计算
  if (self.pointsArrays.count > 0) {
    return self.pointsArrays;
  } else {
    NSMutableArray* pointsArrays = [NSMutableArray new];
    // Get Points
    [self.dataItemArray enumerateObjectsUsingBlock:^(
                            XLineChartItem* _Nonnull obj, NSUInteger idx,
                            BOOL* _Nonnull stop) {
      NSMutableArray* numberArray = obj.numberArray;
      NSMutableArray* linePointArray = [NSMutableArray new];
      [obj.numberArray enumerateObjectsUsingBlock:^(NSNumber* _Nonnull obj,
                                                    NSUInteger idx,
                                                    BOOL* _Nonnull stop) {
        CGPoint point = [self calculateDrawablePointWithNumber:obj
                                                           idx:idx
                                                         count:numberArray.count
                                                        bounds:self.bounds];
        NSValue* pointValue = [NSValue valueWithCGPoint:point];
        [linePointArray addObject:pointValue];
      }];
      [pointsArrays addObject:linePointArray];
    }];
    return pointsArrays;
  }
}

#pragma mark Helper
/**
 计算点通过 数值 和 idx

 @param number number
 @param idx like 0.1.2.3...
 @return CGPoint
 */
// Calculate -> Point
- (CGPoint)calculateDrawablePointWithNumber:(NSNumber*)number
                                        idx:(NSUInteger)idx
                                      count:(NSUInteger)count
                                     bounds:(CGRect)bounds {
  CGFloat percentageH = [[XAuxiliaryCalculationHelper shareCalculationHelper]
      calculateTheProportionOfHeightByTop:self.top.doubleValue
                                   bottom:self.bottom.doubleValue
                                   height:number.doubleValue];
  CGFloat percentageW = [[XAuxiliaryCalculationHelper shareCalculationHelper]
      calculateTheProportionOfWidthByIdx:(idx)
                                   count:count];
  CGFloat pointY = percentageH * bounds.size.height;
  CGFloat pointX = percentageW * bounds.size.width;
  CGPoint point = CGPointMake(pointX, pointY);
  CGPoint rightCoordinatePoint =
      [[XAuxiliaryCalculationHelper shareCalculationHelper]
          changeCoordinateSystem:point
                  withViewHeight:self.frame.size.height];
  return rightCoordinatePoint;
}

- (CAShapeLayer*)lineShapeLayerWithPoints:
                     (NSMutableArray<NSValue*>*)pointsValueArray
                                   colors:(UIColor*)color
                                 lineMode:(XLineMode)lineMode {
  UIBezierPath* line = [[UIBezierPath alloc] init];

  CAShapeLayer* chartLine = [CAShapeLayer layer];
  chartLine.lineCap = kCALineCapRound;
  chartLine.lineJoin = kCALineJoinRound;
  chartLine.lineWidth = self.configuration.lineWidth;

  for (int i = 0; i < pointsValueArray.count - 1; i++) {
    CGPoint point1 = pointsValueArray[i].CGPointValue;

    CGPoint point2 = pointsValueArray[i + 1].CGPointValue;
    [line moveToPoint:point1];

    if (lineMode == Straight) {
      [line addLineToPoint:point2];
    } else if (lineMode == CurveLine) {
      CGPoint midPoint = [[XAuxiliaryCalculationHelper shareCalculationHelper]
          midPointBetweenPoint1:point1
                      andPoint2:point2];
      [line addQuadCurveToPoint:midPoint
                   controlPoint:[[XAuxiliaryCalculationHelper
                                    shareCalculationHelper]
                                    controlPointBetweenPoint1:midPoint
                                                    andPoint2:point1]];
      [line addQuadCurveToPoint:point2
                   controlPoint:[[XAuxiliaryCalculationHelper
                                    shareCalculationHelper]
                                    controlPointBetweenPoint1:midPoint
                                                    andPoint2:point2]];
    } else {
      [line addLineToPoint:point2];
    }

    //当前线段的四个点
    CGPoint rectPoint1 =
        CGPointMake(point1.x - LineWidth / 2, point1.y - LineWidth / 2);
    NSValue* value1 = [NSValue valueWithCGPoint:rectPoint1];
    CGPoint rectPoint2 =
        CGPointMake(point1.x - LineWidth / 2, point1.y + LineWidth / 2);
    NSValue* value2 = [NSValue valueWithCGPoint:rectPoint2];
    CGPoint rectPoint3 =
        CGPointMake(point2.x + LineWidth / 2, point2.y - LineWidth / 2);
    NSValue* value3 = [NSValue valueWithCGPoint:rectPoint3];
    CGPoint rectPoint4 =
        CGPointMake(point2.x + LineWidth / 2, point2.y + LineWidth / 2);
    NSValue* value4 = [NSValue valueWithCGPoint:rectPoint4];

    //当前线段的矩形组成点
    NSMutableArray<NSValue*>* segementPointsArray = [NSMutableArray new];
    [segementPointsArray addObject:value1];
    [segementPointsArray addObject:value2];
    [segementPointsArray addObject:value3];
    [segementPointsArray addObject:value4];

    //把当前线段的矩形组成点数组添加到 数组中
    if (chartLine.segementPointsArrays == nil) {
      chartLine.segementPointsArrays = [[NSMutableArray alloc] init];
      [chartLine.segementPointsArrays addObject:segementPointsArray];
    } else {
      [chartLine.segementPointsArrays addObject:segementPointsArray];
    }
  }

  chartLine.path = line.CGPath;
  chartLine.strokeStart = 0.0;
  chartLine.strokeEnd = 1.0;
  chartLine.opacity = 0.6;
  chartLine.strokeColor = color.CGColor;
  chartLine.fillColor = [UIColor clearColor].CGColor;
  
  
  if (self.configuration.isShowShadow) {
    // shadow
    chartLine.shadowColor = [UIColor blackColor].CGColor;
    chartLine.shadowOpacity = 0.45f;
    chartLine.shadowOffset = CGSizeMake(0.0f, 6.0f);
    chartLine.shadowRadius = 5.0f;
    chartLine.masksToBounds = NO;
  } else {
    [chartLine addAnimation:self.pathAnimation forKey:@"strokeEndAnimation"];
  }
  
  // selectedStatus
  chartLine.selectStatusNumber = [NSNumber numberWithBool:NO];

  return chartLine;
}

- (CAShapeLayer*)coverShapeLayerWithPath:(CGPathRef)path color:(UIColor*)color {
  CAShapeLayer* chartLine = [CAShapeLayer layer];
  chartLine.lineCap = kCALineCapRound;
  chartLine.lineJoin = kCALineJoinRound;
  chartLine.lineWidth = LineWidth * 1.5;
  chartLine.path = path;
  chartLine.strokeStart = 0.0;
  chartLine.strokeEnd = 1.0;
  chartLine.strokeColor = color.CGColor;
  chartLine.fillColor = [UIColor clearColor].CGColor;
  chartLine.opacity = 0.8;

  return chartLine;
}

- (CABasicAnimation*)pathAnimation {
  _pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
  _pathAnimation.duration = 3.0;
  _pathAnimation.timingFunction = [CAMediaTimingFunction
      functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  _pathAnimation.fromValue = @0.0f;
  _pathAnimation.toValue = @1.0f;
  return _pathAnimation;
}

#pragma mark - Touch
- (void)removePreHiglightDraw {
  [self.numberLabelDecoration removeNumberLabels];
  [self.coverLayer removeFromSuperlayer];
}

- (void)findXIdx:(int *)areaIdx point:(const CGPoint *)point {
  NSArray<NSValue*>* points = self.pointsArrays.lastObject;
  for (int i = 0; i < points.count - 1; i++) {
    if (point->x >= points[i].CGPointValue.x &&
        point->x <= points[i + 1].CGPointValue.x) {
      *areaIdx = i;
    }
  }
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event {
    CGPoint point = [[touches anyObject] locationInView:self];
    self.pointsForHightlight = [self findNearestPointsForPoint:point];
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.pointsForHightlight = @[];
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

#pragma mark - Helpers

- (NSArray <NSValue *> *)findNearestPointsForPoint:(CGPoint)point {
    NSMutableArray *results = [NSMutableArray array];
    
    for (NSMutableArray <NSValue *> *points in self.pointsArrays) {
        CGFloat distance = CGFLOAT_MAX;
        NSInteger index = NSNotFound;
        
        for (NSValue *value in points) {
            CGPoint aPoint = value.CGPointValue;
            if (fabs(aPoint.x - point.x) < distance) {
                index = [points indexOfObject:value];
                distance = fabs(aPoint.x - point.x);
            }
        }
        
        NSInteger itemIndex = [self.pointsArrays indexOfObject:points];
        
        if ([self.delegate canHighlightPointAtIndex:index forLineAtIndex:itemIndex]) {
            [results addObject:points[index]];            
            if ([self.delegate respondsToSelector:@selector(lineChart:didHighlightPointAtIndex:forLineAtIndex:)]) {
                [self.delegate lineChart:self.chart didHighlightPointAtIndex:index forLineAtIndex:itemIndex];
            }
        } else {
            [results addObject:[NSValue valueWithCGPoint:CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN)]];
        }
    }
    
    return results;
}

#pragma mark - Configuration

- (XNormalLineChartConfiguration *)configuration {
  if (_configuration == nil) {
    _configuration = [[XNormalLineChartConfiguration alloc] init];
  }
  return _configuration;
}



@end
