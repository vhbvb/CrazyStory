//
//  MAXMineCountView.h
//  CrazyStory
//
//  Created by youzu_Max on 2017/2/17.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MAXMineCountView : UIView
@property(nonatomic,copy) NSString * name ;
@property(nonatomic, assign) NSInteger count ;
@property(nonatomic, assign) BOOL selected ;

- (void)addTapGestureWithTarget:(id)target selector:(SEL)selector ;

@end
