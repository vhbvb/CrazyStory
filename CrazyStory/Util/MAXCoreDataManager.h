//
//  MAXCoreDataManager.h
//  CrazyStory
//
//  Created by youzu_Max on 2017/2/27.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MAXCoreDataManager : NSObject

+ (instancetype)shareManager ;

- (NSManagedObjectContext *) context ;

+ (BOOL) saveStory:(AVObject *)story content:(NSArray *)contents ;

+ (NSArray *)contentsOfStory:(AVObject *)story ;

+ (BOOL)updateContentsOfStory:(AVObject *)story contents:(NSArray *)contents ;

+ (BOOL)deleteCacheOfStory:(AVObject *)story ;

@end
