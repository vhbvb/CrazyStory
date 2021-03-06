//
//  NSString+MAXCommon.h
//  CrazyStory
//
//  Created by youzu_Max on 2017/2/6.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MAXCommon)

- (BOOL)isEmpty ;

- (BOOL)isPhoneNumber ;

- (BOOL)isEmail ;

- (BOOL)isPassword ;

- (BOOL)isUserName ;

+ (NSString *)localTimeStringWithDate:(NSDate *)date ;

/**
 获取文字长度

 @return 字数
 */
- (NSInteger)charNumber ;
@end
