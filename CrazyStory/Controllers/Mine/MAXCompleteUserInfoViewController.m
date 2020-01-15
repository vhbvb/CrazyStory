//
//  MAXCompleteUserInfoViewController.m
//  CrazyStory
//
//  Created by youzu_Max on 2017/2/7.
//  Copyright © 2017年 youzu. All rights reserved.
//

#import "MAXCompleteUserInfoViewController.h"
#import "MAXSetUserNameViewController.h"
#import "MAXSetEmailViewController.h"
#import "MAXSetPhoneNumberViewController.h"
#import "MAXSetIntroductionViewController.h"
#import "MAXSetEmailViewController.h"
#import "MAXVerifyPhoneNumberViewController.h"
#import "AVUser+MAXExtend.h"
#import "UIImage+MAXExtend.h"
#import <LeanCloudSocial/AVUser+SNS.h>
#import <ShareSDK/ShareSDK.h>
#import "MAXEMHelper.h"

@interface MAXCompleteUserInfoViewController ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    BOOL _flag ;//判断是pop回来还是push进
}
@property(nonatomic, strong) UITableView * userInfoTableView ;
@property(nonatomic, strong) AVUser * user ;
@property(nonatomic, assign) BOOL isCurrentUser ;

@end

@implementation MAXCompleteUserInfoViewController

- (instancetype)initWithUserInfo:(AVUser *)user
{
    if (self = [super init])
    {
        _user = user ;
        MAXLog(@"%@",_user);
        self.hidesBottomBarWhenPushed = YES ;
    }
    return self ;
}

+ (instancetype)currentUser
{
    MAXCompleteUserInfoViewController * userVc = [[self alloc] initWithUserInfo:[AVUser currentUser]];
    userVc.isCurrentUser = YES ;
    return userVc ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _flag = YES ;
    [self configUI];
}

- (void)configUI
{
    if (!self.isCurrentUser) {
        self.navigationItem.title = _user.username ;
    }
    self.navigationItem.title = @"我的账号" ;
    
    self.userInfoTableView =
    ({
        UITableView * userInfoTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        
        if (self.isCurrentUser)
        {
            userInfoTableView.tableFooterView =
            ({
                UIButton * footLoginOutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [footLoginOutBtn addTarget:self action:@selector(loginOut:) forControlEvents:UIControlEventTouchUpInside];
                footLoginOutBtn.frame = CGRectMake(0, 0, self.view.width, 44) ;
                footLoginOutBtn.backgroundColor = [UIColor whiteColor];
                [footLoginOutBtn setTitle:@"退出当前账号" forState:UIControlStateNormal];
                [footLoginOutBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                footLoginOutBtn ;
            });

        }
        
        [self.view addSubview:userInfoTableView];
        userInfoTableView.delegate = self ;
        userInfoTableView.dataSource = self ;
        userInfoTableView ;
    });
}

#pragma mark UITableDataSource and UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            if (self.isCurrentUser) {
                return 6 ;
            }else{
                return 5 ;
            }
        case 1:
            return 3 ;
        default:
            return 0 ;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    if (self.isCurrentUser)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator ;
    }
    
    if (!indexPath.section)
    {
        switch (indexPath.row)
        {
            case 0:
                cell.textLabel.text = @"昵称" ;
                cell.detailTextLabel.text = _user.username ;
                break;
            case 1:
                [self configHeadImgForCell:cell];
                break;
            case 2:
                cell.textLabel.text = @"简介" ;
                cell.detailTextLabel.text = _user[kUserPropertyInstroduction] ;
                cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
                break;
            case 3:
                cell.textLabel.text = @"电话号码" ;
                cell.detailTextLabel.text = _user.mobilePhoneNumber ;
                break;
            case 4:
                cell.textLabel.text = @"邮箱" ;
                cell.detailTextLabel.text = _user.email ;
                break;
            case 5:
                cell.textLabel.text = @"修改密码" ;
            default:
                break;
        }
        
    }
    else
    {
        NSDictionary * authData = _user[@"authData"];
        switch (indexPath.row)
        {
            case 0:
                if (authData && [authData.allKeys containsObject:@"weibo"])
                {
                    cell.textLabel.text = @"新浪微博(已绑定)";
                    cell.detailTextLabel.text = @"取消绑定" ;
                }
                else
                {
                    cell.textLabel.text = @"新浪微博(未绑定)";
                    cell.detailTextLabel.text = @"立即绑定" ;
                }
                break;
            case 1:
                if (authData && [authData.allKeys containsObject:@"qq"])
                {
                    cell.textLabel.text = @"QQ(已绑定)";
                    cell.detailTextLabel.text = @"取消绑定" ;
                }
                else
                {
                    cell.textLabel.text = @"QQ(未绑定)";
                    cell.detailTextLabel.text = @"立即绑定" ;
                }
                break;
            default:
                if (authData && [authData.allKeys containsObject:@"weixin"])
                {
                    cell.textLabel.text = @"微信(已绑定)";
                    cell.detailTextLabel.text = @"取消绑定" ;
                }
                else
                {
                    cell.textLabel.text = @"微信(未绑定)";
                    cell.detailTextLabel.text = @"立即绑定" ;
                }
                break;
        }
    }
    return cell ;
}

