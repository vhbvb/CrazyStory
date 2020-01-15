//
//  MAXCommodityView.h
//  CrazyStory
//
//  Created by youzu_Max on 2017/3/16.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    MAXCommodityType_100Ink,
    MAXCommodityType_250Ink,
    MAXCommodityType_500Ink,
    MAXCommodityType_1000Ink
} MAXCommodityType;

@interface MAXCommodityView : UIView

@property (nonatomic, assign) MAXCommodityType commodityType ;
@property (nonatomic, assign ,getter=isSelected) BOOL select ;

- (void)addTapGestureRecognizerWithTarget:(id)target action:(SEL)selector ;

@end
