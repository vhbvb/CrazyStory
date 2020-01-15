//
//  MAXSetViewController.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/2/4.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXSetViewController.h"
#import "MAXCompleteUserInfoViewController.h"
#import "MAXLoginRegisterViewController.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import "MAXEMHelper.h"
#import "MAXBuyViewController.h"

@interface MAXSetViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic , strong) UITableView * setTableView ;

@end

@implementation MAXSetViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES ;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup
{
    self.navigationItem.title = @"设 置";
    self.navigationItem.backBarButtonItem.title = @"返回" ;
    self.setTableView =
    ({
        UITableView * setTableView  = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        setTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        setTableView.delegate = self ;
        setTableView.dataSource = self ;
        [self.view addSubview:setTableView];
        setTableView;
    });
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2 ;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 3 ;
        case 1:
            return 1 ;
        default:
            return 0 ;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                    reuseIdentifier:@"setTableViewCellReuseIdentifier"];
    if (indexPath.section)
    {
        cell.textLabel.text = @"购买";
    }
    else
    {
        if (indexPath.row == 1)
        {
           cell.textLabel.text = @"修改个人信息";
        }
        else if (indexPath.row == 0)
        {
            cell.textLabel.text = @"邀请好友";
        }
        else
        {
            cell.textLabel.text = @"退出登录";
        }
    }
    return cell ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:YES];
    
    if (!indexPath.section)
    {
        switch (indexPath.row)
        {
            case 0:
                [self inviteFriends];
                break;
            case 1:
                [self reviseInfo];
                break;
            case 2:
                [self logout];
            default:
                break;
        }
    }
    else
    {
        [self buyInk];
    }
}

- (void)inviteFriends
{
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    NSString * title = @"一款有趣的app";
    NSString * text = [NSString stringWithFormat:@"来一起玩接龙啊，故事和成语随你选 😄 (邀请码:%@)",[AVUser currentUser].objectId];
    NSString * url = @"www.mob.com/crazyStory" ;
    
    [shareParams SSDKSetupShareParamsByText:text
                                     images:nil
                                        url:[NSURL URLWithString:url]
                                      title:title
                                       type:SSDKContentTypeAuto];
    //有的平台要客户端分享需要加此方法，例如微博
    [shareParams SSDKEnableUseClientShare];
    [ShareSDK showShareActionSheet:nil
                             items:nil
                       shareParams:shareParams
               onShareStateChanged:^(SSDKResponseState state,
                                     SSDKPlatformType platformType,
                                     NSDictionary *userData,
                                     SSDKContentEntity *contentEntity,
                                     NSError *error,
                                     BOOL end){
                   switch (state)
                   {
                       case SSDKResponseStateSuccess:
                       {
                           [SVProgressHUD showSuccessWithStatus:@"分享成功"];
                           [SVProgressHUD dismissWithDelay:1.25];
                           break;
                       }
                       case SSDKResponseStateFail:
                       {
                           MAXAlert(@"分享失败 : %@",error);
                           break;
                       }
                       case SSDKResponseStateCancel:
                       {
                           MAXLog(@"取消分享");
                       }
                       case SSDKResponseStateBegin:
                       {
                           MAXLog(@"开始分享？");
                       }
                       default:
                           break;
                   }
               }];
}

- (void)reviseInfo
{
    if (!isLogined)
    {
        [SVProgressHUD showInfoWithStatus:@"请先登录"];
        [SVProgressHUD dismissWithDelay:1.5 completion:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    
    [[AVUser currentUser] isAuthenticatedWithSessionToken:[AVUser currentUser].sessionToken callback:^(BOOL succeeded, NSError * _Nullable error)
    {
        MAXLog(@"succeeded -> %zd ,error :%@",succeeded,error);
        if (succeeded)
        {
            [self.navigationController pushViewController:[MAXCompleteUserInfoViewController currentUser] animated:YES];
        }
        else
        {
            MAXLog(@"fault error :%@",error.localizedDescription);
            if (error.code==-1001 || error.code ==-1009)
            {
                MAXAlert(@"网络好像有点问题，请检查网络后重试");
            }
            else
            {
                [self.navigationController pushViewController:[[MAXLoginRegisterViewController alloc] init] animated:YES];
            }
        }
    }];
}

- (void)logout
{
    [AVUser logOut] ;
    isLogined = NO ;
    [[EMClient sharedClient] logout:YES completion:^(EMError *aError) {
        MAXLog(@"EMClient loginOut %@",aError.errorDescription);
        if (!aError) {
            [[MAXEMHelper shareHelper].contactViewVC.tableView reloadData];
        }
    }];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)buyInk
{
    MAXBuyViewController * vc = [[MAXBuyViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}
@end
