//
//  MAXChatGroupDetailViewController.h
//  CrazyStory
//
//  Created by youzu_Max on 2017/3/10.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "EaseRefreshTableViewController.h"
@class EMGroup ;

@interface MAXChatGroupDetailViewController : EaseRefreshTableViewController

- (instancetype)initWithGroup:(EMGroup *)chatGroup;

- (instancetype)initWithGroupId:(NSString *)chatGroupId;

@end