// 请求头像图片。
- (void)configHeadImgForCell:(UITableViewCell *)cell
{
    cell.textLabel.text = @"头像" ;
    
    [AVUser getCircleHeadImageForUser:[AVUser currentUser] result:^(UIImage *headImg, NSError *error) {
        if (!error&&headImg) {
            UIImageView * headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 39, 39)];
            headImgView.image = headImg;
            cell.accessoryView = headImgView ;
        }else{
            cell.detailTextLabel.text = @"null";
        }
    }];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (!section) {
        return @"账号";
    }else{
        return @"绑定";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 33 ;
}

- (void)loginOut:(UIButton *)loginOutBtn
{
    [AVUser logOut] ;
    isLogined = NO ;
    [self.navigationController popViewControllerAnimated:YES];
    [[EMClient sharedClient] logout:YES completion:^(EMError *aError) {
        MAXLog(@"EMClient loginOut %@",aError.errorDescription);
        if (!aError) {
            [[MAXEMHelper shareHelper].contactViewVC.tableView reloadData];
        }
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:YES];
    
    if (!self.isCurrentUser)
    {
        return ;
    }
    else
    {
        [[AVUser currentUser] isAuthenticatedWithSessionToken:[AVUser currentUser].sessionToken callback:^(BOOL succeeded, NSError * _Nullable error) {
            if (!succeeded)
            {
                if (error.code==-1001 && error.code==-1009)
                {
                    MAXAlert(@"网络连接超时，请检查重试");
                    return ;
                }
                else
                {
                    [self loginOut:nil];
                    return ;
                }
            }
            else
            {
                if (!indexPath.section)
                {
                    switch (indexPath.row) {
                        case 0:
                            [self.navigationController pushViewController:[[MAXSetUserNameViewController alloc] init] animated:YES];
                            break;
                        case 1:
                            [self setHeadImg];
                            break;
                        case 2:
                            [self.navigationController pushViewController:[[MAXSetIntroductionViewController alloc] init] animated:YES];
                            break;
                        case 3:
                            [self.navigationController pushViewController:[[MAXSetPhoneNumberViewController alloc] init] animated:YES];
                            break;
                        case 4:
                            [self.navigationController pushViewController:[[MAXSetEmailViewController alloc] init] animated:YES];
                            break;
                        case 5:
                            [self.navigationController pushViewController:[[MAXVerifyPhoneNumberViewController alloc] init] animated:YES];
                            break;
                        default:
                            break;
                    }
                }
                else
                {
                    NSDictionary * authData = _user[@"authData"];
                    switch (indexPath.row)
                    {
                        case 0:
                            if (authData && [authData.allKeys containsObject:@"weibo"])
                            {
                                [self cancelBindSinaWeibo];
                            }
                            else
                            {
                                [self bindWeiChat];
                            }
                            break;
                        case 1:
                            if (authData && [authData.allKeys containsObject:@"qq"])
                            {
                                [self cancelBindQQ];
                            }
                            else
                            {
                                [self bindQQ];
                            }
                            break;
                        default:
                            if (authData && [authData.allKeys containsObject:@"weixin"])
                            {
                                [self cancelBindWeiChat];
                            }
                            else
                            {
                                [self bindWeiChat];
                            }
                            break;
                    }
                }
            }
        }];
    }
}

- (void) setHeadImg
{
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:nil message:@"不要上传不雅头像哦~" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * takePhoto = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self takePhoto];
    }];
    UIAlertAction * pickImg = [UIAlertAction actionWithTitle:@"从相册选取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self pickImgInAlbum];
    }];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:takePhoto];
    [alertVC addAction:pickImg];
    [alertVC addAction:cancel];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)takePhoto
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [SVProgressHUD showInfoWithStatus:@"相机不可用.=_="];
        return ;
    }
    
    UIImagePickerController * cameraVc = [[UIImagePickerController alloc] init];
    cameraVc.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraVc.allowsEditing = YES ;
    cameraVc.delegate = self ;
    [self presentViewController:cameraVc animated:YES completion:nil];
}

