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
#import "UIImage+MAXExtend.h"

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
    
    if (self.isCurrentUser) {
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
        cell.detailTextLabel.text = @"立即绑定" ;
        switch (indexPath.row)
        {
            case 0:
                cell.textLabel.text = @"新浪微博(未绑定)";
                break;
            case 1:
                cell.textLabel.text = @"QQ(未绑定)";
                break;
            default:
                cell.textLabel.text = @"微信(未绑定)";
                break;
        }
    }
    return cell ;
}

// 请求头像图片。
- (void)configHeadImgForCell:(UITableViewCell *)cell
{
    cell.textLabel.text = @"头像" ;
    
    [UIImage getHeadImageForUser:[AVUser currentUser] result:^(UIImage *headImg, NSError *error) {
        if (!error&&headImg) {
            UIImageView * headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
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
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.isCurrentUser) {
        return ;
    }
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:YES];
    
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
        
        //第三方登录
        
    }
    
    //操作；
}

- (void) setHeadImg
{
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:nil message:@"不要上传不雅头像哦~" preferredStyle:UIAlertControllerStyleActionSheet];\
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
    UIImage *editedImg = [info[UIImagePickerControllerEditedImage] imageScaledToSize:CGSizeMake(300, 300)];
    AVFile * fileData = [AVFile fileWithData:UIImagePNGRepresentation(editedImg)];
    [AVUser currentUser][kUserPropertyHeadImage] = fileData ;
    
    [[AVUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded)
        {
            UITableViewCell * cell = [_userInfoTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            UIImageView * headImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
            headImg.image = editedImg ;
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
    if (self.isCurrentUser && _flag) {
        [_userInfoTableView reloadData];
    }
}

@end
