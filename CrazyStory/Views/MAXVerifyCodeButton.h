//
//  MAXVerifyCodeButton.h
//  CrazyStory
//
//  Created by youzu_Max on 2017/3/15.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    MAXVerifyCodeButtonStateNormal,
    MAXVerifyCodeButtonStateCountdown,
    MAXVerifyCodeButtonStateDisabled
} MAXVerifyCodeButtonState;

@interface MAXVerifyCodeButton : UIView

@property (nonatomic, assign) MAXVerifyCodeButtonState state ;
- (void)addTapGestureWithTarget:(id)target action:(SEL)selector ;

@end
