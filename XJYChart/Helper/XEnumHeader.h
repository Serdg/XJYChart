//
//  XEnumHeader.h
//  RecordLife
//
//  Created by 谢俊逸 on 22/03/2017.
//  Copyright © 2017 谢俊逸. All rights reserved.
//

#ifndef XEnumHeader_h
#define XEnumHeader_h

typedef NS_ENUM(NSUInteger, XLineMode) {
  Straight,
  CurveLine,

};

typedef NS_ENUM(NSUInteger, XLineGraphMode) {
  MutiLineGraph,
  AreaLineGraph,
  StackAreaLineGraph,
};

typedef NS_ENUM(NSInteger, XLineChartOrdinateMode) {
    XLineChartOrdinateModeSingle,
    XLineChartOrdinateModeDouble
};

#endif /* XEnumHeader_h */