- (void)pickImgInAlbum
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        [SVProgressHUD showInfoWithStatus:@"图库不可用.=_="];
        return ;
    }
    
    UIImagePickerController * cameraVc = [[UIImagePickerController alloc] init];
    cameraVc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    cameraVc.allowsEditing = YES ;
    cameraVc.delegate = self ;
    [self presentViewController:cameraVc animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *editedImg = info[UIImagePickerControllerEditedImage];
    UIImage *circleImg = [[editedImg imageScaledToSize:CGSizeMake(150, 150)] circleImageWithBorderWidth:1 borderColor:[UIColor whiteColor]];
    AVFile * editedImgData = [AVFile fileWithData:UIImagePNGRepresentation(editedImg)];
    [AVUser currentUser][kUserPropertyHeadImage] = editedImgData ;
    AVFile * circleImgData = [AVFile fileWithData:UIImagePNGRepresentation(circleImg)];
    [AVUser currentUser][kUserPropertyCircleHeadImage] = circleImgData ;
    
    [[AVUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded)
        {
            UITableViewCell * cell = [_userInfoTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            UIImageView * headImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
            headImg.image = circleImg ;
            cell.accessoryView = headImg ;
            cell.detailTextLabel.text = nil ;
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"头像设置失败 : %@",error.localizedDescription]];
        }
    }];
    
    [picker dismissViewControllerAnimated:YES completion:nil];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.isCurrentUser && _flag)
    {
        [_userInfoTableView reloadData];
    }
}

#pragma mark - 第三方账号绑定

- (void) bindSinaWeibo
{
    
    __weak typeof(self) weakSelf = self ;
    [ShareSDK getUserInfo:SSDKPlatformTypeSinaWeibo onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        if (state == SSDKResponseStateSuccess)
        {
            NSDictionary * authData = @{
                                        @"uid": user.credential.uid,
                                        @"access_token": user.credential.token,
                                        @"expiration_in": user.credential.rawData[@"expires_in"],
                                        };
            [SVProgressHUD setStatus:@"正在绑定..."];
            [_user addAuthData:authData platform:AVOSCloudSNSPlatformWeiBo block:^(AVUser * _Nullable user, NSError * _Nullable error) {
                if (!error)
                {
                    [SVProgressHUD showSuccessWithStatus:@"已完成绑定"];
                    UITableViewCell * cell = [weakSelf.userInfoTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
                    cell.textLabel.text = @"新浪微博(已绑定)";
                    cell.detailTextLabel.text = @"取消绑定" ;
                    [SVProgressHUD dismissWithDelay:1.25];
                    MAXLog(@"%@",user);
                }
                else
                {
                    [SVProgressHUD dismiss];
                    MAXAlert(@"bind error:%@",error.localizedDescription);
                }
            }];
        }
        else if (state == SSDKResponseStateFail)
        {
            MAXAlert(@"%@",error);
        }
    }];
}

- (void) bindQQ
{
    __weak typeof(self) weakSelf = self ;
    [ShareSDK getUserInfo:SSDKPlatformTypeQQ onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        if (state == SSDKResponseStateSuccess)
        {
            NSDictionary * authData = @{
                                        @"openid": user.credential.uid,
                                        @"access_token": user.credential.token,
                                        @"expires_in": user.credential.rawData[@"expires_in"],
                                        };
            [SVProgressHUD setStatus:@"正在绑定..."];
            [_user addAuthData:authData platform:AVOSCloudSNSPlatformQQ block:^(AVUser * _Nullable user, NSError * _Nullable error) {
                if (!error)
                {
                    [SVProgressHUD showSuccessWithStatus:@"已完成绑定"];
                    UITableViewCell * cell = [weakSelf.userInfoTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
                    cell.textLabel.text = @"QQ(已绑定)";
                    cell.detailTextLabel.text = @"取消绑定" ;
                    [SVProgressHUD dismissWithDelay:1.25];
                    MAXLog(@"%@",user);
                }
                else
                {
                    [SVProgressHUD dismiss];
                    MAXAlert(@"bind error:%@",error.localizedDescription);
                }
            }];

        }
        else if (state == SSDKResponseStateFail)
        {
            MAXAlert(@"%@",error);
        }
    }];

}

