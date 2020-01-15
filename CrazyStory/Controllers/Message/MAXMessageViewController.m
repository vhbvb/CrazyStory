//
//  MAXMessageViewController.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/1/23.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXMessageViewController.h"
#import "MAXLoginRegisterViewController.h"
#import "MAXCoreDataManager.h"
#import <CoreData/CoreData.h>
#import "MAXConversationListViewController.h"
#import "MAXContactListViewController.h"
#import "EaseUsersListViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "AVUser+MAXExtend.h"
#import "MAXApplyTableViewController.h"
#import "MAXEMHelper.h"

@interface MAXMessageViewController()
@property(nonatomic ,strong) MAXConversationListViewController *chatsViewController ;
@property(nonatomic ,strong) MAXContactListViewController *userListViewController ;
@end

@implementation MAXMessageViewController

- (void)viewDidLoad
{
    self.automaticallyAdjustsScrollViewInsets = NO ;
    self.navigationItem.titleView =
    ({
        UISegmentedControl * seg = [[UISegmentedControl alloc] initWithItems:@[@"会话",@"通讯录"]];
        seg.size = CGSizeMake(self.view.width/2.5, NavigationBarHeight-12.5);
        [seg setSelectedSegmentIndex:0];
        seg.tintColor = [UIColor darkGrayColor];
        [seg addTarget:self action:@selector(viewControllerSwitch:) forControlEvents:UIControlEventValueChanged];
        seg;
    });
}

- (void)loginEM
{
    [[EMClient sharedClient] loginWithUsername:[AVUser currentUser].objectId password:[AVUser currentUser].objectId completion:^(NSString *aUsername, EMError *aError) {
        if (!aError)
        {
            MAXLog(@"EM loginSuccess...");
            [[EMClient sharedClient] setApnsNickname:[AVUser currentUser].username];
            [[EMClient sharedClient].options setIsAutoLogin:YES] ;
            [self setup];
        }
        else
        {
            MAXAlert(@"即时通讯离线:%@",aError.errorDescription);
        }
    }];
}


- (void)setup
{
    _chatsViewController = [[MAXConversationListViewController alloc] init];
    _userListViewController = [[MAXContactListViewController alloc] init];
    
    _chatsViewController.view.frame = CGRectMake(0, NavigationBarOffsetValue, self.view.width, self.view.height-NavigationBarOffsetValue) ;
    _userListViewController.view.frame = CGRectMake(0, NavigationBarOffsetValue, self.view.width, self.view.height-NavigationBarOffsetValue) ;
    
    [self addChildViewController:_chatsViewController];
    [self addChildViewController:_userListViewController];
    [self.view addSubview:_chatsViewController.view];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [MAXEMHelper shareHelper].conversationListVC = _chatsViewController ;
    [MAXEMHelper shareHelper].contactViewVC = _userListViewController ;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupUntreatedApplyCount) name:@"setupUntreatedApplyCount" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupUnreadMessageCount) name:@"setupUnreadMessageCount" object:nil];

}

- (void)viewWillAppear:(BOOL)animated
{
    
    if (isLogined)
    {
        if ([EMClient sharedClient].isLoggedIn)
        {
            if(!_userListViewController && !_chatsViewController)
            {
                [self setup];
            }
            [self setupUnreadMessageCount];
            [self setupUntreatedApplyCount];
            [self.chatsViewController.tableView reloadData];
        }
        else
        {
            [self loginEM];
        }
    }
    else
    {
        [self.navigationController pushViewController:[[MAXLoginRegisterViewController alloc] init] animated:YES];
        self.hidesBottomBarWhenPushed = NO ;
    }
}

- (void)viewControllerSwitch:(UISegmentedControl *)seg
{
    switch (seg.selectedSegmentIndex) {
        case 0:
            [self transitionFromViewController:_userListViewController
                              toViewController:_chatsViewController
                                      duration:0.3
                                       options:UIViewAnimationOptionLayoutSubviews
                                    animations:nil
                                    completion:nil];
            break;
        case 1:
            [self transitionFromViewController:_chatsViewController
                              toViewController:_userListViewController
                                      duration:0.3
                                       options:UIViewAnimationOptionLayoutSubviews
                                    animations:nil
                                    completion:nil];
            break;
            
        default:
            break;
    }
}

// 统计未读消息数
-(void)setupUnreadMessageCount
{
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        unreadCount += conversation.unreadMessagesCount;
    }
    if (_chatsViewController)
    {
        if (unreadCount > 0)
        {
            self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i",(int)unreadCount];
        }else{
            self.tabBarItem.badgeValue = nil;
        }
    }
    
    UIApplication *application = [UIApplication sharedApplication];
    [application setApplicationIconBadgeNumber:unreadCount];
}

- (void)networkChanged:(EMConnectionState)connectionState
{
    _connectionState = connectionState;
    [_chatsViewController networkChanged:connectionState];
}

