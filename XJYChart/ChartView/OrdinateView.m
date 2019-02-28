//
//  OrdinateView.m
//  RecordLife
//
//  Created by 谢俊逸 on 16/03/2017.
//  Copyright © 2017 谢俊逸. All rights reserved.
//

#import "OrdinateView.h"
#import "XColor.h"
#import "XAbscissaView.h"
#import "XBaseChartConfiguration.h"
@interface OrdinateView ()

@property(nonatomic, strong) NSMutableArray<UILabel*>* labelArray;
@property(nonatomic, assign) CGFloat top;
@property(nonatomic, assign) CGFloat bottom;
@property(nonatomic, strong) XBaseChartConfiguration *configuration;

@end

@implementation OrdinateView

- (instancetype)initWithFrame:(CGRect)frame
                    topNumber:(NSNumber*)topNumber
                 bottomNumber:(NSNumber*)bottomNumber {
  if (self = [self initWithFrame:frame]) {
    self.top = topNumber.floatValue;
    self.bottom = bottomNumber.floatValue;
    self.labelArray = [NSMutableArray new];
    for (int i = 0; i < 4; i++) {
      UILabel* label = [[UILabel alloc] init];
      [self.labelArray addObject:label];
    }
    [self setupUI];
  }
  return self;
}
- (instancetype)initWithFrame:(CGRect)frame
                    topNumber:(NSNumber*)topNumber
                 bottomNumber:(NSNumber*)bottomNumber
                configuration:(XBaseChartConfiguration *)configuration {
  if (self = [self initWithFrame:frame]) {
    self.top = topNumber.floatValue;
    self.bottom = bottomNumber.floatValue;
    self.labelArray = [NSMutableArray new];
    self.configuration = configuration;
    for (int i = 0; i < self.configuration.ordinateTitles.count; i++) {
      UILabel* label = [[UILabel alloc] init];
      [self.labelArray addObject:label];
    }
    [self setupUI];
  }
  return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
  }
  return self;
}

- (void)setupUI {
  if (!self.configuration.isShowOrdinate) {
    return ;
  }
  [self.labelArray
      enumerateObjectsUsingBlock:^(UILabel* _Nonnull obj, NSUInteger idx,
                                   BOOL* _Nonnull stop) {
        CGFloat width = self.frame.size.width;
        
        //
        CGFloat newH = ((self.frame.size.height - AbscissaHeight)/(self.labelArray.count - 1)) * (self.labelArray.count - idx - 1);
          
        obj.frame = CGRectMake(0, newH, width, 15);

          obj.font = self.configuration.titlesFont;
        obj.textColor = self.configuration.titlesColor;
          if (idx < self.configuration.ordinateTitles.count) {
              obj.text = self.configuration.ordinateTitles[idx];
          }
        obj.textAlignment = NSTextAlignmentCenter;
        obj.backgroundColor = [UIColor clearColor];

        [self addSubview:obj];
      }];
}

@end