- (void)bindWeiChat
{
    __weak typeof(self) weakSelf = self ;
    [ShareSDK getUserInfo:SSDKPlatformTypeWechat onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        if (state == SSDKResponseStateSuccess)
        {
            NSDictionary * authData = @{
                                        @"openid": user.credential.uid,
                                        @"access_token": user.credential.token,
                                        @"expires_in": user.credential.rawData[@"expires_in"],
                                        };
            [SVProgressHUD setStatus:@"正在绑定..."];
            [_user addAuthData:authData platform:AVOSCloudSNSPlatformWeiXin block:^(AVUser * _Nullable user, NSError * _Nullable error) {
                if (!error)
                {
                    [SVProgressHUD showSuccessWithStatus:@"已完成绑定"];
                    UITableViewCell * cell = [weakSelf.userInfoTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]];
                    cell.textLabel.text = @"微信(已绑定)";
                    cell.detailTextLabel.text = @"取消绑定" ;
                    [SVProgressHUD dismissWithDelay:1.25];
                    MAXLog(@"%@",user);
                }
                else
                {
                    [SVProgressHUD dismiss];
                    MAXAlert(@"bind error:%@",error.localizedDescription);
                }
            }];
        }
        else if (state == SSDKResponseStateFail)
        {
            MAXAlert(@"%@",error);
        }
    }];
}

#pragma mark - 解绑第三方账户

- (void) cancelBindSinaWeibo
{
    __weak typeof(self) weakSelf = self ;
    
    UIAlertController * vc = [UIAlertController alertControllerWithTitle:@"注意" message:@"取消绑定后将无法通过微博账户登录此账户,只能用用户名或电话号码通过密码登录" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"解绑" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SVProgressHUD showWithStatus:@"正在解除绑定"];
        [_user deleteAuthDataForPlatform:AVOSCloudSNSPlatformWeiBo block:^(AVUser * _Nullable user, NSError * _Nullable error) {
            if (!error)
            {
                [SVProgressHUD showSuccessWithStatus:@"已解除绑定"];
                [SVProgressHUD dismissWithDelay:1.25];
                MAXLog(@"%@",user);
                UITableViewCell * cell = [weakSelf.userInfoTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
                cell.textLabel.text = @"新浪微博(未绑定)";
                cell.detailTextLabel.text = @"立即绑定" ;
            }
            else
            {
                [SVProgressHUD dismiss];
                MAXAlert(@"%@",error.localizedDescription);
            }
        }];
    }];
    [vc addAction:okAction];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [vc addAction:cancel];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void) cancelBindQQ
{
    __weak typeof(self) weakSelf = self ;

    UIAlertController * vc = [UIAlertController alertControllerWithTitle:@"注意" message:@"取消绑定后将无法通过QQ登录此账户,只能通过用户名或电话号码登录" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"解绑" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SVProgressHUD showWithStatus:@"正在解除绑定"];
        [_user deleteAuthDataForPlatform:AVOSCloudSNSPlatformQQ block:^(AVUser * _Nullable user, NSError * _Nullable error) {
            if (!error)
            {
                [SVProgressHUD showSuccessWithStatus:@"已解除绑定"];
                [SVProgressHUD dismissWithDelay:1.25];
                MAXLog(@"%@",user);
                UITableViewCell * cell = [weakSelf.userInfoTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
                cell.textLabel.text = @"QQ(未绑定)";
                cell.detailTextLabel.text = @"立即绑定" ;
            }
            else
            {
                [SVProgressHUD dismiss];
                MAXAlert(@"%@",error);
            }
        }];
        
    }];
    [vc addAction:okAction];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [vc addAction:cancel];
    [self presentViewController:vc animated:YES completion:nil];}

- (void) cancelBindWeiChat
{
    __weak typeof(self) weakSelf = self ;
    
    UIAlertController * vc = [UIAlertController alertControllerWithTitle:@"注意" message:@"取消绑定后将无法通过微信账户登录此账户,只能通过用户名或电话号码登录" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"解绑" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SVProgressHUD showWithStatus:@"正在解除绑定"];
        [_user deleteAuthDataForPlatform:AVOSCloudSNSPlatformWeiXin block:^(AVUser * _Nullable user, NSError * _Nullable error) {
            if (!error)
            {
                [SVProgressHUD showSuccessWithStatus:@"已解除绑定"];
                [SVProgressHUD dismissWithDelay:1.25];
                MAXLog(@"%@",user);
                UITableViewCell * cell = [weakSelf.userInfoTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]];
                cell.textLabel.text = @"微信(未绑定)";
                cell.detailTextLabel.text = @"立即绑定" ;
            }
            else
            {
                [SVProgressHUD dismiss];
                MAXAlert(@"%@",error.localizedDescription);
            }
        }];
        
    }];
    [vc addAction:okAction];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [vc addAction:cancel];
    [self presentViewController:vc animated:YES completion:nil];
}


@end
