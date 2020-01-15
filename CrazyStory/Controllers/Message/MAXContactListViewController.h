//
//  MAXContactListViewController.h
//  CrazyStory
//
//  Created by youzu_Max on 2017/3/9.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "EaseUsersListViewController.h"
#import "MAXGroupListViewController.h" 
@interface MAXContactListViewController : EaseUsersListViewController

@property (strong, nonatomic) MAXGroupListViewController *groupController;

//好友请求变化时，更新好友请求未处理的个数
- (void)reloadApplyView;

//群组变化时，更新群组页面
- (void)reloadGroupView;

//好友个数变化时，重新获取数据
- (void)reloadDataSource;

//添加好友的操作被触发
- (void)addFriendAction;

@end
