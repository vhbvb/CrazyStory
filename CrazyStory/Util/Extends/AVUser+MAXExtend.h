//
//  AVUser+MAXExtend.h
//  CrazyStory
//
//  Created by youzu_Max on 2017/3/13.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>

@interface AVUser (MAXExtend)

+ (void)getOriginHeadImageForUser:(AVUser *)user result:(void (^)(UIImage *, NSError *))result ;

+ (void)getCircleHeadImageForUser:(AVUser *)user result:(void(^)(UIImage *,NSError *))result ;

+ (void)loadUserWithUsername:(NSString *)username result:(void(^)(AVUser * ,NSError *))result ;

+ (void)loadUserWithUserID:(NSString *)userID result:(void(^)(AVUser * ,NSError *))result ;

+ (instancetype)SyncLoadUserWithUserID:(NSString *)userID ;

+ (NSCache *)userCache ;

@end