- (void)playSoundAndVibration
{
    NSTimeInterval timeInterval = [[NSDate date]
                                   timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        //如果距离上次响铃和震动时间太短, 则跳过响铃
        NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
        return;
    }
    
    //保存最后一次响铃时间
    self.lastPlaySoundDate = [NSDate date];
    
    // 收到消息时，播放音频
    [[EMCDDeviceManager sharedInstance] playNewMessageSound];
    // 收到消息时，震动
    [[EMCDDeviceManager sharedInstance] playVibration];
}


- (void)showNotificationWithMessage:(EMMessage *)message
{
    [EMClient sharedClient];
    
//    EMPushNotificationOptions
    
    EMPushOptions *options = [[EMClient sharedClient] pushOptions];
    NSString *alertBody = nil;
    if (options.displayStyle == EMPushDisplayStyleMessageSummary)
    {
        EMMessageBody *messageBody = message.body;
        NSString *messageStr = nil;
        switch (messageBody.type)
        {
            case EMMessageBodyTypeText:
            {
                messageStr = ((EMTextMessageBody *)messageBody).text;
            }
                break;
            case EMMessageBodyTypeImage:
            {
                messageStr = @"图片";
            }
                break;
            case EMMessageBodyTypeLocation:
            {
                messageStr = @"位置";
            }
                break;
            case EMMessageBodyTypeVoice:
            {
                messageStr = @"音频";
            }
                break;
            case EMMessageBodyTypeVideo:{
                messageStr = @"视频";
            }
                break;
            default:
                break;
        }
        
        do {
            NSString *title = [AVUser SyncLoadUserWithUserID:message.from].username ;
            
            if (message.chatType == EMChatTypeGroupChat) {
                NSDictionary *ext = message.ext;
                if (ext && ext[kGroupMessageAtList]) {
                    id target = ext[kGroupMessageAtList];
                    if ([target isKindOfClass:[NSString class]]) {
                        if ([kGroupMessageAtAll compare:target options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                            alertBody = [NSString stringWithFormat:@"%@%@", title, @"在群中@了我"];
                            break;
                        }
                    }
                    else if ([target isKindOfClass:[NSArray class]]) {
                        NSArray *atTargets = (NSArray*)target;
                        if ([atTargets containsObject:[EMClient sharedClient].currentUsername]) {
                            alertBody = [NSString stringWithFormat:@"%@%@", title, @"在群中@了我"];
                            break;
                        }
                    }
                }
                NSArray *groupArray = [[EMClient sharedClient].groupManager getJoinedGroups];
                for (EMGroup *group in groupArray) {
                    if ([group.groupId isEqualToString:message.conversationId]) {
                        title = [NSString stringWithFormat:@"%@(%@)", message.from, group.subject];
                        break;
                    }
                }
            }
            else if (message.chatType == EMChatTypeChatRoom)
            {
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                NSString *key = [NSString stringWithFormat:@"OnceJoinedChatrooms_%@", [[EMClient sharedClient] currentUsername]];
                NSMutableDictionary *chatrooms = [NSMutableDictionary dictionaryWithDictionary:[ud objectForKey:key]];
                NSString *chatroomName = [chatrooms objectForKey:message.conversationId];
                if (chatroomName)
                {
                    title = [NSString stringWithFormat:@"%@(%@)", message.from, chatroomName];
                }
            }
            
            alertBody = [NSString stringWithFormat:@"%@:%@", title, messageStr];
        } while (0);
    }
    else{
        alertBody = @"你有一条新的消息";
    }
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastPlaySoundDate];
    BOOL playSound = NO;
    if (!self.lastPlaySoundDate || timeInterval >= kDefaultPlaySoundInterval) {
        self.lastPlaySoundDate = [NSDate date];
        playSound = YES;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithInt:message.chatType] forKey:kMessageType];
    [userInfo setObject:message.conversationId forKey:kConversationChatter];
    
    //发送本地推送
    if (NSClassFromString(@"UNUserNotificationCenter")) {
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.01 repeats:NO];
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        if (playSound) {
            content.sound = [UNNotificationSound defaultSound];
        }
        content.body =alertBody;
        content.userInfo = userInfo;
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:message.messageId content:content trigger:trigger];
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
    }
    else
    {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = [NSDate date]; //触发通知的时间
        notification.alertBody = alertBody;
        notification.alertAction = NSLocalizedString(@"open", @"Open");
        notification.timeZone = [NSTimeZone defaultTimeZone];
        if (playSound)
        {
            notification.soundName = UILocalNotificationDefaultSoundName;
        }
        notification.userInfo = userInfo;
        
        //发送通知
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

- (void)setupUntreatedApplyCount
{
    NSInteger unreadCount = [[[MAXApplyTableViewController shareController] dataSource] count];
    if (_userListViewController) {
        if (unreadCount > 0) {
            self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i",(int)unreadCount];
        }else{
            self.tabBarItem.badgeValue = nil;
        }
    }
}


@end
