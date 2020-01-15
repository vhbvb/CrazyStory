//
//  AVUser+MAXExtend.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/3/13.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "AVUser+MAXExtend.h"
#import "UIImage+MAXExtend.h"

typedef enum : NSUInteger {
    MAXImageStyleCircle,
    MAXImageStyleOrigin,
} MAXImageStyle;


@implementation AVUser (MAXExtend)

+ (NSCache *)userCache
{
    static NSCache * shareCache ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareCache = [[NSCache alloc] init];
    });
    return shareCache ;
}

+ (void)getUserWithObjectId:(NSString *)userID result:(void (^)(AVUser *user, NSError *error))result
{
    AVQuery * query = [AVQuery queryWithClassName:@"_User"];
    [query getObjectInBackgroundWithId:userID block:^(AVObject * _Nullable object, NSError * _Nullable error) {
        AVUser *user = (AVUser *)object ;
        result(user,error);
    }];
}

+ (instancetype)SyncLoadUserWithUserID:(NSString *)userID
{
    AVUser * savedUser = [[AVUser userCache] objectForKey:userID] ;
    if (savedUser) {
        return savedUser ;
    }
    AVQuery * query = [AVQuery queryWithClassName:@"_User"];
    
    NSError * error = nil ;
    
    AVUser * user = (AVUser *)[query getObjectWithId:userID error:&error] ;
    
    if (!error && user)
    {
        [[AVUser userCache] setObject:user forKey:userID];
        return user ;
    }
    else
    {
        MAXLog(@"%@,%@",userID,error);
    }
    return nil ;
}

+ (void)loadUserWithUsername:(NSString *)username result:(void(^)(AVUser * ,NSError *))result
{
    AVQuery * query =  [AVQuery queryWithClassName:kUsersListClass];
    [query whereKey:@"username" equalTo:username];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error && objects.count)
        {
            result(objects.firstObject,nil);
        }
        else
        {
            result(nil,error);
        }
    }];
}

+ (void)loadUserWithUserID:(NSString *)userID result:(void(^)(AVUser * ,NSError *))result
{
    AVUser * savedUser = [[AVUser userCache] objectForKey:userID] ;
    if (savedUser)
    {
        result(savedUser,nil);
    }
    else
    {
        AVQuery * query = [AVQuery queryWithClassName:kUsersListClass];
        [query getObjectInBackgroundWithId:userID block:^(AVObject * _Nullable object, NSError * _Nullable error) {
            if (!error && object)
            {
                AVUser * user = (AVUser *)object ;
                [[AVUser userCache] setObject:user forKey:userID];
            }
            result((AVUser *)object,error);
        }];
    }
}

+ (void)getOriginHeadImageForUser:(AVUser *)user result:(void (^)(UIImage *, NSError *))result
{
    [self getHeadImageForUser:user result:result imageStyle:MAXImageStyleOrigin];
}

+ (void)getCircleHeadImageForUser:(AVUser *)user result:(void(^)(UIImage *,NSError *))result
{
    [self getHeadImageForUser:user result:result imageStyle:MAXImageStyleCircle];
}

+ (void)getHeadImageForUser:(AVUser *)user result:(void(^)(UIImage *,NSError *))result imageStyle:(MAXImageStyle)style
{
    AVFile * circleHeadImage = user[kUserPropertyCircleHeadImage];
    
    if (style == MAXImageStyleCircle)
    {
        UIImage * image = [[AVUser userCache] objectForKey:circleHeadImage.objectId];
        if (image) {
            result(image,nil);
            return ;
        }
    }
    
    AVFile *headImg = (style == MAXImageStyleCircle ? user[kUserPropertyCircleHeadImage]:user[kUserPropertyHeadImage]);
    
    [headImg getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error)
     {
         if (data)
         {
             UIImage * image = [UIImage imageWithData:data];
             if (style==MAXImageStyleCircle)
             {
                 [[AVUser userCache] setObject:image forKey:circleHeadImage.objectId];
             }
             result(image,nil);
         }
         else
         {
             if (error.code == 149)
             {
                 [self getImageWithAVFile:headImg result:^(UIImage *image, NSError *error) {
                     if (!error && image && style==MAXImageStyleCircle)
                     {
                         [[AVUser userCache] setObject:image forKey:circleHeadImage.objectId ];
                     }
                         result(image,error);
                 }];
             }
             else
             {
                 if (result) {
                     result(nil,error);
                 }
             }
         }
     }];
}

+ (void)getImageWithAVFile:(AVFile *)file result:(void(^)(UIImage *,NSError *))result
{
    AVQuery * query = [AVQuery queryWithClassName:@"_File"];
    [query whereKey:@"objectId" equalTo:file.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects&&objects.count)
        {
            MAXLog(@"%@",objects.firstObject);
            AVFile *file = [AVFile fileWithAVObject:objects.firstObject];
            [file getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error)
             {
                 if (data)
                 {
                     UIImage * image = [UIImage imageWithData:data];
                     result(image,nil);
                 }
                 else
                 {
                     if (result)
                     {
                         result(nil,error);
                     }
                 }
             }];
        }
        else
        {
            if (result)
            {
                result(nil,error);
            }
        }
    }];
}

@end
