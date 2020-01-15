//
//  MAXCoreDataManager.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/2/27.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXCoreDataManager.h"
#import <CoreData/CoreData.h>
#import <WebKit/WebKit.h>
@interface MAXCoreDataManager()

@end

@implementation MAXCoreDataManager

+ (instancetype)shareManager
{
    static MAXCoreDataManager * single = nil ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        single = [[MAXCoreDataManager alloc] init];
    });
    return single ;
}

- (NSManagedObjectContext *)context
{
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSURL * url = [NSURL fileURLWithPath:[docsPath stringByAppendingPathComponent:@"stories.data"]];
    
    NSError *error = nil ;
    NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error];
    
    if (store == nil)
    {
        MAXLog(@"sqlite creat failure : %@",error.localizedDescription);
        return nil;
    }
    
    NSManagedObjectContext * context = [[NSManagedObjectContext alloc] init];
    context.persistentStoreCoordinator = psc ;
    return context ;
}

+ (BOOL)saveStory:(AVObject *)story content:(NSArray *)contents
{
    NSManagedObjectContext * context = [MAXCoreDataManager shareManager].context ;
    NSManagedObject * storyObj = [NSEntityDescription insertNewObjectForEntityForName:@"Story" inManagedObjectContext:context];
    [storyObj setValue:story.objectId forKey:@"objectId"];
    [storyObj setValue:contents forKey:@"contentArr"];
    NSError * error ;
    if (![context save:&error])
    {
//        abort() ;
        MAXAlert(@"save error : %@",error.localizedDescription);
        return NO ;
    }
    else
    {
        return YES ;
    }
}

+ (NSArray *)contentsOfStory:(AVObject *)story
{
    NSManagedObjectContext * context = [MAXCoreDataManager shareManager].context ;
    NSFetchRequest * req = [[NSFetchRequest alloc] init];
    req.entity = [NSEntityDescription entityForName:@"Story" inManagedObjectContext:context];
    req.predicate = [NSPredicate predicateWithFormat:@"objectId == %@",story.objectId];
    NSError * error = nil ;
    NSArray * objects  = [context executeFetchRequest:req error:&error];
    if (!error)
    {
        if (objects.count)
        {
            NSManagedObject * story = [objects lastObject];
            return [story valueForKey:@"contentArr"];
        }
        else
        {
            return nil ;
        }
    }
    else
    {
        MAXLog(@" check %@ contents error :%@",story[kStoryPropertyTitle],error);
//        abort() ;
        return nil ;
    }
}

+ (BOOL)updateContentsOfStory:(AVObject *)story contents:(NSArray *)contents
{
    NSManagedObjectContext * context = [MAXCoreDataManager shareManager].context ;
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    req.entity = [NSEntityDescription entityForName:@"Story" inManagedObjectContext:context];
    req.predicate = [NSPredicate predicateWithFormat:@"objectId == %@",story.objectId];
    NSError * error ;
    NSArray *objects = [context executeFetchRequest:req error:&error];
    if (!error)
    {
        if (objects.count)
        {
            NSManagedObject *storyObj = [objects lastObject];
            [storyObj setValue:contents forKey:@"contentArr"];
            NSError * saveError ;
            if (![context save:&saveError])
            {
//                abort();
                MAXLog(@"coreData updateSave %@ error:%@",story[kStoryPropertyTitle],saveError);
                return NO ;
            }
            else
            {
                return YES ;
            }
        }
        else
        {
            return [self saveStory:story content:contents];
        }
    }
    else
    {
        MAXLog(@"coreData updateCheck %@ error:%@",story[kStoryPropertyTitle],error);
        return NO ;
    }
}

+ (BOOL)deleteCacheOfStory:(AVObject *)story
{
    NSManagedObjectContext * context = [MAXCoreDataManager shareManager].context ;
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    req.entity = [NSEntityDescription entityForName:@"Story" inManagedObjectContext:context];
    req.predicate = [NSPredicate predicateWithFormat:@"objectId == %@",story.objectId];
    NSError * error ;
    NSArray *objects = [context executeFetchRequest:req error:&error];
    if (!error)
    {
        if (objects&&objects.count)
        {
            [context deleteObject:[objects lastObject]];
            NSError * saveError ;
            if (![context save:&saveError])
            {
//                abort() ;
                return NO;
            }
            else
            {
                return YES ;
            }
        }
        else
        {
            return NO ;
        }
    }
    else
    {
        return NO ;
    }
}

@end
