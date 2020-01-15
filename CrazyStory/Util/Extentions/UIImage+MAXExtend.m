//
//  UIImage+MAXExtend.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/2/15.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "UIImage+MAXExtend.h"

@implementation UIImage (MAXExtend)

- (UIImage*)imageScaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [self drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (void)getHeadImageForUser:(AVUser *)user result:(void(^)(UIImage *,NSError *))result
{
    
    NSString *objectId = [user[kUserPropertyHeadImage] objectId] ;
    if (objectId)
    {
        AVQuery * query = [AVQuery queryWithClassName:@"_File"];
        [query whereKey:@"objectId" equalTo:objectId];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (!error && objects && objects.count) {
                AVObject * obj = objects[0];
                AVFile *file = [AVFile fileWithAVObject:obj];
                [file getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error)
                 {
                     if (data) {
                         UIImage * image = [UIImage imageWithData:data];
                         UIImage * circleImg = [image circleImageWithBorderWidth:1 borderColor:[UIColor whiteColor]];
                         result(circleImg,nil);
                     }
                     else
                     {
                         if (result) {
                             result(nil,error);
                         }
                     }
                 }];
            }
            else
            {
                if (result) {
                    result(nil,error);
                }
            }
        }];
    }
    else
    {
        if (result) {
            result(nil,nil);
        }
    }
}

- (instancetype)circleImageWithBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor
{
    CGFloat imageW = self.size.width + 2 * borderWidth;
    CGFloat imageH = self.size.height + 2 * borderWidth;
    CGSize imageSize = CGSizeMake(imageW, imageH);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [borderColor set];
    CGFloat bigRadius = imageW * 0.5; // 大圆半径
    CGFloat centerX = bigRadius; // 圆心
    CGFloat centerY = bigRadius;
    CGContextAddArc(ctx, centerX, centerY, bigRadius, 0, M_PI * 2, 0);
    CGContextFillPath(ctx); // 画圆
    
    CGFloat smallRadius = bigRadius - borderWidth;
    CGContextAddArc(ctx, centerX, centerY, smallRadius, 0, M_PI * 2, 0);
    CGContextClip(ctx);
    
    [self drawInRect:CGRectMake(borderWidth, borderWidth, self.size.width, self.size.height)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
