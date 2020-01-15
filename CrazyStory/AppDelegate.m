//
//  AppDelegate.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/1/23.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "AppDelegate.h"
#import "MAXMainViewController.h"
#import "MAXMessageViewController.h"
#import "MAXUserDetailsViewController.h"
#import "MAXLoginRegisterViewController.h"

#import <AVOSCloud/AVOSCloud.h>

#import <SMS_SDK/SMSSDK+ContactFriends.h>

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "WeiboSDK.h"

#import "EaseUI.h"
#import "MAXEMHelper.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self registSDKs];
    [[EaseSDKHelper shareHelper] hyphenateApplication:application
                        didFinishLaunchingWithOptions:launchOptions
                                               appkey:kEaseMobAppkey
                                         apnsCertName:kCertName
                                          otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:YES]}];
    
    [self checkLoginState];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UITabBarController *basicTabBarVC = [[UITabBarController alloc] init];
    basicTabBarVC.viewControllers = [self setupChildViewControllers];
    self.window.rootViewController = basicTabBarVC;
    self.window.backgroundColor = [UIColor whiteColor] ;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)checkLoginState
{
    if (![AVUser currentUser])
    {
        MAXLog(@"未登录，user为nil");
    }
    
    [[AVUser currentUser] isAuthenticatedWithSessionToken:[AVUser currentUser].sessionToken callback:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded)
        {
            MAXLog(@"用户已经登录 :%@",[AVUser currentUser].password);
            self.Logined = YES ;
        }
        else
        {
            MAXLog(@"未登录：%@",error);
            [[EMClient sharedClient] logout:YES completion:^(EMError *aError) {
                MAXLog(@"EMClient loginOut %@",aError.errorDescription);
            }];
        }
    }];
}

- (void) registSDKs
{
    //LeanCloud
    [AVOSCloud setApplicationId:kLeanCloudAppID clientKey:kLeanCloudAppKey];
    [AVOSCloud setAllLogsEnabled:NO];
    [AVLogger setAllLogsEnabled:NO];
    
//    [SMSSDK registerApp:kSMSSDKAppKey withSecret:kSMSSDKAppSecret];
    [SMSSDK enableAppContactFriends:NO];
    
    [self registShareSDK];
    
    EMOptions *options = [EMOptions optionsWithAppkey:kEaseMobAppkey];
    options.apnsCertName = kCertName;
    [[EMClient sharedClient] pushOptions];
    [[EMClient sharedClient] initializeSDKWithOptions:options];
    [self registNotification];
    [[EMClient sharedClient] getPushNotificationOptionsFromServerWithCompletion:^(EMPushOptions *aOptions, EMError *aError) {
        MAXLog(@"%@,%@",aOptions,aError.errorDescription);
    }];
    
}

- (void)registNotification
{
    //iOS8以上 注册APNS
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge |
        UIUserNotificationTypeSound |
        UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    else
    {
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeSound |
        UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
    }
}

- (NSArray *) setupChildViewControllers
{
    MAXMainViewController *mainVC = [[MAXMainViewController alloc] init];
    MAXMessageViewController *messageVC = [[MAXMessageViewController alloc] init];
    MAXUserDetailsViewController *mineVC = [MAXUserDetailsViewController currentUser];
    
    mainVC.tabBarItem.image = [UIImage imageNamed:@"tabBar_essence_icon"];
    messageVC.tabBarItem.image = [UIImage imageNamed:@"tabBar_new_icon"];
    mineVC.tabBarItem.image = [UIImage imageNamed:@"tabBar_friendTrends_icon"];
    
    mainVC.tabBarItem.title = @"主页" ;
    messageVC.tabBarItem.title = @"消息" ;
    mineVC.tabBarItem.title = @"我的" ;
    
    UINavigationController *messageNav = [[UINavigationController alloc] initWithRootViewController:messageVC];
    UINavigationController *mainNav = [[UINavigationController alloc] initWithRootViewController:mainVC];
    UINavigationController *mineNav = [[UINavigationController alloc] initWithRootViewController:mineVC];
    
    [MAXEMHelper shareHelper].mainVC = messageVC ;
    
    return @[mainNav,messageNav,mineNav];
}

- (void)registShareSDK
{

    [ShareSDK registerActivePlatforms:@[@(SSDKPlatformTypeQQ),
                                        @(SSDKPlatformTypeMail),
                                        @(SSDKPlatformTypeSMS),
                                        @(SSDKPlatformTypeWechat),
                                        @(SSDKPlatformTypeSinaWeibo)]
                             onImport:^(SSDKPlatformType platformType)
                            {
                                switch (platformType)
                                {
                                    case SSDKPlatformTypeWechat:
                                        [ShareSDKConnector connectWeChat:[WXApi class]];
                                        break;
                                    case SSDKPlatformTypeSinaWeibo:
                                        [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                                        break;
                                    case SSDKPlatformTypeQQ:
                                        [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                                        break;
                                    default:
                                        break;
                                }

                            } onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
                            {
                                switch (platformType)
                                {
                                    case SSDKPlatformTypeSinaWeibo:
                                        //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                                        [appInfo SSDKSetupSinaWeiboByAppKey:kSinaAppkey
                                                                  appSecret:kSinaAppSecret
                                                                redirectUri:@"http://www.sharesdk.cn"
                                                                   authType:SSDKAuthTypeBoth];
                                        break;
                                        
                                    case SSDKPlatformTypeWechat:
                                        [appInfo SSDKSetupWeChatByAppId:kWeChatPublicAppID
                                                              appSecret:kWeChatPublicAppSecret];
                                        break;
                                        
                                    case SSDKPlatformTypeQQ:
                                        [appInfo SSDKSetupQQByAppId:kQQAppID
                                                             appKey:kQQAppSecret
                                                           authType:SSDKAuthTypeBoth];
                                        break;
                                        
                                    default:
                                        break;
                                }

                            }];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationWillEnterForeground:application];
}

// 将得到的deviceToken传给SDK
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[EMClient sharedClient] bindDeviceToken:deviceToken];
}

// 注册deviceToken失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"-----> error -- %@",error);
}

@end
