//
//  UIImage+MAXExtend.h
//  CrazyStory
//
//  Created by youzu_Max on 2017/2/15.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MAXExtend)

- (UIImage*)imageScaledToSize:(CGSize)newSize ;

+ (void)getHeadImageForUser:(AVUser *)user result:(void(^)(UIImage *,NSError *))result ;

@end
